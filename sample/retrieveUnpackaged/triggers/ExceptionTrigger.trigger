trigger ExceptionTrigger on Exception__c (before insert, before update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            ExceptionTriggerServices.updateUserLokups(Trigger.new, new Map<Id, Exception__c>());
        }else if(Trigger.isUpdate){
            ExceptionTriggerServices.updateUserLokups(Trigger.new, Trigger.oldMap);            
        }
    }
}