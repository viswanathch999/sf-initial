@isTest
private class RecertificationExtensionTest {
	static Contact testContact;
	static User testUser;
	static User standardUser;
	static Opportunity testOpp;

	static void setupData()
	{
		User runningUser = [SELECT Id FROM User Where Profile.Name = 'System Administrator' and isActive=true LIMIT 1];
		Id standardProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
		Id communityProfileId = [SELECT Id FROM Profile WHERE Name = 'Partner Community User'].Id;
		Id  userRoleId = [SELECT Id FROM UserRole WHERE PortalType = 'Partner' LIMIT 1].Id;
		
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
		testContact.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member','Contact').Id;
		testContact.Join_Date__c = Date.today().addYears(-1);
		insert testContact;
		
		testUser = (User) SObjectFactory.build(User.SObjectType,User.ContactId,testContact.Id);
		testUser.ProfileId = communityProfileId;
		System.debug('###testUser: ' + testUser);
		insert testUser;
        
		testOpp = (Opportunity) SObjectFactory.build(Opportunity.SObjectType);
		//testOpp.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member','Opportunity').Id;
		testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Member').getRecordTypeId();
		testOpp.KGRenewal__Contact__c = testContact.Id;
		testOpp.Contact_ID__c = testContact.Id;
		testOpp.StageName = 'Cycle Open';
		testOpp.Fiscal_Date_Start__c = Date.newInstance(System.Today().year(), 7, 1); //FiscalDateUtility.startOfNextFiscal();
		testOpp.Opportunity_Type__c = 'Renewal';
		testOpp.KGRenewal__IsActiveCart__c = true;
		testOpp.AccountId = testAccount.Id;
		insert testOpp;

		OpportunityContactRole testOppRole = new OpportunityContactRole();
		testOppRole.ContactId = testContact.id;
		testOppRole.OpportunityId = testOpp.id;
		testOppRole.Role = 'Member';
		testOppRole.IsPrimary = true;
		insert testOppRole;

	}

	static testMethod void saveOnRecertificationTest() {
		setupData();
		testOpp.NumberOfEmployees__c = 10;
		testOpp.Certification_Type__c = RecertificationExtension.CTYPE_NOT_NEEDED;
		testOpp.Certification_Page_Status_Exchange__c = RecertificationExtension.CEXCHANGE_NOTSTARTED;
		testOpp.Certification_Status__c = RecertificationExtension.CSTATUS_INCOMPLETE;
		update testOpp;

		Test.setCurrentPage(Page.Recertification_YPO);
		ApexPages.StandardController standCon = new ApexPages.StandardController(testContact);
		RecertificationExtension conExt = new RecertificationExtension(standCon);
		conExt.init();

		conExt.setupOpportunityForPage();

		String expectedCompany = 'Some Value';
		String expectedTitle = 'Some Title';
		conExt.Opp_QualifyingCompany = expectedCompany;
		conExt.Opp_Title = expectedTitle;

		conExt.saveOnRecertification();

		System.assert(!ApexPages.hasMessages(),'Apexpages are reporting messages: ' + ApexPages.getMessages());

		/*These fields are no longer being copied over*/
		//Opportunity updatedOpp = [SELECT NumberOfEmployees__c,Title__c, Qualifying_Company__c, Updated_Qualifying_Criteria__c FROM Opportunity WHERE Id = :testOpp.Id];
		//System.assertEquals(RecertificationExtension.UPDATED_CRITERIA_BOTH,updatedOpp.Updated_Qualifying_Criteria__c,'We expected the Opp to be Updated with the correct value');
		//System.assertEquals(expectedCompany,updatedOpp.Qualifying_Company__c,'We expected the Opp to be Updated with the correct value');
		//System.assertEquals(expectedTitle,updatedOpp.Title__c,'We expected the Opp to be Updated with the correct value');
		//System.assertEquals(10,updatedOpp.NumberOfEmployees__c,'We expected the this field not to be updated');

		System.assert(conExt.oOpp.Certification_Page_Status_Exchange__c == RecertificationExtension.CEXCHANGE_COMPLETE,'Page Exchange Status is not set to Complete.');
		System.assert(conExt.oOpp.Certification_Status__c == RecertificationExtension.CSTATUS_COMPLETE,'Cert Status is not set to Complete.');
	}
	
