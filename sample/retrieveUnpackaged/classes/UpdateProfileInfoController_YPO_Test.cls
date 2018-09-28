@isTest
private class UpdateProfileInfoController_YPO_Test {
            
	@TestSetup
    private static void setupContactForPage()
    {
		Profile prof = [SELECT Id FROM Profile WHERE Name = :Label.Customer_Community_User_Custom LIMIT 1];

        Account chapterAccount = (Account) SObjectFactory.build(Account.SObjectType);
        chapterAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chapter').getRecordTypeId();
        chapterAccount.Type = 'Chapter';
        chapterAccount.YPOI_Type__c = 'YPO Chapter';
        
        Account Household1 = new Account();
        Household1.Name ='Test Account';
        Household1.Type = 'Relationship';
        Household1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship').getRecordTypeId();
		
        Account Household2 = new Account();
        Household2.Name ='Test Account';
        Household2.Type = 'Relationship';
        Household2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship').getRecordTypeId();
		
		insert new List<Account>{chapterAccount, Household1, Household2};
        
        Contact testContact = (Contact) SObjectFactory.build(Contact.SObjectType);
        testContact.FirstName = 'Test First Name';
        testContact.Lastname = 'Test last Name';
        testContact.Gender__c = 'Male';
        testContact.Email = 'test.name@gmail.com';
        testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        testContact.Date_Last_Profile_Updated__c = Date.Today().addDays(-1);
		testContact.Is_Address2_Primary__c = true;
        testContact.AccountId = chapterAccount.Id;
		testContact.MailingStreet = '123 Any St.\r\nSuite 120';
		testContact.MailingCity = 'Anytown';
		testContact.MailingState = 'Florida';
		testContact.MailingCountry = 'United States';
		testContact.OtherStreet = '456 Some St.';
		testContact.OtherCity = 'Sometown';
		testContact.OtherState = 'Alabama';
		testContact.OtherCountry = 'United States';

        Contact ProspectContact = (Contact) SObjectFactory.build(Contact.SObjectType);
        ProspectContact.FirstName = 'Test First Name';
        ProspectContact.Lastname = 'Test last Name';
        ProspectContact.Gender__c = 'Male';
        ProspectContact.Email = 'Prospect@gmail.com';
        ProspectContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        ProspectContact.Date_Last_Profile_Updated__c = Date.Today().addDays(-1);
		ProspectContact.Is_Address2_Primary__c = true;
        ProspectContact.AccountId = chapterAccount.Id;
		ProspectContact.MailingStreet = '123 Any St.\r\nSuite 120';
		ProspectContact.MailingCity = 'Anytown';
		ProspectContact.MailingState = 'Florida';
		ProspectContact.MailingCountry = 'United States';
		ProspectContact.OtherStreet = '456 Some St.';
		ProspectContact.OtherCity = 'Sometown';
		ProspectContact.OtherState = 'Alabama';
		ProspectContact.OtherCountry = 'United States';

        Contact spousecon = new Contact();
        spousecon.FirstName = 'Spouse First Name';
        spousecon.Lastname = 'Spouse last Name';
        spousecon.Gender__c = 'Female';
        spousecon.Email = 'spouse.name@ypo.com';
        spousecon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Spouse/Partner').getRecordTypeId();
        spousecon.AccountId = chapterAccount.Id;
        
        Contact childCon = new Contact();
        childCon.FirstName = 'Child First Name';
        childCon.Lastname = 'Child last Name';
        childCon.Gender__c = 'Female';
        childCon.Email = 'child.name@ypo.com';
        childCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Child').getRecordTypeId();
        childCon.AccountId = chapterAccount.Id;

        insert new List<Contact>{testContact,spousecon,childCon, ProspectContact};
        
        Relationship__c relCmmtyUser = new Relationship__c(
            Account__c = Household1.Id, 
            Is_Active__c=true, 
            Contact__c = testContact.Id, 
            Relationship_Type__c = 'Member');
        
        Relationship__c relSpouse = new Relationship__c(
            Account__c = Household1.Id, 
            Is_Active__c=true, 
            Contact__c = spousecon.Id, 
            Relationship_Type__c = 'Spouse/Partner');
        
        Relationship__c relChild = new Relationship__c(
            Account__c = Household1.Id, 
            Is_Active__c=true, 
            Contact__c = childCon.Id, 
            Relationship_Type__c = 'Child');

        Relationship__c relCmmtyUser2 = new Relationship__c(
            Account__c = Household2.Id, 
            Is_Active__c=true, 
            Contact__c = ProspectContact.Id, 
            Relationship_Type__c = 'Member');
        
		insert new List<Relationship__c>{relCmmtyUser,relSpouse,relChild,relCmmtyUser2};

		User AdminUser = [SELECT Id FROM User Where Profile.Name = 'System Administrator' and isActive=true LIMIT 1];

		System.runAs(AdminUser) {
			User customerUser = new User(
				Email = 'test-user@fakeemail.com',
				ContactId = testContact.id,
				ProfileId = prof.id,
				UserName = 'test-user@fakeemail.com',
				Alias = 'customer',
				LocaleSidKey = 'en_US',
				CommunityNickName = 'customer',
				TimeZoneSidKey = 'America/Los_Angeles',
				EmailEncodingKey = 'ISO-8859-1',
				LanguageLocaleKey = 'en_US',
				FirstName = 'Customer Portal Manager',
				LastName = 'Custom',
				isActive = true);

			insert new List<User> {customerUser};
		}
        
        Opportunity testOpp = TestServices.createOpp('Cycle Open',chapterAccount.Id,testContact.Id,true);

		testOpp = TestServices.createOpp('New',chapterAccount.Id,ProspectContact.Id,true);
        System.debug('Stagename: ' + testOpp.StageName + ' KGRenewal__IsActiveCart__c: ' + testOpp.KGRenewal__IsActiveCart__c);
		System.debug('Opp_Rec_Type: ' + testOpp.Record_Type_Name__c);
    }
    
