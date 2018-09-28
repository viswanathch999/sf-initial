@isTest 
private class CustomAddressExtensionTest {

	@TestSetup static void setup(){
		Contact con = new Contact(lastName = 'TestName', Int_General__c = 'Male', Email = 'Test@test.com', RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId());
		insert con;

		Account acct = new Account(name = 'test123', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId());
		insert acct;

		Account_Affiliation__c AA = new Account_Affiliation__c(contact__c = con.Id, account__c = acct.Id, recordTypeId = Schema.SObjectType.Account_Affiliation__c.getRecordTypeInfosByName().get('Business').getRecordTypeId(), start_date__c = System.today());
		insert AA;
	}

	@isTest
	private static void editAA() {
		PageReference pageRef = Page.CustomAddress;
		Test.setCurrentPage(pageRef);

		Account_Affiliation__c AA = [Select ID from Account_Affiliation__c where Start_Date__c = :System.today()];
		ApexPages.currentPage().getParameters().put('id', AA.id);

		Test.startTest();
			ApexPages.StandardController stdController = new ApexPages.StandardController(AA);
			CustomAddressExtension stdAA = new CustomAddressExtension(stdController);
			stdAA.dummyAcct.BillingCountryCode = 'US';
			stdAA.dummyAcct.BillingStateCode = 'TX';
			stdAA.saveRecord();
		Test.stopTest();

		System.assertEquals('United States', stdAA.AA.Country__c);
		System.assertEquals('Texas', stdAA.AA.State__c);

	}

	@isTest
	private static void newAA() {
		PageReference pageRef = Page.CustomAddress;
		Test.setCurrentPage(pageRef);

		Account_Affiliation__c AA = new Account_Affiliation__c();
		Contact cont = [Select Id, Name From Contact where lastname = 'TestName'];
		Account acct = [Select Id From Account where name = 'test123'];

		ApexPages.currentPage().getParameters().put('contactId', cont.id);
		ApexPages.currentPage().getParameters().put('accountId', acct.id);

		Test.startTest();
			ApexPages.StandardController stdController = new ApexPages.StandardController(AA);
			CustomAddressExtension stdAA = new CustomAddressExtension(stdController);
			stdAA.dummyAcct.BillingCountryCode = 'US';
			stdAA.dummyAcct.BillingStateCode = 'TX';

		stdAA.saveRecord();
		Test.stopTest();

		System.assertEquals('United States', stdAA.AA.Country__c);
		System.assertEquals('Texas', stdAA.AA.State__c);

	}
}