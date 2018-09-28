/**
 * Class responsible for deactivating a Communities user when the related contact is set to resigned.
 *
 * @author Matthew A
 */
public without sharing class ContactUserServices {

	/**
	 * @author Matthew A
	 * @param newContactMap - map of the new values for the updated contact
	 * @param oldContactMap - map of the old values for the updated contact
	 */
    public static void processContactsForUserDeactivation(Map<Id, Contact> newContactMap, Map<Id, Contact> oldContactMap) {
    	System.debug('*** processContactsForUserDeactivation: newContactMap :' + newContactMap) ;
    	System.debug('*** processContactsForUserDeactivation: oldContactMap :' + oldContactMap) ;
    	Map<Id, Contact> contactsToDeactivateMap = new Map<Id, Contact>() ;
    	Set<String> householdToDeactivateSet = new Set<String>() ;
    	for(Contact c: newContactMap.values()) {
    		if((c.Membership_Status__c != oldContactMap.get(c.Id).Membership_Status__c) && (c.Membership_Status__c == 'Resigned')) {
		    	System.debug('*** processContactsForUserDeactivation: c.HouseholdID__c :' + c.HouseholdID__c) ;
    			contactsToDeactivateMap.put(c.Id, c) ;
    			if(c.HouseholdID__c != null) {
    				householdToDeactivateSet.add(c.HouseholdID__c) ;
    			}
    		}
    	}
    	System.debug('*** processContactsForUserDeactivation: contactsToDeactivateMap :' + contactsToDeactivateMap) ;
    	if(!contactsToDeactivateMap.isEmpty()) {
	    	Map<Id, User> usersToDeactivateMap = new Map<Id, User>([
	    		SELECT
	    			IsActive,
	    			UserName
	    		FROM User
	    		WHERE ContactId IN :contactsToDeactivateMap.keySet()
	    	]) ;
	    	System.debug('*** processContactsForUserDeactivation: usersToDeactivateList :' + usersToDeactivateMap) ;
	    	if(usersToDeactivateMap != null && !usersToDeactivateMap.isEmpty()) {
	    		processRecords(new List<Id>(usersToDeactivateMap.keySet()));
	    	}
    	}
    	if(!householdToDeactivateSet.isEmpty()) {
    		List<Relationship__c> relationshipToDeactivateList = new List<Relationship__c>() ;
    		List<Contact> spouseToDeactivateList = new List<Contact>() ;

    		List<Relationship__c> relationshipList = [
    				SELECT
    					Account__c,
    					Contact__c,
    					Contact__r.Portal_Access_Level__c,
    					Relationship_Type__c,
    					Is_Active__c
    				FROM Relationship__c
    				WHERE Account__c IN :householdToDeactivateSet
    			] ;
    		for(Relationship__c r: relationshipList) {
    			if(r.Relationship_Type__c == 'Spouse/Partner') {
    				r.Is_Active__c = false ;
    				relationshipToDeactivateList.add(r) ;
    				r.Contact__r.Portal_Access_Level__c = 'None' ;
    				spouseToDeactivateList.add(r.Contact__r) ;
    			}
    		}
    		if(!relationshipToDeactivateList.isEmpty()) {
    			update relationshipToDeactivateList ;
    		}
    		if(!spouseToDeactivateList.isEmpty()) {
    			update spouseToDeactivateList ;
    		}
    	}
    }

	@future
    public static void processRecords(List<ID> recordIds) {  
        // Get those records based on the IDs
        List<User> users = [SELECT Name FROM User WHERE Id IN :recordIds];
    	for(User u: users) {
    		u.IsActive = false ;
    	}
    	System.debug('*** processContactsForUserDeactivation: after usersToDeactivateList if') ;
    	System.debug('*** processContactsForUserDeactivation: usersToDeactivateList2 :' + users) ;
    	update users ;
        // Process records
    }


    // relatonships object between contact of record type member and an householdID of type household.
    // Contact has a field Household Id. Account Id. Just check the household id and then do the relationships.
    // Grab the relationship and deactivate them. Is_Active__c = false Relationship type = 'Spouse/Partner'
    // on the spouse record need to update the field Portal_Access_Level__c set to 'None'.


}