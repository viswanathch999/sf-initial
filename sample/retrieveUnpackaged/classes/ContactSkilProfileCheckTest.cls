@isTest
private class ContactSkilProfileCheckTest  {

	@TestSetup static void setup(){
		Map<String, Schema.RecordTypeInfo> accountRecordTypes = new Map<String, Schema.RecordTypeInfo> (RecordTypeServices.getRecordType('Account'));
		Map<String, Schema.RecordTypeInfo> contactRecordTypes = new Map<String, Schema.RecordTypeInfo> (RecordTypeServices.getRecordType('Contact'));

		insert new Profile_Completion_Criteria__c(Name = 'Initial Criteria', Interests__c = 1, Business_Expertise__c = 1);

		Account testAccount = TestServices.createAccount('Test Chapter Name');
		testAccount.Type = 'Chapter';
		testAccount.RecordTypeId = accountRecordTypes.get('Chapter').getRecordTypeId();
		insert testAccount;

		Contact testContact = TestServices.createContact(testAccount.Id);
		testContact.RecordTypeId = contactRecordTypes.get('Member').getRecordTypeId();
		insert testContact;	

		insert new Contact_Skill_Option__c(Category_Contact_Skill_Option__c = 'Finance', Theme_Contact_Skill_Option__c = 'Business');
	}

	@isTest
	private static void insertExpertiseContactSkill() {
		Account acct = [Select Id FROM Account WHERE Name = 'Test Chapter Name' LIMIT 1];
		Contact cont = [Select Id From Contact WHERE LastName = 'TestLN' LIMIT 1];
		Contact_Skill_Option__c testContSkill = [Select Id FROM Contact_Skill_Option__c LIMIT 1];

		insert new Contact_Skill__c(Contact_on_Contact_Skill__c = cont.Id, Type_Contact_Skill__c = 'Expertise', Contact_Skill_Option_ID__c = testContSkill.Id, Active_Contact_Skill__c = true);

		Contact_Profile_Completion__c contProfileComp = [Select Business_Expertise__c FROM Contact_Profile_Completion__c WHERE Contact__c = :cont.id];

		System.assert(contProfileComp.Business_Expertise__c == 100, 'Contact Expertise Didn\'t Change to 100%');
	}

	@isTest
	private static void insertInterestContactSkill() {
		Account acct = [Select Id FROM Account WHERE Name = 'Test Chapter Name' LIMIT 1];
		Contact cont = [Select Id From Contact WHERE LastName = 'TestLN' LIMIT 1];
		Contact_Skill_Option__c testContSkill = [Select Id FROM Contact_Skill_Option__c LIMIT 1];

		insert new Contact_Skill__c(Contact_on_Contact_Skill__c = cont.Id, Type_Contact_Skill__c = 'Interest', Contact_Skill_Option_ID__c = testContSkill.Id, Active_Contact_Skill__c = true);

		Contact_Profile_Completion__c contProfileComp = [Select Interests__c FROM Contact_Profile_Completion__c WHERE Contact__c = :cont.id];

		System.assert(contProfileComp.Interests__c == 100, 'Contact Interest Didn\'t Change to 100%');
	}

	@isTest
	private static void insertMultipleContactSkill() {
		Account acct = [Select Id FROM Account WHERE Name = 'Test Chapter Name' LIMIT 1];
		Contact cont = [Select Id From Contact WHERE LastName = 'TestLN' LIMIT 1];
		Contact_Skill_Option__c testContSkill = [Select Id FROM Contact_Skill_Option__c LIMIT 1];

		insert new Contact_Skill__c(Contact_on_Contact_Skill__c = cont.Id, Type_Contact_Skill__c = 'Interest', Contact_Skill_Option_ID__c = testContSkill.Id, Active_Contact_Skill__c = true);

		Contact_Profile_Completion__c contProfileComp = [Select Interests__c FROM Contact_Profile_Completion__c WHERE Contact__c = :cont.id];

		System.assert(contProfileComp.Interests__c == 100, 'Contact Interest Didn\'t Change to 100%');

		insert new Contact_Skill__c(Contact_on_Contact_Skill__c = cont.Id, Type_Contact_Skill__c = 'Expertise', Contact_Skill_Option_ID__c = testContSkill.Id, Active_Contact_Skill__c = true);

		contProfileComp = [Select Business_Expertise__c FROM Contact_Profile_Completion__c WHERE Contact__c = :cont.id];

		System.assert(contProfileComp.Business_Expertise__c == 100, 'Contact Interest Didn\'t Stay at 100%');
	}
}