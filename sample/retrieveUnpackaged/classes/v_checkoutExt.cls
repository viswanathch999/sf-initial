public without sharing class v_checkoutExt
{
  public KGRenewal.VenueCheckoutController venueCtrl { get; set; }
  public Boolean isPaymentSuccessful { get; private set; }

  //public Id cartId { get; set; }

  public Boolean isCodeOfConductAccepted { get; set; }
  public String paymentMode { get; set; }

  public List<SelectOption> billingAddressOptions { get; private set; }
  public String selectedOption { get; set; }
  public static FINAL String CLOSED_WON = 'Closed Won';
  //public Integer gatewayValue { get; set; }

  public List<SelectOption> paymentOptions {
    get {
      List<SelectOption> optionslist = new List<SelectOption>();
      optionslist.add( new SelectOption('Payment Card', 'Payment Card') );
      optionslist.add( new SelectOption('Check or Wire Payment', 'Check or Wire Payment') );
      return optionslist;
    }
  }


/*****************************************************************************/
  public v_checkoutExt( KGRenewal.VenueCheckoutController v ) {
    venueCtrl = v;
    isCodeOfConductAccepted = true;
    paymentMode = 'Payment Card';

    billingAddressOptions = KGServiceClass.getBillingAddressOptions();
    if( billingAddressOptions.size() > 1 ) {
      if( KGServiceClass.contactHasFirstAddress(v.currentContact) ) {
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
      venueCtrl.BillingAddress = KGServiceClass.getFirstAddress();
    }
    else if( selectedOption == 'Second' ) {
      venueCtrl.BillingAddress = KGServiceClass.getSecondAddress();
    }
    else if( selectedOption == 'New' ) {
      venueCtrl.BillingAddress = new KGRenewal.AddressDisplayItem( KGRenewal.Cart.getContactId() );
    }
  }
/*****************************************************************************/

  public void toggleGateway() {
   // System.debug('gatewayValue: '+gatewayValue);
   // venueCtrl.gateway = gatewayValue ;
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
             CLOSED_WON  : KGRenewal__VenueSettings__c.getOrgDefaults().KGRenewal__OpportunityStageOnOrderSubmission__c)
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
//This method is called instead of calling the controller's pay() method directly in order to run additional logic after the payment
  public PageReference newPay() {
	venueCtrl.BillingAddress.streetAddress1 = ' ';
	venueCtrl.BillingAddress.city = ' ';
	venueCtrl.BillingAddress.state = ' ';
	venueCtrl.BillingAddress.postalCode = ' ';
	venueCtrl.BillingAddress.country = ' ';

	PageReference pr = Page.v_confirm;
    isPaymentSuccessful = false;
    System.debug( '****** venueCtrl.gateway: ' + venueCtrl.gateway );

    // If the payment is successful, the user will be navigated to their confirm page
    //return page;

    if (paymentMode == 'Check or Wire Payment') {
      // Check or wire payment
      venueCtrl.setShippingAndBillingDetails();
      venueCtrl.updateOpportunityToQuoteStage();
      pr.getParameters().put( 'method', 'check' );
/*
      sendEmail();
*/
      isPaymentSuccessful = true;
    }
    else if( ! Test.isRunningTest() ) {
      // Credit card payment
      // Call the checkout controller's pay method
	  venueCtrl.BillingAddress = new KGRenewal.AddressDisplayItem();
      pr = venueCtrl.pay();
      System.debug( '****** ' + KGRenewal.CalloutService.getPrettyStackDebugString() );
      if( pr != null ) {
        isPaymentSuccessful = true;
      }
    } 
    else {
      // Test context for credit card payment
      isPaymentSuccessful = true;
    }
/*
    if( isPaymentSuccessful ) {
      //Additional logic if payment is successful
      pr.getParameters().put( 'status', 'success' );
      if( ! Test.isRunningTest() ) {
        update new Opportunity ( Id = venueCtrl.cartId, 
                                  Code_of_Conduct_Accepted__c = true );
      }     
    }
*/
    return pr;
  }
/*****************************************************************************/
  private boolean sendEmail() {
    boolean isEmailSuccess = false;
    try {
      System.debug( '****** before email' );
      update new Opportunity( Id = venueCtrl.cartId, 
                              SendQuote__c = true );
      System.debug( '****** after email' );
      isEmailSuccess = true;
    }
    catch( Exception e ) {
      System.debug( '****** email failed' );
      System.debug( '****** ' + e );
    }
    return isEmailSuccess;
  }
/*****************************************************************************/
  // action method that loads inital Opp (Prospect record type) as cart
  public PageReference setProspectOppAsCart()
  {
      return KGServiceClass.setProspectOppAsCart();
  }
/*****************************************************************************/
}