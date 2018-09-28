/*
 * 
 * AccountAffiliationTrigger is a trigger for all the operations to be performed on 
 * Account_Affiliation__c object. 
 *
 * @author Shri K
*/

trigger AccountAffiliationTrigger on Account_Affiliation__c(after insert, before insert, before update, after update, after delete) {

	BusinessAddress BA = new BusinessAddress();

	if (Trigger.isBefore) {
		if (Trigger.isUpdate) {
			if (!System.isBatch()) {
				AccountAffiliationServices.syncSpouseAccAffs(AccountAffiliationServices.filterAccAffsForSync(Trigger.new, Trigger.oldMap), Trigger.oldMap);
				AccountAffiliationServices.updateContactChapterLookup(AccountAffiliationServices.filterAccAffsMarkedPrimary(Trigger.new, Trigger.oldMap));
				AccountAffiliationServices.revokeCAToNetworkAccSharing(AccountAffiliationServices.filterNetworkAffiliations(Trigger.new, Trigger.oldMap));
				AccountAffiliationServices.addAccAffForSpouse(Select.Field.isEqual('Validation_Check__c', true).filter(Trigger.new, Trigger.oldMap));
				BA.getAddress(trigger.new, trigger.oldMap, false);
			}
		}

		if (Trigger.isInsert) {
			AccountAffiliationServices.checkIfDuplicateAffExist(Trigger.new);
		}
	}

	if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			AccountAffiliationServices.generateGUID(Trigger.new);
			AccountAffiliationServices.addAccAffForSpouse(Trigger.new);
		}
		if (Trigger.isDelete) {
			Map<Id, Account_Affiliation__c> emptyMap = new Map<Id, Account_Affiliation__c> ();
			AccountAffiliationServices.revokeCAToNetworkAccSharing(AccountAffiliationServices.filterNetworkAffiliations(Trigger.old, emptyMap));
		}

	}

	new MyTriggers()
	.attach(MyTriggers.Evt.afterInsert, new AccountAffiliationProfileCheck())
	.attach(MyTriggers.Evt.afterUpdate, new AccountAffiliationProfileCheck())
	.run();

}