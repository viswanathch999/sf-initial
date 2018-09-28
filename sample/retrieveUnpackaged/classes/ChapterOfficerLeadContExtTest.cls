/**
 * This class contains unit tests for validating the behavior of ChapterOfficerLeadContExt
 * "Given" defines the preconditions, "When" defines what happens, and 
 * "Then" defines the result of the scenario. Or in other words: 
 * "Given" describes the start state, and "When" the steps 
 * necessary to reach the accepting state (= "Then").
 * ChapterOfficerLeadContExtTest is service as test class for ChapterOfficerLeadContExt which 
 * is a extension class for chapter officer lead creation page.
 */
 
@isTest
private class ChapterOfficerLeadContExtTest {

    static final String CONST_PARTNER_USER = 'Partner User';
        
    static /*testMethod*/ void testgivenUser_bindLead() {
        
        //test data setup
        Account oAccount = TestServices.createAccount('Test-Account');
        insert oAccount;
        Contact oContact = TestServices.createContact(oAccount.id);
        insert oContact;
        
        Id profileId = [SELECT id FROM Profile WHERE Name =: CONST_PARTNER_USER].id;
        User oUser = TestServices.createPartnerCommunityUser(oContact.id, profileId);
        insert oUser;
        
        Lead oLead = new Lead(LastName = 'Test Lead', Company = 'XYZ');
        insert oLead;
        
        Test.startTest();
        ApexPages.StandardController oLeadStandardController = new ApexPages.StandardController(oLead);
        system.runAs(oUser){
            ChapterOfficerLeadContExt oChapterOfficerLeadContExt = new ChapterOfficerLeadContExt(oLeadStandardController);
        }
        Test.stopTest();
        
        System.assertEquals(oAccount.Name, ((Lead)oLeadStandardController.getRecord()).Organization__c);
        
    }
}