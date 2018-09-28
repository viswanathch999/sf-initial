trigger InterestTrigger on Interest__c (after insert, after update, after delete) {

    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete))
    {
        InterestServices.calculateMarketingSegmentation(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
    }
    if(Trigger.isInsert)
    {
        if(Trigger.isAfter)
        GUIDServices.generateGUID([Select Id, GUID__c from Interest__c where id in: Trigger.newMap.keyset()]);
    }
}