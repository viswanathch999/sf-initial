trigger VoucherTrigger on Voucher__c (after insert, after update) {
    if(Trigger.isInsert)
    {
        if(Trigger.isAfter){
            GUIDServices.generateGUID([Select Id, GUID__c from Voucher__c where id in: Trigger.newMap.keyset()]);
        }
    }
    
    if(Trigger.isUpdate)
    {
        if(Trigger.isAfter){
             GUIDServices.generateGUID([Select Id, GUID__c from Voucher__c where id in: Trigger.newMap.keyset() and GUID__C = '']); 
        }
    }
}