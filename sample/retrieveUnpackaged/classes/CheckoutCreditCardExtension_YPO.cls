public without sharing class CheckoutCreditCardExtension_YPO {

	public static String DEFAULT_ERROR = Label.Payment_Error_Message;

	public KGRenewal.VenueCheckoutController venueCtrl { get; set; }
	public Boolean isPaymentSuccessful { get; private set; }
	private static Boolean LifetimeProductIncluded {
		get {
			if (LifetimeProductIncluded == Null)
			{
				LifetimeProductIncluded = false;
			}

			return LifetimeProductIncluded;
		}
		set;
	} //Item-07099
	public String paymentErrorMsgYPO { get; set; }
	public String CurrencyCode { set; get; }
	public Contact con { set; get; }
	public Contact conts { set; get; }

	public static string checkoutLogId { set; get; }

	//public Id cartId { get; set; }
	public Boolean isLifetimeMembers { set; get; }
	public Boolean isLifetimeMembersCC { set; get; }
	public Boolean isCodeOfConductAccepted { get; set; }
	public Boolean hasSecondAddress { 
		get{
			if (hasSecondaddress == null) {
				hasSecondAddress = false;
			}
			return hasSecondAddress;
		}
		set; 
	}
	public Boolean hasFirstAddress { 
		get {
			if (hasFirstAddress == null) {
				hasFirstAddress = false;
			}
			return hasFirstAddress;
		}
		set; 
	}
	public String paymentMode { get; set; }

	public List<SelectOption> billingAddressOptions { get; private set; }
	public String selectedOption { get; set; }

	//public Integer gatewayValue { get; set; }

	public KGRenewal.AddressDisplayItem firstAddress { get; set; } // = new KGRenewal.AddressDisplayItem(KGRenewal.Cart.getContactId());
	public KGRenewal.AddressDisplayItem secondAddress { get; set; }
	public KGRenewal.AddressDisplayItem newAddress { get; set; }
	public static FINAL String CLOSED_WON = 'Closed Won';
	public List<SelectOption> paymentOptions {
		get {
			List<SelectOption> optionslist = new List<SelectOption> ();
			//optionslist.add( new SelectOption('None', '--Select Payment Mode--'));
			//Item-07099 If a Lifetime product line item is included, disable the Credit Card option
			if (!isLifetimeMembers) {
				optionslist.add(new SelectOption('Credit Card', 'Credit Card', false));
			} else {
				optionslist.add(new SelectOption('Credit Card', 'Credit cards cannot be accepted for invoices that include lifetime dues payments.', true));
			}
			optionslist.add(new SelectOption('Check/Wire', 'Check or Wire'));
			return optionslist;
		}
	}

	public boolean cameFromLifetimePage {
		get {
			if (cameFromLifetimePage == null) {
				cameFromLifetimePage = false;
				if (ApexPages.currentPage().getParameters().get('lifetime') == 'true') {
					cameFromLifetimePage = true;
				} 
			}
			return cameFromLifetimePage;
		} set;

	}

	public boolean successfulTransExist {
		get {
			if (successfulTransExist == null) {
				successfulTransExist = false;

				Integer numSuccessfulTrans = [SELECT count() FROM KGRenewal__Transaction__c WHERE KGRenewal__Opportunity__c = :venueCtrl.cartId AND KGRenewal__Status__c = 'Success'];
				if (numSuccessfulTrans >= 1) {
					successfulTransExist = true;
				}
			}
			return successfulTransExist;
		} set;
	}

	public String vatNumber {
		get {
			if (vatNumber == null) {
				vatNumber = String.valueOf('');
				List<Opportunity> lstOppts = [SELECT VAT__c FROM Opportunity WHERE Id = :venueCtrl.cartId LIMIT 1];
				if (lstOppts.size() > 0) {
					vatNumber = String.valueof(lstOppts[0].VAT__c);
				}
			}
			return vatNumber;
		}
		set;
	}

	public String CompanyName {
		get {
			if (CompanyName == null) {
				CompanyName = String.valueOf('');
				List<Opportunity> lstOppts = [SELECT Qualifying_Company__c FROM Opportunity WHERE Id = :venueCtrl.cartId LIMIT 1];
				if (lstOppts.size() > 0) {
					CompanyName = String.valueof(lstOppts[0].Qualifying_Company__c);
				}
			}
			return CompanyName;
		}
		set;
	}


	public String MembershipID {
		get { 
			MembershipId = String.valueOf('');
			List<Contact> MemberID = [SELECT Id, Contact_Number__c FROM Contact WHERE Id = :con.Id LIMIT 1];
			if (MemberID.size() > 0) {
				MembershipId = String.valueof(MemberID[0].Contact_Number__c);
			}
			return MembershipId;
		}
		set;

	}

	public String AddressType1 {
		get { 
			AddressType1 = String.valueOf('');
			List<Contact> AddType1 = [SELECT Id, Address1_Type__c FROM Contact WHERE Id = :con.Id LIMIT 1];
			if (AddType1.size() > 0) {
				AddressType1 = String.valueof(AddType1[0].Address1_Type__c);
			}
			return AddressType1;
		}
		set;
	}

	public String AddressType2 {
		get { 
			AddressType2 = String.valueOf('');
			List<Contact> AddType2 = [SELECT Id, Address2_Type__c FROM Contact WHERE Id = :con.Id LIMIT 1];
			if (AddType2.size() > 0) {
				AddressType2 = String.valueof(AddType2[0].Address2_Type__c);
			}
			return AddressType2;
		}
		set;
	}

	/*****************************************************************************/
	public CheckoutCreditCardExtension_YPO(KGRenewal.VenueCheckoutController v) {

		venueCtrl = v;

		//Item-07099 open up the product services and set the Lifetime product status if it exists.
		LifetimeProductIncluded = OpportunityServices.IsLifetimeProductIncluded(New Opportunity(Id = venueCtrl.cartid, KGRenewal__Contact__c = venueCtrl.currentContact.id));

		isCodeOfConductAccepted = true;
		isLifetimeMembers = false;

		//paymentMode = paymentOptions[0].getValue(); //Item-07099 - set to the default first choice of the PaymentOptions.
		con = v.currentContact;

		conts = new Contact(lastName = 'test');
		CurrencyCode = UserInfo.getDefaultCurrency();
		try {
			List<Contact> conWithLifetime = [SELECT Id, Lifetime_Dues_Status__c FROM Contact WHERE Id = :con.Id LIMIT 1];
			System.debug('###conWithLifetime: ' + conWithLifetime);
			if (!conWithLifetime.isEmpty()) {
				if (LifetimeProductIncluded) {
					isLifetimeMembers = true;
				}

				if (isLifetimeMembers == false)
				{
					paymentMode = paymentOptions[0].getValue(); //Item-07099 - set to the default first choice of the PaymentOptions.
					isLifetimeMembersCC = false;
				}
				else if (isLifetimeMembers == true)
				{
					paymentMode = paymentOptions[1].getValue();
					isLifetimeMembersCC = true;
				}
			}
		} catch (Exception excpt) {
			System.debug('Contact Lifetime retrevial failed: ' + excpt);
		}

		billingAddressOptions = KGServiceClass.getBillingAddressOptions();
		if (billingAddressOptions.size() > 0) {
			if (KGServiceClass.contactHasFirstAddress(v.currentContact)) {
				firstAddress = KGServiceClass.getFirstAddress();
				hasFirstAddress = true;
			} 
			if (KGServiceClass.contactHasSecondAddress(v.currentContact)) {
				secondAddress = KGServiceClass.getSecondAddress();
				hasSecondAddress = true;
			} 

			if (hasFirstAddress) {
				selectedOption = 'First';
			} else if (hasSecondAddress) {
				selectedOption = 'Second';
			} else {
				selectedOption = 'New';
			}
			setBillingAddress();
		}

		if (venueCtrl.cartId != null && venueCtrl.lineItems != null && venueCtrl.lineItems.size() > 0)
		{
			Map<Id, OpportunityLineItem> oliMap;
			oliMap = new Map<Id, OpportunityLineItem> ([SELECT Contact__r.Name
			                                           FROM OpportunityLineItem
			                                           WHERE OpportunityId = :venueCtrl.cartId]);
			for (KGRenewal.Cart.LineItem item : venueCtrl.lineItems)
			{
				String contactName = '';
				if (!oliMap.isEmpty()) {
					if (item<> null && item.recordId<> null) {
						system.debug('---------oliMap---------' + oliMap);
						system.debug('---------item.recordId---------' + item.recordId);
						system.debug('---------oliMap.get(item.recordId).Contact__c---------' + oliMap.get(item.recordId).Contact__c);
						if (oliMap.get(item.recordId).Contact__c<> null)
						contactName = oliMap.get(item.recordId).Contact__r.Name;
					}
				}

				if (String.isNotBlank(contactName))
				{
					item.description = contactName;
					//item.customFields.put('Contact__r.Name', oliMap.get(item.recordId).Contact__r.Name);
					//update(item.record);
				}
			}
		}
	}

	/*****************************************************************************/
	public void setBillingAddress() {
		System.debug('@@@ in set billing: ' + selectedOption);
		if (selectedOption == 'First') {
			venueCtrl.BillingAddress = KGServiceClass.getFirstAddress();
		}
		else if (selectedOption == 'Second') {
			venueCtrl.BillingAddress = KGServiceClass.getSecondAddress();
		}
		else if (selectedOption == 'New') {
			venueCtrl.BillingAddress = new KGRenewal.AddressDisplayItem(KGRenewal.Cart.getContactId());
		}
	}
	/*****************************************************************************/

	public void setCurrentBillingAddress() {
		venueCtrl.BillingAddress.country = conts.MailingCountryCode;
		venueCtrl.BillingAddress.state = conts.MailingStateCode;
		venueCtrl.BillingAddress.streetAddress1 = conts.MailingStreet;

		//Bringing in line with all other addresses on the system.
		if (String.isNotBlank(venueCtrl.BillingAddress.streetAddress2)) {
			venueCtrl.BillingAddress.streetAddress1 = venueCtrl.BillingAddress.streetAddress1 + '\r\n' + venueCtrl.BillingAddress.streetAddress2;
			venueCtrl.BillingAddress.streetAddress2 = null;
		}

		venueCtrl.BillingAddress.city = conts.MailingCity;
		venueCtrl.BillingAddress.postalCode = conts.MailingPostalCode;
	}
	public void setCurrentBillingAddresstoMailing() {

		venueCtrl.BillingAddress = FirstAddress;
	}
	public void setCurrentBillingAddressToOther() {

		venueCtrl.BillingAddress = secondAddress;
	}
	public void toggleGateway() {
		//System.debug('gatewayValue: '+gatewayValue);
		// venueCtrl.gateway = gatewayValue ;
		system.debug('---------paymentMode-------' + paymentMode);
	}

	/*****************************************************************************/
	/*
	  public PageReference customPay() {
	 
	  KGRenewal__PaymentCard__c card = venueCtrl.paymentCard.getObject();
	  card.KGRenewal__Contact__r = venueCtrl.currentContact;
	 
	  Map<String, Object> reqMap = new Map<String, Object>();
	  reqMap.put('doNotSendReceipt', true);
	  reqMap.put('contact', venueCtrl.currentContact);
	  reqMap.put('amount', (Decimal)venueCtrl.summary.get('billed_amount'));
	  reqMap.put('opportunityId', venueCtrl.cartId);
	  reqMap.put('paymentCardSecurityCode', venueCtrl.paymentCard.securityCode);
	  reqMap.put('billingAddress', venueCtrl.billingAddress.getObject());
	  reqMap.put('isCartCheckout', true);
	  reqMap.put('paymentCard', card);
	 
	  String reqJSON = JSON.serialize(reqMap);
	  Opportunity cartOpty = [SELECT AccountId, 
	  CloseDate 
	  FROM Opportunity 
	  WHERE Id = :venueCtrl.cartId];
	 
	  KGRenewal.PaymentGateway.TransactionRequest request = (KGRenewal.PaymentGateway.TransactionRequest)JSON.deserialize(reqJSON, KGRenewal.PaymentGateway.TransactionRequest.class);
	 
	  KGRenewal.PaymentGateway.TransactionResult result;
	 
	  try {
	  result = KGRenewal.PaymentGateway.createCaptureTransaction(request);
	  }
	  catch(Exception e) {
	  venueCtrl.paymentErrorMessage = result.message;
	  }
	 
	  if(result != null && result.isSuccess) {
	  Opportunity cart = new Opportunity(
	  Id = venueCtrl.cartId,
	  CloseDate = cartOpty.CloseDate < System.Today() ? System.Today() : cartOpty.CloseDate,
	  KGRenewal__BilledAmount__c = (Decimal)venueCtrl.summary.get('billed_amount'),
	  StageName = (KGRenewal__VenueSettings__c.getOrgDefaults().KGRenewal__OpportunityStageOnOrderSubmission__c == null ?
	  CLOSED_WON : KGRenewal__VenueSettings__c.getOrgDefaults().KGRenewal__OpportunityStageOnOrderSubmission__c)
	  );
	  update cart;
	  }
	  else if (result != null){
	  venueCtrl.paymentErrorMessage = result.message;
	  return null;
	  }
	  else {
	  return null;
	  }
	  return null;
	  }
	 */
	/*****************************************************************************/
	// Transaction is inserted so workflow can send email
	// Workflow rule 'KG Online Checkout Email' relies on the values set in this method
	public void insertOfflineTransaction(Id invoiceId)
	{
		try { //Item-07188
			KGRenewal__Transaction__c trans = new KGRenewal__Transaction__c(
			                                                                KGRenewal__Amount__c = 0,
			                                                                KGRenewal__Contact__c = KGRenewal.Cart.getContactId(),
			                                                                KGRenewal__Opportunity__c = venueCtrl.cartId,
			                                                                KGRenewal__Invoice__c = invoiceId,
			                                                                KGRenewal__Status__c = 'Success',
			                                                                //KGRenewal__Type__c =  'Authorization and Capture',
			                                                                KGRenewal__TransactionMethod__c = 'Offline',
			                                                                KGRenewal__TransactionMethodDetails__c = 'Check or wire payment pending'
			);

			insert trans;
		} catch(Exception e) {
			sendPaymentErrorEmail(e, venueCtrl.cartId, 'YPO transaction email Invoice exception');
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'We have experienced an issue emailing your invoice! Please contact Member Services to have another invoice generated.'));
		}
	}
	@future()
	public static void createCheckoutLog(string loggedinUser, string loggedinUserName, string payMod)
	{
		Checkout_Log__c cl = new Checkout_Log__c();
		cl.User_Id__c = loggedinUser;
		cl.User_Name__c = loggedinUserName;
		cl.Submission_Date_Time__c = dateTime.now();
		cl.Payment_Mode__c = payMod;
		cl.Payment_Sucessfull__c = false;
		insert cl;
		checkoutLogId = cl.id;
	}


	/**
	 * @description goBackAction() returns the ReviewOrder_YPO page back to the Checkout_Check_Wire_YPO page. 
	 * @return PageReference
	 */
	public PageReference goBackAction() {
		venueCtrl.paymentErrorMessage = null;
		paymentErrorMsgYPO = null;
		PageReference pr = page.Checkout_Check_Wire_YPO;
		pr.setRedirect(TRUE);
		return pr;
	}

	/*****************************************************************************/
	//This method is called instead of calling the controller's pay() 
	// method directly in order to run additional logic after the payment
	public PageReference newPay() {

		System.debug('****** venueCtrl.gateway: ' + venueCtrl.gateway);
		venueCtrl.shippingAddress.label = 'Shipping';
		//venueCtrl.billingAddress.label = 'Billing';

		string usrId = UserInfo.getUserId();
		string usrName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
		PageReference pr = Page.Confirmation_YPO;
		Id invoiceid;
		isPaymentSuccessful = false;
		String oDues_Status_Is = 'In Progress'; //DE7869 - Initialization of the status value

		try {
			if (paymentMode == 'Check/Wire') {
				// Check or wire payment
				venueCtrl.setShippingAndBillingDetails();
				venueCtrl.updateOpportunityToQuoteStage(); // Update stage to 100% for Encore to create an Invoice

				// Insert a Transaction linked to the Inovice so workflow rule sends an email
				List<KGRenewal__Invoice__c> invoiceList = ([SELECT Id FROM KGRenewal__Invoice__c WHERE KGRenewal__Opportunity__c = :venueCtrl.cartId LIMIT 1]);
				if (invoiceList.size() > 0)
				{
					invoiceId = invoiceList[0].Id;
					insertOfflineTransaction(invoiceId);
				}

				pr.getParameters().put('method', 'check');
				isPaymentSuccessful = true;
			} else {
				// Credit card payment
				// Call the checkout controller's pay method
				pr = venueCtrl.pay();
				if (pr != null) {
					isPaymentSuccessful = true;
					oDues_Status_Is = 'Complete'; //DE7869 - Set to 'Complete' for successful CC payments
				}
			}

			// PAYMENT SUCCESS
			if (isPaymentSuccessful) {
				Savepoint sp1 = Database.setSavepoint();
				Try {

					update new Contact(Id = con.Id, Accept_Code_Conduct__c = true);

					Checkout_Log__c cl = new Checkout_Log__c();
					cl.User_Id__c = UserInfo.getUserId();
					cl.User_Name__c = UserInfo.getUserName();
					cl.Submission_Date_Time__c = dateTime.now();
					cl.Payment_Mode__c = paymentMode;
					cl.Payment_Sucessfull__c = true;
					Insert cl;

					Savepoint sp2 = Database.setSavepoint();
					try {

						if (invoiceid == null) {
							invoiceid = ([SELECT Id from KGRenewal__Invoice__c where KGRenewal__Opportunity__c = :venueCtrl.cartId LIMIT 1]).Id;
						}
						pr.getParameters().put('invoice', invoiceid);
						update new Opportunity(Id = venueCtrl.cartId, Dues_Page_Status_Exchange__c = oDues_Status_Is); //DE7869 - Assign the set status
						cl.Post_Payment_Updates__c = true;

					} catch(Exception e) {
						cl.Post_Payment_Updates__c = false;
						system.debug(e);
						Database.rollback(sp2);
					} finally {
						update cl;
					}
				} catch(Exception excpt) {
					System.debug(excpt);
					Database.rollback(sp1);
				}
			}

			// PAYMENT ERROR
			else {
				// Get error code from payment response XML
				String paymentResponse = KGRenewal.CalloutService.getPrettyStackDebugString();
				String errorCode = '';
				System.debug('###Payment Response: ' + paymentResponse + '/' + paymentResponse.indexOf('<c:reasonCode>'));
				if (paymentResponse.indexOf('<c:reasonCode>') > 0) {
					errorCode = paymentResponse.substring(paymentResponse.indexOf('<c:reasonCode>') + 14, paymentResponse.indexOf('</c:reasonCode>'));
				}
				System.debug('###Payment Error codes: ' + errorCode + '/' + venueCtrl.paymentErrorMessage);

				// Use payment error code to lookup YPO friendly message
				try {
					paymentErrorMsgYPO = [SELECT YPO_Message__c FROM Payment_Error__c WHERE Error_Code__c = :errorCode LIMIT 1].YPO_Message__c;
				}

				// If there is not a friendly message for this code, create a default message
				catch(Exception e) {
					Payment_Error__c pError = new Payment_Error__c();
					pError.Error_Code__c = errorCode;
					pError.Cybersource_Message__c = venueCtrl.paymentErrorMessage;
					pError.YPO_Message__c = DEFAULT_ERROR;
					paymentErrorMsgYPO = DEFAULT_ERROR;
					try {
						insert pError;
					}
					catch(DmlException dex) {
						System.debug('Could not create Payment_Error__c entry: ' + dex);
						paymentErrorMsgYPO = DEFAULT_ERROR;
					}
				}

				// Update transaction with error details
				try {
					KGRenewal__Transaction__c tran = [SELECT Id FROM KGRenewal__Transaction__c WHERE KGRenewal__Opportunity__c = :venueCtrl.cartId LIMIT 1];
					tran.KGRenewal__Message__c = errorCode + ' - ' + venueCtrl.paymentErrorMessage;
					update tran;
				} catch(DmlException dex) {
					System.debug('Could not update transaction record with error details: ' + dex);
				} catch(Exception excpt) {
					System.debug('Could not update transaction record with error details: ' + excpt.getMessage());
					sendPaymentErrorEmail(excpt, venueCtrl.cartid, 'YPO online checkout exception');
				}

				// Update checkout log with payment details
				Checkout_Log__c cl = new Checkout_Log__c();
				cl.User_Id__c = UserInfo.getUserId();
				cl.User_Name__c = UserInfo.getUserName();
				cl.Submission_Date_Time__c = dateTime.now();
				cl.Payment_Mode__c = paymentMode;
				cl.Payment_Sucessfull__c = false;
				insert cl;
			}

		}

		// Unexpected error processing payment (not a decline)
		catch(Exception e) {
			sendPaymentErrorEmail(e, venueCtrl.cartId, 'YPO online checkout exception');
			venueCtrl.paymentErrorMessage = DEFAULT_ERROR;
			//ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.FATAL, venueCtrl.paymentErrorMessage) );
			pr = null;
		}

		if (successfulTransExist) {
			System.debug('###isPaymentSuccessful due to prev transactions: ' + isPaymentSuccessful);
			isPaymentSuccessful = true;
		}

		if (!isPaymentSuccessful) {
			return null;
		} else {
			Id prospectRecordTypeId = RecordTypeServices.getRecordTypeByName('Prospect', 'Contact').Id;
			Contact oContact = new Contact();
			if (con.id != null)
				oContact = [Select recordtypeid from contact where Id=: con.id];

			if (oContact.RecordTypeId != prospectRecordTypeId) {
				//New Renewal Thankyou page
				pr = Page.SplashScreen_Thankyou;
				pr.setRedirect(TRUE);
			} else {
				//original Prospect confirmation page.
				pr = Page.Confirmation_YPO;
				pr.setRedirect(TRUE);
			}
		}

		return pr;
	}
	/*****************************************************************************/
	@TestVisible
	private boolean sendEmail() {
		boolean isEmailSuccess = false;
		try {
			System.debug('****** before email');
			if (venueCtrl<> null && venueCtrl.cartId<> null)
			update new Opportunity(Id = venueCtrl.cartId, SendQuote__c = true);

			System.debug('****** after email');
			isEmailSuccess = true;
		}
		catch(Exception e) {
			System.debug('****** email failed');
			System.debug('****** ' + e);
		}
		return isEmailSuccess;
	}

	/*****************************************************************************/
	/**
	 * Send an email to notify of an uncaught exception during payment.
	 *
	 * @param  {Exception}  e     The exception that was thrown during payment.
	 * @param  {Id}  cartId       Id of the cart.
	 */
