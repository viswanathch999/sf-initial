public class v_InvoicePdfController
{
/*****************************************************************************/
// Pass in an Invoice record to query to get related Invoice Items and Transactions
// Used since if the component is passed an Invoice record from an email template related 
// to a Transaction, the Inoice standard controller will not include the related 
// Invoice Items and Transactions in the Invoice fields it provides

  public KGRenewal__Invoice__c invoiceRecord
  {
    public get;
    public set
    {
      if(value == null || value.Id == null)
      {
        invoiceRecord = new KGRenewal__Invoice__c();
        return;
      }
      invoiceRecord = [SELECT Id, 
                              (SELECT Name, 
                                      Description_PDF__c, 
                                      SalesPriceDisplay__c, 
                                      KGRenewal__DiscountDisplay__c, 
                                      KGRenewal__Amount__c 
                                  FROM KGRenewal__InvoiceItems__r 
                                  //ORDER BY KGRenewal__SortOrder__c, Name), 
                                  ORDER BY Sort_PDF__c, Name), 
                              (SELECT CreatedDate, 
                                      KGRenewal__Type__c,
                                      KGRenewal__TransactionMethod__c, 
                                      KGRenewal__TransactionMethodDetails__c, 
                                      KGRenewal__Amount__c 
                                  FROM KGRenewal__Transactions__r 
                                  WHERE KGRenewal__IsSuccess__c = true 
                                  ORDER BY CreatedDate) 
                          FROM KGRenewal__Invoice__c 
                          WHERE Id = :value.Id];
    }
  }
/*****************************************************************************/
}