trigger ContactSkillOptionTrigger on Contact_Skill_Option__c (after insert)  { 
	
	if (Trigger.isAfter && Trigger.isInsert) {
		GUIDServices.generateGUID([SELECT Id, GUID__c FROM Contact_Skill_Option__c WHERE Id in: Trigger.newMap.keyset()]);
	}

}