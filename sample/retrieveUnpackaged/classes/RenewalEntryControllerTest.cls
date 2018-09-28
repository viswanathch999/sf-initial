@isTest
private class RenewalEntryControllerTest {

    static Contact testContact; 
    static User testUser;
    static User standardUser;
    static Opportunity testOpp;

    private static void setupContactForPage()
    {
        User runningUser = [SELECT Id FROM User Where Profile.Name = 'System Administrator' and isActive=true LIMIT 1];
		Id standardProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
		Id communityProfileId = [SELECT Id FROM Profile WHERE Name = 'Partner Community User'].Id;
		Id  userRoleId = [SELECT Id FROM UserRole WHERE PortalType = 'Partner' LIMIT 1].Id;
		insert new Profile_Completion_Criteria__c(Name = 'Initial Criteria', Biography__c = 1);

		UserRole standardRole = new UserRole(name = 'TEST ROLE');
		System.runAs(runningUser) {
			insert standardRole;
			standardUser = (User) SObjectFactory.build(User.SObjectType);
			standardUser.ProfileId = standardProfileId;
			standardUser.UserRoleId = standardRole.Id;
			insert standardUser;
		}
		
		Account testAccount = (Account) SObjectFactory.build(Account.SObjectType);
        testAccount.Type ='Chapter';
        testAccount.OwnerId = standardUser.Id;
        insert testAccount;
        
		testContact = (Contact) SObjectFactory.build(Contact.SObjectType);
		testContact.AccountId = testAccount.Id;
		insert testContact;
		
		testUser = (User) SObjectFactory.build(User.SObjectType,User.ContactId,testContact.Id);
		testUser.ProfileId = communityProfileId;
		System.debug('###testUser: ' + testUser);
		insert testUser;
        
        /*** TO DO ***/
        /*Change this back to: startOfNextFiscal */
		testOpp = (Opportunity) SObjectFactory.build(Opportunity.SObjectType);
		testOpp.Fiscal_Date_Start__c = Date.newInstance(Date.today().year(),7,1); //FiscalDateUtility.startOfNextFiscal;
		testOpp.Opportunity_Type__c = 'Renewal';
		testOpp.KGRenewal__IsActiveCart__c = true;
		testOpp.StageName = RenewalEntryController.STAGE_CYCLE_OPEN;
		testOpp.KGRenewal__Contact__c = testContact.id;
		// Set default Status's
		testOpp.Profile_Page_Status_Exchange__c = RenewalEntryController.PROFILE_STATUS_NOT_STARTED;
		testOpp.Grace_Status__c = 'No Grace Needed';
		testOpp.Certification_Type__c = RenewalEntryController.CERTIFICATION_TYPE_THIRD_PARTY;
		insert testOpp;

		KGRenewal__Invoice__c Invoice = new KGRenewal__Invoice__c();
		Invoice.KGRenewal__Opportunity__c = testOpp.Id;
		Invoice.KGRenewal__Account__c = testAccount.Id;
		insert Invoice;

		Profile_Completion_Criteria__c Criteria = new Profile_Completion_Criteria__c(Name='Initial Criteria',Biography__c = 1);
		insert Criteria;
    }
    
    static testMethod void Test_toNextPage_Welcome()
    {
        PageReference result;
        setupContactForPage();
        String expectedPageRef = Page.WelcomePage.getURL() + '?id=' + testContact.id;
        
        System.runAs(testUser) {
        	Test.startTest();
	            ApexPages.standardController controller = new ApexPages.standardController(testContact); 
	            RenewalEntryController pgCont = new RenewalEntryController(controller);
	            
	            result = pgCont.toNextPage();
	        Test.stopTest();
	        
	        System.assertEquals(expectedPageRef, result.getURL(), 'We expect the Page Reference to be correct.');
        }
    }

    static testMethod void Test_toNextPage_ProfileComplete_Transition()
    {
        PageReference result;
        setupContactForPage();

        String  expectedPgRefURL = page.catalog_ypo.geturl() + '?Modal=Transition';
        
        testOpp.Profile_Page_Status_Exchange__c = RenewalEntryController.PROFILE_STATUS_COMPLETE;
		testOpp.Certification_Page_Status_Exchange__c = RenewalEntryController.CERTIFICATION_PAGE_STATUS_INPROGRESS;
		testOpp.Dues_Page_Status_Exchange__c = RenewalEntryController.DUES_STATUS_NOT_STARTED;
		testOpp.Grace_Status__c = 'No Grace Needed';
		testOpp.Transition_flag__c = true; // this is sending it to the Catalog page according to the Nav logic.
		update testOpp;

        System.runAs(testUser) {

	        Test.startTest();
	            ApexPages.standardController controller = new ApexPages.standardController(testContact); 
	            RenewalEntryController pgCont = new RenewalEntryController(controller);
	            
	            pgCont.relatedOpp = testOpp;
	            
	            result = pgCont.toNextPage();
	        Test.stopTest();
	        
	        System.assertEquals(expectedPgRefURL, result.getURL(), 'We expect the Page Reference to match.');
		}

    }
    
