@isTest 
private class Utility_Test {

	@TestSetup
	static void setup() {
		Profile prof = [SELECT Id FROM Profile WHERE Name = :Label.Customer_Community_User_Custom LIMIT 1];

        Account chapterAccount = (Account) SObjectFactory.build(Account.SObjectType);
        chapterAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chapter').getRecordTypeId();
        chapterAccount.Type = 'Chapter';
        chapterAccount.YPOI_Type__c = 'YPO Chapter';
		insert chapterAccount;
        
        Contact testContact = (Contact) SObjectFactory.build(Contact.SObjectType);
        testContact.FirstName = 'Test First Name';
        testContact.Lastname = 'Test last Name';
        testContact.Gender__c = 'Male';
        testContact.Email = 'test.name@gmail.com';
        testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        testContact.Date_Last_Profile_Updated__c = Date.Today().addDays(-1);
		testContact.Is_Address2_Primary__c = true;
        testContact.AccountId = chapterAccount.Id;
		testContact.MailingStreet = '123 Any St.\r\nSuite 120';
		testContact.MailingCity = 'Anytown';
		testContact.MailingState = 'Florida';
		testContact.MailingCountry = 'United States';
		testContact.OtherStreet = '456 Some St.';
		testContact.OtherCity = 'Sometown';
		testContact.OtherState = 'Alabama';
		testContact.OtherCountry = 'United States';

        insert testContact;

        Account Household1 = new Account();
        Household1.Name = testContact.name + ' Household';
        Household1.Type = 'Relationship';
        Household1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship').getRecordTypeId();
				
		insert Household1;
        
	}

	static testmethod void test_getPageParameterValue() {
		contact mycontact = [Select Id, name From Contact Where Email = 'test.name@gmail.com'];
		Account myhousehold = [Select Id From Account where name like '%Household'];
		PageReference mypage = page.updateprofileinfo_ypo;
		Test.setCurrentPage(mypage);
        ApexPages.currentPage().getParameters().put('id', mycontact.id);

		Test.startTest();
			id myContactid = Utility.getPageParameterValue('Id');
		Test.stopTest();

		System.assertEquals(mycontact.Id,myContactid,'The page parameter didn`t get returned properly.');
	}

	static testmethod void test_createRelationship() {
		contact mycontact = [Select Id, name From Contact Where Email = 'test.name@gmail.com'];
		Account myhousehold = [Select Id From Account where name like '%Household'];

		Test.startTest();
			Relationship__c newRel = Utility.createRelationship(mycontact.Id, myhousehold.id,'Member');
			insert newRel;
		Test.stopTest();

		List<Relationship__c> householdlist = [Select Id From Relationship__c Where Contact__c = :mycontact.id];
		System.assertEquals(1,householdlist.size(),'A Relationship record should have been created for the user.');
	}

	static testmethod void test_SanitizeString() {
		string testnull;
		string testvalue = 'string value';

		System.assertEquals('',Utility.SanitizeString(testnull),'Supposed to return an empty string for a null value!');
		system.assertEquals(testvalue,Utility.SanitizeString(testvalue),'Supposed to return the string sent in!');
	}
}