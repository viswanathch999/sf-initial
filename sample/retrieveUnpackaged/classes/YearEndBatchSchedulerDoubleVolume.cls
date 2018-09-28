global class YearEndBatchSchedulerDoubleVolume implements Schedulable{
     /**
* start method of schedulable interface. 
* Method internally calls batch for contact position`s status current and elect.  
*/
    global void execute( SchedulableContext sc ) {        
         //Database.executeBatch(new UpdConPostionAndAccAffBatch('Current'));
        //Database.executeBatch(new UpdConPostionAndAccAffBatch('Elect'));
        //Database.executeBatch(new updMembershipHistoryAndCreateAccAffBatch());
        Id memberRecordTypeId = RecordTypeServices.getRecordTypeByName('Member', 'Contact').Id;
        
        List<Contact> flowContacts = [Select Id, Age_Next_Fiscal_Year__c, Transition_Status__c, Join_Date__c, 
                          Grace_Years_Used__c, Tenure_FY17_c__c 
                          From Contact 
                          Where RecordTypeId =: memberRecordTypeId 
                          AND Tenure_FY17_c__c != null
                          AND Age_Next_Fiscal_Year__c != null
                          AND Transition_Status__c != null
                          AND Grace_Years_Used__c != null
                          AND Grace_Accrued_FY17__c >= 2
                          AND YPO_WPO_Formula__c = 'YPO' 
                          AND Age_Next_Fiscal_Year__c >= 45];
         
        Set<Id> tempContactIds = new Set<Id>();
         for(Integer i = 0; i < flowContacts.size(); i++) {
           
           tempContactIds.add(flowContacts[i].Id);
           
           if(Math.mod(i, 400) == 0 || i == flowContacts.size() - 1) {
             callTransitionFlow(tempContactIds);
             tempContactIds.clear();
           }
         }
    }
    
    @future
    public static void callTransitionFlow(Set<Id> contactIds) {
      Map<String, Object> mapFlowInput = new Map<String, Object>();
      List<Contact> flowContactsRe = [Select Id, Age_Next_Fiscal_Year__c, Transition_Status__c, Join_Date__c, 
                          Grace_Years_Used__c, Tenure_FY17_c__c 
                          From Contact 
                          Where ID IN: contactIds];
         mapFlowInput.put('varSObjColContact', flowContactsRe);
        
         Flow.Interview.Transition_Status_Flow oFlow2 = new Flow.Interview.Transition_Status_Flow(mapFlowInput); 
         oFlow2.start();
    }
}