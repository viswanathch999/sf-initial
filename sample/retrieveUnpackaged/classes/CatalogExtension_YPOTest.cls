@isTest(seeAllData = true)
private class CatalogExtension_YPOTest {
    static Contact testContact; 
    static User testUser;
    static User standardUser;
    static Opportunity testOpty;
    
    public static void setup(){
        User runningUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true AND Email = 'lphillips@ypo.org' LIMIT 1];
		Id standardProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
		Id communityProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community User'].Id;
		Id userRoleId = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1].Id;
		
		v_TestUtil.createSiteConfig();
		/*
        KGRenewal__VenueSettings__c settings = KGRenewal__VenueSettings__c.getOrgDefaults();
        settings.KGRenewal__OpportunityStageOnInsertion__c = 'TEST STAGE';
        upsert settings;
		*/

		UserRole standardRole = new UserRole(Name = 'TEST ROLE');
		System.runAs(runningUser) {
			insert standardRole;
			standardUser = (User) SObjectFactory.build(User.SObjectType);
			standardUser.ProfileId = standardProfileId;
			standardUser.UserRoleId = standardRole.Id;
			insert standardUser;
		
			Account testAccount = (Account) SObjectFactory.build(Account.SObjectType);
			testAccount.Type ='Chapter';
			testAccount.OwnerId = standardUser.Id;
			insert testAccount;
		
			testContact = (Contact) SObjectFactory.build(Contact.SObjectType);
			testContact.AccountId = testAccount.Id;
			testContact.RecordType = RecordTypeServices.getRecordTypeByDeveloperName('Member', 'Contact');
			insert testContact;
		
			testUser = (User) SObjectFactory.build(User.SObjectType,User.ContactId,testContact.Id);
			testUser.ProfileId = communityProfileId;
			System.debug('###testUser: ' + testUser);
			insert testUser;
		
			testOpty = TestServices.createOpp('Cycle Open', testAccount.Id, testContact.Id, true);
			TestServices.Build_OpportunityLineItem(testOpty.Id);
		}
    }


    static testmethod void testControllerExt() {
        setup();
		testContact.Transition_Status__c = 'Transitioned';
		//testContact.recalculateFormulas();
		update testContact;

		System.runAs(testUser) {
			PageReference pageRef = Page.Catalog_YPO;
			Test.setCurrentPage(pageRef);
			KGRenewal.VenueCatalogController v = new KGRenewal.VenueCatalogController();
			CatalogExtension_YPO controller = new CatalogExtension_YPO(v);
			controller.theOpp = testOpty;
			controller.oContact = testContact;
			Boolean TestTruth;
			TestTruth = controller.isYPOGold;
			TestTruth = controller.isTransitioning;
			TestTruth = controller.isGraceNeeded;
			TestTruth = controller.cameFromLifetimePage;
			TestTruth = controller.displayTransitionModal;
			TestTruth = controller.displayGraceModal;

			String nextPage;
			if(controller <> null && controller.setProspectOppAsCart() <> null ) {
				Integer i = controller.totalItemCount;
				nextPage = controller.setProspectOppAsCart().getUrl();
			}
			// Verify that page fails without parameters
			//System.assertEquals('/apex/failure?error=noParam', nextPage);
			String deleteItem;
			if(controller.venueCartCtrl <> null && controller.venueCartCtrl.lineItems <> null && controller.venueCartCtrl.lineItems.size() > 0){
				deleteItem = controller.venueCartCtrl.lineItems[0].recordId;
			}
			// Add parameters to page URL
			if(deleteItem <> null)
				ApexPages.currentPage().getParameters().put('q', deleteItem);
        
			controller.SaveAndContinue();

			// Instantiate a new controller with all parameters in the page
			controller = new CatalogExtension_YPO(v); 
			controller.CatalogModel_CartContrl();
			controller.updateQuantity();
			//controller.setLastName('lastname');
			//controller.setFirstName('firstname');
			//controller.setCompany('acme');
			//controller.setEmail('firstlast@acme.com');
			String CloseCatalogPage = controller.closeCatalgogItem().getUrl();
			//String RemoveCatalogPage = controller.removeCatalgogItem().getUrl();
        
			// Verify that the Modal closes
			//System.assertEquals('/apex/Catalog_YPO', CloseCatalogPage);
        
			// Verify that the Modal returns to CataLog Page after it  removes Item
			//System.assertEquals('/apex/Catalog_YPO', RemoveCatalogPage);
        }
    }
    
    
    static testmethod void testCart() {
	    setup();

		System.runAs(testuser) {
            KGRenewal.VenueCatalogController venueCtrl = new KGRenewal.VenueCatalogController();
            CatalogExtension_YPO ext = new CatalogExtension_YPO(venueCtrl);

            // Cover properties and get methods
            Boolean hasTerm = ext.hasTerm;
            String zipCode = ext.zipCode;
            String zipCodeError = ext.zipCodeError;
            Integer totalItemCount = ext.totalItemCount;

            // Cover action methods
            Test.setCurrentPageReference(Page.Catalog_YPO);
            System.currentPageReference().getParameters().put('search', 'test-test');

            ApexPages.currentPage().getParameters().put('q', ext.venueCartCtrl.lineItems[0].record.Id);
            ext.updateQuantity();
			ext.doSearch2();
        	ext.doSearch3();
		}
    }


    static testmethod void backTest_LifeTime() {
        setup();

		testContact.Lifetime_Dues_Status__c = 'Eligible for Lifetime';
		update testContact;

		System.runAs(testuser) {
			KGRenewal.VenueCatalogController venueCtrl = new KGRenewal.VenueCatalogController();
			CatalogExtension_YPO ext = new CatalogExtension_YPO(venueCtrl);
			ext.theOpp = testOpty;
			ext.oContact = testContact;
			System.debug(ext);

			//// debug
			//Opportunity checkOpp = [SELECT Id, Name FROM Opportunity WHERE Id = :testOpty.Id LIMIT 1];
			//System.debug('checkOpp: ' + checkOpp);
			//System.debug('ext.theOpp: ' + ext.theOpp);

			// page
			PageReference expectedPage =  Page.LifetimeOption_ypo;
			System.debug('expectedPage: ' + expectedPage);

			// test
			Test.setCurrentPageReference(Page.Catalog_YPO);
			System.currentPageReference().getParameters().put('lifetime', 'true');
			PageReference currentPage = ext.back();
			System.debug('currentPage: ' + currentPage);

			System.assert(currentPage.getUrl().contains(expectedPage.getUrl()),'We expect to be redirect to the correct page. Expected: '+expectedPage.getUrl()+' Actual: ' + currentPage.getUrl());
		}
    }


    static testmethod void backTest_ThirdParyCertify() {
    	setup();

		testOpty.Certification_Type__c = 'Third Party Certify';
		update testOpty;

		System.runAs(testuser) {
			KGRenewal.VenueCatalogController venueCtrl = new KGRenewal.VenueCatalogController();
			CatalogExtension_YPO ext = new CatalogExtension_YPO(venueCtrl);
			ext.theOpp = testOpty;
			ext.oContact = testContact;

			PageReference expectedPage =  Page.ThirdPartyCertification_Screens_ypo;

			Test.setCurrentPageReference(Page.Catalog_YPO);

			Test.startTest();
				PageReference currentPage = ext.back();
			Test.stopTest();

			System.assert(currentPage.getUrl().contains(expectedPage.getUrl()),'We expect to be redirect to the correct page. Expected: '+expectedPage.getUrl()+' Actual: ' + currentPage.getUrl());
		}
    }
    
    static testmethod void propertiesTest() {
    	setup();

		System.runAs(testuser) {
			KGRenewal.VenueCatalogController venueCtrl = new KGRenewal.VenueCatalogController();
			CatalogExtension_YPO ext = new CatalogExtension_YPO(venueCtrl);
			ext.theOpp = testOpty;
			ext.oContact = testContact;
			Boolean hasGrace;
			Boolean liftimeDuesStatusFlag;
        
			Test.startTest();
        		hasGrace = ext.hasGrace;
        		liftimeDuesStatusFlag = ext.lifetimeDuesStatusFlag;
        		ext.closePopup();
			Test.stopTest();
        
			System.assert(!hasGrace, 'We expect the property to be correct.');
			System.assert(!liftimeDuesStatusFlag, 'We expect the property to be correct.');
		}
    }
    
    static testmethod void pageReferencesTest() {
        setup();

        testOpty.Certification_Type__c = 'Third Party Certify';
		testOpty.Transition_Flag__c = true;
		testOpty.KGRenewal__Contact__c = testContact.id;
		update testOpty;
		
		System.runAs(testuser) {
			KGRenewal.VenueCatalogController venueCtrl = new KGRenewal.VenueCatalogController();
			CatalogExtension_YPO ext = new CatalogExtension_YPO(venueCtrl);
			ext.theOpp = testOpty;
			ext.oContact = testContact;
        
			PageReference expectedPage =  Page.Catalog_YPO;

			Test.setCurrentPageReference(Page.Catalog_YPO);
        
			PageReference actualRemove;
			PageReference actualClose;
			PageReference doSearch;
			PageReference testPR;
        
			Test.startTest();
        		actualRemove = ext.removeCatalgogItem();
        		actualClose = ext.closeCatalgogItem();
        		testPR = ext.setProspectOppAsCart();
			Test.stopTest();
        
			System.assert(actualRemove.getUrl().contains(expectedPage.getUrl()),'We expect to be redirect to the correct page. Expected: '+expectedPage.getUrl()+' Actual: ' + actualRemove.getUrl());
			System.assert(actualClose.getUrl().contains(expectedPage.getUrl()),'We expect to be redirect to the correct page. Expected: '+expectedPage.getUrl()+' Actual: ' + actualClose.getUrl());
		}
    }
    
    static testmethod void catalogModelCartContTest() {
    	setup();

		System.runAs(testuser) {
			KGRenewal.VenueCatalogController venueCtrl = new KGRenewal.VenueCatalogController();
			CatalogExtension_YPO ext = new CatalogExtension_YPO(venueCtrl);
			ext.theOpp = testOpty;
			ext.oContact = testContact;
    	
    		Test.startTest();
    			ext.CatalogModel_CartContrl();
    		Test.stopTest();
		}
    }

	@isTest
	static void testNoContact() {
		setup();
		Contact testCont = null;

		System.runAs(testuser) {
            KGRenewal.VenueCatalogController venueCtrl = new KGRenewal.VenueCatalogController();
            CatalogExtension_YPO ext = new CatalogExtension_YPO(venueCtrl);
			ext.oContact = null;
			testCont = ext.oContact;
		}

		System.assert(testCont != null, 'Contact should not be null');
	}

	
}