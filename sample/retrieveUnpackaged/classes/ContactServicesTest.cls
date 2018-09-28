@isTest
private class ContactServicesTest{
    static User testUser;
    static User standardUser;
    
    @TestSetup static void setupData(){        
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

		Account oAccount = New Account();
        oAccount.recordtypeid=  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        oAccount.Industry = 'Technology';
        oAccount.Sub_Category__c ='Warehousing & Storage';
        oAccount.Is_Subsidiary__c = TRUE;
        oAccount.Parent_Company__c='Test parent';
        oAccount.Name = 'Acc';
        oAccount.Type = 'Business';
        insert oAccount;
        
        Contact oContact = new Contact();
        oContact.AccountId = testAccount.Id;
        oContact.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member','Contact').Id;
        //oContact = (Contact)JSONUtils.setField(oContact, 'Record_Type_Name__c', 'Member');
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
        oContact.HouseholdID__c = string.valueOf(oAccount.id);
        insert oContact; 
        
        testUser = (User) SObjectFactory.build(User.SObjectType,User.ContactId,oContact.Id);
        testUser.ProfileId = communityProfileId;

        insert testUser;
        
    }

    @isTest static void graceUsedTestPositive(){
		Contact testContact = [select id, Grace_Years_Available__c, Grace_Years_Used__c from Contact LIMIT 1];
        testContact = (Contact)JSONUtils.setField(testContact, 'Grace_Years_Available__c', 3);
        testContact = (Contact)JSONUtils.setField(testContact, 'Grace_Years_Used__c' ,4);

        Test.startTest();
            Boolean checkForGrace = ContactServices.isGraceAvailable(testContact);
        Test.stopTest();

        //system.assertEquals(true, checkForGrace,'It should return true since the grace values are greater than 0' );


    }

    @isTest static void graceUsedTestNegative(){
		Contact testContact = [select id, Grace_Years_Available__c, Grace_Years_Used__c from Contact LIMIT 1];
        testContact = (Contact)JSONUtils.setField(testContact, 'Grace_Years_Available__c', 0);
        testContact = (Contact)JSONUtils.setField(testContact, 'Grace_Years_Used__c' ,0);
        
        Test.startTest();
            Boolean checkForGrace = ContactServices.isGraceAvailable(testContact);
        Test.stopTest();

        //system.assertEquals(false, checkForGrace,'It should return false since the grace values is 0' );



    }

    @isTest static void testStateCode() {
        String stCodeVal = '';
        Test.startTest();
            stCodeVal = ContactServices.getStateCodeValue('Florida');
        Test.stopTest();
        
        System.assert(stCodeVal != null, 'We expect the state code to be populated.');
    }
    
    @isTest static void testCountryCode() {
        String countryCodeVal = '';
        Test.startTest();
            countryCodeVal = ContactServices.getCountryCodeValue('Algeria');
        Test.stopTest();
        
        System.assert(countryCodeVal != null, 'We expect the state code to be populated.');
    }
    