    public static testMethod void NoContactTest(){
		User AdminUser = [SELECT Id FROM User Where Profile.Name = 'System Administrator' and isActive=true LIMIT 1];

		System.runAs(AdminUser) {
			Test.startTest();
				Test.setCurrentPage(page.UpdateProfileInfo_YPO);
				ApexPages.StandardController stdCon = new ApexPages.StandardController(new contact());
				UpdateProfileInfoController_YPO controller = new UpdateProfileInfoController_YPO(stdCon);

				System.assert(ApexPages.hasMessages(),'Should have errored out because no contact should have been found. \r\n ' + ApexPages.getMessages());
			Test.stopTest();
		}
	}

    static testMethod void Test_Contactprofileunittest() {
		User PartnerUser = [Select Id, ContactId from user where UserName = 'test-user@fakeemail.com'];
		contact testcontact = [select Id, Name, AccountId, Email, Transition_Status__c, RecordTypeId, Is_Address1_Primary__c, Is_Address2_Primary__c, OtherCountry, OtherState, MailingStreet, Date_Last_Profile_Updated__c from Contact where id = :PartnerUser.ContactId];
		Relationship__c HouseHold_Member = [Select account__c from Relationship__c where Is_Active__c=true and Contact__c = :testContact.Id and Relationship_Type__c = 'Member'];
		List<Relationship__c> HouseHold = [Select id from Relationship__c where Is_Active__c=true and Account__c = :HouseHold_Member.Account__c];

        System.runAs(PartnerUser) {
			Test.startTest();
				Test.setCurrentPage(page.UpdateProfileinfo_YPO);
				//ApexPages.currentPage().getParameters().put('id',testContact.Id);
				ApexPages.StandardController sc = new ApexPages.StandardController(new contact());
				UpdateProfileInfoController_YPO updateprofile = new UpdateProfileInfoController_YPO(sc);
				System.assert(!ApexPages.hasMessages(),'Should not have errored out. \r\n ' + ApexPages.getMessages());

				updateProfile.updateLastProfileUpdatedOnContact();
				id ChildRecId = updateprofile.childRecordTypeId;
				id SpouseRecId = updateprofile.spouseRecordTypeId;
				String JEmail = 'ContactProfile@ypo.com';
				String contactJSONStr = '{ "Id" : \"'+ testContact.Id + '\" , "Email":\"'+JEmail+ '\" }';        
				UpdateProfileInfoController_YPO.updateContactProfile(contactJSONStr);
				List<Contact> listContacts = UpdateProfileInfoController_YPO.getAllSpouseChilds(testContact.Id, HouseHold_Member.Account__c);
				for (Contact HouseholdContacts : listContacts) {
					UpdateProfileInfoController_YPO.updateSpouseChild(HouseholdContacts.FirstName, HouseholdContacts.LastName, HouseholdContacts.Gender__c,
							HouseholdContacts.Email, HouseholdContacts.Phone, String.valueOf(false), HouseholdContacts.Id, HouseholdContacts.RecordTypeId,
							RecordTypeServices.getRecordTypeById(HouseholdContacts.RecordTypeId).Name, HouseHold_Member.Account__c, HouseholdContacts.AccountId, string.valueOf(false),'',
							'', '', '1', '', String.valueOf(HouseholdContacts.Birthdate));
				}
				Contact cnt = UpdateProfileInfoController_YPO.getAContact(testContact.Id);

				Integer HouseholdSize = HouseHold.size();
				//Add a new child to the household.
				UpdateProfileInfoController_YPO.updateSpouseChild('firstName', 'lastName','Male', 'email@ypo.com', '9876543210','PortalAccessLevel',
							'', String.valueOf(Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Child').getRecordTypeId()), 
							'Child', String.valueOf(HouseHold_Member.Account__c), String.valueOf(testcontact.accountid), 
							String.valueOf(false), '', '', '', '1234567890', '', '2000-10-01');
				
				HouseHold = [Select id from Relationship__c where Is_Active__c=true and Account__c = :HouseHold_Member.Account__c];
				System.assertNotEquals(HouseholdSize,HouseHold.size(),'New child should have been added to the household!');

				System.assertNotEquals(testContact.Date_Last_Profile_Updated__c, cnt.Date_Last_Profile_Updated__c, 'We expect the Contact profile to have been updated.');
			Test.stopTest();
		}
    }
    
    static testMethod void Test_Constructor_OppStatus()
    {
		User PartnerUser = [Select Id, ContactId from user where UserName = 'test-user@fakeemail.com'];
		contact testcontact = [select Id, Name, AccountId, Email, Transition_Status__c, RecordTypeId, Is_Address1_Primary__c, Is_Address2_Primary__c, OtherCountry, OtherState, MailingStreet, Date_Last_Profile_Updated__c from Contact where id = :PartnerUser.ContactId];

        System.runAs(PartnerUser) {
			Test.startTest();
				Test.setCurrentPageReference(new PageReference('/apex/UpdateProfileInfoController_YPO'));
				ApexPages.currentPage().getParameters().put('id', testContact.Id);
        
				ApexPages.standardController controller = new ApexPages.standardController(testContact); 
				UpdateProfileInfoController_YPO currentPage = new UpdateProfileInfoController_YPO(controller);
				System.assert(!ApexPages.hasMessages(),'Should not have errored out. \r\n ' + ApexPages.getMessages());

				currentPage.updateLastProfileUpdatedOnContact();
			Test.stopTest();

			//Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
			System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_IN_PROGRESS, currentPage.relatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');
        }
    }
    
    static testMethod void Test_saveOpportunity()
    {
		User PartnerUser = [Select Id, ContactId from user where UserName = 'test-user@fakeemail.com'];
		contact testcontact = [select Id, Name, AccountId, Email, Transition_Status__c, RecordTypeId, Is_Address1_Primary__c, Is_Address2_Primary__c, OtherCountry, OtherState, MailingStreet, Date_Last_Profile_Updated__c from Contact where id = :PartnerUser.ContactId];

        PageReference expectedPage =  Page.Recertification_Screen;
        
        System.runAs(PartnerUser) {
			Test.startTest();
				Test.setCurrentPageReference(new PageReference('/apex/UpdateProfileInfoController_YPO'));
				ApexPages.currentPage().getParameters().put('id', testContact.Id);
        
				ApexPages.standardController controller = new ApexPages.standardController(testContact); 
				UpdateProfileInfoController_YPO currentPage = new UpdateProfileInfoController_YPO(controller);
				System.assert(!ApexPages.hasMessages(),'Should not have errored out. \r\n ' + ApexPages.getMessages());

				currentPage.updateLastProfileUpdatedOnContact();
				//Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
				//System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_IN_PROGRESS, currentPage.relatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');
        
				PageReference returnPage = currentPage.saveOpportunity();
			Test.stopTest();

			System.assert(!ApexPages.hasMessages(),'We expect the page to not have any messages: '+ApexPages.getMessages());

			System.assert(returnPage.getUrl().contains(expectedPage.getUrl()), 'We expected to redirected to the correct page. Expected: '+expectedPage.getUrl()+' Actual: '+returnPage.getUrl() );
        }

		Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Contact__c = :testcontact.id LIMIT 1];
		System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_COMPLETE, updatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');

    }

