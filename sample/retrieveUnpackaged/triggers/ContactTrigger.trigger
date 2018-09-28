/*
 * 
 * ContactTrigger is a trigger for all the operations to be performed on 
 * contact object. 
 *
 * @author Shri K
 */
trigger ContactTrigger on Contact(before insert, after insert, before update, after update) {
	ContactServices cs = new ContactServices();

	if (Trigger.isBefore && Trigger.isInsert) {
		cs.createContactShareRecords(Trigger.new, false);
	}
	if (Trigger.isAfter && Trigger.isInsert) {
		ContactServices.generateGUID(trigger.new);
	}

	if (Trigger.isBefore && Trigger.isUpdate) {
		ContactUserServices.processContactsForUserDeactivation(Trigger.newMap, Trigger.oldMap);
		cs.deleteOldCreateNewShareRecords(Trigger.new, Trigger.oldMap);
		if (UserInfo.getProfileId() != [Select Id From Profile Where Name = :Label.Customer_Community_User_Custom LIMIT 1].Id) {
			cs.createContactShareRecords(Select.Field.hasChanged('RecordTypeId').filter(Trigger.new, Trigger.oldMap), true);
		}

		ContactServices.contactCommunityUserCreation(Trigger.newMap);
	}

	new MyTriggers()
	.attach(MyTriggers.Evt.afterInsert, new ContactProfileCheck())
	.attach(MyTriggers.Evt.afterUpdate, new ContactProfileCheck())
	.run();
}