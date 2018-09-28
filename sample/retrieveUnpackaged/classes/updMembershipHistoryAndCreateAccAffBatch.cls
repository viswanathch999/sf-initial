/**
* updMembershipHistoryAndCreateAccAffBatch is scheduler which will run at year end and do the following
* For all Contact Position Records currently at Status 'Current'. 
* Update Status to Past
* Find Account Affiliation for Account__c on Contact Position and 
* update end date to 6/30 year just finished and uncheck Is_Active__c (make FALSE).
*
* @author Nikunj Doshi
*/
global class updMembershipHistoryAndCreateAccAffBatch implements Database.Stateful, Database.Batchable<sObject>{
    global String query;
    global String errorMessage = '';
    public updMembershipHistoryAndCreateAccAffBatch(){
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
        Map<String, Object> mapFlowInput = new Map<String, Object>();
        Flow.Interview.Grace_Accrual_v_3_0 oFlow1 = 
            new Flow.Interview.Grace_Accrual_v_3_0(mapFlowInput); 
        oFlow1.start();
        Flow.Interview.Transition_Status_Flow oFlow2 = 
            new Flow.Interview.Transition_Status_Flow(mapFlowInput); 
        oFlow2.start();
    }
}