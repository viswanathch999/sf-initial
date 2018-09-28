public without sharing class KGServiceClass 
{
//=============================================================================
  public static KGRenewal__VenueSettings__c venueSettings 
  {
    get { return KGRenewal__VenueSettings__c.getOrgDefaults(); }
  }
//=============================================================================
  public static String venueCartCreatedStage 
  {
    get { return venueSettings.KGRenewal__OpportunityStageOnInsertion__c; }
  }
//=============================================================================
// Used by v_checkout
// Returns a KGRenewal.AddressDisplayItem with fields populated from the Contact's MailingAddress

  public static KGRenewal.AddressDisplayItem getFirstAddress() 
  {
    KGRenewal.AddressDisplayItem address = 
            new KGRenewal.AddressDisplayItem( KGRenewal.Cart.getContactId() );
    try
    {
      Contact con = getCurrentContact();
      address.firstName = con.FirstName;
      address.lastName = con.LastName;
      if( con.Account != null )
      { 
        address.organization = con.Account.Name;
      }
      address.streetAddress1 = con.MailingStreet;
      //address.streetAddress2 = '';
      address.city = con.MailingCity;
      address.state = con.MailingState;
      address.postalCode = con.MailingPostalCode;
      //address.country = con.MailingCountry;
      address.country = con.MailingCountryCode;
    }
    catch( Exception e )
    {
      System.debug( 'EXCEPTION in KGServiceClass.getFirstAddress()' );
      System.debug( e );
    }
    return address;
  }
//=============================================================================
// used by v_checkout
// Returns a KGRenewal.AddressDisplayItem with fields populated from the Contact's OtherAddress

  public static KGRenewal.AddressDisplayItem getSecondAddress() 
  {
    KGRenewal.AddressDisplayItem address = 
            new KGRenewal.AddressDisplayItem( KGRenewal.Cart.getContactId() );
    try 
    { 
      Contact con = getCurrentContact();
      address.firstName = con.FirstName;
      address.lastName = con.LastName;
      if( con.Account != null )
      { 
        address.organization = con.Account.Name;
      }
      address.streetAddress1 = con.OtherStreet;
      //address.streetAddress2 = '';
      address.city = con.OtherCity;
      address.state = con.OtherState;
      address.postalCode = con.OtherPostalCode;
      //address.country = con.OtherCountry;
      address.country = con.OtherCountryCode;
    }
    catch( Exception e )
    {
      System.debug( 'EXCEPTION in KGServiceClass.getSecondAddress()' );
      System.debug( e );
    }
    return address;
  }
//=============================================================================
// Query and cache the current User's Contact

  private static Contact cachedContact;

  private static Contact getCurrentContact() 
  {
    if( cachedContact == null 
        && KGRenewal.Cart.getContactId() != null )
    {
      // initialize cachedContact
      try
      {
        cachedContact = [SELECT FirstName,
                              LastName,
                              Name,
                              MailingStreet,
                              MailingCity,
                              MailingState,
                              MailingPostalCode,
                              MailingCountry,
                              MailingCountryCode,
                              OtherStreet,
                              OtherCity,
                              OtherState,
                              OtherPostalCode,
                              OtherCountry,
                              OtherCountryCode,
                              Account.Name,
                              Is_Address1_Primary__c,
                              Is_Address2_Primary__c,
                              Is_Address1_Private__c,
                              Is_Address2_Private__c,
                              Address1_Type__c,
                              Address2_Type__c,
                              Tier_Number__c,
                              Is_Spouse_Member__c,
                              Is_Surviving_Spouse__c,
                              Membership_status__c,
                              RecordTypeId,
                              YPO_WPO_Formula__c,
                              Lifetime_Dues_Status__c    
                          FROM Contact 
                          WHERE Id = :KGRenewal.Cart.getContactId()
                          LIMIT 1];
      }
      catch( Exception e )
      {
        System.debug( 'EXCEPTION in KGServiceClass.getCurrentContact()' );
        System.debug( e );
      }
    }
    return cachedContact;
  }
//=============================================================================
// Returns a list of SelectOption of saved addresses on the Contact

  public static List<SelectOption> getBillingAddressOptions() 
  {
    List<SelectOption> optionsList = new List<SelectOption>();
    Contact con = getCurrentContact();
    if( contactHasFirstAddress(con) )
    {
      optionslist.add( new SelectOption('First', con.MailingStreet) );
    }
    if( contactHasSecondAddress(con) ) 
    {
      optionslist.add( new SelectOption('Second', con.OtherStreet) );
    }
    optionslist.add( new SelectOption('New', 'Enter a new address...') );
    return optionsList;
  }
//=============================================================================
// Returns TRUE if the contact has a Mailing Address1

  public static Boolean contactHasFirstAddress( Contact con ) 
  {
    return con != null && String.isNotBlank( con.MailingStreet );
  }
//=============================================================================
//Returns TRUE if the contact has a Mailing Address2

  public static Boolean contactHasSecondAddress( Contact con ) 
  {
    return con != null && String.isNotBlank( con.OtherStreet );
  }
//=============================================================================

  public static Boolean hasAvailableContactOptions( List<SelectOption> optList ) 
  {
    if( optList.size() == 0 ) 
    { 
      // product doesn't have contact select list, show the button
      return true;
    }
    else 
    { 
      // product has a list, check if any option is NOT disabled
      for( SelectOption opt : optList ) 
      {
        if( ! opt.getDisabled() ) 
        { 
          // this option is not disabled, show the button
          return true;
        }
      }
    }
    // all options are disabled
    return false;
  }
//=============================================================================
/*
 * used by v_catalog, v_detail, v_cart, v_catalog
 * used to load Prospect record type Opp if no other Cart found
 * If KGRenewal.Cart.getOpportunityId() doesn't return a cartId, then we will search for it
 * 1. Get the contact Id
 * 2. Get the buyer role from KG settings
 * 3. Query for Opportunity Contact roles of that contact, with the buyer role, on an active cart
 * 4. We order it by IsPrimary, so if there are several options we choose the cart where the buyer is the primary contact role
 * 5. We set that opportunity as the cart and redirect to v_catalog.
 */
    public static PageReference setProspectOppAsCart()
    {
        System.debug('***************************** ENTER: v_detailControllerExt.loadProspectOpp()');
        PageReference pr = Page.nullCheckPage;
        Id cartId = KGRenewal.Cart.getOpportunityId();
        //if there is no cart, we search for the cart
        if( cartId == null )
        {
            Id contactId = KGRenewal.Cart.getContactId();
            String ocrRole = KGRenewal__VenueSettings__c.getOrgDefaults().KGRenewal__BuyerRole__c; 
            System.debug(loggingLevel.DEBUG, 'ocrRole :'+ocrRole);
            List<OpportunityContactRole> ocrList = [SELECT OpportunityId
                                                    FROM OpportunityContactRole
                                                    WHERE ContactId = :contactId
                                                        AND Role = :ocrRole
                                                        AND Opportunity.KGRenewal__IsActiveCart__c = true
                                                    ORDER BY IsPrimary DESC];
            
            
            System.debug(loggingLevel.DEBUG, 'ocrList :'+ocrList);
            
            if( ocrList.size() > 0 ) {
                PageReference nextPage = Page.Catalog_YPO;
                return KGRenewal.Ecommerce.setOpportunityAsCart(ocrList[0].OpportunityId, nextPage);
            }
        }
        System.debug('***************************** EXIT: v_detailControllerExt.loadProspectOpp()');
        return pr;
    }
//=============================================================================

    public static PageReference setProspectOppAsCartInactive()
    {
        System.debug('***************************** ENTER: v_detailControllerExt.loadProspectOppinactive()');
        PageReference pr = Page.nullCheckPage;
        Id cartId = KGRenewal.Cart.getOpportunityId();
        //if there is no cart, we search for the cart
        if( cartId == null )
        {
            Id contactId = KGRenewal.Cart.getContactId();
            String ocrRole = KGRenewal__VenueSettings__c.getOrgDefaults().KGRenewal__BuyerRole__c; 
            System.debug(loggingLevel.DEBUG, 'ocrRole :'+ocrRole);
            List<OpportunityContactRole> ocrList = [SELECT OpportunityId
                                                    FROM OpportunityContactRole
                                                    WHERE ContactId = :contactId
                                                        AND Role = :ocrRole
                                                        AND Opportunity.Fiscal_date_start__c = :FiscalDateUtility.startOfnextFiscal
                                                    ORDER BY IsPrimary DESC];
            
            
            System.debug(loggingLevel.DEBUG, 'ocrList :'+ocrList);
            
            if( ocrList.size() > 0 ) {
                PageReference nextPage = Page.Catalog_YPO;
                return KGRenewal.Ecommerce.setOpportunityAsCart(ocrList[0].OpportunityId, nextPage);
            }
        }
        System.debug('***************************** EXIT: v_detailControllerExt.loadProspectOpp()');
        return pr;
    }
//=============================================================================
/*
* used by v_catalog and v_detail
* Returns a list of SelectOptions of eligible member contacts for the given product
*/
  public static List<SelectOption> getListOfEligibleContacts(Product2 prod) {
    List<SelectOption> selectOptionList = new List<SelectOption>();
    if(prod == null) {

      return selectOptionList;
    }

    // Used to diable option if there is already an OLI for this contact

    for(Contact con : householdContactsMap.values()) {
      // Only add contact to options if product isn't exlcusive OR contact is eligable
      if(String.isBlank(prod.Exclusive__c) || con.Product_Eligibility__c == prod.Exclusive__c || prod.Exclusive__c == 'Family') {
         Boolean isDisabled = false;

         // If there are items in the cart for this contact, determine if there is a cart item for this product
         if(oliContactMap.containsKey(con.Id)) {
            for(OpportunityLineItem oli : oliContactMap.get(con.Id)) {
                if(prod.Id == oli.PricebookEntry.Product2.Id) {
                    // This contact already has this product
                    isDisabled = true;
                    break;
                }
            }
         }
          
         String LabelName = '<label>'+con.Name+'</label><span>'+con.Record_Type_Name__c+'</span>';
         System.debug('*** Added contact to select option list: '+ labelname);
         
         if((prod.Exclusive__c == 'YNG' && con.RecordTypeId == RecordTypeServices.getRecordTypeByName('Child', 'Contact').Id) || (prod.Exclusive__c == 'Family' && con.RecordTypeId != RecordTypeServices.getRecordTypeByName('Member', 'Contact').Id && con.RecordTypeId != RecordTypeServices.getRecordTypeByName('Former Member', 'Contact').Id)) {
           selectOptionList.add(new SelectOption(con.Id, LabelName, isDisabled));
         }
      }
    }
    return selectOptionList;
  }
//=============================================================================
/*
* Why do we need this?
* Where do we use this?
* Returns a map of Contacts associated with the Memeber's household Account
*/
  private static Map<Id, Contact> householdContactsMap {
      get {
          if(householdContactsMap == null) {
              householdContactsMap = initializeHouseholdContactsMap();
          }
          return householdContactsMap;
      }
  }

  private static Map<Id, Contact> initializeHouseholdContactsMap() {
    Map<Id, Contact> contactsMap = new Map<Id, Contact>();

    Contact con = getCurrentContact();
    Id contactId;
    if(con != null) {
      contactId = con.Id;
    }
    if(contactId == null) {
      ApexPages.addMessage( new ApexPages.message(ApexPages.Severity.Info, 'No ContactId parameter found'));
      return contactsMap;
    }

    // From the Member's active relaionships, get the Account Id(s) for the household account(s)
    List<Relationship__c> membersRelationshipList = [SELECT Account__c
                                                          FROM Relationship__c
                                                          WHERE Contact__c = :contactId
                                                             AND Is_Active__c = true
                                                             AND Relationship_Type__c = 'Member'];
    if(membersRelationshipList.isEmpty()){
      ApexPages.addMessage( new ApexPages.message(ApexPages.Severity.Info, 'No Active Relationships found for this Contact'));
      return contactsMap;
    }

    Set<Id> householdAccountIdSet = new Set<Id>();
    for(Relationship__c rel : membersRelationshipList) {
        householdAccountIdSet.add(rel.Account__c);
    }

    List<Relationship__c> householdRelationshipList = [SELECT Contact__r.Name,
                                                              Contact__r.Product_Eligibility__c,
                                                              Contact__r.Record_Type_Name__c
                                                         FROM Relationship__c
                                                         WHERE Is_Active__c = true
                                                            AND Account__c IN :householdAccountIdSet
                                                         ORDER BY Account__r.Name, Contact__r.Name];
    for(Relationship__c rel : householdRelationshipList) {
        contactsMap.put(rel.Contact__c, rel.Contact__r);
    }
    return contactsMap;
  }
//=============================================================================
    /*
    *  Used to diable select option if there is already an OLI for this contact
    *  Returns map of oli.Contact__c to OLI's for that contact
    * Uses the Opportunity Id and creates a map of all the OLI that the
    *   Opportunity currently has.
    */

    public static Map<Id, List<OpportunityLineItem>> oliContactMap {
        get {
            if(oliContactMap == null) {
                oliContactMap = initializeOliContactMap();
            }
            return oliContactMap;
        }
    }

    private static Map<Id, List<OpportunityLineItem>> initializeOliContactMap() {
      Id cartId = KGRenewal.Cart.getOpportunityId();
      Id contactId = KGRenewal.Cart.getContactId();
      Date endOfFy = getTermEndDate();
      String ocrRole = KGRenewal__VenueSettings__c.getOrgDefaults().KGRenewal__BuyerRole__c;
      List<OpportunityContactRole> ocrList = [SELECT OpportunityId
                                                FROM OpportunityContactRole
                                                WHERE ContactId = :contactId
                                                    AND Role = :ocrRole
                                                    AND IsPrimary = true
                                                    AND (OpportunityId = :cartId
                                                        OR (Opportunity.KGRenewal__ContractEndDate__c =: endOfFy
                                                            AND Opportunity.Probability = 100))
                                                              ];
      Set<Id> oppIdSet = new Set<Id>();
      for(OpportunityContactRole ocr : ocrList) {
        oppIdSet.add(ocr.OpportunityId);
      }

      List<OpportunityLineItem> oliList = [SELECT Name,
                                                  Contact__c,
                                                  UnitPrice,
                                                  TotalPrice,
                                                  Quantity,
                                                  PricebookEntry.Product2.Id,
                                                  PricebookEntry.Product2.Name
                                              FROM OpportunityLineItem
                                              WHERE Contact__c != null
                                              AND OpportunityId IN :oppIdSet
                                              ORDER BY Contact__c
                                                        ];

      Map<Id, List<OpportunityLineItem>> ContactIdToOliListMap = new Map<Id, List<OpportunityLineItem>>();
      for(OpportunityLineItem oli : oliList) {
        if(ContactIdToOliListMap.containsKey(oli.Contact__c)) {
          ContactIdToOliListMap.get(oli.Contact__c).add(oli);
        }
        else {
          ContactIdToOliListMap.put(oli.Contact__c, new List<OpportunityLineItem>{oli});
        }
      }
      return ContactIdToOliListMap;
    }
//=============================================================================
// This method returns the calculated Term end date
  public static Date getTermEndDate() {
    if(System.Now().month() >= 4) {
      // If April or after, set the year next year.
      return Date.newInstance(System.Now().year() + 1, 6, 30);
    }
    else {
      // Before April, so end date is June 30 of this year
      return Date.newInstance(System.Now().year(), 6, 30);
    }
  }
//=============================================================================
// This method returns the Date of the first day of the current month.

  public static Date getFirstDayOfMonth() {
    return Date.newInstance(System.Now().year(), System.Now().month(), 1);
  }
//=============================================================================
// This method returns the Date of the first day of the Annual Billing Cycle

  public static Date getFirstDayOfFiscalYear() {
    Date myDate = Date.newInstance(System.Now().year()-1, 7, 1);
    // If it is July or after then set the year to this year.
    if(System.Now().month() >= 7) {
      myDate = myDate.addMonths(12);
    }
    return myDate;
  }
//=============================================================================
  /*
  * Make sure there is only one primary opportunity contact role that matches the required contact and role
  * The for loop is more efficient if the list of OCRs is sorted with primary OCRs first
  */
  public static void setOpportunityContactRoles(Opportunity cart) {
    Boolean matchFound = false;     //set to true once the list contains a matching primary ocr

    for (OpportunityContactRole ocr : cart.OpportunityContactRoles) {
      if (!matchFound && ocr.Role == venueSettings.KGRenewal__BuyerRole__c){ //cr.ContactId == cart.KGRenewal__Contact__c &&
        //this is the first matching opportunity contact role
        matchFound = true;
        ocr.IsPrimary = true;
      }
      else {
        //not the correct contact role
        //(already found a match or contact or role is incorrcet)
        //If any of these are primary, we should make them not primary
        ocr.IsPrimary = false;
      }
    }

    if (cart.OpportunityContactRoles.size() > 0) {
      update cart.OpportunityContactRoles;
    }

    if (!matchFound){
      //only create a new OCR if we don't already have one in the list that matches and is primary
      Id currentContactId;
      if (cart.KGRenewal__Contact__c != null) {
        currentContactId = cart.KGRenewal__Contact__c;
      }
      else if (KGRenewal.Cart.getContactId() != null) {
        currentContactId = KGRenewal.Cart.getContactId();
      }
      if (currentContactId != null) {
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = cart.Id,
                                                              ContactId = currentContactId,
                                                              Role = venueSettings.KGRenewal__BuyerRole__c,
                                                              IsPrimary = true
                                                              );
        matchFound = true;
        insert ocr;
      }
    }
    try {
      OpportunityContactRole c = [SELECT ContactId FROM OpportunityContactRole WHERE IsPrimary = true AND OpportunityId =: cart.Id];
      cart.KGRenewal__Contact__c = c.Contactid;
      update cart;
    }
    catch(Exception e) {
    }
  }
