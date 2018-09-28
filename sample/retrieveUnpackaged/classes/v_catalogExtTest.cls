@isTest(SeeAllData=true)
public with sharing class v_catalogExtTest {
  @isTest

    public static void testExt() {
        KGRenewal.VenueCatalogController v = new KGRenewal.VenueCatalogController();
    v_catalogExt e = new v_catalogExt(v);
    Test.setCurrentPageReference(new PageReference('Page.v_catalog')); 
    System.currentPageReference().getParameters().put('search', 'test-test');
    e.doSearch2();
    e.doSearch3();
    }
    
    
    @isTest
    public static void testLinkingProductsWithContact() {
        
        Product2 theProduct = new Product2(Name='YNG+ Product', Exclusive__c='YNG');
        
        //Contact theContact = TestServices.
    }
}