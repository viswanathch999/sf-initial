public class ExternalConnectionProfileCheck implements MyTriggers.Handler {
	private Set<Id> modifiedRecords = new Set<Id> ();
	private Map<Id, List<Contact_External_Connection__c>> recordLookup = new Map<Id, List<Contact_External_Connection__c>> ();

	private Map<Id, String> JSONMap = new Map<Id, String> ();

	public void handle() {

		checkExisting();

		checkProfile();

	}

	private void checkExisting() {

		for (SObject s : Trigger.new) {
			modifiedRecords.add((Id) s.get('Contact__c'));
		}
		if (modifiedRecords.size() > 0) {
			for (Contact_External_Connection__c extCon :[Select Id, Contact__c, Active_ContactExternalConnection__c FROM Contact_External_Connection__c WHERE Contact__c IN :modifiedRecords]) {
				if (recordLookup.containsKey(extCon.Contact__c)) {
					recordLookup.get(extCon.Contact__c).add(extCon);
				} else {
					recordLookup.put(extCon.Contact__c, new List<Contact_External_Connection__c> { extCon });
				}
			}
		}
	}

	private void checkProfile() {
		Profile_Completion_Criteria__c updateCompletion;

		for (Id i : Trigger.newMap.keySet()) {
			updateCompletion = new Profile_Completion_Criteria__c();

			updateCompletion.External_Connection__c = ((Boolean) Trigger.newMap.get(i).get('Active_ContactExternalConnection__c') || checkExisting((Id) Trigger.newMap.get(i).get('Contact__c')) ? 1 : 0);

			JSONMap.put((Id) Trigger.newMap.get(i).get('Contact__c'), JSON.serialize(updateCompletion));
		}

		if (JSONMap.size() > 0) {
			ProfileCompletionUtility.ProfileCompletionUtility(JSONMap);
		}
	}


	private Boolean checkExisting(Id contID){
		for(Contact_External_Connection__c c : recordLookup.get(contID)){
			if (c.Active_ContactExternalConnection__c){
				return true;
			}
		}

		return false;
	}

}