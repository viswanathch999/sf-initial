@isTest
private class TestGraceExtension_YPO {
	static Contact testContact;
    static User testUser;
    static Opportunity testOpp;
    
    private static void setupContactForPage()
    {
		Account ChapterAccount = TestServices.createChapterAccount('Test Chapter',Null);
        testContact = TestServices.createContact(ChapterAccount.id,true);
        testOpp = TestServices.createOpp('Cycle Open',ChapterAccount.id,testContact.Id,true);
        
        User runningUser = [SELECT Id FROM User Where Profile.Name = 'System Administrator' and isActive=true LIMIT 1];
        System.runAs(runningUser)
        {
            testUser = (User) SObjectFactory.create(User.SObjectType);
        }
    }

	static testMethod void RedirectToTest() 
	{
		setupContactForPage();
		PageReference expectedPage = Page.Recertification_Screen;
		ApexPages.StandardController stdCont = new ApexPages.StandardController(testContact);
		GraceExtension_YPO contExt = new GraceExtension_YPO(stdCont);
		
		Test.startTest();
			PageReference currentPage = contExt.redirectTo();
		Test.stopTest();

		System.assert(currentPage.getUrl().contains(expectedPage.getUrl()),'We expect to be redirect to the correct page. Expected: '+expectedPage.getUrl()+' Actual: ' + currentPage.getUrl());	

	}
	
	static testMethod void testProperties() {
		setupContactForPage();
		
		User runningUser = [SELECT Id FROM User Where Profile.Name = 'System Administrator' and isActive=true LIMIT 1];
		Id standardProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
		Id communityProfileId = [SELECT Id FROM Profile WHERE Name = 'Partner Community User'].Id;
		Id  userRoleId = [SELECT Id FROM UserRole WHERE PortalType = 'Partner' LIMIT 1].Id;
		User standardUser;
		Contact oContact;
		User oUser;
		
		UserRole standardRole = new UserRole(name = 'TEST ROLE');
		System.runAs(runningUser) {
			insert standardRole;
			standardUser = (User) SObjectFactory.build(User.SObjectType);
			standardUser.ProfileId = standardProfileId;
			standardUser.UserRoleId = standardRole.Id;
			insert standardUser;
		}
		
		List<Exception_Reason__c> ExcptReasons = new List<Exception_Reason__c>();
			ExcptReasons.add(new Exception_Reason__c(Name='Other',category__c = 'Other'));
			ExcptReasons.add(new Exception_Reason__c(Name='Waiver',category__c = 'Waiver'));
		insert ExcptReasons;

		PageReference expectedPage = Page.Recertification_Screen;
		expectedPage.getParameters().put('Id',testContact.Id);

		ApexPages.StandardController stdCont = new ApexPages.StandardController(testContact);
		GraceExtension_YPO contExt = new GraceExtension_YPO(stdCont);
        
		String testStr;
		Boolean testBool;
		List<SelectOPtion> opts = new List<SelectOption>();
		PageReference pr; 
		
		Test.startTest();
			contExt.init();
			testBool = contExt.hasGrace;
			testStr = contExt.graceReasonSelected;
			testStr = contExt.exceptionDesc;
			contExt.oOpp = testOpp;
			pr = contExt.createGraceCase();
			opts = contExt.graceReasons2;

			testOpp.StageName = 'Payment Pending';
			pr = contExt.createGraceCase();
		Test.stopTest();
		
	}
	
}