@istest (seeAllData=true) // required for KG licensing
public class v_InvoiceExt_Test  {
	static account ChapterAccount;
	static Contact testContact;
	static Opportunity oOppty;
	private static User partnerUser { get; set; } 

	static testmethod void PageChecks() {
		ChapterAccount = TestServices.createChapterAccount('Test Chapter',null);
		insert ChapterAccount;

		testContact = TestServices.createContact(ChapterAccount.id,true);

		Id profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community User(Custom)' LIMIT 1].Id;
		partnerUser = TestServices.createPartnerCommunityUser(testContact.Id, profileId);
		partnerUser.UserRoleId = null;
		insert partnerUser;
		
		oOppty = TestServices.createOpp('Cycle Open',ChapterAccount.Id,testContact.Id,true);
		TestServices.Build_OpportunityLineItem(oOppty.id);

		TestServices.createOppLineItems(oOppty.Id,1,'Lifetime Dues',true);

		List<OpportunityLineItem> OppLineItems = [Select Id, Product2Id, Product_Name__c, Product_Family__c, Quantity, UnitPrice, PricebookEntryId From OpportunityLineItem where OpportunityId = :oOppty.id];
		
		List<Id> Prodids = new List<Id>();
		for (OpportunityLineItem Opplineitem : OppLineItems) {
			Prodids.add(OppLineItem.Product2id);
		}

		//KGRenewal.Cart.add(Prodids);

		oOppty.StageName = 'Payment Pending';
		oOppty.Probability = 100;
		update oOppty;

		System.runAs(partnerUser) {

			List<KGRenewal__Invoice__c> Invoice = [Select id From KGRenewal__Invoice__c where KGRenewal__Opportunity__c =: oOppty.Id];
		
			System.assert(Invoice.size() == 1,'An Invoice should have been created!');

			List<KGRenewal__Invoice__c> Invoices = [SELECT id, (SELECT Id FROM KGRenewal__InvoiceItems__r)
									  FROM KGRenewal__Invoice__c Where KGRenewal__Opportunity__c =: oOppty.id];
			System.assert(Invoices.size() > 0, 'Invoice is missing');
			//System.assert(Invoices[0].KGRenewal__InvoiceItems__r.size() > 0, 'This is missing some of the OppLineItems. Current Invoices:' + Invoices.size() + ' LineItems:' + Invoices[0].KGRenewal__InvoiceItems__r.size());

			Test.startTest();
				Test.setCurrentPage(Page.v_invoice);
				ApexPages.currentPage().getParameters().put('id', Invoices[0].Id);
				ApexPages.currentPage().getParameters().put('Modal', 'Grace');
				ApexPages.StandardController sc = new ApexPages.StandardController(Invoices[0]);
				v_InvoiceExt vCtrl = new v_InvoiceExt(sc);

				//System.assert(vCtrl.isLifetime,'isLifetime should be true.');
				System.assert(!vCtrl.displayTransitionModal,'Transition should not be set.');
				System.assert(vCtrl.displayGraceModal,'Grace should be set.');

				Test.setCurrentPage(Page.v_invoice);
				ApexPages.currentPage().getParameters().put('id', Invoices[0].Id);
				ApexPages.currentPage().getParameters().put('Modal', 'Transition');
				sc = new ApexPages.StandardController(Invoices[0]);
				vCtrl = new v_InvoiceExt(sc);

				//System.assert(vCtrl.isLifetime,'isLifetime should be true.');
				System.assert(vCtrl.displayTransitionModal,'Transition should be set.');
				System.assert(!vCtrl.displayGraceModal,'Grace should not be set.');
			Test.stopTest();
		}

	}
}