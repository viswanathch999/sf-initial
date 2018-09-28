@isTest
private class ContactPositionTest {
    public static final String ACCOUNT_AFFILIATION_ROLE = 'Member of Chapter';
    public static Account testAccount1;
    public static Account testAccount2;
    public static Contact testContact1;
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
        testAccount2 = TestServices.createAccount('Test 2');
        testAccount2.Type = 'Chapter';
        testAccount2.RecordTypeId =  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id; 
        testAccount2.ParentId = mockRegion.Id;
        insert testAccount2;
        Account testAccount3 = TestServices.createAccount('Test 2');
        insert testAccount3;
        testContact1 = TestServices.createContact('Test Last Name', testAccount1.Id);
        testContact1.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member','Contact').Id;
        testContact1.HouseholdID__c = testAccount3.id;
        testContact1.MailingStreet = '123 Main St';
        testContact1.MailingCity = 'LoveLand';
        testContact1.MailingState = 'Colorado';
        testContact1.MailingPostalCode = '80538';
        testContact1.MailingCountry = 'United States';
        insert testContact1;
        testContact2 = TestServices.createContact('Test Last Name', testAccount2.Id);
        testContact2.HouseholdID__c = testAccount3.id;
        testContact2.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member','Contact').Id;
        testContact2.MailingStreet = '123 Main St';
        testContact2.MailingCity = 'Atlanta';
        testContact2.MailingState = 'Georgia';
        testContact2.MailingPostalCode = '30363';
        testContact2.MailingCountry = 'United States';
        insert testContact2;
        Position__c pos = Testservices.createPosition(false);
        pos.Member_Type__c = 'Member';
        insert pos;
        originalConPos = Testservices.createContactPosition(testAccount1.id, testContact1.id, pos.id, 'Current', false);
        insert originalConPos;
        duplicateConPos = Testservices.createContactPosition(testAccount1.id, testContact2.id, pos.id, 'Current', false);        
    }
    static testMethod void testgivenAExistingConPos_WhenDuplicateConPosInserted_thenErrorOut() {
        setup();
        
        Test.startTest();
        	Boolean result = ContactPositionServices.validateDuplicatePositionRecords( new List<Contact_Position__c> { duplicateConPos } );
		Test.stopTest();

		System.assert(!result, 'Duplicate_Contact_Position error should be thrown');
    }
    
    static testMethod void testContactPositionEditController_Save(){
    	setup();
    	ApexPages.StandardController sc = new ApexPages.StandardController(duplicateConPos);
    	ContactPositionEditController cpCont = new ContactPositionEditController(sc);
    	
    	Test.startTest();
    		cpCont.theCp = duplicateConPos;
    		PageReference result1 = cpCont.saveCustom();
    		PageReference result2 = cpCont.saveCustom();
    	Test.stopTest();
    	
    	System.assertEquals(null, result1, 
    			'We expect a null page reference to be returned when there is a duplicate Contact Position saved');
    	System.assertEquals(true, cpCont.saveAttempted, 
    			'We expect the save Attempted boolean to be set when a duplicate Contact position is saved');
    	System.assertNotEquals(null, result2, 
    			'We expect a the detail page to be returned when save is pressed a second time');
    	
    }

    static testMethod void testContactPositionEditController_SaveAndNew(){
    	setup();
    	ApexPages.StandardController sc = new ApexPages.StandardController(duplicateConPos);
    	ContactPositionEditController cpCont = new ContactPositionEditController(sc);
    	
    	Test.startTest();
    		cpCont.theCp = duplicateConPos;
    		PageReference result = cpCont.saveAndNew();
    		PageReference result2 = cpCont.saveAndNew();
    	Test.stopTest();
    	
    	System.assertEquals(null, result, 
    			'We expect a null page reference to be returned when there is a duplicate Contact Position saved');
    	System.assertEquals(true, cpCont.saveNewAttempted, 
    			'We expect the save Attempted boolean to be set when a duplicate Contact position is saved');
    	System.assertEquals(Page.ContactPositionEdit.getUrl(), result2.getUrl(), 
    			'We expect the edit page to be returned when save is pressed a second time');
    }
}