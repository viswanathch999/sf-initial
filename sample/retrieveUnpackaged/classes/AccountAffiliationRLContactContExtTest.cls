/**
 * AccountAffiliationDeleteExtTest is a Test class for AccountAffiliationRelatedListExt, and DisplayResults
 * on Contact Detail Page
 *
 * @author Malay Desai
 */
@isTest
private class AccountAffiliationRLContactContExtTest{
    
    public static Contact testContact;
    public static Account testAccount1,testAccount2;
    public static Account_Affiliation__c testAccAff1,testAccAff2;
    
    
    /**
     * Create some test data for testMethods
     * @returns null
     */
    @testSetup
    static void setup(){
        Account mockRegion = TestServices.createAccount('Test Region Chapter');
        mockRegion.Type = 'Region';
        mockRegion.Start_Date__c = system.today();
        mockRegion.RecordTypeId = RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        insert mockRegion;
        
        testAccount1 = TestServices.createAccount('Test Account Name');
        testAccount1.Type = 'Chapter';
        testAccount1.Start_Date__c = system.today();
        testAccount1.RecordTypeId =  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        testAccount1.ParentId = mockRegion.Id; 
        insert testAccount1;
        
        testContact = TestServices.createContact('Test Last Name', testAccount1.Id);
        insert testContact;
        Id chapAffId = RecordTypeServices.getRecordTypeByName('Chapter','Account_Affiliation__c').Id;
        testAccAff1 = TestServices.createAccountAffiliation(testAccount1.Id, testContact.Id);
        testAccAff1.Start_Date__c = system.today();
        testAccAff1.recordtypeid = chapAffId;
        testAccAff1.IsActive__c = true;
        insert testAccAff1;
    }
    static testMethod void TestAccountAffiliationRLConstructor() {
        testContact = [Select id, Name from Contact];
        PageReference pageRef = Page.AccountAffiliationRL;
        pageRef.getParameters().put('Id',testContact.Id);        
        Test.setCurrentPage(pageRef);    
        ApexPages.StandardController controller = new ApexPages.StandardController(testContact);
        Test.startTest();
        AccountAffiliationRLContactContExt controllerExt = new AccountAffiliationRLContactContExt(controller); 
        Test.stopTest();
        System.assert(controllerExt.accAffRecTypes.size()>0, 'Recordtypes should be properly retrieved');
        System.assert(controllerExt.allRecords.size()>0, 'Affiliations should be retrieved');
    }
    static testMethod void TestAccountAffiliationRLShowAll() {
        testContact = [Select id, Name from Contact];
        PageReference pageRef = Page.AccountAffiliationRL;
        pageRef.getParameters().put('Id',testContact.Id);        
        Test.setCurrentPage(pageRef);    
        ApexPages.StandardController controller = new ApexPages.StandardController(testContact);
        AccountAffiliationRLContactContExt controllerExt = new AccountAffiliationRLContactContExt(controller); 
        Test.startTest();
        controllerExt.selectedRecordTypeId = AccountAffiliationRLContactContExt.ALL_RT;
        controllerExt.queryResultsByRT();
        controllerExt.queryAllResults();
        Test.stopTest();
        System.assert(controllerExt.accAffRecTypes.size()>0, 'Recordtypes should be properly retrieved');
        System.assert(controllerExt.filteredRecords.size()>0, 'Affiliations should be retrieved');
    }
    static testMethod void negativeTestNoAccountAffiliation() {
        testContact = [Select id, Name from Contact];
        PageReference pageRef = Page.AccountAffiliationRL;
        pageRef.getParameters().put('Id',testContact.Id);        
        Test.setCurrentPage(pageRef);    
        ApexPages.StandardController controller = new ApexPages.StandardController(testContact);
        AccountAffiliationRLContactContExt controllerExt = new AccountAffiliationRLContactContExt(controller); 
        Test.startTest();
        controllerExt.selectedRecordTypeId = '000000000000001';
        controllerExt.queryResultsByRT();
        Test.stopTest();
        System.assert(controllerExt.accAffRecTypes.size()>0, 'Recordtypes should be properly retrieved');
        System.assert(controllerExt.filteredRecords.size()==0, 'Affiliations should be retrieved');
    }
    
}