    static testmethod void Test_DuplicateEmail() {
		User PartnerUser = [Select Id, ContactId from user where UserName = 'test-user@fakeemail.com'];
		contact testcontact = [select Id, Name, AccountId, Email, Transition_Status__c, RecordTypeId, Is_Address1_Primary__c, Is_Address2_Primary__c, OtherCountry, OtherState, MailingStreet, Date_Last_Profile_Updated__c from Contact where id = :PartnerUser.ContactId];

		Contact NewContact = (Contact) SObjectFactory.build(Contact.SObjectType);
		NewContact.Email = 'test.name@gmail.com';

        System.runAs(PartnerUser) {
    		Test.startTest();
				Boolean FoundDuplicateEmail = UpdateProfileInfoController_YPO.isDuplicateEMail(testContact.Email,testContact.Id);
				System.assert(!FoundDuplicateEmail,'No duplicate email should exist!');

				FoundDuplicateEmail = UpdateProfileInfoController_YPO.isDuplicateEMail(NewContact.Email,NewContact.Id);
				System.assert(FoundDuplicateEmail,'Duplicate email should exist!');
    		Test.stopTest();
		}
    }

    static testMethod void Test_saveOpportunity_Contact_Transitioned() {
		User PartnerUser = [Select Id, ContactId from user where UserName = 'test-user@fakeemail.com'];
		contact testcontact = [select Id, Name, AccountId, Email, Transition_Status__c, RecordTypeId, Is_Address1_Primary__c, Is_Address2_Primary__c, OtherCountry, OtherState, MailingStreet, Date_Last_Profile_Updated__c from Contact where id = :PartnerUser.ContactId];
		testcontact.Transition_Status__c = 'Scheduled for transition';
		update testcontact;

        PageReference expectedPage =  Page.Gold_Transition_Option_YPO;

		//Renewal status settings
		Opportunity testOpp = [SELECT Id, Profile_Page_Status_Exchange__c, Certification_Page_Status_Exchange__c FROM Opportunity WHERE Contact__c = :testcontact.id LIMIT 1];
        testOpp.Profile_Page_Status_Exchange__c = UpdateProfileInfoController_YPO.PROFILE_STATUS_NOT_STARTED;
		testOpp.Certification_Page_Status_Exchange__c = 'Not Started';
		testOpp.Dues_Page_Status_Exchange__c = 'Not Started';
		testOpp.Grace_Status__c = 'No Grace Needed';
		testOpp.Certification_Type__c = 'Self Certify';
		testOpp.Transition_Flag__c = false;
		update testOpp;
        
        System.runAs(PartnerUser) {
			Test.startTest();
				Test.setCurrentPageReference(new PageReference('/apex/UpdateProfileInfoController_YPO'));
				ApexPages.currentPage().getParameters().put('id', testContact.Id);
				//testContact.recalculateFormulas();
        
				ApexPages.standardController controller = new ApexPages.standardController(testContact); 
				UpdateProfileInfoController_YPO currentPage = new UpdateProfileInfoController_YPO(controller);
				currentPage.updateLastProfileUpdatedOnContact();
				System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_IN_PROGRESS, currentPage.relatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');
        
				PageReference returnPage = currentPage.saveOpportunity();
			Test.stopTest();
        
			System.assert(!ApexPages.hasMessages(),'We expect the page to not have any messages: '+ApexPages.getMessages());
			System.assert(returnPage.getUrl().contains(expectedPage.getUrl()), 'We expected to redirected to the correct page. Expected: '+expectedPage.getUrl()+' Actual: '+returnPage.getUrl() );
		}

		Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
		System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_COMPLETE, updatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');
    }
    
