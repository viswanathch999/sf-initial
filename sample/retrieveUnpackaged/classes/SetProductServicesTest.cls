@isTest
public with sharing class SetProductServicesTest {

	@TestSetup static void Setup() {
		Map<String, RecordTypeInfo> recordTypeLookup = RecordTypeServices.getRecordType('Account');
		ID standardPriceBookId = Test.getStandardPricebookId();

		List<Account> listAccount = new List<Account> ();

		Account testAcc = TestServices.createAccount('Primary Chapter');
		testAcc.Type = 'Chapter';
		testacc.Chapter_Dues__c = 'All Members';
		testAcc.RecordTypeId = recordTypeLookup.get('Chapter').getRecordTypeId();
		listAccount.add(testAcc);

		Account SecAcc = TestServices.createAccount('Secondary Chapter');
		secAcc.Type = 'Chapter';
		secacc.Chapter_Dues__c = 'All Members';
		secAcc.RecordTypeId = recordTypeLookup.get('Chapter').getRecordTypeId();
		listAccount.add(secAcc);

		Account testHouseholdAccount1 = TestServices.createAccount('Household');
		testHouseholdAccount1.Type = 'Relationship';
		testHouseholdAccount1.RecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Relationship', 'Account').Id;
		listAccount.add(testHouseholdAccount1);

		Account testHouseholdAccount2 = TestServices.createAccount('Household');
		testHouseholdAccount2.Type = 'Relationship';
		testHouseholdAccount2.RecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Relationship', 'Account').Id;
		listAccount.add(testHouseholdAccount2);

		insert listAccount;

		List<Contact> listContact = new List<Contact> ();

		Contact testCon = TestServices.createContact(listAccount[0].Id,'Member',RecordTypeServices.getRecordTypeByDeveloperName('Member','Contact').id,false);
		listContact.add(testCon);

		testCon = TestServices.createContact(listAccount[0].Id,'Spouser',RecordTypeServices.getRecordTypeByDeveloperName('Spouse_Partner','Contact').Id,false);
		listContact.add(testCon);

		testCon = TestServices.createContact(listAccount[0].Id,'Prospector',RecordTypeServices.getRecordTypeByDeveloperName('Prospect','Contact').id,false);
		listContact.add(testCon);

		insert listContact;
		for (integer i=0; i<3; ++i) {
			System.assert(String.isNotBlank(listContact[i].Id),'ID should not be blank for ' + listContact[i].LastName);
		}

		List<Opportunity> ListOpps = new List<Opportunity>();

		Opportunity testOpp = (Opportunity) sObjectFactory.build(Opportunity.sObjectType);
		testOpp.AccountId = testAcc.Id;
		testOpp.KGRenewal__Contact__c = listContact[0].Id;
		testOpp.Pricebook2Id = standardPriceBookId;
		testOpp.Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
		ListOpps.add(testopp);

		testopp = (Opportunity) sObjectFactory.build(Opportunity.sObjectType);
		testOpp.AccountId = testAcc.Id;
		testOpp.KGRenewal__Contact__c = listContact[2].Id;
		testOpp.Pricebook2Id = standardPriceBookId;
		testOpp.Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
		ListOpps.add(testopp);

		insert ListOpps;

		List<Account_Affiliation__c> accfList = new List<Account_Affiliation__c>();

		Account_Affiliation__c aa = new Account_Affiliation__c();
			aa.Contact__c = listContact[2].Id;
			aa.Account__c = testAcc.Id;
			aa.Is_Primary__c = true;
			aa.IsActive__c = false;
			aa.Start_Date__c = System.today();
		accfList.add(aa);

		aa = new Account_Affiliation__c(
			Account__c = SecAcc.Id, 
			Contact__c = listContact[0].Id, 
			Start_Date__c = Date.today(), 
			IsActive__c = true, 
			Is_Primary__c = false);
		accfList.add(aa);

		aa = new Account_Affiliation__c(
			Account__c = testAcc.Id, 
			Contact__c = listContact[0].Id, 
			Start_Date__c = Date.today(), 
			IsActive__c = true, 
			Is_Primary__c = true, 
			Transfer_Flag__c = 'Renewal Transition');
		accfList.add(aa);

		insert accfList;
		System.debug('Chapter Account: ' + testAcc.Name + '/' + testAcc.Type);
		for (Account_Affiliation__c AffCheck : [SELECT Account__c, Contact__c, Contact__r.lastname, Contact__r.RecordType.DeveloperName, IsActive__c, Is_Primary__c, Transfer_Flag__c, End_Date__c, Type__c
																					   FROM Account_Affiliation__c 
																					   WHERE Type__c='Chapter' ]) {
			System.debug(AffCheck.Contact__r.lastname + ' Record: ' + AffCheck.Contact__r.RecordType.DeveloperName + '/' + AffCheck.Type__c + '/' + AffCheck.Is_Primary__c + '/' + AffCheck.IsActive__c);
		}

		List<Relationship__c> HouseHolds = new List<Relationship__c>();
		HouseHolds.add(TestServices.createRelationship(listContact[0].Id, testHouseholdAccount1.Id, 'Member', true, false));
		HouseHolds.add(TestServices.createRelationship(listContact[1].Id, testHouseholdAccount1.Id, 'Spouse/Partner', true, false));
		HouseHolds.add(TestServices.createRelationship(listContact[2].Id, testHouseholdAccount2.Id, 'Member', true, false));
		insert HouseHolds;

		List<Product2> testProducts = new List<Product2> ();

		Product2 p = new Product2();
		p.Name = 'Primary Test Product 1';
		p.Product_Type__c = 'Primary';
		p.Family = 'Chapter Dues';
		p.Account__c = testAcc.Id;
		p.Fiscal_Date_Start__c = FiscalDateUtility.startOfCurrentFiscal;
		p.IsActive = true;
		p.Tier_Number__c = '1';

		testProducts.add(p);

		p = new Product2();
		p.Name = 'Primary Test Product 1';
		p.Product_Type__c = 'Primary';
		p.Family = 'Chapter Dues';
		p.Account__c = testAcc.Id;
		p.Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
		p.IsActive = true;
		p.Tier_Number__c = '1';

		testProducts.add(p);

		p = new Product2();
		p.Name = 'Secondary Test Product 1';
		p.Product_Type__c = 'Secondary';
		p.Family = 'Chapter Dues';
		p.Account__c = testAcc.Id;
		p.Fiscal_Date_Start__c = FiscalDateUtility.startOfCurrentFiscal;
		p.IsActive = true;

		testProducts.add(p);

		p = new Product2();
		p.Name = 'Secondary Test Product 1';
		p.Product_Type__c = 'Secondary';
		p.Family = 'Chapter Dues';
		p.Account__c = testAcc.Id;
		p.Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
		p.IsActive = true;

		testProducts.add(p);

		p = new Product2();
		p.Name = 'Initiation Test Product 1';
		p.Product_Type__c = 'Initiation';
		p.Family = 'Annual Dues';
		p.Fiscal_Date_Start__c = FiscalDateUtility.startOfCurrentFiscal;
		p.IsActive = true;

		testProducts.add(p);

		p = new Product2();
		p.Name = 'Initiation Test Product 1';
		p.Product_Type__c = 'Initiation';
		p.Family = 'Annual Dues';
		p.Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
		p.IsActive = true;

		testProducts.add(p);

		p = new Product2();
		p.Name = 'Paid in Full Test Product 1';
		p.Product_Type__c = 'Paid in Full';
		p.Family = 'Lifetime Dues';
		p.Fiscal_Date_Start__c = FiscalDateUtility.startOfCurrentFiscal;
		p.IsActive = true;

		testProducts.add(p);

		p = new Product2();
		p.Name = 'Paid in Full Test Product 1';
		p.Product_Type__c = 'Paid in Full';
		p.Family = 'Lifetime Dues';
		p.Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
		p.IsActive = true;

		testProducts.add(p);

		p = new Product2();
		p.Name = 'Benefit Test Product';
		p.YPO_Universal_Member_Benefit__c = true;
		p.IsActive = true;
		p.Fiscal_Date_Start__c = FiscalDateUtility.startOfCurrentFiscal;
		p.Family = 'Member Benefit';
		p.Exclusive__c = 'Member';
		testProducts.add(p);

		p = new Product2();
		p.Name = 'Benefit Test Product';
		p.YPO_Universal_Member_Benefit__c = true;
		p.IsActive = true;
		p.Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
		p.Family = 'Member Benefit';
		p.Exclusive__c = 'Member';
		testProducts.add(p);

		//for (integer x = 0; x < 4; x++) {
			//p = new Product2();
			//p.Name = 'Benefit Test Product' + x;
			//p.YPO_Universal_Member_Benefit__c = true;
			//p.IsActive = true;
			//p.Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
			//p.Family = 'Member Benefit';
			//p.Exclusive__c = 'Member';
			//testProducts.add(p);
		//}

		insert testProducts;

		List<PriceBookEntry> PBE = new List<PriceBookEntry> ();

		for (Product2 prod : testProducts) {
			PBE.add(new PriceBookEntry(Product2Id = prod.id, PriceBook2Id = standardPriceBookId, isActive = true, UnitPrice = 1.0));
		}

		insert PBE;

		List<OpportunityLineItem> opptyLines = (List<OpportunityLineItem>) SObjectFactory.build(10, OpportunityLineItem.sObjectType);

		integer x = 0;
		for (OpportunityLineItem opptyLine : opptyLines) {
			if (PBE[x] != null) {
				opptyLine.PriceBookEntryId = PBE[x].id;
				opptyLine.OpportunityId = ListOpps[0].id;
				opptyLine.Quantity = 1;
				opptyLine.TotalPrice = x + 100;
			}
			x++;
		}

		insert opptyLines;
	}

	static testmethod void deleteProducts_success() {
		List<Opportunity> testOpp = new List<Opportunity> ([Select Id from Opportunity]);
		List<OpportunityLineItem> allLine = new List<OpportunityLineItem> ([Select Id from OpportunityLineItem where OpportunityId = :testOpp[0].id]);
		System.assertEquals(10, allLine.size());
		SetProductServices setProdSer = new SetProductServices(new ApexPages.StandardController(testOpp[0]));
		setProdSer.deleteCurrentProducts(testOpp);
		List<OpportunityLineItem> allLineN = new List<OpportunityLineItem> ([Select Id from OpportunityLineItem where OpportunityId = :testOpp[0].id]);
		System.assertEquals(2, allLineN.size(), 'Lines not Deleted Properly'); //counting the number of Lifetime products listed.
		SetProductServices.createErrorLog(testOpp[0].id, 'This is test Error');
	}

	static testmethod void prospectQ4() {
		Contact testContact = [Select Id from Contact Where Record_Type_Name__c = 'Prospect' Limit 1];
		testContact.Membership_Status__c = 'Prospect';
		testContact.MailingCountry = 'United States';
		testContact.Address1_Type__C = 'Home';
		testContact.Tier_Number__c = '1';
		update testContact;

		List<Opportunity> testOpp = new List<Opportunity> ([Select Id, Fiscal_Date_Start__c, Q4_Date_Testing__c from Opportunity Where KGRenewal__Contact__c = :testContact.id]);
		System.assertEquals(1, testOpp.size());
		testOpp[0].Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
		testOpp[0].Q4_Date_Testing__c = Date.newInstance(Date.today().year(), 05, 01);
		testOpp[0].Opportunity_Type__c = 'Prospect';
		update testOpp;

		List<Product2> testProds = new List<Product2> ([Select Id, Tier_Number__c, Fiscal_Date_Start__c, Country__c, Family from Product2]);
		System.assertEquals(10, testProds.size());
		testProds[0].Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
		testProds[0].Family = 'Annual Dues';
		testProds[0].Tier_Number__c = '1';

		testProds[1].Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
		testProds[1].Country__c = 'United States';
		testProds[1].Tier_Number__c = '1';

		update testProds;

		SetProductServices setProdSer = new SetProductServices(new ApexPages.StandardController(testOpp[0]));
		setProdSer.flowControl();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		for (Apexpages.Message msg : msgs) {
			System.assert(msg.getDetail().contains('Set products was successful!'),msg);
		}

		List<OpportunityLineItem> OppLineItem = [Select Id From OpportunityLineItem Where OpportunityId = :testopp[0].id and Product_Family__c = 'Member Benefit'];
		System.assertEquals(1,OppLineItem.size(),'Number of Benefit products differ from the expected.');

	}

	static testmethod void chapterProducts() {
		Account acct = [Select Id from Account limit 1];
		acct.RecordtypeId = RecordTypeServices.getRecordTypeByDeveloperName('Chapter', 'Account').Id;
		acct.Chapter_Dues__c = 'All Members';
		update acct;

		Contact testCon = [Select Id, AccountId from Contact Where Record_Type_Name__c = 'Member' limit 1];
		testCon.AccountId = acct.Id;
		testCon.Membership_Status__c = 'Member';
		testCon.Lifetime_Dues_Status__c = 'Completed Payment Cycle';
		update testCon;

		List<Opportunity> testOpp = new List<Opportunity> ([Select Id, Fiscal_Date_Start__c, Q4_Date_Testing__c from Opportunity Where KGRenewal__Contact__c = :testCon.id]);
		System.assertEquals(1, testOpp.size());
		testOpp[0].Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
		//testOpp[0].Q4_Date_Testing__c = Date.newInstance(Date.today().year(), 05, 01);
		update testOpp;

		//Product2 testProd = [Select Id, Tier_Number__c, Fiscal_Date_Start__c, Country__c, Family from Product2 Where Name = 'Test Product 1' LIMIT 1];
		Test.startTest();

		SetProductServices setProdSer = new SetProductServices(new ApexPages.StandardController(testOpp[0]));
		setProdSer.flowControl();

		Test.stopTest();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		for (Apexpages.Message msg : msgs) {
			System.assert(msg.getDetail().contains('Set products was successful!'),msg);
		}

		List<OpportunityLineItem> OppLineItem = [Select Id From OpportunityLineItem Where OpportunityId = :testopp[0].id and Product_Family__c = 'Member Benefit'];
		System.assertEquals(1,OppLineItem.size(),'Number of Benefit products differ from the expected.');

	}

	static testmethod void yrAnnualDuesProducts() {
		Contact testCon = [Select Id, AccountId from Contact limit 1];
		testCon.Membership_Status__c = 'Honorary Member';
		testCon.MailingCountry = 'United States';
		testCon.Address1_Type__C = 'Home';
		testCon.Tier_Number__c = '1';
		testCon.HouseholdID__c = testCon.AccountId;
		update testCon;

		List<Product2> testProds = new List<Product2> ([Select Id, Tier_Number__c, Fiscal_Date_Start__c, Country__c, Family from Product2]);
		System.assertEquals(10, testProds.size());
		testProds[0].Fiscal_Date_Start__c = FiscalDateUtility.startOfCurrentFiscal;
		testProds[0].Family = 'Annual Dues';
		testProds[0].Product_Type__c = 'Primary';
		testProds[0].Tier_Number__c = '1';

		testProds[1].Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
		testProds[1].Product_Type__c = 'Primary';
		testProds[1].Family = 'Lifetime Dues';

		testProds[2].Fiscal_Date_Start__c = FiscalDateUtility.startOfCurrentFiscal;
		testProds[2].Family = 'Annual Dues';
		testProds[2].Country__c = '';
		testProds[2].Tier_Number__c = '1';

		update testProds;

		List<Opportunity> testOpp = new List<Opportunity> ([Select Id, Fiscal_Date_Start__c, Q4_Date_Testing__c from Opportunity  Where KGRenewal__Contact__c = :testCon.id]);
		System.assertEquals(1, testOpp.size());
		testOpp[0].Fiscal_Date_Start__c = Date.newInstance(Date.today().year(), 07, 01);
		testOpp[0].Q4_Date_Testing__c = Date.newInstance(Date.today().year(), 05, 01);
		update testOpp;

		Test.startTest();

		SetProductServices setProdSer = new SetProductServices(new ApexPages.StandardController(testOpp[0]));
		setProdSer.flowControl();

		testCon.Membership_Status__c = 'Member';
		testCon.Lifetime_Dues_Status__c = 'Completed Payment Cycle';
		update testCon;

		setProdSer = new SetProductServices(new ApexPages.StandardController(testOpp[0]));
		setProdSer.flowControl();

		testCon.Membership_Status__c = 'Member';
		testCon.Lifetime_Dues_Status__c = 'In Payment Cycle';
		update testCon;

		setProdSer = new SetProductServices(new ApexPages.StandardController(testOpp[0]));
		setProdSer.flowControl();

		testCon.Membership_Status__c = 'Prospect';
		testCon.Lifetime_Dues_Status__c = '';
		update testCon;

		setProdSer = new SetProductServices(new ApexPages.StandardController(testOpp[0]));
		setProdSer.flowControl();

		Test.stopTest();

	}

	static testmethod void survivingSpousePartner() {

		Account acct = [Select Id from Account limit 1];
		acct.RecordtypeId = RecordTypeServices.getRecordTypeByDeveloperName('Chapter', 'Account').Id;
		acct.Chapter_Dues__c = 'All Members';
		update acct;

		Contact testCon = [Select Id, AccountId from Contact limit 1];
		testCon.AccountId = acct.Id;
		testCon.Membership_Status__c = 'Surviving Spouse/Partner';
		testCon.Lifetime_Dues_Status__c = 'Completed Payment Cycle';
		testCon.Tier_Number__c = '1';
		update testCon;

		List<Opportunity> testOpp = new List<Opportunity> ([Select Id, Fiscal_Date_Start__c, Q4_Date_Testing__c from Opportunity  Where KGRenewal__Contact__c = :testCon.id]);
		System.assertEquals(1, testOpp.size());
		testOpp[0].Fiscal_Date_Start__c = Date.newInstance(Date.today().year(), 07, 01);
		testOpp[0].Q4_Date_Testing__c = Date.newInstance(Date.today().year(), 05, 01);
		update testOpp;


		Product2 testProd = [Select Id, Tier_Number__c, Fiscal_Date_Start__c, Country__c, Family from Product2 LIMIT 1];
		testProd.Fiscal_Date_Start__c = Date.newInstance(Date.today().year(), 07, 01);
		testProd.Family = 'Chapter Dues';
		testProd.Product_Type__c = 'Primary';
		testProd.Tier_Number__c = '1';
		testProd.Account__c = testCon.AccountId;

		update testProd;

		Test.startTest();

		SetProductServices setProdSer = new SetProductServices(new ApexPages.StandardController(testOpp[0]));
		setProdSer.flowControl();

		Test.stopTest();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		for (Apexpages.Message msg : msgs) {
			System.assert(msg.getDetail().contains('Set products was successful!'),msg);
		}
	}
}