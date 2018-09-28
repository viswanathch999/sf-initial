global class EndOfYearBatch implements Database.Batchable<sObject>{
    global String query;

	global Database.QueryLocator start(Database.BatchableContext BC){      
        
        query = 'SELECT Id, KGRenewal__Contact__c, KGRenewal__IsActiveCart__c  FROM Opportunity WHERE StageName = \'New\' AND KGRenewal__Subscription__c != NULL AND KGRenewal__IsActiveCart__c = false';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {   
    	
    	EndOfYearBatchServices.setActiveCart(scope);
    	
    	EndOfYearBatchServices.opportunitySetProductFlow(scope);
    	     
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}