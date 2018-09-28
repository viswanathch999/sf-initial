public class StartAffiliationsDailyBatchServices {
	public static Set<Account_Affiliation__c> accAffsToUpdate = new Set<Account_Affiliation__c>();
	public static Set<Contact> contactsToUpdate = new Set<Contact>();
	public static List<Membership_History__c> memHistsToUpdate = new List<Membership_History__c>();
	public static Map<Id, Account_Affiliation__c> memberIdToAff = new Map<Id, Account_Affiliation__c>();
	public static List<String> allErrorMessages = new List<String>();
	public static List<Account_Affiliation__c> allAccAffsToUpdate = new List<Account_Affiliation__c>();
	public static List<Id> transferContactIds = new List<Id>();
	public static List<Id> transitionContactIds = new List<Id>();
	public static Map<String, List<KGRenewal__Transaction__c>> invNameToRelatedTransaction = new Map<String, List<KGRenewal__Transaction__c>>();
	public static List<KGRenewal__Transaction__c> allTrans = new List<KGRenewal__Transaction__c>();
	public static Map<Id, List<Account_Affiliation__c>> contactIdToNewAAs = new Map<Id, List<Account_Affiliation__c>>();
	public static Id chapterAARecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Chapter', 'Account_Affiliation__c').Id;
	public static List<String> processAllAccountAffiliations(List<Account_Affiliation__c> affsToProcess) {
		contactIdToNewAAs = GroupBy.ids('Contact__c', affsToProcess);
		
		List<Account_Affiliation__c> transferAccAffs = new List<Account_Affiliation__c>();
		List<Account_Affiliation__c> transitionAccAffs = new List<Account_Affiliation__c>();
		List<Account_Affiliation__c> primaryAccAffs = new List<Account_Affiliation__c>();
		List<Opportunity> oppsForInvoicesToUpdate = new List<Opportunity>();
		
		List<Contact> primaryHouseholdContactsToUpdate = new List<Contact>();
		
		for(Account_Affiliation__c accAff: affsToProcess) {
			accAff.IsActive__c = true;
			
			if(accAff.Is_Primary__c == true) {
				primaryAccAffs.add(accAff);
				memberIdToAff.put(accAff.Contact__c, accAff);
			}
			
			if(accAff.Transfer_Flag__c == 'Renewal Transition' || accAff.Transfer_Flag__c == 'Off-Cycle Transition') {
				System.debug('###transitions: ' + accAff);
				transitionAccAffs.add(accAff);
				transitionContactIds.add(accAff.Contact__c);
			}
			
			else if (accAff.Transfer_Flag__c == 'Transfer') {
				System.debug('###transfers: ' + accAff);
				transferAccAffs.add(accAff);
				transferContactIds.add(accAff.Contact__c);
			}
			allAccAffsToUpdate.add(accAff);
		}
		
		System.debug('###primaryAccAffs: ' + primaryAccAffs);
		System.debug('###memberIdToAff: ' + memberIdToAff);
		
		primaryHouseholdContactsToUpdate.addAll(updateRelatedHouseholdContactsForPrimaryAccAffs(primaryAccAffs));
		oppsForInvoicesToUpdate.addAll(updateRelatedOpenOpps(primaryAccAffs));
		allErrorMessages.addAll(updateContacts(primaryHouseholdContactsToUpdate));
		allErrorMessages.addAll(updateOpportunities(oppsForInvoicesToUpdate));
		updateRelatedInvoices(oppsForInvoicesToUpdate);
		processTransferScenario(transferAccAffs);
		processTransitionScenario(transitionAccAffs);
		
		if(!allAccAffsToUpdate.isEmpty()) {
			try {
				System.debug('###allAccAffsToUpdate: ' + allAccAffsToUpdate);
				update allAccAffsToUpdate;
			}catch(DmlException dEx){
	        	System.debug('###dEx: ' + dEx);
	            allErrorMessages.add(dEx.getMessage());
        	}
		}
		
		allErrorMessages.addAll(upsertMembershipHistory(memHistsToUpdate));
		System.debug('###allErrorMessages: ' + allErrorMessages);
		return allErrorMessages;
		
	}
	
	public static List<Opportunity> updateRelatedOpenOpps(List<Account_Affiliation__c> accAffs) {
		List<Opportunity> oppsToUpdate = new List<Opportunity>();
		Map<Id, Id> contactIdToNewAccId = new Map<Id, Id>();
		for(Account_Affiliation__c accAff : accAffs) {
			contactIdToNewAccId.put(accAff.Contact__c, accAff.Account__c);
		}
		
		List<Opportunity> oppsToStamp = [SELECT Id, KGRenewal__Contact__c, AccountId, Referred_by_Chapter__c FROM Opportunity WHERE KGRenewal__Contact__c IN: contactIdToNewAccId.keySet()];
		Map<Id, List<Opportunity>> conIdToOpenOpps = GroupBy.ids('KGRenewal__Contact__c', oppsToStamp);
		
		for(Id key : conIdToOpenOpps.keySet()) {
			for(Opportunity opp : conIdToOpenOpps.get(key)) {
				opp.AccountId = contactIdToNewAccId.get(key);
				opp.Referred_by_Chapter__c = opp.AccountId;
				oppsToUpdate.add(opp);
			}
		}
		
		return oppsToUpdate;	
	}
	
	public static void updateRelatedInvoices(List<Opportunity> relatedOpps) {
		System.debug('###inside inv update stuff');
		System.debug('###relatedOpps: ' + relatedOpps);
		
		Map<Id, KGRenewal__Invoice__c> originalInvIdToClonedinv = new Map<Id, KGRenewal__Invoice__c>();
		Map<String, List<KGRenewal__InvoiceItem__c>> clonedInvToInvItemsList = new Map<String, List<KGRenewal__InvoiceItem__c>>();
		List<KGRenewal__Transaction__c> transToUpdate = new List<KGRenewal__Transaction__c>();
		List<KGRenewal__Invoice__c> invoicesToUpdate = new List<KGRenewal__Invoice__c>();
		List<KGRenewal__Invoice__c> invoicesToUpdateClone = new List<KGRenewal__Invoice__c>();
		Map<Id, Id> oppIdToAccountId = new Map<Id, Id>();
		for(Opportunity opp : relatedOpps) {
			oppIdToAccountId.put(opp.Id, opp.AccountId);
		}
		invoicesToUpdate = [SELECT Id, Name, KGRenewal__Account__c, KGRenewal__AdjustedSubtotal__c, KGRenewal__AdjustmentAmount__c, 
							KGRenewal__AdjustmentDescription__c, KGRenewal__Amount__c, KGRenewal__AmountDue__c, KGRenewal__AmountPaid__c, 
							KGRenewal__DueDate__c, BillingCity__c, BillingCountry__c, BillingFirstName__c, BillingLastName__c, 
							BillingOrganization__c, BillingPostalCode__c, BillingState__c, BillingStreetAddressLine1__c, 
							BillingStreetAddressLine2__c, KGRenewal__IsClosed__c, Closed_Date__c, KGRenewal__Contact__c, ContractEffectiveDate__c, 
							ContractEndDate__c, CVent_ID__c, Description__c, KGRenewal__DisableAutomaticInvoicingAndBilling__c, 
							Discounted_Items__c, KGRenewal__ECommerceOrder__c, Invoice_Number_Historical__c, KGRenewal__InvoiceSent__c, 
							KGRenewal__BillingDate__c, KGRenewal__ItemSubtotal__c, KGRenewal__MergedIntoInvoice__c, KGRenewal__OnlinePaymentKey__c, 
							KGRenewal__Opportunity__c, Opportunity_Name__c, KGRenewal__PaymentAttempts__c, Payment_Type__c, KGRenewal__PeriodEnd__c, 
							KGRenewal__PeriodStart__c, KGRenewal__Status__c, KGRenewal__Subscription__c, KGRenewal__Tax__c, 
							KGRenewal__TotalAmount__c, VAT__c, 
								(SELECT Id, Name, KGRenewal__Amount__c, CVent_ID__c, KGRenewal__Description__c, Description_PDF__c, 
								 KGRenewal__DescriptionDisplay__c , KGRenewal__Discount__c,  KGRenewal__DiscountDisplay__c, 
								 KGRenewal__Invoice__c, KGRenewal__IsSubscription__c, KGRenewal__Product2__c, KGRenewal__ProductNameDisplay__c, 
								 KGRenewal__Quantity__c, KGRenewal__QuantityDisplay__c, Sort_PDF__c, KGRenewal__SortOrder__c, 
								 KGRenewal__SubscriptionProduct__c, KGRenewal__TaxAmount__c, KGRenewal__UnitPrice__c, 
								 KGRenewal__UnitPriceDisplay__c FROM KGRenewal__InvoiceItems__r),
								(SELECT Id, Name, KGRenewal__Invoice__r.Name, KGRenewal__Invoice__c FROM KGRenewal__Transactions__r)
							FROM KGRenewal__Invoice__c 
							WHERE KGRenewal__Opportunity__c IN: relatedOpps];
							
		for(KGRenewal__Invoice__c inv : invoicesToUpdate) {
			KGRenewal__Invoice__c clonedInv = inv.clone(false, true, true, true);
			clonedInv.KGRenewal__Account__c = oppIdToAccountId.get(clonedInv.KGRenewal__Opportunity__c);
			clonedInv.Do_Not_Stamp_Closed_Date__c = true;
			clonedInvToInvItemsList.put(clonedInv.Name, inv.KGRenewal__InvoiceItems__r);
			invoicesToUpdateClone.add(clonedInv);
			
			for(KGRenewal__Transaction__c trans : inv.KGRenewal__Transactions__r) {
				allTrans.add(trans);
				if(invNameToRelatedTransaction.get(inv.Name) != null) {
					invNameToRelatedTransaction.get(inv.Name).add(trans);
				}
				
				else {
					invNameToRelatedTransaction.put(inv.Name, new List<KGRenewal__Transaction__c>{trans});
				}
			}
		}
		
		System.debug('###before try');
		System.debug('###invoicesToUpdateClone before try: ' + invoicesToUpdateClone);
		System.debug('###clonedInvToInvItemsList before try: ' + clonedInvToInvItemsList);
		
        try
        {
        	System.debug('###inside try');
            insert invoicesToUpdateClone;
            Map<String, Id> invCloneNameToId = new Map<String, Id>();
            
            for(KGRenewal__Invoice__c inv : invoicesToUpdateClone) {
            	invCloneNameToId.put(inv.Name, inv.Id);
            	inv.Do_Not_Stamp_Closed_Date__c = false;
            }
            
            for(String key : invNameToRelatedTransaction.keySet()){
	            for(KGRenewal__Transaction__c trans : invNameToRelatedTransaction.get(key)) {
	            		trans.KGRenewal__Invoice__c = invCloneNameToId.get(key);
	            		transToUpdate.add(trans);
	            }
            }
            
            System.debug('###invoicesToUpdateClone: ' + invoicesToUpdateClone);
            System.debug('###clonedInvToInvItemsList: ' + clonedInvToInvItemsList);
            
            List<KGRenewal__InvoiceItem__c> invItemsToUpdate = new List<KGRenewal__InvoiceItem__c>();
            for(String invName : clonedInvToInvItemsList.keySet()) {
            	for(KGRenewal__InvoiceItem__c invItem : clonedInvToInvItemsList.get(invName)) {
            		System.debug('###updating inv item: ' + invItem);
            		KGRenewal__InvoiceItem__c invItemClone = invItem.clone(false, true, true, true);
            		invItemClone.KGRenewal__Invoice__c = invCloneNameToId.get(invName);
            		invItemsToUpdate.add(invItemClone);
            	}
            }
            
            System.debug('###clonedInvToInvItemsList.values(): ' + clonedInvToInvItemsList.values());
            
            delete invoicesToUpdate;
            insert invItemsToUpdate;
            update transToUpdate;
            update invoicesToUpdateClone;
            
        }
        catch(DmlException ex)
        {
        	System.debug('###inside catch: ' + ex);
            allErrorMessages.add(ex.getMessage());
        }
        
	}
	
	
	public static List<Contact> updateRelatedHouseholdContactsForPrimaryAccAffs(List<Account_Affiliation__c> accAffs) {
		
		List<Contact> householdContactsToUpdate = new List<Contact>();
		
		Map<Id, Account_Affiliation__c> householdIdToMemberAff = new Map<Id, Account_Affiliation__c>(); 
        for(Relationship__c houseHoldRelationship :[Select account__c, contact__c from Relationship__c where Is_Active__c = true and Relationship_Type__c = 'Member' and contact__c IN :memberIdToAff.keySet()]){
            householdIdToMemberAff.put(houseHoldRelationship.account__c,
                                       memberIdToAff.get(houseHoldRelationship.contact__c));
        }
        System.debug('@@@ householdRelationships : '+householdIdToMemberAff);
        Set<Contact> familyContactsToUpdate = new Set<Contact>();
        for(Relationship__c houseHoldRel: [Select id, account__c, contact__c from Relationship__c where 
                                           account__c =:householdIdToMemberAff.keySet() and 
                                           (Relationship_Type__c='Member' OR (Relationship_Type__c='Child' AND Contact__r.RecordType.DeveloperName != 'Member') OR Relationship_Type__c='Spouse/Partner' OR Relationship_Type__c='Spouse/Partner Not Visible') ]){                                               
                                               Contact familyConToUpdate = new Contact(id = houseHoldRel.Contact__c);
                                               familyConToUpdate.AccountId = householdIdToMemberAff.get(houseHoldRel.account__c).Account__c;
                                               householdContactsToUpdate.add(familyConToUpdate);        
                                           } 
                                           
        System.debug('@@@ householdContactsToUpdate: '+ householdContactsToUpdate);                         
		return householdContactsToUpdate;
	}
	
	public static void processTransferScenario(List<Account_Affiliation__c> accAffs) {
		System.debug('###accAffs in transfer: ' + accAffs);
		
		if(!accAffs.isEmpty()) {
			List<Account_Affiliation__c> existingPrimToUpdate = new List<Account_Affiliation__c>();
			
			List<Account_Affiliation__c> existingActiveAffs = [Select id, Account__c, Transfer_Flag__c, Contact__c, Is_Primary__c, Account__r.Is_Integrated__c from Account_Affiliation__c where Contact__c IN: transferContactIds 
	                                                           and RecordTypeId =:chapterAARecordTypeId 
	                                                           and IsActive__c = true
	                                                           and Is_Primary__c = true
	                                                           and id Not IN: accAffs];
	        
	        for(Account_Affiliation__c updateAff : existingActiveAffs){
	            updateAff.isActive__c = false;
	            System.debug('###contactIdToNewAAs: ' + contactIdToNewAAs);
	            if(contactIdToNewAAs.get(updateAff.Contact__c) != null)
	            	updateAff.End_Date__c = contactIdToNewAAs.get(updateAff.Contact__c)[0].Start_Date__c.addDays(-1);
	            updateAff.Reason_for_Leaving__c = 'Transfer';
	            existingPrimToUpdate.add(updateAff);
	        }
	        
	        if(!existingPrimToUpdate.isEmpty()) {
	        	try {
	        		System.debug('###existingPrimToUpdate: ' + existingPrimToUpdate);
			        update existingPrimToUpdate;
	        	}
	        	catch(DMLException ex) {
	        		System.debug('###ex in transfer: ' + ex);
	        		allErrorMessages.add(ex.getMessage());
	        	}
	        }
		}
	}
	
	public static void processTransitionScenario(List<Account_Affiliation__c> accAffs) {
		System.debug('###accAffs in transition: ' + accAffs);
		if(!accAffs.isEmpty()) {
			List<Account_Affiliation__c> accAffsToInactivate = new List<Account_Affiliation__c>();
			accAffsToInactivate.addAll(updateTransitionAffiliations(accAffs).values());
			
			if(!accAffsToInactivate.isEmpty()) {
		        try {
				        update accAffsToInactivate;
		        	}
		        	catch(DMLException ex) {
		        		allErrorMessages.add(ex.getMessage());
		        	}
	        }
	        
	        memHistsToUpdate.addAll(updateMembershipHistoryUponTransition(accAffs));
		}
	}
	
	public static Map<Id, Account_Affiliation__c> updateTransitionAffiliations(List<Account_Affiliation__c> transitionedAccAffs){
        Map<Id, Account_Affiliation__c> memberIdToTransAff = new Map<Id, Account_Affiliation__c>();
        for(Account_Affiliation__c transitionedAccAff: transitionedAccAffs)
            memberIdToTransAff.put(transitionedAccAff.Contact__c, transitionedAccAff);
        Map<Id, Account_Affiliation__c> affsToInactivate = new Map<Id, Account_Affiliation__c>();
        //Id chapterAARecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Chapter', 'Account_Affiliation__c').Id;
        for(Account_Affiliation__c updateAff : [Select id, account__c, contact__c, Account__r.YPOI_Type__c from Account_Affiliation__c where 
        										RecordTypeId =:chapterAARecordTypeId 
        										and contact__c IN: transitionContactIds  
                                                and id NOT IN: transitionedAccAffs
                                                and isActive__c = true]){            
                                                    updateAff.isActive__c = false;
                                                    System.debug('###contactIdToNewAAs: ' + contactIdToNewAAs);
                                                    if(contactIdToNewAAs.get(updateAff.Contact__c) != null)
                                                    	updateAff.End_Date__c = contactIdToNewAAs.get(updateAff.Contact__c)[0].Start_Date__c.addDays(-1);
                                                    updateAff.Reason_for_Leaving__c = 'Transitioned';
                                                    affsToInactivate.put(updateAff.id, updateAff);
                                                }     
        system.debug('2. '+affsToInactivate);
        return affsToInactivate;
    } 
    
     private static List<Membership_History__c> updateActiveMembershipHistory(List<Account_Affiliation__c> accAffList)
    {
        List<Membership_History__c> relatedMemberHistorys = [SELECT Id FROM Membership_History__c WHERE Contact__c IN :PLuck.ids('Contact__c',accAffList)];
        Date defaultDateLeft = Date.today().addDays(-1);
        for(Membership_History__c relatedMemberHistory : relatedMemberHistorys)
        {
            relatedMemberHistory.Date_Left__c = defaultDateLeft;
            relatedMemberHistory.Status__c = 'Resigned';
            relatedMemberHistory.Reason__c = 'Transitioned';
        }
        System.debug('@@@ related membership histories (resigned) '+ relatedMemberHistorys);
        return relatedMemberHistorys;
    }

    private static List<Membership_History__c> createMembershipHistory(List<Account_Affiliation__c> accAffList)
    {
        List<Membership_History__c> newMemberHistorys = new List<Membership_History__c>();
        Date defaultDate = Date.today();
        for(Account_Affiliation__c accAff : accAffList)
        {
        	System.debug('###rec type for mem hist: ' + accAff.Contact__r.RecordType.DeveloperName);
        	if(accAff.Contact__r.RecordType.DeveloperName == 'Member') {
	            newMemberHistorys.add(new Membership_History__c(
	                Account__c = accAff.Account__c,
	                Contact__c = accAff.Contact__c,
	                YPO_WPO__c = 'YPO Gold',
	                Status__c = 'Member',
	                Join_Date__c = defaultDate
	            ));
        	}
        }
        System.debug('@@@ new member histories : '+newMemberHistorys );
        return newMemberHistorys;
    }

    private static List<String> upsertMembershipHistory(List<Membership_History__c> membershipHistoryList)
    {
        List<String> errorMessages = new List<String>();
        try
        {
            upsert membershipHistoryList;
        }
        catch(DmlException ex)
        {
            errorMessages.add(ex.getMessage());
        }
        return errorMessages;
    }

    public static List<Membership_History__c> updateMembershipHistoryUponTransition(List<Account_Affiliation__c> accAffList)
    {
        List<String> errorMessages = new List<String>();
        allErrorMessages.addAll(updateContacts(updateRelatedContactTransitionStatus(accAffList)));
        List<Membership_History__c> memberHistorysToUpsert = new List<Membership_History__c>();
        memberHistorysToUpsert.addAll(updateActiveMembershipHistory(accAffList));
        memberHistorysToUpsert.addAll(createMembershipHistory(accAffList));
        return memberHistorysToUpsert;
    }
    
    private static List<Contact> updateRelatedContactTransitionStatus(List<Account_Affiliation__c> accAffList)
    { 
        List<Contact> relatedContacts = [SELECT Id, Transition_Status__c FROM Contact WHERE Id IN : PLuck.ids('Contact__c',accAffList)];
        System.debug('@@@ contacts to update transition status: '+ relatedContacts);
        for(Contact relatedContact : relatedContacts)
        {
            relatedContact.Transition_Status__c = 'Transitioned';
        }
        return relatedContacts;
    }

    private static List<String> updateContacts(List<Contact> contactList)
    {
    	System.debug('###contactList: ' + contactList);
        List<String> errorMessages = new List<String>();
        try
        {
        	Set<Contact> contactSet = new Set<Contact>(contactList);
        	
            update new List<Contact>(contactSet);
        }
        catch(DmlException ex)
        {
            errorMessages.add(ex.getMessage());
        }
        return errorMessages;
    }
	
    private static List<String> updateOpportunities(List<Opportunity> opportunityList)
    {
    	System.debug('###opportunityList: ' + opportunityList);
        List<String> errorMessages = new List<String>();
        try
        {
            update opportunityList;
        }
        catch(DmlException ex)
        {
            errorMessages.add(ex.getMessage());
        }
        return errorMessages;
    }
    
    /*private static List<String> updateInvoices(List<KGRenewal__Invoice__c> invoiceList)
    {
    	System.debug('###invoiceList: ' + invoiceList);
        List<String> errorMessages = new List<String>();
        try
        {
        	System.debug('###inside try update inv');
            insert invoiceList;
        }
        catch(DmlException ex)
        {
            errorMessages.add(ex.getMessage());
        }
        return errorMessages;
    }*/
	
}