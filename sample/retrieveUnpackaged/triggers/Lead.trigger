trigger Lead on Lead(after insert, before Insert, before update, after update) {

/*
	LeadServices leadSvc = new LeadServices();

	if (Trigger.isUpdate) {
		LeadServices.syncLeadwithGeoRequirements(Trigger.new, Trigger.oldMap);
		LeadServices.updateChapterUsers(trigger.new, trigger.oldMap);
		leadSvc.deleteOldCreateNewShareRecords(Trigger.newMap, Trigger.oldMap);
		LeadServices.createLeadShareRecords(trigger.new, Trigger.oldMap, true);
	}
	if (Trigger.isInsert) {
		if(Trigger.isBefore){
			LeadServices.updateChapterUsers(trigger.new, trigger.oldMap);		
		}else{
			LeadServices.createLeadShareRecords(Trigger.new, null, false);		
		}
	}
*/
	new MyTriggers()
	.attach(MyTriggers.Evt.beforeInsert, new LeadServices())
	.attach(MyTriggers.Evt.afterInsert, new LeadServices())
	.attach(MyTriggers.Evt.beforeUpdate, new LeadServices())
	.attach(MyTriggers.Evt.afterUpdate, new LeadServices())
	.run();
}