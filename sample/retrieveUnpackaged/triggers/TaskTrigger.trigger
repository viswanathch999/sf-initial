trigger TaskTrigger on Task (after insert, before delete) {
   if(Trigger.isAfter){
        if(Trigger.isInsert){
            TaskServices.updateLastContactedOnContact(Trigger.new);            
        }        
    }
    if(Trigger.isBefore){
        if(Trigger.isDelete){
            TaskServices.validateDeleteAllowed(Trigger.old);
        }
    }
}