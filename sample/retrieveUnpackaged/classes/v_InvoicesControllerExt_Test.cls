@isTest (seeAllData=true) // required for KG licensing
private class v_InvoicesControllerExt_Test {
	
	private static User adminUser { get; set; } 
	private static User partnerUser { get; set; } 

	private static void setup() {
		v_TestUtil.createSiteConfig();
		
		Id adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
		// required for KG licensing
		adminUser = [SELECT Id, Profile.Name, Email, isActive 
					 FROM User 
					 WHERE Profile.Name = 'System Administrator' 
					 AND isActive = true 
					 AND (Email = 'lphillips@ypo.org' OR Email = 'mfrizzell@ypo.org')
					 LIMIT 1]; 
		
		System.runAs(adminUser) {
			Account chapter = TestServices.createAccount(true);
			Contact member = TestServices.createContact(chapter.Id, 'TestUser', true);

			Id profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community User(Custom)' LIMIT 1].Id;
			partnerUser = TestServices.createPartnerCommunityUser(member.Id, profileId);
			partnerUser.UserRoleId = null;
			insert partnerUser;
			
			Opportunity opp = TestServices.createOpp('Cycle Open', chapter.Id, member.Id, false);
			opp.Fiscal_Date_Start__c = Date.newInstance(Date.today().year(), 7, 1);
            opp.KGRenewal__IsActiveCart__c = true;
            opp.KGRenewal__BillingFrequency__c = 'Periodic';
            opp.KGRenewal__BillingPeriod__c = 999.0;
			opp.Certification_Type__c = 'Third Party Certify';
			opp.Certification_Status__c = 'Complete';
			opp.Grace_Status__c = 'No Grace Needed';
			opp.KGRenewal__CreateNewSubscription__c = true;
			opp.KGRenewal__IsActiveCart__c = true;
            opp.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member', 'Opportunity').Id;
			insert opp;

			System.debug('opp init: ' + opp);

			List<OpportunityLineItem> oliLifetime = TestServices.createOppLineItems(opp.Id, 1, 'Lifetime Dues', true);
			List<OpportunityLineItem> oliDues = TestServices.createOppLineItems(opp.Id, 1, 'Annual Dues', true);
			//List<OpportunityLineItem> oliBenefit = TestServices.createOppLineItems(opp.Id, 1, 'Member Benefit', true);

			opp.StageName = 'Payment Pending';
			opp.Probability = 100;
			update opp;

			System.debug('opp final: ' + opp);
			System.debug('line items: ' + [SELECT Id, Name, TotalPrice FROM OpportunityLineItem WHERE OpportunityId = :opp.Id]);
		}
	}

	@isTest
	private static void pageLoad_Positive() {
		setup();
		
		Opportunity opp = [SELECT Id, KGRenewal__Contact__c, Amount, StageName, Probability 
						   FROM Opportunity 
						   WHERE KGRenewal__Contact__c = :partnerUser.ContactId 
						   LIMIT 1];
		System.debug('opp in test: ' + opp);

		List<KGRenewal__Invoice__c> invoices = [SELECT Id, Name, KGRenewal__Account__c, KGRenewal__Subscription__c, KGRenewal__Opportunity__c, KGRenewal__Contact__c, KGRenewal__BillingDate__c, 
													   KGRenewal__DueDate__c, KGRenewal__Status__c, KGRenewal__TotalAmount__c, KGRenewal__AmountPaid__c, KGRenewal__AmountDue__c
												FROM KGRenewal__Invoice__c 
												WHERE KGRenewal__Opportunity__c = :opp.Id];
		for (KGRenewal__Invoice__c inv : invoices) {
			inv.KGRenewal__Status__c = 'Open';
			inv.KGRenewal__Contact__c = partnerUser.ContactId;
		}
		update invoices;
		System.debug('invoices: ' + invoices);

		List<KGRenewal__InvoiceItem__c> invLineItems = [SELECT Id, Name, KGRenewal__Amount__c, KGRenewal__QuantityDisplay__c, KGRenewal__UnitPriceDisplay__c FROM KGRenewal__InvoiceItem__c WHERE KGRenewal__Invoice__c IN :Pluck.ids('Id', invoices)];
		System.debug('inv line items: ' + invLineItems);

		System.runAs(partnerUser) {
			KGRenewal.VenueInvoicesController kgCtrl = new KGRenewal.VenueInvoicesController();
			v_InvoicesControllerExt vCtrl = new v_InvoicesControllerExt(kgCtrl);
			System.debug('vCtrl : ' + vCtrl);

			PageReference pageRef = Page.v_invoices;

			Test.startTest();
            Test.setCurrentPage(pageRef);
			Test.stopTest();
		}
	}

	@isTest
	private static void pageLoad_Negative() {
		
	}
}