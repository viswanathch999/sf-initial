trigger EventTrigger on Event (before delete) {
    
    if(Trigger.isBefore){
        if(Trigger.isDelete){
            EventServices.validateDeleteAllowed(Trigger.old);
        }
    }
}