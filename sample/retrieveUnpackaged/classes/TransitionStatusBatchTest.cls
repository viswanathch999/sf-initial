@isTest
private class TransitionStatusBatchTest {

    static testMethod void testTransitionStatusBatch() {
    	
    	Id memberRec = RecordTypeServices.getRecordTypeByName('Member', 'Contact').Id;
        Contact con = new Contact();
        
        con.LastName = 'Dude';
        con.RecordTypeId = memberRec;
        con.Grace_Accrued_FY17__c = 0;
        con.Tenure_FY17_c__c = 0;
        con.Transition_Status__c = 'Not Transitioned';
        con.BirthDate = Date.newInstance(1967, 12, 12);
        insert con;
        
        Contact actualCon = [SELECT Id, Tenure_FY17_c__c, Transition_Status__c, Grace_Years_used__c, Grace_Accrued_FY17__c, YPO_WPO_Formula__c, Age_Next_Fiscal_Year__c FROM Contact WHERE Id =: con.Id];
        System.debug('###actualCon; ' + actualCon);
        Test.startTest();
        	Database.executeBatch(new TransitionStatusBatch());
        Test.stopTest();
    }
}