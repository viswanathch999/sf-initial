trigger ContactSkill on Contact_Skill__c (after insert, after update)  { 

	new MyTriggers()
	.attach(MyTriggers.Evt.afterInsert, new ContactSkilProfileCheck())
	.attach(MyTriggers.Evt.afterUpdate, new ContactSkilProfileCheck())
	.run();
}