trigger RelationshipTrigger on Relationship__c (before insert, before update, after insert, after update) {
   if(Trigger.isBefore){
        if(Trigger.isInsert) 
        { RelationshipServices.restrictMoreThanOneActiveSpouse(
            RelationshipServices.filterActiveSpouseRelationship(Trigger.new, new Map<Id,Relationship__c>()));
        }
        if(Trigger.isUpdate)
        {
            RelationshipServices.restrictMoreThanOneActiveSpouse(RelationshipServices.filterActiveSpouseRelationship(Trigger.new, Trigger.oldMap));
            RelationshipServices.deactivateExSpouse(RelationshipServices.filterForExSpouseRelationship(trigger.new,trigger.oldMap));
        }
    }
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert){
            GUIDServices.generateGUID([Select Id, GUID__c from Relationship__c where id in: Trigger.newMap.keyset()]);
            RelationshipServices.insertAccountAffiliations(RelationshipServices.filterSpouseRelationships(Trigger.new, new Map<Id, Relationship__c>()));
        }
        if(Trigger.isUpdate){
            RelationshipServices.updateAccountAffiliations(RelationshipServices.filterSpouseRelationships(Trigger.new, Trigger.oldMap));
        }
    }
}