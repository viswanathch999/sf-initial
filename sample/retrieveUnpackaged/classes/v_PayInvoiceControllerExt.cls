public without sharing class v_PayInvoiceControllerExt {

	public static String DEFAULT_ERROR = Label.Payment_Error_Message;

	public ApexPages.StandardController stdCtrl { get; set; }
	public String paymentErrorMsgYPO { get; set; }

	public KGRenewal.VenuePayInvoiceController ctrl {
		get {
			if( ctrl == null ) {
				ctrl = new KGRenewal.VenuePayInvoiceController( stdCtrl );
			}
			return ctrl;
		}
		set;
	}

	public KGRenewal.AddressDisplayItem billingAddress {
		get {
    		System.debug('###billingAddress in get: ' + billingAddress);
    		System.debug('###ctrl.billingAddress in get: ' + ctrl.billingAddress);
		return ctrl.billingAddress;
		}
		set;
	}

	public List<SelectOption> billingAddressOptions { get; private set; }
	public String selectedOption { get; set; }

	public KGRenewal__Invoice__c invoice {
		get {
		if (invoice == null) {
			invoice = (KGRenewal__Invoice__c)stdCtrl.getRecord();
		}
		return invoice;
		}
		set;
	}

	public Id currentContactId { 
		get {
			if(currentContactId == null){
				currentContactId = invoice.KGRenewal__Contact__c;
			}
			return currentContactId;
		}
		set;
	}

	public Contact currentContact {
		get {
			if (currentContact == null) {
				setContact();
			}
			return currentContact;
		} set;
	}

	public void setContact() {
		List<Contact> conList= [SELECT FirstName,
										LastName,
										Name,
										MailingStreet,
										MailingCity,
										MailingState,
										MailingPostalCode,
										MailingCountry,
										OtherStreet,
										OtherCity,
										OtherState,
										OtherPostalCode,
										OtherCountry,
										Email,
										Phone,
										AccountId,
										Account.Name,
										Fax
                                FROM Contact
                                WHERE Id = :currentContactId];
        if(conList.size() > 0){
			currentContact = conList[0];
        }
	}
/*****************************************************************************/
// Constructor
    public v_PayInvoiceControllerExt( ApexPages.StandardController stdCtrl ) {
        this.stdCtrl = stdCtrl;
        
        billingAddressOptions = KGServiceClass.getBillingAddressOptions();
        
        if( billingAddressOptions.size() > 1 && currentContact != null) {
            if(KGServiceClass.contactHasFirstAddress(currentContact) ) {
                selectedOption = 'First';
            }
            else {
                selectedOption = 'Second';
            }
            setBillingAddress();
        }
    }
/*****************************************************************************/

	public void setBillingAddress() {
		if( selectedOption == 'First' ) {
			Contact con = currentContact;
			billingAddress.contactId = currentContactId;
			billingAddress.firstName = con.FirstName;
			billingAddress.lastName = con.LastName;
			billingAddress.streetAddress1 = con.MailingStreet;
			billingAddress.city = con.MailingCity;
			billingAddress.state = con.MailingState;
			billingAddress.postalCode = con.MailingPostalCode;
			billingAddress.country = con.MailingCountry;
			System.debug('###set billing address first: ' + billingAddress);
		}
		else if( selectedOption == 'Second' ) {
			Contact con = currentContact;
			billingAddress.contactId = currentContactId;
			billingAddress.firstName = con.FirstName;
			billingAddress.lastName = con.LastName;
			billingAddress.streetAddress1 = con.OtherStreet;
			billingAddress.city = con.OtherCity;
			billingAddress.state = con.OtherState;
			billingAddress.postalCode = con.OtherPostalCode;
			billingAddress.country = con.OtherCountry;
			System.debug('###set billing address second: ' + billingAddress);
		}
		else if( selectedOption == 'New' ) {
			billingAddress.contactId = currentContactId;
			billingAddress.firstName = null;
			billingAddress.lastName = null;
			billingAddress.streetAddress1 = null;
			billingAddress.city = null;
			billingAddress.state = null;
			billingAddress.postalCode = null;
			billingAddress.country = null;
			System.debug('###set billing address new: ' + billingAddress);
		}
	}
/*****************************************************************************/
	
	// This payment method is used instead of the default pay()
	// method so we can change the error message and perform 
	// any other steps necessary before or after processing.
	public void newPay() {
		System.debug('+++++ newPay()');
		if (!Test.isRunningTest()) {
			ctrl.pay();
		}

		KGRenewal__Transaction__c trans = new KGRenewal__Transaction__c();
		try {
			trans = [SELECT Id, KGRenewal__Opportunity__c, KGRenewal__Invoice__c, KGRenewal__Invoice__r.KGRenewal__Opportunity__c, 
							KGRenewal__GatewayReasonCode__c, KGRenewal__Message__c, KGRenewal__Status__c, YPO_Error_Message__c 
					 FROM KGRenewal__Transaction__c 
					 WHERE KGRenewal__Invoice__c = :ctrl.invoice.Id
					 ORDER BY CreatedDate DESC 
					 LIMIT 1];
		} 
		catch (Exception e) {}

		if (trans.KGRenewal__Opportunity__c == null) {
			trans.KGRenewal__Opportunity__c = trans.KGRenewal__Invoice__r.KGRenewal__Opportunity__c;
		}
		
		// Item 7173 - custom YPO error messages
		if (trans.KGRenewal__Status__c != 'Success') {
			List<Payment_Error__c> errorMsgs = [SELECT YPO_Message__c FROM Payment_Error__c WHERE Error_Code__c = :trans.KGRenewal__GatewayReasonCode__c];
			
			if (errorMsgs.size() > 0) {
				trans.YPO_Error_Message__c = errorMsgs[0].YPO_Message__c;
			}
			else {
				Payment_Error__c payError = new Payment_Error__c();
				payError.Error_Code__c = trans.KGRenewal__GatewayReasonCode__c;
				payError.Cybersource_Message__c = trans.KGRenewal__Message__c;
				payError.YPO_Message__c = DEFAULT_ERROR;
				try { 
					insert payError;
				} 
				catch (DmlException dex) {
					System.debug('Could not create Payment_Error__c entry: ' + dex);
				}
			}

			try { 
				update trans;
			}
			catch (DmlException dex) {
				System.debug('Could not update transaction in v_PayInvoiceControllerExt.newPay(): ' + dex);
			}
			paymentErrorMsgYPO = trans.YPO_Error_Message__c;
		}
	}

}