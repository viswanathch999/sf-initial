global class TierBatch implements Database.Batchable<sObject>{
    global String query;

	global Database.QueryLocator start(Database.BatchableContext BC){      
        
        Id spousePartnerRecordType = RecordTypeServices.getRecordTypeByName('Spouse/Partner', 'Contact').Id;
        
        query = 'SELECT Id, Contact__r.Age_Current__c, Contact__r.Membership_status__c, Contact__r.Member_Tier__c, Contact__r.YNG_Member__c, Account__c, Contact__c, Relationship_Type__c FROM Relationship__c WHERE Is_Active__c = true AND Relationship_Type__c = \'Spouse/Partner\' AND  Contact__r.Membership_status__c = \'Surviving Spouse/Partner\' AND Contact__r.RecordTypeId =: spousePartnerRecordType';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Relationship__c> scope) {   
    	
    	TierBatchServices.assessTiers(scope);
    	     
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}