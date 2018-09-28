@isTest
public class ExceptionTriggerTest {
    public static Exception__c testException;
    public static void setup(){
        Id memberRTId = RecordTypeServices.getRecordTypeByName('Member','Contact').Id; 
        Account tAccount = TestServices.createAccount('TestAcc');
        insert tAccount;
        Contact tContact = TestServices.createContact(tAccount.Id);
        tContact.RecordTypeId = memberRTId;
        insert tContact;
        Id recordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Chapter', 'Account').Id;
        Account mockRegion = TestServices.createAccount('Test Region Chapter');
        mockRegion.Type = 'Region';
        mockRegion.RecordTypeId = recordTypeId;
        mockRegion.Start_Date__c = system.today();
        insert mockRegion;
        Account oAccount = TestServices.createAccount('Test-Account');
        oAccount.ParentId = mockRegion.Id;
        oAccount.RecordTypeId = recordTypeId;
        oAccount.Type = 'Chapter';
        oAccount.Start_Date__c = system.today();
        insert oAccount;
        Contact testContact = TestServices.createContact(oAccount.Id);
        testContact.LastName = 'contact';
        testContact.Email = 'test@email.com';
        insert testContact;
        KGRenewal__VenueSettings__c settings = KGRenewal__VenueSettings__c.getOrgDefaults();
        settings.KGRenewal__OpportunityStageOnInsertion__c = 'TEST STAGE';
        upsert settings;
        Opportunity opp = new Opportunity(
            StageName = 'Payment Received', 
            Certification_Status__c = 'Complete', 
            Name = 'TestOpp',
            CloseDate = System.today(),
            KGRenewal__IsActiveCart__c = true,
            KGRenewal__ContractEffectiveDate__c = FiscalDateUtility.startOfCurrentFiscal,
            KGRenewal__Contact__c  = testContact.id,
            Chapter_Membership_Officer__c = userinfo.getUserId(),
            Chapter_Administrator__c = userinfo.getUserId()
        );
        insert opp ;
        testException = TestServices.createException(oAccount.id, testContact.id, opp.Id, 'Approved', false);
        CA_Setting__c oCASetting1 = TestServices.createCASetting(oAccount.id, userinfo.getUserId(), true);
        oCASetting1.Primary__c = true;
        oCASetting1.Role__c = CASettingServices.CONST_CHAP_MEM_OFF;
        CA_Setting__c oCASetting2 = TestServices.createCASetting(oAccount.id, userinfo.getUserId(), true);
        oCASetting2.Primary__c = true;
        oCASetting2.Role__c = CASettingServices.CONST_CHAP_CHAIR;
        CA_Setting__c oCASetting3 = TestServices.createCASetting(oAccount.id, userinfo.getUserId(), true);
        oCASetting3.Primary__c = true;
        oCASetting3.Role__c = CASettingServices.CONST_CHAP_ADMIN;
        insert new List<CA_Setting__c>{oCASetting1, oCASetting2, oCASetting3};
    }
    public static testMethod void givenExceptionAndCAForSameChapter_WhenExceptionIsInserted_thenUpdateUserLookup(){
        setup();
        Test.startTest();
        	insert testException;
        Test.stopTest();
        Exception__c updatedExLog = [Select Chapter_Membership_Officer__c, Chpter_Chair__c, Chapter_Administrator__c from Exception__c where id=:testException.id];
        system.assert(updatedExLog.Chapter_Administrator__c == userinfo.getUserId());
        system.assert(updatedExLog.Chpter_Chair__c == userinfo.getUserId());
        system.assert(updatedExLog.Chapter_Membership_Officer__c == userinfo.getUserId());
    }
    public static testMethod void givenExceptionAndCAForSameChapter_WhenExceptionIsUpdated_thenUpdateUserLookup(){
        setup();
        Id accId = testException.Account__c;
        testException.Account__c = null;
        	insert testException;
        Test.startTest();
        testException.Account__c = accId;
        update testException;
        Test.stopTest();
        Exception__c updatedExLog = [Select Chapter_Membership_Officer__c, Chpter_Chair__c, Chapter_Administrator__c from Exception__c where id=:testException.id];
        system.assert(updatedExLog.Chapter_Administrator__c == userinfo.getUserId());
        system.assert(updatedExLog.Chpter_Chair__c == userinfo.getUserId());
        system.assert(updatedExLog.Chapter_Membership_Officer__c == userinfo.getUserId());
    }
}