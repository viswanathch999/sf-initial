@isTest
private class WelcomePageController_YPO_Test {

    static final Id ACCOUNT_RECORDTYPEID = [select Id  from RecordType  WHERE SObjectType=:'Account' AND DeveloperName ='Relationship' LIMIT 1].Id;
    static final Id CONTACT_RECORDTYPEID = [select Id  from RecordType  WHERE SObjectType=:'Contact' AND DeveloperName ='Prospect' LIMIT 1].Id;
    
    static testMethod void unittestWelcomeContrl_WithCon() {
        
        Account acc = new Account();
        acc.Name ='Test Account';
        acc.Type = 'Relationship';
        acc.RecordTypeId = ACCOUNT_RECORDTYPEID;
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test First Name';
        con.Lastname = 'Test last Name';
        con.Gender__c = 'Male';
        con.Email = 'test.name@gmail.com';
        con.RecordTypeId = CONTACT_RECORDTYPEID;
        con.AccountId = acc.Id;
        con.Active__c = false;
        insert con;
        
        Id p = [select id from profile where name=:Label.Customer_Community_User_Custom].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        ApexPages.currentPage().getParameters().put('id',con.Id);
        system.runAs(user){
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            WelcomePageController_YPO welcomecontrl = new WelcomePageController_YPO(sc);
			System.assert(!WelcomePageController_YPO.isThirdPartyCertify);
        }
    }

	static testMethod void unittestWelcomeContrl_WithoutCon() {
        
        Account acc = new Account();
        acc.Name ='Test Account';
        acc.Type = 'Relationship';
        acc.RecordTypeId = ACCOUNT_RECORDTYPEID;
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test First Name';
        con.Lastname = 'Test last Name';
        con.Gender__c = 'Male';
        con.Email = 'test.name@gmail.com';
        con.RecordTypeId = CONTACT_RECORDTYPEID;
        con.AccountId = acc.Id;
        con.Active__c = false;
        insert con;
        
        Id p = [select id from profile where name=:Label.Customer_Community_User_Custom].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        //ApexPages.currentPage().getParameters().put('id',con.Id);
        system.runAs(user){
            ApexPages.StandardController sc = new ApexPages.StandardController(new Contact());
            WelcomePageController_YPO welcomecontrl = new WelcomePageController_YPO(sc);
			System.assert(!WelcomePageController_YPO.isThirdPartyCertify);
        }
    }
}