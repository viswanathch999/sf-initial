public without sharing class InvoicePdfCtrl {
    
    public String pageTitle {
        public get {
            return '' + invoiceRecord.Name; 
        }
    }
    
    public KGRenewal__Invoice__c invoiceRecord { 
        public get; 
        public set {
            if(value == null || value.Id == null) {
                invoiceRecord = new KGRenewal__Invoice__c();
                oneTimeSaleLineItems = new List<KGRenewal__InvoiceItem__c>();
                subscriptionLineItems = new List<KGRenewal__InvoiceItem__c>();
                return;
            }
            invoiceRecord = [SELECT KGRenewal__Opportunity__c,
                                    KGRenewal__Opportunity__r.KGRenewal__ContractEffectiveDate__c,
                                    KGRenewal__Opportunity__r.KGRenewal__ContractEndDate__c,
                                    KGRenewal__Subscription__c,
                                    KGRenewal__Status__c,
                                    KGRenewal__BillingDate__c,
                                    KGRenewal__DueDate__c,
                                    KGRenewal__AdjustmentAmount__c,
                                    KGRenewal__TotalAmount__c,
                                    KGRenewal__Amount__c,
                                    KGRenewal__AdjustmentDescription__c,
                                    Name,
                                    KGRenewal__Subscription__r.KGRenewal__Amount__c,
                                    KGRenewal__Subscription__r.KGRenewal__Account__r.Name,
                                    KGRenewal__Subscription__r.KGRenewal__Account__r.BillingStreet,
                                    KGRenewal__Subscription__r.KGRenewal__Account__r.BillingCity,
                                    KGRenewal__Subscription__r.KGRenewal__Account__r.BillingState,
                                    KGRenewal__Subscription__r.KGRenewal__Account__r.BillingPostalCode,
                                    KGRenewal__Subscription__r.KGRenewal__StartDate__c,
                                    KGRenewal__Subscription__r.KGRenewal__EndDate__c,
                                    KGRenewal__Subscription__r.KGRenewal__Account__r.Owner.Name,
                                    KGRenewal__Subscription__r.KGRenewal__Account__r.Owner.Phone,
                                    KGRenewal__Subscription__r.KGRenewal__Account__r.Owner.Email,
                                    KGRenewal__Subscription__r.KGRenewal__BillingFrequency__c
                                FROM KGRenewal__Invoice__c
                                WHERE Id = :value.Id];
            oneTimeSaleLineItems = [SELECT Name,
                                KGRenewal__Amount__c,
                                KGRenewal__QuantityDisplay__c,
                                KGRenewal__DescriptionDisplay__c,
                                KGRenewal__UnitPriceDisplay__c,
                                KGRenewal__DiscountDisplay__c,
                                KGRenewal__SubscriptionProduct__r.KGRenewal__EndDate__c
                            FROM KGRenewal__InvoiceItem__c
                            WHERE KGRenewal__Invoice__c = :invoiceRecord.Id
                            AND KGRenewal__SubscriptionProduct__r.KGRenewal__IsSubscription__c = FALSE
                            ORDER BY KGRenewal__SortOrder__c
                            ];
            subscriptionLineItems = [SELECT Name,
                                KGRenewal__Amount__c,
                                KGRenewal__QuantityDisplay__c,
                                KGRenewal__DescriptionDisplay__c,
                                KGRenewal__UnitPriceDisplay__c,
                                KGRenewal__DiscountDisplay__c,
                                KGRenewal__SubscriptionProduct__r.KGRenewal__EndDate__c
                            FROM KGRenewal__InvoiceItem__c
                            WHERE KGRenewal__Invoice__c = :invoiceRecord.Id
                            AND KGRenewal__SubscriptionProduct__r.KGRenewal__IsSubscription__c = TRUE
                            ORDER BY KGRenewal__SortOrder__c
                            ];
        }
    }
    public Account accountRecord { public get; public set; }
    
    
    public String currentDate {
        public get {
            return System.Today().format();
        }
        private set;
    }
    
    public List<KGRenewal__InvoiceItem__c> oneTimeSaleLineItems { public get; public set; }

    public List<KGRenewal__InvoiceItem__c> subscriptionLineItems { public get; public set; }

    public InvoicePdfCtrl() { }

}