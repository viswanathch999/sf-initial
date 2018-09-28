/**
* This class contains unit tests for validating the behavior of FlattenMultiSelectPicklistFieldBatch
* "Given" defines the preconditions, "When" defines what happens, and 
* "Then" defines the result of the scenario. Or in other words: 
* "Given" describes the start state, and "When" the steps 
* necessary to reach the accepting state (= "Then").
* FlattenMultiSelectPicklistFieldBatchTest is service as test class for FlattenMultiSelectPicklistFieldBatch 
* which copies the data from multiple multiselect picklists defined in custom setting M2MXSkillsetSearchObject
* into a text field containing the concatenation from all the multiselect fields.
* 
* @author: Nikunj Doshi
*/

@isTest
private class FlattenMultiSelectPicklistFieldBatchTest {
    public static Contact testContact;
    public static Account testAccount1;
    public static Account_Affiliation__c testAccAff1;
    public static final String ACCOUNT_AFFILIATION_ROLE = 'Member of Chapter';
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    /*
* Test Data generation method for FlattenMultiSelectPicklistFieldBatchTest
* @returns null
*/
    @testSetup
    static void createTestData(){
        
        Account mockRegion = TestServices.createAccount('Test Region Chapter');
        mockRegion.Type = 'Region';
        mockRegion.RecordTypeId = RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        insert mockRegion;
        
        testAccount1 = TestServices.createAccount('Test Account Name');
        testAccount1.Type = 'Chapter';
        testAccount1.RecordTypeId =  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        testAccount1.ParentId = mockRegion.Id; 
        insert testAccount1;
        
        testContact = TestServices.createContact('Test Last Name', testAccount1.Id);
        insert testContact;
        
        testAccAff1 = TestServices.createAccountAffiliation(testAccount1.Id,testContact.Id);
        testAccAff1.Role__c = ACCOUNT_AFFILIATION_ROLE;
        testAccAff1.Industry_Sub_Category_1__c =' a;b';
        testAccAff1.Industry_Sub_Category_2__c= 'C;D';
        testAccAff1.Industry_Sub_Category_3__c= 'E;F';
        testAccAff1.isActive__c = true;
        insert testAccAff1;
        
    }
    /*
* Positive Test Method for FlattenMultiSelectPicklistFieldBatch
* @returns null
*/
    static testMethod void givenM2MXSkillsetSearchObject_WhenFlattenMultiSelectPicklistFieldBatchRuns_thenFlattenMultiSelects(){
        createTestData();
        
        TestServices.createM2MXSkillsetSearchObject('Account_Affiliation__c', 
                                                    'Industry_Sub_Category_1__c,Industry_Sub_Category_2__c,Industry_Sub_Category_3__c',
                                                    'MultiSelectPicklists_Text__c', true);    
        Test.startTest();
        FlattenMultiSelectPicklistFieldBatch fb= new FlattenMultiSelectPicklistFieldBatch('Account_Affiliation__c');
        Database.executeBatch(fb);         
        Test.stopTest();
        Account_Affiliation__c insertedAffiliation = [Select MultiSelectPicklists_Text__c from Account_Affiliation__c][0];
        System.assertEquals('E;F;C;D;a;b', insertedAffiliation.MultiSelectPicklists_Text__c, 'Text field should have been updated with concatenation of multiselect fields');
    }
    
    /*
* Negative Test Method for FlattenMultiSelectPicklistFieldBatch
* @returns null
*/
    static testMethod void givenNoM2MXSkillsetSearchObject_WhenFlattenMultiSelectPicklistFieldBatchRuns_thenDontFlattenMultiSelects(){
        createTestData();
        TestServices.createM2MXSkillsetSearchObject('Account_Affiliation__c', 
                                                    'Industry_Sub_Category_1__c,Industry_Sub_Category_2__c',
                                                    'MultiSelectPicklists_Text__c', true);    
        Test.startTest();
        FlattenMultiSelectPicklistFieldBatch fb= new FlattenMultiSelectPicklistFieldBatch('Account_Affiliation__c');
        Database.executeBatch(fb);         
        Test.stopTest();
        Account_Affiliation__c insertedAffiliation = [Select MultiSelectPicklists_Text__c from Account_Affiliation__c][0];
        System.assertNotEquals('E;F;C;D;a;b', insertedAffiliation.MultiSelectPicklists_Text__c, 
                               'Text field should have been updated only with concatenation of multiselect fields Industry_Sub_Category_1__c & Industry_Sub_Category_2__c');
    }
    static testMethod void testFlattenMultiSelectPicklistFieldBatchSchedule(){
        createTestData();
        TestServices.createM2MXSkillsetSearchObject('Account_Affiliation__c', 
                                                    'Industry_Sub_Category_1__c,Industry_Sub_Category_2__c',
                                                    'MultiSelectPicklists_Text__c', true);    
        Test.startTest();
        System.schedule('MarchEndBatchJob', CRON_EXP,  new FlattenMultiSelectPicklistFieldBatch('Account_Affiliation__c'));        
        
        Test.stopTest();
    }
}