//=============================================================================
// This method activates the current cart and disables all other possible carts on the Account

  public static void activateCart(Opportunity cart) {
    cart.KGRenewal__IsActiveCart__c = true;
    cart.KGRenewal__SyncingRenewal__c = false;
    cart.StageName = venueCartCreatedStage;
    List<Opportunity> allCarts = new List<Opportunity>();
    allCarts.add(cart);
    if(cart.AccountId != null){
      List<Opportunity> oldCarts = [SELECT Id FROM Opportunity WHERE AccountId =: cart.AccountId AND Id !=: cart.Id AND KGRenewal__IsActiveCart__c = true AND IsClosed = FALSE];
      //system.debug('old carts: ');
      //system.debug(JSON.serialize(oldCarts));

      for (Opportunity o : oldCarts){
        o.KGRenewal__IsActiveCart__c = false;
        allCarts.add(o);
      }
    }
    update allCarts;
  }

//=============================================================================
// encryptionKey used to encrypt the opportunity
// Please never change this key unless you want to break everything

  private static Blob encryptionKey 
  {
    get { return Blob.valueOf('z0Ak@j%x.!42nCja'); }
  }
//=============================================================================
// Decrypts a string and returns it. 
// Parameter has to be url decoded for this to work!

  public static String decryptString( String encryptedText ) 
  {
    String decryptedClearText = '';
    try
    {
      // Althouggh this was previously URL Encoded, 
      // we don't have to URL decode it because that already happens 
      // when the parameter is inputted/grabbed from the url
      Blob encodedEncryptedBlob = EncodingUtil.base64Decode( encryptedText );
      Blob decryptedBlob = Crypto.decryptWithManagedIV( 'AES128', 
                                                          encryptionKey, 
                                                          encodedEncryptedBlob );
      decryptedClearText = decryptedBlob.toString();
    }
    catch( Exception e )
    {
      System.debug( 'EXCEPTION in KGServiceClass.decryptString()' );
      System.debug( e );
    }
    return decryptedClearText;
  }
