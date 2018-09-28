/**
* UpdConPostionAndAccAffBatch is scheduler which will run at year end and do the following
* For all Contact Position Records currently at Status 'Current'. 
* Update Status to Past
* Find Account Affiliation for Account__c on Contact Position and 
* update end date to 6/30 year just finished and uncheck Is_Active__c (make FALSE).
*
* @author Nikunj Doshi
*/
global class UpdConPostionAndAccAffBatch implements Database.Stateful, Database.Batchable<sObject>{
    String query;
    global String status = '';
    public UpdConPostionAndAccAffBatch(){
        query = 'Select Id, account__c, Status__c, Position__r.Position_Category__c, Contact__r.Number_Years_a_Member__c From Contact_Position__c Where Status__c = \'Current\'';
        status = 'Current';
    }
    /**
* Contructor takes constructs the start query for all the Contact_Position__c Where Status__c is 'Current'
* @param status, status:-> 'Current'/'Elect'
*/
    public UpdConPostionAndAccAffBatch(String status){
        this.status = status;
        query = 'Select Id, account__c, Status__c, Position__r.Position_Category__c, Contact__r.Number_Years_a_Member__c From Contact_Position__c Where Status__c = \''+status+'\'';
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
    global void execute(Database.BatchableContext BC, List<Contact_Position__c> scope) {        
        UpdConPostionAndAccAffServices.updateConPositionAndAccAffiliation(scope);
    }
    
    /**
* finish method of batchable interface.
* @param BC batchable context variable.
* @return null.
*/
    global void finish(Database.BatchableContext BC){
        if(status == 'Current'){
            Database.executeBatch(new UpdConPostionAndAccAffBatch('Elect'));
        }
        else if(status == 'Elect'){
            Database.executeBatch(new updMembershipHistoryAndCreateAccAffBatch());
        }
    }
}