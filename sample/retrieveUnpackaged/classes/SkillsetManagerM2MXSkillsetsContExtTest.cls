/*
 * Test class for  SkillsetManagerM2MXSkillsetsContExt class which an ext class for Skillset Manager page. 
 *
 * @author Malay Desai
 */
@isTest
private class SkillsetManagerM2MXSkillsetsContExtTest {

    static testMethod void TestSaveSkillset(){
        Account oAccount = TestServices.createAccount('TestAccount');
        insert oAccount;
        
        Contact oContact = TestServices.createContact('TestContact', oAccount.Id);
        insert oContact;     
        
        M2MX_Skillsets__c oSkillset = TestServices.createSkillset(oContact.Id, null, null,null);
        
        ApexPages.StandardController oStandardController = new ApexPages.StandardController(oSkillset); 
        
        SkillsetManagerM2MXSkillsetsContExt.testContactId = oContact.Id;
        SkillsetManagerM2MXSkillsetsContExt oSkillsetManagerM2MXSkillsetsContExt = new SkillsetManagerM2MXSkillsetsContExt(oStandardController);
        oSkillsetManagerM2MXSkillsetsContExt.oSkillset.Category__c = 'test1';
        oSkillsetManagerM2MXSkillsetsContExt.oSkillset.Sub_Category__c = 'test2';
        oSkillsetManagerM2MXSkillsetsContExt.oSkillset.Expertise__c = 'test3';
        
        // Added on 20 Feb 2016
        insert new Skillsets_Expertise__c(Category__c = 'test1', Sub_Category__c = 'test2', Expertise__c = 'test3');
         
        Test.startTest();
        oSkillsetManagerM2MXSkillsetsContExt.filterExpertise(); // Added on 20 Feb 2016
        oSkillsetManagerM2MXSkillsetsContExt.oSkillsetExpertise[0].isChecked = true; // Added on 20 Feb 2016
        oSkillsetManagerM2MXSkillsetsContExt.saveSkillset();
        Test.stopTest();
        
        List<M2MX_Skillsets__c> lstSkillset = [SELECT Category__c, Sub_Category__c FROM M2MX_Skillsets__c];
        system.assertEquals(1, lstSkillset.size());
        system.assertEquals('test1', lstSkillset[0].Category__c);
        system.assertEquals('test2', lstSkillset[0].Sub_Category__c);
        system.assertEquals(1, oSkillsetManagerM2MXSkillsetsContExt.lstSkillsets.size());
    }
    
}