@TestVisible
	private List<Messaging.SendEmailResult> sendPaymentErrorEmail(Exception e, Id cartId, String SubjectBody) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		// Set the to addresses 
		List<String> toAddresses = Chapter_Health_Batch_Error_Email_Setting__c.getInstance().Error_Email_Recipients__c.split(';');
		mail.setToAddresses(toAddresses);
		// Set the subject
		mail.setSubject(SubjectBody);
		// Set the body
		String plainTextBody = UserInfo.getOrganizationName();
		plainTextBody += '\n\norg Id:  ' + UserInfo.getOrganizationId();
		plainTextBody += '\n\ncart Id:  ' + cartId;
		plainTextBody += '\n\n==== EXCEPTION MESSAGE ====\n\n' + e.getMessage();
		plainTextBody += '\n\n==== STACK TRACE ====\n\n' + e.getStackTraceString();
		mail.setPlainTextBody(plainTextBody);
		// Set other fields
		mail.setReplyTo('support@kineticgrowth.com');
		try { mail.setSenderDisplayName('Venue eCommerce'); } catch(Exception ex) { }
		mail.setUseSignature(false);
		// Send the email
		return Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { mail }, false);
	}
	/*****************************************************************************/
	// action method that loads inital Opp (Prospect record type) as cart
	public PageReference setProspectOppAsCart()
	{
		return KGServiceClass.setProspectOppAsCart();
	}
	public PageReference reviewOrder() {

		System.debug('VENUECTRL: ' + venueCtrl);
		System.debug('###venueCtrl.paymentCard: ' + venueCtrl.paymentCard);
		update new Opportunity(Id = venueCtrl.cartId, Vat__c = vatNumber, Qualifying_Company__c = CompanyName);
		System.debug('Id = ' + venueCtrl.cartId + ', Vat__c = ' + vatNumber + ', Qualifying_Company__c = ' + CompanyName);
		//venueCtrl.paymentCard.cardholderName = venueCtrl.paymentCard.cardholderName;
		System.debug('###venueCtrl.paymentCard.cardholderName After: ' + venueCtrl.paymentCard.cardHolderName);
		PageReference pg = Page.ReviewOrder_YPO;
		pg.getParameters().put('lifetime', ApexPages.currentPage().getParameters().get('lifetime'));
		//pg.setRedirect(TRUE);
		return pg;
	}
	/*****************************************************************************/


}