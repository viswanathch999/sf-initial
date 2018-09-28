@isTest ( seeAllData = false )
class v_InvoicePdfControllerTest 
{
  @isTest
  static void testInvoicePdfController() 
  {
      v_InvoicePdfController ctrl = new v_InvoicePdfController();
      ctrl.invoiceRecord = null;
      System.assertNotEquals( ctrl.invoiceRecord, null, 'invoiceRecord should not be null');

      User customer = v_TestUtil.createCustomerUser();
      Contact con = [SELECT AccountId FROM Contact WHERE Id = :customer.ContactId];
      KGRenewal__Invoice__c invoice = new KGRenewal__Invoice__c( KGRenewal__Account__c = con.AccountId);
      insert invoice;
      ctrl.invoiceRecord = invoice;
      System.assertEquals( ctrl.invoiceRecord.id, invoice.id, 'invoiceRecord should be set');
  }
}