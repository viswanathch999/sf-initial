@isTest
private class AccountAffiliationRTExtensionTest{

	@TestSetup static void setup(){
		insert new Profile_Completion_Criteria__c(Name = 'Initial Criteria', Biography__c = 1);

		Contact con = new Contact(lastName = 'TestName', Int_General__c = 'Male', Email = 'Test@test.com', RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId());
		insert con;

		Account acct = new Account(name = 'test123', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId());
		insert acct;

		Account_Affiliation__c AA = new Account_Affiliation__c(contact__c = con.Id, account__c = acct.Id, recordTypeId = Schema.SObjectType.Account_Affiliation__c.getRecordTypeInfosByName().get('Business').getRecordTypeId(), start_date__c = System.today());
		insert AA;
	}

	@isTest
	private static void businessAA() {
		PageReference pageRef = Page.AccountAffliationRecordType;
		Test.setCurrentPage(pageRef);
		Account_Affiliation__c AA = [Select ID from Account_Affiliation__c where Start_Date__c = :System.today()];
		ApexPages.currentPage().getParameters().put('id', AA.id);
		ApexPages.StandardController stdAA = new ApexPages.StandardController(AA);
		AccountAffliatoinRecordTypeExtension stdController = new AccountAffliatoinRecordTypeExtension(stdAA);

		stdController.recordTypeName = Schema.SObjectType.Account_Affiliation__c.getRecordTypeInfosByName().get('Business').getRecordTypeId();

		stdController.redirectRecordType();

	}

	@IsTest
	private static void nonBusinessAA(){
		PageReference pageRef = Page.AccountAffliationRecordType;
		Test.setCurrentPage(pageRef);
		Account_Affiliation__c AA = [Select ID from Account_Affiliation__c where Start_Date__c = :System.today()];
		ApexPages.currentPage().getParameters().put('id', AA.id);
		ApexPages.StandardController stdAA = new ApexPages.StandardController(AA);
		AccountAffliatoinRecordTypeExtension stdController = new AccountAffliatoinRecordTypeExtension(stdAA);

		stdController.recordTypeName = Schema.SObjectType.Account_Affiliation__c.getRecordTypeInfosByName().get('Chapter').getRecordTypeId();

		stdController.redirectRecordType();	
	}
}