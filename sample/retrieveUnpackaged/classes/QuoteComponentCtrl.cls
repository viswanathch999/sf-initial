/************************************************* 
* Class: Quote Pdf Controller
* Purpose: This class handles the back end for
*   generating quote pdf attachments.
* Author: dharrison@kineticgrowth.com
*************************************************/
global with sharing class QuoteComponentCtrl {

    public String pageTitle {
        public get {
            return 'Quote #: ' + '000001 - ' + opportunityRecord.Account.Name; 
        }
    }
    public String quoteNumber {
        public get {
            if(quoteNumber == null) {
                try {
                    return 'QTE' + System.Now().year() + System.Now().month() + System.Now().day() + '-' + System.Now().hour() + System.Now().minute() + '-' + opportunityRecord.Owner.FirstName.substring(0,1) + opportunityRecord.Owner.LastName.substring(0,1);
                }
                catch(exception e) {
                    try {
                        return 'QTE' + System.Now().year() + System.Now().month() + System.Now().day() + '-' + System.Now().hour() + System.Now().minute();
                    }
                    catch(exception e2) { return ''; }
                }
            }
            else {
                return quoteNumber;
            }
        }
        public set;
    }

    public Boolean isMultiCurrencyOrganization {
        get {

            if (isMultiCurrencyOrganization == null){
                isMultiCurrencyOrganization = UserInfo.isMultiCurrencyOrganization();
            }
            return isMultiCurrencyOrganization;
            } set ;
    }
    
    public String CurrencyISOCode { public get {
        return (isMultiCurrencyOrganization ? 
                    (String)opportunityRecord.get('CurrencyIsoCode') : 
                    UserInfo.getDefaultCurrency());
    } public set; }
    
    public String totalListPrice {
        public get {
            Decimal total = 0;
            for(OpportunityLineItem oli : lineItems) {
                total += oli.ListPrice;
            }
            return (isMultiCurrencyOrganization ? opportunityRecord.get('CurrencyIsoCode') : 
                UserInfo.getDefaultCurrency()) + ' ' + total.setScale(2).format();
        }
        private set;
    }
    
    public Decimal taxedAmount {
        public get{
        return OpportunityRecord.Amount + OpportunityRecord.KGRenewal__Tax__c;
        }
    }
    
    public Opportunity opportunityRecord { public get; 
        public set {
        opportunityRecord = value;
        lineItems = [SELECT PricebookEntry.Product2.Name, 
                            Quantity,
                            UnitPrice,
                            ListPrice,
                            TotalPrice,
                            Discount,
                            KGRenewal__UnitPrice__c,
                            Description
                        FROM OpportunityLineItem
                        WHERE OpportunityId = :opportunityRecord.Id];
        }
    }
    
    public String currentDate {
        public get {
            return System.Today().format();
        }
        private set;
    }
    
    public String expirationDate {
        public get {
            return (System.Today().addDays(30)).format();
        }
        private set;
    }
    
    public List<OpportunityLineItem> lineItems { public get; private set; }

    public QuoteComponentCtrl(ApexPages.StandardController stdCtrl) {
        opportunityRecord = (Opportunity)stdCtrl.getRecord();
        lineItems = [SELECT PricebookEntry.Product2.Name, 
                            Quantity,
                            UnitPrice,
                            ListPrice,
                            TotalPrice,
                            Discount,
                            Description
                        FROM OpportunityLineItem
                        WHERE OpportunityId = :opportunityRecord.Id];
    }
    
    public QuoteComponentCtrl(Id opportunityId, String quoteName) {
        opportunityRecord = [SELECT Name, 
                                    Id, 
                                    Pricebook2.Name,
                                    Account.Name,
                                    Account.BillingStreet,
                                    Account.BillingCity,
                                    Account.BillingState,
                                    Account.BillingPostalCode,
                                    KGRenewal__ContractEffectiveDate__c,
                                    KGRenewal__ContractEndDate__c,
                                    Owner.Name,
                                    Amount,
                                    Owner.Email,
                                    Owner.Phone,
                                    KGRenewal__Tax__c  
                                FROM Opportunity 
                                WHERE Id = :opportunityId];
        lineItems = [SELECT PricebookEntry.Product2.Name, 
                            Quantity,
                            UnitPrice,
                            ListPrice,
                            TotalPrice,
                            Discount,
                            Description
                        FROM OpportunityLineItem
                        WHERE OpportunityId = :opportunityRecord.Id];
        quoteNumber = quoteName;
    }
    
    
    public QuoteComponentCtrl() {
    
    }
    
    public String formatCurrency(Decimal d) {
        if(d == null) {
            return '';
        }
        else {
            return '$' + d.format() ;
        }
    }
}