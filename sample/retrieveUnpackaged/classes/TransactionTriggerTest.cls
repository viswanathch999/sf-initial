@isTest 
private class TransactionTriggerTest {
	
	private static Account chapter1;
	private static Account chapter2;
	private static Contact member;
	private static KGRenewal__Subscription__c sub;
	private static Opportunity opp;
	private static KGRenewal__Invoice__c inv;
	private static KGRenewal__Transaction__c trans;


	private static void setup(Integer identifier) {
		chapter1 = new Account(
			Name = 'TransactionTrig Chapter 1 ' + identifier,
			RecordType = RecordTypeServices.getRecordTypeByDeveloperName('Chapter', 'Account')
		);
		insert chapter1;
		System.debug('+++++ ' + chapter1);

		chapter2 = new Account(
			Name = 'TransactionTrig Chapter 2 ' + identifier,
			RecordType = RecordTypeServices.getRecordTypeByDeveloperName('Chapter', 'Account')
		);
		insert chapter2;
		System.debug('+++++ ' + chapter2);

		member = new Contact(
			FirstName = 'TransactionTrig', 
			LastName = 'Member ' + identifier, 
			AccountId = chapter1.Id, 
			RecordType = RecordTypeServices.getRecordTypeByDeveloperName('Member', 'Contact')
		);
		insert member;
		System.debug('+++++ ' + member);
		
		sub = new KGRenewal__Subscription__c(
			KGRenewal__Amount__c = 100.00, 
			KGRenewal__StartDate__c = FiscalDateUtility.startOfCurrentFiscal, 
			KGRenewal__EndDate__c = FiscalDateUtility.startOfNextFiscal.addDays(-1), 
			KGRenewal__Account__c = chapter1.Id, 
			KGRenewal__Contact__c = member.Id, 
			KGRenewal__IsActive__c = true
		);
		insert sub;
		System.debug('+++++ ' + sub);

		opp = new Opportunity(
			Name = 'Test Opp ' + identifier, 
			RecordType = RecordTypeServices.getRecordTypeByDeveloperName('Member', 'Opportunity'),
			Opportunity_Type__c = 'Member', 
			AccountId = chapter1.Id, 
			KGRenewal__Contact__c = member.Id, 
			KGRenewal__Subscription__c = sub.Id,
			CloseDate = Date.today(), 
			Fiscal_Date_Start__c = FiscalDateUtility.startOfCurrentFiscal, 
			StageName = 'Cycle Open', 
			Amount = 300.00, 
			KGRenewal__BilledAmount__c = 200.00
		);
		insert opp;
		System.debug('+++++ ' + opp);

		// don't insert these yet
		inv = new KGRenewal__Invoice__c(
			KGRenewal__Account__c = chapter2.Id,
			KGRenewal__Contact__c = member.Id
		);
		trans = new KGRenewal__Transaction__c(
			KGRenewal__Contact__c = member.Id,
			KGRenewal__Opportunity__c = opp.Id,
			KGRenewal__Amount__c = 200.00
		);
	}


