@isTest 
private class OpportunityQualificationCheckTest {
	
	private static Opportunity testOpp { get; set; } 
	private static Contact testContact { get; set; } 


	public static void setup(String ident) {
		Account testChapter = new Account(
			Name = 'Test Chapter ' + ident, 
			RecordType = RecordTypeServices.getRecordTypeByDeveloperName('Chapter', 'Account')
		);
		insert testChapter;

		testContact = new Contact(
			FirstName = 'Test', 
			LastName = 'Member ' + ident, 
			AccountId = testChapter.Id, 
			RecordType = RecordTypeServices.getRecordTypeByDeveloperName('Member', 'Contact')
		);
		insert testContact;

		testOpp = new Opportunity(
			Name = 'Test Opp ' + ident, 
			KGRenewal__Contact__c = testContact.Id, 
			StageName = 'New', 
			CloseDate = Date.today().addDays(30)
		);
		insert testOpp;
	}


	// Requirement A
	@isTest
	private static void testReqA_Pass1() {
		System.debug('testReqA_Pass1');
		
		String ident = String.valueOf(Datetime.now().millisecond());
		setup(ident);

		testContact.Number_of_Employees__c = 1;
		update testContact;

		testOpp.NumberOfEmployees__c = 2;
		update testOpp;
		
		PageReference pageRef = Page.OpportunityQualificationCheck;
		pageRef.getParameters().put('id', testOpp.id);
		
		Test.startTest();
		Test.setCurrentPage(pageRef);
		OpportunityQualificationCheckCtrl ctrl = new OpportunityQualificationCheckCtrl();
		ctrl.checkQualifications();
		Test.stopTest();
	}


	@IsTest
	private static void testReqA_Pass2() {
		System.debug('testReqA_Pass2');
		
		String ident = String.valueOf(Datetime.now().millisecond());
		setup(ident);

		testContact.Number_of_Employees__c = 3;
		testContact.Total_Employee_Compensation__c = 1;
		testContact.Number_of_Employees_opt_2__c = 1;
		update testContact;

		testOpp.Total_Employee_Compensation__c = 2;
		testOpp.NumberOfEmployees__c = 2;
		update testOpp;
		
		PageReference pageRef = Page.OpportunityQualificationCheck;
		pageRef.getParameters().put('id', testOpp.id);
		
		Test.startTest();
		Test.setCurrentPage(pageRef);
		OpportunityQualificationCheckCtrl ctrl = new OpportunityQualificationCheckCtrl();
		ctrl.checkQualifications();
		Test.stopTest();
	}


	@IsTest
	private static void testReqA_Fail() {
		System.debug('testReqA_Fail');
		
		String ident = String.valueOf(Datetime.now().millisecond());
		setup(ident);

		testContact.Number_of_Employees__c = 2;
		update testContact;

		testOpp.NumberOfEmployees__c = 1;
		update testOpp;
		
		PageReference pageRef = Page.OpportunityQualificationCheck;
		pageRef.getParameters().put('id', testOpp.id);
		
		Test.startTest();
		Test.setCurrentPage(pageRef);
		OpportunityQualificationCheckCtrl ctrl = new OpportunityQualificationCheckCtrl();
		ctrl.checkQualifications();
		Test.stopTest();
	}


	// Requirement B
	@IsTest
	private static void testReqB_Pass1() {
		System.debug('testReqB_Pass1');

		String ident = String.valueOf(Datetime.now().millisecond());
		setup(ident);

		testContact.Annual_Fees__c = 1;
		update testContact;

		testOpp.Organization_Type__c = 'Agency-type';
		testOpp.AnnualRevenue__c = 2;
		update testOpp;
		
		PageReference pageRef = Page.OpportunityQualificationCheck;
		pageRef.getParameters().put('id', testOpp.id);
		
		Test.startTest();
		Test.setCurrentPage(pageRef);
		OpportunityQualificationCheckCtrl ctrl = new OpportunityQualificationCheckCtrl();
		ctrl.checkQualifications();
		Test.stopTest();
	}
	

	@IsTest
	private static void testReqB_Pass2() {
		System.debug('testReqB_Pass2');

		String ident = String.valueOf(Datetime.now().millisecond());
		setup(ident);
		
		testContact.Annual_Assets__c = 3;
		testContact.Number_of_Employees__c = 1;
		testContact.Enterprise_Value__c = 1;
		update testContact;
		
		testOpp.Organization_Type__c = 'Financial Institution';
		testOpp.AnnualRevenue__c = 2;
		testOpp.NumberOfEmployees__c = 2;
		testOpp.Enterprise_Value__c = 2;
		testOpp.Enterprise_Type__c = 'Sum of public equity plus debt less cash';
		update testOpp;
		
		PageReference pageRef = Page.OpportunityQualificationCheck;
		pageRef.getParameters().put('id', testOpp.id);
		
		Test.startTest();
		Test.setCurrentPage(pageRef);
		OpportunityQualificationCheckCtrl ctrl = new OpportunityQualificationCheckCtrl();
		ctrl.checkQualifications();
		Test.stopTest();
	}


	@IsTest
	private static void testReqB_Fail() {
		System.debug('testReqB_Fail');
		
		String ident = String.valueOf(Datetime.now().millisecond());
		setup(ident);

		testContact.Enterprise_Value__c = 2;
		update testContact;

		testOpp.Enterprise_Value__c = 1;
		update testOpp;
		
		PageReference pageRef = Page.OpportunityQualificationCheck;
		pageRef.getParameters().put('id', testOpp.id);
		
		Test.startTest();
		Test.setCurrentPage(pageRef);
		OpportunityQualificationCheckCtrl ctrl = new OpportunityQualificationCheckCtrl();
		ctrl.checkQualifications();
		Test.stopTest();
	}


	@IsTest
	private static void testNegative() {
		PageReference pageRef = Page.OpportunityQualificationCheck;
		
		Test.startTest();
		Test.setCurrentPage(pageRef);
		OpportunityQualificationCheckCtrl ctrl = new OpportunityQualificationCheckCtrl();
		ctrl.checkQualifications();
		Test.stopTest();
	}

}