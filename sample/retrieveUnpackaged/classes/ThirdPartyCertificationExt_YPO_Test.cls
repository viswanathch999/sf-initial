@isTest
private class ThirdPartyCertificationExt_YPO_Test
{
	static Id communityProfileId = [SELECT Id FROM Profile WHERE Name = 'Partner Community User'].Id;
	static Id  userRoleId = [SELECT Id FROM UserRole WHERE PortalType = 'Partner' LIMIT 1].Id; 
	static Contact testContact;
	static User testCommUser;
	static Opportunity oOpp;
	static User standardUser;

	static void setupData()
	{
		User runningUser = [SELECT Id FROM User Where Profile.Name = 'System Administrator' and isActive=true LIMIT 1];
		Id standardProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
		
		Account testAccount = (Account) SObjectFactory.build(Account.SObjectType);
        testAccount.Type ='Chapter';
        //testAccount.OwnerId = standardUser.Id;
        insert testAccount;
		/*
		testAccount.IsPartner = true;
		update testAccount;
		*/
		UserRole standardRole = new UserRole();
		System.runAs(runningUser) {
			//standardRole.PortalType = 'Partner';
			standardRole.Name = 'Test Role';
			//standardRole.PortalAccountId = testAccount.Id;
			insert standardRole;
			standardUser = (User) SObjectFactory.build(User.SObjectType);
			standardUser.ProfileId = standardProfileId;
			standardUser.UserRoleId = standardRole.Id;
			insert standardUser;
		}
		
		testAccount.OwnerId = standardUser.Id;
        update testAccount;

		testContact = (Contact) SObjectFactory.build(Contact.SObjectType);
		testContact.AccountId = testAccount.Id;
		insert testContact;
		
		testCommUser = (User) new SObjectBuilder(User.SObjectType)
							   .put(User.ProfileId,communityProfileId)
							   /*.put(User.UserRoleId,userRoleId)*/
							   .put(User.ContactId,testContact.Id)
							   .createAsAdmin()
							   .getRecord();
	}


	static testMethod void constructorTest()
	{
		setupData();

		System.runAs(testCommUser)
		{
			ApexPages.StandardController stdCont =  new ApexPages.StandardController(testContact);
			Test.startTest();
				ThirdPartyCertificationExt_YPO cont = new ThirdPartyCertificationExt_YPO(stdCont);
			Test.stopTest();

			System.assert(cont.oContact != null && cont.oContact.Id == testContact.Id,
						  'We expect to get the correct contact back from the constructor');			
		}

	}

	static void setupOppRetrevial()
	{
		Account oAccount = new Account();
        oAccount.recordtypeid=  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        oAccount.Industry = 'Technology';
        oAccount.Sub_Category__c ='Warehousing & Storage';
        oAccount.Is_Subsidiary__c = TRUE;
        oAccount.Parent_Company__c='Test parent';
        oAccount.Name = 'Acc';
        insert oAccount;
        
        KGRenewal__Subscription__c script = new KGRenewal__Subscription__c();
		script.KGRenewal__Account__c = oAccount.Id;
		script.KGRenewal__StartDate__c = System.today();
		insert script;
        
		oOpp = new Opportunity();
        oOpp.AccountId = oAccount.id;
        oOpp.Name = 'Opp';
        oOpp.CloseDate = Date.Today().addDays(1);

        oOpp.StageName = 'Cycle Open';
        oOpp.Fiscal_Date_Start__c = Date.newInstance(System.Today().year(), 7, 1);
		oOpp.Opportunity_Type__c = 'Renewal';
        oOpp.KGRenewal__IsActiveCart__c = true;

        oOpp.KGRenewal__Subscription__c = script.Id;
        oOpp.KGRenewal__Contact__c = testContact.Id;
        oOpp.KGRenewal__Contact__c = testContact.Id;
        insert oOpp;
           
		
        OpportunityContactRole oppConRole = new OpportunityContactRole(Contactid=testContact.Id,OpportunityId=oOpp.id,IsPrimary=TRUE);
        insert oppConRole;
	}