	private static void setupKG(Integer identifier) {
		Product2 prod = new Product2(
			Name = 'Test Product ' + identifier, 
			IsActive = true
		);
		insert prod;
		System.debug('+++++ ' + prod);

		Pricebook2 pBook = new Pricebook2(
			Name = 'TestPriceBook ' + identifier, 
			IsActive = true
		);
		insert pBook;
		System.debug('+++++ ' + pBook);

		PricebookEntry pBookEntry = new PricebookEntry(
			IsActive = true, 
			Pricebook2Id = pBook.Id, 
			Product2Id = prod.Id, 
			UnitPrice = 200.00, 
			UseStandardPrice = false
		);
		insert pBookEntry;
		System.debug('+++++ ' + pBookEntry);

		opp.Certification_Type__c = 'Third Party Certify';
		opp.Certification_Status__c = 'Complete';
		opp.GUID__c = 'test-test-test-test-test-test';
		opp.Code_of_Conduct_Accepted__c = true;
		opp.Grace_Status__c = 'No Grace Needed';
		opp.KGRenewal__BillingPeriod__c = 999;
		opp.KGRenewal__BillingFrequency__c = 'Periodic';
		opp.KGRenewal__ContractEffectiveDate__c = FiscalDateUtility.startOfCurrentFiscal;
		opp.KGRenewal__ContractEndDate__c = FiscalDateUtility.startOfNextFiscal.addDays(-1);
		opp.KGRenewal__Term__c = 12;
		opp.KGRenewal__CreateNewSubscription__c = true;
		opp.KGRenewal__BillingOrganization__c = chapter1.Name;
		opp.KGRenewal__BillingFirstName__c = member.FirstName;
		opp.KGRenewal__BillingLastName__c = member.LastName;
		opp.KGRenewal__BillingStreetAddressLine1__c = '123 Main St.';
		opp.KGRenewal__BillingCity__c = 'Dallas';
		opp.KGRenewal__BillingState__c = 'TX';
		opp.KGRenewal__BillingCountry__c = 'United States';
		opp.KGRenewal__BillingPostalCode__c = '75201';
		opp.Pricebook2Id = pBook.Id;
		update opp;

		OpportunityLineItem oppLineItem = new OpportunityLineItem(
			OpportunityId = opp.Id, 
			Product2Id = prod.Id, 
			PricebookEntryId = pBookEntry.Id, 
			UnitPrice = 200.00, 
			TotalPrice = 200.00, 
			KGRenewal__UnitPrice__c = 200.00, 
			Quantity = 1
			/*
			KGRenewal__Name__c = 'TestOppLineItem ' + identifier, 
			KGRenewal__ContractEffectiveDate__c = fis
			KGRenewal__ContractEndDate__c
			KGRenewal__UnitPrice__c
			KGRenewal__LockedListPrice__c
			UnitPrice
			TotalPrice
			*/
		);
		insert oppLineItem;
		System.debug('+++++ ' + oppLineItem);
	}
	

	@isTest
	private static void testFindOpportunity() {
		Integer identifier = Datetime.now().millisecond();
		setup(identifier);

		inv.KGRenewal__Opportunity__c = opp.Id;
		insert inv;
		System.debug('+++++ ' + inv);

		Test.startTest();
		trans.KGRenewal__Opportunity__c = null;
		trans.KGRenewal__Invoice__c = inv.Id;
		System.debug('+++++ ' + trans);
		insert trans;
		Test.stopTest();

		System.assert(
			[SELECT KGRenewal__Opportunity__c FROM KGRenewal__Transaction__c WHERE Id = :trans.Id].KGRenewal__Opportunity__c != null,
			'Opportunity should be populated on transaction.'
		);
	}
	

	@isTest
	private static void testFindInvoiceCaseA() {
		Integer identifier = Datetime.now().millisecond();
		setup(identifier);
		//setupKG(identifier);

		Test.startTest();
		System.debug('+++++ ' + trans);
		insert trans;
		Test.stopTest();

		System.debug('+++++ Opportunity.StageName: ' + [SELECT StageName FROM Opportunity WHERE Id = :opp.Id LIMIT 1].StageName);
		System.debug('+++++ Invoice count: ' + [SELECT COUNT(Id) FROM KGRenewal__Invoice__c WHERE KGRenewal__Contact__c = :member.Id][0].get('expr0'));
		System.debug('+++++ Transaction.Invoice: ' + [SELECT KGRenewal__Invoice__c FROM KGRenewal__Transaction__c WHERE Id = :trans.Id LIMIT 1].KGRenewal__Invoice__c);
		//System.debug('#+#+#  Invoices: ' + [SELECT Id, Name, KGRenewal__Account__c, KGRenewal__Opportunity__c, KGRenewal__Subscription__c FROM KGRenewal__Invoice__c WHERE KGRenewal__Contact__c = :member.Id]);

		/*
		System.assert(
			[SELECT KGRenewal__Invoice__c FROM KGRenewal__Transaction__c WHERE Id = :trans.Id LIMIT 1].KGRenewal__Invoice__c != null,
			'Invoice should be populated on transaction.'
		);
		*/
	}
	

