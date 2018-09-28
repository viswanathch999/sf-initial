global class StartAffiliationsDailyBatch implements Database.Batchable<sObject>, Database.Stateful{
	
    global String query;
    private final String BATCH_JOB_Name = 'Start Account Affiliations Daily Batch';    
    global List<String> errorMessages = new List<String>(); 
    global Id chapterAARecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Chapter', 'Account_Affiliation__c').Id;
    
    global Database.QueryLocator start(Database.BatchableContext BC){   
        query = 'SELECT Id, Contact__c, Is_Primary__c, Transfer_Flag__c, Account__c, Account__r.Is_Integrated__c, Start_Date__c, Contact__r.RecordType.DeveloperName '+ 
            'FROM Account_Affiliation__c WHERE Chapter_Approval_Status__c = \'Approved\''+
            ' AND Start_Date__c <= TODAY AND IsActive__c = false AND Is_Primary__c = true AND Transfer_Flag__c != null AND End_Date__c = null AND RecordTypeId = \'' + chapterAARecordTypeId + '\'';
        return Database.getQueryLocator(query);
    }    
    
    global void execute(Database.BatchableContext BC, List<Account_Affiliation__c> scope) {   
        errorMessages.addAll(StartAffiliationsDailyBatchServices.processAllAccountAffiliations(scope));
    }   
    
    global void finish(Database.BatchableContext BC){
        String errorMessage = '';
        errorMessage = String.join(errorMessages, ' \n ');
        
        System.debug('###errorMessage: ' + errorMessage);
        System.debug('###errorMessages: ' + errorMessages);
        if(errorMessages!= null && !errorMessages.isEmpty()) {
	        UpdChapterHealthDailyBatchServices.sendBatchEmailNotification(bc.getJobId(), BATCH_JOB_Name,
	                                                                          Label.Account_Affiliations_Email_Failure_Message
	                                                                          +'\n Error: '+errorMessage);
        }
        else {
	        UpdChapterHealthDailyBatchServices.sendBatchEmailNotification(bc.getJobId(), BATCH_JOB_Name,
	                                                                          '');
        }
        
    }
}