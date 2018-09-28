@isTest
private class AccountAffiliationProfileCheckTest {

	@TestSetup static void setup() {
		Map<String, Schema.RecordTypeInfo> accountRecordTypes = new Map<String, Schema.RecordTypeInfo> (RecordTypeServices.getRecordType('Account'));
		Map<String, Schema.RecordTypeInfo> contactRecordTypes = new Map<String, Schema.RecordTypeInfo> (RecordTypeServices.getRecordType('Contact'));

		insert new Profile_Completion_Criteria__c(Name = 'Initial Criteria', Education__c = 1, Business_Role__c = 1, Company_Name__c = 1, Company_Industry_Category__c = 1, Company_Address__c = 1, Business_Scope__c = 1, Type_of_President__c = 1, Company_Size__c = 1);

		Account testAccount = TestServices.createAccount('Test Chapter Name');
		testAccount.Type = 'Chapter';
		testAccount.RecordTypeId = accountRecordTypes.get('Chapter').getRecordTypeId();
		insert testAccount;

		Account testSchool = TestServices.createAccount('Test School Name');
		testSchool.Type = 'School';
		testSchool.RecordTypeId = accountRecordTypes.get('School').getRecordTypeId();
		insert testSchool;

		Contact testContact = TestServices.createContact(testAccount.Id);
		testContact.RecordTypeId = contactRecordTypes.get('Member').getRecordTypeId();
		insert testContact;

	}

	@isTest
	private static void insertBusinessAA() {
		Map<String, Schema.RecordTypeInfo> accountAffiliationRecordTypes = new Map<String, Schema.RecordTypeInfo> (RecordTypeServices.getRecordType('Account_Affiliation__c'));
		Account acct = [Select Id FROM Account WHERE Name = 'Test Chapter Name' LIMIT 1];
		Contact cont = [Select Id From Contact LIMIT 1];

		insert new Account_Affiliation__c(Contact__c = cont.Id, Account__c = acct.Id, RecordTypeId = accountAffiliationRecordTypes.get('Business').getRecordTypeId(), Start_Date__c = System.today(), is_Primary__c = true, isActive__c = true,
		                                  Business_Role__c = 'Owner', Industry_Category_1__c = 'Agriculture', Street__c = '123 1st Street', Scope_of_Business__c = 'Local', Job_Title__c = 'President', Company_Size__c = '25 to 50');

		Contact_Profile_Completion__c contProfileComp = [Select Business_Role__c, Company_Name__c, Company_Industry_Category__c, Company_Address__c, Business_Scope__c, Type_of_President__c, Company_Size__c FROM Contact_Profile_Completion__c WHERE Contact__c = :cont.id];

		System.assert(contProfileComp.Business_Role__c == 100, 'Business Role Didn\'t Change to 100%');
		System.assert(contProfileComp.Company_Name__c == 100, 'Company Name Didn\'t Change to 100%');
		System.assert(contProfileComp.Company_Industry_Category__c == 100, 'Company Industry Didn\'t Change to 100%');
		System.assert(contProfileComp.Company_Address__c == 100, 'Company Address Didn\'t Change to 100%');
		System.assert(contProfileComp.Business_Scope__c == 100, 'Business Scope Didn\'t Change to 100%');
		System.assert(contProfileComp.Type_of_President__c == 100, 'Type of President Didn\'t Change to 100%');
		System.assert(contProfileComp.Company_Size__c == 100, 'Company Size Didn\'t Change to 100%');
	}

	@isTest
	private static void insertEducationAA() {
		Map<String, Schema.RecordTypeInfo> accountAffiliationRecordTypes = new Map<String, Schema.RecordTypeInfo> (RecordTypeServices.getRecordType('Account_Affiliation__c'));
		Account acct = [Select Id FROM Account WHERE Name = 'Test Chapter Name' LIMIT 1];
		Contact cont = [Select Id From Contact LIMIT 1];

		insert new Account_Affiliation__c(Contact__c = cont.Id, Account__c = acct.Id, RecordTypeId = accountAffiliationRecordTypes.get('School').getRecordTypeId(), Start_Date__c = System.today(), isActive__c = true);

		Contact_Profile_Completion__c contProfileComp = [Select Education__c FROM Contact_Profile_Completion__c WHERE Contact__c = :cont.id];

		System.assert(contProfileComp.Education__c == 100, 'Education Didn\'t Change to 100%');
	}