//=============================================================================
// This method encrypts a string, url encodes it and returns it

  public static String encryptString( String clearText ) 
  {
    String encodedCipherText = '';
    try 
    {
      Blob cipherText = Crypto.encryptWithManagedIV( 'AES128', 
                                                      encryptionKey, 
                                                      Blob.valueOf(clearText) );
      encodedCipherText = EncodingUtil.base64Encode( cipherText );

      //Because this is going in a URL parameter, we have to URL Encode this
      encodedCipherText = EncodingUtil.urlEncode( encodedCipherText, 'UTF-8' );
    }
    catch( Exception e )
    {
      System.debug( 'EXCEPTION in KGServiceClass.encryptString()' );
      System.debug( e );
    }
    return encodedCipherText;
  }
//=============================================================================
// Static Boolean to keep track of whether our trigger has already fired or not

  public static Boolean hasEncryptedOptyId 
  {
    get 
    {
      if( hasEncryptedOptyId == null ) 
      {
        hasEncryptedOptyId = false;
      }
      return hasEncryptedOptyId;
    }
    set;
  }
//=============================================================================
// Take in a list of Opportunities and update them with encrypted Ids
// Performs DML

/*
  // used by 'setCartToken' Opportunity Trigger 
  // which was set to Active=false on Jan 24 2017
  public static void encryptOptyId(List<Opportunity> optys) {
    if(hasEncryptedOptyId) {
      return;
    }
    List<Opportunity> optysToUpdate = new List<Opportunity>();
    for(Opportunity opp : optys) {
      //This shouldnt happen in an after insert trigger or update trigger
      if(opp.Id != null && String.isBlank(opp.CartToken__c)) {
        optysToUpdate.add(new Opportunity(Id = opp.Id, CartToken__c = encryptString(opp.Id)));
      }
    }
    update optysToUpdate;
    hasEncryptedOptyId = true;
  }
*/
//=============================================================================
  /*
  * Set Dates on Dues Line Item
  *
  */
  /*
  public static void setDatesOnOpportunityLineItems(List<OpportunityLineItem> oliList) {
    Map<Id, Product2> productMap = getProductMap(oliList);
    for(OpportunityLineItem oli : oliList) {
      String family = productMap.get(oli.Product2Id).family;
      if('Annual Dues'.equals(family)) {
        oli.KGRenewal__ContractEffectiveDate__c = getFirstDayOfMonth();
        oli.KGRenewal__ContractEndDate__c = getTermEndDate();
      }
      else if('Member Benefit'.equals(family)) {
        oli.KGRenewal__ContractEffectiveDate__c = getFirstDayOfFiscalYear();
        oli.KGRenewal__ContractEndDate__c = getTermEndDate();
      }
    }
  }*/