    @isTest static void testPrevOpp() {
		Contact testContact = [select id, RecordTypeId from Contact LIMIT 1];

        Account oAccount = new Account();
        oAccount.recordtypeid=  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
       // oAccount.Firm_Type__c ='Public';
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
        
        Opportunity oOpp = new Opportunity();
        oOpp.AccountId = oAccount.id;
        oOpp.Qualifying_Company__c='Test Company';
        oOpp.Organization_Type__c ='Sales';
        oOpp.AnnualRevenue__c =4;
        oOpp.Total_Employee_Compensation__c = 2;
        oOpp.NumberOfEmployees__c = 1;
        oOpp.Enterprise_Value__c = 5;
        oOpp.Title__c ='Other';
        oOpp.Title_Other__c ='xyz';
        oOpp.Birthdate__c = Date.today().addyears(-20);
        oOpp.President_Type__c ='Owner';
        oOpp.Business_Scope__c = 'National';
        oOpp.Business_Description__c = 'Test Description';
        oOpp.Transition_Via_Renewal_Form__c = TRUE;
        oOpp.Third_Party_Firm__c = 'Test Firm';
        oOpp.Third_Party_Name__c = 'Test Third Party';
        oOpp.Third_Party_Email__c ='test@example.com';
        oOpp.Chapter_Membership_Officer__c = userinfo.getUserId();
        oOpp.Name = 'Opp';
        oOpp.CloseDate = Date.Today().addDays(1);
        oOpp.StageName = 'Cycle Open';
		oOpp.Opportunity_Type__c = 'Renewal';
        oOpp.Fiscal_Date_Start__c = Date.newInstance(System.Today().year(), 7, 1);
        oOpp.KGRenewal__Subscription__c = script.Id;
        oOpp.KGRenewal__Contact__c = testContact.Id;
        oOpp.KGRenewal__IsActiveCart__c = true;
        insert oOpp;
        
        OpportunityContactRole oppConRole = new OpportunityContactRole(Contactid=testContact.id,OpportunityId=oOpp.id,IsPrimary=TRUE);
        insert oppConRole;

        oOpp = new Opportunity();
        oOpp.AccountId = oAccount.id;
        oOpp.Qualifying_Company__c='Test Company';
        oOpp.Organization_Type__c ='Sales';
        oOpp.AnnualRevenue__c =4;
        oOpp.Total_Employee_Compensation__c = 2;
        oOpp.NumberOfEmployees__c = 1;
        oOpp.Enterprise_Value__c = 5;
        oOpp.Title__c ='Other';
        oOpp.Title_Other__c ='xyz';
        oOpp.Birthdate__c = Date.today().addyears(-20);
        oOpp.President_Type__c ='Owner';
        oOpp.Business_Scope__c = 'National';
        oOpp.Business_Description__c = 'Test Description';
        oOpp.Transition_Via_Renewal_Form__c = TRUE;
        oOpp.Third_Party_Firm__c = 'Test Firm';
        oOpp.Third_Party_Name__c = 'Test Third Party';
        oOpp.Third_Party_Email__c ='test@example.com';
        oOpp.Chapter_Membership_Officer__c = userinfo.getUserId();
        oOpp.Name = 'Opp';
        oOpp.CloseDate = Date.Today().addDays(1);
        oOpp.StageName = 'Closed Won';
        oOpp.Fiscal_Date_Start__c = Date.newInstance(System.Today().year() - 1, 7, 1);
        oOpp.KGRenewal__Subscription__c = script.Id;
        oOpp.KGRenewal__Contact__c = testContact.Id;
        oOpp.KGRenewal__IsActiveCart__c = false;
        insert oOpp;
        
        oppConRole = new OpportunityContactRole(Contactid=testContact.id,OpportunityId=oOpp.id,IsPrimary=TRUE);
        insert oppConRole;
        
        Opportunity opp;
        Test.startTest();
            opp = ContactServices.getPreviousOpportunity(testContact);
			System.assert(opp <> null, 'Unable to find the previous years opportunity');

            opp = ContactServices.getOpportunities(testContact);
            System.assert(opp <> null, 'Unable to find the next fiscal years opportunity');
        Test.stopTest();
    }
    