    static testMethod void Test_saveOpportunity_Recertification() {
		User PartnerUser = [Select Id, ContactId from user where UserName = 'test-user@fakeemail.com'];
		contact testcontact = [select Id, Name, AccountId, Email, Transition_Status__c, RecordTypeId, Is_Address1_Primary__c, Is_Address2_Primary__c, OtherCountry, OtherState, MailingStreet, Date_Last_Profile_Updated__c from Contact where id = :PartnerUser.ContactId];

        PageReference expectedPage =  Page.Recertification_Screen;

		//Renewal status settings
		Opportunity testOpp = [SELECT Id, Profile_Page_Status_Exchange__c, Certification_Page_Status_Exchange__c FROM Opportunity WHERE Contact__c = :testcontact.id LIMIT 1];
        testOpp.Profile_Page_Status_Exchange__c = UpdateProfileInfoController_YPO.PROFILE_STATUS_NOT_STARTED;
		testOpp.Certification_Page_Status_Exchange__c = 'Not Started';
		testOpp.Dues_Page_Status_Exchange__c = 'Not Started';
		testOpp.Grace_Status__c = 'No Grace Needed';
		testOpp.Certification_Type__c = 'Self Certify';
		testOpp.Transition_Flag__c = false;
		update testOpp;
        
        System.runAs(PartnerUser) {
			Test.startTest();
				Test.setCurrentPageReference(new PageReference('/apex/UpdateProfileInfoController_YPO'));
				ApexPages.currentPage().getParameters().put('id', testContact.Id);
				//testContact.recalculateFormulas();
        
				ApexPages.standardController controller = new ApexPages.standardController(testContact); 
				UpdateProfileInfoController_YPO currentPage = new UpdateProfileInfoController_YPO(controller);
				currentPage.updateLastProfileUpdatedOnContact();
				//Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
				System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_IN_PROGRESS, currentPage.relatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');
        
				PageReference returnPage = currentPage.saveOpportunity();
			Test.stopTest();
        
			System.assert(!ApexPages.hasMessages(),'We expect the page to not have any messages: '+ApexPages.getMessages());
			System.assert(returnPage.getUrl().contains(expectedPage.getUrl()), 'We expected to redirected to the correct page. Expected: '+expectedPage.getUrl()+' Actual: '+returnPage.getUrl() );
		}
		Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
		System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_COMPLETE, updatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');

	}

