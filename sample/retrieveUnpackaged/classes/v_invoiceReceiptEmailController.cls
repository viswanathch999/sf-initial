public without sharing class v_invoiceReceiptEmailController {

  public Id invoiceId {
        get;
        set {
            invoiceId = value;
            if(invoiceId != null) {
              initializeController();
            }
          }
  }

  public Decimal amount {get; set;}
  //public String orderNumber {get; set;} 
  public Decimal tax {get; set;}
  public Decimal billedAmount {get; set;}
  public Boolean hasTerm {get; set;}

  public String billingFirstName {get; set;}
  public String billingLastName {get; set;}
  public String billingStreet1 {get; set;}
  public String billingStreet2 {get; set;}
  public String billingCity {get; set;}
  public String billingState {get; set;}
  public String billingPostalCode {get; set;}
  public String billingCountry {get; set;}

  public String shippingFirstName {get; set;}
  public String shippingLastName {get; set;}
  public String shippingStreet1 {get; set;}
  public String shippingStreet2 {get; set;}
  public String shippingCity {get; set;}
  public String shippingState {get; set;}
  public String shippingPostalCode {get; set;}
  public String shippingCountry {get; set;}

  public List<LineItemWrapper> LineItemWrapperList {get; set;}

  //wrapper for line items
  public class LineItemWrapper {
    public String name {get; set;}
    public String productCode {get; set;}
    public Decimal salesPrice {get; set;}
    public Decimal term {get; set;}
    public Decimal unitPrice {get; set;}
    public Decimal quantity {get; set;}
    public Decimal totalPrice {get; set;}

    public LineItemWrapper() {
    }
  }

  public void initializeController() {
    //query fields to copy to primitive fields to get around permissions
    System.debug('Got here');
    KGRenewal__Invoice__c i = [Select
      KGRenewal__Amount__c,                             //subtotal
      KGRenewal__TotalAmount__c,         //Billed Amount from Venue. Do we want to use Transaction.Amount__c or Invoice.TotalAmount__c?
      KGRenewal__Opportunity__r.KGRenewal__BillingFirstName__c,
      KGRenewal__Opportunity__r.KGRenewal__BillingLastName__c,
      KGRenewal__Opportunity__r.KGRenewal__BillingStreetAddressLine1__c,
      KGRenewal__Opportunity__r.KGRenewal__BillingStreetAddressLine2__c,
      KGRenewal__Opportunity__r.KGRenewal__BillingCity__c,
      KGRenewal__Opportunity__r.KGRenewal__BillingState__c,
      KGRenewal__Opportunity__r.KGRenewal__BillingPostalCode__c, 
      KGRenewal__Opportunity__r.KGRenewal__BillingCountry__c,
      KGRenewal__Opportunity__r.KGRenewal__ShippingFirstName__c,
      KGRenewal__Opportunity__r.KGRenewal__ShippingLastName__c,
      KGRenewal__Opportunity__r.KGRenewal__ShippingStreetAddressLine1__c,
      KGRenewal__Opportunity__r.KGRenewal__ShippingStreetAddressLine2__c,
      KGRenewal__Opportunity__r.KGRenewal__ShippingCity__c,
      KGRenewal__Opportunity__r.KGRenewal__ShippingState__c,
      KGRenewal__Opportunity__r.KGRenewal__ShippingPostalCode__c,
      KGRenewal__Opportunity__r.KGRenewal__ShippingCountry__c,
      (SELECT 
        Name,
        KGRenewal__ProductNameDisplay__c, 
        //PricebookEntry.Product2.ProductCode, 
        KGRenewal__UnitPriceDisplay__c,
        //KGRenewal__Term__c,
        KGRenewal__QuantityDisplay__c
        //TotalPrice
        FROM KGRenewal__InvoiceItems__r)
      FROM KGRenewal__Invoice__c WHERE Id =: invoiceId];
    if(i != null) {
        if(i.KGRenewal__Amount__c != null) {
          amount =  i.KGRenewal__Amount__c;
        }
    
        //orderNumber = i.SF_Opportunity_Number__c.right(8);
        
        tax = 0;

  
        
        billedAmount = i.KGRenewal__TotalAmount__c;
        
        if(i.KGRenewal__Opportunity__c != null){  
            billingFirstName = i.KGRenewal__Opportunity__r.KGRenewal__BillingFirstName__c;
            billingLastName = i.KGRenewal__Opportunity__r.KGRenewal__BillingLastName__c;
            billingStreet1 = i.KGRenewal__Opportunity__r.KGRenewal__BillingStreetAddressLine1__c;
            billingStreet2 = i.KGRenewal__Opportunity__r.KGRenewal__BillingStreetAddressLine2__c;
            billingCity = i.KGRenewal__Opportunity__r.KGRenewal__BillingCity__c;
            billingState = i.KGRenewal__Opportunity__r.KGRenewal__BillingState__c;
            billingPostalCode = i.KGRenewal__Opportunity__r.KGRenewal__BillingPostalCode__c;
            billingCountry = i.KGRenewal__Opportunity__r.KGRenewal__BillingCountry__c;
        
            shippingFirstName = i.KGRenewal__Opportunity__r.KGRenewal__ShippingFirstName__c;
            shippingLastName = i.KGRenewal__Opportunity__r.KGRenewal__ShippingLastName__c;
            shippingStreet1 = i.KGRenewal__Opportunity__r.KGRenewal__ShippingStreetAddressLine1__c;
            shippingStreet2 = i.KGRenewal__Opportunity__r.KGRenewal__ShippingStreetAddressLine2__c;
            shippingCity = i.KGRenewal__Opportunity__r.KGRenewal__ShippingCity__c;
            shippingState = i.KGRenewal__Opportunity__r.KGRenewal__ShippingState__c;
            shippingPostalCode = i.KGRenewal__Opportunity__r.KGRenewal__ShippingPostalCode__c;
            shippingCountry = i.KGRenewal__Opportunity__r.KGRenewal__ShippingCountry__c;
        }
      
        //set line item values
        hasTerm = false;        //initialize
        LineItemWrapperList = new List<LineItemWrapper>();
    
        for (KGRenewal__InvoiceItem__c lineItem : i.KGRenewal__InvoiceItems__r) {
          LineItemWrapper wrapper = new LineItemWrapper();
          //wrapper.name = lineItem.KGRenewal__Name__c;
          wrapper.name = lineItem.KGRenewal__ProductNameDisplay__c;
          //wrapper.ProductCode = lineItem.PricebookEntry.Product2.ProductCode;
          wrapper.salesPrice = lineItem.KGRenewal__UnitPriceDisplay__c;
          //wrapper.term = lineItem.KGRenewal__Term__c;
          if (wrapper.term != null && wrapper.term > 0) {
            hasTerm = true;
          }
          wrapper.quantity = lineItem.KGRenewal__QuantityDisplay__c;
          wrapper.unitPrice = lineItem.KGRenewal__UnitPriceDisplay__c;
          wrapper.totalPrice = lineItem.KGRenewal__QuantityDisplay__c * lineItem.KGRenewal__UnitPriceDisplay__c; //clarify
          LineItemWrapperList.add(wrapper);
          }
       }
    }
    
}