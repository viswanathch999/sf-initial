@isTest
private class SplashScreenController_YPOTest {

    static Contact testContact;
	static User testUser;
	static Opportunity testOpp;

	static void setupData()
	{
		Id communityProfileId = [SELECT Id FROM Profile WHERE Name = 'Partner Community User'].Id;
		Id  userRoleId = [SELECT Id FROM UserRole WHERE PortalType = 'Partner' LIMIT 1].Id;
		account ChapterAccount = TestServices.createChapterAccount('Test Chapter',null);
		insert ChapterAccount;

		testContact = TestServices.createContact(ChapterAccount.id,'TestRenewal23',true);

		//User runningUser = [SELECT Id FROM User Where Profile.Name = 'System Administrator' and isActive=true LIMIT 1];
		//System.runAs(runningUser)
		//{
			//testUser = (User) SObjectFactory.build(User.SObjectType,User.ContactId,testContact.Id);
			//testUser.ProfileId = communityProfileId;
			//testUser.UserRoleId = userRoleId;
			//testUser.ContactId = testContact.Id;
			//insert testUser;	
		//}
		
		testOpp = TestServices.createOpp('Payment Received',testContact.AccountId,testContact.Id,true);


	}
	
	@isTest static void testConstructor() {
		setupData();
		
		Test.setCurrentPage(Page.SplashScreen_Thankyou);
		ApexPages.StandardController standCon = new ApexPages.StandardController(testContact);
		SplashScreenController_YPO conExt = new SplashScreenController_YPO(standCon);

		delete testopp;
		testOpp = TestServices.createOpp('New',testContact.AccountId,testContact.Id,true);
		
		Test.setCurrentPage(Page.SplashScreen_Thankyou);
		standCon = new ApexPages.StandardController(testContact);
		conExt = new SplashScreenController_YPO(standCon);

	}
	
	@isTest static void testBooleans() {
		setupData();
		
		Test.setCurrentPage(Page.SplashScreen_Thankyou);
		ApexPages.StandardController standCon = new ApexPages.StandardController(testContact);
		SplashScreenController_YPO conExt = new SplashScreenController_YPO(standCon);

		System.assert(!conExt.displayGraceModal, 'We expect the boolean to be properly set.');
		System.assert(!conExt.displayTransitionModal, 'We expect the boolean to be properly set.');
		System.assert(!conExt.isCheckWire, 'We expect the boolean to be properly set.');
		System.assert(conExt.isCreditCard, 'We expect the boolean to be properly set.');
	}
}