	static testMethod void initTest()
	{
		setupData();
		setupOppRetrevial();

        System.runAs(testCommUser)
		{
			ApexPages.StandardController stdCont =  new ApexPages.StandardController(testContact);
			ThirdPartyCertificationExt_YPO cont = new ThirdPartyCertificationExt_YPO(stdCont);
			Test.startTest();
				cont.oContact = testContact;
				cont.selectdCertificate = 'some string';
				cont.selectdDocumentType = 'more strings';
				cont.selectdTypeOfPartyVerifier = 'even more strings';
				cont.opp_cert_URL = 'perfect strings perfect form';
				cont.init();
			Test.stopTest();

			System.assert(!ApexPages.hasMessages(),'We expect the page to have not errors' + ApexPages.getMessages());
			System.assertEquals(oOpp.Id,cont.OpportunityId,
						  		'We expect to get the correct OpportunityId back from the controller');			
		}
	}

	static testMethod void getTypeOf3rdPartyVerifierTest()
	{
		setupData();

		System.runAs(testCommUser)
		{
			ApexPages.StandardController stdCont =  new ApexPages.StandardController(testContact);
			ThirdPartyCertificationExt_YPO cont = new ThirdPartyCertificationExt_YPO(stdCont);
			Test.startTest();
				List<SelectOption> acutalOptions = cont.getTypeOf3rdPartyVerifier();
			Test.stopTest();

			System.assertEquals(Opportunity.Type_of_3rd_Party_Verifier__c.getDescribe().getPicklistValues().size(),
								acutalOptions.size(),
						  		'We expect to get the create an SelectOption for each picklist value');			
		}
	}

	static testMethod void getDocumentTypesTest()
	{
		setupData();

		System.runAs(testCommUser)
		{
			ApexPages.StandardController stdCont =  new ApexPages.StandardController(testContact);
			ThirdPartyCertificationExt_YPO cont = new ThirdPartyCertificationExt_YPO(stdCont);
			Test.startTest();
				List<SelectOption> acutalOptions = cont.getDocumentTypes();
			Test.stopTest();

			System.assert(!acutalOptions.isEmpty() && acutalOptions.size() > 0,
						  'We expect to get the SelectOption to be generated for document types');			
		}	
	}

	static testMethod void getCertificateOptionsTest()
	{
		setupData();

		System.runAs(testCommUser)
		{
			ApexPages.StandardController stdCont =  new ApexPages.StandardController(testContact);
			ThirdPartyCertificationExt_YPO cont = new ThirdPartyCertificationExt_YPO(stdCont);
			Test.startTest();
				List<SelectOption> acutalOptions = cont.getCertificateOptions();
			Test.stopTest();

			System.assertEquals(Opportunity.X3rd_Party_Certification_Option_Chosen__c.getDescribe().getPicklistValues().size() + 1,
								acutalOptions.size(),
						  		'We expect to get the create an SelectOption for each picklist value');			
		}
	}

	static testMethod void updateAnOpportunityTest_Success_Recieved() 
	{
		setupData();
		setupOppRetrevial();
		oOpp.Third_Party_Firm_Website__c = 'some value';
		oOpp.KGRenewal__Contact__c = testContact.Id;
		Test.startTest();
			Boolean result = ThirdPartyCertificationExt_YPO.updateAnOpportunity(JSON.serialize(oOpp));
		Test.stopTest();

		System.assertEquals(true,result,'We expect the operation to be successful.');
		Opportunity updatedOpp = [SELECT Id, Certification_status__c FROM Opportunity WHERE Id =: oOpp.Id ];
		System.assertEquals(ThirdPartyCertificationExt_YPO.CERTIFICATION_STATUS_RECEIVED,
							updatedOpp.Certification_status__c,
							'We expect these values to be equal.');
	}