//=============================================================================
/*
  Sets the description on the Line item. This is so we can see the description field
  on an Invoice PDF. The max description length is 255 characters.

  public static void setLineItemDescription(List<OpportunityLineItem> oliList) {
    Map<Id, Product2> productMap = getProductMap(oliList);
    Map<Id, Opportunity> oppMap = getOppMap(oliList);

    Set<Id> contactIdSet = new Set<Id> ();
    for(OpportunityLineItem oli : oliList) {
      if(oli.Contact__c != null) {
        contactIdSet.add(oli.Contact__c);
      }
    }
    Map<Id, Contact> contactMap = new Map <Id, Contact> ([SELECT Name
                                      FROM Contact
                                      WHERE Id IN :contactIdSet]);

    for(OpportunityLineItem oli : oliList) {
      String oliDescription = '';

      Opportunity theOpp = oppMap.get(oli.OpportunityId);
      Product2 myProduct = productMap.get(oli.Product2Id);
      String family = myProduct.family;

      if(myProduct != null) {
        //If the Product is prorated, State the Effective date and End date of the product
        if(theOpp != null && myProduct.isProrate__c == true && theOpp.KGRenewal__PreviousSale__c == null){
          oliDescription += 'You are purchasing this item for the term of ' + (getFirstDayOfMonth()).format() + ' - ' + oli.KGRenewal__ContractEndDate__c.month()+ '/' + oli.KGRenewal__ContractEndDate__c.day()+ '/' + oli.KGRenewal__ContractEndDate__c.year() +'. ';
        }
        //If the product is a Lifetime Due, State how many installments are left
        if('Lifetime Dues'.equals(family) && theOpp.Remaining_Installments__c != null) {
          oliDescription += 'There are ' + theOpp.Remaining_Installments__c + ' remaining installments (including this one). ';
        }
        //If the Product has a contact in it's contact__c field, state the contact's name
        if(oli.Contact__c != null && contactMap.get(oli.Contact__c) != null) {
          oliDescription += 'This ' + myProduct.Name +' is for ' + contactMap.get(oli.Contact__c).Name + '. ';
        }
        // Append the item description.
        if (myProduct.Description != null) {
          oliDescription += myProduct.Description;
          oli.Description = oliDescription.abbreviate(255);
        }
      }
    }
  }*/
