/**
* UserContactShare enables partner portal user to
* share the affiliated contact record 
*
* @author Shri K 
*/

public class UserServices {
    
    /**
* update users to share affiliated contacts.  
* @param: lstNewUser list of new user records. 
*/
    public static void shareContact(List<User> lstNewUser, List<Id> lstAccountId)
    {
    	
    	System.debug('###lstNewUser: ' + lstNewUser);
    	System.debug('###lstAccountId: ' + lstAccountId);
		List<OpportunityShare> lstOpportunityShare = new List<OpportunityShare>();
        list<ContactShare> lstContactShare = new list<ContactShare>();
        List<String> networkCategoriesToShareWithCA = new List<String>{'Secret','Public'};
        Map<Id, set<Id>> mapUserIdAndAssociatedContact = new Map<Id, set<Id>>();
        Map<Id, Id> mapUserIdAccountId = new Map<Id, Id>();
        Map<Id, Set<Id>> chapterToCAUser = new Map<Id, Set<Id>>();        
        Map<Id, Id> caContactToCAUser = new Map<Id, Id>();
        set<Id> setMasterContactID = new set<Id>();
        //logic for house hold accounts
        List<AccountShare> lstAccountShare = new List<AccountShare>();
        Set<String> accUserShareKey = new Set<String>();
        Integer iCount = 0;
        Id networkRecordTypeId = [Select Id From RecordType where sobjecttype = 'Account' and name in ('Network')].Id;
        for(User portalCAUser: [Select Id, ContactId from User where id in:lstNewUser and ContactId!=null]){
            caContactToCAUser.put(portalCAUser.ContactId, portalCAUser.Id);
        }
        for(User oUser: lstNewUser)
        {
            if(oUser.AccountId != null)
            {
                mapUserIdAccountId.put(oUser.Id, oUser.AccountId);
                if(!chapterToCAUser.containsKey(oUser.AccountId)) {
                    chapterToCAUser.put(oUser.AccountId, new Set<Id>());
                }
                chapterToCAUser.get(oUser.AccountId).add(oUser.Id);
                String accUserKey= oUser.AccountId+'_'+oUser.Id;
                if(!accUserShareKey.contains(accUserKey)) {
                    lstAccountShare.add(createAccountShare(oUser.AccountId, oUser.Id, 'Edit'));
                }
                accUserShareKey.add(accUserKey);
            }
            else if(lstAccountId != null && String.isNotEmpty(lstAccountId[iCount]))
            {
                mapUserIdAccountId.put(oUser.Id, lstAccountId[iCount]);
                if(!chapterToCAUser.containsKey(lstAccountId[iCount]))
                    chapterToCAUser.put(lstAccountId[iCount], new Set<Id>());
                chapterToCAUser.get(lstAccountId[iCount]).add(oUser.Id);
            }
            iCount ++;            
        }
        
        if(mapUserIdAccountId.isEmpty())
        {
            return;
        }
        
        list<Account_Affiliation__c> lstAccountAffiliation = [SELECT Id, Account__c, Contact__c, Contact__r.OwnerId, Account__r.OwnerId, Type__c, Account__r.RecordTypeId, Account__r.Category__c
                                                              FROM Account_Affiliation__c 
                                                              WHERE Account__c =: mapUserIdAccountId.values()
                                                              /*AND Is_Primary__c = false*/ AND IsActive__c = true ];  
        
        System.debug('###lstAccountAffiliation: ' + lstAccountAffiliation);
        Set<Id> contactIds = Pluck.ids('Contact__c', lstAccountAffiliation);
        
        /*for(Account_Affiliation__c accAff : lstAccountAffiliation) {
			contactIds.add(accAff.Contact__c);        	
        }*/
        
        //List<Opportunity> listOfRelatedOpps = [SELECT Id, OwnerId, AccountId, Contact__c FROM Opportunity WHERE AccountId IN : mapUserIdAccountId.values()];
        List<Opportunity> listOfRelatedOpps = [SELECT Id, OwnerId, AccountId, KGRenewal__Contact__c FROM Opportunity WHERE KGRenewal__Contact__c IN : contactIds AND AccountId != null];
        System.debug('###listOfRelatedOpps: ' + listOfRelatedOpps);
        //Map<Id, List<Opportunity>> accountIdToListOfOpps = GroupBy.ids('AccountId',listOfRelatedOpps);
        Map<Id, List<Opportunity>> contactIdToListOfOpps = GroupBy.ids('KGRenewal__Contact__c',listOfRelatedOpps);
        	
        if(lstAccountAffiliation.isEmpty())
        {
            return;
        }
        Map<Id, List<Id>> contactsToAffiliatedChapters = new Map<Id, List<Id>>();
        Map<Id, List<Id>> opportunitiesToAffiliatedChapters = new Map<Id, List<Id>>();
        
        ContactShare oContactShare;
        OpportunityShare oOpportunityShare;
        
        set<String> setUniqueContactUserKey = new set<String>();
        for(User oUser: lstNewUser)
        {
            for(Account_Affiliation__c oAccountAffiliation : lstAccountAffiliation)
            {
                if(!contactsToAffiliatedChapters.containsKey(oAccountAffiliation.Contact__c)) {
                    contactsToAffiliatedChapters.put(oAccountAffiliation.Contact__c, new List<Id>());
                }
                contactsToAffiliatedChapters.get(oAccountAffiliation.Contact__c).add(oAccountAffiliation.Account__c);
                setMasterContactID.add(oAccountAffiliation.Contact__c);                
                
                if(oUser.id != oAccountAffiliation.Contact__r.OwnerId && mapUserIdAccountId.get(oUser.Id) == oAccountAffiliation.Account__c &&
                   !setUniqueContactUserKey.contains(oAccountAffiliation.Contact__c+'_'+oUser.Id))
                {
                    setUniqueContactUserKey.add(oAccountAffiliation.Contact__c+'_'+oUser.Id);
                    oContactShare = createContactShare(oAccountAffiliation.Contact__c, oUser.Id, 'Edit');
                    lstContactShare.add(oContactShare);
                    
                }
                
                if(contactIdToListOfOpps.get(oAccountAffiliation.Contact__c) != null && !contactIdToListOfOpps.get(oAccountAffiliation.Contact__c).isEmpty()) {
					for(Opportunity eachOpp : contactIdToListOfOpps.get(oAccountAffiliation.Contact__c)) {
							
						if(oUser.id != eachOpp.OwnerId && mapUserIdAccountId.get(oUser.Id) == oAccountAffiliation.Account__c)
	                   		{
	                   			oOpportunityShare = createOpportunityShare(eachOpp.Id, oUser.Id, 'Edit');
	                   			lstOpportunityShare.add(oOpportunityShare);
	                   		}
					}         
                }
                
                
            }
        }
        if(!setMasterContactID.isEmpty()){
            
            //This set is holding household account Id's
            set<Id> setRelationShipAccountId = new set<Id>();
            
            //Queries relationship records of contacts associated to chapter is through affiliations
            List<Relationship__c> lstRelationship = [SELECT Id, Account__c, Contact__c FROM Relationship__c WHERE Contact__c IN: setMasterContactID];
            AccountShare oAccountShare;
            for(Relationship__c oRelationship: lstRelationship)
            {
                String accUserKey= oRelationship.Account__c+'_'+lstNewUser[0].Id;
                if(!accUserShareKey.contains(accUserKey))
                {
                    oAccountShare = createAccountShare(oRelationship.Account__c, lstNewUser[0].Id, 'Edit');
                    lstAccountShare.add(oAccountShare);
                } 
                accUserShareKey.add(accUserKey);
                
                setRelationShipAccountId.add(oRelationship.Account__c);
            }
            
            
            //From CA Setting - Account stored in CA Settings should have access
            if(lstAccountId != null)
            {
                for(Id accountId: lstAccountId)
                {
                    String accUserKey= accountId+'_'+ lstNewUser[0].Id;
                    if(!accUserShareKey.contains(accUserKey))
                    {
                        lstAccountShare.add(createAccountShare(accountId, lstNewUser[0].Id, 'Edit'));                
                    }
                    accUserShareKey.add(accUserKey);  
                    
                }
            }
            
            lstRelationship = [SELECT Id, Account__c, Contact__c FROM Relationship__c 
                               WHERE Account__c IN: setRelationShipAccountId and Contact__r.OwnerId!=:lstNewUser[0].Id];
            for(Relationship__c oRelationship: lstRelationship)
            {
                if(!setUniqueContactUserKey.contains(oRelationship.Contact__c+'_'+lstNewUser[0].Id)){
                    oContactShare = createContactShare(oRelationship.Contact__c, lstNewUser[0].Id, 'Edit');
                    lstContactShare.add(oContactShare);   
                }
            }
            
            List<Account> allAccts = [select ID, RecordTypeId From Account Where Id IN: Pluck.ids('AccountId',lstAccountShare)];
            List<Account> chAccts = new list<account>();
            for(Account tAcct : allAccts ){
            	if(tAcct.RecordTypeId == '01261000000WfVk')
            		chAccts.add(tAcct);
            }
            
            system.debug('@@@lstAccountShare chapter only::' + chAccts);
            system.debug('lstAccountShare::' + lstAccountShare);
            system.debug('lstContactShare::' + lstContactShare);
            system.debug('lstOpportunityShare::' + lstOpportunityShare);
            insertSharingrecords(Json.serialize(lstAccountShare), Json.serialize(lstContactShare), Json.serialize(lstOpportunityShare));
        }
    }
    
    
    static void insertSharingrecords(String sAllAccountShare, String sAllContactShare, String sAllOpportunityShare)
    {
		try {
			list<AccountShare> lstAccountShare = (List<AccountShare>)JSON.deserialize(sAllAccountShare, AccountShare[].class); 
			insert lstAccountShare;
		
			list<ContactShare> lstContactShare = (List<ContactShare>)JSON.deserialize(sAllContactShare, ContactShare[].class); 
			insert lstContactShare;
        
			list<OpportunityShare> lstOpportunityShare = (List<OpportunityShare>)JSON.deserialize(sAllOpportunityShare, OpportunityShare[].class); 
			insert lstOpportunityShare;
		}
		catch (DmlException dex) { 
			ErrorLogUtil.createErrorLog(dex.getTypeName(), String.valueOf(dex.getNumDml()), dex.getMessage());
		}
    }
    private static OpportunityShare createOpportunityShare(Id opportunityId, Id userID, String sAccessLevel)
    {
        OpportunityShare oOpportunityShare = new OpportunityShare();
        oOpportunityShare.OpportunityId = opportunityId;
        oOpportunityShare.UserOrGroupId = userID;
        oOpportunityShare.OpportunityAccessLevel = sAccessLevel;        
        return oOpportunityShare; 
    }
    	 
    private static ContactShare createContactShare(Id contactId, Id userID, String sAccessLevel)
    {
        ContactShare oContactShare = new ContactShare();
        oContactShare.ContactId = contactId;
        oContactShare.UserOrGroupId = userID;
        oContactShare.ContactAccessLevel = sAccessLevel;        
        return oContactShare;
    }
    
    private static AccountShare createAccountShare(Id accountId, Id userID, String sAccessLevel)
    {
        AccountShare oAccountShare = new AccountShare();
        oAccountShare.AccountId = accountId;
        oAccountShare.UserOrGroupId = userID;
        oAccountShare.AccountAccessLevel = sAccessLevel;
        oAccountShare.OpportunityAccessLevel = sAccessLevel;
        return oAccountShare;
    }   
}