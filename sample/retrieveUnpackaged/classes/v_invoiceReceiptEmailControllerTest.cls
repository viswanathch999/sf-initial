@isTest
public with sharing class v_invoiceReceiptEmailControllerTest {
  @isTest
  public static void testReceiptCtrl() {
    v_invoiceReceiptEmailController ctrl = new v_invoiceReceiptEmailController();

    Account a = new Account(Name='test');
    insert a;


    KGRenewal__Invoice__c i = new KGRenewal__Invoice__c(
      KGRenewal__Account__c = a.Id
    );
    insert i;


    ctrl.InvoiceId = i.Id;
    
    v_invoiceReceiptEmailController.LineItemWrapper w = new v_invoiceReceiptEmailController.LineItemWrapper();
    System.debug(w.name);
    System.debug(w.productCode );
    System.debug(w.salesPrice );
    System.debug(w.term );
    System.debug(w.unitPrice);
    System.debug(w.quantity );
    System.debug(w.totalPrice );

  }
}