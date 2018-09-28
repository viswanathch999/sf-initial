@isTest(SeeAllData=true)
public with sharing class v_checkoutExtTest {
  @isTest
  public static void testCheckoutExt() {
    KGRenewal.VenueCheckoutController ctrl = new KGRenewal.VenueCheckoutController();
    v_checkoutExt ext = new v_checkoutExt( ctrl);
    ext.toggleGateway();
    List<SelectOption> paymentOptions = ext.paymentOptions;
    System.debug(ext.paymentMode);
    //System.debug(ext.gatewayValue);
    ext.newPay();

  }
}