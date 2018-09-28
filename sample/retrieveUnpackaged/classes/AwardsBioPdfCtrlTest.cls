@isTest
private class AwardsBioPdfCtrlTest {
    
    private static Account regionAccount { get; set; }
    private static Account chapterAccount { get; set; }
    private static Account householdAccount { get; set; }
    private static Account eventAccount { get; set; }
    private static Contact testContact { get; set; }
    

    static void setupMember() {
        regionAccount = TestServices.createChapterAccount('Test Region', RecordTypeServices.getRecordTypeByName('Chapter', 'Account').Id);
        insert regionAccount;
        
		chapterAccount = TestServices.createChapterAccount('Test Chapter', RecordTypeServices.getRecordTypeByName('Chapter', 'Account').Id);
        chapterAccount.ParentId = regionAccount.Id;
        insert chapterAccount;
        
        householdAccount = TestServices.createAccount('Test Household');
		householdAccount.RecordTypeId = RecordTypeServices.getRecordTypeByName('Relationship', 'Account').Id;
        householdAccount.Type = 'Relationship';
        insert householdAccount;
        
        testContact = TestServices.createContact('Test Last Name', chapterAccount.Id);
        testContact.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member', 'Contact').Id;
        testContact.HouseholdId__c = householdAccount.Id;
        testContact.Active__c = true;
        testContact.MailingStreet = '123 Main St';
        testContact.MailingCity = 'LoveLand';
        testContact.MailingState = 'Colorado';
        testContact.MailingPostalCode = '80538';
        testContact.MailingCountry = 'United States';
        testContact.Country_Code__c = '1';
        testContact.Phone = '111-111-1111';
        testContact.Phone_Extension__c = '1111';
        testContact.Home_Phone_Country_Code__c = '2';
        testContact.HomePhone = '222-222-2222';
        testContact.Home_Phone_Extension__c = '';
        testContact.Mobile_Phone_Country_Code__c = '';
        testContact.MobilePhone = '333-333-3333';
        testContact.Birthdate = Date.newInstance(1960, 1, 1);
        testContact.Biography__c = 'Test Bio';
        insert testContact;
        
        insert TestServices.createRelationship(testContact.Id, householdAccount.Id, 'Member');
        
		System.debug('Member Created: ' + testContact);
		System.debug('Region: ' + regionAccount);
		System.debug('Chapter: ' + chapterAccount);
		System.debug('Household: ' + householdAccount);

        /*
        originalConPos = TestServices.createContactPosition(chapterAccount.Id, testContact.Id, pos.Id, 'Current', false);
        insert originalConPos;
        
        Event__c anEvent = new Event__c(Event_Name__c = 'Test Event');
        insert anEvent;
        
        insert new Contact_Event__c(Contact__c = testContact.Id, Event__c = anEvent.Id);
        */
    }
    

    static void setupPositions() {
        List<String> positionCategories = new List<String> { 'Committee', 'Chapter', 'Region', 'Network', 'Event' };
        Position__c pos;
        for (String cat : positionCategories) {
            pos = new Position__c();
            pos = TestServices.createPosition(false);
            pos.Position_Category__c = cat;
            insert pos;
            insert new Contact_Position__c(Contact__c = testContact.Id, 
                                           Account__c = chapterAccount.Id, 
                                           Position__c = pos.Id, 
                                           Start_Date__c = Date.today().addDays(-1), 
                                           End_Date__c = Date.today().addDays(1),
                                           Status__c = 'ACTIVE');
			System.debug('Contact Position inserted: ' + pos);
        }
    }
    

    static void setupAffiliations() {
        List<String> affiliationTypes = new List<String> { 'Committee', 'Network' };
        Account_Affiliation__c aff;
        
        for (String afftype : affiliationTypes) {
            eventAccount = TestServices.createAccount('Test Event Account');
            eventAccount.Type = 'Event';
            eventAccount.RecordTypeId = RecordTypeServices.getRecordTypeByName('Committee', 'Account').Id;
            insert eventAccount;
            
            aff = new Account_Affiliation__c();
            aff = TestServices.createAccountAffiliation(eventAccount.Id, testContact.Id, true, RecordTypeServices.getRecordTypeByName(afftype, 'Account_Affiliation__c').Id, false);
            insert aff;
			System.debug('Account Affiliation Inserted: ' + aff);
        }
    }
    

    static void setupEvents() {
		List<String> eventFormats = new List<String> { 'GLC/CLW', 'Non-Chapter Event', 'Non-Chapter Event Complex', 'Fast Track Event', 'Global Conference Call (GCC)', 'Regional Board Meeting' };
		for (String format : eventFormats) {
			Event__c parentEvent = new Event__c();
			parentEvent.Event_Name__c = format + 'Event';
			parentEvent.Program_Format__c = format;
			parentEvent.Start_Date__c = Date.today().addDays(-1);
			parentEvent.End_Date__c = Date.today().addDays(1);
			insert parentEvent;

			Contact_Event__c cEvent = new Contact_Event__c();
			cEvent.Contact__c = testContact.Id;
			cEvent.Event__c = parentEvent.Id;
			insert cEvent;
			System.debug('Contact Event Inserted: ' + cEvent);
		}
    }
    

