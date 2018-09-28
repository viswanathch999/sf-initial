trigger KGRenewalInvoiceTrigger on KGRenewal__Invoice__c (after insert, after update) {
/*
    if(Trigger.isAfter){
        if(Trigger.isInsert)
        {KGRenewalInvoiceServices.sendEmails(
            KGRenewalInvoiceServices.filterCheckOrWireTranferInvoice(Trigger.new,
                                                                     new Map<Id, KGRenewal__Invoice__c>()));
        }
        if(Trigger.isUpdate)
        {KGRenewalInvoiceServices.sendEmails(
            KGRenewalInvoiceServices.filterCheckOrWireTranferInvoice(Trigger.new,
                                                                     Trigger.oldMap));
        }
    }*/
}