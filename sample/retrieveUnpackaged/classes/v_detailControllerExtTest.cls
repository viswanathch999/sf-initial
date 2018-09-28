@isTest(seeAllData=true)
private class v_detailControllerExtTest {

  static User customer;

  static void setup() {

    // Create a site configuration for Venue
    v_TestUtil.createSiteConfig();

    // Create an ecommerce product with a price
    Product2 prod = new Product2(Name = 'v_detailControllerExtTest Product',
                                 IsActive = true,
                                 KGRenewal__ECommerceEnabled__c = true,
                                 KGRenewal__AvailableForPurchase__c = true,
                                 KGRenewal__MainImageSmall__c = '/image.png',
                                 KGRenewal__SecondImageSmall__c = '/image.png',
                                 KGRenewal__ThirdImageSmall__c = '/image.png',
                                 KGRenewal__FourthImageSmall__c = '/image.png',
                                 KGRenewal__MainImageMed__c = '/image.png',
                                 KGRenewal__SecondImageMed__c = '/image.png',
                                 KGRenewal__ThirdImageMed__c = '/image.png',
                                 KGRenewal__FourthImageMed__c = '/image.png',
                                 KGRenewal__MainImageLarge__c = '/image.png',
                                 KGRenewal__SecondImageLarge__c = '/image.png',
                                 KGRenewal__ThirdImageLarge__c = '/image.png',
                                 KGRenewal__FourthImageLarge__c = '/image.png');
    insert prod;

    PricebookEntry price = new PricebookEntry(Product2Id = prod.Id,
                                              Pricebook2Id = Test.getStandardPricebookId(),
                                              IsActive = true,
                                              UnitPrice = 10);
    insert price;

    // Create our customer user
    customer = v_TestUtil.createCustomerUser();
  }

  //@isTest
  static void itShouldGiveUsCodeCoverage() {

    setup();

    // Setup page params
    Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'v_detailControllerExtTest Product' LIMIT 1];
    ApexPages.currentPage().getParameters().put('id', prod.Id);

    System.runAs(customer) {
      KGRenewal.Cart.add(new List<Id> { prod.id });
    }

    Test.startTest();

    // Construct a new instance
    KGRenewal.VenueDetailController venueCtrl = new KGRenewal.VenueDetailController();
    v_detailControllerExt ext = new v_detailControllerExt(venueCtrl);

    // Cover properties and get methods
    List<String> imageList = ext.imageList;
    Boolean hasAvailableContactOptions = ext.hasAvailableContactOptions;
    List<SelectOption> contactOptions = ext.getContactOptions();

    // Cover action methods
    ext.setProspectOppAsCart();
    ext.activateRenewal();
  }

  @isTest
  static void itShouldSetupImageList() {
    setup();

    // Setup page params
    Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'v_detailControllerExtTest Product' LIMIT 1];
    ApexPages.currentPage().getParameters().put('id', prod.Id);

    System.runAs(customer) {
      KGRenewal.Cart.add(new List<Id> { prod.id });
    }

    Test.startTest();

    // Construct a new instance
    KGRenewal.VenueDetailController venueCtrl = new KGRenewal.VenueDetailController();
    v_detailControllerExt ext = new v_detailControllerExt(venueCtrl);

    List<String> imageList = ext.imageList;
    System.assertNotEquals(null, imageList);
    System.assertEquals('/image.png', imageList[0]);
    System.assertEquals('/image.png', imageList[10]);

  }

  @isTest
  static void itShouldGetNoContactOptions() {
    setup();

    // Setup page params
    Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'v_detailControllerExtTest Product' LIMIT 1];
    ApexPages.currentPage().getParameters().put('id', prod.Id);

    System.runAs(customer) {
      KGRenewal.Cart.add(new List<Id> { prod.id });
    }

    Test.startTest();

    // Construct a new instance
    KGRenewal.VenueDetailController venueCtrl = new KGRenewal.VenueDetailController();
    v_detailControllerExt ext = new v_detailControllerExt(venueCtrl);

    Boolean hasAvailableContactOptions = ext.hasAvailableContactOptions;
    List<SelectOption> contactOptions = ext.getContactOptions();

    System.assertEquals(true, hasAvailableContactOptions);
    System.assertEquals(0, contactOptions.size());
  }

  @isTest
  static void itShouldReturnNullPageReference() {

    setup();

    // Setup page params
    Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'v_detailControllerExtTest Product' LIMIT 1];
    ApexPages.currentPage().getParameters().put('id', prod.Id);

    Test.startTest();

    // Construct a new instance
    KGRenewal.VenueDetailController venueCtrl = new KGRenewal.VenueDetailController();
    v_detailControllerExt ext = new v_detailControllerExt(venueCtrl);

    PageReference pr = ext.setProspectOppAsCart();
    System.assertEquals(Page.NullCheckPage.getUrl(), pr.getUrl());

  }

  @isTest
  static void itShouldSetProspectOppAsCart() {

    setup();

    // Setup page params
    Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'v_detailControllerExtTest Product' LIMIT 1];
    ApexPages.currentPage().getParameters().put('id', prod.Id);


    System.runAs(customer) {
      KGRenewal.Cart.add(new List<Id> { prod.id });
    }

    String ocrRole = KGRenewal__VenueSettings__c.getOrgDefaults().KGRenewal__BuyerRole__c;
    Contact c = [SELECT MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry FROM Contact WHERE FirstName = 'Customer Portal Manager'];

    Opportunity opp = [SELECT KGRenewal__isActiveCart__c, AccountId FROM Opportunity WHERE Id = :KGRenewal.Cart.getOpportunityId()];
    opp.KGRenewal__isActiveCart__c = false;
    update opp;

    Opportunity opty = new Opportunity (
                        Name = 'Test Opp',
                        CloseDate = System.Today(),
                        AccountId = opp.AccountId,
                        StageName = 'Prospecting',
                        KGRenewal__IsActiveCart__c = true
    );
    insert opty;

    OpportunityContactRole ocr = new OpportunityContactRole (
                                      OpportunityId = opty.Id,
                                      Role = ocrRole,
                                      IsPrimary = true,
                                      ContactId = c.Id
    );
    insert ocr;
    Test.startTest();
    KGRenewal.Cart.cartOpportunityId = null;
    // Construct a new instance
    KGRenewal.VenueDetailController venueCtrl = new KGRenewal.VenueDetailController();
    v_detailControllerExt ext = new v_detailControllerExt(venueCtrl);

    PageReference pr = ext.setProspectOppAsCart();
    System.assertEquals('/apex/catalog_ypo', pr.getUrl(), pr.getUrl() + ' was not set correctly.');

  }

}