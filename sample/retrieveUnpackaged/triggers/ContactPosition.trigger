trigger ContactPosition on Contact_Position__c (before insert, after insert) {
    if(Trigger.isBefore && Trigger.isInsert){
        
        ContactPositionServices.validateDuplicatePositionRecords(Trigger.new);
    }
    if(Trigger.isInsert)
    {
        if(Trigger.isAfter)
        GUIDServices.generateGUID([Select Id, GUID__c from Contact_Position__c where id in: Trigger.newMap.keyset()]);
    }
}