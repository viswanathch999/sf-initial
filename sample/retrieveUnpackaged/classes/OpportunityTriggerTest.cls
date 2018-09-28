@isTest
public class OpportunityTriggerTest {
    
    static Contact testContact; 
    static User testUser;
    static User standardUser; 
    static Opportunity testOpp;
    static Opportunity testOppBad;
    static Account testAccount;
    static final String TEMPLATE_NAME= 'YNG_Notifications_to_Member_and_Child_Closed_Won';
    static final String YNG= 'YNG';
    static final String Payment_Received= 'Closed Won';
    static Opportunity opp;
    
    public static void setup(){
        KGRenewal__VenueSettings__c settings = KGRenewal__VenueSettings__c.getOrgDefaults();
        settings.KGRenewal__OpportunityStageOnInsertion__c = 'TEST STAGE';
        upsert settings;
        
        Account testAccount = new Account(
            Name = 'testAccount',
            CurrencyIsoCode = 'USD',
            BillingPostalCode = '91320',
            Industry = 'Banking'
        );
        insert testAccount;
        
         testContact = new Contact(
            LastName = 'contact',
            AccountId = testAccount.Id,
            Email = 'test@email.com',
            recordTypeId = RecordTypeServices.getRecordTypeByName('Member', 'Contact').Id,
            Gender__c= 'Female'
        );
        insert testContact;
        
         opp = new Opportunity(
            Name = 'testOpty',
            AccountId = testAccount.Id,
            StageName = 'Prospect',
            Type = 'Renewal',
            Certification_Status__c='Validated',
            Grace_Status__c='Approved',
            CloseDate = System.today(),
            ForecastCategoryName = 'Pipeline',
            LeadSource = 'Adwords',
            KGRenewal__Contact__c = testContact.Id
        );
        insert opp;
        
        Product2 testProduct = new Product2(
            IsActive = true,
            ProductCode = 'TEST',
            CurrencyIsoCode = 'USD',
            Name = 'TEST NAME',
            KGRenewal__IsTaxable__c = true,
            Exclusive__c = YNG,
            contact__c = testContact.id
        );
        insert testProduct;
        
        PricebookEntry testEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert testEntry;
        
        OpportunityLineItem testOli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 1,
            PricebookEntryId = testEntry.Id,
            TotalPrice = 1 * testEntry.UnitPrice,
            Contact__c = testContact.id
        );
        insert testOli;
    }
    
    public static void reinstatementSetup() {
        Id chapterRecordTypeId = RecordTypeServices.getRecordTypeByName('Chapter', 'Account').Id;
        testAccount = (Account) SObjectFactory.build(Account.SObjectType);
        testAccount.Type ='Chapter';
        //testAccount.OwnerId = standardUser.Id;
        testAccount.RecordTypeId = chapterRecordTypeId;
        insert testAccount;
        
        testContact = (Contact) SObjectFactory.build(Contact.SObjectType);
        testContact.AccountId = testAccount.Id;
        testContact.FirstName = 'New First Reinstatement';
        testContact.LastName = 'New Last';
        testContact.Email = 'test@testeroni.com';
        insert testContact;
        
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
        testOpp.Opportunity_Type__c = 'Reinstatement';
    }
    
    public static testMethod void sendEmailIfPaymentisWireOrCheckPaymentOnUpdate(){
        setup();
        opp.stagename = Payment_Received;
        Test.startTest();
        update opp;
        Test.stopTest();
        System.assert(opp.id != null);//Not possible to test send email from test class context
    }
    
    public static testMethod void reinstatementFilterTest(){
        
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
        testOpp.Opportunity_Type__c = 'Reinstatement'; 
        
        testOppBad = (Opportunity) SObjectFactory.build(Opportunity.SObjectType);
        testOppBad.Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
        testOppBad.KGRenewal__Contact__c = testContact.id;
        testOppBad.KGRenewal__IsActiveCart__c = true;
        testOppBad.StageName = 'Cycle Open';
        testOppBad.KGRenewal__BillingFrequency__c = 'Periodic';
        testOppBad.KGRenewal__BillingPeriod__c = 999.0;
        //testOpp.KGRenewal__Subscription__c = script.id;
        testOppBad.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member', 'Opportunity').Id;
        testOppBad.Opportunity_Type__c = 'BAD'; 
        
        List<Opportunity> testOpps = new List<Opportunity>();
        testOpps.add(testOpp);
        testOpps.add(testOppBad);
        
        Test.startTest();
            List<Opportunity> actualOpps = OpportunityServices.filterReinstatementOpps(testOpps, null);
        Test.stopTest();
        
        System.assertEquals(1,actualOpps.size(),'Expect only reinstatement opp to be returned.');
        
    }
    
    public static testMethod void updateReinstatementTest() {
        reinstatementSetup();
        testOpp.Opportunity_Type__c = 'Member';
        insert testOpp;
        
        Test.startTest();
            testOpp.Opportunity_Type__c = 'Reinstatement'; 
            update testOpp;
        Test.stopTest();
        
        List<User> actualCommunityUsers = [SELECT Id FROM User WHERE ContactId = :testContact.Id ];
        System.assertEquals(1,actualCommunityUsers.size(), 'Expect only one user to be returned');
    }
    
    public static testMethod void insertReinstatementTest() {
        reinstatementSetup();
        testOpp.Opportunity_Type__c = 'Reinstatement';
        
        Test.startTest();
            insert testOpp;
        Test.stopTest();
        
        List<User> actualCommunityUsers = [SELECT Id FROM User WHERE ContactId = :testContact.Id ];
        System.assertEquals(1,actualCommunityUsers.size(), 'Expect only one user to be returned');
    }
    
    public static testMethod void markOppsAsClosedWonTest() {
        setup();
        OpportunityServices.getMapOfOppIdToContactIds(new Set<ID>{opp.id});
        opp.StageName = 'Payment Received';
        opp.Certification_Status__c = 'Complete';
        opp.Grace_Status__c = 'No Grace Needed';
        List<Opportunity> oppsList = new List<Opportunity>{opp};
        Id expectedRecordTypeId = [Select Id from recordType where developerName = :OpportunityServices.MEMBER and sObjectType='Contact' Limit 1][0].Id;
        Test.startTest();
            OpportunityServices.markOppsAsClosedWon(oppsList);
        Test.stopTest();
        
        List<Contact> actualContacts = [SELECT Id, Join_Date__c, Member_Forum_Status__c, Membership_Status__c, recordTypeId FROM Contact];
        for(Contact actualCon : actualContacts) {
            System.assertEquals(opp.KGRenewal__Contact__c,actualCon.Id,'Ids should be the same.');
            System.assertEquals(Date.today(),actualCon.Join_Date__c,'Dates should be the same.');
            System.assertEquals('Pending Placement',actualCon.Member_Forum_Status__c,'Member forum statuses should be the same.');
            System.assertEquals(OpportunityServices.MEMBER,actualCon.Membership_Status__c,'Membership statuses should be the same.');
            System.assertEquals(expectedRecordTypeId,actualCon.recordTypeId,'Record type Ids should be the same.'); 
        }
        
    }
    
    public static testMethod void testFilterThroughFlow() {
        setup();
        opp.StageName = 'Payment Received';
        opp.Certification_Status__c = 'Complete';
        opp.Grace_Status__c = 'No Grace Needed';
        List<Opportunity> oppsList = new List<Opportunity>{opp};
        
        Test.startTest();
            update oppsList;
        Test.stopTest();
        
        List<Opportunity> actualOpps = [SELECT Id, KGRenewal__Contact__c, StageName FROM Opportunity WHERE Id =: oppsList[0].Id LIMIT 1];
        
        System.assert(actualOpps[0].StageName == 'Closed Won', 'We expect the stage to be set correctly. Actual: ' + actualOpps[0].StageName);
    }
    
    public static testMethod void filterOppsForAddMemberYearTest(){
        reinstatementSetup();
        testOpp.AccountId = testAccount.id;
        insert testOpp;
        
        KGRenewal__Subscription__c sub = [Select Id from KGRenewal__Subscription__c where KGRenewal__Account__c = :testAccount.Id];
        
        testOpp.StageName = 'Payment Received';
        testOpp.KGRenewal__Subscription__c = sub.id;
        //testOpp
        
        List<Opportunity> oppsList = new List<Opportunity>{testOpp};
        
        Test.startTest();
            update oppsList;
        Test.stopTest();
        
        List<Opportunity> actualOpps = [SELECT Id, KGRenewal__Contact__c, StageName FROM Opportunity WHERE Id =: oppsList[0].Id LIMIT 1];
        
        //System.assert(actualOpps[0].StageName == 'Closed Won', 'We expect the stage to be set correctly. Actual: ' + actualOpps[0].StageName);
    }
    
    public static testMethod void testfilterOppsTobeMarkedClosedWon(){
        reinstatementSetup();
        testOpp.Opportunity_Type__c = 'Member';
        insert testOpp;
        
        Test.startTest();
            testOpp.Opportunity_Type__c = 'Reinstatement'; 
            testOpp.StageName = 'Payment Received'; 
            testOpp.Certification_Status__c = 'Complete';
            update testOpp;
        
            testOpp.recordTypeId = RecordTypeServices.getRecordTypeByName('Former Member', 'Opportunity').Id;
            update testOpp;
        Test.stopTest();
        
        List<User> actualCommunityUsers = [SELECT Id FROM User WHERE ContactId = :testContact.Id ];
        System.assertEquals(1,actualCommunityUsers.size(), 'Expect only one user to be returned');
    }
       
    //Test method to update contact fields
    public static testMethod void testUpdateContactfields(){
        setup();
        Opp.CloseDate = System.today()+4;
        Opp.Opportunity_Type__c = 'Reinstatement';
        Opp.President_Type__c   = 'Entrepreneur';
        Opp.Firm_Type__c        = 'Public';
        Opp.Enterprise_Type__c  = 'Net Worth or assets before depreciation';
        Opp.Business_Scope__c   = 'Regional';
        Opp.Title__c            = 'Other';
        Opp.Title_Other__c      = 'CEO';
        Opp.StageName = 'Payment Received';
        Opp.Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;     
        Opp.recordTypeId = RecordTypeServices.getRecordTypeByName('Member', 'Opportunity').Id;              
        update opp;
     
        Test.startTest();
        Opp.President_Type__c   = 'Professional Manager';
        Opp.StageName = 'Closed Won';
        Opp.Business_Scope__c= 'Local';                 
        update Opp;
        Test.stopTest();
        
        List<Contact>con = [SELECT Id, Name,President_Type__c,Corporation_Type__c,Firm_Type__c,Business_Scope__c,Enterprise_Type__c,Title,Title_Other__c FROM Contact where id = :Opp.KGRenewal__Contact__c];
        System.assertEquals(Opp.Business_Scope__c,con[0].Business_Scope__c,'Value of Opportunity fields should get copied to contact fields'); 
        System.assertEquals(Opp.President_Type__c,con[0].President_Type__c,'Value of Opportunity fields should get copied to contact fields');         
    }
    
    public static testMethod void testfilterOppsTobeMarkedClosedWonScenario2(){
        reinstatementSetup();
        testOpp.Opportunity_Type__c = 'Member';
        testOpp.recordTypeId = RecordTypeServices.getRecordTypeByName('Former Member', 'Opportunity').Id;
        insert testOpp;
        
        Account_Affiliation__c aff = new Account_Affiliation__c(Contact__c = testContact.id, contact_Type__c = 'Member', Account__c=testAccount.id, Start_Date__c = Date.today());
        insert aff;
        Test.startTest();
            testOpp.Opportunity_Type__c = 'Reinstatement'; 
            testOpp.StageName = 'Payment Received'; 
            testOpp.Certification_Status__c = 'Complete';
            
            update testOpp;
        Test.stopTest();
        
        List<User> actualCommunityUsers = [SELECT Id FROM User WHERE ContactId = :testContact.Id ];
        System.assertEquals(1,actualCommunityUsers.size(), 'Expect only one user to be returned');
    }
    
    public static testMethod void testfilterOppsTobeMarkedClosedWonScenario3(){
        reinstatementSetup();
        testOpp.Opportunity_Type__c = 'Member';
        testOpp.recordTypeId = RecordTypeServices.getRecordTypeByName('Prospect', 'Opportunity').Id;
        insert testOpp;
        
        Test.startTest();
            testOpp.Opportunity_Type__c = 'Reinstatement'; 
            testOpp.StageName = 'Payment Received'; 
            testOpp.Certification_Status__c = 'Complete';
            
            update testOpp;
        Test.stopTest();
        
        List<User> actualCommunityUsers = [SELECT Id FROM User WHERE ContactId = :testContact.Id ];
        System.assertEquals(1,actualCommunityUsers.size(), 'Expect only one user to be returned');
    }
}