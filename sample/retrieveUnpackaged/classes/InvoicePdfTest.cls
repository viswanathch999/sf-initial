@isTest
public with sharing class InvoicePdfTest {
	
  @isTest
  public static void testCtrl(){
    Account a = new Account(Name='test');
    insert a;


    KGRenewal__Invoice__c i = new KGRenewal__Invoice__c(
      KGRenewal__Account__c = a.Id
    );
    
    InvoicePdfCtrl ctrl = new InvoicePdfCtrl();
    InvoicePdfExt ext = new InvoicePdfExt(ctrl);
    ctrl.invoiceRecord = i;
    insert i;
    ctrl.invoiceRecord = i;
    System.debug(JSON.serialize(ext.oneTimeSaleLineItems));
    System.debug(JSON.serialize(ext.subscriptionLineItems));
    System.debug(JSON.serialize(ctrl.oneTimeSaleLineItems));
    System.debug(JSON.serialize(ctrl.subscriptionLineItems));
    System.debug(JSON.serialize(ctrl.currentDate));
    System.debug(JSON.serialize(ctrl.accountRecord));
    System.debug(JSON.serialize(ctrl.pageTitle));

    KGRenewal__Subscription__c s = new KGRenewal__Subscription__c(
      KGRenewal__Account__c = a.Id,
      KGRenewal__StartDate__c = System.today()
    );
    insert s;

    KGRenewal__SubscriptionProduct__c sp = new KGRenewal__SubscriptionProduct__c(
        KGRenewal__Subscription__c = s.Id,
        KGRenewal__Quantity__c = 1,
        KGRenewal__TotalPrice__c = 42,
        KGRenewal__UnitPrice__c  =42
    );
    insert sp;

    KGRenewal__InvoiceItem__c ii = new KGRenewal__InvoiceItem__c(
      KGRenewal__Invoice__c = i.Id
    );

    
    ext = new InvoicePdfExt(ctrl);
    ext.ctrl.oneTimeSaleLineItems = new List<KGRenewal__InvoiceItem__c>();
    ext.ctrl.oneTimeSaleLineItems.add(ii);

    ext.ctrl.subscriptionLineItems  = new List<KGRenewal__InvoiceItem__c>();
    ext.ctrl.subscriptionLineItems.add(ii);

    
    System.debug(JSON.serialize(ext.oneTimeSaleLineItems));
    System.debug(JSON.serialize(ext.subscriptionLineItems));

    ext.generateKey(ii);
  }
}