	@isTest
	private static void updateBusinessAA() {
		Map<String, Schema.RecordTypeInfo> accountAffiliationRecordTypes = new Map<String, Schema.RecordTypeInfo> (RecordTypeServices.getRecordType('Account_Affiliation__c'));
		Account acct = [Select Id FROM Account WHERE Name = 'Test Chapter Name' LIMIT 1];
		Contact cont = [Select Id From Contact LIMIT 1];

		Account_Affiliation__c a = new Account_Affiliation__c(Contact__c = cont.Id, Account__c = acct.Id, RecordTypeId = accountAffiliationRecordTypes.get('Business').getRecordTypeId(), Start_Date__c = System.today(), is_Primary__c = true, isActive__c = true,
		                                                      Business_Role__c = 'Owner', Industry_Category_1__c = 'Agriculture', Street__c = '123 1st Street', Scope_of_Business__c = 'Local', Job_Title__c = 'President', Company_Size__c = '25 to 50');

		insert a;

		a.Industry_Category_1__c = null;
		a.Street__c = null;
		a.Scope_of_Business__c = null;
		a.Business_Role__c = null;
		a.Company_Size__c = null;
		a.Organization_Type__c = null;

		update a;

		Contact_Profile_Completion__c contProfileComp = [Select Company_Address__c FROM Contact_Profile_Completion__c WHERE Contact__c = :cont.id];

		System.assert(contProfileComp.Company_Address__c == 0, 'Company Address Didn\'t Change to 0%');

	}

	@isTest
	private static void updateEducationAA() {
		Map<String, Schema.RecordTypeInfo> accountAffiliationRecordTypes = new Map<String, Schema.RecordTypeInfo> (RecordTypeServices.getRecordType('Account_Affiliation__c'));
		Account acct = [Select Id FROM Account WHERE Name = 'Test Chapter Name' LIMIT 1];
		Contact cont = [Select Id From Contact LIMIT 1];

		Account_Affiliation__c a = new Account_Affiliation__c(Contact__c = cont.Id, Account__c = acct.Id, RecordTypeId = accountAffiliationRecordTypes.get('School').getRecordTypeId(), Start_Date__c = System.today(), isActive__c = false);

		insert a;

		Contact_Profile_Completion__c contProfileComp = [Select Education__c FROM Contact_Profile_Completion__c WHERE Contact__c = :cont.id];

		System.assert(contProfileComp.Education__c == 0, 'Education Didn\'t Stay at 0%');

		a.IsActive__c = true;

		update a;

		contProfileComp = [Select Education__c FROM Contact_Profile_Completion__c WHERE Contact__c = :cont.id];

		System.assert(contProfileComp.Education__c == 100, 'Company Address Didn\'t Change to 100%');

		a.IsActive__c = false;

		update a;

		contProfileComp = [Select Education__c FROM Contact_Profile_Completion__c WHERE Contact__c = :cont.id];

		System.assert(contProfileComp.Education__c == 0, 'Company Address Didn\'t Change to 0%');

	}


