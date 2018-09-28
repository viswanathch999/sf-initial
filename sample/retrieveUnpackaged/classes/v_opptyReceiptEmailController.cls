public without sharing class v_opptyReceiptEmailController {

  public KGRenewal__Transaction__c tranny {
    get;
        set {
            tranny = value;
            if(tranny != null && tranny.Id != null){
              KGRenewal__Transaction__c trans = [SELECT KGRenewal__Opportunity__c FROM KGRenewal__Transaction__c WHERE Id =: tranny.Id];
              if(trans != null) {
                opptyId = trans.KGRenewal__Opportunity__c ;
              }
              if(opptyId != null){
                initializeController();
              }
            }
          }
  }
  public Id opptyId {
        get;
        set;
  }

  public Decimal amount {get; set;}
  public String orderNumber {get; set;}
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
    Opportunity o = [Select
      Amount,                             
      KGRenewal__Tax__c,                
      KGRenewal__BilledAmount__c,
      KGRenewal__BillingFirstName__c,
      KGRenewal__BillingLastName__c,
      KGRenewal__BillingStreetAddressLine1__c,
      KGRenewal__BillingStreetAddressLine2__c,
      KGRenewal__BillingCity__c,
      KGRenewal__BillingState__c,
      KGRenewal__BillingPostalCode__c, 
      KGRenewal__BillingCountry__c,
      KGRenewal__ShippingFirstName__c,
      KGRenewal__ShippingLastName__c,
      KGRenewal__ShippingStreetAddressLine1__c,
      KGRenewal__ShippingStreetAddressLine2__c,
      KGRenewal__ShippingCity__c,
      KGRenewal__ShippingState__c,
      KGRenewal__ShippingPostalCode__c,
      KGRenewal__ShippingCountry__c,
      (SELECT 
        //KGRenewal__Name__c,
        PricebookEntry.Product2.Name, 
        PricebookEntry.Product2.ProductCode, 
        KGRenewal__UnitPrice__c,
        KGRenewal__Term__c,
        UnitPrice,
        Quantity,
        TotalPrice
        FROM OpportunityLineItems)
      FROM Opportunity WHERE Id =: opptyId];
    

        
        if(o.Amount != null) {
          amount =  o.Amount;
        }
    
        orderNumber = '';
        
        tax = 0;
    
        billedAmount = o.KGRenewal__BilledAmount__c;
    
        billingFirstName = o.KGRenewal__BillingFirstName__c;
        billingLastName = o.KGRenewal__BillingLastName__c;
        billingStreet1 = o.KGRenewal__BillingStreetAddressLine1__c;
        billingStreet2 = o.KGRenewal__BillingStreetAddressLine2__c;
        billingCity = o.KGRenewal__BillingCity__c;
        billingState = o.KGRenewal__BillingState__c;
        billingPostalCode = o.KGRenewal__BillingPostalCode__c;
        billingCountry = o.KGRenewal__BillingCountry__c;
    
        shippingFirstName = o.KGRenewal__ShippingFirstName__c;
        shippingLastName = o.KGRenewal__ShippingLastName__c;
        shippingStreet1 = o.KGRenewal__ShippingStreetAddressLine1__c;
        shippingStreet2 = o.KGRenewal__ShippingStreetAddressLine2__c;
        shippingCity = o.KGRenewal__ShippingCity__c;
        shippingState = o.KGRenewal__ShippingState__c;
        shippingPostalCode = o.KGRenewal__ShippingPostalCode__c;
        shippingCountry = o.KGRenewal__ShippingCountry__c;
    
        //set line item values
        hasTerm = false;        //initialize
        LineItemWrapperList = new List<LineItemWrapper>();
    
        for (OpportunityLineItem lineItem : o.OpportunityLineItems) {
          LineItemWrapper wrapper = new LineItemWrapper();
          //wrapper.name = lineItem.KGRenewal__Name__c;
          wrapper.name = lineItem.PricebookEntry.Product2.Name;
          wrapper.ProductCode = lineItem.PricebookEntry.Product2.ProductCode;
          wrapper.salesPrice = lineItem.KGRenewal__UnitPrice__c;
          wrapper.term = lineItem.KGRenewal__Term__c;
          if (wrapper.term != null && wrapper.term > 0) {
            hasTerm = true;
          }
          wrapper.quantity = lineItem.Quantity;
          wrapper.unitPrice = lineItem.UnitPrice;
          wrapper.totalPrice = lineItem.TotalPrice;
          LineItemWrapperList.add(wrapper);
          }
       
    }

}