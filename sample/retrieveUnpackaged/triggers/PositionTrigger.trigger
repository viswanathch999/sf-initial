trigger PositionTrigger on Position__c (After Insert) {
    if(Trigger.isInsert)
    {
        if(Trigger.isAfter)
        GUIDServices.generateGUID([Select Id, GUID__c from Position__c where id in: Trigger.newMap.keyset()]);
    }
}