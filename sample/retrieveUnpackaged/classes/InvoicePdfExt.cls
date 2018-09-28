public with sharing class InvoicePdfExt {

	public InvoicePdfCtrl ctrl { get; set; }
    public List<KGRenewal__InvoiceItem__c> subscriptionLineItems { 
        get {
            Map<String, KGRenewal__InvoiceItem__c> subscriptionLineItemMap = new Map<String, KGRenewal__InvoiceItem__c>();

            if(ctrl.subscriptionLineItems != null) {
                for(KGRenewal__InvoiceItem__c item : ctrl.subscriptionLineItems) {
                    String key = generateKey(item);
                    KGRenewal__InvoiceItem__c newItem;
                    if(subscriptionLineItemMap.containsKey(key)) {
                        newItem = subscriptionLineItemMap.get(key);
                        newItem.KGRenewal__Quantity__c += item.KGRenewal__QuantityDisplay__c;
                    }
                    else {
                        newItem = item;
                    }
                    subscriptionLineItemMap.put(key, newItem);
                }
                subscriptionLineItems = subscriptionLineItemMap.values();
            }
            else {
                subscriptionLineItems = new List<KGRenewal__InvoiceItem__c>();
            }
            return subscriptionLineItems;
        }set; 
    }

    public List<KGRenewal__InvoiceItem__c> oneTimeSaleLineItems { 
        get {
            Map<String, KGRenewal__InvoiceItem__c> subscriptionLineItemMap = new Map<String, KGRenewal__InvoiceItem__c>();

            if(ctrl.oneTimeSaleLineItems != null) {
                for(KGRenewal__InvoiceItem__c item : ctrl.oneTimeSaleLineItems) {
                    String key = generateKey(item);
                    KGRenewal__InvoiceItem__c newItem;
                    if(subscriptionLineItemMap.containsKey(key)) {
                        newItem = subscriptionLineItemMap.get(key);
                        newItem.KGRenewal__Quantity__c += newItem.KGRenewal__QuantityDisplay__c;
                    }
                    else {
                        newItem = item;
                    }
                    subscriptionLineItemMap.put(key, newItem);
                }
                oneTimeSaleLineItems = subscriptionLineItemMap.values();
            }
            else {
                oneTimeSaleLineItems = new List<KGRenewal__InvoiceItem__c>();
            }
            return oneTimeSaleLineItems;
        }set; 
    }

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public InvoicePdfExt(InvoicePdfCtrl ctrl) {
        this.ctrl = ctrl;
    }

    public String generateKey(KGRenewal__InvoiceItem__c item) {
        return '' + item.Name + item.KGRenewal__UnitPriceDisplay__c + item.KGRenewal__SubscriptionProduct__r.KGRenewal__EndDate__c;
    }
}