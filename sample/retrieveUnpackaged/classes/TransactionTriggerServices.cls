/**
* @author mfrizzell
* @description Used by TransactionTrigger to process record updates
*/ 
public class TransactionTriggerServices  {
	
	public static FINAL String STATUS_PMT_PENDING = 'Payment Pending';
	public static FINAL String STATUS_PMT_RECD = 'Payment Received';
	public static FINAL String STATUS_CLOSED_WON = 'Closed Won';
	public static FINAL String TRANS_ERROR = 'Error';
	public static FINAL String TRANS_SUCCESS = 'Success';
	public static FINAL String OPP_TYPE_PROSPECT = 'Prospect';
	public static FINAL String OPP_TYPE_MEMBER = 'Member';


	/**
	* @description Find opportunity that is missing on transaction (item 6859)
	* @param transIds Set of transaction IDs to process
	*/
	public static void findOpportunity(Set<Id> transIds) {
		List<SObject> updates = new List<SObject>();
		List<KGRenewal__Transaction__c> transactions = new List<KGRenewal__Transaction__c>();
		
		try { 
			transactions = [SELECT Id, KGRenewal__Opportunity__c, KGRenewal__Invoice__c 
							FROM KGRenewal__Transaction__c 
							WHERE Id IN :transIds];
		}
		catch (QueryException ex) {
			System.debug('Error getting transactions: ' + ex.getTypeName() + ' - ' + ex.getMessage());
			return;
		}

		Map<Id, Id> oppToInvoice = new Map<Id, Id>();
		for (KGRenewal__Invoice__c inv : [SELECT Id, KGRenewal__Opportunity__c 
										  FROM KGRenewal__Invoice__c 
										  WHERE Id IN :Pluck.ids('KGRenewal__Invoice__c', transactions)] ) 
		{
			oppToInvoice.put(inv.Id, inv.KGRenewal__Opportunity__c);
		}
		
		for (KGRenewal__Transaction__c trans : transactions) {
			if (trans.KGRenewal__Opportunity__c == null) {
				System.debug('+++ Item 6859');
				Id oppId = oppToInvoice.get(trans.KGRenewal__Invoice__c);
				System.debug('+++ oppId: ' + oppId);
				if (oppId != null) {
					trans.KGRenewal__Opportunity__c = oppId;
					updates.add(trans);
				}
			}
		}
		if (updates.size() > 0) { 
			updateRecords(updates);
		}
		updateOppBalance(transIds);
	}


	/**
	* @description Find invoice that is missing from transaction (item 7312)
	* @param transIds Set of transaction IDs to process
	*/ 
	public static void findInvoice(Set<Id> transIds) {
		List<KGRenewal__Transaction__c> transactions = new List<KGRenewal__Transaction__c>();
		List<Opportunity> oppList = new List<Opportunity>();
		List<KGRenewal__Subscription__c> subList = new List<KGRenewal__Subscription__c>();
		List<KGRenewal__Invoice__c> invList = new List<KGRenewal__Invoice__c>();
		List<SObject> updates = new List<SObject>();

		try {
			transactions = [SELECT Id, Name, KGRenewal__Opportunity__c, KGRenewal__Contact__c, KGRenewal__Invoice__c, KGRenewal__Status__c
							FROM KGRenewal__Transaction__c
							WHERE Id IN :transIds];
			
			oppList = [SELECT Id, Type, StageName, AccountId, KGRenewal__Subscription__c, Contact__r.AccountId, Contact__r.Lifetime_Dues_Status__c
					   FROM Opportunity 
					   WHERE Id IN :Pluck.ids('KGRenewal__Opportunity__c', transactions)];

			subList = [SELECT Id, Name, KGRenewal__Account__c 
					   FROM KGRenewal__Subscription__c 
					   WHERE Id IN :Pluck.ids('KGRenewal__Subscription__c', oppList)];

			invList = [SELECT Id, KGRenewal__Account__c, KGRenewal__Opportunity__c, KGRenewal__Subscription__c
					   FROM KGRenewal__Invoice__c 
					   WHERE KGRenewal__Opportunity__c IN :Pluck.ids('Id', oppList) 
					   ORDER BY Id ASC];
			
			System.debug('+++ OPPS: ' + oppList.size());
			System.debug('+++ SUBS: ' + subList.size());
			System.debug('+++ INV: ' + invList.size());
		}
		catch (QueryException ex) {
			System.debug('Error getting related records: ' + ex.getTypeName() + ' - ' + ex.getMessage());
			return;
		}
		
		for (KGRenewal__Transaction__c trans : transactions) {
			if (trans.KGRenewal__Invoice__c == null) {
				for (Opportunity opp : oppList) {
					System.debug('+++ ' + opp);
					if (opp.Id == trans.KGRenewal__Opportunity__c) {
					
						Integer invCount = 0;

						// (Case B) At least one invoice exists and no transaction errors, so remove 
						// subscription from the invoice and update transaction with invoice number
						for (KGRenewal__Invoice__c inv : invList) { 
							System.debug('+++ ' + inv);
							if (inv.KGRenewal__Opportunity__c == opp.Id && trans.KGRenewal__Status__c != TRANS_ERROR) {
								System.debug('+++ Item 7312 - Case B');
								inv.KGRenewal__Subscription__c = null;
								trans.KGRenewal__Invoice__c = inv.Id;
								updates.add(inv);
								updates.add(trans);
								invCount++;
							}
						}

						// (Case C) Prospect, lifetime, or transaction error, so just write to error log 
						if ((opp.Type == OPP_TYPE_PROSPECT && trans.KGRenewal__Status__c == TRANS_ERROR) || opp.Contact__r.Lifetime_Dues_Status__c != null) {
							System.debug('+++ Item 7312 - Case C');
							String errMsg = 'TransactionTrigger_YPO did not update the invoice on this opp because it was for a ';
							errMsg += opp.Contact__r.Lifetime_Dues_Status__c != null ? 'lifetime member.' : 'prospect and there was a transaction error.';
							if(!Test.isRunningTest()) {
								Error_Log__c err = ErrorLogUtil.createErrorLog('', opp.Id, errMsg);
								updates.add(err);
							}
						}
                        
						// (Case A) Opportunity doesn't have any invoices, so set opp stage to pmt pending
						// and it should automatically create invoice and link it to the transaction
						
						/*
						else if (invCount == 0) {
							System.debug('+++ Item 7312 - Case A');
							opp.StageName = STATUS_PMT_PENDING;
							updates.add(opp);
						}
						*/

					}
				}
			}
		}
		if (updates.size() > 0) {
			updateRecords(updates);
		}
	}


