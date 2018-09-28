@isTest
public with sharing class v_loadCartCtrlTest {
/*****************************************************************************/
  public static void setup(){

    KGRenewal__VenueSettings__c settings = KGRenewal__VenueSettings__c.getOrgDefaults();
    settings.KGRenewal__OpportunityStageOnInsertion__c = 'TEST STAGE';
    upsert settings;


    //test Account
    Account testAccount = new Account(
        Name = 'testAccount',
        CurrencyIsoCode = 'USD',
        BillingPostalCode = '91320',
        Industry = 'Banking'
        );
    insert testAccount;

    //test contact
    Contact testContact = new Contact(
        LastName = 'contact',
        AccountId = testAccount.Id,
        Email = 'test@email.com'
        );
    insert testContact;

    //test opportunity
    Opportunity testOpty = new Opportunity(
        Name = 'testOpty',
        AccountId = testAccount.Id,
        StageName = 'Prospect',
        Type = 'Renewal',
        CloseDate = System.today(),
        ForecastCategoryName = 'Pipeline',
        LeadSource = 'Adwords',
        KGRenewal__Contact__c = testContact.Id
        );

    insert testOpty;
    String testOptyCartToken = KGServiceClass.encryptString( testOpty.Id );
    update new Opportunity(Id = testOpty.Id, CartToken__c = testOptyCartToken);
    
    //test product 
    Product2 testProduct = new Product2(
        IsActive = true,
        ProductCode = 'TEST',
        CurrencyIsoCode = 'USD',
        Name = 'TEST NAME',
        KGRenewal__IsTaxable__c = true
        );

    insert testProduct;

    PricebookEntry testEntry = new PricebookEntry(
        Pricebook2Id = Test.getStandardPricebookId(),
        Product2Id = testProduct.Id,
        UnitPrice = 100,
        IsActive = true
        );
    insert testEntry;

    OpportunityLineItem testOli = new OpportunityLineItem(
        OpportunityId = testOpty.Id,
        Quantity = 1,
        PricebookEntryId = testEntry.Id,
        TotalPrice = 1 * testEntry.UnitPrice
        );
    insert testOli;
  }
/*****************************************************************************/
  //This unit test covers error handling around paramters.
  //First pass tests without parameter
  //Second pass tests with bad token
  @isTest
  public static void testParameterErrorHandling(){
    PageReference pageRef = Page.v_loadCart;
    Test.setCurrentPage(pageRef);
    V_loadCartCtrl ctrl = new V_loadCartCtrl();

    System.assertEquals(ctrl.errorList.size(), 1);

    ApexPages.currentPage().getParameters().put('ct', 'sksdfnsdfkjdsnfksjdnfkdsjnskjnskdjns');
    ctrl = new V_loadCartCtrl();

    System.assertEquals(ctrl.errorList.size(), 1);

    //get a little more coverage
    ctrl.loadCart();
  }
/*****************************************************************************/
  //This test loads up a cart with no OCRs from an account with a bunch of old carts
  //The test asserts no errors, OCR creation, and proper cart activation/deactivation
  @isTest
  public static void testPageSuccess(){
    setup();
    
    
    Opportunity opty = [SELECT CartToken__c, KGRenewal__Contact__c, KGRenewal__IsActiveCart__c, AccountId FROM Opportunity];

    List<Opportunity> otherCartsOnAccount = new List<Opportunity>();

    for (Integer i = 0; i < 10; i++){
      otherCartsOnAccount.add(new Opportunity(
          Name = 'test ' + i,
          StageName = 'anything',
          CloseDate = System.today().addMonths(-i),
          AccountId = opty.AccountId,
          KGRenewal__IsActiveCart__c = (Math.mod(i,2) == 0),
          KGRenewal__Contact__c = opty.KGRenewal__Contact__c
        )
      );
    }

    insert otherCartsOnAccount;

    List<OpportunityContactRole> ocrList = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId = : opty.Id];
    otherCartsOnAccount = [SELECT Id FROM Opportunity WHERE AccountId =: opty.AccountId AND KGRenewal__IsActiveCart__c = true AND Id != : opty.Id];

    String token = opty.CartToken__c;
    PageReference pageRef = Page.v_loadCart;

    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('ct', EncodingUtil.urlDecode(token, 'UTF-8'));
    V_loadCartCtrl ctrl = new V_loadCartCtrl();

    System.assertEquals(ctrl.errorList.size(), 0);
    System.assertEquals(ocrList.size(), 0);
    System.assertEquals(otherCartsOnAccount.size(), 5);
    System.assertEquals(opty.KGRenewal__IsActiveCart__c, false);

    PageReference p = ctrl.loadCart();

    ocrList = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId = : opty.Id];
    opty = [SELECT CartToken__c, KGRenewal__IsActiveCart__c, AccountId FROM Opportunity WHERE Id = : opty.Id];
    otherCartsOnAccount = [SELECT Id FROM Opportunity WHERE AccountId =: opty.AccountId AND KGRenewal__IsActiveCart__c = true AND Id != : opty.Id];

    System.assertEquals(ctrl.errorList.size(), 0);
    System.assertEquals(p.getUrl(), '/apex/v_catalog');
    System.assertEquals(p.getRedirect(), true);
    System.assertEquals(ocrList.size(), 1);
    System.assertEquals(opty.KGRenewal__IsActiveCart__c, true);
    System.assertEquals(otherCartsOnAccount.size(), 0);
  }
