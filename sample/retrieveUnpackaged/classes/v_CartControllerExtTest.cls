@isTest
public with sharing class v_CartControllerExtTest {
  @isTest(SeeAllData=true)
  	public static void testCartExt() {
    KGRenewal.VenueCartController ctrl = new KGRenewal.VenueCartController();
        v_CartControllerExt ext = new v_CartControllerExt(ctrl);

    System.debug(ext.hasTerm);
    //System.debug(ext.isLoggingOn);
    System.debug(ext.zipCode);
    System.debug(ext.zipCodeError);

    System.debug(ext.totalItemCount);

    Test.setCurrentPageReference(new PageReference('Page.v_catalog')); 
    System.currentPageReference().getParameters().put('search', 'test-test');
	System.currentPageReference().getParameters().put('lifetime', 'true');
    Boolean lifetime = ext.cameFromLifetimePage;
    Boolean prosp = ext.prospectRType;
    ext.updateQuantity();

    }
}