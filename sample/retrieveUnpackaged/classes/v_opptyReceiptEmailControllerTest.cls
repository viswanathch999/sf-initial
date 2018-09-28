@isTest
public with sharing class v_opptyReceiptEmailControllerTest {
  @isTest
  public static void testReceiptCtrl() {
    v_opptyReceiptEmailController ctrl1 = new v_opptyReceiptEmailController();

    Account a = new Account(Name='test');
    insert a;

    Opportunity i = new Opportunity(
      Name = 'aasds',
      StageName = 'test',
      CloseDate = System.today()
    );
    insert i;

    ctrl1.opptyId = i.Id;
    

    v_opptyReceiptEmailController.LineItemWrapper w = new v_opptyReceiptEmailController.LineItemWrapper();
    System.debug(w.name);
    System.debug(w.productCode );
    System.debug(w.salesPrice );
    System.debug(w.term );
    System.debug(w.unitPrice);
    System.debug(w.quantity );
    System.debug(w.totalPrice );
  }
}