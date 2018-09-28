trigger ContactSkillTrigger on Contact_Skill__c (after insert)  { 
	
	if (Trigger.isAfter && Trigger.isInsert) {
		GUIDServices.generateGUID([SELECT Id, GUID__c FROM Contact_Skill__c WHERE Id in: Trigger.newMap.keyset()]);
	}

}