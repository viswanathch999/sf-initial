@isTest
public class updMembershipHistoryAndCreateAccAffTest {
    
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    public static final String ACCOUNT_AFFILIATION_ROLE = 'Member of Chapter';
    public static Account testAccount1;
    public static Account testAccount2;
    public static Contact testContact1;
    public static Contact testContact2;
    
    static void createTestData(){
        
        Account mockRegion = TestServices.createAccount('Test Region Chapter');
        mockRegion.Type = 'Region';
        mockRegion.RecordTypeId = RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        insert mockRegion;
        
        testAccount1 = TestServices.createAccount('Test 1');
        testAccount1.Type = 'Chapter';
        testAccount1.RecordTypeId =  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id; 
        testAccount1.ParentId = mockRegion.Id;
        insert testAccount1;
        testAccount2 = TestServices.createAccount('Test 2');
        testAccount2.Type = 'Chapter';
        testAccount2.RecordTypeId =  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id; 
        testAccount2.ParentId = mockRegion.Id;
        insert testAccount2;
        Account testAccount3 = TestServices.createAccount('Test 2');
        insert testAccount3;
        testContact1 = TestServices.createContact('Test Last Name', testAccount1.Id);
        testContact1.HouseholdID__c = testAccount3.id;
        testContact1.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member','Contact').Id;
        insert testContact1;
        testContact2 = TestServices.createContact('Test Last Name', testAccount2.Id);
        testContact2.HouseholdID__c = testAccount3.id;
        testContact2.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member','Contact').Id;
        insert testContact2;
        Account_Affiliation__c testAccAff1 = TestServices.createAccountAffiliation(testAccount1.Id,testContact1.Id);
        testAccAff1.Role__c = ACCOUNT_AFFILIATION_ROLE;
        testAccAff1.isActive__c = true;
        insert testAccAff1;
        Position__c pos = Testservices.createPosition(false);
        pos.Member_Type__c = 'Member';
        insert pos;
        Contact_Position__c cp1 = Testservices.createContactPosition(testAccount1.id, testContact1.id, pos.id, 'Current', false);
        cp1.Committee_Member_Type__c = 'Member';
        insert cp1;
        Contact_Position__c cp2 = Testservices.createContactPosition(testAccount2.id, testContact2.id, pos.id, 'Elect', true);
        insert new Membership_History__c(Contact__c = testContact1.id, account__c = testAccount2.id, Status__c= 'Member', YPO_WPO__c='WPO');
        Opportunity opp = new Opportunity(
            StageName = 'New', 
            Name = 'TestOpp',
            CloseDate = System.today(),
            recordtypeid = RecordTypeServices.getRecordTypeByDeveloperName('Member', 'Opportunity').Id,
            accountid = testAccount2.id,
            KGRenewal__Contact__c = testContact1.Id
        );
        insert opp;
        OpportunityContactRole ocr = new OpportunityContactRole(
            OpportunityId = opp.Id, 
            ContactId = testContact2.Id, 
            Role = 'Other'
        ) ;
        insert ocr;
    }
    
    static testMethod void givenContactPositions_WhenUpdConPostionAndAccAffBatchRuns_thenScheduleUpdConPostionAndAccAffBatch(){
        createTestData();
        
        Test.startTest();
        Database.executeBatch(new updMembershipHistoryAndCreateAccAffBatch());    
        Test.stopTest();
        List<Account_Affiliation__c> affs = [Select id, Account__r.name from Account_Affiliation__c where account__c =: testAccount2.id];
        //TODO: UPdate above batch for current state req's and update unit tests. 
        /*System.assertEquals(1, affs.size());
        Contact con = [Select accountId from contact where id =:testContact2.id];
        System.assertEquals(testAccount2.id, con.AccountId);
        List<Membership_History__c> mhs =
            [Select Id from Membership_History__c where status__c = 'Resigned' and reason__c = 'Transitioned'];
        System.assertEquals(1, mhs.size()); */      
    }
}