//=============================================================================
  /*
  *  Add Initiaton Fee when Dues added
  * If the Line item is an Annual Due AND if the Opportunity is NOT a Renewal add the line item to the list.
  */
  /*
  public static void addInitiationFeeOnNonRenewal(List<OpportunityLineItem> oliList) {
    Map<Id, Product2> productMap = getProductMap(oliList);
    Map<Id, Opportunity> oppMap = getOppMap(oliList);

    List<OpportunityLineItem> annualDuesOliList = new List<OpportunityLineItem>();
    for(OpportunityLineItem oli : oliList) {
      String family = productMap.get(oli.Product2Id).family;
      if('Annual Dues'.equals(family) && oppMap.get(oli.OpportunityId).KGRenewal__PreviousSale__c == null) {
          annualDuesOliList.add(oli);
      }
    }

    if(annualDuesOliList.size() > 0) {
      //Check if the Oli's opportunity is a renewal
      // Create Map of all Annual Fees price book entries
      List<PricebookEntry> pbeList = [SELECT Pricebook2Id, UnitPrice FROM PricebookEntry WHERE Product2.family = 'Annual Fees' AND IsActive = true AND Pricebook2.IsStandard = false];

      Map<Id, PricebookEntry> pbeMap = getPbeMap(pbeList);

      // Create Annual Fee OLI for Dues OLI
      List<OpportunityLineItem> annualFeesOliList = new List<OpportunityLineItem>();
      for(OpportunityLineItem oli : annualDuesOliList) {
        Id pbId = oppMap.get(oli.OpportunityId).Pricebook2Id;
        PricebookEntry annualFeesPbe = pbeMap.get(pbId);
        OpportunityLineItem annualFeesOli = new OpportunityLineItem(OpportunityId = oli.OpportunityId,
                                                                    PricebookEntryId = annualFeesPbe.Id,
                                                                    KGRenewal__ContractEffectiveDate__c = getFirstDayOfMonth(),
                                                                    KGRenewal__ContractEndDate__c = getTermEndDate(),
                                                                    KGRenewal__IsLockedInCart__c = true,
                                                                    KGRenewal__IsRenewal__c = false,
                                                                    UnitPrice = annualFeesPbe.UnitPrice,
                                                                    Quantity = 1);
        annualFeesOliList.add(annualFeesOli);
      }
      insert annualFeesOliList;
    }
  }*/