	/**
	* @description Update billed amount on opp and set to payment received if necessary (called from findOpportunity() method above)
	* @param transIds Set of transaction IDs to process
	*/ 
	public static void updateOppBalance(Set<Id> transIds) {
		List<Opportunity> oppList = new List<Opportunity>();
		List<SObject> updates = new List<SObject>();
		List<KGRenewal__Transaction__c> transactions = [SELECT Id, KGRenewal__Opportunity__c, KGRenewal__Status__c, KGRenewal__Amount__c
														FROM KGRenewal__Transaction__c
														WHERE Id IN :transIds];

		// Sum transaction amounts and update opp fields
		for (Opportunity opp : [SELECT Id, Type, StageName, Amount, KGRenewal__BilledAmount__c
							    FROM Opportunity 
							    WHERE Id IN :Pluck.ids('KGRenewal__Opportunity__c', transactions)]) 
		{ 
			Boolean isChanged = false;
			Decimal total = 0;

			for (KGRenewal__Transaction__c trans : transactions) {
				if (trans.KGRenewal__Opportunity__c == opp.Id && trans.KGRenewal__Status__c == 'Success') {
					total += trans.KGRenewal__Amount__c;
				}
			}
			if (opp.KGRenewal__BilledAmount__c != total) {
				opp.KGRenewal__BilledAmount__c = total;
				isChanged = true;
			}
			if (opp.KGRenewal__BilledAmount__c >= opp.Amount) {
				opp.StageName = STATUS_PMT_RECD;
				isChanged = true;
			}
			if (isChanged) {
				updates.add(opp);
			}
		}
		if (updates.size() > 0) {
			updateRecords(updates);
		}
	}

	
	/**
	* @description If GatewayReasonCode contains an error, update YPO error message
	* @param transIds Set of transaction IDs to process
	*/ 
	public static void updateErrorMsg(Set<Id> transIds) {
		List<SObject> updates = new List<SObject>();
		Map<String, String> errors = new Map<String, String>();

		for (Payment_Error__c err : [SELECT Error_Code__c, YPO_Message__c FROM Payment_Error__c]) {
			errors.put(err.Error_Code__c, err.YPO_Message__c);
		}

		for (KGRenewal__Transaction__c trans : [SELECT Id, KGRenewal__GatewayReasonCode__c, YPO_Error_Message__c 
												FROM KGRenewal__Transaction__c 
												WHERE Id IN :transIds] ) 
		{
			if (trans.KGRenewal__GatewayReasonCode__c != null) {
				trans.YPO_Error_Message__c = errors.containsKey(trans.KGRenewal__GatewayReasonCode__c) ? 
											 errors.get(trans.KGRenewal__GatewayReasonCode__c) : 
											 Label.Payment_Error_Message;
				updates.add(trans);
			}
		}
		if (updates.size() > 0) {
			updateRecords(updates);
		}
	}


	/**
	* @description Commit changes to the database (update) and write error logs for any issues
	* @param updates List of SObjects to update
	*/ 
	private static void updateRecords(List<SObject> updates) { 
		List<Database.SaveResult> results = new List<Database.SaveResult>();
		List<Error_Log__c> errors = new List<Error_Log__c>();
		
		System.debug('+++ Updates: ' + updates); 

		if (updates.size() > 0) {
			results = Database.update(updates, false);
		}

		for (Database.SaveResult sr : results) {
			if (!sr.isSuccess()) {
				for(Database.Error err : sr.getErrors()) {
					errors.add(ErrorLogUtil.createErrorLog('', sr.getId(), err.getMessage() + ' | ' + err.getFields()));
				}
			}
		}
		
		if (!Test.isRunningTest() && errors.size() > 0) {
			insert errors;
		}
	} 

}