	@isTest
	private static void deactivateBusinessAA() {
		Map<String, Schema.RecordTypeInfo> accountAffiliationRecordTypes = new Map<String, Schema.RecordTypeInfo> (RecordTypeServices.getRecordType('Account_Affiliation__c'));
		Account acct = [Select Id FROM Account WHERE Name = 'Test Chapter Name' LIMIT 1];
		Account acctSchool = [Select Id FROM Account WHERE Name = 'Test School Name' LIMIT 1];
		Contact cont = [Select Id From Contact LIMIT 1];

		Account_Affiliation__c Business = new Account_Affiliation__c(Contact__c = cont.Id, Account__c = acct.Id, RecordTypeId = accountAffiliationRecordTypes.get('Business').getRecordTypeId(), Start_Date__c = System.today(), is_Primary__c = true, isActive__c = true,
		                                                             Business_Role__c = 'Owner', Industry_Category_1__c = 'Agriculture', Street__c = '123 1st Street', Scope_of_Business__c = 'Local', Job_Title__c = 'President', Company_Size__c = '25 to 50');

		insert Business;

		Contact_Profile_Completion__c contProfileComp = [Select Business_Role__c, Company_Name__c, Company_Industry_Category__c, Company_Address__c, Business_Scope__c, Type_of_President__c, Company_Size__c FROM Contact_Profile_Completion__c WHERE Contact__c = :cont.id];

		System.assert(contProfileComp.Business_Role__c == 100, 'Business Role Didn\'t Change to 100%');
		System.assert(contProfileComp.Company_Name__c == 100, 'Company Name Didn\'t Change to 100%');
		System.assert(contProfileComp.Company_Industry_Category__c == 100, 'Company Industry Didn\'t Change to 100%');
		System.assert(contProfileComp.Company_Address__c == 100, 'Company Address Didn\'t Change to 100%');
		System.assert(contProfileComp.Business_Scope__c == 100, 'Business Scope Didn\'t Change to 100%');
		System.assert(contProfileComp.Type_of_President__c == 100, 'Type of President Didn\'t Change to 100%');
		System.assert(contProfileComp.Company_Size__c == 100, 'Company Size Didn\'t Change to 100%');


		insert new Account_Affiliation__c(Contact__c = cont.Id, Account__c = acctSchool.Id, RecordTypeId = accountAffiliationRecordTypes.get('School').getRecordTypeId(), Start_Date__c = System.today(), isActive__c = true);

		contProfileComp = [Select Education__c, Business_Role__c, Company_Name__c, Company_Industry_Category__c, Company_Address__c, Business_Scope__c, Type_of_President__c, Company_Size__c FROM Contact_Profile_Completion__c WHERE Contact__c = :cont.id];

		System.assert(contProfileComp.Education__c == 100, 'Education Didn\'t Change to 100%');

		System.assert(contProfileComp.Business_Role__c == 100, 'Business Role Didn\'t Stay to 100%');
		System.assert(contProfileComp.Company_Name__c == 100, 'Company Name Didn\'t Stay to 100%');
		System.assert(contProfileComp.Company_Industry_Category__c == 100, 'Company Industry Didn\'t Stay to 100%');
		System.assert(contProfileComp.Company_Address__c == 100, 'Company Address Didn\'t Stay to 100%');
		System.assert(contProfileComp.Business_Scope__c == 100, 'Business Scope Didn\'t Stay to 100%');
		System.assert(contProfileComp.Type_of_President__c == 100, 'Type of President Didn\'t Stay to 100%');
		System.assert(contProfileComp.Company_Size__c == 100, 'Company Size Didn\'t Stay to 100%');

		Business.IsActive__c = false;

		update Business;

		contProfileComp = [Select Education__c, Business_Role__c, Company_Name__c, Company_Industry_Category__c, Company_Address__c, Business_Scope__c, Type_of_President__c, Company_Size__c FROM Contact_Profile_Completion__c WHERE Contact__c = :cont.id];

		System.assert(contProfileComp.Business_Role__c == 0, 'Business Role Didn\'t Change to 0%');
		System.assert(contProfileComp.Company_Name__c == 0, 'Company Name Didn\'t Change to 0%');
		System.assert(contProfileComp.Company_Industry_Category__c == 0, 'Company Industry Didn\'t Change to 0%');
		System.assert(contProfileComp.Company_Address__c == 0, 'Company Address Didn\'t Change to 0%');
		System.assert(contProfileComp.Business_Scope__c == 0, 'Business Scope Didn\'t Change to 0%');
		System.assert(contProfileComp.Type_of_President__c == 0, 'Type of President Didn\'t Change to 0%');
		System.assert(contProfileComp.Company_Size__c == 0, 'Company Size Didn\'t Change to 0%');

		System.assert(contProfileComp.Education__c == 100, 'Education Didn\'t Stay at 100%');
	}

	@isTest
	private static void deactivateEducationAA() {
		Map<String, Schema.RecordTypeInfo> accountAffiliationRecordTypes = new Map<String, Schema.RecordTypeInfo> (RecordTypeServices.getRecordType('Account_Affiliation__c'));
		Account acct = [Select Id FROM Account WHERE Name = 'Test Chapter Name' LIMIT 1];
		Account acctSchool = [Select Id FROM Account WHERE Name = 'Test School Name' LIMIT 1];
		Contact cont = [Select Id From Contact LIMIT 1];

		Account_Affiliation__c a = new Account_Affiliation__c(Contact__c = cont.Id, Account__c = acct.Id, RecordTypeId = accountAffiliationRecordTypes.get('School').getRecordTypeId(), Start_Date__c = System.today(), isActive__c = true);

		insert a;

		Contact_Profile_Completion__c contProfileComp = [Select Education__c FROM Contact_Profile_Completion__c WHERE Contact__c = :cont.id];

		System.assert(contProfileComp.Education__c == 100, 'Education Didn\'t Update tp 100%');

		a.IsActive__c = false;

		update a;

		contProfileComp = [Select Education__c FROM Contact_Profile_Completion__c WHERE Contact__c = :cont.id];

		System.assert(contProfileComp.Education__c == 0, 'Education Didn\'t Update tp 0%');
	}

