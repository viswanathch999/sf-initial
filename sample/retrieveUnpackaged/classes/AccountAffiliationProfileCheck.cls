public class AccountAffiliationProfileCheck implements MyTriggers.Handler {
	private List<SObject> AccountAffiliationCollection = new List<SObject> (Trigger.new);
	private Map<Id, Set<Account_Affiliation__c>> verifyChanges = new Map<Id, Set<Account_Affiliation__c>> ();
	private Boolean isUpdated = false;
	private Map<String, Schema.RecordTypeInfo> recordTypes = RecordTypeServices.getRecordType('Account_Affiliation__c');
	private Map<Id, String> jsonMap = new Map<Id, String> ();
	private Set<Id> contactsAffected = new Set<Id> ();

	public void handle() {
		cleanRecords();

		if(contactsAffected.size() > 0){
			educationProfileCheck();

			businessProfileCheck();

			ProfileCompletionUtility.ProfileCompletionUtility(jsonMap);		
		}
	}

	private void cleanRecords() {
		Id schoolRecordTypeId = recordTypes.get('School').getRecordTypeId();
		Id businessRecordTypeId = recordTypes.get('Business').getRecordTypeId();

		for (SObject s : Trigger.new) { 
			if ((s.get('RecordTypeId') == schoolRecordTypeId || s.get('RecordTypeId') == businessRecordTypeId) && s.get('Contact_Record_Type_Name__c') != 'Non-Member') {
				contactsAffected.add((Id) s.get('Contact__c'));
			}
		}
		System.debug('Contacts Affected : ' + contactsAffected);
		System.debug((contactsAffected.size() > 0));		
		if (contactsAffected.size() > 0) {
			for (Account_Affiliation__c a :[Select ID, Contact__c, RecordTypeId, IsActive__c, Is_Primary__c, Job_Title__c, Account__c, Industry_Category_1__c, Street__c, Scope_of_Business__c, Business_Role__c, Company_Size__c, Organization_Type__c
			     FROM Account_Affiliation__c WHERE Contact__c IN :contactsAffected AND(RecordTypeId = :schoolRecordTypeId OR RecordTypeId = :businessRecordTypeId)]) {

				if (a.RecordTypeId == schoolRecordTypeId) {
					if (verifyChanges.containsKey(a.Contact__c)) {
						verifyChanges.get(a.Contact__c).add(a);
					} else {
						verifyChanges.put(a.Contact__c, new Set<Account_Affiliation__c> { a });
					}

				}
				if (a.RecordTypeId == recordTypes.get('Business').getRecordTypeId()) {
					if (a.IsActive__c && a.Is_Primary__c) {
						if (verifyChanges.containsKey(a.Contact__c)) {
							verifyChanges.get(a.Contact__c).add(a);
						} else {
							verifyChanges.put(a.Contact__c, new Set<Account_Affiliation__c> { a });
						}
					}
				}
			}
		} else {
			return;
		}
	}

	private void educationProfileCheck() {
		Profile_Completion_Criteria__c updateCompletion;
		for (SObject s : Trigger.new) {
			updateCompletion = new Profile_Completion_Criteria__c();
			if (((String) s.get('RecordTypeId') == recordTypes.get('School').getRecordTypeId() && (Boolean) s.get('IsActive__c')) || checkExisting((Id) s.get('Contact__c'), 'School')) {
				updateCompletion.Education__c = 1;
			} else if ((String) s.get('RecordTypeId') == recordTypes.get('School').getRecordTypeId()) {
				updateCompletion.Education__c = 0;
			}
			jsonMap.put((Id) s.get('Contact__c'), JSON.serialize(updateCompletion));
		}
	}


	private void businessProfileCheck() {
		Profile_Completion_Criteria__c updateCompletion;
		for (SObject s : Trigger.new) {
			updateCompletion = new Profile_Completion_Criteria__c();
			if (s.get('RecordTypeId') == recordTypes.get('Business').getRecordTypeId() && (Boolean) s.get('isActive__c') && (Boolean) s.get('is_Primary__c')) {
				isUpdated = true;
				updateCompletion.Business_Role__c = (s.get('Job_Title__c') != NULL ? 1 : 0);
				updateCompletion.Company_Name__c = (s.get('Account__c') != NULL ? 1 : 0);
				updateCompletion.Company_Industry_Category__c = (s.get('Industry_Category_1__c') != NULL ? 1 : 0);
				updateCompletion.Company_Address__c = (s.get('Street__c') != NULL ? 1 : 0);
				updateCompletion.Business_Scope__c = (s.get('Scope_of_Business__c') != NULL ? 1 : 0);
				updateCompletion.Type_of_President__c = (s.get('Business_Role__c') != NULL ? 1 : 0);
				updateCompletion.Company_Size__c = (s.get('Company_Size__c') != NULL ? 1 : 0);
				updateCompletion.Company_Type__c = (s.get('Organization_Type__c') != NULL ? 1 : 0);
			} else if (!checkExisting((Id) s.get('Contact__c'), 'Business')) {
				isUpdated = true;
				updateCompletion = clearBusinessPercentages(updateCompletion);
			}

			if (jsonMap.containsKey((Id) s.get('Contact__c'))) {
				updateCompletion.Education__c = ((Profile_Completion_Criteria__c) JSON.deserializeStrict(jsonMap.get((Id) s.get('Contact__c')), Profile_Completion_Criteria__c.class)).Education__c;
			}
			System.debug(isUpdated);
			if (isUpdated) {
				isUpdated = false;
				jsonMap.put((Id) s.get('Contact__c'), JSON.serialize(updateCompletion));

			}

		}
	}

	private Boolean checkExisting(Id i, String rType) {
		if (verifyChanges.containsKey(i)) {
			for (Account_Affiliation__c a : verifyChanges.get(i)) {
				if (a.RecordTypeId == recordTypes.get(rType).getRecordTypeId() && a.IsActive__c) {
					return true;
				}
			}
			return false;
		}
		return false;
	}

	private Profile_Completion_Criteria__c clearBusinessPercentages(Profile_Completion_Criteria__c pCC) {
		pCC = new Profile_Completion_Criteria__c();
		pCC.Business_Role__c = 0;
		pCC.Company_Name__c = 0;
		pCC.Company_Industry_Category__c = 0;
		pCC.Company_Address__c = 0;
		pCC.Business_Scope__c = 0;
		pCC.Type_of_President__c = 0;
		pCC.Company_Size__c = 0;
		pCC.Company_Type__c = 0;

		return pCC;
	}
}