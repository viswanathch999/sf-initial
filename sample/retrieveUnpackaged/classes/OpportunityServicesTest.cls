@isTest
public class OpportunityServicesTest {

	@TestSetup static void setup() {
		Account testAccount = new Account(
		                                  Name = 'testAccount',
		                                  CurrencyIsoCode = 'USD',
		                                  BillingPostalCode = '91320',
		                                  Industry = 'Banking'
		);
		insert testAccount;
		List<Contact> contList = new List<Contact>();


		Contact testContact = new Contact(
		                                  FirstName = 'Test',
		                                  LastName = 'Contact1',
		                                  AccountId = testAccount.Id,
		                                  Email = 'test_OppServices@email.com',
		                                  Join_Date__c = System.today(),
		                                  Membership_Status__c = 'Member',
										  Number_Years_a_Member__c = null,
		                                  Lifetime_Dues_Status__c = 'In Payment Cycle'
		);
		contList.add(testContact);

		//Household account
		Account oRelationshipAcct = new Account(Name = 'Test-Household',
									Type = 'Relationship',
									Record_Type__c = RecordTypeServices.getRecordTypeByName('Relationship','Account').Id);
		insert oRelationshipAcct;
		
		testContact = new Contact(
		                                  FirstName = 'Child',
		                                  LastName = 'Contact1',
		                                  AccountId = testAccount.Id,
		                                  Email = 'Child_OppServices@email.com',
		                                  Join_Date__c = System.today(),
										  Number_Years_a_Member__c = null,
		                                  //Membership_Status__c = 'Child',
										  //YNG_Member__c = true,
										  Birthdate = Date.newInstance(Date.today().year() - 23,7,1),
										  RecordTypeid = RecordTypeServices.getRecordTypeByName('Child','Contact').id
		);
		testContact.recalculateFormulas();
		contList.add(testContact);

		insert contList;

		//Relationship
		List<Relationship__c> relList = new List<Relationship__c>();

		relList.add(Utility.createRelationship(contList[0].id, oRelationshipAcct.id, 'Member'));
		relList.add(Utility.createRelationship(testContact.id, oRelationshipAcct.id, 'Child'));

		insert relList;

		ID standardPriceBookId = Test.getStandardPricebookId();

		Opportunity testopp = new Opportunity(
		                                      Name = 'testOpty',
		                                      AccountId = testAccount.Id,
		                                      StageName = 'Payment Pending',
		                                      Type = 'Payment Received',
		                                      CloseDate = System.today(),
		                                      President_Type__c = 'Entrepreneur',
											  Title__c = 'Chairman of the Board',
		                                      Firm_Type__c = 'Public',
		                                      Business_Scope__c = 'National',
		                                      Enterprise_Type__c = 'Independent third party investment/valuation',
		                                      ForecastCategoryName = 'Pipeline',
		                                      LeadSource = 'Adwords',
		                                      KGRenewal__Contact__c = testContact.Id,
		                                      KGRenewal__ContractEffectiveDate__c = Date.newInstance(Date.today().year(), 07, 01),
		                                      KGRenewal__ContractEndDate__c = Date.newInstance(Date.today().year() + 1, 06, 30),
		                                      Fiscal_Date_Start__c = Date.newInstance(Date.today().year(), 07, 01),
		                                      Opportunity_Type__c = 'Member',
		                                      Certification_Status__c = 'Complete',
		                                      Grace_Status__c = 'Approved',
		                                      RecordTypeId = RecordTypeServices.getRecordTypeByName('Member', 'Opportunity').Id,
		                                      Pricebook2Id = standardPriceBookId
		);
		insert testopp;

		Account testAccountChapter = TestServices.createAccount('Test Chapter Name');
		testAccountChapter.Type = 'Chapter';
		testAccountChapter.RecordTypeId = RecordTypeServices.getRecordTypeByName('Chapter', 'Account').Id;
		insert testAccountChapter;

		List<Account_Affiliation__c> acctAffList = new List<Account_Affiliation__c>();

		Account_Affiliation__c testAccountAffiliation = TestServices.createAccountAffiliation(testAccountChapter.Id, testContact.Id);
		testAccountAffiliation.contact_Type__c = 'Member';
		acctAffList.add(testAccountAffiliation);

		// Insert an account for member benfit product
		Account benefitProductAccount = new Account(Name = 'Test Product', RecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Benefit', 'Account').Id, Status__c = 'Active');
		insert benefitProductAccount;

		testAccountAffiliation = TestServices.createAccountAffiliation(benefitProductAccount.Id, testContact.Id);
		testAccountAffiliation.RecordTypeId = RecordTypeServices.getRecordTypeByName('Benefit', 'Account_Affiliation__c').Id;
		testAccountAffiliation.Start_Date__c = Date.newInstance(Date.today().year(), 07, 01);
		testAccountAffiliation.IsActive__c = true;
		acctAffList.add(testAccountAffiliation);

		insert acctAffList;

		List<Product2> testProducts = new List<Product2> ();
		testProducts.add( new Product2(Name='Test product',
		YPO_Universal_Member_Benefit__c = true,
		IsActive = true,
		KGRenewal__eCommerceEnabled__c = true,
		KGRenewal__AvailableForPurchase__c = true,
		KGRenewal__Subscription__c = true,
		KGRenewal__PriceTerm__c = 12,
		Fiscal_Date_Start__c = Date.newInstance(Date.today().year() - 1, 07, 01),
		Family = 'Annual Dues',
		Product_Type__c = 'Honorary',
		Tier_Number__c = '1'));

		testProducts.add( new Product2(Name = 'Test Product',
		YPO_Universal_Member_Benefit__c = true,
		IsActive = true,
		KGRenewal__eCommerceEnabled__c = true,
		KGRenewal__AvailableForPurchase__c = true,
		KGRenewal__Subscription__c = true,
		KGRenewal__PriceTerm__c = 12,
		Fiscal_Date_Start__c = Date.newInstance(Date.today().year(), 07, 01),
		Family = 'Lifetime Dues',
		Product_Type__c = 'Paid in Full'));

		testProducts.add( new Product2(
		Name = 'Test Product',
		IsActive = true,
		KGRenewal__eCommerceEnabled__c = true,
		KGRenewal__AvailableForPurchase__c = true,
		KGRenewal__Subscription__c = true,
		KGRenewal__PriceTerm__c = 12,
		Fiscal_Date_Start__c = Date.newInstance(Date.today().year(), 07, 01),
		Family = 'Member Benefit',
		Product_Type__c = 'Paid in Full'));

		testProducts.add( new Product2(
		Name = 'Test Product',
		IsActive = true,
		KGRenewal__eCommerceEnabled__c = true,
		KGRenewal__AvailableForPurchase__c = true,
		KGRenewal__Subscription__c = true,
		KGRenewal__PriceTerm__c = 12,
		Fiscal_Date_Start__c = Date.newInstance(Date.today().year(), 07, 01),
		Family = 'Member Benefit',
		Exclusive__c = 'YNG'));
		//testProducts[3].Product_Type__c = 'Paid in Full';

		insert testProducts;

		List<PriceBookEntry> PBE = new List<PriceBookEntry> ();

		for (Integer x = 0; x < testProducts.size(); x++) {
			PBE.add(new PriceBookEntry(Product2Id = testProducts[x].id, PriceBook2Id = standardPriceBookId, isActive = true, UnitPrice = 1.0));
		}

		insert PBE;

		List<OpportunityLineItem> opptyLines = (List<OpportunityLineItem>) SObjectFactory.build(testProducts.size(), OpportunityLineItem.sObjectType);

		integer x = 0;
		for (OpportunityLineItem opptyLine : opptyLines) {
			if (PBE[x] != null) {
				opptyLine.PriceBookEntryId = PBE[x].id;
				opptyLine.OpportunityId = testOpp.id;
				opptyLine.Quantity = 1;
				opptyLine.TotalPrice = x + 100;
				opptyLine.KGRenewal__ContractEffectiveDate__c = testOpp.KGRenewal__ContractEffectiveDate__c;
				opptyLine.KGRenewal__ContractEndDate__c = testopp.KGRenewal__ContractEndDate__c;
				System.debug('YNG Test: ' + PBE[x].Product2.exclusive__c);
				contact conteiner = [Select Id, Name, Product_Eligibility__c, Age_Current__c, Age_Next_Fiscal_Year__c FROM Contact WHERE email = 'Child_OppServices@email.com'];
				System.debug(conteiner.Id +'/'+ conteiner.Name +'/'+ conteiner.Product_Eligibility__c +'/'+ conteiner.Age_Current__c +'/'+ conteiner.Age_Next_Fiscal_Year__c);
				//if(PBE[x].Product2.exclusive__c == 'YNG') {
					opptyLine.Contact__c = [Select Id FROM Contact WHERE email = 'Child_OppServices@email.com' LIMIT 1].Id;
				//}
              
			}
			x++;
		}
		insert opptyLines;



		//// Member benefit refund
		//OpportunityLineItem benefitRefund = new OpportunityLineItem(
		                                                            //PriceBookEntryId = [SELECT Id FROM PriceBookEntry WHERE Name = 'Test Product' and UnitPrice = -1.0 LIMIT 1].Id,
		                                                            //OpportunityId = testopp.Id,
		                                                            //Quantity = - 1,
		                                                            //TotalPrice = 0,
		                                                            //KGRenewal__ContractEffectiveDate__c = testOpp.KGRenewal__ContractEffectiveDate__c,
		                                                            //KGRenewal__ContractEndDate__c = testopp.KGRenewal__ContractEndDate__c
		//);
		//insert benefitRefund;

		// Benefit AA error email setting
		Error_Email_Settings__c errEmail = new Error_Email_Settings__c(
		                                                               Name = 'Benefit AA Not Found',
		                                                               To__c = 'benefitAAtest@ypo.org',
		                                                               Active__c = true
		);
		insert errEmail;
	}

	@isTest static void markOppsAsClosedWonProspect() {
		Opportunity testOpp = [SELECT Id, StageName FROM Opportunity WHERE Name = 'testOpty' LIMIT 1];
		testOpp.RecordTypeId = RecordTypeServices.getRecordTypeByName('Prospect', 'Opportunity').Id;
		testOpp.Opportunity_Type__c = 'Prospect';
		testOpp.StageName = 'Payment Received';
		update testOpp;
	}

	@isTest static void markOppsAsClosedWonMember() {
		Opportunity testOpp = [SELECT Id, StageName FROM Opportunity WHERE Name = 'testOpty' LIMIT 1];
        
        OpportunityLineItem oli = [SELECT Id, Quantity, Product2.Exclusive__c, KGRenewal__ContractEffectiveDate__c FROM OpportunityLineItem WHERE OpportunityId = :testOpp.Id AND Product2.exclusive__c = 'YNG' LIMIT 1];
        system.debug('oli: ' + oli);
        oli.Quantity = -1;
        update oli;
        
		testOpp.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member', 'Opportunity').Id;
		testOpp.Opportunity_Type__c = 'Renewal';
		testOpp.StageName = 'Payment Received';

		update testOpp;
	}


	@IsTest static void filterOppsMarkedAsClosedWon() {
		Opportunity testOpp = [Select Id, StageName, Title__c, Opportunity_Type__c from Opportunity where Name = 'testOpty'];
        
		testopp.StageName = 'Closed Won';
		testOpp.Title__c = 'Managing Director';
		testOpp.Opportunity_Type__c = 'Renewal'; 
		update testOpp;
	}

	@IsTest static void testUpdateContact() {
		Opportunity testOpp = [Select StageName from Opportunity where Name = 'testOpty'];
		List<Opportunity> testOpps = new List<Opportunity> ();

		testOpps.add(testOpp);

		testOpp.StageName = 'Closed won';
		update testOpp;
		OpportunityServices.UpdateContact(testOpps);
		OpportunityServices.incrementYearOnContact(testOpps);

		id ProspectRecID = OpportunityServices.Opp_Prospect_RT_Id;
		id FormerMemberID = OpportunityServices.Opp_Former_Member_RT_Id;
		id ContactMemberID = OpportunityServices.Contact_Memeber_RT_Id;

		Boolean CodeOfConduct = OpportunityServices.IsCodeOfConductAccepted(testOpp.id);

		OpportunityServices.sendEmails(testOpps);

		List<Error_Log__c> Errorlog = OpportunityServices.createCancelBenefitAA(testopps);
	}


	@IsTest static void positiveAAContact() {
		Opportunity testOpp = [Select StageName from Opportunity where Name = 'testOpty'];
		Contact testCon = [Select Id from Contact where Email = 'test_OppServices@email.com'];
		Account testAcct = [Select Id from Account where name = 'testAccount'];

		testCon.Business_Network__c = 'Deal Network';
		update testCon;

		Account networkAccount = new Account(name = 'Deal Network', Type = 'Business', Status__c = 'Active',
		                                     RecordTypeId = RecordTypeServices.getRecordTypeByName('Network', 'Account').Id);
		insert networkAccount;

		KGRenewal__Invoice__c renewalInvoice = new KGRenewal__Invoice__c(KGRenewal__Account__c = testAcct.Id, KGRenewal__Opportunity__c = testOpp.Id,
		                                                                 KGRenewal__Contact__c = testCon.id, KGRenewal__Status__c = 'Paid');
		insert renewalInvoice;

		testOpp.StageName = 'Closed Won';
		update testOpp;

		//System.assertEquals(1, [Select Id from Account_Affiliation__c where Account__c = :networkAccount.id].size());
		//System.assertEquals(networkAccount.Id, [Select Account__c from Account_Affiliation__c where Account__c = :networkAccount.id].Account__c);
		//System.assertEquals(testCon.Id, [Select Contact__c from Account_Affiliation__c where Account__c = :networkAccount.id].Contact__c);
		//System.assertEquals('Network', [Select Recordtype.Name from Account_Affiliation__c where Account__c = :networkAccount.id].Recordtype.Name);
	}

	@isTest static void noNetworkMatchAAContact() {
		Opportunity testOpp = [Select StageName from Opportunity where Name = 'testOpty'];
		Contact testCon = [Select Id from Contact where Email = 'test_OppServices@email.com'];
		Account testAcct = [Select Id from Account where name = 'testAccount'];

		testCon.Business_Network__c = 'Deal Network';
		update testCon;

		testOpp.Name = 'Test Record';
		update testOpp;

		Account networkAccount = new Account(name = 'Deal Network', Type = 'Business', Status__c = 'Active', RecordTypeId = RecordTypeServices.getRecordTypeByName('Network', 'Account').Id);
		insert networkAccount;

		KGRenewal__Invoice__c renewalInvoice = new KGRenewal__Invoice__c(KGRenewal__Account__c = testAcct.Id, KGRenewal__Opportunity__c = testOpp.Id,
		                                                                 KGRenewal__Contact__c = testCon.id, KGRenewal__Status__c = 'Paid');
		insert renewalInvoice;

		testOpp.StageName = 'Closed Won';
		update testOpp;

		//System.assert([SELECT Id FROM Error_Log__c where Record_Id__c = :testOpp.Id].size() > 0);
	}

	//@isTest static void invoiceNotPaidContact(){
	//Opportunity testOpp = [Select StageName from Opportunity where Name = 'testOpty'];
	//Contact testCon = [Select Id from Contact where lastName = 'contact'];
	//Account testAcct = [Select Id from Account where name = 'testAccount'];

	//testCon.Business_Network__c = 'Deal Network';
	//update testCon;

	//Account networkAccount = new Account(name = 'Deal Network', Type = 'Business', Status__c = 'Active', 
	//RecordTypeId = RecordTypeServices.getRecordTypeByName('Network', 'Account').Id);
	//insert networkAccount;

	//KGRenewal__Invoice__c renewalInvoice = new KGRenewal__Invoice__c(KGRenewal__Account__c = testAcct.Id, KGRenewal__Opportunity__c = testOpp.Id, 
	//KGRenewal__Contact__c = testCon.id, KGRenewal__Status__c = 'Paid');
	//insert renewalInvoice;

	//testOpp.Opportunity_Type__c = 'Member';
	//testOpp.StageName = 'Closed Won';
	//update testOpp;

	//System.assertEquals(1, [Select Id from Account_Affiliation__c where Account__c = :networkAccount.id].size());     
	//}

	//Item-07099(Item-3740) test routine for IsLifetimeProductIncluded(Opportunity Opp)
	@isTest static void IsLifetimeProductInclude() {

		//Positive 
		Opportunity testopp = [SELECT id, KGRenewal__Contact__c FROM Opportunity WHERE Name = 'testOpty' LIMIT 1];
		System.assert(OpportunityServices.IsLifetimeProductIncluded(testopp), 'Lifetime Product should be included and true');

	}


	@IsTest static void testSendEmails() {
		Opportunity testOpp = [Select Id, StageName, KGRenewal__Contact__c from Opportunity where Name = 'testOpty'];
		List<Opportunity> testOpps = new List<Opportunity> ();

		testOpps.add(testOpp);

		OpportunityServices.sendEmails(testOpps);

	}
}