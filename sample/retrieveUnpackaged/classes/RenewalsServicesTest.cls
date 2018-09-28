@isTest
private class RenewalsServicesTest {

	static Contact testContact;
	static User testUser;
	static User standarduser;
	static String transitionStatus;

    static void setupData()
	{
		User runningUser = [SELECT Id FROM User Where Profile.Name = 'System Administrator' and isActive=true LIMIT 1];
		Id standardProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
		Id communityProfileId = [SELECT Id FROM Profile WHERE Name = 'Partner Community User'].Id;
		Id  userRoleId = [SELECT Id FROM UserRole WHERE PortalType = 'Partner' LIMIT 1].Id;
		
		UserRole standardRole = new UserRole(name = 'TEST ROLE');
		System.runAs(runningUser) {
			insert standardRole;
			standardUser = (User) SObjectFactory.build(User.SObjectType);
			standardUser.ProfileId = standardProfileId;
			standardUser.UserRoleId = standardRole.Id;
			insert standardUser;
		}
		
		Account testAccount = (Account) SObjectFactory.build(Account.SObjectType);
        testAccount.Type ='Chapter';
        testAccount.OwnerId = standardUser.Id;
        insert testAccount;
        
		testContact = (Contact) SObjectFactory.build(Contact.SObjectType);
		testContact.AccountId = testAccount.Id;
		insert testContact;
		
		testUser = (User) SObjectFactory.build(User.SObjectType,User.ContactId,testContact.Id);
		testUser.ProfileId = communityProfileId;
		System.debug('###testUser: ' + testUser);
		insert testUser;
        
	}
    	
	@isTest static void testRenewelsPositive() {
		transitionStatus = 'Eligible for early transition';
		setUpData();

		testContact.Lifetime_Dues_Status__c = '';

        PageReference expectedpage = Page.Catalog_YPO;

        Test.startTest();
             Pagereference actualPage = RenewalsServices.lifetimeOptionCheck(testContact);
        Test.stopTest();

        System.assert(actualPage.getUrl().contains(expectedpage.getUrl()),'It should be navigated to life time option ypo page' +actualPage.getUrl()+expectedpage.getUrl());
        System.assert(actualPage.getUrl().contains(testContact.Id),'It should contain test contact Id');

	}

	@isTest static void testRenewelsNegative() {
		transitionStatus = '';
		setUpData();
		testContact.Lifetime_Dues_Status__c = '';

        PageReference expectedpage = Page.Catalog_YPO;

        Test.startTest();
             Pagereference actualPage = RenewalsServices.lifetimeOptionCheck(testContact);
        Test.stopTest();

        System.assert(actualPage.getUrl().contains(expectedpage.getUrl()),'It should be navigated to catalog page'+actualPage.getUrl()+expectedpage.getUrl());
        System.assert(actualPage.getUrl().contains(testContact.Id),'It should contain test contact Id');

	}	
	
}