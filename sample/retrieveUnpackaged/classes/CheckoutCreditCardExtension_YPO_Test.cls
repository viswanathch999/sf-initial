@isTest(seeAllData=true) //seeAllData needed for KG licensing
    public class CheckoutCreditCardExtension_YPO_Test {
    
    static User customer;
    static Contact testContact; 
    static User testUser;
    static User standardUser;
    static Opportunity testOpp;
    static Account testAccount;
    static User runningUser;
    static User runningUser2;
    
    /*
    static void setup() {
        
        // Create a site configuration for Venue
        v_TestUtil.createSiteConfig();
        
        // Create our customer user
        customer = v_TestUtil.createCustomerUser();
        
        update new Contact(Id = customer.ContactId, MailingStreet='testmst', OtherStreet = 'testost');
    }
    
     private static void setupContactForPage()
    {
        User runningUser = [SELECT Id FROM User Where Profile.Name = 'System Administrator' and isActive=true LIMIT 1];
    Id standardProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
    Id communityProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community User(Custom)'].Id;
    Id  userRoleId = [SELECT Id FROM UserRole WHERE PortalType = 'Partner' LIMIT 1].Id;
    
    UserRole standardRole = new UserRole(name = 'TEST ROLE');
    System.runAs(runningUser) {
      insert standardRole;
      standardUser = (User) SObjectFactory.build(User.SObjectType);
      standardUser.ProfileId = standardProfileId;
      standardUser.UserRoleId = standardRole.Id;
      insert standardUser;
    }
    
    Id chapterRecordTypeId = RecordTypeServices.getRecordTypeByName('Chapter', 'Account').Id;
    testAccount = (Account) SObjectFactory.build(Account.SObjectType);
        testAccount.Type ='Chapter';
        testAccount.OwnerId = standardUser.Id;
        testAccount.RecordTypeId = chapterRecordTypeId;
        insert testAccount;
        
    testContact = (Contact) SObjectFactory.build(Contact.SObjectType);
    testContact.AccountId = testAccount.Id;
    insert testContact;
    
    testUser = (User) SObjectFactory.build(User.SObjectType,User.ContactId,testContact.Id);
    testUser.ProfileId = communityProfileId;
    System.debug('###testUser: ' + testUser);
    insert testUser;
    
    KGRenewal__Subscription__c script = new KGRenewal__Subscription__c(KGRenewal__Account__c = testAccount.Id);
    script.KGRenewal__StartDate__c = System.today();
    insert script;
        
    testOpp = (Opportunity) SObjectFactory.build(Opportunity.SObjectType);
    testOpp.Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
    testOpp.KGRenewal__Contact__c = testContact.id;
    testOpp.KGRenewal__IsActiveCart__c = true;
    testOpp.StageName = 'Cycle Open';
    testOpp.KGRenewal__BillingFrequency__c = 'Periodic';
    testOpp.KGRenewal__BillingPeriod__c = 999.0;
    //testOpp.KGRenewal__Subscription__c = script.id;
    testOpp.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member', 'Opportunity').Id;
    
    }
    
    static Contact testContComm;
    static User testUserComm;
    static User standardUser;
    
    static void setupCommunityUserData()
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
    */
    static void setup() {
        
        // have to hard-code this user because of KG license requirements - user must have active license
        runningUser = [SELECT Id, Profile.Name, Email, isActive FROM User WHERE isActive = true AND Alias = 'kine' LIMIT 1];
    	Id standardProfileId = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User'].Id;
    	Id communityProfileId = [SELECT Id, Name FROM Profile WHERE Name = 'Customer Community User(Custom)'].Id;
    	Id userRoleId = [SELECT Id, PortalType FROM UserRole WHERE PortalType = 'Partner' LIMIT 1].Id;
    	
    	system.debug('+++ runningUser: ' + runningUser);
    	system.debug('+++ standardProfileId: ' + standardProfileId);
    	system.debug('+++ communityProfileId: ' + communityProfileId);
    	system.debug('+++ userRoleId: ' + userRoleId);
        
        v_TestUtil.createSiteConfig();
        
        KGRenewal__VenueSettings__c settings = KGRenewal__VenueSettings__c.getOrgDefaults();
        settings.KGRenewal__OpportunityStageOnInsertion__c = 'TEST STAGE';
        upsert settings;
    	
    	UserRole standardRole = new UserRole(Name = 'TEST ROLE');
    	System.runAs(runningUser) { 
    		insert standardRole;
    		standardUser = (User) SObjectFactory.build(User.SObjectType);
    		standardUser.ProfileId = standardProfileId;
    		standardUser.UserRoleId = standardRole.Id;
    		insert standardUser;
    	
        	Account testAccount = (Account) SObjectFactory.build(Account.SObjectType);
        	testAccount.Type ='Chapter';
        	//testAccount.OwnerId = standardUser.Id;
        	insert testAccount;
        	
        	testContact = (Contact) SObjectFactory.build(Contact.SObjectType);
        	testContact.AccountId = testAccount.Id;
        	testContact.RecordType = RecordTypeServices.getRecordTypeByDeveloperName('Member', 'Contact');
			testContact.FirstName = 'Member';
			testContact.LastName = 'Tester';
        	insert testContact;
        	
        	testUser = (User) SObjectFactory.build(User.SObjectType,User.ContactId,testContact.Id);
        	testUser.ProfileId = communityProfileId;
        	System.debug('###testUser: ' + testUser);
			testUser.ContactId = testContact.Id;
        	insert testUser;
        	
        	KGRenewal__Subscription__c script = new KGRenewal__Subscription__c(KGRenewal__Account__c = testAccount.Id);
        	script.KGRenewal__StartDate__c = System.today();
        	insert script;
        	
        	testOpp = TestServices.createOpp('Cycle Open', testAccount.Id, testContact.Id, true);
            testOpp.OwnerId = runningUser.Id;
            testOpp.Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
            testOpp.KGRenewal__IsActiveCart__c = true;
            testOpp.KGRenewal__BillingFrequency__c = 'Periodic';
            testOpp.KGRenewal__BillingPeriod__c = 999.0;
            //testOpp.KGRenewal__Subscription__c = script.id;
            testOpp.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member', 'Opportunity').Id;
			testOpp.KGRenewal__BilledAmount__c = 2300.00;
            update testOpp;
            
        	TestServices.Build_OpportunityLineItem(testOpp.Id);
    	}
    }
    
    
    //updating to create invoice
    @isTest
    public static void testCheckoutExt() {
		setup();
        
		TestServices.createOppLineItems(testOpp.Id,1,'Lifetime Dues',true);

        Test.startTest();
        
		//Address1
		testContact.MailingCountryCode = 'US';
		testContact.MailingStateCode = 'AL';
		testContact.MailingStreet='testmst';
		testContact.MailingCity = 'Atlanta';
		testContact.MailingPostalCode = '83762';
		//Address2
		testContact.OtherCountryCode = 'US';
		testContact.OtherStateCode = 'AL';
        testContact.OtherStreet = 'testost';
		testContact.OtherCity = 'Atlanta';
		testContact.OtherPostalCode = '83762';
		update testContact;

        System.runAs(testUser) {
            
            KGRenewal.VenueCheckoutController ctrl = new KGRenewal.VenueCheckoutController();
            CheckoutCreditCardExtension_YPO ext = new CheckoutCreditCardExtension_YPO(ctrl);
            ext.setProspectOppAsCart();

            List<SelectOption> paymentOptions = ext.paymentOptions;
            System.debug(ext.paymentMode);
            ext.paymentMode='Check/Wire';
    		string VAT = ext.vatNumber;
    		string COMP = ext.CompanyName;
    		string memshipid = ext.MembershipID;
    		String add1type = ext.AddressType1;
    		string add2type = ext.AddressType2;

            // Cover set methods
            ext.selectedOption = 'First';
            ext.setBillingAddress();
            ext.selectedOption = 'Second';
            ext.setBillingAddress();
            ext.selectedOption = 'New';
			ext.conts = new contact(MailingCountryCode = 'US',
					MailingStateCode = 'AL',
					MailingStreet = '243 AnyStreet',
					MailingCity = 'Atlanta',
					MailingPostalCode = '83762');
            ext.setCurrentBillingAddress();
			ext.setCurrentBillingAddresstoMailing();
			ext.setCurrentBillingAddresstoOther();
            ext.newPay();
            boolean successFulTrans = ext.successfulTransExist;
            ext.sendEmail();
            PageReference pr = ext.goBackAction();
        }
    }
    
    @isTest
    public static void testPR() {
		setup();

    	System.runAs(testUser) {
        
            KGRenewal.VenueCheckoutController ctrl = new KGRenewal.VenueCheckoutController();
            CheckoutCreditCardExtension_YPO ext = new CheckoutCreditCardExtension_YPO(ctrl);
            
            PageReference pageRef = Page.Catalog_YPO;
            Test.setCurrentPage(pageRef);
            System.currentPageReference().getParameters().put('lifetime', 'true');
        
            Boolean bool = ext.cameFromLifetimePage;
    	}
    }
    
    @isTest
    public static void testInvoice() {
		setup();
        
        system.runAs(runningUser) {
        	testOpp.StageName = RenewalEntryController.STAGE_PAYMENT_PENDING;
        	testOpp.Probability = 100;
			testOpp.KGRenewal__BilledAmount__c = 100;
            update testOpp;
        }
        
        Id chapterRecordTypeId = RecordTypeServices.getRecordTypeByName('Chapter', 'Account').Id;
    	System.debug('Probability: ' + testOpp.Probability);
    	List<KGRenewal__Invoice__c> inv = [SELECT Id FROM KGRenewal__Invoice__c WHERE KGRenewal__Opportunity__c =: testOpp.id];
    	System.assert(inv.size() > 0, 'We expected to see an invoice created by the Payment Pending');
        
    }
    
	@IsTest
	public static void testCreditCardProcess() {
		setup();

		//Address2
		testContact.OtherCountryCode = 'US';
		testContact.OtherStateCode = 'AL';
        testContact.OtherStreet = 'testost';
		testContact.OtherCity = 'Atlanta';
		testContact.OtherPostalCode = '83762';
		update testContact;

        System.runAs(testUser) {
    		Test.startTest();
    			KGRenewal.VenueCheckoutController ctrl = new KGRenewal.VenueCheckoutController();
                ctrl.cartId = testOpp.id;
                CheckoutCreditCardExtension_YPO ext = new CheckoutCreditCardExtension_YPO(ctrl);

            	ext.toggleGateway();
            	ext.paymentMode='Credit Card';
    			ctrl.paymentcard.cardholderName = testContact.Name;
    			ctrl.paymentcard.cardNumber = '4111111111111111';
    			ctrl.paymentcard.expirationMonth = '01';
    			ctrl.paymentcard.expirationYear = '2018';
            	ext.newPay();
    		Test.stopTest();
    	}
	}

    @isTest
    public static void createCheckoutLogTest() {
    	Test.startTest();
    		CheckoutCreditCardExtension_YPO.createCheckoutLog('test', 'testerson', 'Payment Card');
    	Test.stopTest();
    }
    
    static testmethod void ReviewOrder() {
		setup();

    	System.runAs(testUser){
    		Test.startTest();
    			KGRenewal.VenueCheckoutController ctrl = new KGRenewal.VenueCheckoutController();
    			ctrl.cartId = testOpp.id;
    			CheckoutCreditCardExtension_YPO ext = new CheckoutCreditCardExtension_YPO(ctrl);
    			ext.reviewOrder();
    		Test.stopTest();
    	}
    }
    
    }