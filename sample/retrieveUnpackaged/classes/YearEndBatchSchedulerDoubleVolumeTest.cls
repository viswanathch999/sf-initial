@isTest
private class YearEndBatchSchedulerDoubleVolumeTest {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    static testMethod void testYearEndBatchScheduler() {
        Id memberRecordTypeId = RecordTypeServices.getRecordTypeByName('Member', 'Contact').Id;
        Contact oContact = new Contact();
        oContact.RecordTypeId = memberRecordTypeId;
        oContact.Tenure_FY17_c__c = 5;
        oContact.Transition_Status__c = 'Eligible for early transition';
        oContact.Tenure_FY17_c__c = 5;
        oContact.Grace_Accrued_FY17__c = 3;
        oContact.Birthdate = Date.newInstance(1966, 5, 13);
        oContact.LastName = 'Some Contact';
        insert oContact;
        
        Test.startTest();
            System.schedule('ScheduleApexClassDoubleVolumeTest', CRON_EXP,  new YearEndBatchSchedulerDoubleVolume()); 
        Test.stopTest();
        
    }
}