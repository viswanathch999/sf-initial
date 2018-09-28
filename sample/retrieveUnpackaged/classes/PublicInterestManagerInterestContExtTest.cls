@isTest
public class PublicInterestManagerInterestContExtTest {
    
    static testMethod void testgivenContact_WhenAddedInterest_ThenInterestSavedToDB()
    {
        Account oAccount = TestServices.createAccount('TestAccount');
        insert oAccount;
        
        Contact oContact = TestServices.createContact(oAccount.Id);
        insert oContact;
        
        Interest__c oInterest = TestServices.createInterest(oContact.Id, null, null);
        
        ApexPages.StandardController oStandardController = new ApexPages.StandardController(oInterest); 
        
        PublicInterestManagerInterestContExt.testContactId = oContact.Id;
        PublicInterestManagerInterestContExt oPublicInterestManagerInterestContExt = new PublicInterestManagerInterestContExt(oStandardController);
        oPublicInterestManagerInterestContExt.oInterest.Category__c = 'test1';
        oPublicInterestManagerInterestContExt.oInterest.Interest__c = 'test2';
         
        Test.startTest();
        oPublicInterestManagerInterestContExt.saveInterest();
        Test.stopTest();
        
        List<Interest__c> lstInterest = [SELECT Category__c, Interest__c FROM Interest__c];
        system.assertEquals(1, lstInterest.size());
        system.assertEquals('test1', lstInterest[0].Category__c);
        system.assertEquals('test2', lstInterest[0].Interest__c);
        system.assertEquals(1, oPublicInterestManagerInterestContExt.lstInterests.size());
    }
    
    static testMethod void testgivenContact_WhenAUpdated_ThenSavedToDB()
    {
        Account oAccount = TestServices.createAccount('TestAccount');
        insert oAccount;
        
        Contact oContact = TestServices.createContact(oAccount.Id);
        insert oContact;
        
        Interest__c oInterest = TestServices.createInterest(oContact.Id, null, null);
        
        ApexPages.StandardController oStandardController = new ApexPages.StandardController(oInterest);
        
        PublicInterestManagerInterestContExt.testContactId = oContact.Id;
        PublicInterestManagerInterestContExt oPublicInterestManagerInterestContExt = new PublicInterestManagerInterestContExt(oStandardController);
        oPublicInterestManagerInterestContExt.oContact.Golf_Clubs__c = 'test1';
        
        Test.startTest();
        oPublicInterestManagerInterestContExt.saveContact();
        Test.stopTest();
        
        oContact = [SELECT Golf_Clubs__c FROM Contact WHERE id =: oContact.Id];
        system.assertEquals('test1', oContact.Golf_Clubs__c);
    }
    
    static testMethod void testgivenContact_WhenClickedOnCancel_ThenReturnedToContactdetail()
    {
        Account oAccount = TestServices.createAccount('TestAccount');
        insert oAccount;
        
        Contact oContact = TestServices.createContact(oAccount.Id);
        insert oContact;
        
        Interest__c oInterest = TestServices.createInterest(oContact.Id, null, null);
        
        ApexPages.StandardController oStandardController = new ApexPages.StandardController(oInterest);
        
        PublicInterestManagerInterestContExt.testContactId = oContact.Id;
        PublicInterestManagerInterestContExt oPublicInterestManagerInterestContExt = new PublicInterestManagerInterestContExt(oStandardController);
        
        Test.startTest();
        PageReference oPageReference = oPublicInterestManagerInterestContExt.returnToContact();
        Test.stopTest();
        
        system.assertEquals('/' + oContact.Id, oPageReference.getUrl() );
    }
    
    static testMethod void testgivenNoContact_WhenQueriedOnInterest_thenNoInterestFound()
    {
        Account oAccount = TestServices.createAccount('TestAccount');
        insert oAccount;
        
        Contact oContact = TestServices.createContact(oAccount.Id);
        insert oContact;
        
        Interest__c oInterest = TestServices.createInterest(oContact.Id, null, null);
        
        ApexPages.StandardController oStandardController = new ApexPages.StandardController(oInterest);
        
        Test.startTest();
        PublicInterestManagerInterestContExt oPublicInterestManagerInterestContExt = new PublicInterestManagerInterestContExt(oStandardController);
        Test.stopTest();
        
        system.assertEquals(null, oPublicInterestManagerInterestContExt.lstInterests); 
    }
}