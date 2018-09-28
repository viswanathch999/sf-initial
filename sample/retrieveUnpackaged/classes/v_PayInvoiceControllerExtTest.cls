@isTest(seeAllData = true)
private class v_PayInvoiceControllerExtTest {

	static User customer;

	static void setup() {

		// Create a site configuration for Venue
		v_TestUtil.createSiteConfig();

		// Create our customer user
		customer = v_TestUtil.createCustomerUser();
	}

	@isTest
	static void itShouldGiveUsCodeCoverage() {

		setup();

		Account testAccount = [SELECT Id FROM Account WHERE Name = 'KG Chapter' LIMIT 1];
		KGRenewal__Invoice__c inv = (KGRenewal__Invoice__c) KGRenewal__Invoice__c.getSObjectType().newSObject(null, true);
		inv.KGRenewal__Account__c = testAccount.Id;
		inv.KGRenewal__AdjustmentAmount__c = 10;
		inv.KGRenewal__Contact__c = customer.ContactId;
		insert inv;

		Test.startTest();

		System.runAs(customer) {

			ApexPages.currentPage().getParameters().put('id', inv.Id);

			// Construct a new instance
			ApexPages.StandardController stdCtrl = new ApexPages.StandardController(inv);
			v_PayInvoiceControllerExt ext = new v_PayInvoiceControllerExt(stdCtrl);

			// Cover properties and get methods
			KGRenewal.AddressDisplayItem billingAddress = ext.billingAddress;
			Contact currentContact = ext.currentContact;

			// Cover setters
			ext.selectedOption = 'First';
			ext.setBillingAddress();

			ext.selectedOption = 'Second';
			ext.setBillingAddress();

			ext.selectedOption = 'New';
			ext.setBillingAddress();
		}
	}

	@isTest
	static void itShouldSetBillingAddress() {

		setup();
		Contact c = [SELECT MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry FROM Contact WHERE FirstName = 'Customer Portal Manager'];
		c.MailingStreet = 'Mailing Street';
		c.MailingCity = 'Mailing City';
		c.MailingState = 'California';
		c.MailingPostalCode = '12345';
		c.MailingCountry = 'United States';
		c.OtherStreet = 'Other Street';
		c.OtherCity = 'Other City';
		c.OtherState = 'Alberta';
		c.OtherPostalCode = '54321';
		c.OtherCountry = 'Canada';
		update c;

		Account testAccount = [SELECT Id FROM Account WHERE Name = 'KG Chapter' LIMIT 1];
		KGRenewal__Invoice__c inv = (KGRenewal__Invoice__c) KGRenewal__Invoice__c.getSObjectType().newSObject(null, true);
		inv.KGRenewal__Account__c = testAccount.Id;
		inv.KGRenewal__AdjustmentAmount__c = 10;
		inv.KGRenewal__Contact__c = customer.ContactId;
		insert inv;

		Test.startTest();

		System.runAs(customer) {

			ApexPages.currentPage().getParameters().put('id', inv.Id);

			// Construct a new instance
			ApexPages.StandardController stdCtrl = new ApexPages.StandardController(inv);
			v_PayInvoiceControllerExt ext = new v_PayInvoiceControllerExt(stdCtrl);

			// Cover setters
			ext.selectedOption = 'First';
			ext.setBillingAddress();
			System.assertEquals('Mailing Street', ext.billingAddress.streetAddress1);
			System.assertEquals('California', ext.billingAddress.state);
			System.assertEquals('12345', ext.billingAddress.postalCode);
			System.assertEquals('United States', ext.billingAddress.country);
			System.assertEquals('Mailing City', ext.billingAddress.city);

			ext.selectedOption = 'Second';
			ext.setBillingAddress();

			System.assertEquals('Other Street', ext.billingAddress.streetAddress1);
			System.assertEquals('Alberta', ext.billingAddress.state);
			System.assertEquals('54321', ext.billingAddress.postalCode);
			System.assertEquals('Canada', ext.billingAddress.country);
			System.assertEquals('Other City', ext.billingAddress.city);

			ext.selectedOption = 'New';
			ext.setBillingAddress();

			System.assertEquals(null, ext.billingAddress.streetAddress1);
			System.assertEquals(null, ext.billingAddress.state);
			System.assertEquals(null, ext.billingAddress.postalCode);
			System.assertEquals(null, ext.billingAddress.country);
			System.assertEquals(null, ext.billingAddress.city);
			ext.newPay();
		}
	}

	@isTest
	static void itShouldSetCurrentContact() {
		setup();
		Contact c = [SELECT MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry FROM Contact WHERE FirstName = 'Customer Portal Manager'];


		Account testAccount = [SELECT Id FROM Account WHERE Name = 'KG Chapter' LIMIT 1];
		KGRenewal__Invoice__c inv = (KGRenewal__Invoice__c) KGRenewal__Invoice__c.getSObjectType().newSObject(null, true);
		inv.KGRenewal__Account__c = testAccount.Id;
		inv.KGRenewal__Contact__c = customer.ContactId;
		insert inv;

		Test.startTest();

		System.runAs(customer) {

			ApexPages.currentPage().getParameters().put('id', inv.Id);

			// Construct a new instance
			ApexPages.StandardController stdCtrl = new ApexPages.StandardController(inv);
			v_PayInvoiceControllerExt ext = new v_PayInvoiceControllerExt(stdCtrl);

			// Cover properties and get methods
			ext.setContact();
			// Make sure extension has the correct Contact
			System.assertEquals(c.Id, ext.currentContact.Id, 'setContact did not return correct Contact.');
		}
	}
}