/*
 * 
 * AccountTrigger is a trigger for all the operations to be performed on 
 * Account object. 
 *
 * @author Shri K
 */
trigger AccountTrigger on Account (after insert) {
   
    if(Trigger.isAfter && Trigger.isInsert)
    {
        AccountServices.generateGUID(Trigger.new);
    }
}