//=============================================================================
/* Not used anyomre
  * Returns the first day of month in a string format
  *
  public static String getfirstDayOfMonthString() {
    return System.Now().formatGMT('yyyy-MM') +'-01';
  }
//=============================================================================
  /*
  * Returns the first day of billing cycle in a string format
  *
  public static String getfirstDayOfCycle(){
    if(System.Now().month() <= 6) {
      return String.valueof((System.Now().year() - 1))+'-07-01';
    }
    else {
      return System.Now().formatGMT('yyyy') +'-07-01';
    }
  }*/
//=============================================================================
  /*
  * This method takes in a list of OpportunityLineItems and sets their dates.
  */
  /*
  public static void setLineItemDates(List<OpportunityLineItem> oliList) {
    Set<Id> productIdSet = new Set<Id>();
    for(OpportunityLineItem oli : oliList) {
      productIdSet.add(oli.product2Id);
    }
    if(productIdSet.isEmpty()) {
      return;
    }
    List<Product2> productList = [SELECT family FROM Product2 WHERE Id IN :productIdSet];
    Map<Id, Product2> productMap = new Map<Id, Product2>(productList);

    for(OpportunityLineItem oli : oliList) {
      String family = productMap.get(oli.Product2Id).family;
      if('Annual Dues'.equals(family)) {
        oli.KGRenewal__ContractEffectiveDate__c = getFirstDayOfMonth();
        oli.KGRenewal__ContractEndDate__c = getTermEndDate();
      }
      else if('Member Benefit'.equals(family)) {
        oli.KGRenewal__ContractEffectiveDate__c = getFirstDayOfFiscalYear();
        oli.KGRenewal__ContractEndDate__c = getTermEndDate();
      }
    }
  }
*/
//=============================================================================
/*
* NO LONGER USED
* Returns a list of SelectOptions of eligible member contacts for the given product
*
  private static List<SelectOption> getListOfEligibleContacts(Id prodId) {
    //query for product2.Exclusive__c of that pbe
    // We can replace this query by using the site configuration
    Product2 prod = [SELECT Exclusive__c
                        FROM Product2
                        WHERE Id = :prodId];
    if(prod == null) {
      return null;
    }

    List<SelectOption> selectOptionList = new List<SelectOption>();

    for(Contact con : householdContactsMap.values()) {
      // Only add contact to options if product isn't exlcusive OR contact is eligable
      if(String.isBlank(prod.Exclusive__c) || con.Product_Eligibility__c == prod.Exclusive__c) {
         Boolean isDisabled = false;

         // If there are items in the cart for this contact, determine if there is a cart item for this product
         if(oliContactMap.containsKey(con.Id)) {
            for(OpportunityLineItem oli : oliContactMap.get(con.Id)) {
                if(prod.Id == oli.PricebookEntry.Product2.Id) {
                    isDisabled = true;
                    break;
                }
            }
         }
         selectOptionList.add(new SelectOption(con.Id, con.Name, isDisabled));
      }
    }
    return selectOptionList;
  }
*/
//=============================================================================
}