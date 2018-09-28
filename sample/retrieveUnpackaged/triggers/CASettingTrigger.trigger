/*
* 
* ContactTrigger is a trigger for all the operations to be performed on 
* CA Settings object. 
* This object removes/adds access to portal on few sets of records.
* @author Shri K
*/
trigger CASettingTrigger on CA_Setting__c (before insert, after insert, after update, before delete) {
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            Map<Id, CA_Setting__c> emptyMap = new Map<Id, CA_Setting__c>();
            CASettingServices.validateAndMarkPrimary(Trigger.new, emptyMap);
        }
        else if(Trigger.isUpdate){
            CASettingServices.validateAndMarkPrimary(Trigger.new, Trigger.oldMap);            
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            CASettingServices.shareRecordsWithPartnerUser(Trigger.new, Trigger.oldMap);
            CASettingServices.updateLeads(Trigger.new, new Map<Id, CA_Setting__c>());
            CASettingServices.updateAccAff(Trigger.new, new Map<Id, CA_Setting__c>());
        }
        else if(Trigger.isUpdate){
            CASettingServices.shareRecordsWithPartnerUser(Trigger.new, Trigger.oldMap); 
            CASettingServices.updateLeads(Trigger.new, Trigger.oldMap);
            CASettingServices.updateAccAff(Trigger.new, Trigger.oldMap);
            
        }
    }  
    if(Trigger.isBefore && Trigger.isDelete){
        Map<Id, CA_Setting__c> emptyMap = new Map<Id, CA_Setting__c>();
        CASettingServices.shareRecordsWithPartnerUser(Trigger.old, emptyMap);
    }
}