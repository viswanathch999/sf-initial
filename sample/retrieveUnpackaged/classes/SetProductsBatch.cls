global class SetProductsBatch implements Database.Batchable<sObject>{
    global String query;
   
    
    global Database.QueryLocator start(Database.BatchableContext BC){      
       Date nextFiscalStart = FiscalDateUtility.startOfNextFiscal; 
           Date thisFiscalYear = FiscalDateUtility.startOfCurrentFiscal;
        
        query = 'SELECT Id, KGRenewal__Contact__c, KGRenewal__IsActiveCart__c, KGRenewal__Contact__r.YPO_WPO_Formula__c, KGRenewal__Contact__r.Tenure_FY17_c__c, Referred_by_Chapter__c, Record_Type_Name__c,'+
            +' KGRenewal__Contact__r.Number_Years_a_Member__c, KGRenewal__Contact__r.Date_Last_Grace_Year_Used__c FROM Opportunity WHERE StageName = \'Cycle Open\' ';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {   
        RenewalsBatchServices.opportunitySetProductFlow(scope);
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}