    @isTest
    static void testCAShares() {
		
        Id standardProfileId2 = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
        User standardUser2 = [Select id from user where ProfileId =: standardProfileId2 limit 1];

        Account oAccount1 = [Select recordtypeid, Industry, Sub_Category__c, Is_Subsidiary__c, Parent_Company__c, Name, Type from Account where Name = 'Acc' LIMIT 1];
        
		List<Account> ListAccount = new List<Account>();
        Account oAccount = new Account();
        oAccount.recordtypeid=  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        oAccount.Industry = 'Business';
        oAccount.Sub_Category__c ='Warehousing & Storage';
        oAccount.Is_Subsidiary__c = TRUE;
        oAccount.Parent_Company__c='Test parent';
        oAccount.Name = 'Acc2';
        ListAccount.add(oAccount);
                
        oAccount = (Account) SObjectFactory.build(Account.SObjectType);
        oAccount.Type ='Chapter';
        oAccount.OwnerId = standardUser2.Id;
        oAccount.Type = 'Relationship';
        oAccount.Name = 'Acc3';
		ListAccount.add(oAccount);
        
        oAccount = (Account) SObjectFactory.build(Account.SObjectType);
        oAccount.OwnerId = standardUser2.Id;
        oAccount.Type = 'Business';
        oAccount.Name = 'Acc4';
        ListAccount.add(oAccount);
		
		insert ListAccount;
        
		//Add new contacts via list
		List<Contact> Contactlist = new List<Contact>();
        Contact oContact = new Contact();
        oContact.AccountId = ListAccount[0].Id;
        oContact.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member','Contact').Id;
        //oContact = (Contact)JSONUtils.setField(oContact, 'Record_Type_Name__c', 'Member');
        oContact.lastname = 'Test Member Contact2';
        oContact.YPO_WPO__c = 'YPO';
        oContact.Transition_Status__c =  'Eligible for early transition';
        //oContact.Grace_Years_Accrued__c = 10;
        oContact.Grace_Accrued_FY17__c = 10;
        oContact.Is_Grace_Used__c = FALSE;
        oContact.Date_Last_Grace_Year_Used__c = Date.newInstance(System.Today().year(), 8, 1);
        oContact.Join_date__c = Date.newInstance(2000, 1, 1);
		oContact.Email = 'TestMemberContact2@ypo.org.test';
		oContact.GUID__c = '54s654f456s4';
        Contactlist.add(oContact);
        
        oContact = new Contact();
        oContact.AccountId = ListAccount[0].Id;
        oContact.RecordTypeId = RecordTypeServices.getRecordTypeByName('Child','Contact').Id;
        //oContact = (Contact)JSONUtils.setField(oContact, 'Record_Type_Name__c', 'Member');
        oContact.lastname = 'Test Member Contact3';
        oContact.YPO_WPO__c = 'YPO';
        oContact.Transition_Status__c =  'Eligible for early transition';
        //oContact.Grace_Years_Accrued__c = 10;
        oContact.Grace_Accrued_FY17__c = 10;
        oContact.Is_Grace_Used__c = FALSE;
        oContact.Date_Last_Grace_Year_Used__c = Date.newInstance(System.Today().year(), 8, 1);
        oContact.Join_date__c = Date.newInstance(2000, 1, 1);
		Contactlist.add(oContact);
        
        oContact = (Contact) SObjectFactory.build(Contact.SObjectType);
        oContact.AccountId = ListAccount[1].id;
        Contactlist.add(oContact);
        
		insert Contactlist; 
        
		//Retrieve the contact added in Setup.
		oContact = [Select id, AccountId, RecordType.DeveloperName, Number_of_Employees__c, Join_date__c, 
			Number_of_Employees_Opt_2__c, Total_Employee_Compensation__c, Annual_Revenue__c, Annual_Fees__c, 
			Annual_Assets__c, Transition_Status__c, HouseholdID__c
			From Contact Where lastname = 'Test Member Contact' limit 1];

        Contact_Share_Settings__c css = new Contact_Share_Settings__c();
        css.CA_Access_Level__c = 'Edit';
        css.Contact_RecordType_DeveloperName__c = 'Member';
        css.Name = 'Chapter Administrator';
        insert css;
        
        User runningUser2 = [SELECT Id FROM User Where Profile.Name = 'System Administrator' and isActive=true LIMIT 1];
        Id communityProfileId2 = [SELECT Id FROM Profile WHERE Name = 'Partner Community User'].Id;
        
        CA_Setting__c caSet = new CA_Setting__c();
        caSet.Chapter__c = ListAccount[0].Id;
        caSet.isActive__c = true;
        caSet.Role__c = 'Chapter Administrator';
        caSet.User__c = standardUser2.id;
        insert caSet;
        
        User testUser3 = (User) SObjectFactory.build(User.SObjectType,User.ContactId,oContact.Id);
        testUser3.ProfileId = communityProfileId2;
        
        Opportunity testOpp = (Opportunity) SObjectFactory.build(Opportunity.SObjectType);
        //testOpp.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member','Opportunity').Id;
        testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        testOpp.Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
        testOpp.NumberOfEmployees__c = 100;
        testOpp.Enterprise_Value__c = 100;
        testOpp.AnnualRevenue__c = 100;
        testOpp.NumberOfEmployees__c = 100;
        testOpp.Organization_Type__c = 'Agency-Type';
        testOpp.KGRenewal__Contact__c = oContact.Id;
        insert testOpp;
        
        Account_Affiliation__c aff = new Account_Affiliation__c();
        aff.Contact__c = oContact.Id;
        aff.IsActive__c = true;
        aff.RecordTypeId =  RecordTypeServices.getRecordTypeByName('Business','Account_Affiliation__c').Id;
        aff.Account__c = oAccount.Id;
        aff.Start_Date__c = FiscalDateUtility.startOfNextFiscal;
        insert aff;
        //Account__r.Firm_Type__c,
        List<Account_Affiliation__c> lstAccAff = [SELECT Id, Account__c,  Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity,Account__r.BillingState, Account__r.BillingCountry,Account__r.BillingPostalCode,Account__r.BillingStateCode, Account__r.BillingCountryCode,Account__r.BillingLatitude, Account__r.BillingLongitude, Account__r.Industry, Account__r.Phone,Account__r.Website FROM Account_Affiliation__c WHERE Contact__c = :oContact.Id AND Account_Type__c = 'Business' AND IsActive__c = true AND RecordType.Name = 'Business' LIMIT 1];
        
        system.debug('rehan ' + lstAccAff);
        
        Map<Id, Id> contactToChapter = new Map<Id, Id>();
        contactToChapter.put(oContact.Id, ListAccount[0].Id);
        String ccValue;
        String scValue;
        List<User> commUser;
        Boolean isQualified;
        String testStr;
        Boolean testBool;
        Boolean isGrace;
        Boolean isGraceExt;
        Boolean waiver;
        
        List<Contact> testConts = new List<Contact>();
        
        ContactServices cs = new ContactServices();

        Test.startTest();
            
            Relationship__c rel = new Relationship__c(Is_Active__c = true, Contact__c = Contactlist[1].id, Account__c = ListAccount[1].id);
            insert rel;

            ContactServices.rtToAccess = new Map<String, String> { 'Member' => 'Edit' };

            cs.createContactShareRecordEdit(new List<Contact>{oContact}, true);
            cs.deleteContactShares(contactToChapter, new List<Contact>{oContact});
            cs.createContactShareRecords(new List<Contact>{oContact}, true);
            
            ContactServices.rtToAccess = null;
            List<Contact_Share_Settings__c> sa = [Select Id, Contact_RecordType_DeveloperName__c, CA_Access_Level__c from Contact_Share_Settings__c where Contact_RecordType_DeveloperName__c = 'Member'];
            for(Contact_Share_Settings__c sass : sa){
                sass.CA_Access_Level__c = 'None';
            }
            update sa;

            cs.createContactShareRecordEdit(new List<Contact>{oContact}, true);
            cs.createContactShareRecords(new List<Contact>{oContact}, true);
            
            ccValue = ContactServices.getCountryCodeValue('Algeria');
            scValue = ContactServices.getStateCodeValue('Georgia');
            commUser = ContactServices.createCommunityUserForContact(new List<Contact>{Contactlist[0]});
            ContactServices.insertCommunityUsers(new List<User>{testUser3}, new Map<Id, Contact>{oContact.Id => oContact});
            isQualified = ContactServices.isQualified(oContact, testOpp, 'Prev');
            ContactServices.getAssociatedAccount(oContact);
            ContactServices.createRelationship(Contactlist[1].id,ListAccount[2].id,'Business');
            testStr = ContactServices.CONST_CONTACT;
            testStr = ContactServices.CONST_OPPORTUNITY;
            testStr = ContactServices.CONST_SPOUSE;
            testStr = ContactServices.CONST_CHILD;
            testStr = ContactServices.CONST_MEMBER;
            testStr = ContactServices.CONST_PROSPECT;
            testStr = ContactServices.CONST_EXCEPTION;
            testStr = ContactServices.CONST_WAIVER;
            testBool = ContactServices.isTransitionAvailable(oContact);
            testConts = ContactServices.getChildrenAndSpouse(oContact);
            isGrace = ContactServices.isGraceAvailable(Contactlist[2]);
            isGraceExt = ContactServices.isGraceExtension(Contactlist[2]);
            waiver = ContactServices.isWaiver(Contactlist[2]);
            ContactServices.getRelationship(Contactlist[2]);
            ContactServices.isJoinDateInThirdQuarter(Contactlist[2]);
            ContactServices.deleteContactSharesFuture(new Set<Id>{Contactlist[2].Id});
            cs.createContactSharesPB(new List<Id>{Contactlist[2].Id});
            
        Test.stopTest();
    }
}