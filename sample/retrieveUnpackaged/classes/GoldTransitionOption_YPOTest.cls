@isTest
private class GoldTransitionOption_YPOTest {
    
    static Contact testContact;
    static User testUser;
    static Opportunity testOpp;
    
    private static void setupContactForPage()
    {
		Account ChapterAccount = TestServices.createChapterAccount('Test Chapter',Null);
        testContact = TestServices.createContact(ChapterAccount.id,true);
        testOpp = TestServices.createOpp('Cycle Open',ChapterAccount.id,testContact.Id,true);
        
        User runningUser = [SELECT Id FROM User Where Profile.Name = 'System Administrator' and isActive=true LIMIT 1];
        System.runAs(runningUser)
        {
            testUser = (User) SObjectFactory.create(User.SObjectType);
        }
    }

    /*
    SaveOpportunitny is no longer doing a dml operation
    static testMethod void Test_saveOpportunity() 
    {
        String REGION_VALUE = 'Europe';
        setupContactForPage();
        
        Test.setCurrentPageReference(new PageReference('/apex/Gold_Transition_Option_YPO'));
        ApexPages.currentPage().getParameters().put('id', testContact.Id);
        
        ApexPages.standardController controller = new ApexPages.standardController(testContact); 
        GoldTransitionOption_YPO page = new GoldTransitionOption_YPO(controller);
        
        Test.startTest();
            page.oOpp = testOpp;
            page.oOpp.Region__c = REGION_VALUE;
            page.saveOpportunity();
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT Id, Region__c FROM Opportunity WHERE Id =: page.oOpp.Id LIMIT 1];
        
        System.assertEquals(REGION_VALUE, updatedOpp.Region__c, 'We expect the Region to be updated on the Opportunity.');
    }*/
    
    static testMethod void Test_saveOpportunity_RedirectCatalogItemPage() 
    {
        setupContactForPage();
        PageReference expectedPage, currentPage;
        
        Test.setCurrentPageReference(new PageReference('/apex/Gold_Transition_Option_YPO'));
        ApexPages.currentPage().getParameters().put('id', testContact.Id);
        
        ApexPages.standardController controller = new ApexPages.standardController(testContact); 
        GoldTransitionOption_YPO contExt = new GoldTransitionOption_YPO(controller);
        
        Test.startTest();
            contExt.oOpp = testOpp;
            contExt.oContact.Lifetime_Dues_Status__c = NULL;
            currentPage = contExt.saveOpportunity();
        Test.stopTest();
        
        expectedPage = Page.Recertification_Screen; 
        
        System.assertEquals(FALSE, ApexPages.hasMessages(), 'We expect the page to not contain any messages.  ' + ApexPages.getMessages());
        System.assert(currentPage.getURL().containsIgnoreCase(expectedPage.getURL()), 'We expect to be on the correct page. Expected: ' + expectedPage.getURL() + ' Actual: ' + currentPage.getURL());
    }
    
    static testMethod void Test_saveOpportunity_RedirectCatalogPage() 
    {
        setupContactForPage();
        PageReference expectedPage, currentPage;
        
        Test.setCurrentPageReference(new PageReference('/apex/Gold_Transition_Option_YPO'));
        ApexPages.currentPage().getParameters().put('id', testContact.Id);
        
        ApexPages.standardController controller = new ApexPages.standardController(testContact); 
        GoldTransitionOption_YPO page = new GoldTransitionOption_YPO(controller);
        
        Test.startTest();
            page.oOpp = testOpp;
            page.oContact.Lifetime_Dues_Status__c = 'In Payment Cycle';
            currentPage = page.saveOpportunity();
        Test.stopTest();
        
        expectedPage = new PageReference('/apex/recertification_Screen');
        expectedPage.getParameters().put('id', testContact.Id);
        
        System.assertEquals(FALSE, ApexPages.hasMessages(), 'We expect the page to not contain any messages.  ' + ApexPages.getMessages());
        System.assert(expectedPage.getURL().equalsIgnoreCase(currentPage.getURL()), 'We expect to be on the correct page. Expected: ' + expectedPage.getURL() + ' Actual: ' + currentPage.getURL());
    }

    static testMethod void Test_goBack_ValidTransitionStatus() 
    {
        setupContactForPage();
        PageReference expectedPage, currentPage;
        
        Test.setCurrentPageReference(new PageReference('/apex/Gold_Transition_Option_YPO'));
        ApexPages.currentPage().getParameters().put('id', testContact.Id);
        
        ApexPages.standardController controller = new ApexPages.standardController(testContact); 
        GoldTransitionOption_YPO contExt = new GoldTransitionOption_YPO(controller);
        
        Test.startTest();
            contExt.init();
            contExt.oContact.Transition_Status__c = GoldTransitionOption_YPO.TRANSITION_STATUS_OVERDUE;
            currentPage = contExt.goBack();
        Test.stopTest();
        
        expectedPage = Page.UpdateProfileInfo_YPO;
        
        System.assertEquals(FALSE, ApexPages.hasMessages(), 'We expect the page to not contain any messages.  ' + ApexPages.getMessages());
        System.assert(currentPage.getURL().contains(expectedPage.getURL()), 'We expect to be on the correct page. Expected: ' + expectedPage.getURL() + ' Actual: ' + currentPage.getURL());
    }
    
