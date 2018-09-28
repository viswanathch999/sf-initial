@isTest
private class ContactTriggerTest {
    
    static final String CONST_PARTNER_USER = 'Partner User';
    static final String CONST_CHAPTER = 'Chapter';
    static final String CONST_ACCOUNT = 'Account';
    static final String CONST_MEMBER = 'Member';
    static final String CONST_PROSPECT = 'Prospect';
    static final String CONST_CONTACT = 'Contact';
    static final String STATUS_NEW = 'New';
    static final String STATUS_NOT_PURSUE = 'Will not pursue';
    static final String ACCESS_EDIT = 'Edit';
    static final String ACCESS_NONE = 'None';
    static User adminUser;
    static Account chapter;
    static User adminUser2;
    static User adminUser3;
    static Account chapter2;
    static Contact prospectContact;
    static Contact memberContact;
    
    
    private static void setup(){
        
        //insert new Profile_Completion_Criteria__c(Name = 'Test Criteria', Primary_Address__c = 1, External_Connection__c = 1);
        
        Id profileId = [SELECT id FROM Profile WHERE Name =: CONST_PARTNER_USER].id;
        chapter = TestServices.createAccount('Test-Account1');
        chapter.RecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Chapter', 'Account').id;
        chapter.Type = 'Chapter';
        insert chapter;
        
        Id memberContRType = RecordTypeServices.getRecordTypeByDeveloperName('Member', 'Contact').id;
        
        Contact oContact1 = TestServices.createContact(chapter.id, memberContRType, true);
        //insert oContact1;
        
        adminUser = TestServices.createPartnerCommunityUser(oContact1.id, profileId);
        insert adminUser;
        chapter2 = TestServices.createAccount('Test-Account3');
        chapter2.RecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Chapter', 'Account').id;
        chapter2.Type = 'Chapter';
        insert chapter2;
        Contact oContact2 = TestServices.createContact(chapter2.id, memberContRType, false);
        oContact2.Email = 'con2@mail.com';
        insert oContact2;
        adminUser2 = TestServices.createPartnerCommunityUser(oContact2.id, profileId);
        insert adminUser2;

        Contact oContact3 = TestServices.createContact(chapter.id, memberContRType, false);
        oContact3.Email = 'con3@mail.com';
        insert oContact3;
        adminUser3 = TestServices.createPartnerCommunityUser(oContact3.id, profileId);
        insert adminUser3;
        
        TestServices.createCASetting(chapter.id, adminUser3.id, true, true);
        TestServices.createCASetting(chapter.id, adminUser.id, true, true);
        TestServices.createCASetting(chapter2.id, adminUser2.id, true, true);
        TestServices.createContact_Share_Settings(CONST_PROSPECT, ACCESS_EDIT, true);
        TestServices.createContact_Share_Settings(CONST_MEMBER, ACCESS_NONE, true);   
        prospectContact = 
            TestServices.createContact(chapter.Id, RecordTypeServices.getRecordTypeByDeveloperName(CONST_PROSPECT, CONST_CONTACT).Id, false);
        memberContact = 
            TestServices.createContact(chapter.Id, RecordTypeServices.getRecordTypeByDeveloperName(CONST_MEMBER, CONST_CONTACT).Id, false);
    }
    
    
    static testMethod void testgivenCASettings_WhenContactIsInserted_thenEditContactShareRecordsInserted() {
        setup();
        Test.startTest();
        ContactServices.rtToAccess= null; 
        insert prospectContact;
        Test.stopTest();
        List<ContactShare> insertedShares =
            [Select Id from ContactShare where ContactId =: prospectContact.id and UserOrGroupId IN : new Set<Id> { adminUser.id, adminUser3.Id } and ContactAccessLevel =: ACCESS_EDIT];
        //System.assertEquals(2, insertedShares.size(), 'Contact share record with edit access should be created for chapter admins');
    }
    
    
    static testMethod void testgivenCASettings_WhenContactIsInserted_thenNoContactShareRecordsInserted() {
        setup();
        Test.startTest();
        ContactServices.rtToAccess= null; 
        insert memberContact;
        Test.stopTest();
        List<ContactShare> insertedShares =
            [Select Id from ContactShare where ContactId =: memberContact.id and UserOrGroupId =: adminUser.id and ContactAccessLevel =: ACCESS_EDIT];
        //System.assertEquals(0, insertedShares.size(),
        //                    'No Contact share record should be created for chapter admin as none access level mentioned in custom setting');
    }
    
    
    static testMethod void testgivenCASettings_WhenContactsChapterIsUpdated_thenContactShareRecordsUpdated() {
        setup();
        ContactServices.rtToAccess= null; 
        insert prospectContact;
            Test.startTest();
        ContactServices.rtToAccess= null; 
        prospectContact.accountId = chapter2.id;
        update prospectContact;
        Test.stopTest();
        List<ContactShare> deletedSharesForAdmin1 = new List<ContactShare>();
        deletedSharesForAdmin1 = 
            [Select Id from ContactShare where ContactId =: prospectContact.id and 
             UserOrGroupId =: adminUser.id and ContactAccessLevel =: ACCESS_EDIT];
        //System.assertEquals(0, deletedSharesForAdmin1.size(), 'Contact share record with edit access for admin1 should be deleted');
        List<ContactShare> insertedSharesForAdmin2 =
            [Select Id from ContactShare where ContactId =: prospectContact.id and UserOrGroupId =: adminUser2.id and ContactAccessLevel =: ACCESS_EDIT];        
        //System.assertEquals(1, insertedSharesForAdmin2.size(), 'Contact share record with edit access should be created for chapter2`s admin');
        
    }
    
    
    static testMethod void testgivenCASettings_WhenContactsRecordTypeIsUpdated_thenContactShareRecordsUpdated() {
        setup();
        ContactServices.rtToAccess= null; 
        insert prospectContact;
        List<ContactShare> insertedShares =
            [Select Id from ContactShare where ContactId =: prospectContact.id and UserOrGroupId =: adminUser.id and ContactAccessLevel =: ACCESS_EDIT];
        //System.assertEquals(1, insertedShares.size(), 'Contact share record with edit access should be created for chapter admin');
        
        Test.startTest();
        prospectContact.recordtypeid =  RecordTypeServices.getRecordTypeByDeveloperName(CONST_MEMBER, CONST_CONTACT).Id;
        update prospectContact;
        Test.stopTest();
        List<ContactShare> deletedSharesForAdmin1 = new List<ContactShare>();
        deletedSharesForAdmin1 = 
            [Select Id from ContactShare where ContactId =: prospectContact.id and 
             UserOrGroupId =: adminUser.id];
        //System.assertEquals(0, deletedSharesForAdmin1.size(), 'Contact share record with edit access for admin1 should be deleted');
    }
}