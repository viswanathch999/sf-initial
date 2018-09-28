/**
* Author: Vasu
* Description: 
* Created Date: 
* Modified Date
**/

@isTest(seeAllData = true)
public class CatalogItemDetailed_Extension_Test {

    static User customer;
    static Contact testContact;
	static User testUser;
	static User standardUser;
	static Opportunity testOpp;

    static final String CONST_CONTACT = 'Contact';
    static final String CONST_SPOUSE = 'Spouse_Partner';
    static final String CONST_CHILD = 'Child';
	static final String CONST_MEMBER = 'Member';

    public static Id childRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_CHILD, CONST_CONTACT).Id;
    public static Id spouseRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_SPOUSE, CONST_CONTACT).Id;
    public static Id memberRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_MEMBER, CONST_CONTACT).Id;

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
    
    @isTest
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
        CatalogItemDetailed_Extension ext = new CatalogItemDetailed_Extension(venueCtrl);
        ext.con.LastName = 'Contact Last Name';
        Id rid = ext.childRecordTypeId;
		id mid = ext.memberRecordTypeId;
        // Cover properties and get methods
        List<String> imageList = ext.imageList;
        Boolean hasAvailableContactOptions = ext.hasAvailableContactOptions;
        List<SelectOption> contactOptions = ext.getContactOptions();
        
        // Cover action methods
        ext.setProspectOppAsCart();
        ext.activateRenewal();
        //ext.addToCartSave();
		ext.selectedContactId = ext.oContact.id;
        ext.getselContact();
        ext.updateContactRecord();
        
        Contact c = new Contact(FirstName ='Con FName',LastName = 'Con LName',Email = 'test-user@fakeemail.com',accountId=ext.con.accountId);
        ext.con = c;
		ext.Birthdate_Year = '1992';
		ext.Birthdate_Month = '10';
		ext.Birthdate_Day = '5';
        ext.updateContactRecord();
        
        System.debug('Check for Duplicate Email: ' + CatalogItemDetailed_Extension.isDuplicataEMail('test-user@fakeemail.com',''));
    }
    
    @isTest
    public static void testProperties() {
        setup();

        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'v_detailControllerExtTest Product' LIMIT 1];
        ApexPages.currentPage().getParameters().put('id', prod.Id);
        
        System.runAs(customer) {
            KGRenewal.Cart.add(new List<Id> { prod.id });
        }
        
    	KGRenewal.VenueDetailController venueCtrl = new KGRenewal.VenueDetailController();
        CatalogItemDetailed_Extension ext = new CatalogItemDetailed_Extension(venueCtrl);
        
        Test.setCurrentPageReference(Page.CatalogItemDetailed_YPO);
        System.currentPageReference().getParameters().put('lifetime','true');
        
    	Id spouseRTId;
    	Boolean cameFromLT;
    	Boolean isDupEmail;
    	String testStr;
    	
    	Test.startTest();
    		ext.selectedContactId = ext.oContact.id;
    		spouseRTId = ext.spouseRecordTypeId;
    		cameFromLT = ext.cameFromLifetimePage;
    		ext.getselContact();
    	Test.stopTest();
    }
    
    @isTest public static void testPhones() {
    	setup();
    	
		testOpp = (Opportunity) SObjectFactory.build(Opportunity.SObjectType);
		//testOpp.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member','Opportunity').Id;
		testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Member').getRecordTypeId();
		testOpp.Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
		testOpp.NumberOfEmployees__c = 100;
		testOpp.Enterprise_Value__c = 100;
		testOpp.AnnualRevenue__c = 100;
		testOpp.NumberOfEmployees__c = 100;
		testOpp.Organization_Type__c = 'Agency-Type';
		testOpp.StageName = 'Cycle Open';
		testOpp.KGRenewal__IsActiveCart__c = true;
		insert testOpp;
		
		OpportunityContactRole oppConRole = new OpportunityContactRole(Contactid=customer.ContactId,OpportunityId=testOpp.id,IsPrimary=TRUE);
        insert oppConRole;
        // Setup page params
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'v_detailControllerExtTest Product' LIMIT 1];
        ApexPages.currentPage().getParameters().put('id', prod.Id);
        
        System.runAs(customer) {
            KGRenewal.Cart.add(new List<Id> { prod.id });
        }
        
        Contact con;
        Contact conAlt;
        Test.startTest();
        
	        KGRenewal.VenueDetailController venueCtrl = new KGRenewal.VenueDetailController();
	        CatalogItemDetailed_Extension ext = new CatalogItemDetailed_Extension(venueCtrl);
	        
			ext.selectedContactId = customer.ContactId;
			ext.getselContact();
	        ext.con.Preferred_Phone__c = 'Business Phone';
	        conAlt = (Contact) JSON.deserialize(CatalogItemDetailed_Extension.updateCatalogItemContact(String.valueOf(customer.ContactId)), Contact.class);
			system.assert(ext.con.Phone == null, 'Business Phone is not loaded');
	        
	        ext.con.Preferred_Phone__c = 'Mobile Phone';
			ext.con.MobilePhone = '1234567890';
			ext.con.Mobile_Phone_Country_Code__c = '1';
	        conAlt = (Contact) JSON.deserialize(CatalogItemDetailed_Extension.updateCatalogItemContact(String.valueOf(customer.ContactId)), Contact.class);
			system.assert(ext.con.MobilePhone <> null, 'Mobile Phone is not loaded');

	        ext.con.Preferred_Phone__c = 'Home Phone';
	        conAlt = (Contact) JSON.deserialize(CatalogItemDetailed_Extension.updateCatalogItemContact(String.valueOf(customer.ContactId)), Contact.class);
			system.assert(ext.con.HomePhone == null, 'Home Phone is not loaded');

	        ext.con.Preferred_Phone__c = 'Other Phone';
	        conAlt = (Contact) JSON.deserialize(CatalogItemDetailed_Extension.updateCatalogItemContact(String.valueOf(customer.ContactId)), Contact.class);
			system.assert(ext.con.OtherPhone == null, 'Other Phone is not loaded');

        Test.stopTest();
    }

	@isTest public static void testBirthDateFunction() {
		//isFiscalAge
		System.assert(CatalogItemDetailed_Extension.isFiscalAge(String.valueOf(Datetime.newInstance(2000,6,30))),'Did not meet Fiscal age - test1');
		System.assert(CatalogItemDetailed_Extension.isFiscalAge(String.valueOf(Datetime.newInstance(1998,1,1))),'Is within Fiscal age limit - test2');
		System.assert(!CatalogItemDetailed_Extension.isFiscalAge(String.valueOf(Datetime.newInstance(2018,6,31))),'This should be an Invalid Date - test3');
		System.assert(CatalogItemDetailed_Extension.isFiscalAge(String.valueOf(Datetime.newInstance(1987,7,1))),'Should have met current age - test4');
		System.assert(!CatalogItemDetailed_Extension.isFiscalAge(null),'This should be an Invalid Date - test5');
		//Birthday check
		System.assert(CatalogItemDetailed_Extension.DOBCheck(date.newInstance(2018,10,3),Date.newInstance(1992,10,5)),'This should be an valid DOBcheck - test6');
	}
}