    static testMethod void Test_saveOpportunity_Grace() {
		User PartnerUser = [Select Id, ContactId from user where UserName = 'test-user@fakeemail.com'];
		contact testcontact = [select Id, Name, AccountId, Email, Transition_Status__c, RecordTypeId, Is_Address1_Primary__c, Is_Address2_Primary__c, OtherCountry, OtherState, MailingStreet, Date_Last_Profile_Updated__c from Contact where id = :PartnerUser.ContactId];

        PageReference expectedPage =  Page.Catalog_YPO;

		//Renewal status settings
		Opportunity testOpp = [SELECT Id, Profile_Page_Status_Exchange__c, Certification_Page_Status_Exchange__c FROM Opportunity WHERE Contact__c = :testcontact.id LIMIT 1];
        testOpp.Profile_Page_Status_Exchange__c = UpdateProfileInfoController_YPO.PROFILE_STATUS_NOT_STARTED;
		testOpp.Certification_Page_Status_Exchange__c = 'Not Started';
		testOpp.Dues_Page_Status_Exchange__c = 'Not Started';
		testOpp.Grace_Status__c = 'Approved';
		testOpp.Certification_Type__c = 'Self Certify';
		testOpp.Transition_Flag__c = false;
		update testOpp;
        
        System.runAs(PartnerUser) {
			Test.startTest();
				Test.setCurrentPageReference(new PageReference('/apex/UpdateProfileInfoController_YPO'));
				ApexPages.currentPage().getParameters().put('id', testContact.Id);
				//testContact.recalculateFormulas();
        
				ApexPages.standardController controller = new ApexPages.standardController(testContact); 
				UpdateProfileInfoController_YPO currentPage = new UpdateProfileInfoController_YPO(controller);
				currentPage.updateLastProfileUpdatedOnContact();
				//Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
				System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_IN_PROGRESS, currentPage.relatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');
        
				PageReference returnPage = currentPage.saveOpportunity();
			Test.stopTest();
        
			System.assert(!ApexPages.hasMessages(),'We expect the page to not have any messages: '+ApexPages.getMessages());
			System.assert(returnPage.getUrl().contains(expectedPage.getUrl()), 'We expected to redirected to the correct page. Expected: '+expectedPage.getUrl()+' Actual: '+returnPage.getUrl() );
		}
		Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
		System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_COMPLETE, updatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');

	}