    static void setupAchievements() {
        List<String> achvTypes = new List<String> { 'Award' };
		for (String aType : achvTypes) {
			Achievement__c achievement = new Achievement__c();
			achievement.RecordType = RecordTypeServices.getRecordTypeByDeveloperName(aType, 'Achievement__c');
			achievement.Achievement_Category__c = aType;
			achievement.Achievement_Type__c = 'Both';
			achievement.Award_Department__c = 'Family';
			achievement.Membership_Type__c = 'YPO';
			achievement.Name__c = 'Test Achievement';
			achievement.Stage__c = 'Awarded for year';
			achievement.Status__c = 'Active';
			achievement.Type__c = 'International';
			achievement.Validation_Check__c = false;
			insert achievement;

			Contact_Achievement__c ca = new Contact_Achievement__c();
			ca.Achievement__c = achievement.Id;
			ca.RecordType = RecordTypeServices.getRecordTypeByDeveloperName(aType, 'Contact_Achievement__c');
			ca.Contact__c = testContact.Id;
			ca.Candidate_Status__c = 'Selected';
			ca.YPO_Award_Year__c = '2015-2016';
			insert ca;
		}
    }
        

	@IsTest
	private static void testPageLoad() {
		setupMember();
        Test.startTest();
        
		// Load page with no contact
		PageReference reportPage = new PageReference('Page.AwardsBioPdfView');
		Test.setCurrentPageReference(reportPage);
		AwardsBioPdfCtrl ctrl = new AwardsBioPdfCtrl();

		// Load page properly
		reportPage = new PageReference('Page.AwardsBioPdfView');
		Test.setCurrentPageReference(reportPage);
		ApexPages.currentPage().getParameters().put('id', testContact.Id);
		ctrl = new AwardsBioPdfCtrl();

        Test.stopTest();
	}
	

	@IsTest
	private static void testPositions() {
	    setupMember();
	    setupPositions();
	    
		Test.startTest();
		PageReference reportPage = Page.AwardsBioPdfView;
		Test.setCurrentPageReference(reportPage);
		ApexPages.currentPage().getParameters().put('id', testContact.Id);
		AwardsBioPdfCtrl ctrl = new AwardsBioPdfCtrl();
	    Test.stopTest();
	    
        System.assertEquals(1, ctrl.committeePositions.size());
        System.assertEquals(1, ctrl.chapterOfficers.size());
        System.assertEquals(1, ctrl.regionOfficers.size());
        System.assertEquals(1, ctrl.networkOfficers.size());
        System.assertEquals(1, ctrl.meetingsChampioned.size());
	}
	
	private static testMethod void testAffiliations() {
	    setupMember();
	    setupAffiliations();
	    
		Test.startTest();
	    PageReference reportPage = Page.AwardsBioPdfView;
		Test.setCurrentPageReference(reportPage);
		ApexPages.currentPage().getParameters().put('id', testContact.Id);
		AwardsBioPdfCtrl ctrl = new AwardsBioPdfCtrl();
	    Test.stopTest();

	    System.assertEquals(1, ctrl.committeeMemberships.size());
	    System.assertEquals(1, ctrl.networkMemberships.size());
	}
	
	private static testMethod void testEvents() {
	    setupMember();
		setupEvents();
	    
		Test.startTest();
	    PageReference reportPage = Page.AwardsBioPdfView;
		Test.setCurrentPageReference(reportPage);
		ApexPages.currentPage().getParameters().put('id', testContact.Id);
		AwardsBioPdfCtrl ctrl = new AwardsBioPdfCtrl();
	    Test.stopTest();

	    System.assertEquals(1, ctrl.glcClwEvents.size());
	    System.assertEquals(1, ctrl.nonChapterEvents.size());
	    System.assertEquals(1, ctrl.nonChapterComplexEvents.size());
	    System.assertEquals(1, ctrl.fastTrackEvents.size());
	    System.assertEquals(1, ctrl.gccEvents.size());
	    System.assertEquals(1, ctrl.regBoardMeetingEvents.size());
	}
	
	private static testMethod void testAchievements() {
		setupMember();
		setupAchievements();
	    
		Test.startTest();
	    PageReference reportPage = Page.AwardsBioPdfView;
		Test.setCurrentPageReference(reportPage);
		ApexPages.currentPage().getParameters().put('id', testContact.Id);
		AwardsBioPdfCtrl ctrl = new AwardsBioPdfCtrl();
		Test.stopTest();
	    
	    System.assertEquals(1, ctrl.awards.size());
	}

}