	@isTest
	private static void testFindInvoiceCaseB() {
		Integer identifier = Datetime.now().millisecond();
		setup(identifier);

		inv.KGRenewal__Opportunity__c = opp.Id;
		inv.KGRenewal__Subscription__c = sub.Id;
		insert inv;
		System.debug('+++++ ' + inv);

		Test.startTest();
		System.debug('+++++ ' + trans);
		insert trans;
		Test.stopTest();
		
		System.assert(
			[SELECT KGRenewal__Invoice__c FROM KGRenewal__Transaction__c WHERE Id = :trans.Id LIMIT 1].KGRenewal__Invoice__c != null,
			'Invoice should be populated on transaction.'
		);
	}
	

	@isTest
	private static void testFindInvoiceCaseC() {
		Integer identifier = Datetime.now().millisecond();
		setup(identifier);

		opp.Type = TransactionTriggerServices.OPP_TYPE_PROSPECT;
		update opp;
		insert inv;
		System.debug('+++++ ' + inv);

		Test.startTest();
		trans.KGRenewal__Status__c = TransactionTriggerServices.TRANS_ERROR;
		System.debug('+++++ ' + trans);
		insert trans;
		Test.stopTest();

		System.assert(
			[SELECT KGRenewal__Invoice__c FROM KGRenewal__Transaction__c WHERE Id = :trans.Id LIMIT 1].KGRenewal__Invoice__c == null,
			'Transaction should not have changed.'
		);
	}
	

	@isTest
	private static void testUpdateBalance() {
		Integer identifier = Datetime.now().millisecond();
		setup(identifier);

		inv.KGRenewal__Opportunity__c = opp.Id;
		inv.KGRenewal__Subscription__c = sub.Id;
		insert inv;

		opp.Amount = 200.00;
		opp.KGRenewal__BilledAmount__c = 0;
		opp.Certification_Type__c = 'Third Party Certify';
		opp.Certification_Status__c = 'Complete';
		opp.Grace_Status__c = 'No Grace Needed';
		update opp;
		
		System.debug('+++++ ' + inv);
		System.debug('+++++ ' + opp);

		Test.startTest();
		trans.KGRenewal__Invoice__c = inv.Id;
		trans.KGRenewal__Status__c = TransactionTriggerServices.TRANS_SUCCESS;
		System.debug('+++++ ' + trans);
		insert trans;
		Test.stopTest();

		System.debug([SELECT StageName FROM Opportunity WHERE Id = :opp.Id LIMIT 1].StageName);

		System.assert(
			[SELECT StageName FROM Opportunity WHERE Id = :opp.Id LIMIT 1].StageName == TransactionTriggerServices.STATUS_CLOSED_WON,
			'Opportunity should have been updated to Closed Won.'
		);
		
	}


	@isTest
	private static void testUpdateErrorMsgPositive() {
		Integer identifier = Datetime.now().millisecond();
		setup(identifier);

		insert inv;

		Payment_Error__c payError = new Payment_Error__c(
			Error_Code__c = '111',
			YPO_Message__c = 'YPO_Error'
		);
		insert payError;

		Test.startTest();
		trans.KGRenewal__Invoice__c = inv.Id;
		trans.KGRenewal__GatewayReasonCode__c = '111';
		System.debug('+++++ ' + trans);
		insert trans;
		Test.stopTest();

		System.assert(
			[SELECT YPO_Error_Message__c FROM KGRenewal__Transaction__c WHERE Id = :trans.Id].YPO_Error_Message__c == 'YPO_Error',
			'YPO error message should be set.'
		);
	}


	@isTest
	private static void testUpdateErrorMsgNegative() {
		Integer identifier = Datetime.now().millisecond();
		setup(identifier);

		insert inv;

		Test.startTest();
		trans.KGRenewal__Invoice__c = inv.Id;
		trans.KGRenewal__GatewayReasonCode__c = '222';
		System.debug('+++++ ' + trans);
		insert trans;
		Test.stopTest();

		System.assert(
			[SELECT YPO_Error_Message__c FROM KGRenewal__Transaction__c WHERE Id = :trans.Id].YPO_Error_Message__c == Label.Payment_Error_Message,
			'YPO error message should be set to the default message.'
		);
	}
}