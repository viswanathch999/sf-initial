global class TransitionStatusBatch implements Database.Batchable<sObject> {


	global Database.QueryLocator start(Database.BatchableContext BC){ 
		
		Id memberRecordTypeId = RecordTypeServices.getRecordTypeByName('Member', 'Contact').Id;
        
        String query = 'Select Id, Age_Next_Fiscal_Year__c, Transition_Status__c, Join_Date__c, '+
                          'Grace_Years_Used__c, Tenure_FY17_c__c '+
                          'From Contact ' +
                          'Where RecordTypeId = \''+ memberRecordTypeId + '\' '+ 
                          'AND Tenure_FY17_c__c != null ' + 
                          'AND Age_Next_Fiscal_Year__c != null '+
                          'AND Transition_Status__c != null '+
                          'AND Grace_Years_Used__c != null '+
                          'AND Grace_Accrued_FY17__c != null '+
                          'AND YPO_WPO_Formula__c = \'YPO\' '+ 
                          'AND Age_Next_Fiscal_Year__c >= 45 ';     
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Contact> scope)
    {
        system.debug('scope '+scope);        
        //public static void callTransitionFlow(Set<Id> contactIds) {
      	Map<String, Object> mapFlowInput = new Map<String, Object>();
      	List<Contact> flowContactsRe = [Select Id, Age_Next_Fiscal_Year__c, Transition_Status__c, Join_Date__c, 
                          Grace_Years_Used__c, Tenure_FY17_c__c 
                          From Contact 
                          Where ID IN: Pluck.ids(scope)];
         mapFlowInput.put('varSObjColContact', flowContactsRe);
        
         Flow.Interview.Transition_Status_Flow oFlow2 = new Flow.Interview.Transition_Status_Flow(mapFlowInput); 
         oFlow2.start();
    
    }
    
    global void finish(Database.BatchableContext BC)
    {
    	
    }
    
}