    static testMethod void Test_saveOpportunity_Transitioned() {
		User PartnerUser = [Select Id, ContactId from user where UserName = 'test-user@fakeemail.com'];
		contact testcontact = [select Id, Name, AccountId, Email, Transition_Status__c, RecordTypeId, Is_Address1_Primary__c, Is_Address2_Primary__c, OtherCountry, OtherState, MailingStreet, Date_Last_Profile_Updated__c from Contact where id = :PartnerUser.ContactId];

        PageReference expectedPage =  Page.Catalog_YPO;

		//Renewal status settings
		Opportunity testOpp = [SELECT Id, Profile_Page_Status_Exchange__c, Certification_Page_Status_Exchange__c FROM Opportunity WHERE Contact__c = :testcontact.id LIMIT 1];
        testOpp.Profile_Page_Status_Exchange__c = UpdateProfileInfoController_YPO.PROFILE_STATUS_NOT_STARTED;
		testOpp.Certification_Page_Status_Exchange__c = 'Not Started';
		testOpp.Dues_Page_Status_Exchange__c = 'Not Started';
		testOpp.Grace_Status__c = 'No Grace Needed';
		testOpp.Certification_Type__c = 'Self Certify';
		testOpp.Transition_Flag__c = true;
		update testOpp;
        
        System.runAs(PartnerUser) {
			Test.startTest();
				Test.setCurrentPageReference(new PageReference('/apex/UpdateProfileInfoController_YPO'));
				ApexPages.currentPage().getParameters().put('id', testContact.Id);
				//testContact.recalculateFormulas();
        
				ApexPages.standardController controller = new ApexPages.standardController(testContact); 
				UpdateProfileInfoController_YPO currentPage = new UpdateProfileInfoController_YPO(controller);
				currentPage.updateLastProfileUpdatedOnContact();
				//Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
				System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_IN_PROGRESS, currentPage.relatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');
        
				PageReference returnPage = currentPage.saveOpportunity();
			Test.stopTest();
        
			System.assert(!ApexPages.hasMessages(),'We expect the page to not have any messages: '+ApexPages.getMessages());
			System.assert(returnPage.getUrl().contains(expectedPage.getUrl()), 'We expected to redirected to the correct page. Expected: '+expectedPage.getUrl()+' Actual: '+returnPage.getUrl() );
		}
		Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
		System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_COMPLETE, updatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');
	}

    static testMethod void Test_saveOpportunity_Grace_Paid() {
		User PartnerUser = [Select Id, ContactId from user where UserName = 'test-user@fakeemail.com'];
		contact testcontact = [select Id, Name, AccountId, Email, Transition_Status__c, RecordTypeId, Is_Address1_Primary__c, Is_Address2_Primary__c, OtherCountry, OtherState, MailingStreet, Date_Last_Profile_Updated__c from Contact where id = :PartnerUser.ContactId];

        PageReference expectedPage =  Page.SplashScreen_Thankyou;

		//Renewal status settings
		Opportunity testOpp = [SELECT Id, Profile_Page_Status_Exchange__c, Certification_Page_Status_Exchange__c FROM Opportunity WHERE Contact__c = :testcontact.id LIMIT 1];
        testOpp.Profile_Page_Status_Exchange__c = UpdateProfileInfoController_YPO.PROFILE_STATUS_NOT_STARTED;
		testOpp.Certification_Page_Status_Exchange__c = 'Not Started';
		testOpp.Dues_Page_Status_Exchange__c = 'Complete';
		testOpp.Grace_Status__c = 'Approved';
		testOpp.Certification_Type__c = 'Self Certify';
		testOpp.Transition_Flag__c = false;
		update testOpp;
        
        System.runAs(PartnerUser) {
			Test.startTest();
				Test.setCurrentPageReference(new PageReference('/apex/UpdateProfileInfoController_YPO'));
				ApexPages.currentPage().getParameters().put('id', testContact.Id);
				//testContact.recalculateFormulas();
        
				ApexPages.standardController controller = new ApexPages.standardController(testContact); 
				UpdateProfileInfoController_YPO currentPage = new UpdateProfileInfoController_YPO(controller);
				currentPage.updateLastProfileUpdatedOnContact();
				//Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
				System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_IN_PROGRESS, currentPage.relatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');
        
				PageReference returnPage = currentPage.saveOpportunity();
			Test.stopTest();
        
			System.assert(!ApexPages.hasMessages(),'We expect the page to not have any messages: '+ApexPages.getMessages());
			System.assert(returnPage.getUrl().contains(expectedPage.getUrl()), 'We expected to redirected to the correct page. Expected: '+expectedPage.getUrl()+' Actual: '+returnPage.getUrl() );
		}
		Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
		System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_COMPLETE, updatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');
	}

