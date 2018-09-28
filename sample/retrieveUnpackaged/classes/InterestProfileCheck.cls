public class InterestProfileCheck implements MyTriggers.Handler {
	Map<Id, SObject> newCollection = new Map<Id, SObject> ();
	Map<Id, SObject> oldCollection = new Map<Id, SObject> ();
    Map<Id, Profile_Completion_Criteria__c> potentialUpdates = new Map<Id, Profile_Completion_Criteria__c>();
	Set<Id> updatedContactSkills = new Set<Id> ();

	Map<Id, String> JSONMap = new Map<Id, String> ();

	public void handle() {
		if (Trigger.isUpdate || Trigger.isDelete) {
			newCollection = Trigger.newMap;
			oldCollection = Trigger.oldMap;
		} else if (Trigger.isInsert) {
			newCollection = Trigger.newMap;
		}
		checkNewRecords();
        checkExstingRecords();
		if (JSONMap.size() > 0) {
			ProfileCompletionUtility.ProfileCompletionUtility(JSONMap);
		}
	}

	private void checkNewRecords() {
		Profile_Completion_Criteria__c updateCompletion;
		if (Trigger.isInsert) {
			for (SObject s : newCollection.values()) {
				updateCompletion = new Profile_Completion_Criteria__c();
				if (s.get('Type_Contact_Skill__c') == 'Interest') {
					updateCompletion.Interests__c = 1;
					updatedContactSkills.add((Id) s.get('Id'));
				}
                
				if (s.get('Type_Contact_Skill__c') == 'Expertise') {
					updateCompletion.Business_Expertise__c = 1;
					updatedContactSkills.add((Id) s.get('Id'));
				}
                
				potentialUpdates.put((Id) s.get('Contact_on_Contact_Skill__c'), updateCompletion);
			}
		} else if(Trigger.isUpdate) {
			for (SObject s : newCollection.values()) {
                System.debug(s);
				updateCompletion = new Profile_Completion_Criteria__c();
				if (s.get('Type_Contact_Skill__c') == 'Interest') {
					updateCompletion.Interests__c = 1;
					updatedContactSkills.add((Id) s.get('Id'));
                }else if(s.get('Type_Contact_Skill__c') != 'Interest' && oldCollection.get((Id) s.get('Id')).get('Type_Contact_Skill__c') == 'Interest'){
 					updateCompletion.Interests__c = 0;
					updatedContactSkills.add((Id) s.get('Id'));                   
                }
                
				if (s.get('Type_Contact_Skill__c') == 'Expertise') {
					updateCompletion.Business_Expertise__c = 1;
					updatedContactSkills.add((Id) s.get('Id'));
                }else if(s.get('Type_Contact_Skill__c') != 'Expertise' && oldCollection.get((Id) s.get('Id')).get('Type_Contact_Skill__c') == 'Expertise'){
 					updateCompletion.Business_Expertise__c = 0;
					updatedContactSkills.add((Id) s.get('Id'));                   
                }
                
				JSONMap.put((Id) s.get('Contact_on_Contact_Skill__c'), JSON.serialize(updateCompletion));
			}
        } else{
 			for (SObject s : oldCollection.values()) {
                System.debug(s);
				updateCompletion = new Profile_Completion_Criteria__c();
				if (oldCollection.get((Id) s.get('Id')).get('Type_Contact_Skill__c') == 'Interest') {
					updateCompletion.Interests__c = 0;
					updatedContactSkills.add((Id) s.get('Id'));
                }
                
				if (oldCollection.get((Id) s.get('Id')).get('Type_Contact_Skill__c') == 'Expertise') {
					updateCompletion.Business_Expertise__c = 0;
					updatedContactSkills.add((Id) s.get('Id'));
                }
                
				potentialUpdates.put((Id) s.get('Contact_on_Contact_Skill__c'), updateCompletion);
			}           
        }
	}
    
    private void checkExstingRecords(){
        for(Contact_skill__c contSkill : [Select Id, Contact_on_Contact_Skill__c from Contact_Skill__c where Contact_On_Contact_Skill__c IN :potentialUpdates.keySet()]){
            System.debug('Potenital Updates: ' + potentialUpdates);
            System.debug('Contact Skill: ' + contSkill);
            if(potentialUpdates.get(contSkill.Contact_On_Contact_Skill__c).Business_Expertise__c == 0){
                potentialUpdates.remove(contSkill.Contact_On_Contact_Skill__c);
            }else{
                JSONMap.put(contSkill.Contact_on_Contact_Skill__c, JSON.serialize(potentialUpdates.get(contSkill.Contact_On_Contact_Skill__c)));
            }
            
            if(potentialUpdates.get(contSkill.Contact_On_Contact_Skill__c).Interests__c == 0){
                potentialUpdates.remove(contSkill.Contact_On_Contact_Skill__c);
            }else{
                JSONMap.put(contSkill.Contact_on_Contact_Skill__c, JSON.serialize(potentialUpdates.get(contSkill.Contact_On_Contact_Skill__c)));
            }            
        }
        
    }
}