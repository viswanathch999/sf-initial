@isTest
public class ContactExternalConTriggerTest {

    @IsTest
	private static void newCompletionPercentage(){
        insert new Profile_Completion_Criteria__c(Name = 'Test Criteria', Primary_Address__c = 1, External_Connection__c = 1);
        
       	Account testAccount = new Account(Name = 'Test Account', Type = 'Chapter');
		insert testAccount;

		Contact testContact = new Contact(LastName = 'Test Name', AccountId = testAccount.id);
		insert testContact;
        
        External_Connection__c externalCon = new External_Connection__c(name = 'test conn');
        insert externalCon;
               
        Contact_External_Connection__c connt = new Contact_External_Connection__c(External_Connection__c = externalCon.Id, Type__c = 'Video', Contact__c = testContact.Id);
        
        insert connt;
        
        delete connt;
    }
}