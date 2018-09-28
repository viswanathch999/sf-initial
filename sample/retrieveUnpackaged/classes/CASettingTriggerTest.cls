@isTest
public class CASettingTriggerTest {
    
    static final String CONST_PARTNER_USER = Label.Partner_User_Custom;
    static final String CONST_CHAPTER = 'Chapter';
    static final String CONST_ACCOUNT = 'Account';
    
	@TestSetup
    private static void testingsetup()
    {
		List<Lead_and_Contact_Sharing_CA_Roles__c> list_LCSR = new List<Lead_and_Contact_Sharing_CA_Roles__c>();
		Lead_and_Contact_Sharing_CA_Roles__c LCSR = new Lead_and_Contact_Sharing_CA_Roles__c();
		LCSR.Name = 'Chapter Administrator';
		list_LCSR.add(LCSR);
		LCSR = new Lead_and_Contact_Sharing_CA_Roles__c();
		LCSR.Name = 'Chapter Chair';
		list_LCSR.add(LCSR);
		LCSR = new Lead_and_Contact_Sharing_CA_Roles__c();
		LCSR.Name = 'Chapter Membership Officer';
		list_LCSR.add(LCSR);
		insert list_LCSR;
		
		Lead_Share_Settings__c LSS = new Lead_Share_Settings__c();
		LSS.Name = 'New_Edit';
		LSS.CA_Access_Level__c='Edit';
		LSS.Lead_Status__c = 'New';
		insert LSS;

		Profile CommunityUser_prof = [SELECT Id FROM Profile WHERE Name = :Label.Customer_Community_User_Custom LIMIT 1];
		Profile PartnerUser_Prof = [SELECT Id FROM Profile WHERE Name = 'Partner User' LIMIT 1];

		List<Account> accountList = new List<Account>();
        Account mockRegion = TestServices.createAccount('Test Region Chapter');
        mockRegion.Type = 'Region';
        mockRegion.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chapter').getRecordTypeId();
        mockRegion.Start_Date__c = system.today();
		accountList.add(mockRegion);
        
        Account chapterAccount = TestServices.createChapterAccount('Chapter1',Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chapter').getRecordTypeId());
        chapterAccount.ParentId = mockRegion.Id;
		chapterAccount.Type = 'Chapter';
		chapterAccount.Start_Date__c = system.today();
        chapterAccount.YPOI_Type__c = 'YPO Chapter';
		chapterAccount.Status__c = 'Active';
		accountList.add(chapterAccount);
        
        chapterAccount = TestServices.createChapterAccount('Chapter2',Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chapter').getRecordTypeId());
        chapterAccount.ParentId = mockRegion.Id;
		chapterAccount.Type = 'Chapter';
		chapterAccount.Start_Date__c = system.today();
        chapterAccount.YPOI_Type__c = 'YPO Chapter';
		chapterAccount.Status__c = 'In Development';
		accountList.add(chapterAccount);
        
        Account Household1 = new Account();
        Household1.Name ='Test Account';
        Household1.Type = 'Relationship';
        Household1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship').getRecordTypeId();
		accountList.add(Household1);
		
        Account Household2 = new Account();
        Household2.Name ='Test Account';
        Household2.Type = 'Relationship';
        Household2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship').getRecordTypeId();
		accountList.add(Household2);
		
		insert accountList;

        
        Contact testContact = TestServices.createContact(chapterAccount.Id,'Member1',Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId(),false);

        Contact testContact2 = TestServices.createContact(chapterAccount.Id,'Member2',Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId(),false);

        Contact ProspectContact = TestServices.createContact(chapterAccount.Id,'Prospect1',Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Prospect').getRecordTypeId(),false);

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

        insert new List<Contact>{testContact, testcontact2 ,spousecon, childCon, ProspectContact};
        
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

		List<Account_Affiliation__c> listAffiliation = new List<Account_Affiliation__c>();
		Account_Affiliation__c oAccountAffiliation = TestServices.createAccountAffiliation(testContact.AccountId, testContact.id);
		oAccountAffiliation.IsActive__c = true;
		oAccountAffiliation.Start_Date__c = Date.today();
		listAffiliation.add(oAccountAffiliation);

		oAccountAffiliation = TestServices.createAccountAffiliation(testContact2.AccountId, testContact2.id);
		oAccountAffiliation.IsActive__c = true;
		oAccountAffiliation.Start_Date__c = Date.today();
		listAffiliation.add(oAccountAffiliation);

		oAccountAffiliation = TestServices.createAccountAffiliation(ProspectContact.AccountId, ProspectContact.id);
		oAccountAffiliation.IsActive__c = true;
		oAccountAffiliation.Start_Date__c = Date.today();
		oAccountAffiliation.Chapter_Approval_Status__c = 'Pending';
		listAffiliation.add(oAccountAffiliation);

		insert listAffiliation;
        
		User AdminUser = [SELECT Id FROM User Where Profile.Name = 'System Administrator' and isActive=true LIMIT 1];

		System.runAs(AdminUser) {
			User partnerUser = new User(
				Email = 'test-user@fakeemail.com',
				ContactId = testContact.id,
				ProfileId = PartnerUser_Prof.id,
				UserName = 'test-user@fakeemail.com',
				Alias = 'partner',
				LocaleSidKey = 'en_US',
				CommunityNickName = 'partner',
				TimeZoneSidKey = 'America/Los_Angeles',
				EmailEncodingKey = 'ISO-8859-1',
				LanguageLocaleKey = 'en_US',
				FirstName = 'Partner Portal Manager',
				LastName = 'Custom',
				isActive = true);

			User customerUser = new User(
				Email = 'Comm-user@fakeemail.com',
				ContactId = testContact2.id,
				ProfileId = PartnerUser_Prof.id,
				UserName = 'Comm-user@fakeemail.com',
				Alias = 'customer',
				LocaleSidKey = 'en_US',
				CommunityNickName = 'customer',
				TimeZoneSidKey = 'America/Los_Angeles',
				EmailEncodingKey = 'ISO-8859-1',
				LanguageLocaleKey = 'en_US',
				FirstName = 'Customer Member',
				LastName = 'Custom',
				isActive = true);

			insert new List<User> {partnerUser, customerUser};

			CA_Setting__c oCASetting = TestServices.createCASetting(chapterAccount.id, partnerUser.id, true);
			insert oCASetting;

		}
        
        Opportunity testOpp = TestServices.createOpp('Cycle Open',chapterAccount.Id,testContact.Id,true);

		testOpp = TestServices.createOpp('New',chapterAccount.Id,ProspectContact.Id,true);
        System.debug('Stagename: ' + testOpp.StageName + ' KGRenewal__IsActiveCart__c: ' + testOpp.KGRenewal__IsActiveCart__c);
		System.debug('Opp_Rec_Type: ' + testOpp.Record_Type_Name__c);

    }

    static testMethod void testgivenUser_WhenInserted_thenCAShareContact() {
        
		User AdminUser = [SELECT Id FROM User Where Profile.Name = 'System Administrator' and isActive=true LIMIT 1];

        System.runAs(AdminUser) {
			Test.startTest();
				ChapterAdditionalUserAccessBatch oChapterAdditionalUserAccessBatch = new ChapterAdditionalUserAccessBatch();
				database.executebatch(oChapterAdditionalUserAccessBatch);
			Test.stopTest();
        }

		User partnerUser = [Select id from user where Email = 'test-user@fakeemail.com'];

        List<ContactShare> lstContactShare = [SELECT Id, UserOrGroupId, ContactId, RowCause,
                                              ContactAccessLevel FROM ContactShare WHERE UserOrGroupId =: partnerUser.id];      
        System.assert(lstContactShare.size()>0);
        
        List<AccountShare> lstAccountShare = [SELECT Id, UserOrGroupId, AccountId, RowCause FROM AccountShare WHERE UserOrGroupId =: partnerUser.id];      
        System.assert(lstAccountShare.size()>0);
        
        List<OpportunityShare> lstOpportunityShare = [SELECT Id, UserOrGroupId, OpportunityId, RowCause 
        											  FROM OpportunityShare 
        											  WHERE UserOrGroupId =: partnerUser.id];
 
        System.assert(lstOpportunityShare.size() > 0);
        
         
    }
    
    static testMethod void testgivenUser_WhenInserted_thenCAShareContactMultiple() {
        
		User MemberUser = [SELECT Id, Contactid FROM User Where Email = 'Comm-user@fakeemail.com' LIMIT 1];
		Contact oContact = [SELECT Id, AccountId FROM Contact WHERE id = :MemberUser.Contactid];

        CA_Setting__c oCASetting = TestServices.createCASetting(oContact.AccountId, MemberUser.id, true);
        oCASetting.Role__c = 'Chapter Chair';
        Test.startTest();
        insert oCASetting;
        Test.stopTest();
        
        List<ContactShare> lstContactShare = [SELECT Id, UserOrGroupId, ContactId, RowCause,
                                              ContactAccessLevel FROM ContactShare WHERE UserOrGroupId =: MemberUser.id];      
        System.assert(lstContactShare.size() > 0);
        
        List<AccountShare> lstAccountShare = [SELECT Id, UserOrGroupId, AccountId, RowCause FROM AccountShare WHERE UserOrGroupId =: MemberUser.id];      
        system.debug('lstAccountShare::' + lstAccountShare);
        System.assert(lstAccountShare.size() > 0);
        
        Account_Affiliation__c updatedAccAff = [Select Chapter_Chair__c from Account_Affiliation__c where Chapter_Chair__c = :MemberUser.id limit 1];
        System.assertEquals(MemberUser.id,updatedAccAff.Chapter_Chair__c);
    }
    
    static testMethod void testgivenUser_WhenDeletedCASetting_thenDeleteShare() {
        
		User partnerUser = [Select id from user where Email = 'test-user@fakeemail.com'];
		CA_Setting__c oCASetting = [SELECT Id, isActive__c, Primary__c FROM CA_Setting__c WHERE User__c = :partnerUser.Id];
        
        Test.startTest();
        oCASetting.isActive__c = false;
        oCASetting.Primary__c = false;
        update oCASetting;
        Test.stopTest();
        
        List<ContactShare> lstContactShare = [SELECT Id, UserOrGroupId, ContactId, RowCause,
                                              ContactAccessLevel FROM ContactShare WHERE UserOrGroupId =: partnerUser.id];      
        system.assertEquals(0, lstContactShare.size());
        
        List<AccountShare> lstAccountShare = [SELECT Id, UserOrGroupId, AccountId, RowCause FROM AccountShare WHERE UserOrGroupId =: partnerUser.id];      
        system.assertEquals(0, lstAccountShare.size());
        
    }
    static testMethod void testgivenUser_WhenDeletedCASetting() {
        
		User partnerUser = [Select id from user where Email = 'test-user@fakeemail.com'];
		CA_Setting__c oCASetting = [SELECT Id, isActive__c, Primary__c FROM CA_Setting__c WHERE User__c = :partnerUser.Id];        
        
        Test.startTest();
        delete oCASetting;
        Test.stopTest();
        
        List<ContactShare> lstContactShare = [SELECT Id, UserOrGroupId, ContactId, RowCause,
                                              ContactAccessLevel FROM ContactShare WHERE UserOrGroupId =: partnerUser.id];      
        system.assertEquals(0, lstContactShare.size());
        
        List<AccountShare> lstAccountShare = [SELECT Id, UserOrGroupId, AccountId, RowCause FROM AccountShare WHERE UserOrGroupId =: partnerUser.id];      
        system.assertEquals(0, lstAccountShare.size());
        
    }
    static testMethod void testgivenExistingPrimarCASetting_WhenInsertedDuplicateCASettingEntered_thenError() {
        
		User partnerUser = [Select id, ContactId from user where Email = 'test-user@fakeemail.com'];
		Contact Member = [SELECT Id, AccountId FROM Contact WHERE id = :partnerUser.ContactId];
		CA_Setting__c oCASetting = [SELECT Id, isActive__c, Primary__c FROM CA_Setting__c WHERE User__c = :partnerUser.Id];
        
        System.assertEquals(true, [Select Primary__c from CA_Setting__c where id=:oCASetting.id][0].Primary__c,
                            'As no existing CA Setting per Role/Chapter, Primary should be set to true');
        CA_Setting__c duplicatePrimaryCASetting = TestServices.createCASetting(Member.Accountid, partnerUser.id, true);
        duplicatePrimaryCASetting.Primary__c = true;
        Test.startTest();
        try{
            insert duplicatePrimaryCASetting;
            system.assert(false, 'Exception should have been thrown');
        }catch(DmlException dEx){
            String errorMessage = dEx.getMessage();
            System.assert(errorMessage.contains(Label.Only_One_Primary_CA_Setting),
                          'Only_One_Primary_CA_Setting exception should have been thrown');
        }
        Test.stopTest();
    }
    static testMethod void testgivenLeadAndCAForSameChapter_WhenCAChapterUpdated_thenLeadUpdated() {
		User partnerUser = [Select id, ContactId from user where Email = 'test-user@fakeemail.com'];
		Contact Member = [SELECT Id, AccountId FROM Contact WHERE id = :partnerUser.ContactId];

		Account oAccount = [Select Id, Type, Status__c From Account Where id = :Member.AccountId];
		System.debug('id,type,status__c: ' + oAccount.Id + '/' + oAccount.Type + '/' + oAccount.Status__c);

		CA_Setting__c oCASetting = [SELECT Id, isActive__c, Primary__c FROM CA_Setting__c WHERE User__c = :partnerUser.Id];

        Lead testLead = TestServices.createLead('Test Lead', 'New', oAccount.id, false);
        testLead.Country = 'Algeria';
        testLead.State = '';
        insert testLead;

        Test.startTest();
			oCASetting.Chapter__c = oAccount.id;
			update oCASetting;
        Test.stopTest();

        Lead updatedLead = [Select Chpter_Chair__c,Chapter_Administrator__c,Chapter_Membership_Officer__c from Lead where id =: testLead.id limit 1];
        System.assertEquals(updatedLead.Chapter_Administrator__c, partnerUser.id);
    }

    static testMethod void SyncAccAff_CASettingUpdate() {
		User partnerUser = [Select id, ContactId from user where Email = 'test-user@fakeemail.com'];
		Contact Member = [SELECT Id, AccountId FROM Contact WHERE id = :partnerUser.ContactId];

		Account oAccount = [Select Id, Type, Status__c From Account Where id = :Member.AccountId];
		System.debug('id,type,status__c: ' + oAccount.Id + '/' + oAccount.Type + '/' + oAccount.Status__c);

		CA_Setting__c oCASetting = [SELECT Id, isActive__c, Primary__c, Role__c FROM CA_Setting__c WHERE User__c = :partnerUser.Id];

        Test.startTest();
            oCASetting.Role__c = CASettingServices.CONST_CHAP_CHAIR;
            update oCASetting;
        Test.stopTest();

        Account_Affiliation__c updatedAccAff = [Select Chapter_Chair__c from Account_Affiliation__c where Chapter_Chair__c = :partnerUser.id limit 1];
        System.assertEquals(updatedAccAff.Chapter_Chair__c, partnerUser.id);
    }
    
    static testMethod void testProperties() {
        String testStr;
        
        Test.startTest();
        	testStr = CASettingServices.CONST_SHARING_METHOD;
        	testStr = CASettingServices.CONST_CHAP_CHAIR;
        	testStr = CASettingServices.CONST_CHAP_MEM_OFF;
        	testStr = CASettingServices.CONST_CHAP_ADMIN;
        	testStr = CASettingServices.CONST_PEDNING;
        Test.stopTest();
    }
}