    static testMethod void Test_saveOpportunity_Transitioned_Paid() {
		User PartnerUser = [Select Id, ContactId from user where UserName = 'test-user@fakeemail.com'];
		contact testcontact = [select Id, Name, AccountId, Email, Transition_Status__c, RecordTypeId, Is_Address1_Primary__c, Is_Address2_Primary__c, OtherCountry, OtherState, MailingStreet, Date_Last_Profile_Updated__c from Contact where id = :PartnerUser.ContactId];

        PageReference expectedPage =  Page.SplashScreen_Thankyou;

		//Renewal status settings
		Opportunity testOpp = [SELECT Id, Profile_Page_Status_Exchange__c, Certification_Page_Status_Exchange__c FROM Opportunity WHERE Contact__c = :testcontact.id LIMIT 1];
        testOpp.Profile_Page_Status_Exchange__c = UpdateProfileInfoController_YPO.PROFILE_STATUS_NOT_STARTED;
		testOpp.Certification_Page_Status_Exchange__c = 'Not Started';
		testOpp.Dues_Page_Status_Exchange__c = 'Complete';
		testOpp.Grace_Status__c = 'No Grace Needed';
		testOpp.Certification_Type__c = 'Self Certify';
		testOpp.Transition_Flag__c = true;
		update testOpp;
        
        System.runAs(PartnerUser) {
			Test.startTest();
				Test.setCurrentPageReference(new PageReference('/apex/UpdateProfileInfoController_YPO'));
				ApexPages.currentPage().getParameters().put('id', testContact.Id);
				//testContact.recalculateFormulas();
        
				ApexPages.standardController controller = new ApexPages.standardController(testContact); 
				UpdateProfileInfoController_YPO currentPage = new UpdateProfileInfoController_YPO(controller);
				currentPage.updateLastProfileUpdatedOnContact();
				//Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
				System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_IN_PROGRESS, currentPage.relatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');
        
				PageReference returnPage = currentPage.saveOpportunity();
			Test.stopTest();
        
			System.assert(!ApexPages.hasMessages(),'We expect the page to not have any messages: '+ApexPages.getMessages());
			System.assert(returnPage.getUrl().contains(expectedPage.getUrl()), 'We expected to redirected to the correct page. Expected: '+expectedPage.getUrl()+' Actual: '+returnPage.getUrl() );
		}
		Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
		System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_COMPLETE, updatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');
	}

    static testMethod void Test_saveOpportunity_Grace_Progress() {
		User PartnerUser = [Select Id, ContactId from user where UserName = 'test-user@fakeemail.com'];
		contact testcontact = [select Id, Name, AccountId, Email, Transition_Status__c, RecordTypeId, Is_Address1_Primary__c, Is_Address2_Primary__c, OtherCountry, OtherState, MailingStreet, Date_Last_Profile_Updated__c from Contact where id = :PartnerUser.ContactId];

        PageReference expectedPage =  Page.Checkout_Check_Wire_YPO;

		//Renewal status settings
		Opportunity testOpp = [SELECT Id, Profile_Page_Status_Exchange__c, Certification_Page_Status_Exchange__c FROM Opportunity WHERE Contact__c = :testcontact.id LIMIT 1];
        testOpp.Profile_Page_Status_Exchange__c = UpdateProfileInfoController_YPO.PROFILE_STATUS_NOT_STARTED;
		testOpp.Certification_Page_Status_Exchange__c = 'Not Started';
		testOpp.Dues_Page_Status_Exchange__c = 'In Progress';
		testOpp.Grace_Status__c = 'Approved';
		testOpp.Certification_Type__c = 'Self Certify';
		testOpp.Transition_Flag__c = false;
		update testOpp;
        
        System.runAs(PartnerUser) {
			Test.startTest();
				Test.setCurrentPageReference(new PageReference('/apex/UpdateProfileInfoController_YPO'));
				ApexPages.currentPage().getParameters().put('id', testContact.Id);
				//testContact.recalculateFormulas();
        
				ApexPages.standardController controller = new ApexPages.standardController(testContact); 
				UpdateProfileInfoController_YPO currentPage = new UpdateProfileInfoController_YPO(controller);
				currentPage.updateLastProfileUpdatedOnContact();
				//Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
				System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_IN_PROGRESS, currentPage.relatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');
        
				PageReference returnPage = currentPage.saveOpportunity();
			Test.stopTest();
        
			System.assert(!ApexPages.hasMessages(),'We expect the page to not have any messages: '+ApexPages.getMessages());
			System.assert(returnPage.getUrl().contains(expectedPage.getUrl()), 'We expected to redirected to the correct page. Expected: '+expectedPage.getUrl()+' Actual: '+returnPage.getUrl() );
		}
		Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
		System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_COMPLETE, updatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');

	}