    static testMethod void Test_toNextPage_ProfileComplete_Transition_Payment()
    {
        PageReference result;
        setupContactForPage();

        String  expectedPgRefURL = page.catalog_YPO.geturl() + '?Modal=Transition';
        
        testOpp.Profile_Page_Status_Exchange__c = RenewalEntryController.PROFILE_STATUS_COMPLETE;
		testOpp.Certification_Page_Status_Exchange__c = RenewalEntryController.CERTIFICATION_PAGE_STATUS_INPROGRESS;
		testOpp.Dues_Page_Status_Exchange__c = RenewalEntryController.DUES_STATUS_IN_PROGRESS;
		testOpp.Grace_Status__c = 'No Grace Needed';
		testOpp.Transition_flag__c = true; // this is sending it to the Catalog page according to the Nav logic.
		update testOpp;

        System.runAs(testUser) {

	        Test.startTest();
	            ApexPages.standardController controller = new ApexPages.standardController(testContact); 
	            RenewalEntryController pgCont = new RenewalEntryController(controller);
	            
	            pgCont.relatedOpp = testOpp;
	            
	            result = pgCont.toNextPage();
	        Test.stopTest();
	        
	        System.assertEquals(expectedPgRefURL, result.getURL(), 'We expect the Page Reference to match.');
		}

    }
    
    static testMethod void Test_toNextPage_ProfileComplete_Grace()
    {
        PageReference result;
        setupContactForPage();

        String  expectedPgRefURL = page.catalog_ypo.geturl() + '?Modal=Grace';
        
        testOpp.Profile_Page_Status_Exchange__c = RenewalEntryController.PROFILE_STATUS_COMPLETE;
		testOpp.Certification_Page_Status_Exchange__c = RenewalEntryController.CERTIFICATION_PAGE_STATUS_INPROGRESS;
		testOpp.Dues_Page_Status_Exchange__c = RenewalEntryController.DUES_STATUS_NOT_STARTED;
		testOpp.Grace_Status__c = 'Requested'; // this is sending it to the Catalog page according to the Nav logic.
		testOpp.Transition_flag__c = false; 
		update testOpp;

        System.runAs(testUser) {

	        Test.startTest();
	            ApexPages.standardController controller = new ApexPages.standardController(testContact); 
	            RenewalEntryController pgCont = new RenewalEntryController(controller);
	            
	            pgCont.relatedOpp = testOpp;
	            
	            result = pgCont.toNextPage();
	        Test.stopTest();
	        
	        System.assertEquals(expectedPgRefURL, result.getURL(), 'We expect the Page Reference to match.');
		}

    }
    
    static testMethod void Test_toNextPage_ProfileComplete_Grace_Payment()
    {
        PageReference result;
        setupContactForPage();

        String  expectedPgRefURL = page.catalog_ypo.geturl() + '?Modal=Grace';
        
        testOpp.Profile_Page_Status_Exchange__c = RenewalEntryController.PROFILE_STATUS_COMPLETE;
		testOpp.Certification_Page_Status_Exchange__c = RenewalEntryController.CERTIFICATION_PAGE_STATUS_INPROGRESS;
		testOpp.Dues_Page_Status_Exchange__c = RenewalEntryController.DUES_STATUS_IN_PROGRESS;
		testOpp.Grace_Status__c = 'Requested'; // this is sending it to the Catalog page according to the Nav logic.
		testOpp.Transition_flag__c = false; 
		update testOpp;

        System.runAs(testUser) {

	        Test.startTest();
	            ApexPages.standardController controller = new ApexPages.standardController(testContact); 
	            RenewalEntryController pgCont = new RenewalEntryController(controller);
	            
	            pgCont.relatedOpp = testOpp;
	            
	            result = pgCont.toNextPage();
	        Test.stopTest();
	        
	        System.assertEquals(expectedPgRefURL, result.getURL(), 'We expect the Page Reference to match.');
		}

    }
    
