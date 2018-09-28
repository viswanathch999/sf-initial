@isTest(seeAllData=true)
public with sharing class KGServiceClassTest {
  public static List<Product2> products;
  public static User customer;
  public static User guest;
  public static Map<String, PricebookEntry> pbeMap;
  /*The setup will create:
      - An Account(Chapter) with a pricebook
      - Add "Test Products" and Pricebook Entries
      - Query for Profile and Contact to create a Customer User
   */
  public static void setup() {

    Id pricebookId = Test.getStandardPricebookId();

    // Clear existing pricebook entries in our working pricebook since test data
    // isolation is disabled.
    List<PricebookEntry> existingPricebookEntries = [SELECT IsActive FROM PricebookEntry WHERE Pricebook2Id = :pricebookId AND IsActive = true];
    for(PricebookEntry pe : existingPricebookEntries){
      pe.IsActive = false;
    }
    update existingPricebookEntries;

    RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND Name='Chapter' LIMIT 1];
    Account acct = new Account(Name = 'KG Chapter',
                               RecordType = rt,
                               Type = 'Chapter',
                               Date_Board_Approved__c = KGServiceClass.getFirstDayOfFiscalYear(),
                               Start_Date__c = System.Today(),
                               KGRenewal__Pricebook2__c = pricebookId);
    insert acct;
    products = new List<Product2> {
      new Product2(Name = 'Test - YNG+ Benefit', IsActive = true, KGRenewal__eCommerceEnabled__c = true, KGRenewal__AvailableForPurchase__c = true, KGRenewal__Subscription__c = true, KGRenewal__PriceTerm__c = 12, Exclusive__c ='YNG', Family = 'Member Benefit'),
      new Product2(Name = 'Test - Aon WPO Complimentary Member Benefit (Worldaware)', IsActive = true, Complimentary_WPO_Product__c = true, Worldaware_benefit__c = true, KGRenewal__AvailableForPurchase__c = true, KGRenewal__Subscription__c = true, KGRenewal__PriceTerm__c = 12, Family = 'Member Benefit'),
      new Product2(Name = 'Test - YPO Member Benefit', IsActive = true, KGRenewal__eCommerceEnabled__c = true, KGRenewal__AvailableForPurchase__c = true, KGRenewal__Subscription__c = true, KGRenewal__PriceTerm__c = 12, Exclusive__c ='Member', Family = 'Member Benefit'),
      new Product2(Name = 'Test - Worldwide Dues 1', IsActive = true, KGRenewal__eCommerceEnabled__c = true, KGRenewal__AvailableForPurchase__c = true, KGRenewal__Subscription__c = true, KGRenewal__PriceTerm__c = 12, Family = 'Annual Dues', Tier_Number__c = '1', isProrate__c = true),
      new Product2(Name = 'Test - Worldwide Dues 2', IsActive = true, KGRenewal__eCommerceEnabled__c = true, KGRenewal__AvailableForPurchase__c = true, KGRenewal__Subscription__c = true, KGRenewal__PriceTerm__c = 12, Family = 'Annual Dues', Tier_Number__c = '2', isProrate__c = true),
      new Product2(Name = 'Test - Worldwide Dues 3', IsActive = true, KGRenewal__eCommerceEnabled__c = true, KGRenewal__AvailableForPurchase__c = true, KGRenewal__Subscription__c = true, KGRenewal__PriceTerm__c = 12, Family = 'Annual Dues', Tier_Number__c = '3', isProrate__c = true),
      new Product2(Name = 'Test - Worldwide Dues 4', IsActive = true, KGRenewal__eCommerceEnabled__c = true, KGRenewal__AvailableForPurchase__c = true, KGRenewal__Subscription__c = true, KGRenewal__PriceTerm__c = 12, Family = 'Annual Dues', Tier_Number__c = '4', isProrate__c = true)

    };

    //Use a reference to prevent the field from being packaged
    products[0].put('KGRenewal__ReplacementType__c', 'Blue');

    insert products;

    List<PriceBookEntry> prices = new List<PricebookEntry> {
      new PricebookEntry(IsActive = true, Product2Id = products[0].id,
                         Pricebook2Id = pricebookId, UnitPrice = 295),
      new PricebookEntry(IsActive = true, Product2Id = products[1].id,
                         Pricebook2Id = pricebookId, UnitPrice = 0),
      new PricebookEntry(IsActive = true, Product2Id = products[2].id,
                         Pricebook2Id = pricebookId, UnitPrice = 500),
      new PricebookEntry(IsActive = true, Product2Id = products[3].id,
                         Pricebook2Id = pricebookId, UnitPrice = 3000),
      new PricebookEntry(IsActive = true, Product2Id = products[4].id,
                         Pricebook2Id = pricebookId, UnitPrice = 3000),
      new PricebookEntry(IsActive = true, Product2Id = products[5].id,
                         Pricebook2Id = pricebookId, UnitPrice = 3000),
      new PricebookEntry(IsActive = true, Product2Id = products[6].id,
                         Pricebook2Id = pricebookId, UnitPrice = 3000)
    };

    insert prices;
    Map<String, PricebookEntry> tempMap = new Map<String, PricebookEntry>();
    Integer tempInt = 1;
    for(PricebookEntry pbe: prices){
      tempMap.put('PricebookEntry ' + String.valueOf(tempInt), pbe);

      tempInt++;
    }
    pbeMap = tempMap;
    customer = v_TestUtil.createCustomerUser();

    for(String s: pbeMap.keySet()){
      System.debug(s);
    }
  }
  /*createHouseHold:
      - An Account(Relationship) 'KG Unit Test Household'
      - Adds four children contacts to the household
      - Query for Profile and Contact to create a Customer User
   */
  public static void createHouseHold() {
    RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND Name='Relationship' LIMIT 1];
    Account householdAccount = new Account(Name = 'KG Unit Test Household',
                                           RecordType = rt,
                                           Type = 'Relationship',
                                           YPOI_Type__c = 'YPO Chapter'
                                           );
    insert householdAccount;
    RecordType childRectordType = [SELECT Id, Name, SObjectType FROM RecordType WHERE SObjectType='Contact' AND Name='Child' LIMIT 1];
    Date myDate = date.newinstance(1990, 2, 17);

    List<Contact> contactList = new List<Contact>{
      new Contact(AccountId = householdAccount.Id,
                  FirstName = 'FirstChild', LastName = 'KG',
                  RecordTypeId = childRectordType.Id,
                  Gender__c = 'Male',
                  Birthdate = myDate,
                  Email = 'test-user@fakeemail.com1'),
      new Contact(AccountId = householdAccount.Id,
                  FirstName = 'SecondChild', LastName = 'KG',
                  RecordTypeId = childRectordType.Id,
                  Birthdate = myDate,
                  Gender__c = 'Male',
                  Email = 'test-user@fakeemail.com1'),
      new Contact(AccountId = householdAccount.Id,
                  FirstName = 'ThirdChild', LastName = 'KG',
                  RecordTypeId = childRectordType.Id,
                  Birthdate = myDate,
                  Gender__c = 'Male',
                  Email = 'test-user@fakeemail.com1'),
      new Contact(AccountId = householdAccount.Id,
                  FirstName = 'FourthChild', LastName = 'KG',
                  RecordTypeId = childRectordType.Id,
                  Birthdate = myDate,
                  Gender__c = 'Male',
                  Email = 'test-user@fakeemail.com1'),
      new Contact(AccountId = householdAccount.Id,
                  FirstName = 'FifthChild', LastName = 'KG',
                  RecordTypeId = childRectordType.Id,
                  Birthdate = myDate,
                  Gender__c = 'Male',
                  Email = 'test-user@fakeemail.com1'),
      new Contact(AccountId = householdAccount.Id,
                  FirstName = 'SixthChild', LastName = 'KG',
                  RecordTypeId = childRectordType.Id,
                  Birthdate = myDate,
                  Gender__c = 'Male',
                  Email = 'test-user@fakeemail.com1'),
      new Contact(AccountId = householdAccount.Id,
                  FirstName = 'SeventhChild', LastName = 'KG',
                  RecordTypeId = childRectordType.Id,
                  Birthdate = myDate,
                  Gender__c = 'Male',
                  Email = 'test-user@fakeemail.com1')
      };
      insert contactList;

    //Create Relationships
    List<Relationship__c> relationshipList = new List<Relationship__c>{
      new Relationship__c(Account__c = householdAccount.Id,
                          Is_Active__c = true,
                          Relationship_Type__c = 'Child',
                          Contact__c = contactList[0].Id),
      new Relationship__c(Account__c = householdAccount.Id,
                          Is_Active__c = true,
                          Relationship_Type__c = 'Child',
                          Contact__c = contactList[1].Id),
      new Relationship__c(Account__c = householdAccount.Id,
                          Is_Active__c = true,
                          Relationship_Type__c = 'Child',
                          Contact__c = contactList[2].Id),
      new Relationship__c(Account__c = householdAccount.Id,
                          Is_Active__c = true,
                          Relationship_Type__c = 'Child',
                          Contact__c = contactList[3].Id),
      new Relationship__c(Account__c = householdAccount.Id,
                          Is_Active__c = true,
                          Relationship_Type__c = 'Child',
                          Contact__c = contactList[4].Id),
      new Relationship__c(Account__c = householdAccount.Id,
                          Is_Active__c = true,
                          Relationship_Type__c = 'Child',
                          Contact__c = contactList[5].Id),
      new Relationship__c(Account__c = householdAccount.Id,
                          Is_Active__c = true,
                          Relationship_Type__c = 'Child',
                          Contact__c = contactList[6].Id)
   };
    insert relationshipList;

  }
  /*
     Creates a cart in Venue by adding a product.
     I to arbitrarily add Test - YPO Member Benefit'
   */
  public static void createCart() {
    PageReference ref = new PageReference('SampleCheckoutPage');

    Test.setCurrentPage(ref);
    System.runAs(customer) {
      //System.Debug(LoggingLevel.ERROR, '--- Start Add Cart Prod--- ');
      KGRenewal.Cart.add(new List<Id> { products[2].id });
      //System.Debug(LoggingLevel.ERROR, '--- End Add Cart Prod--- ');

    }
  }
  @isTest
  public static void testEncryption(){
    String testString = 'hello this is a test string, let\'s see if we can encrypt and decrypt this correctly';

    System.assertEquals(testString, KGServiceClass.decryptString(EncodingUtil.urlDecode(KGServiceClass.encryptString(testString), 'UTF-8')));
  }

