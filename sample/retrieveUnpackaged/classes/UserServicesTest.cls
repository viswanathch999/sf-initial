/**
 * This class contains unit tests for validating the behavior of UserServices
 * "Given" defines the preconditions, "When" defines what happens, and 
 * "Then" defines the result of the scenario. Or in other words: 
 * "Given" describes the start state, and "When" the steps 
 * necessary to reach the accepting state (= "Then").
 * UserServicesTest is service as test class for UserServices which enables 
 * partner portal user to share the affiliated contact record.
 */
 
@isTest
private class UserServicesTest {

    static final String CONST_PARTNER_USER = 'Partner User';
    static final String CONST_CHAPTER = 'Chapter';
    static final String CONST_ACCOUNT = 'Account';

    static /*testMethod*/ void testgivenUser_WhenInserted_thenShareContact() {
        
        //test data setup
        Id recordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_CHAPTER, CONST_ACCOUNT).Id;
        Account mockRegion = TestServices.createAccount('Test Region Chapter');
        mockRegion.Type = 'Region';
        mockRegion.RecordTypeId = recordTypeId;
        insert mockRegion;
        
        Account oAccount = TestServices.createAccount('Test-Account');
        oAccount.ParentId = mockRegion.Id;
        oAccount.RecordTypeId = recordTypeId;
        oAccount.Type = 'Chapter';
        insert oAccount;
        Contact oContact = TestServices.createContact(oAccount.id);
        insert oContact;
        
        Account_Affiliation__c oAccountAffiliation = TestServices.createAccountAffiliation(oAccount.id, oContact.id);
        oAccountAffiliation.IsActive__c = true;
        insert oAccountAffiliation;
        
        Id profileId = [SELECT id FROM Profile WHERE Name =: CONST_PARTNER_USER].id;
        User oUser = TestServices.createPartnerCommunityUser(oContact.id, profileId);
        insert oUser;
        
        Test.startTest();
        ChapterUserAccessBatchScheduler oChapterUserAccessBatchScheduler = new ChapterUserAccessBatchScheduler();
        database.executebatch(oChapterUserAccessBatchScheduler);
        Test.stopTest();
        
        List<ContactShare> lstContactShare = [SELECT Id, UserOrGroupId, ContactId,
                                                ContactAccessLevel FROM ContactShare WHERE UserOrGroupId =: oUser.id];      
        System.assertEquals(1, lstContactShare.size());
        System.assertEquals(oContact.id, lstContactShare[0].ContactId);
        System.assertEquals('Edit', lstContactShare[0].ContactAccessLevel);

