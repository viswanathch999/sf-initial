trigger ContactExternalConnectionTrigger on Contact_External_Connection__c(after insert, after update) {

	if (Trigger.isAfter && Trigger.isInsert) {
		GUIDServices.generateGUID([SELECT Id, GUID__c FROM Contact_External_Connection__c WHERE Id in :Trigger.newMap.keyset()]);
	}


	new MyTriggers()
	.attach(MyTriggers.Evt.afterInsert, new ExternalConnectionProfileCheck())
	.attach(MyTriggers.Evt.afterUpdate, new ExternalConnectionProfileCheck())
	.run();
}