/*****************************************************************************/
  //This test loads up a cart with a bunch of primary OCRs
  //The test asserts no errors, OCR creation, and proper cart activation/deactivation
  @isTest
  public static void testPageSuccessWithOCRS(){
     setup();
    
    Opportunity opty = [SELECT CartToken__c, KGRenewal__IsActiveCart__c, AccountId FROM Opportunity];

    List<OpportunityContactRole> ocrs = new List<OpportunityContactRole>();


    List<Contact> contacts = new List<Contact>();
    for (Integer i = 0; i < 10; i++){
      contacts.add(new Contact(LastName='test'+i));
    }
    insert contacts;

    for (Integer i = 0; i < 10; i++){
      ocrs.add(new OpportunityContactRole(OpportunityId = opty.Id, 
                                          ContactId = contacts[i].Id, 
                                          Role = (Math.mod(i,3)==0) ? KGServiceClass.venueSettings.KGRenewal__BuyerRole__c : 'something random', 
                                          IsPrimary = (Math.mod(i,2)==0) ? true : false
                                          )
      );
    }
    insert ocrs;

    List<OpportunityContactRole> ocrList = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId = : opty.Id];
    //otherCartsOnAccount = [SELECT Id FROM Opportunity WHERE AccountId =: opty.AccountId AND KGRenewal__IsActiveCart__c = true AND Id != : opty.Id];

    String token = opty.CartToken__c;
    PageReference pageRef = Page.v_loadCart;

    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('ct', EncodingUtil.urlDecode(token, 'UTF-8'));
    V_loadCartCtrl ctrl = new V_loadCartCtrl();

    System.assertEquals(ctrl.errorList.size(), 0);
    System.assertEquals(ocrList.size(), 10);
    //System.assertEquals(otherCartsOnAccount.size(), 5);
    System.assertEquals(opty.KGRenewal__IsActiveCart__c, false);

    PageReference p = ctrl.loadCart();

    ocrList = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId = : opty.Id AND IsPrimary = true];
    opty = [SELECT CartToken__c, KGRenewal__IsActiveCart__c, AccountId FROM Opportunity WHERE Id = : opty.Id];
    //otherCartsOnAccount = [SELECT Id FROM Opportunity WHERE AccountId =: opty.AccountId AND KGRenewal__IsActiveCart__c = true AND Id != : opty.Id];

    System.assertEquals(ctrl.errorList.size(), 0);
    System.assertEquals(p.getUrl(), '/apex/v_catalog');
    System.assertEquals(p.getRedirect(), true);
    System.assertEquals(ocrList.size(), 1);
    System.assertEquals(opty.KGRenewal__IsActiveCart__c, true);
    //System.assertEquals(otherCartsOnAccount.size(), 0);
  }
/*****************************************************************************/
}