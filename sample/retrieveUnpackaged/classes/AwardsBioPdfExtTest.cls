@isTest
private class AwardsBioPdfExtTest {
    public static final String ACCOUNT_AFFILIATION_ROLE = 'Member of Chapter';
    public static Account testAccount1;
    public static Account testAccount2;
    public static Contact testContact;
    public static Contact testContact2;
    public static Contact_Position__c originalConPos;    
    public static Contact_Position__c duplicateConPos;
    
    static void setup(){
        
        Account mockRegion = TestServices.createAccount('Test Region Chapter');
        mockRegion.Type = 'Region';
        mockRegion.RecordTypeId = RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        insert mockRegion;
        
        testAccount1 = TestServices.createAccount('Test 1');
        testAccount1.Type = 'Chapter';
        testAccount1.RecordTypeId =  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id; 
        testAccount1.ParentId = mockRegion.Id;
        insert testAccount1;
        Account testAccount3 = TestServices.createAccount('Test 2');
        testAccount3.Type = 'Relationship';
        insert testAccount3;
        testContact = TestServices.createContact('Test Last Name', testAccount1.Id);
        testContact.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member','Contact').Id;
        testContact.HouseholdID__c = testAccount3.id;
        testContact.MailingStreet = '123 Main St';
        testContact.MailingCity = 'LoveLand';
        testContact.MailingState = 'Colorado';
        testContact.MailingPostalCode = '80538';
        testContact.MailingCountry = 'United States';
        insert testContact;
        Position__c pos = Testservices.createPosition(false);
        pos.Member_Type__c = 'Member';
        insert pos;
        originalConPos = Testservices.createContactPosition(testAccount1.id, testContact.id, pos.id, 'Current', false);
        insert originalConPos;
        Event__c anEvent = new Event__c(Event_Name__c = 'Test');
        insert anEvent;
        insert new Contact_Event__c(Contact__c= testContact.id, Event__c= anEvent.id);
        insert TestServices.createRelationship(testContact.Id, testAccount3.Id, 'Member');
    
    }
    static testMethod void testLoadPage() {
        setup();        
        Test.startTest();
        Apexpages.StandardController oStandardContactCon = new Apexpages.StandardController(testContact);
        AwardsBioPdfExt ext = new AwardsBioPdfExt(oStandardContactCon);
        
        List<AwardsBioPdfExt.RelatedListWrapper> relatedListWrappersList = ext.relatedListWrappersList;
        List<AwardsBioPdfExt.RelatedListWrapper> meetingListWrappersList = ext.meetingListWrappersList;
        Test.stopTest();        
        //System.assert(!result, 'Duplicate_Contact_Position error should be thrown');
    }
}