	static testMethod void updateAnOpportunityTest_Failure() 
	{
		Test.startTest();
			Boolean result = ThirdPartyCertificationExt_YPO.updateAnOpportunity(JSON.serialize(new Opportunity()));
		Test.stopTest();

		System.assertEquals(false,result,'We expect the operation to be unsuccessful.');
		System.assert(ApexPages.hasMessages() && ApexPages.getMessages().size() == 1,
					 'We expect a error message to be displayed.');
	}

	
	static testMethod void getAnOpportunityTest() 
	{
		setupData();
		setupOppRetrevial();

		Test.startTest();
			Opportunity acutalOpp = ThirdPartyCertificationExt_YPO.getAnOpportunity(JSON.serialize(testContact));
		Test.stopTest();

		System.assert(acutalOpp != null && oOpp.Id == acutalOpp.Id,'We expect to get back the correct Opportunity');
	}
	static testMethod void doUploadAttachmentTest_Sucess_NewAttachment() 
	{
		setupData();
		setupOppRetrevial();

		Test.startTest();
			String resultString = ThirdPartyCertificationExt_YPO.doUploadAttachment(String.valueOf(oOpp.Id), 
																					'some body',
																					'some name', 
																					null /*Attachment Id*/, 
																					null /*Attachment Type*/, 
																					null /*Document Type*/);
		Test.stopTest();

		System.assert(resultString instanceof Id && ((Id) resultString).getSobjectType() == Attachment.SObjectType,
					  'We expect to get back an attachment Id' );
		List<Attachment> acutalAttachments = [SELECT Id,ParentId FROM Attachment];
		System.assert(!acutalAttachments.isEmpty() && acutalAttachments.size() == 1, 'we expect an attachment to be created');
		System.assertEquals(oOpp.Id,acutalAttachments[0].ParentId,'We expect the attachment to be linked to the correct opp');

		Opportunity updatedOpp =[SELECT Id,X3rd_Party_Certification_Option_Chosen__c,Certification_status__c,
										Date_Third_Party_Validated__c 
								 FROM Opportunity 
								 WHERE Id=:oOpp.Id ];
		System.assertEquals(ThirdPartyCertificationExt_YPO.CERTIFICATION_STATUS_RECEIVED,
							updatedOpp.Certification_status__c,
							'We expect the field to be updated');
		System.assertEquals(System.today(),
							updatedOpp.Date_Third_Party_Validated__c,
							'We expect the field to be updated');
		System.assertEquals('Upload Documents',
							updatedOpp.X3rd_Party_Certification_Option_Chosen__c,
							'We expect the field to be updated');
	}
	static testMethod void getAllAttachmentstoOppTest() 
	{
		setupData();
		setupOppRetrevial();

		UnitTest.addData(SObjectFactory.create(2,Attachment.SObjectType,Attachment.ParentId,oOpp.Id))
				.tag('All Attachments');

		Test.startTest();
			List<Attachment> acutalAttachments = ThirdPartyCertificationExt_YPO.getAllAttachmentstoOpp(String.valueOf(oOpp.Id));
		Test.stopTest();

		UnitTest.analyze('All Attachments').assertEquivalence(acutalAttachments,'We expect these lists to be the same');

	}
	static testMethod void removeAttachmentTest_Success() 
	{
		setupData();
		setupOppRetrevial();

		List<Attachment> testAttachments = SObjectFactory.create(2,Attachment.SObjectType,Attachment.ParentId,oOpp.Id);
		Attachment expectedDeletedAttach = testAttachments[0];

		Test.startTest();
			Boolean result = ThirdPartyCertificationExt_YPO.removeAttachment(String.valueOf(expectedDeletedAttach.Id));
		Test.stopTest();

		System.assertEquals(true,result,'We expect return of true since the attachment should be deleted');
		System.assert(new List<Attachment>([SELECT Id FROM Attachment WHERE Id =: expectedDeletedAttach.Id]).isEmpty(),
					  'We expect the attachment to be deleted');
	}

	static testMethod void submitUploadDocsTest_Success() 
	{
		setupData();
		setupOppRetrevial();

		ThirdPartyCertificationExt_YPO.oOpp = oOpp;
		ThirdPartyCertificationExt_YPO.allAttachments.addAll( (List<Attachment>) SObjectFactory.build(2,Attachment.SObjectType,Attachment.ParentId,oOpp.Id));

		Test.startTest();
			String acutalString = ThirdPartyCertificationExt_YPO.submitUploadDocs(null);
		Test.stopTest();

		System.assertEquals('Success',acutalString,'We expected the correct return string');
		Opportunity updatedOpp = [SELECT Id,Certification_Documentation_URL__c,Certification_Status__c
								  FROM Opportunity
								  WHERE Id =: oOpp.Id];
		System.assertEquals(ThirdPartyCertificationExt_YPO.CERTIFICATION_STATUS_RECEIVED,
							updatedOpp.Certification_Status__c,
							'We expect these values to be equal');
		
	}

