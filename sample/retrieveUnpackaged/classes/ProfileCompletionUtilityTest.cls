@isTest
public class ProfileCompletionUtilityTest  {

	@TestSetup static void setup(){
		insert new Profile_Completion_Criteria__c(Name = 'Initial Criteria', Biography__c = 1);
		
		Account testAccount = new Account(Name = 'Test Account', Type = 'Chapter');
		insert testAccount;

		Contact testContact = new Contact(LastName = 'Test Name', AccountId = testAccount.id);
		insert testContact;
	}
	
	@IsTest
	private static void newCompletionPercentage(){
		Map<Id, String> updatedCriteria = new Map<Id, String>();
		Contact cont = [Select ID from Contact where lastname = 'Test Name' limit 1];

		Profile_Completion_Criteria__c profileCompletion = new Profile_Completion_Criteria__c();
		profileCompletion.Biography__c = 1;

		String jsonCompletionPercentage = JSON.serialize(profileCompletion);
		updatedCriteria.put(cont.Id, jsonCompletionPercentage);
		
		ProfileCompletionUtility.ProfileCompletionUtility(updatedCriteria);

		System.assertEquals(100, [Select Biography__c From Contact_Profile_Completion__c Where Contact__c =: cont.Id].Biography__c);
	}

	@isTest
	private static void updateCompletionPercentage(){
		Map<Id, String> updatedCriteria = new Map<Id, String>();
		Contact cont = [Select ID from Contact where lastname = 'Test Name' limit 1];

		Contact_Profile_Completion__c oldPercentage = new Contact_Profile_Completion__c(Contact__c = cont.Id, Biography__c = 100);
		insert oldPercentage;

		Profile_Completion_Criteria__c profileCompletion = new Profile_Completion_Criteria__c();
		profileCompletion.Biography__c = 0;

		String jsonCompletionPercentage = JSON.serialize(profileCompletion);

		updatedCriteria.put(cont.Id, jsonCompletionPercentage);

		ProfileCompletionUtility.ProfileCompletionUtility(updatedCriteria);	
	}
}