	static testMethod void hasOpportunintyBeModifiedTest_True() {
		setupData();

		Test.setCurrentPage(Page.Recertification_YPO);
		ApexPages.StandardController standCon = new ApexPages.StandardController(testContact);
		RecertificationExtension conExt = new RecertificationExtension(standCon);

		conExt.oOpp = testOpp;
		conExt.setupOpportunityForPage();

		conExt.oOpp.Qualifying_Company__c = 'Some Value';

		Test.startTest();
			Boolean actualResults = conExt.hasOpportunintyBeModified();
		Test.stopTest();

		System.assertEquals(true,actualResults,'We expect the Opportunity to be flagged as modified');

	}

	static testMethod void hasOpportunintyBeModifiedTest_False() {
		setupData();

		Test.setCurrentPage(Page.Recertification_YPO);
		ApexPages.StandardController standCon = new ApexPages.StandardController(testContact);
		RecertificationExtension conExt = new RecertificationExtension(standCon);

		conExt.oOpp = testOpp;
		conExt.setupOpportunityForPage();

		Test.startTest();
			Boolean actualResults = conExt.hasOpportunintyBeModified();
		Test.stopTest();

		System.assertEquals(false,actualResults,'We expect the Opportunity to not be flagged as modified');
	}

	static testMethod void updatedQualifyingCriteriaTest_TitleOnly() {
		setupData();

		Test.setCurrentPage(Page.Recertification_YPO);
		ApexPages.StandardController standCon = new ApexPages.StandardController(testContact);
		RecertificationExtension conExt = new RecertificationExtension(standCon);

		conExt.oOpp = testOpp;
		conExt.oOpp.Title_Other__c = 'Old Title';
		conExt.setupOpportunityForPage();

		conExt.oOpp.Title_Other__c = 'Some Title';

		Test.startTest();
			conExt.updatedQualifyingCriteria();
		Test.stopTest();

		Opportunity actualOpp = [SELECT Id, Updated_Qualifying_Criteria__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
		System.assertEquals(RecertificationExtension.UPDATED_CRITERIA_TITLE,
							actualOpp.Updated_Qualifying_Criteria__c,
							'We expect the Opportunitys update criteria to be set to the correct value');	
	}

	static testMethod void updatedQualifyingCriteriaTest_CompanyOnly() {
		setupData();

		Test.setCurrentPage(Page.Recertification_YPO);
		ApexPages.StandardController standCon = new ApexPages.StandardController(testContact);
		RecertificationExtension conExt = new RecertificationExtension(standCon);

		conExt.oOpp = testOpp;
		conExt.oOpp.Qualifying_Company__c = 'Old Company';
		conExt.setupOpportunityForPage();

		conExt.oOpp.Qualifying_Company__c = 'Some Company';

		Test.startTest();
			conExt.updatedQualifyingCriteria();
		Test.stopTest();

		Opportunity actualOpp = [SELECT Id, Updated_Qualifying_Criteria__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
		System.assertEquals(RecertificationExtension.UPDATED_CRITERIA_COMPANY,
							actualOpp.Updated_Qualifying_Criteria__c,
							'We expect the Opportunitys update criteria to be set to the correct value');	
	}

	static testMethod void updatedQualifyingCriteriaTest_Both() {
		setupData();

		Opportunity reqOpp = [SELECT Id, RecordTypeId FROM Opportunity WHERE Id =: testOpp.Id];
		System.debug('###reqOpp: ' + reqOpp);
		
		Test.setCurrentPage(Page.Recertification_YPO);
		ApexPages.StandardController standCon = new ApexPages.StandardController(testContact);
		RecertificationExtension conExt = new RecertificationExtension(standCon);

		conExt.oOpp = testOpp;
		conExt.oOpp.Qualifying_Company__c = 'Old Company';
		conExt.oOpp.Title_Other__c = 'Old Title';
		conExt.setupOpportunityForPage();

		conExt.oOpp.Qualifying_Company__c = 'Some Company';
		conExt.oOpp.Title_Other__c = 'Some Title';

		Test.startTest();
			conExt.updatedQualifyingCriteria();
		Test.stopTest();

		Opportunity actualOpp = [SELECT Id, Updated_Qualifying_Criteria__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
		System.assertEquals(RecertificationExtension.UPDATED_CRITERIA_BOTH,
							actualOpp.Updated_Qualifying_Criteria__c,
							'We expect the Opportunitys update criteria to be set to the correct value');	
	}

	static testMethod void toRecertificationPageTest() {
		setupData();

		Test.setCurrentPage(Page.ContactMemberServices);
		ApexPages.StandardController standCon = new ApexPages.StandardController(testContact);
		RecertificationExtension conExt = new RecertificationExtension(standCon);
		PageReference expectedPage =  Page.Recertification_Screen;

		Test.startTest();
			PageReference currentPage = conExt.toRecertificationPage();
		Test.stopTest();

		System.assert(currentPage.getUrl().contains(expectedPage.getUrl()),'We expect to be redirect to the correct page. Expected: '+expectedPage.getUrl()+' Actual: ' + currentPage.getUrl());	
	}

	static testMethod void goBackTest_YPO() {
		setupData();

		testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
		update testContact;

		Test.setCurrentPage(Page.Recertification_Screen);
		ApexPages.StandardController standCon = new ApexPages.StandardController(testContact);
		RecertificationExtension conExt = new RecertificationExtension(standCon);
		PageReference expectedPage =  Page.Gold_Transition_Option_YPO;
		
		System.runAs(testUser)
		{
			Test.startTest();
				PageReference currentPage = conExt.goBack();
			Test.stopTest();

			System.assert(currentPage.getUrl().contains(expectedPage.getUrl()),'We expect to be redirect to the correct page. Expected: '+expectedPage.getUrl()+' Actual: ' + currentPage.getUrl());	
			
		}
	}

	static testMethod void goBackTest_YPO_Gold() {
		setupData();

		testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
		testContact.Transition_Status__c = 'Transitioned';
		update testContact;
		testContact.recalculateFormulas();

		Test.setCurrentPage(Page.Recertification_Screen);
		ApexPages.StandardController standCon = new ApexPages.StandardController(testContact);
		RecertificationExtension conExt = new RecertificationExtension(standCon);
		PageReference expectedPage =  Page.UpdateProfileInfo_YPO;
		
		System.runAs(testUser)
		{
			Test.startTest();
				PageReference currentPage = conExt.goBack();
			Test.stopTest();

			System.assert(currentPage.getUrl().contains(expectedPage.getUrl()),'We expect to be redirect to the correct page. Expected: '+expectedPage.getUrl()+' Actual: ' + currentPage.getUrl());	
			
		}
	}

	static testMethod void exitActionTest() {
		setupData();

		Test.setCurrentPage(Page.ContactMemberServices);
		ApexPages.StandardController standCon = new ApexPages.StandardController(testContact);
		RecertificationExtension conExt = new RecertificationExtension(standCon);
		PageReference expectedPage =  Page.Splash_ypo;

		Test.startTest();
			PageReference currentPage = conExt.exitAction();
		Test.stopTest();

		System.assert(currentPage.getUrl().contains(expectedPage.getUrl()),'We expect to be redirect to the correct page. Expected: '+expectedPage.getUrl()+' Actual: ' + currentPage.getUrl());	
	}

	static testMethod void toVCatalogTest() {
		setupData();

		Test.setCurrentPage(Page.ContactMemberServices);
		ApexPages.StandardController standCon = new ApexPages.StandardController(testContact);
		RecertificationExtension conExt = new RecertificationExtension(standCon);
		conExt.init();
		PageReference expectedPage =  Page.Catalog_YPO;
		System.assert(!ApexPages.hasMessages(),'Page messages have been generated: ' + ApexPages.getMessages());

		Test.startTest();
			PageReference currentPage = conExt.toVCatalog();
		Test.stopTest();

		System.assert(currentPage.getUrl().contains(expectedPage.getUrl()),'We expect to be redirect to the correct page. Expected: '+expectedPage.getUrl()+' Actual: ' + currentPage.getUrl());	
		System.assert(currentPage.getUrl().contains('lifetime=true'),'We expect the url to have the correct url parameters set. Expected: '+expectedPage.getUrl()+' Actual: ' + currentPage.getUrl());	
	}

	static testMethod void backLifetime_Opportunity() {
		setupData();

		testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
		testContact.Transition_Status__c = 'Transitioned';
		update testContact;
		testContact.recalculateFormulas();

		testOpp.Certification_Type__c = 'Third Party Certify';
		testOpp.Grace_Status__c = 'No Grace Needed';
		update testOpp;

		Test.setCurrentPage(Page.Recertification_Screen);
		ApexPages.StandardController standCon = new ApexPages.StandardController(testContact);
		RecertificationExtension conExt = new RecertificationExtension(standCon);
		conExt.oOpp = testOpp;

		PageReference expectedPage =  Page.ThirdPartyCertification_screens_ypo;
		
		System.runAs(testUser)
		{
			Test.startTest();
				PageReference currentPage = conExt.backLifetime();
			Test.stopTest();

			System.assert(currentPage.getUrl().contains(expectedPage.getUrl()),'We expect to be redirect to the correct page. Expected: '+expectedPage.getUrl()+' Actual: ' + currentPage.getUrl());	
			
		}
	}

	static testMethod void backLifetime_Contact() {
		setupData();

		testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
		testContact.Transition_Status__c = 'Transitioned';
		update testContact;
		testContact.recalculateFormulas();

		testOpp.Transition_Flag__c = true;
		testOpp.Grace_Status__c = 'No Grace Needed';
		update testOpp;

		Test.setCurrentPage(Page.Recertification_Screen);
		ApexPages.StandardController standCon = new ApexPages.StandardController(testContact);
		RecertificationExtension conExt = new RecertificationExtension(standCon);
		conExt.oOpp = testOpp;

		PageReference expectedPage =  Page.Recertification_Screen;
		
		System.runAs(testUser)
		{
			Test.startTest();
				PageReference currentPage = conExt.backLifetime();
			Test.stopTest();

			System.assert(currentPage.getUrl().contains(expectedPage.getUrl()),'We expect to be redirect to the correct page. Expected: '+expectedPage.getUrl()+' Actual: ' + currentPage.getUrl());	
			
		}
	}
	
	static testMethod void toConfirmationTest() {
		setupData();

		testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
		testContact.Transition_Status__c = 'Transitioned';
		update testContact;
		testContact.recalculateFormulas();
		
		Test.setCurrentPage(Page.LifetimeOption_ypo);
		ApexPages.StandardController standCon = new ApexPages.StandardController(testContact);
		RecertificationExtension conExt = new RecertificationExtension(standCon);
		conExt.oOpp = testOpp;
		
		PageReference expectedPage =  Page.LifetimeOption_ypo;
		
		System.runAs(testUser)
		{
			Test.startTest();
				PageReference currentPage = conExt.toConfirmation();
			Test.stopTest();

		}
		
		Contact actualCont = [SELECT Id, Interested_in_Lifetime_Member_Option__c FROM Contact WHERE Id =: testContact.ID LIMIT 1];
		
		System.assert(actualCont != null, 'We expect the contact to be returned properly.');
		System.assertEquals(true, actualCont.Interested_in_Lifetime_Member_Option__c, 'We expect the checkbox to be set correctly.');
			
	}
	
	static testMethod void testInit() {
		setupData();
		
		Account oAccount = new Account();
        oAccount.recordtypeid=  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        oAccount.Industry = 'Technology';
        oAccount.Sub_Category__c ='Warehousing & Storage';
        oAccount.Is_Subsidiary__c = TRUE;
        oAccount.Parent_Company__c='Test parent';
        oAccount.Name = 'Acc';
        insert oAccount;
        
		Contact oContact = new Contact();
        oContact.AccountId = oAccount.Id;
        oContact.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member','Contact').Id;
        oContact = (Contact)JSONUtils.setField(oContact, 'Record_Type_Name__c', 'Member');
        oContact.lastname = 'Test Member Contact';
        oContact.YPO_WPO__c = 'YPO';
        oContact.Transition_Status__c =  'Eligible for early transition';
        //oContact.Grace_Years_Accrued__c = 10;
        oContact.Grace_Accrued_FY17__c = 10;
        oContact.Is_Grace_Used__c = FALSE;
        oContact.Date_Last_Grace_Year_Used__c = Date.newInstance(System.Today().year(), 8, 1);
        oContact.Join_date__c = Date.newInstance(2000, 1, 1);
        oContact.Number_of_Employees__c = 10;
        oContact.Annual_Assets__c = 10;
        oContact.Annual_Fees__c = 10;
        oContact.Annual_Revenue__c = 10;
        
        insert oContact; 
        
		testOpp.NumberOfEmployees__c = 100;
		testOpp.Enterprise_Value__c = 100;
		testOpp.AnnualRevenue__c = 100;
		testOpp.NumberOfEmployees__c = 100;
		testOpp.Organization_Type__c = 'Agency-Type';
		testOpp.KGRenewal__Contact__c = oContact.Id;
		update testOpp;
		
		testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
		testContact.Transition_Status__c = 'Transitioned';
		update testContact;
		testContact.recalculateFormulas();
		
		OpportunityContactRole oppConRole = new OpportunityContactRole(Contactid=oContact.id,OpportunityId=testOpp.id,IsPrimary=TRUE);
        insert oppConRole;
        
        System.debug('###opPConRole: ' + oppConRole);
        
		Test.setCurrentPage(Page.LifetimeOption_ypo);
		ApexPages.StandardController standCon = new ApexPages.StandardController(oContact);
		RecertificationExtension conExt = new RecertificationExtension(standCon);
		conExt.oOpp = testOpp;
		
		Boolean testBool;
		String testStr;
		PageReference pr;
		List<SelectOption> opts;
		Opportunity opp;
		
		System.runAs(testUser) {
			Test.startTest();
				conExt.init();
				//testBool = conExt.hasGrace;
				testStr = RecertificationExtension.UPDATED_CRITERIA_TITLE;
				testStr = RecertificationExtension.UPDATED_CRITERIA_COMPANY;
				testStr = RecertificationExtension.UPDATED_CRITERIA_BOTH;
				pr = conExt.saveOnRecertification();
				pr = conExt.requestTransition();
				pr = conExt.toDesiredWPOChapter();
				pr = conExt.requestGrace();
				//pr = conExt.checkQualificationCriteria();
				pr = conExt.toThirdPartyCertification();
				pr = conExt.toVenuePage();
				pr = conExt.toContactMemberServices();
				pr = conExt.backGold();
				opts = conExt.getPicklistValues(testOpp, 'StageName');
				opp = conExt.getMappedOpportunity();
				opts = conExt.getEnterpriseType();
				opts = conExt.getTitle();
				opts = conExt.getPresidentType();
				opts = conExt.getBusinessScope();
				opts = conExt.getFirmType();
				opts = conExt.getCorporationType();
				opts = conExt.getIndustry();
				testOpp.Transition_Flag__c = true;
				conExt.oOpp = testOpp;
				conExt.oContact = oContact;
				conExt.oContact.Transition_Status__c = 'Eligible for early transition';
				conExt.oContact.Lifetime_Dues_Status__c = null;
				pr = conExt.saveOnRecertification();
				testBool = conExt.hasGrace;
				conExt.isTransition = true;
				conExt.setupOpportunityForPage();
			Test.stopTest();
		}
	}
	
	static testMethod void testSaveOnRecert() {
		setupData();
		
		Account oAccount = new Account();
        oAccount.recordtypeid=  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        oAccount.Industry = 'Technology';
        oAccount.Sub_Category__c ='Warehousing & Storage';
        oAccount.Is_Subsidiary__c = TRUE;
        oAccount.Parent_Company__c='Test parent';
        oAccount.Name = 'Acc';
        insert oAccount;
        
		Contact oContact = new Contact();
        oContact.AccountId = oAccount.Id;
        oContact.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member','Contact').Id;
        oContact = (Contact)JSONUtils.setField(oContact, 'Record_Type_Name__c', 'Member');
        oContact.lastname = 'Test Member Contact';
        oContact.YPO_WPO__c = 'YPO';
        oContact.Transition_Status__c =  'Eligible for early transition';
        //oContact.Grace_Years_Accrued__c = 10;
        oContact.Grace_Accrued_FY17__c = 10;
        oContact.Is_Grace_Used__c = FALSE;
        oContact.Date_Last_Grace_Year_Used__c = Date.newInstance(System.Today().year(), 8, 1);
        oContact.Join_date__c = Date.newInstance(2000, 1, 1);
        oContact.Number_of_Employees__c = 10;
        oContact.Annual_Assets__c = 10;
        oContact.Annual_Fees__c = 10;
        oContact.Annual_Revenue__c = 10;
        oContact.Transition_Status__c = 'Eligible for early transition';
		oContact.Lifetime_Dues_Status__c = null;
        
        insert oContact; 
        
		testOpp.NumberOfEmployees__c = 100;
		testOpp.Enterprise_Value__c = 100;
		testOpp.AnnualRevenue__c = 100;
		testOpp.NumberOfEmployees__c = 100;
		testOpp.Organization_Type__c = 'Agency-Type';
		testOpp.KGRenewal__Contact__c = oContact.Id;
		update testOpp;
		
		testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
		testContact.Transition_Status__c = 'Transitioned';
		update testContact;
		testContact.recalculateFormulas();
		
		OpportunityContactRole oppConRole = new OpportunityContactRole(Contactid=oContact.id,OpportunityId=testOpp.id,IsPrimary=TRUE);
        insert oppConRole;
        
        System.debug('###opPConRole: ' + oppConRole);
        
		Test.setCurrentPage(Page.LifetimeOption_ypo);
		ApexPages.StandardController standCon = new ApexPages.StandardController(oContact);
		RecertificationExtension conExt = new RecertificationExtension(standCon);
		conExt.oOpp = testOpp;
		
		PageReference pr;
		System.runAs(testUser) {
			Test.startTest();
					pr = conExt.saveOnRecertification();
			Test.stopTest();
		}
	}
	
	static testMethod void testSaveOnRecertLifetime() {
		setupData();
		
		Account oAccount = new Account();
        oAccount.recordtypeid=  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        oAccount.Industry = 'Technology';
        oAccount.Sub_Category__c ='Warehousing & Storage';
        oAccount.Is_Subsidiary__c = TRUE;
        oAccount.Parent_Company__c='Test parent';
        oAccount.Name = 'Acc';
        insert oAccount;
        
		Contact oContact = new Contact();
        oContact.AccountId = oAccount.Id;
        oContact.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member','Contact').Id;
        oContact = (Contact)JSONUtils.setField(oContact, 'Record_Type_Name__c', 'Member');
        oContact.lastname = 'Test Member Contact';
        oContact.YPO_WPO__c = 'YPO';
        oContact.Transition_Status__c =  'Eligible for early transition';
        //oContact.Grace_Years_Accrued__c = 10;
        oContact.Grace_Accrued_FY17__c = 10;
        oContact.Is_Grace_Used__c = FALSE;
        oContact.Date_Last_Grace_Year_Used__c = Date.newInstance(System.Today().year(), 8, 1);
        oContact.Join_date__c = Date.newInstance(2000, 1, 1);
        oContact.Number_of_Employees__c = 10;
        oContact.Annual_Assets__c = 10;
        oContact.Annual_Fees__c = 10;
        oContact.Annual_Revenue__c = 10;
        oContact.Transition_Status__c = 'Scheduled for transition';
		oContact.Lifetime_Dues_Status__c = null;
        
        insert oContact; 
        
		testOpp.NumberOfEmployees__c = 100;
		testOpp.Enterprise_Value__c = 100;
		testOpp.AnnualRevenue__c = 100;
		testOpp.NumberOfEmployees__c = 100;
		testOpp.Organization_Type__c = 'Agency-Type';
		testOpp.KGRenewal__Contact__c = oContact.Id;
		update testOpp;
		
		testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
		testContact.Transition_Status__c = 'Transitioned';
		update testContact;
		testContact.recalculateFormulas();
		
		OpportunityContactRole oppConRole = new OpportunityContactRole(Contactid=oContact.id,OpportunityId=testOpp.id,IsPrimary=TRUE);
        insert oppConRole;
        
        System.debug('###opPConRole: ' + oppConRole);
        
		Test.setCurrentPage(Page.LifetimeOption_ypo);
		ApexPages.StandardController standCon = new ApexPages.StandardController(oContact);
		RecertificationExtension conExt = new RecertificationExtension(standCon);
		conExt.oOpp = testOpp;
		
		PageReference pr;
		Boolean testBool;
		Account tAcc;
		Opportunity tOpp;
		System.runAs(testUser) {
			pr = conExt.saveOnRecertification();
			testBool = RecertificationExtension.updateOpportunityEachSec(JSON.serialize(testOpp));
			tAcc = RecertificationExtension.getAnAccount(JSON.serialize(oContact));
			tOpp = RecertificationExtension.getAnOpportunity(JSON.serialize(oContact));
			tOpp = RecertificationExtension.getPreviousOpportunity(JSON.serialize(oContact));
		}
	}
	
}