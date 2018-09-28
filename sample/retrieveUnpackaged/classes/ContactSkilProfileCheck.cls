public class ContactSkilProfileCheck implements MyTriggers.Handler {
	private Map<Id, List<Contact_Skill__c>> potentialUpdates = new Map<Id, List<Contact_Skill__c>> ();

	private Map<Id, String> JSONMap = new Map<Id, String> ();

	public void handle() {

		checkExstingRecords();
		profileCheck();
		if (JSONMap.size() > 0) {
			ProfileCompletionUtility.ProfileCompletionUtility(JSONMap);
		}

	}

	private void checkExstingRecords() {
		for (SObject s : Trigger.new) {
			potentialUpdates.put((Id) s.get('Contact_on_Contact_Skill__c'), new List<Contact_Skill__c>());

		}

		if (potentialUpdates.size() > 0) {
			for (Contact_skill__c contSkill :[Select Id, CreatedBy.Name, LastModifiedBy.Name, Type_Contact_Skill__c, Contact_on_Contact_Skill__c, Active_Contact_Skill__c from Contact_Skill__c
			     where Contact_On_Contact_Skill__c IN :potentialUpdates.keySet() and Active_Contact_Skill__c = true and(Type_Contact_Skill__c = 'Expertise' OR Type_Contact_Skill__c = 'Interest')]) {
				potentialUpdates.get((Id) contSkill.Contact_on_Contact_Skill__c).add(contSkill);
			}
		}

	}

	private void profileCheck() {
		Profile_Completion_Criteria__c updateCompletion;
		for (sObject s : Trigger.new) {
			updateCompletion = new Profile_Completion_Criteria__c();
			if (s.get('Type_Contact_Skill__c') == 'Interest') {
				updateCompletion.Interests__c = (((Boolean) s.get('Active_Contact_Skill__c') || checkExisting((Id) s.get('Contact_on_Contact_Skill__c'), 'Interest')) ? 1 : 0);
			} else if (s.get('Type_Contact_Skill__c') == 'Expertise') {
				updateCompletion.Business_Expertise__c = (((Boolean) s.get('Active_Contact_Skill__c') || checkExisting((Id) s.get('Contact_on_Contact_Skill__c'), 'Expertise')) ? 1 : 0);
			}
			jsonMap.put((Id) s.get('Contact_on_Contact_Skill__c'), JSON.serialize(updateCompletion));
		}
	}

	private Boolean checkExisting(Id recordId, String rType) {
		if (potentialUpdates.containsKey(recordId)) {
			for (SObject s : potentialUpdates.get(recordId)) {
				if (s.get('Type_Contact_Skill__c') == rType && (Boolean) s.get('Active_Contact_Skill__c')) {
					return true;
				}
			}
		}

		return false;
	}
}