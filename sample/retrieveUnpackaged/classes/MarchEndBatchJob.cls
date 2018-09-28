global class MarchEndBatchJob implements Database.Stateful, Database.Batchable<sObject>{
    global String query;
    global String errorMessage = '';
    public MarchEndBatchJob(){
        query = 'SELECT id, Contact__c, account__c, account__r.name, Contact__r.HouseholdID__c FROM Membership_History__c '+
            'WHERE Date_Left__c = null AND Status__c = \'Member\' and Account__c!=null and YPO_WPO__c=\'WPO\'';
    }
    
    /**
* start method of batchable interface.
* Method queries and returns 
* all the Contact_Position__c Where Status__c = status passed o constructor to execute method
* @param BC batchable context variable.
* @return Database.QueryLocator.
*/
    global Database.QueryLocator start(Database.BatchableContext BC){      
        return Database.getQueryLocator(query);
    }
    
    /**
* execute method of batchable interface.
* calls updateConPositionAndAccAffiliation method of UpdConPostionAndAccAffServices
* responsible for updating tcontact position`s Status to past and 
* related account affiliations IsActive__c and Start & End date as per contact position` status
* @param BC batchable context variable.
* @param scope List<Contact_Position__c> returned by Start method.
* @return null.
*/
    global void execute(Database.BatchableContext BC, List<Membership_History__c> scope) {        
        errorMessage += updMemHistoryAndCreateAccAffServices.updateMmembershipHistoryAndCreateAffiliations(scope);
    }
    
    /**
* finish method of batchable interface.
* @param BC batchable context variable.
* @return null.
*/
    global void finish(Database.BatchableContext BC){
        updMemHistoryAndCreateAccAffServices.sendBatchEmailNotification(bc.getJobId(), 'Year End Batch', 'Year End Batch', errorMessage);
    }
}