    static testMethod void Test_toNextPage_ProfileComplete_Grace_Payment_Paid()
    {
        PageReference result;
        setupContactForPage();

        String  expectedPgRefURL = page.splashscreen_thankyou.geturl() + '?id=' + testContact.id +'&Modal=Grace';
        
        testOpp.Profile_Page_Status_Exchange__c = RenewalEntryController.PROFILE_STATUS_COMPLETE;
		testOpp.Certification_Page_Status_Exchange__c = RenewalEntryController.CERTIFICATION_PAGE_STATUS_INPROGRESS;
		testOpp.Dues_Page_Status_Exchange__c = RenewalEntryController.DUES_STATUS_COMPLETE;
		testOpp.Grace_Status__c = 'Requested'; // this is sending it to the Catalog page according to the Nav logic.
		testOpp.Transition_flag__c = false; 
		update testOpp;

        System.runAs(testUser) {

	        Test.startTest();
	            ApexPages.standardController controller = new ApexPages.standardController(testContact); 
	            RenewalEntryController pgCont = new RenewalEntryController(controller);
	            
	            pgCont.relatedOpp = testOpp;
	            
	            result = pgCont.toNextPage();
	        Test.stopTest();
	        
	        System.assertEquals(expectedPgRefURL, result.getURL(), 'We expect the Page Reference to match.');
		}

    }
    
    static testMethod void Test_toNextPage_Recertification_Inprogress()
    {
        PageReference result;
        setupContactForPage();

        String  expectedPgRefURL = Page.Recertification_Screen.getURL() + '?id=' + testContact.id;
        
        testOpp.Profile_Page_Status_Exchange__c = RenewalEntryController.PROFILE_STATUS_COMPLETE;
		testOpp.Certification_Page_Status_Exchange__c = RenewalEntryController.CERTIFICATION_PAGE_STATUS_INPROGRESS;
		testOpp.Dues_Page_Status_Exchange__c = RenewalEntryController.DUES_STATUS_NOT_STARTED;
		testOpp.Grace_Status__c = 'No Grace Needed';
		testOpp.Transition_flag__c = false; 
		testOpp.Certification_Type__c = RenewalEntryController.CERTIFICATION_TYPE_SELF;
		update testOpp;

        System.runAs(testUser) {

	        Test.startTest();
	            ApexPages.standardController controller = new ApexPages.standardController(testContact); 
	            RenewalEntryController pgCont = new RenewalEntryController(controller);
	            
	            pgCont.relatedOpp = testOpp;
	            
	            result = pgCont.toNextPage();
	        Test.stopTest();
	        
	        System.assertEquals(expectedPgRefURL, result.getURL(), 'We expect the Page Reference to match.');
		}

    }
    
    static testMethod void Test_toNextPage_Recertification_Complete()
    {
        PageReference result;
        setupContactForPage();

        String  expectedPgRefURL = page.catalog_ypo.geturl();
        
        testOpp.Profile_Page_Status_Exchange__c = RenewalEntryController.PROFILE_STATUS_COMPLETE;
		testOpp.Certification_Page_Status_Exchange__c = RenewalEntryController.CERTIFICATION_PAGE_STATUS_COMPLETE; // this is sending it to the Catalog page according to the Nav logic.
		testOpp.Certification_Status__c = RenewalEntryController.CERTIFICATION_STATUS_COMPLETE;
		testOpp.Dues_Page_Status_Exchange__c = RenewalEntryController.DUES_STATUS_NOT_STARTED;
		testOpp.Grace_Status__c = 'No Grace Needed'; 
		testOpp.Transition_flag__c = false; 
		update testOpp;

        System.runAs(testUser) {

	        Test.startTest();
	            ApexPages.standardController controller = new ApexPages.standardController(testContact); 
	            RenewalEntryController pgCont = new RenewalEntryController(controller);
	            
	            pgCont.relatedOpp = testOpp;
	            
	            result = pgCont.toNextPage();
	        Test.stopTest();
	        
	        System.assertEquals(expectedPgRefURL, result.getURL(), 'We expect the Page Reference to match.');
		}

    }
    
    static testMethod void Test_toNextPage_Recertification_Complete_Payment_Complete()
    {
        PageReference result;
        setupContactForPage();

        testOpp.Profile_Page_Status_Exchange__c = RenewalEntryController.PROFILE_STATUS_COMPLETE;
		testOpp.Certification_Page_Status_Exchange__c = RenewalEntryController.CERTIFICATION_PAGE_STATUS_COMPLETE; // this is sending it to the Catalog page according to the Nav logic.
		testOpp.Certification_Status__c = RenewalEntryController.CERTIFICATION_STATUS_COMPLETE;
		testOpp.Dues_Page_Status_Exchange__c = RenewalEntryController.DUES_STATUS_COMPLETE;
		testOpp.StageName = RenewalEntryController.STAGENAME_RECEIVED;
		testOpp.KGRenewal__IsActiveCart__c = false;
		update testOpp;

	    id invoiceId = [Select Id From KGRenewal__Invoice__c Where KGRenewal__Opportunity__c =:testOpp.Id Limit 1][0].ID;
		String  expectedPgRefURL = page.v_Invoice.geturl() + '?id=' + invoiceId;

        System.runAs(testUser) {

	        Test.startTest();
	            ApexPages.standardController controller = new ApexPages.standardController(testContact); 
	            RenewalEntryController pgCont = new RenewalEntryController(controller);
	            
	            pgCont.relatedOpp = testOpp;
	            
	            result = pgCont.toNextPage();
	        Test.stopTest();
	        
	        System.assertEquals(expectedPgRefURL, result.getURL(), 'We expect the Page Reference to match.');
		}

    }
    