        List<AccountShare> lstAccountShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE UserOrGroupId =: oUser.id];      
        System.assertEquals(1, lstAccountShare.size());
        System.assertEquals(oAccount.id, lstAccountShare[0].AccountId);

    }

    static /*testMethod*/ void testgivenUser_WhenInserted_thenShareBasedOnRelationship() {
        
        //test data setup
        Id recordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_CHAPTER, CONST_ACCOUNT).Id;
        Account mockRegion = TestServices.createAccount('Test Region Chapter');
        mockRegion.Type = 'Region';
        mockRegion.RecordTypeId = recordTypeId;
        insert mockRegion;
        
        Account oAccount = TestServices.createAccount('Test-Account');
        oAccount.ParentId = mockRegion.Id;
        oAccount.RecordTypeId = recordTypeId;
        oAccount.Type = 'Chapter';
        oAccount.recordtypeid=  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        insert oAccount;
        Contact oContact = TestServices.createContact(oAccount.id);
        insert oContact;
        
        Account_Affiliation__c oAccountAffiliation = TestServices.createAccountAffiliation(oAccount.id, oContact.id);
        oAccountAffiliation.IsActive__c = true;
        insert oAccountAffiliation;
        
        Id profileId = [SELECT id FROM Profile WHERE Name =: CONST_PARTNER_USER].id;
        User oUser = TestServices.createPartnerCommunityUser(oContact.id, profileId);
        insert oUser;
        
        Account oAccountHousehold = TestServices.createAccount('Test-Account-Household');
        oAccountHousehold.Type = 'Relationship';
        insert oAccountHousehold;
        
        Contact oContact1 = TestServices.createContact(oAccount.id);
        oContact1.HouseholdID__c = oAccountHousehold.id;
        insert oContact1;
        system.debug('oContactChild::' + oContact1.Id);
        
        oAccountAffiliation = TestServices.createAccountAffiliation(oAccount.id, oContact1.id);
        oAccountAffiliation.IsActive__c = true;
        insert oAccountAffiliation;
        
        Relationship__c oRelationshipHousehold = TestServices.createRelationship(oContact1.id, oAccountHousehold.id, 'Member');
        insert oRelationshipHousehold;
        
        Contact oContactChild = TestServices.createContact(oAccountHousehold.id);
        insert oContactChild;
        system.debug('oContactChild::' + oContactChild.Id);
        
        oRelationshipHousehold = TestServices.createRelationship(oContactChild.id, oAccountHousehold.id, 'Spouse');
        insert oRelationshipHousehold;
        
        Test.startTest();
        ChapterUserAccessBatchScheduler oChapterUserAccessBatchScheduler = new ChapterUserAccessBatchScheduler();
        database.executebatch(oChapterUserAccessBatchScheduler);
        Test.stopTest();
        
        List<ContactShare> lstContactShare = [SELECT Id, UserOrGroupId, ContactId,
                                                ContactAccessLevel FROM ContactShare WHERE UserOrGroupId =: oUser.id];      
        system.debug('lstContactShare::' + lstContactShare);
        //System.assertEquals(2, lstContactShare.size());

        List<AccountShare> lstAccountShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE UserOrGroupId =: oUser.id];      
       // System.assertEquals(1, lstAccountShare.size());

    }
    
    static /*testMethod*/ void testgivenUser_WhenInserted_thenShareContactWithoutAffiliation() {
        
        //test data setup
        Id recordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_CHAPTER, CONST_ACCOUNT).Id;
        Account mockRegion = TestServices.createAccount('Test Region Chapter');
        mockRegion.Type = 'Region';
        mockRegion.RecordTypeId = recordTypeId;
        insert mockRegion;
        
        Account oAccount = TestServices.createAccount('Test-Account');
        oAccount.ParentId = mockRegion.Id;
        oAccount.RecordTypeId = recordTypeId;
        oAccount.Type = 'Chapter';
        insert oAccount;
        Contact oContact = TestServices.createContact(oAccount.id);
        insert oContact;
        
        Id profileId = [SELECT id FROM Profile WHERE Name =: CONST_PARTNER_USER].id;
        User oUser = TestServices.createPartnerCommunityUser(oContact.id, profileId);
        insert oUser;
        
        Test.startTest();
        ChapterUserAccessBatchScheduler oChapterUserAccessBatchScheduler = new ChapterUserAccessBatchScheduler();
        database.executebatch(oChapterUserAccessBatchScheduler);
        Test.stopTest();
        
        List<ContactShare> lstContactShare = [SELECT Id, UserOrGroupId, ContactId,
                                                ContactAccessLevel FROM ContactShare WHERE UserOrGroupId =: oUser.id];      
        System.assertEquals(0, lstContactShare.size());
        List<AccountShare> lstAccountShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE UserOrGroupId =: oUser.id];      
        System.assertEquals(0, lstAccountShare.size());
    }
    
    static testMethod void testgivenUser_WhenInserted_thenCAShareContact() {
        
        //test data setup
        Id recordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_CHAPTER, CONST_ACCOUNT).Id;
        Account mockRegion = TestServices.createAccount('Test Region Chapter');
        mockRegion.Type = 'Region';
        mockRegion.RecordTypeId = recordTypeId;
        insert mockRegion;
        
        Account oAccount = TestServices.createAccount('Test-Account');
        oAccount.ParentId = mockRegion.Id;
        oAccount.RecordTypeId = recordTypeId;
        oAccount.Type = 'Chapter';
        insert oAccount;
        Contact oContact = TestServices.createContact(oAccount.id);
        insert oContact;
        
        Account_Affiliation__c oAccountAffiliation = TestServices.createAccountAffiliation(oAccount.id, oContact.id);
        oAccountAffiliation.IsActive__c = true;
        insert oAccountAffiliation;
        
        Id profileId = [SELECT id FROM Profile WHERE Name =: CONST_PARTNER_USER].id;
        User oUser = TestServices.createPartnerCommunityUser(oContact.id, profileId);
        insert oUser;
        
        Account oAccount1 = TestServices.createAccount('Test-Account1');
        insert oAccount1;
        Contact oContact1 = TestServices.createContact(oAccount1.id);
        insert oContact1;
        
        User oUser1 = TestServices.createPartnerCommunityUser(oContact1.id, profileId);
        //oUser1.UserName = 'aaa@bbb.com';
        //oUser1.CommunityNickname = 'user11';
        insert oUser1;
        
        Opportunity oOpportunity1 = TestServices.createOpp(oAccount.Id, false);
        oOpportunity1.stageName = 'In Progress';
        oOpportunity1.KGRenewal__Contact__c = oContact.Id;
        insert oOpportunity1;
        
        List<ContactShare> lstContactShare1 = [SELECT Id, UserOrGroupId, ContactId, RowCause,
                                                ContactAccessLevel FROM ContactShare WHERE UserOrGroupId =: oUser1.id];      
        
        CA_Setting__c oCASetting = TestServices.createCASetting(oAccount.id, oUser1.id, true);
        //insert oCASetting;
        
        Test.startTest();
        //ChapterAdditionalUserAccessBatch oChapterAdditionalUserAccessBatch = new ChapterAdditionalUserAccessBatch();
        //database.executebatch(oChapterAdditionalUserAccessBatch);
        insert oCASetting;
        Test.stopTest();
        
        List<ContactShare> lstContactShare = [SELECT Id, UserOrGroupId, ContactId, RowCause,
                                                ContactAccessLevel FROM ContactShare WHERE UserOrGroupId =: oUser1.id];      
        System.assertEquals(1, lstContactShare.size());

        List<AccountShare> lstAccountShare = [SELECT Id, UserOrGroupId, AccountId, RowCause FROM AccountShare WHERE UserOrGroupId =: oUser1.id];      
        System.assertEquals(1, lstAccountShare.size());

    }
    
    static testMethod void testgivenUser_WhenInserted_thenCAShareContactMultiple() {
        
        //test data setup
        Id recordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_CHAPTER, CONST_ACCOUNT).Id;
        Account mockRegion = TestServices.createAccount('Test Region Chapter');
        mockRegion.Type = 'Region';
        mockRegion.RecordTypeId = recordTypeId;
        insert mockRegion;
        
        Account oAccount = TestServices.createAccount('Test-Account');
        oAccount.ParentId = mockRegion.Id;
        oAccount.RecordTypeId = recordTypeId;
        oAccount.Type = 'Chapter';
        insert oAccount;
        
        Contact oContact = TestServices.createContact(oAccount.id);
        insert oContact;
        
        Account_Affiliation__c oAccountAffiliation = TestServices.createAccountAffiliation(oAccount.id, oContact.id);
        oAccountAffiliation.IsActive__c = true;
        insert oAccountAffiliation;
        
        Contact oContactNew = TestServices.createContact(null);
        insert oContactNew;
        
        Account_Affiliation__c oAccountAffiliationNew = TestServices.createAccountAffiliation(oAccount.id, oContactNew.id);
        oAccountAffiliationNew.IsActive__c = true;
        insert oAccountAffiliationNew;
        
        Id profileId = [SELECT id FROM Profile WHERE Name =: CONST_PARTNER_USER].id;
        User oUser = TestServices.createPartnerCommunityUser(oContact.id, profileId);
        insert oUser;
        
        Account oAccount1 = TestServices.createAccount('Test-Account1');
        insert oAccount1;
        Contact oContact1 = TestServices.createContact(oAccount1.id);
        insert oContact1;
        
        User oUser1 = TestServices.createPartnerCommunityUser(oContact1.id, profileId);
        //oUser1.UserName = 'aaa@bbb.com';
        //oUser1.CommunityNickname = 'user11';
        insert oUser1;
        
        Opportunity oOpportunity1 = TestServices.createOpp(oAccount.Id, false);
        oOpportunity1.stageName = 'In Progress';
        oOpportunity1.KGRenewal__Contact__c = oContact1.Id;
        insert oOpportunity1;
        
        CA_Setting__c oCASetting = TestServices.createCASetting(oAccount.id, oUser1.id, true);
        
        Test.startTest();
        insert oCASetting;
        Test.stopTest();
        
        List<ContactShare> lstContactShare = [SELECT Id, UserOrGroupId, ContactId, RowCause,
                                                ContactAccessLevel FROM ContactShare WHERE UserOrGroupId =: oUser1.id];      
        System.assertEquals(2, lstContactShare.size());

        List<AccountShare> lstAccountShare = [SELECT Id, UserOrGroupId, AccountId, RowCause FROM AccountShare WHERE UserOrGroupId =: oUser1.id];      
        system.debug('lstAccountShare::' + lstAccountShare);
        System.assertEquals(1, lstAccountShare.size());

    }
    
    static testMethod void testgivenUser_WhenDeletedCASetting_thenDeleteShare() {
        
        //test data setup
        Id recordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_CHAPTER, CONST_ACCOUNT).Id;
        Account mockRegion = TestServices.createAccount('Test Region Chapter');
        mockRegion.Type = 'Region';
        mockRegion.RecordTypeId = recordTypeId;
        insert mockRegion;
        
        Account oAccount = TestServices.createAccount('Test-Account');
        oAccount.ParentId = mockRegion.Id;
        oAccount.RecordTypeId = recordTypeId;
        oAccount.Type = 'Chapter';
        insert oAccount;
        
        Contact oContact = TestServices.createContact(oAccount.id);
        insert oContact;
        
        Account_Affiliation__c oAccountAffiliation = TestServices.createAccountAffiliation(oAccount.id, oContact.id);
        oAccountAffiliation.IsActive__c = true;
        insert oAccountAffiliation;
        
        Id profileId = [SELECT id FROM Profile WHERE Name =: CONST_PARTNER_USER].id;
        User oUser = TestServices.createPartnerCommunityUser(oContact.id, profileId);
        insert oUser;
        
        Account oAccount1 = TestServices.createAccount('Test-Account1');
        insert oAccount1;
        
        Contact oContact1 = TestServices.createContact(oAccount1.id);
        insert oContact1;
        
        User oUser1 = TestServices.createPartnerCommunityUser(oContact1.id, profileId);
        //oUser1.UserName = 'aaa@bbb.com';
        //oUser1.CommunityNickname = 'user11';
        insert oUser1;    
        
        Opportunity oOpportunity1 = TestServices.createOpp(oAccount.Id, false);
        oOpportunity1.stageName = 'In Progress';
        oOpportunity1.KGRenewal__Contact__c = oContact.Id;
        insert oOpportunity1;
        
        CA_Setting__c oCASetting = TestServices.createCASetting(oAccount.id, oUser1.id, true);        
        oCASetting.Primary__c = false;
        insert oCASetting;
        
        Test.startTest();
        oCASetting.isActive__c = true;
        oCASetting.Primary__c = true;
        
        update oCASetting;
        Test.stopTest();
        
        List<ContactShare> lstContactShare = [SELECT Id, UserOrGroupId, ContactId, RowCause,
                                                ContactAccessLevel FROM ContactShare WHERE UserOrGroupId =: oUser1.id];      
        system.assertEquals(1, lstContactShare.size());

        List<AccountShare> lstAccountShare = [SELECT Id, UserOrGroupId, AccountId, RowCause FROM AccountShare WHERE UserOrGroupId =: oUser1.id];      
        system.assertEquals(1, lstAccountShare.size());

    }
     static testMethod void testgivenUser_WhenDeletedCASetting() {
        
        //test data setup
        Id recordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_CHAPTER, CONST_ACCOUNT).Id;
        Account mockRegion = TestServices.createAccount('Test Region Chapter');
        mockRegion.Type = 'Region';
        mockRegion.RecordTypeId = recordTypeId;
        insert mockRegion;
        
        Account oAccount = TestServices.createAccount('Test-Account');
        oAccount.ParentId = mockRegion.Id;
        oAccount.RecordTypeId = recordTypeId;
        oAccount.Type = 'Chapter';
        insert oAccount;
        
        Contact oContact = TestServices.createContact(oAccount.id);
        insert oContact;
        
        Account_Affiliation__c oAccountAffiliation = TestServices.createAccountAffiliation(oAccount.id, oContact.id);
        oAccountAffiliation.IsActive__c = true;
        insert oAccountAffiliation;
        
        Id profileId = [SELECT id FROM Profile WHERE Name =: CONST_PARTNER_USER].id;
        User oUser = TestServices.createPartnerCommunityUser(oContact.id, profileId);
        insert oUser;
        
        Account oAccount1 = TestServices.createAccount('Test-Account1');
        insert oAccount1;
        
        Contact oContact1 = TestServices.createContact(oAccount1.id);
        insert oContact1;
        
        User oUser1 = TestServices.createPartnerCommunityUser(oContact1.id, profileId);
        //oUser1.UserName = 'aaa@bbb.com';
        //oUser1.CommunityNickname = 'user11';
        insert oUser1;    
        
        Opportunity oOpportunity1 = TestServices.createOpp(oAccount.Id, false);
        oOpportunity1.stageName = 'In Progress';
        oOpportunity1.KGRenewal__Contact__c = oContact.Id;
        insert oOpportunity1;
        
        CA_Setting__c oCASetting = TestServices.createCASetting(oAccount.id, oUser1.id, true);
        insert oCASetting;
        
        Test.startTest();
        oCASetting.isActive__c = false;
        delete oCASetting;
        Test.stopTest();
        
        List<ContactShare> lstContactShare = [SELECT Id, UserOrGroupId, ContactId, RowCause,
                                                ContactAccessLevel FROM ContactShare WHERE UserOrGroupId =: oUser1.id];      
        system.assertEquals(0, lstContactShare.size());

        List<AccountShare> lstAccountShare = [SELECT Id, UserOrGroupId, AccountId, RowCause FROM AccountShare WHERE UserOrGroupId =: oUser1.id];      
        system.assertEquals(0, lstAccountShare.size());

    }  
}