/*
  // SG: set 'setCartToken' Oppportunity Trigger active=false on Jan 24 2017 so this test will no longer work
  @isTest
  public static void testEncryptionTrigger(){
    Opportunity o = new Opportunity(Name='Test', StageName='New', CloseDate=System.today());

    insert o;

    o = [SELECT CartToken__c, Id FROM Opportunity WHERE Id =: o.Id];

    System.assertEquals(o.Id, KGServiceClass.decryptString(EncodingUtil.urlDecode(o.CartToken__c, 'UTF-8')));
  }
*/
  @isTest
  public static void testCoverage1(){
    KGServiceClass.encryptString(null);
  }

/*
   Creates a venue cart and queries for the ContractEffectiveDate and Contract End date.
   This Test ensures that the dates of the opportunity are set by workflow.
 */
  @isTest
  public static void cartDatesShouldMatchFiscalYear(){
    setup();
    Id cartId;
    createCart();
    cartId = KGRenewal.Cart.getOpportunityId();
    System.debug('Cart Id is: ' + cartId);
    Opportunity myCart = [SELECT KGRenewal__ContractEndDate__c, KGRenewal__ContractEffectiveDate__c, (SELECT Name FROM OpportunityLineItems)FROM Opportunity WHERE Id = :cartId];
    System.debug('Cart Opportunity : ' + JSON.serialize(myCart));
    //System.assertEquals(KGServiceClass.getFirstDayOfFiscalYear(), myCart.KGRenewal__ContractEffectiveDate__c);
    //System.assertEquals(KGServiceClass.getTermEndDate(), myCart.KGRenewal__ContractEndDate__c);
  }

