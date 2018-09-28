@isTest
private class AccountAffiliationTriggerTest{
    
    public static Contact testContact;
    public static Account testAccount1,testAccount2;
    public static Account_Affiliation__c testAccAff1,testAccAff2;
    public static Id chapterId;
    public final static Integer HI_COUNT = 10;
    //public static Id networkRecordTypeId;
    
    static void setup(){
        insert new Profile_Completion_Criteria__c(Name = 'Initial Criteria', Primary_Address__c = 1, External_Connection__c = 1);
        
        Account mockRegion = TestServices.createAccount('Test Region Chapter');
        mockRegion.Type = 'Region';
        mockRegion.RecordTypeId = RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        insert mockRegion;
        
        testAccount1 = TestServices.createAccount('Test Account Name');
        testAccount1.Type = 'Chapter';
        testAccount1.RecordTypeId =  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        testAccount1.ParentId = mockRegion.Id; 
        insert testAccount1;
        
        testAccount2 = TestServices.createAccount('Test Account Name 2');
        testAccount2.Type = 'Forum';
        testAccount2.RecordTypeId =  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id; 
        testAccount2.Chapter_Network_Exception__c = true;
        insert testAccount2;
        
        testContact = TestServices.createContact('Test Last Name', testAccount1.Id);
        insert testContact;
        chapterId =  RecordTypeServices.getRecordTypeByName('Chapter','Account_Affiliation__c').Id;        
    }
    static void setupAffiliations(){
        insert new Profile_Completion_Criteria__c(Name = 'Initial Criteria', Primary_Address__c = 1, External_Connection__c = 1);
        
        UnitTest.addData(SObjectFactory.build(HI_COUNT, Account.SObjectType))
                .property('Type').assign('Relationship')
                .property('RecordTypeId').assign(RecordTypeServices.getRecordTypeByName('Relationship','Account').Id)
                .tag('All Accounts')
                .tag('Relationship Accounts');
                
        UnitTest.addData(SObjectFactory.build(HI_COUNT, Account.SObjectType))
                .property('RecordTypeId').assign(RecordTypeServices.getRecordTypeByName('Chapter','Account').Id)
                .tag('All Accounts')
                .tag('Chapter Accounts');
        
        UnitTest.addData(SObjectFactory.build(HI_COUNT, Account.SObjectType))
                .property('RecordTypeId').assign(RecordTypeServices.getRecordTypeByName('Network','Account').Id)
                .tag('All Accounts')
                .tag('Network Accounts');
                
        UnitTest.get('All Accounts').insertAll();
        
        UnitTest.addData(SObjectFactory.build(HI_COUNT, Contact.SObjectType))
                .property('AccountId').assignFrom('Chapter Accounts')
                .property('RecordTypeId').assign(RecordTypeServices.getRecordTypeByName(AccountAffiliationServices.MEMBER, 'Contact').Id)
                .property('Is_Spouse_Member__c').assign(false)
                .tag('All Contacts')
                .tag('Member Contacts');
        
        UnitTest.addData(SObjectFactory.build(HI_COUNT, Contact.SObjectType))
                .property('AccountId').assignFrom('Network Accounts')
                .property('RecordTypeId').assign(RecordTypeServices.getRecordTypeByName(AccountAffiliationServices.MEMBER, 'Contact').Id)
                .property('Is_Spouse_Member__c').assign(false)
                .tag('All Contacts')
                .tag('Network Contacts');
                        
        UnitTest.addData(SObjectFactory.build(HI_COUNT, Contact.SObjectType))
                .property('Is_Spouse_Member__c').assign(false)
                .property('AccountId').assignFrom('Chapter Accounts')
                .property('RecordTypeId').assign(RecordTypeServices.getRecordTypeByName('Spouse/Partner', 'Contact').Id)
                .tag('All Contacts')
                .tag('Spouse Partner Contacts');
        
        UnitTest.get('All Contacts').insertAll();
        
        UnitTest.addData(SObjectFactory.build(HI_COUNT, Relationship__c.SObjectType))
                .property('Relationship_Type__c').assign('Spouse/Partner')
                .property('Account__c').assignFrom('Relationship Accounts')
                .property('Contact__c').assignFrom('Spouse Partner Contacts')
                .tag('All Relationships')
                .tag('Spouse Relationships');
                
        UnitTest.addData(SObjectFactory.build(HI_COUNT, Relationship__c.SObjectType))
                .property('Relationship_Type__c').assign('Spouse/Partner')
                .property('Account__c').assignFrom('Relationship Accounts')
                .property('Contact__c').assignFrom('Network Contacts')
                .tag('All Relationships')   
                .tag('Network Relationships');  
        
        UnitTest.addData(SObjectFactory.build(HI_COUNT, Relationship__c.SObjectType))
                .property('Relationship_Type__c').assign('Member')
                .property('Account__c').assignFrom('Relationship Accounts')
                .property('Contact__c').assignFrom('Member Contacts')
                .tag('All Relationships')   
                .tag('Member Relationships');
    
        UnitTest.get('All Relationships').insertAll();
                        
        UnitTest.addData(SObjectFactory.build(HI_COUNT, Account_Affiliation__c.SObjectType))
                .tag('All Account Affiliations')
                .branch('Member Account Affiliations|Spouse Partner Account Affiliations|Network Account Affiliations');
        
        UnitTest.get('Network Account Affiliations')
                .property('isActive__c').assign(true)
                .property('is_Primary__c').assign(true)
                .property('Start_Date__c').assign(Date.Today())
                //.property('End_Date__c').assign(Date.Today().addDays(25))
                //.property('Reason_for_Leaving__c').assign('Expelled')
                //.property('Reason_Leaving_Other__c').assign('Not Dead')
                .property('Account__c').assignFrom('Network Accounts')
                .property('Contact__c').assignFrom('Network Contacts')
                .property('RecordTypeId').assign(RecordTypeServices.getRecordTypeByName('Network', 'Account_Affiliation__c').Id);
        
        UnitTest.get('Member Account Affiliations')
                .property('An_Affiliate__c').assign('Member Affiliations')
                .property('Start_Date__c').assign(Date.Today())
                .property('IsActive__c').assign(false)
                .property('Is_Primary__c').assign(false)
                .property('Transfer_Flag__c').assign('Renewal Transition')
                //.property('End_Date__c').assign(Date.Today().addDays(25))
                //.property('Reason_for_Leaving__c').assign('Expelled')
                //.property('Reason_Leaving_Other__c').assign('Not Dead')
                .property('Account__c').assignFrom('Chapter Accounts')
                .property('Contact__c').assignFrom('Member Contacts')
                .property('RecordTypeId').assign(RelationshipServices.chapterAccAffRTId);
        
        UnitTest.get('Spouse Partner Account Affiliations')
                .property('An_Affiliate__c').assign('Spouse Affiliations')
                .property('Start_Date__c').assign(Date.Today())
                .property('IsActive__c').assign(true)
                .property('Is_Primary__c').assign(true)
                .property('Transfer_Flag__c').assign('Off-Cycle Transition')
                //.property('End_Date__c').assign(Date.Today().addDays(35))
                //.property('Reason_for_Leaving__c').assign('Deceased')
                //.property('Reason_Leaving_Other__c').assign('Super Dead')
                .property('Account__c').assignFrom('Chapter Accounts')
                .property('Contact__c').assignFrom('Spouse Partner Contacts');
                
        UnitTest.get('All Account Affiliations').insertAll();
    }
    static testMethod void testFilterAccAffsForSync(){
        setupAffiliations();
        
        Map<Id, Account_Affiliation__c> testOldAffiliationsMap = new Map<Id, Account_Affiliation__c>((List<Account_Affiliation__c>) UnitTest.get('All Account Affiliations').getList().deepClone(true, true, true));
        
        Set<Id> newAffIds = Pluck.Ids('Id', UnitTest.get('Member Account Affiliations').getList());
        
        List<Account_Affiliation__c> testNewAffiliations = [SELECT Id, Contact_Record_Type_Name__c, RecordTypeId FROM Account_Affiliation__c WHERE Id IN: newAffIds];
        
        for(Account_Affiliation__c eachAff : testNewAffiliations){
            eachAff.IsActive__c = true;
            eachAff.Is_Primary__c = true;
            eachAff.Transfer_Flag__c = 'Transfer';
            eachAff.End_Date__c = Date.Today().addDays(50);
        }
        
        Test.startTest();
            List<Account_Affiliation__c> actualFilteredResults = AccountAffiliationServices.filterAccAffsForSync(testNewAffiliations, testOldAffiliationsMap);
        Test.stopTest();
        
        UnitTest.analyze('Member Account Affiliations').assertEquivalence(actualFilteredResults, 'these two lists should be the same');
    }
    static testMethod void testSyncSpouseAccAffs(){
        setupAffiliations();
        
        Account_Affiliation__c memberAccountAffiliation = (Account_Affiliation__c) UnitTest.get('Member Account Affiliations').getList()[0];
        Boolean expectedActiveValue = memberAccountAffiliation.isActive__c;
        Boolean expectedPrimaryValue = memberAccountAffiliation.is_Primary__c;
        
        Map<Id, Account_Affiliation__c> testOldAffiliationsMap = new Map<Id, Account_Affiliation__c>((List<Account_Affiliation__c>) UnitTest.get('All Account Affiliations').getList());
        
        Test.startTest();
            AccountAffiliationServices.syncSpouseAccAffs( (List<Account_Affiliation__c>) UnitTest.get('Member Account Affiliations').getList(), testOldAffiliationsMap);
        Test.stopTest();
        
        List<Account_Affiliation__c> actualUpdatedRecords = [SELECT Id, RecordTypeId, isActive__c, is_Primary__c, Start_Date__c, Chapter_Approval_Status__c, Transfer_Flag__c, End_Date__c, Reason_for_leaving__c, Reason_Leaving_Other__c 
                                                            FROM Account_Affiliation__c WHERE ID IN: Pluck.Ids('Id', (List<Account_Affiliation__c>) UnitTest.get('Spouse Partner Account Affiliations').getList())];
        
        
        for(Account_Affiliation__c updatedAA : actualUpdatedRecords){
            System.assertEquals(true, updatedAA.isActive__c, 'The active value should be correctly set');
            System.assertEquals(true, updatedAA.is_Primary__c, 'The primary value should be correctly set');
        }

    }
    static testMethod void testgivenExistingActiveAff_WhenASimilarAffIsInserted_thenErrorThrown() {
        setup();
        testAccAff1 = TestServices.createAccountAffiliation(testAccount2.Id,testContact.Id, true, chapterId, true);
        Test.startTest();
        try{
            testAccAff2 = TestServices.createAccountAffiliation(testAccount2.Id, testContact.Id, true, chapterId, true);
        }
        catch(Exception ex)
        {
            system.assert(ex.getMessage().contains(Label.DuplicateAffiliationFound), '');
        }
        Test.stopTest();
    }
    static /*testMethod*/ void testgivenExistingNotActiveAff_WhenASimilarAffIsInserted_thenErrorThrown() {
        setup();
        testAccAff1 = TestServices.createAccountAffiliation(testAccount2.Id,testContact.Id, false, chapterId, true);
        Test.startTest();
        try{
            testAccAff2 = TestServices.createAccountAffiliation(testAccount2.Id, testContact.Id, true, chapterId, true);
        }
        catch(Exception ex)
        {
            system.assert(true, 'No exception should have been thrown');
        }
        Test.stopTest();
    }
    static String CONST_CONTACT = 'Contact';
    static  String CONST_SPOUSE = 'Spouse_Partner';
    static  String CONST_Member = 'Member';
    static  String CONST_Network = 'Network';
    static  String CONST_Relationship = 'Relationship';
    static  String CONST_Business = 'Business';
    static String CONST_Account = 'Account';
	static String CONST_Chapter = 'Chapter';
    static Id memberRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_Member, CONST_CONTACT).Id;
    static Id spouse_partnerConRTId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_SPOUSE, CONST_CONTACT).Id;
    static Id businessAffRTId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_Business, 'Account_Affiliation__c').Id;
	static Id chapterAffRtId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_Chapter, 'Account_Affiliation__c').id;
	static Id networkAffRtId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_Network, 'Account_Affiliation__c').id;
    static Id businessAccRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_Business, CONST_Account).Id;
    static Id relationshipAccRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_Relationship, CONST_Account).Id;
    static Id networkAccRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_Network, CONST_Account).Id;
    static Relationship__c spouse_PartnerRel;
    static Relationship__c memberRel;
    static Account testHouseholdAccount;
    static Account testBusinessAccount;
	static Account testChapterAccount;
	static account testNetworkAccount;
    static Contact testMemberContact;
    static Contact testSpousePartnerContact;
    static Account_Affiliation__c testUpdateAccAff;
    static Account_Affiliation__c testInsertMemberAccAff;
    
    public static void setup2(){
        insert new Profile_Completion_Criteria__c(Name = 'Initial Criteria', Primary_Address__c = 1, External_Connection__c = 1);

		List<Account> NewAccounts = new List<Account>();
		testHouseholdAccount = TestServices.createAccount('Household');
        testHouseholdAccount.Type = CONST_Relationship;
        testHouseholdAccount.RecordTypeId = relationshipAccRecordTypeId;
        NewAccounts.add(testHouseholdAccount);

		testBusinessAccount = TestServices.createAccount('Business Named');
		testBusinessAccount.Type = CONST_Business;
		testBusinessAccount.Record_Type__c = businessAccRecordTypeId;
		NewAccounts.add(testBusinessAccount);

		testNetworkAccount = TestServices.createAccount('Network Named');
		testNetworkAccount.Type = CONST_Network;
		testNetworkAccount.Record_Type__c = networkAccRecordTypeId;
		NewAccounts.add(testNetworkAccount);

        testChapterAccount = TestServices.createChapterAccount('New Chapter',null);
        NewAccounts.add(testChapterAccount);

		insert NewAccounts;

		contact oContactCA = TestServices.createContact(testChapterAccount.Id,true);
		user CAuser = TestServices.createPartnerCommunityUser(oContactCA.Id,testChapterAccount.id);

        testMemberContact = TestServices.createContact(testChapterAccount.Id,true);
        memberRel = TestServices.createRelationship(testMemberContact.Id, testHouseholdAccount.Id,'Member', true, true);
		TestServices.createAccountAffiliation(testChapterAccount.Id,testMemberContact.Id,Date.today(),true,true,chapterAffRtId,true);

		insert TestServices.createCASetting(testChapterAccount.Id,CAuser.Id,true);

    }
    public static testMethod void testUpdateAffiliation(){
        setup2();

        Test.startTest();
			testSpousePartnerContact = TestServices.createContact(testchapteraccount.id,testMemberContact.LastName,spouse_partnerConRTId,true);
			spouse_PartnerRel = TestServices.createRelationship(testSpousePartnerContact.Id, testHouseholdAccount.Id,'Spouse/Partner', true, true);
			TestServices.createAccountAffiliation(testNetworkAccount.Id,testSpousePartnerContact.Id,Date.today(),true,true,networkAffRtId,true);

			//insert TestServices.createCASetting(testNetworkAccount.Id,TestServices.createPartnerCommunityUser(testSpousePartnerContact.Id,testNetworkAccount.id).id,true);
        
			System.debug('Household Members:');
			for (Relationship__c household : [select Contact__r.name, Relationship_Type__c, Account__r.name from Relationship__c where Account__c = :testHouseholdAccount.Id]) {
				System.debug('\t\t ' + household);
			}

			List<Account_Affiliation__c> UpdateAccAff = [Select Id, Contact__c, Start_Date__c, IsActive__c, Is_Primary__c, End_Date__c, Contact_Type__c From Account_Affiliation__c WHERE Account__c =: testChapterAccount.id];

			System.debug('Account Affiliations:');
			for (Account_Affiliation__c AcctAffl : UpdateAccAff) {
				System.debug('\t\t ' + AcctAffl);
			}

			List<Account_Affiliation__c> insertedAccAffs = [Select id, RecordTypeId, IsActive__c, Is_Primary__c from Account_Affiliation__c where contact__c =:testSpousePartnerContact.id]; //and IsActive__c = true AND Contact_Type__c = 'Spouse/Partner'
			System.debug('insertedAccAffs: ' + insertedAccAffs);
			System.assert(insertedAccAffs.size() > 0, 'Affiliation record(s) should have been inserted');

			for (Account_Affiliation__c updatedAA : insertedAccAffs) {
				if (updatedAA.RecordTypeId == networkAffRtId) {
					updatedAA.isActive__c = false;
					updatedAA.End_Date__c = Date.today();
					updatedAA.Reason_for_Leaving__c = 'Voluntary';
					System.debug('Network Aff deactivated: ' + updatedAA);
				}
				if (updatedAA.RecordTypeId == chapterAffRtId) {
					updatedAA.Is_Primary__c = false;
					System.debug('Chapter Aff Primary false: ' + updatedAA);
				}
			}

			update insertedAccAffs;
        
			for (Account_Affiliation__c updatedAA : insertedAccAffs) {
				if (updatedAA.RecordTypeId == chapterAffRtId) {
					updatedAA.Is_Primary__c = true;
					System.debug('Chapter Aff Primary true: ' + updatedAA);
				}
			}

			update insertedAccAffs;
		Test.stopTest();
        
    }
    public static testMethod void testInsertAffiliation(){
        setup2();

        Test.startTest();
			testInsertMemberAccAff = TestServices.createAccountAffiliation(testBusinessAccount.Id, testMemberContact.Id, true, businessAffRTId, true);
        Test.stopTest();

        List<Account_Affiliation__c> totalAccAff = [Select id, account__c from Account_Affiliation__c where account__c =:testBusinessAccount.id];
        System.assertEquals(1, totalAccAff.size());
        
    }

	public static testmethod void testProfileCompletion() {
		
	}
}