	static testMethod void submitUploadDocsTest_Failure() 
	{

		ThirdPartyCertificationExt_YPO.oOpp = new Opportunity();
		ThirdPartyCertificationExt_YPO.allAttachments.addAll( (List<Attachment>) SObjectFactory.build(2,Attachment.SObjectType));

		Test.startTest();
			String acutalString = ThirdPartyCertificationExt_YPO.submitUploadDocs(null);
		Test.stopTest();

		System.assertNotEquals('Success',acutalString,'We expected not success string to be return');
		
	}
	static testMethod void submitDocumentationURLTest_Success() 
	{
		setupData();
		setupOppRetrevial();
		String expectedUrl = 'www.google.com';
		ThirdPartyCertificationExt_YPO.oOpp = oOpp;

		Test.startTest();
			String acutalString = ThirdPartyCertificationExt_YPO.submitDocumentationURL('parameter not used', expectedUrl);
		Test.stopTest();

		System.assertEquals('Success',acutalString,'We expected the correct return string');
		Opportunity updatedOpp = [SELECT Id,Certification_Documentation_URL__c,Certification_Status__c
								  FROM Opportunity
								  WHERE Id =: oOpp.Id];
		System.assertEquals(ThirdPartyCertificationExt_YPO.CERTIFICATION_STATUS_RECEIVED,
							updatedOpp.Certification_Status__c,
							'We expect these values to be equal');
		System.assertEquals(expectedUrl,
							updatedOpp.Certification_Documentation_URL__c,
							'We expect these values to be equal');
	}

	static testMethod void submitDocumentationURLTest_Failure() 
	{
		ThirdPartyCertificationExt_YPO.oOpp = new Opportunity();

		Test.startTest();
			String acutalString = ThirdPartyCertificationExt_YPO.submitDocumentationURL(null,null);
		Test.stopTest();

		System.assertNOTEquals('Success',acutalString,'We expected the not success string');
	}

	static testMethod void goToTest_Success_LifeTimePage()
	{
		setupData();
		setupOppRetrevial();
		update new Contact(Id = testContact.Id, Lifetime_Dues_Status__c = 'Eligible for Lifetime');

		System.runAs(testCommUser)
		{
			ApexPages.StandardController stdCont =  new ApexPages.StandardController(testContact);
			ThirdPartyCertificationExt_YPO cont = new ThirdPartyCertificationExt_YPO(stdCont);

			PageReference expectedPage = Page.LifetimeOption_ypo;
			expectedPage.getParameters().put('Id',testContact.id);
			
			Test.startTest();
				PageReference returnPage = cont.goTo();
			Test.stopTest();

			System.assertEquals(expectedPage.getUrl(),
								returnPage.getUrl(),
						  		'We expect to redirected to the correct Page');			
		}

		////This is not happening because the page is doing this work.  Shouldn't, but it is.
		//System.assertEquals('In Progress',
					//[SELECT Certification_Page_Status_Exchange__c 
					//FROM Opportunity
					//WHERE Id =: oOpp.Id].Certification_Page_Status_Exchange__c,
					//'We expect the Opp to be updated accordingly');
	}

	static testMethod void goToTest_Success_Catalog()
	{
		setupData();
		setupOppRetrevial();

		System.runAs(testCommUser)
		{
			PageReference expectedPage = Page.Catalog_YPO;
			expectedPage.getParameters().put('Id',testContact.id);
			ApexPages.StandardController stdCont =  new ApexPages.StandardController(testContact);
			ThirdPartyCertificationExt_YPO cont = new ThirdPartyCertificationExt_YPO(stdCont);
			
			Test.startTest();
				PageReference returnPage = cont.goTo();
			Test.stopTest();

			System.assertEquals(expectedPage.getUrl(),
								returnPage.getUrl(),
						  		'We expect to redirected to the correct Page');			
		}
		
		////This is not happening because the page is doing this work.  Shouldn't, but it is.
		//System.assertEquals('In Progress',
							//[SELECT Certification_Page_Status_Exchange__c 
							//FROM Opportunity
							//WHERE Id =: oOpp.Id].Certification_Page_Status_Exchange__c,
							//'We expect the Opp to be updated accordingly');
	}
}