    static testMethod void Test_toNextPage_Transitionpage()
    {
        PageReference result;
        setupContactForPage();

        String  expectedPgRefURL = Page.Gold_Transition_Option_YPO.geturl() + '?id=' + testContact.id;
        
		testContact.Transition_Status__c = RenewalEntryController.TRANSITION_SCHEDULED; // this is sending it to the new page according to the Nav logic.
		update testContact;

        testOpp.Profile_Page_Status_Exchange__c = RenewalEntryController.PROFILE_STATUS_COMPLETE;
		testOpp.Certification_Page_Status_Exchange__c = RenewalEntryController.CERTIFICATION_PAGE_STATUS_INPROGRESS;
		testOpp.Dues_Page_Status_Exchange__c = RenewalEntryController.DUES_STATUS_NOT_STARTED;
		testOpp.Grace_Status__c = 'No Grace Needed';
		testOpp.Transition_flag__c = false; 
		update testOpp;

        System.runAs(testUser) {

	        Test.startTest();
	            ApexPages.standardController controller = new ApexPages.standardController(testContact); 
	            RenewalEntryController pgCont = new RenewalEntryController(controller);
	            
	            pgCont.relatedOpp = testOpp;
	            
	            result = pgCont.toNextPage();
	        Test.stopTest();
	        
	        System.assertEquals(expectedPgRefURL, result.getURL(), 'We expect the Page Reference to match.');
		}

    }
    
    static testMethod void Test_toNextPage_Recertification_Complete_Payment_Inprocess()
    {
        PageReference result;
        setupContactForPage();

        testOpp.Profile_Page_Status_Exchange__c = RenewalEntryController.PROFILE_STATUS_COMPLETE;
		testOpp.Certification_Page_Status_Exchange__c = RenewalEntryController.CERTIFICATION_PAGE_STATUS_COMPLETE; // this is sending it to the Catalog page according to the Nav logic.
		testOpp.Certification_Status__c = RenewalEntryController.CERTIFICATION_STATUS_COMPLETE;
		testOpp.Dues_Page_Status_Exchange__c = RenewalEntryController.DUES_STATUS_IN_PROGRESS;
		testOpp.StageName = RenewalEntryController.STAGENAME_PENDING;
		testOpp.KGRenewal__IsActiveCart__c = false;
		update testOpp;

	    id invoiceId = [Select Id From KGRenewal__Invoice__c Where KGRenewal__Opportunity__c =:testOpp.Id Limit 1][0].ID;
		String  expectedPgRefURL = page.v_Invoice.geturl() + '?id=' + invoiceId;

        System.runAs(testUser) {

	        Test.startTest();
	            ApexPages.standardController controller = new ApexPages.standardController(testContact); 
	            RenewalEntryController pgCont = new RenewalEntryController(controller);
	            
	            pgCont.relatedOpp = testOpp;
	            
	            result = pgCont.toNextPage();
	        Test.stopTest();
	        
	        System.assertEquals(expectedPgRefURL, result.getURL(), 'We expect the Page Reference to match.');
		}

    }
    
    static testMethod void Test_DuesStatusCheck() 
    {
        PageReference result;
        setupContactForPage();

        Account testAccount = (Account) SObjectFactory.build(Account.SObjectType);
        testAccount.Type ='Chapter';
        insert testAccount;

        testOpp.Payment_Status__c = RenewalEntryController.PAYMENT_STATUS_PAID;
        testOpp.StageName = RenewalEntryController.STAGE_CLOSED_WON;
        testOpp.Dues_Page_Status_Exchange__c = RenewalEntryController.DUES_STATUS_NOT_STARTED;
        update testOpp;
        
        System.runAs(testUser){
	        
	    Test.startTest();
		    ApexPages.standardController controller = new ApexPages.standardController(testContact); 
		    RenewalEntryController page = new RenewalEntryController(controller);

	        result = page.toNextPage();
	    Test.stopTest();
	        
	    System.assertEquals(page.relatedOpp.Dues_Page_Status_Exchange__c, RenewalEntryController.DUES_STATUS_COMPLETE, 'We expect the Opportunities Dues Status to be of the correct value.');
        }
    }
    
}