	@isTest
	private static void updateMultipleBusinessAA() {
		Map<String, Schema.RecordTypeInfo> accountAffiliationRecordTypes = new Map<String, Schema.RecordTypeInfo> (RecordTypeServices.getRecordType('Account_Affiliation__c'));
		Account acct = [Select Id FROM Account WHERE Name = 'Test Chapter Name' LIMIT 1];
		Account acctSchool = [Select Id FROM Account WHERE Name = 'Test School Name' LIMIT 1];
		Contact cont = [Select Id From Contact LIMIT 1];

		List<Account_Affiliation__c> listBusiness = new List<Account_Affiliation__c> ();

		listBusiness.add(new Account_Affiliation__c(Contact__c = cont.Id, Account__c = acct.Id, RecordTypeId = accountAffiliationRecordTypes.get('Business').getRecordTypeId(), Start_Date__c = System.today(), is_Primary__c = true, isActive__c = true,
		                                            Business_Role__c = 'Owner', Industry_Category_1__c = 'Agriculture', Street__c = '123 1st Street', Scope_of_Business__c = 'Local', Job_Title__c = 'President', Company_Size__c = '25 to 50'));
		listBusiness.add(new Account_Affiliation__c(Contact__c = cont.Id, Account__c = acct.Id, RecordTypeId = accountAffiliationRecordTypes.get('Business').getRecordTypeId(), Start_Date__c = System.today(), is_Primary__c = false, isActive__c = true,
		                                            Business_Role__c = 'Owner', Industry_Category_1__c = 'Agriculture', Street__c = '123 1st Street', Scope_of_Business__c = 'Local', Job_Title__c = 'President', Company_Size__c = '25 to 50'));
		listBusiness.add(new Account_Affiliation__c(Contact__c = cont.Id, Account__c = acct.Id, RecordTypeId = accountAffiliationRecordTypes.get('Business').getRecordTypeId(), Start_Date__c = System.today(), is_Primary__c = false, isActive__c = false,
		                                            Business_Role__c = 'Owner', Industry_Category_1__c = 'Agriculture', Street__c = '123 1st Street', Scope_of_Business__c = 'Local', Job_Title__c = 'President', Company_Size__c = '25 to 50'));

		insert listBusiness;

		Contact_Profile_Completion__c contProfileComp = [Select Business_Role__c, Company_Name__c, Company_Industry_Category__c, Company_Address__c, Business_Scope__c, Type_of_President__c, Company_Size__c FROM Contact_Profile_Completion__c WHERE Contact__c = :cont.id];

		System.assert(contProfileComp.Business_Role__c == 100, 'Business Role Didn\'t Change to 100%');
		System.assert(contProfileComp.Company_Name__c == 100, 'Company Name Didn\'t Change to 100%');
		System.assert(contProfileComp.Company_Industry_Category__c == 100, 'Company Industry Didn\'t Change to 100%');
		System.assert(contProfileComp.Company_Address__c == 100, 'Company Address Didn\'t Change to 100%');
		System.assert(contProfileComp.Business_Scope__c == 100, 'Business Scope Didn\'t Change to 100%');
		System.assert(contProfileComp.Type_of_President__c == 100, 'Type of President Didn\'t Change to 100%');
		System.assert(contProfileComp.Company_Size__c == 100, 'Company Size Didn\'t Change to 100%');


		listBusiness[1].Industry_Category_1__c = null;

		update listBusiness;

		contProfileComp = [Select Business_Role__c, Company_Name__c, Company_Industry_Category__c, Company_Address__c, Business_Scope__c, Type_of_President__c, Company_Size__c FROM Contact_Profile_Completion__c WHERE Contact__c = :cont.id];

		System.assert(contProfileComp.Business_Role__c == 100, 'Business Role Didn\'t Stay to 100%');
		System.assert(contProfileComp.Company_Name__c == 100, 'Company Name Didn\'t Stay to 100%');
		System.assert(contProfileComp.Company_Industry_Category__c == 100, 'Company Industry Didn\'t Stay to 100%');
		System.assert(contProfileComp.Company_Address__c == 100, 'Company Address Didn\'t Stay to 100%');
		System.assert(contProfileComp.Business_Scope__c == 100, 'Business Scope Didn\'t Stay to 100%');
		System.assert(contProfileComp.Type_of_President__c == 100, 'Type of President Didn\'t Stay to 100%');
		System.assert(contProfileComp.Company_Size__c == 100, 'Company Size Didn\'t Stay to 100%');

		listBusiness[0].IsActive__c = false;
		listBusiness[0].Is_Primary__c = false;

		update listBusiness;

		contProfileComp = [Select Education__c, Business_Role__c, Company_Name__c, Company_Industry_Category__c, Company_Address__c, Business_Scope__c, Type_of_President__c, Company_Size__c FROM Contact_Profile_Completion__c WHERE Contact__c = :cont.id];

		System.assert(contProfileComp.Business_Role__c == 0, 'Business Role Didn\'t Change to 0%');
		System.assert(contProfileComp.Company_Name__c == 0, 'Company Name Didn\'t Change to 0%');
		System.assert(contProfileComp.Company_Industry_Category__c == 0, 'Company Industry Didn\'t Change to 0%');
		System.assert(contProfileComp.Company_Address__c == 0, 'Company Address Didn\'t Change to 0%');
		System.assert(contProfileComp.Business_Scope__c == 0, 'Business Scope Didn\'t Change to 0%');
		System.assert(contProfileComp.Type_of_President__c == 0, 'Type of President Didn\'t Change to 0%');
		System.assert(contProfileComp.Company_Size__c == 0, 'Company Size Didn\'t Change to 0%');
	}
}