    static testMethod void Test_goBack_ValidTransitionFlagTrueStatus() 
    {
        setupContactForPage();
        PageReference expectedPage, currentPage;
        
        Test.setCurrentPageReference(new PageReference('/apex/Gold_Transition_Option_YPO'));
        ApexPages.currentPage().getParameters().put('id', testContact.Id);
        testOpp.Transition_Flag__c = true;
        update testOpp;
        ApexPages.standardController controller = new ApexPages.standardController(testContact); 
        GoldTransitionOption_YPO contExt = new GoldTransitionOption_YPO(controller);
        
        Test.startTest();
            contExt.init();
            contExt.oContact.Transition_Status__c = GoldTransitionOption_YPO.TRANSITION_STATUS_OVERDUE;
            //currentPage = contExt.goBack();
        Test.stopTest();
        
        expectedPage = Page.UpdateProfileInfo_YPO;
        
        System.assertEquals(FALSE, ApexPages.hasMessages(), 'We expect the page to not contain any messages.  ' + ApexPages.getMessages());
        //System.assert(currentPage.getURL().contains(expectedPage.getURL()), 'We expect to be on the correct page. Expected: ' + expectedPage.getURL() + ' Actual: ' + currentPage.getURL());
    }

    static testMethod void Test_goBack_InvalidTransitionStatus() 
    {
        setupContactForPage();
        PageReference expectedPage, currentPage;
        
        Test.setCurrentPageReference(new PageReference('/apex/Gold_Transition_Option_YPO'));
        ApexPages.currentPage().getParameters().put('id', testContact.Id);
        
        ApexPages.standardController controller = new ApexPages.standardController(testContact); 
        GoldTransitionOption_YPO page = new GoldTransitionOption_YPO(controller);
        
        Test.startTest();
            page.init();
            page.oContact.Transition_Status__c = NULL;
            currentPage = page.goBack();
        Test.stopTest();
        
        expectedPage = new PageReference('/apex/recertification_screen');
        
        System.assertEquals(FALSE, ApexPages.hasMessages(), 'We expect the page to not contain any messages.  ' + ApexPages.getMessages());
        System.assert(currentPage.getURL().contains(expectedPage.getURL()), 'We expect to be on the correct page. Expected: ' + expectedPage.getURL() + ' Actual: ' + currentPage.getURL());
    }
    
    static testmethod void testProperties() {
    	setupContactForPage();
    	
    	User runningUser = [SELECT Id FROM User Where Profile.Name = 'System Administrator' and isActive=true LIMIT 1];
		Id standardProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
		Id communityProfileId = [SELECT Id FROM Profile WHERE Name = 'Partner Community User'].Id;
		Id  userRoleId = [SELECT Id FROM UserRole WHERE PortalType = 'Partner' LIMIT 1].Id;
		User standardUser;
		Contact oContact;
		User oUser;
		
		UserRole standardRole = new UserRole(name = 'TEST ROLE');
		System.runAs(runningUser) {
			insert standardRole;
			standardUser = (User) SObjectFactory.build(User.SObjectType);
			standardUser.ProfileId = standardProfileId;
			standardUser.UserRoleId = standardRole.Id;
			insert standardUser;
		}
		
        Id recordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Chapter', 'Account').Id;
        Account mockRegion = TestServices.createAccount('Test Region Chapter');
        mockRegion.Type = 'Region';
        mockRegion.RecordTypeId = recordTypeId;
        mockRegion.Start_Date__c = system.today();
        insert mockRegion;
        
        Account oAccount2 = TestServices.createAccount('Test-Account');
        oAccount2.ParentId = mockRegion.Id;
        oAccount2.RecordTypeId = recordTypeId;
        oAccount2.Type = 'Chapter';
        oAccount2.Start_Date__c = system.today();
        oAccount2.Name = 'Needs Chapter';
        insert oAccount2;
        
        Account_Affiliation__c oAccountAffiliation = TestServices.createAccountAffiliation(oAccount2.id, testContact.id);
        oAccountAffiliation.IsActive__c = true;
        insert oAccountAffiliation;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 stdPB = new Pricebook2(Id = pricebookId, IsActive = true);
        update stdPB;

        Product2 primProd = new Product2();
        primProd.Product_Type__c = 'Primary';
        primProd.Account__c = oAccount2.Id;
        primProd.IsActive = true;
        primProd.Family = 'Chapter Dues';
        primProd.Name = 'Chapter Dues Product';
        primProd.Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
        insert primProd;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.UnitPrice = 100;
        pbe.Product2Id = primProd.Id;
        pbe.Pricebook2Id = pricebookId;
        pbe.isActive = true;
        insert pbe;
        
        
        ApexPages.standardController controller1 = new ApexPages.standardController(testContact); 
        GoldTransitionOption_YPO contExt1 = new GoldTransitionOption_YPO(controller1);
        contExt1.init();
        
    	Test.setCurrentPageReference(new PageReference('/apex/Gold_Transition_Option_YPO'));
        ApexPages.currentPage().getParameters().put('id', testContact.Id);
        
        
        ApexPages.standardController controller = new ApexPages.standardController(testContact); 
        GoldTransitionOption_YPO contExt = new GoldTransitionOption_YPO(controller);
        
    	Boolean transFlag;
    	List<SelectOption> desiredReigons;
    	List<OpportunityLineItem> olis;
    	PageReference save;
    	PageReference testRef;
    	
    	Test.startTest();
    		transFlag = contExt.transitionFlag;
    		contExt.oOpp = testOpp;
        	//contExt.oContact = oContact;
    		contExt.filterRegionChapters();
        	contExt.filterRegionChapters();
    		desiredReigons = contExt.desiredWPORegions;
    		olis = contExt.createNewOLIs(oAccount2.Id, testOpp.Id);
    		save = contExt.saveDesiredWPOChapter();
    		testRef = contExt.toLifeTimeOption();
    		testRef = contExt.WPOTransition();
    		//testRef = contExt.goBack();
    	Test.stopTest();
    }
}