    static testMethod void Test_saveOpportunity_Transitioned_Progress() {
		User PartnerUser = [Select Id, ContactId from user where UserName = 'test-user@fakeemail.com'];
		contact testcontact = [select Id, Name, AccountId, Email, Transition_Status__c, RecordTypeId, Is_Address1_Primary__c, Is_Address2_Primary__c, OtherCountry, OtherState, MailingStreet, Date_Last_Profile_Updated__c from Contact where id = :PartnerUser.ContactId];

        PageReference expectedPage =  Page.Checkout_Check_Wire_YPO;

		//Renewal status settings
		Opportunity testOpp = [SELECT Id, Profile_Page_Status_Exchange__c, Certification_Page_Status_Exchange__c FROM Opportunity WHERE Contact__c = :testcontact.id LIMIT 1];
        testOpp.Profile_Page_Status_Exchange__c = UpdateProfileInfoController_YPO.PROFILE_STATUS_NOT_STARTED;
		testOpp.Certification_Page_Status_Exchange__c = 'Not Started';
		testOpp.Dues_Page_Status_Exchange__c = 'In Progress';
		testOpp.Grace_Status__c = 'No Grace Needed';
		testOpp.Certification_Type__c = 'Self Certify';
		testOpp.Transition_Flag__c = true;
		update testOpp;
        
        System.runAs(PartnerUser) {
			Test.startTest();
				Test.setCurrentPageReference(new PageReference('/apex/UpdateProfileInfoController_YPO'));
				ApexPages.currentPage().getParameters().put('id', testContact.Id);
				//testContact.recalculateFormulas();
        
				ApexPages.standardController controller = new ApexPages.standardController(testContact); 
				UpdateProfileInfoController_YPO currentPage = new UpdateProfileInfoController_YPO(controller);
				currentPage.updateLastProfileUpdatedOnContact();
				//Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
				System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_IN_PROGRESS, currentPage.relatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');
        
				PageReference returnPage = currentPage.saveOpportunity();
			Test.stopTest();
        
			System.assert(!ApexPages.hasMessages(),'We expect the page to not have any messages: '+ApexPages.getMessages());
			System.assert(returnPage.getUrl().contains(expectedPage.getUrl()), 'We expected to redirected to the correct page. Expected: '+expectedPage.getUrl()+' Actual: '+returnPage.getUrl() );
		}
		Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
		System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_COMPLETE, updatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');

	}

    static testMethod void Test_saveOpportunity_Prospect()
    {
		User PartnerUser = [Select Id, ContactId from user where UserName = 'prospect@gmail.com'];
		contact testcontact = [select Id, Name, AccountId, Email, Transition_Status__c, RecordTypeId, Is_Address1_Primary__c, Is_Address2_Primary__c, OtherCountry, OtherState, MailingStreet, Date_Last_Profile_Updated__c, Record_Type_Name__c from Contact where id = :PartnerUser.ContactId];

		Opportunity testOpp = [Select Id, StageName, KGRenewal__IsActiveCart__c From Opportunity Where KGRenewal__Contact__c = :testcontact.id LIMIT 1];
		System.debug('Stagename: ' + testOpp.StageName + ' KGRenewal__IsActiveCart__c: ' + testOpp.KGRenewal__IsActiveCart__c);
		testOpp.KGRenewal__IsActiveCart__c = true;
		update testOpp;

		System.debug('Contacts recordtype: ' + testcontact.Record_Type_Name__c);
        PageReference expectedPage =  Page.ChooseANetwork_YPO;
        
        System.runAs(PartnerUser) {
			Test.startTest();
				Test.setCurrentPageReference(new PageReference('/apex/UpdateProfileInfoController_YPO'));
				ApexPages.currentPage().getParameters().put('id', testContact.Id);
        
				ApexPages.standardController controller = new ApexPages.standardController(testContact); 
				UpdateProfileInfoController_YPO currentPage = new UpdateProfileInfoController_YPO(controller);
				System.assert(!ApexPages.hasMessages(),'Should not have errored out. \r\n ' + ApexPages.getMessages());

				currentPage.updateLastProfileUpdatedOnContact();
				//Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Id =: testOpp.Id LIMIT 1];
				//System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_IN_PROGRESS, currentPage.relatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');
        
				PageReference returnPage = currentPage.saveOpportunity();
			Test.stopTest();

			System.assert(!ApexPages.hasMessages(),'We expect the page to not have any messages: '+ApexPages.getMessages());

			System.assert(returnPage.getUrl().contains(expectedPage.getUrl()), 'We expected to redirected to the correct page. Expected: '+expectedPage.getUrl()+' Actual: '+returnPage.getUrl() );
        }

		Opportunity updatedOpp = [SELECT Id, Profile_Page_Status_Exchange__c FROM Opportunity WHERE Contact__c = :testcontact.id LIMIT 1];
		System.assertEquals(UpdateProfileInfoController_YPO.PROFILE_STATUS_COMPLETE, updatedOpp.Profile_Page_Status_Exchange__c, 'We expect the correct Profile Status.');

    }

}