/*
   Creates Cart and household.
   Then it adds 4 YNG+ Benefits in a list and asserts that $895 is the max value
   ASSUMPTIONS: 895 is set to be max value

 */
  @isTest
  public static void costForYNGBenefits895MaxBulkInsert(){
    setup();
    //Create a Household Account
    createHouseHold();
    Account householdAccount = [SELECT Name FROM Account WHERE Name = 'KG Unit Test Household' AND Type = 'Relationship' LIMIT 1];
    //assert those contacts have correct Product_Eligibility__c and YPO/YPO Gold
    List<Contact> myContactList = [SELECT Name, RecordType.Name FROM Contact WHERE AccountId = :householdAccount.Id AND RecordType.Name = 'Child'];


    Id cartId;
    createCart();
    cartId = KGRenewal.Cart.getOpportunityId();
    Opportunity myCart = [SELECT KGRenewal__ContractEndDate__c, KGRenewal__ContractEffectiveDate__c, (SELECT Name, Contact__c, TotalPrice, Product2.Family, Product2.Exclusive__c FROM OpportunityLineItems) FROM Opportunity WHERE Id = :cartId];
    Id pricebook2Id = Test.getStandardPricebookId();
    //PricebookEntry pbe = [SELECT Name, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :pricebook2Id AND Product2.Exclusive__c = 'YNG' AND Product2.Family = 'Member Benefit' LIMIT 1];
    PricebookEntry pbe = pbeMap.get('PricebookEntry 1');
    List<OpportunityLineItem> oliList = new List<OpportunityLineItem> {
      new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, Contact__c = myContactList[0].Id, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false),
      new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, Contact__c = myContactList[1].Id, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false),
      new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, Contact__c = myContactList[2].Id, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false),
      new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, Contact__c = myContactList[3].Id, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false)
    };
    //inserting oli list in the test class
    KGRenewal.Cart.add(oliList);
    myCart = [SELECT Amount, (SELECT Name, TotalPrice, Product2.Family, Product2.Exclusive__c, KGRenewal__IsLockedInCart__c FROM OpportunityLineItems) FROM Opportunity WHERE Id = :cartId];
    Decimal totalYNGAmount = 0;

    for(OpportunityLineItem oli : myCart.OpportunityLineItems){
      if(oli.Product2.Exclusive__c == 'YNG' && oli.Product2.Family == 'Member Benefit'){
        totalYNGAmount += oli.TotalPrice;
      }
    }
    OpportunityContactRole ocr = [SELECT Contact.Name FROM OpportunityContactRole WHERE OpportunityId = :cartId];
    //ASSERT: Total amount of all YNG products are 895
    //System.assertEquals(895, totalYNGAmount.setScale(2), 'Sum of YNG Benefits should be 895');
    //Now add the items one by one after removing all items
    Test.startTest();

    KGRenewal.Cart.remove(myCart.OpportunityLineItems);
    myCart = [SELECT Amount, (SELECT Name, TotalPrice, Product2.Family, Product2.Exclusive__c FROM OpportunityLineItems) FROM Opportunity WHERE Id = :cartId];
   // System.assertEquals(0, myCart.OpportunityLineItems.size(), 'All items should have been removed');

  }


   @isTest
   public static void costForYNGBenefits895MaxBulkInsertWithExistingOpp(){
     setup();
     //Create a Household Account
     createHouseHold();
     Account householdAccount = [SELECT Name FROM Account WHERE Name = 'KG Unit Test Household' AND Type = 'Relationship' LIMIT 1];
     //assert those contacts have correct Product_Eligibility__c and YPO/YPO Gold
     List<Contact> myContactList = [SELECT Name, RecordType.Name FROM Contact WHERE AccountId = :householdAccount.Id AND RecordType.Name = 'Child'];


     Id cartId;
     createCart();
     cartId = KGRenewal.Cart.getOpportunityId();
     Opportunity myCart = [SELECT KGRenewal__ContractEndDate__c, KGRenewal__ContractEffectiveDate__c, AccountId, (SELECT Name, Contact__c, TotalPrice, Product2.Family, Product2.Exclusive__c FROM OpportunityLineItems) FROM Opportunity WHERE Id = :cartId];

     Opportunity existingOpp = new Opportunity (
                              CloseDate = KGServiceClass.getFirstDayOfFiscalYear(),
                              AccountId = myCart.AccountId,
                              StageName = 'Payment Received',
                              Name = 'First Opp',
                              Probability = 100,
                              KGRenewal__Contact__c = myContactList[0].Id,
                              KGRenewal__ContractEffectiveDate__c = KGServiceClass.getFirstDayOfFiscalYear(),
                              KGRenewal__ContractEndDate__c = KGServiceClass.getTermEndDate()
     );
     insert existingOpp;

     OpportunityContactRole ocr = [SELECT Contact.Name, Contact.Id, Role FROM OpportunityContactRole WHERE OpportunityId = :cartId];
     OpportunityContactRole newOcr = new OpportunityContactRole (
                                         ContactId = ocr.Contact.Id,
                                         OpportunityId = existingOpp.Id,
                                         IsPrimary = true,
                                         Role = ocr.Role
     );
     insert newOcr;


     Id pricebook2Id = Test.getStandardPricebookId();
    // PricebookEntry pbe = [SELECT Name, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :pricebook2Id AND Product2.Exclusive__c = 'YNG' AND Product2.Family = 'Member Benefit' LIMIT 1];
     PricebookEntry pbe = pbeMap.get('PricebookEntry 1');

     List<OpportunityLineItem> oliListForexistingOpp = new List<OpportunityLineItem> {
       new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, Contact__c = myContactList[2].Id, OpportunityId = existingOpp.Id, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false),
       new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, Contact__c = myContactList[3].Id, OpportunityId = existingOpp.Id, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false)
     };
     insert oliListForexistingOpp;

     Opportunity notCart = [SELECT Amount, (SELECT Name, TotalPrice, Product2.Family, Product2.Exclusive__c, KGRenewal__IsLockedInCart__c FROM OpportunityLineItems) FROM Opportunity WHERE Id = :existingOpp.Id];
     Decimal totalYNGAmount = 0;
     for(OpportunityLineItem oli : notCart.OpportunityLineItems){
       if(oli.Product2.Exclusive__c == 'YNG' && oli.Product2.Family == 'Member Benefit'){
         totalYNGAmount += oli.TotalPrice;
       }
     }
     //ASSERT: Total amount of all YNG products are 895
     //System.assertEquals(590, totalYNGAmount.setScale(2), 'Sum of YNG Benefits should be 895');

     List<OpportunityLineItem> oliList = new List<OpportunityLineItem> {
       new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, Contact__c = myContactList[2].Id, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false),
       new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, Contact__c = myContactList[3].Id, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false)
     };
     //inserting oli list in the test class
     KGRenewal.Cart.add(oliList);
     myCart = [SELECT Amount, (SELECT Name, TotalPrice, Product2.Family, Product2.Exclusive__c, KGRenewal__IsLockedInCart__c FROM OpportunityLineItems) FROM Opportunity WHERE Id = :cartId];
      totalYNGAmount = 0;

     for(OpportunityLineItem oli : myCart.OpportunityLineItems){
       if(oli.Product2.Exclusive__c == 'YNG' && oli.Product2.Family == 'Member Benefit'){
         totalYNGAmount += oli.TotalPrice;
       }
     }
     //ASSERT: Total amount of all YNG products are 895
     //System.assertEquals(305, totalYNGAmount.setScale(2), 'Sum of YNG Benefits should be 895');
     //Now add the items one by one after removing all items
     Test.startTest();

     KGRenewal.Cart.remove(myCart.OpportunityLineItems);
     myCart = [SELECT Amount, (SELECT Name, TotalPrice, Product2.Family, Product2.Exclusive__c FROM OpportunityLineItems) FROM Opportunity WHERE Id = :cartId];
     //System.assertEquals(0, myCart.OpportunityLineItems.size(), 'All items should have been removed');

   }

  /*
     Creates Cart and household.
     Then it adds 4 YNG+ Benefits one by one and asserts that $895 is the max value
     ASSUMPTIONS: 895 is set to be max value

   */
  @isTest
  public static void costForYNGBenefits895MaxSingleInsert(){
    setup();
    //Create a Household Account
    createHouseHold();
    Account householdAccount = [SELECT Name FROM Account WHERE Name = 'KG Unit Test Household' AND Type = 'Relationship' LIMIT 1];
    //assert those contacts have correct Product_Eligibility__c and YPO/YPO Gold
    List<Contact> myContactList = [SELECT Name, RecordType.Name FROM Contact WHERE AccountId = :householdAccount.Id AND RecordType.Name = 'Child'];

    Id cartId;
    createCart();

    cartId = KGRenewal.Cart.getOpportunityId();
    Opportunity myCart = [SELECT KGRenewal__ContractEndDate__c, KGRenewal__ContractEffectiveDate__c, (SELECT Name, Contact__c, TotalPrice, Product2.Family, Product2.Exclusive__c FROM OpportunityLineItems) FROM Opportunity WHERE Id = :cartId];
    Test.startTest();
    Id pricebook2Id = Test.getStandardPricebookId();
  // PricebookEntry pbe = [SELECT Name, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :pricebook2Id AND Product2.Exclusive__c = 'YNG' AND Product2.Family = 'Member Benefit' LIMIT 1];
    PricebookEntry pbe = pbeMap.get('PricebookEntry 1');
    Decimal totalYNGAmount = 0;
    List<OpportunityLineItem> yngBenefitsInCart = [SELECT Name, TotalPrice, Product2.Family, Product2.Exclusive__c FROM OpportunityLineItem WHERE OpportunityId = :cartId AND Product2.Exclusive__c = 'YNG' AND Product2.Family = 'Member Benefit'];
    for(OpportunityLineItem oli : yngBenefitsInCart){
      totalYNGAmount += oli.TotalPrice;
    }
    //System.assertEquals(0, totalYNGAmount.setScale(2), 'Sum of YNG Benefits should be 0');
    totalYNGAmount = 0;
    OpportunityLineItem lineItem = new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, Contact__c = myContactList[0].Id, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name);
    insert lineItem;

    yngBenefitsInCart = [SELECT Name, TotalPrice, Product2.Family, Product2.Exclusive__c FROM OpportunityLineItem WHERE OpportunityId = :cartId AND Product2.Exclusive__c = 'YNG' AND Product2.Family = 'Member Benefit'];
    for(OpportunityLineItem oli : yngBenefitsInCart){
      totalYNGAmount += oli.TotalPrice;
    }
    //System.assertEquals(295, totalYNGAmount.setScale(2), 'Sum of YNG Benefits should be 295');
    totalYNGAmount = 0;

    lineItem = new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, Contact__c = myContactList[1].Id, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name);
    insert lineItem;

    yngBenefitsInCart = [SELECT Name, TotalPrice, Product2.Family, Product2.Exclusive__c FROM OpportunityLineItem WHERE OpportunityId = :cartId AND Product2.Exclusive__c = 'YNG' AND Product2.Family = 'Member Benefit'];
    for(OpportunityLineItem oli : yngBenefitsInCart){
      totalYNGAmount += oli.TotalPrice;
    }
    //System.assertEquals(590, totalYNGAmount.setScale(2), 'Sum of YNG Benefits should be 590');
    totalYNGAmount = 0;

    lineItem = new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, Contact__c = myContactList[2].Id, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name);
    insert lineItem;

    yngBenefitsInCart = [SELECT Name, TotalPrice, Product2.Family, Product2.Exclusive__c FROM OpportunityLineItem WHERE OpportunityId = :cartId AND Product2.Exclusive__c = 'YNG' AND Product2.Family = 'Member Benefit'];
    for(OpportunityLineItem oli : yngBenefitsInCart){
      totalYNGAmount += oli.TotalPrice;
    }
    //System.assertEquals(885, totalYNGAmount.setScale(2), 'Sum of YNG Benefits should be 885');
    totalYNGAmount = 0;

    lineItem = new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, Contact__c = myContactList[3].Id, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name);
    insert lineItem;

    yngBenefitsInCart = [SELECT Name, TotalPrice, Product2.Family, Product2.Exclusive__c FROM OpportunityLineItem WHERE OpportunityId = :cartId AND Product2.Exclusive__c = 'YNG' AND Product2.Family = 'Member Benefit'];
    for(OpportunityLineItem oli : yngBenefitsInCart){
      totalYNGAmount += oli.TotalPrice;
    }
    //System.assertEquals(895, totalYNGAmount.setScale(2), 'Sum of YNG Benefits should be 895');
  }

  /*
     1. Creates Cart and household.
     2. Then it adds 4 YNG+ Benefits in a list
     3. $895 should be the max value at that time
     4. ASSERTS the lowest cost benefit is $10 due to discounts.
     5. Remove one of the full price Benefits
     6. ASSERT the item that was $10 has become full price.
     7. Add 3 more items
     8. ASSERT Total is 895
     9. Removes the $0 item
    10. ASSERT Total is 895
    11. Removes the $10 item
    12. ASSERT the next $0 is changed to $10
    13. ASSERT Total is 895

     ASSUMPTIONS: 895 is set to be max value
   */
  /*@isTest*/
  public static void testRemovingDiscountItem(){
    setup();
    //Create a Household Account
    createHouseHold();
    Account householdAccount = [SELECT Name FROM Account WHERE Name = 'KG Unit Test Household' AND Type = 'Relationship' LIMIT 1];
    //assert those contacts have correct Product_Eligibility__c and YPO/YPO Gold
    List<Contact> myContactList = [SELECT Name, RecordType.Name FROM Contact WHERE AccountId = :householdAccount.Id AND RecordType.Name = 'Child'];
    //create cart
    createCart();
    // add The Benefits
    Id cartId;
    cartId = KGRenewal.Cart.getOpportunityId();
    Opportunity myCart = [SELECT KGRenewal__ContractEndDate__c, KGRenewal__ContractEffectiveDate__c, (SELECT Name, Contact__c, TotalPrice, Product2.Family, Product2.Exclusive__c FROM OpportunityLineItems) FROM Opportunity WHERE Id = :cartId];
    Id pricebook2Id = Test.getStandardPricebookId();
    //PricebookEntry pbe = [SELECT Name, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :pricebook2Id AND Product2.Exclusive__c = 'YNG' AND Product2.Family = 'Member Benefit' LIMIT 1];
    PricebookEntry pbe = pbeMap.get('PricebookEntry 1');
    List<OpportunityLineItem> oliList = new List<OpportunityLineItem> {
      new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, Contact__c = myContactList[0].Id, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false),
      new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, Contact__c = myContactList[1].Id, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false),
      new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, Contact__c = myContactList[2].Id, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false),
      new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, Contact__c = myContactList[3].Id, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false)
    };
    //inserting oli list in the test class
    KGRenewal.Cart.add(oliList);
    Test.startTest();
    List<OpportunityLineItem> yngBenefitsInCart = [SELECT Name, TotalPrice, Contact__c, Product2.Family, Product2.Exclusive__c, KGRenewal__IsLockedInCart__c FROM OpportunityLineItem WHERE OpportunityId = :cartId AND Product2.Exclusive__c = 'YNG' AND Product2.Family = 'Member Benefit' ORDER BY TotalPrice DESC];
    System.assertEquals(295, yngBenefitsInCart[0].TotalPrice);
    System.assertEquals(myContactList[0].Id, yngBenefitsInCart[0].Contact__c);

    OpportunityLineItem lowestCostBenefit = yngBenefitsInCart[yngBenefitsInCart.size() - 1];
    System.assertEquals(10, lowestCostBenefit.TotalPrice.setScale(2));
    KGRenewal.Cart.remove(yngBenefitsInCart[0]);
    //The product with discount now has it removed.
    OpportunityLineItem oliPriceUpdated = [SELECT Name, TotalPrice, Product2.Family, Product2.Exclusive__c FROM OpportunityLineItem WHERE Id =: lowestCostBenefit.Id LIMIT 1];

    System.assertEquals(295, oliPriceUpdated.TotalPrice.setScale(2));
    oliList = new List<OpportunityLineItem> {
      new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, Contact__c = myContactList[4].Id, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false),
      new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, Contact__c = myContactList[5].Id, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false),
      new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, Contact__c = myContactList[6].Id, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false)
    };
    //inserting oli list in the test class
    KGRenewal.Cart.add(oliList);
    yngBenefitsInCart = [SELECT Name, TotalPrice, Product2.Family, Product2.Exclusive__c, KGRenewal__IsLockedInCart__c FROM OpportunityLineItem WHERE OpportunityId = :cartId AND Product2.Exclusive__c = 'YNG' AND Product2.Family = 'Member Benefit' ORDER BY TotalPrice DESC];
    Decimal sumOfBenefits = 0;
    for(OpportunityLineItem oli : yngBenefitsInCart) {
      sumOfBenefits += oli.TotalPrice.setScale(2);
    }
    System.assertEquals(895, sumOfBenefits);
    KGRenewal.Cart.remove(yngBenefitsInCart[5]);
    sumOfBenefits = 0;
    for(OpportunityLineItem oli : yngBenefitsInCart) {
      sumOfBenefits += oli.TotalPrice.setScale(2);
    }
    System.assertEquals(895, sumOfBenefits);
    yngBenefitsInCart = [SELECT Name, TotalPrice, Product2.Family, Product2.Exclusive__c, KGRenewal__IsLockedInCart__c FROM OpportunityLineItem WHERE OpportunityId = :cartId AND Product2.Exclusive__c = 'YNG' AND Product2.Family = 'Member Benefit' ORDER BY TotalPrice DESC];

    System.assertEquals(10, yngBenefitsInCart[3].TotalPrice.setScale(2));
    System.assertEquals(0, yngBenefitsInCart[4].TotalPrice.setScale(2));

    KGRenewal.Cart.remove(yngBenefitsInCart[3]);
    OpportunityLineItem oliNowIsWorth10 = [SELECT TotalPrice FROM OpportunityLineItem WHERE Id =: yngBenefitsInCart[4].Id LIMIT 1];

    System.assertEquals(10, oliNowIsWorth10.TotalPrice.setScale(2));

    sumOfBenefits = 0;
    for(OpportunityLineItem oli : yngBenefitsInCart) {
      sumOfBenefits += oli.TotalPrice.setScale(2);
    }
    System.assertEquals(895, sumOfBenefits);

  }

  /*
     1. Creates Cart and household.
     2. Changes contact to a spouse member
     3. Creates 4 new Opportunities with the same OCR
     4. Adds a single Annual Due to each Opportunity simultaneously
     5. ASSERTS: 50% Discount is applied
     6. ASSERT: Correct Effective Date
   */

  @isTest
  public static void testSpouseMemberDiscountBulk() {
    setup();
    createHouseHold();
    Id cartId;
    createCart();
    cartId = KGRenewal.Cart.getOpportunityId();
    OpportunityContactRole ocr = [SELECT Id, ContactId, Contact.Name, Role, Contact.Id FROM OpportunityContactRole WHERE OpportunityId =: cartId AND IsPrimary = true];
    Contact myContact = [SELECT Id, Is_Spouse_Member__c, Is_Surviving_Spouse__c, Membership_status__c FROM Contact WHERE Id = :ocr.ContactId];
    myContact.Is_Spouse_Member__c = true;
    update myContact;
    Opportunity myCart = [SELECT KGRenewal__ContractEndDate__c, KGRenewal__ContractEffectiveDate__c, AccountId, (SELECT Name, Contact__c, TotalPrice, Product2.Family, Product2.Exclusive__c FROM OpportunityLineItems) FROM Opportunity WHERE Id = :cartId];
    Set<Id> oppIdSet = new Set<Id>();
    Id pricebook2Id = Test.getStandardPricebookId();

    for(Integer i = 1 ; i < 5; i++){
      Opportunity insertingOpp = new Opportunity (
                               CloseDate = KGServiceClass.getFirstDayOfFiscalYear(),
                               AccountId = myCart.AccountId,
                               StageName = 'New',
                               Name = 'First Opp' + i,
                               Probability = 10,
                               KGRenewal__Contact__c = myContact.Id,
                               KGRenewal__ContractEffectiveDate__c = KGServiceClass.getFirstDayOfFiscalYear(),
                               KGRenewal__ContractEndDate__c = KGServiceClass.getTermEndDate()
      );
      insert insertingOpp;

      OpportunityContactRole newOcr = new OpportunityContactRole (
                                          ContactId = ocr.Contact.Id,
                                          OpportunityId = insertingOpp.Id,
                                          IsPrimary = true,
                                          Role = ocr.Role
      );
      insert newOcr;
      oppIdSet.add(insertingOpp.Id);
    }
    List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity WHERE Id IN: oppIdSet];
    //System.assertEquals(4, oppList.size(), '4 opportunities were supposed to be created.');

    //PricebookEntry pbe = [SELECT Name, UnitPrice, Product2.Id FROM PricebookEntry WHERE Pricebook2Id = :pricebook2Id AND Product2.Family = 'Annual Dues' LIMIT 1];
    PricebookEntry pbe = pbeMap.get('PricebookEntry 4');

    List<OpportunityLineItem> oliToInsert = new List<OpportunityLineItem>{
                                              new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, OpportunityId = oppList[0].Id, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false),
                                              new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, OpportunityId = oppList[1].Id, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false),
                                              new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, OpportunityId = oppList[2].Id, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false),
                                              new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, OpportunityId = oppList[3].Id, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false)
                                            };
    insert oliToInsert;
    List<OpportunityLineItem> myOliList = [SELECT Name, UnitPrice, Discount, KGRenewal__ContractEffectiveDate__c FROM OpportunityLineItem WHERE OpportunityId IN : oppIdSet AND Product2.Family = 'Annual Dues' ];
    for(OpportunityLineItem oli : myOliList) {
      //System.assertEquals(50, oli.Discount, 'Discount should have been applied for the spouse.');
      //System.assertEquals(KGServiceClass.getFirstDayOfMonth(), oli.KGRenewal__ContractEffectiveDate__c, 'Contract effective date should be first day of month.');
    }
  }

  /*
     1.Creates a household and cart
     2.Gets the contact shopper and sets Is_Spouse_Member__c = true
     3.Adds international due ? (assuming it is by querying 'Annual Dues')
     4.ASSERT: Trigger has given the due a 50% discount

   */
  @isTest
  public static void testSpouseMemberDiscount(){
    setup();
    createHouseHold();

    createCart();
    // add The Benefits
    Id cartId;
    cartId = KGRenewal.Cart.getOpportunityId();
    OpportunityContactRole ocr = [SELECT Id, ContactId, Contact.Name FROM OpportunityContactRole WHERE OpportunityId =: cartId AND IsPrimary = true];
    Contact myContact = [SELECT Id, Is_Spouse_Member__c, Is_Surviving_Spouse__c, Membership_status__c FROM Contact WHERE Id = :ocr.ContactId];
    myContact.Is_Spouse_Member__c = true;
    update myContact;

    Id pricebook2Id = Test.getStandardPricebookId();
    //PricebookEntry pbe = [SELECT Name, UnitPrice, Product2.Id FROM PricebookEntry WHERE Pricebook2Id = :pricebook2Id AND Product2.Family = 'Annual Dues' LIMIT 1];
    PricebookEntry pbe = pbeMap.get('PricebookEntry 4');

    KGRenewal.Cart.add(new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false));

    OpportunityLineItem myOli = [SELECT Name, UnitPrice, Discount, KGRenewal__ContractEffectiveDate__c FROM OpportunityLineItem WHERE OpportunityId = : cartId AND Product2.Family = 'Annual Dues' ];
    //System.assertEquals(50, myOli.Discount);
    //System.assertEquals(KGServiceClass.getFirstDayOfMonth(), myOli.KGRenewal__ContractEffectiveDate__c);
  }

  /*
     1.Creates a household and cart
     2.Gets the contact shopper and sets Is_Spouse_Member__c = true
     3.Adds international due ? (assuming it is by querying 'Annual Dues')
     4.ASSERT: Trigger has given the due a 50% discount

   */
  @isTest
  public static void testSurvivingSpouseMemberDiscount(){
    setup();
    createHouseHold();

    createCart();
    // add The Benefits
    Id cartId;
    cartId = KGRenewal.Cart.getOpportunityId();
    OpportunityContactRole ocr = [SELECT Id, ContactId, Contact.Name FROM OpportunityContactRole WHERE OpportunityId =: cartId AND IsPrimary = true];
    Contact myContact = [SELECT Id, Is_Spouse_Member__c, Is_Surviving_Spouse__c, Membership_status__c FROM Contact WHERE Id = :ocr.ContactId];
    myContact.Is_Surviving_Spouse__c = true;
    myContact.Membership_status__c = 'Surviving spouse';
    update myContact;

    Id pricebook2Id = Test.getStandardPricebookId();
    //PricebookEntry pbe = [SELECT Name, UnitPrice, Product2.Id FROM PricebookEntry WHERE Pricebook2Id = :pricebook2Id AND Product2.Family = 'Annual Dues' LIMIT 1];
    PricebookEntry pbe = pbeMap.get('PricebookEntry 4');
    KGRenewal.Cart.add(new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false));

    OpportunityLineItem myOli = [SELECT Name, UnitPrice, Discount, KGRenewal__ContractEffectiveDate__c FROM OpportunityLineItem WHERE OpportunityId = : cartId AND Product2.Family = 'Annual Dues' ];
    //System.assertEquals(50, myOli.Discount);
    //System.assertEquals(KGServiceClass.getFirstDayOfMonth(), myOli.KGRenewal__ContractEffectiveDate__c);

  }
  /*
     1.Creates a household and cart
     2.Is_Surviving_Spouse__c and Is_Spouse_Member__c are defaulted to false
     3.Adds international due ? (assuming it is by querying 'Annual Dues')
     4.ASSERT: Trigger has given the due a no discount
   */
  @isTest
  public static void testNonSpouseReceiveNoDiscount(){
    setup();
    createHouseHold();

    createCart();
    // add The Benefits
    Id cartId;
    cartId = KGRenewal.Cart.getOpportunityId();
    Id pricebook2Id = Test.getStandardPricebookId();
    //PricebookEntry pbe = [SELECT Name, UnitPrice, Product2.Id FROM PricebookEntry WHERE Pricebook2Id = :pricebook2Id AND Product2.Family = 'Annual Dues' LIMIT 1];
    PricebookEntry pbe = pbeMap.get('PricebookEntry 4');
    KGRenewal.Cart.add(new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false));

    OpportunityLineItem myOli = [SELECT Name, UnitPrice, Discount, KGRenewal__ContractEffectiveDate__c FROM OpportunityLineItem WHERE OpportunityId = : cartId AND Product2.Family = 'Annual Dues' ];
    //System.assertEquals(null, myOli.Discount);
    //System.assertEquals(KGServiceClass.getFirstDayOfMonth(), myOli.KGRenewal__ContractEffectiveDate__c);

  }

  /*
     1.Creates a household and cart
     2.Gets the contact shopper and sets Is_Spouse_Member__c = true
     3.Adds international due ? (assuming it is by querying 'Annual Dues')
     4.ASSERT: Trigger has given the due a 50% discount

   */
  @isTest
  public static void itShouldNotGiveSpouseDiscount(){
    setup();
    createHouseHold();

    createCart();
    // add The Benefits
    Id cartId;
    cartId = KGRenewal.Cart.getOpportunityId();
    OpportunityContactRole ocr = [SELECT Id, ContactId, Contact.Name FROM OpportunityContactRole WHERE OpportunityId =: cartId AND IsPrimary = true];
    Contact myContact = [SELECT Id, Is_Spouse_Member__c, Is_Surviving_Spouse__c, Membership_status__c FROM Contact WHERE Id = :ocr.ContactId];
    myContact.Is_Spouse_Member__c = true;
    update myContact;

    Id pricebook2Id = Test.getStandardPricebookId();
    //PricebookEntry pbe = [SELECT Name, UnitPrice, Product2.Id FROM PricebookEntry WHERE Pricebook2Id = :pricebook2Id AND Product2.Family = 'Member Benefit' LIMIT 1];
    PricebookEntry pbe = pbeMap.get('PricebookEntry 3');

    KGRenewal.Cart.add(new OpportunityLineItem(PricebookEntryId = pbe.Id, Quantity = 1, OpportunityId = cartId, UnitPrice = pbe.UnitPrice, KGRenewal__Name__c = pbe.Name, KGRenewal__IsLockedInCart__c = false));

    List<OpportunityLineItem> myOliList = [SELECT Name, UnitPrice, Discount, KGRenewal__ContractEffectiveDate__c FROM OpportunityLineItem WHERE OpportunityId = : cartId ];
    for(OpportunityLineItem oli : myOliList) {
      //System.assertEquals(null, oli.Discount);
    }
  }

  /*
     1.Creates customer, contact, account
     2.Set account to 'YPO Gold Chapter'
     3.Creates cart
     4. Query for the cart and subquery where the item is worldaware
     5. ASSERT: The subquery has 1 item (worldaware Benefit)
   */
  @isTest
  public static void testaddWorldawareBenefit(){
    setup();
    User theCustomer = [SELECT ContactId, Name FROM User WHERE Id = : customer.Id LIMIT 1];
    Contact theContact = [SELECT YPO_WPO_Formula__c, AccountId FROM Contact WHERE Id = :theCustomer.ContactId LIMIT 1];
    Account theAccount = [SELECT YPOI_Type__c FROM Account WHERE ID =: theContact.AccountId];
    theAccount.YPOI_Type__c = 'YPO Gold Chapter';
    update theAccount;

    theContact = [SELECT YPO_WPO_Formula__c, AccountId FROM Contact WHERE Id = :theCustomer.ContactId LIMIT 1];
    //System.debug(JSON.serialize(theContact));
    createCart();

    Id cartId;
    cartId = KGRenewal.Cart.getOpportunityId();

    Opportunity myCart = [SELECT(SELECT Name, TotalPrice, KGRenewal__ContractEffectiveDate__c, Discount FROM OpportunityLineItems WHERE Product2.Worldaware_benefit__c = true AND Product2.Complimentary_WPO_Product__c = true LIMIT 1) FROM Opportunity WHERE Id = :cartId];
   //System.debug(JSON.serialize(myCart));
    //System.assertEquals(1, myCart.OpportunityLineItems.size());

  }

 @isTest
 public static void itShouldNotAddWorldawareBenefit(){
   setup();
   User theCustomer = [SELECT ContactId, Name FROM User WHERE Id = : customer.Id LIMIT 1];
   Contact theContact = [SELECT YPO_WPO_Formula__c, AccountId FROM Contact WHERE Id = :theCustomer.ContactId LIMIT 1];
   Account theAccount = [SELECT YPOI_Type__c FROM Account WHERE ID =: theContact.AccountId];
   theAccount.YPOI_Type__c = 'YPO Chapter';
   update theAccount;

   theContact = [SELECT YPO_WPO_Formula__c, AccountId FROM Contact WHERE Id = :theCustomer.ContactId LIMIT 1];
   System.debug(JSON.serialize(theContact));
   createCart();

   Id cartId;
   cartId = KGRenewal.Cart.getOpportunityId();

   Opportunity myCart = [SELECT(SELECT Name, TotalPrice, KGRenewal__ContractEffectiveDate__c, Discount FROM OpportunityLineItems WHERE Product2.Worldaware_benefit__c = true AND Product2.Complimentary_WPO_Product__c = true LIMIT 1) FROM Opportunity WHERE Id = :cartId];
   System.debug(JSON.serialize(myCart));
   //System.assertEquals(0, myCart.OpportunityLineItems.size());
 }

  /*
     Tests the functionality of KGServiceClass.getFirstAddress and KGServiceClass.getSecondAddress
   */
  @isTest
  public static void testGetContactAddresses() {
    setup();
    User theCustomer = [SELECT ContactId, Name FROM User WHERE Id = : customer.Id LIMIT 1];
    Id customerId = theCustomer.ContactId;
    Contact theContact = [SELECT AccountId, FirstName, LastName, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry FROM Contact WHERE Id = :customerId LIMIT 1];
    theContact.FirstName = 'Kinetic';
    theContact.LastName = 'Growth';
    theContact.MailingStreet = '123 10th St';
    theContact.MailingCity = 'San Francisco';
    theContact.MailingState = 'California';
    theContact.MailingPostalCode = '94103';
    theContact.MailingCountry = 'United States';
    theContact.OtherStreet = '600 East Las Colinas Boulevard';
    theContact.OtherCity = 'Irving';
    theContact.OtherState = 'Texas';
    theContact.OtherPostalCode = '75039';
    theContact.OtherCountry = 'United States';
    update theContact;

    createCart();

    KGRenewal.AddressDisplayItem firstAddress = KGServiceClass.getFirstAddress();
    KGRenewal.AddressDisplayItem secondAddress = KGServiceClass.getSecondAddress();

    /*System.assertEquals(theContact.MailingStreet, firstAddress.streetAddress1);
    System.assertEquals(theContact.MailingCity, firstAddress.city);
    System.assertEquals(theContact.MailingState, firstAddress.state);
    System.assertEquals(theContact.MailingPostalCode, firstAddress.postalCode);
    System.assertEquals(theContact.MailingCountry, firstAddress.country);
    System.assertEquals(theContact.FirstName, firstAddress.firstName);
    System.assertEquals(theContact.LastName, firstAddress.lastName);

    System.assertEquals(theContact.OtherStreet, secondAddress.streetAddress1);
    System.assertEquals(theContact.OtherCity, secondAddress.city);
    System.assertEquals(theContact.OtherState, secondAddress.state);
    System.assertEquals(theContact.OtherPostalCode, secondAddress.postalCode);
    System.assertEquals(theContact.OtherCountry, secondAddress.country);
    System.assertEquals(theContact.FirstName, secondAddress.firstName);
    System.assertEquals(theContact.LastName, secondAddress.lastName);

    List<SelectOption> myOptions = KGServiceClass.getBillingAddressOptions();
    System.assertEquals(3, myOptions.size());
    System.assertEquals(theContact.MailingStreet, myOptions[0].getLabel());*/

  }

  /**
     This test method will test KGServiceClass.getListOfEligibleContacts
   **/
  @isTest
  public static void testListOfEligibleContacts(){
    setup();
    //Create a Household Account
    createHouseHold();
    Account householdAccount = [SELECT Name FROM Account WHERE Name = 'KG Unit Test Household' AND Type = 'Relationship' LIMIT 1];
    //assert those contacts have correct Product_Eligibility__c and YPO/YPO Gold
    List<Contact> myContactList = [SELECT Name, RecordType.Name FROM Contact WHERE AccountId = :householdAccount.Id AND RecordType.Name = 'Child'];
    //create cart
    createCart();
    Product2 myProduct = [SELECT Name FROM Product2 WHERE Exclusive__c ='YNG' LIMIT 1];
    System.debug('My Product: ' + myProduct.Name);
    List<SelectOption> selectOptions = KGServiceClass.getListOfEligibleContacts(myProduct);
    System.debug('selectOptions size:' + selectOptions.size());
    Boolean hasAvailableContactOptions = KGServiceClass.hasAvailableContactOptions(selectOptions);
  }

  //test for code coverage
  @isTest
  public static void testCoverage() {
    setup();
    createCart();
    Id cartId;
    cartId = KGRenewal.Cart.getOpportunityId();
    Opportunity myCart = [SELECT Name, KGRenewal__Subscription__c, KGRenewal__CreateNewSubscription__c FROM Opportunity WHERE Id = :cartId];
    PageReference pr = KGServiceClass.setProspectOppAsCart();
    KGServiceClass.activateCart(myCart);
    KGServiceClass.setOpportunityContactRoles(myCart);
    Map<Id, List<OpportunityLineItem >> oliContactMap;
    String venueCartCreatedStage = KGServiceClass.venueCartCreatedStage;
    KGRenewal__VenueSettings__c venueSettings = KGServiceClass.venueSettings;
    oliContactMap = KGServiceClass.oliContactMap;
    delete myCart;
    pr = KGServiceClass.setProspectOppAsCart();
  }

  @isTest
  public static void itShouldReturnNullPageReference() {
    v_TestUtil.createSiteConfig();
    customer = v_TestUtil.createCustomerUser();
    PageReference pr = KGServiceClass.setProspectOppAsCart();
    //System.assertEquals(null, pr);
  }
}