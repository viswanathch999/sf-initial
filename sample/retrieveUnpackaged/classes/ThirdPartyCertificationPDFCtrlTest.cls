@isTest 
private class ThirdPartyCertificationPDFCtrlTest {

	@isTest
	private static void pageTestPositive() {
		Account acc = new Account(Name = 'ABC Inc.');
		insert acc;
		System.debug('+++ acc: ' + acc);

		Contact cont = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
		insert cont;
		System.debug('+++ cont: ' + cont);

		Opportunity opp = new Opportunity(
			AccountId = acc.Id,
			KGRenewal__Contact__c = cont.Id,
			Name = 'TestOpp',
			StageName = 'Cycle Open',
			CloseDate = Date.today(),
			KGRenewal__IsActiveCart__c = true,
			Fiscal_Date_Start__c = Date.newInstance(Date.today().year(), 07, 01),
			Opportunity_Type__c = 'Renewal'
		);
		insert opp;
		System.debug('+++ opp: ' + opp);
		
		PageReference pageRef = Page.ThirdPartyCertificationPDF;
		pageRef.getParameters().put('id', cont.id);
		Test.setCurrentPage(pageRef);
		Test.startTest();
		ThirdPartyCertificationPDFCtrl ctrl = new ThirdPartyCertificationPDFCtrl();
		Test.stopTest();
	}

	@isTest
	private static void pageTestNegative() {
		PageReference pageRef = Page.ThirdPartyCertificationPDF;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		ThirdPartyCertificationPDFCtrl ctrl = new ThirdPartyCertificationPDFCtrl();
		Test.stopTest();
	}

}