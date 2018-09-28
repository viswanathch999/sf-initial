public with sharing class CreateNonSubcriptionOpportunityAction {
	
	@InvocableMethod(label='Create Non-Subscription Opportunity' description='Creates Non-Subscription Opportunity for each account Affiliation ')
	public static void CreateNonSubcriptionOpportunityAction(List<Account_Affiliation__c> acctAffList)
	{
		List<Opportunity> oppList = new List<Opportunity>();
		for(Account_Affiliation__c acctAff : acctAffList)
		{
			System.debug('*** inside createNonSubscriptOppty***');
			oppList.add( 
				new Opportunity(
					Name = 'New Opportunity',
					CloseDate = Date.today(),
					StageName = 'New',
					Referred_by_Chapter__c = acctAff.Account__c,
					KGRenewal__Contact__c = acctAff.Contact__c,
					Fiscal_Date_Start__c = FiscalDateUtility.startOfCurrentFiscal.addYears(1),
					Chapter_Acceptance_Status__c = 'Approved'
				)
			);

		}
		if(!oppList.isEmpty()){ insertOpportunties(oppList); }		
	}

	@TestVisible
	private static void insertOpportunties(List<Opportunity> oppList)
	{
		try
		{
			insert oppList;
			
		}
		catch(DmlException dml)
		{
			//TO-DO: Add Email Error Handling
			if(Test.isRunningTest()){ throw dml; }
		}
		
		createOCRs(oppList);
	}
	
	private static void createOCRs( List<Opportunity> newlyInsertedOpps ){
		
		List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
		for(Opportunity oOpp : newlyInsertedOpps){
			
			ocrList.add(
				new OpportunityContactRole(
					ContactId = oOpp.KGRenewal__Contact__c,
					OpportunityId = oOpp.id,
					Role = 'Business User',
					IsPrimary = true
				)	
			);
		}
		
		if(!ocrList.isEmpty()){
			try{
				insert ocrList;
			}catch(DMLException dmlex){
				//TODO Email error handling
			}
		}
	}
}