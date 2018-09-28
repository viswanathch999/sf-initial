@isTest
public class UpdConPostionAndAccAffBatchTest {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    public static final String ACCOUNT_AFFILIATION_ROLE = 'Member of Chapter';
  
    @testSetup
    static void setup(){
        
        Account mockRegion = TestServices.createAccount('Test Region Chapter');
        mockRegion.Type = 'Region';
        mockRegion.RecordTypeId = RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        insert mockRegion;
        
        Account testAccount1 = TestServices.createAccount('Test 1');
        testAccount1.Type = 'Chapter';
        testAccount1.RecordTypeId =  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        testAccount1.ParentId = mockRegion.Id;  
        insert testAccount1;
        
        Account testAccount2 = TestServices.createAccount('Test 2');
        testAccount2.Type = 'Chapter';
        testAccount2.RecordTypeId =  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        testAccount2.ParentId = mockRegion.Id;  
        insert testAccount2;
        
        Contact testContact1 = TestServices.createContact('Test Last Name', testAccount1.Id);
        testContact1.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member','Contact').Id;
        insert testContact1;
        
        Contact testContact2 = TestServices.createContact('Test Last Name', testAccount1.Id);
        testContact2.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member','Contact').Id;
        insert testContact2;
        
        Id profileId = [SELECT id FROM Profile WHERE Name =:Label.Partner_User_Custom].id;
        User oUser1 = TestServices.createPartnerCommunityUser(testContact1.id, profileId);
        insert oUser1;
        
        CA_Setting__c oCASetting = TestServices.createCASetting(testAccount1.id, oUser1.id, true);
        oCASetting.Primary__c = true;
        oCASetting.Role__c = 'Chapter Administrator';
        insert oCASetting;
        
        Account_Affiliation__c testAccAff1 = TestServices.createAccountAffiliation(testAccount1.Id,testContact1.Id);
        testAccAff1.Role__c = ACCOUNT_AFFILIATION_ROLE;
        testAccAff1.isActive__c = true;
        //insert testAccAff1;
        
        Account_Affiliation__c testAccAff2 = TestServices.createAccountAffiliation(testAccount2.Id,testContact2.Id);
        testAccAff2.Role__c = ACCOUNT_AFFILIATION_ROLE;
        testAccAff2.isActive__c = true;
        insert new List<Account_Affiliation__c> {testAccAff2, testAccAff1};
        
        Position__c pos = Testservices.createPosition(true);
        Contact_Position__c cp1 = Testservices.createContactPosition(testAccount1.id, testContact1.id, pos.id, 'Current', true);
        Contact_Position__c cp2 = Testservices.createContactPosition(testAccount2.id, testContact2.id, pos.id, 'Elect', true);
    }
  
    @isTest
    static void givenContactPositions_WhenUpdConPostionAndAccAffBatchRuns_thenScheduleUpdConPostionAndAccAffBatch(){
        
        Test.startTest();
        setup();
        System.schedule('ScheduleApexClassTest', CRON_EXP,  new YearEndBatchScheduler());        
        Test.stopTest();
       }
      
    @isTest
    static void givenCurrentContactPositions_WhenUpdConPostionAndAccAffBatchRuns_thenUpdConPostionAndAccAff(){
        
        Test.startTest();
        setup();
        Database.executeBatch(new UpdConPostionAndAccAffBatch('Current'));        
        Test.stopTest();
        Id acc1Id = [Select Id from Account where name='Test 1'][0].id;
        String status1 =[Select status__c from Contact_Position__c where account__c =: acc1Id][0].status__c;
        System.assertEquals('Past', status1, 'Contact_Position__c should be marked as Past');
        Account_Affiliation__c aff1 = [Select End_Date__c, IsActive__c from Account_Affiliation__c where account__c =: acc1Id][0];
        system.assertEquals(false, aff1.IsActive__c, 'Should be marked inactive');
        system.assertEquals(date.newInstance(System.today().year(), 6, 30),
                            aff1.End_Date__c, 'Should be set to  6/30 year of current year');
        
    }
    
    @isTest
    static void givenElectContactPositions_WhenUpdConPostionAndAccAffBatchRuns_thenUpdConPostionAndAccAff(){
        Test.startTest();
        setup();        
        Database.executeBatch(new UpdConPostionAndAccAffBatch('Elect'));        
        Test.stopTest();
        Id acc2Id = [Select Id from Account where name='Test 2'][0].id;
        String status2 =[Select status__c from Contact_Position__c where account__c =: acc2Id][0].status__c;
        System.assertEquals('Current', status2, 'Contact_Position__c should be marked as Past');
        Account_Affiliation__c aff2 = [Select start_Date__c, IsActive__c, End_Date__c from Account_Affiliation__c where account__c =: acc2Id][0];
        system.assertEquals(true, aff2.IsActive__c, 'Should be marked as active');
        system.assertEquals(date.newInstance(System.today().year(), 7, 1),
                            aff2.Start_Date__c, 'Should be set to 7/1 year of current year');
    }
}