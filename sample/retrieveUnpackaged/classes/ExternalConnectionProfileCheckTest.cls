@isTest
private class ExternalConnectionProfileCheckTest {
	
	@TestSetup static void setup() {
		insert new Profile_Completion_Criteria__c(Name = 'Initial Criteria', External_Connection__c = 1);

		Account testAccount = new Account(Name = 'Test Account', Type = 'Chapter');
		insert testAccount;

		insert new Contact(LastName = 'Test Name', AccountId = testAccount.id);

		External_Connection__c extCon = new External_Connection__c();
		extCon.RecordTypeId = [Select ID FROM RecordType where DeveloperName = 'Video' and SobjectType = 'External_Connection__c'].Id;
		extCon.Name = 'Test Connection';
		insert extCon;
	}

	@IsTest
	private static void newExternalConnection(){
		Contact testContact = [Select Id From Contact where LastName = 'Test Name' LIMIT 1];

		External_Connection__c extCon = [Select Id FROM External_Connection__c WHERE Name = 'Test Connection'];

		insert new Contact_External_Connection__c(Type__c = 'Video', Contact__c = testContact.id, External_Connection__c = extCon.id, Active_ContactExternalConnection__c = true);

		Contact_Profile_Completion__c contProfile = [Select External_Connection__c From Contact_Profile_Completion__c Where Contact__c =: testContact.Id];
		
		System.assertEquals(100, contProfile.External_Connection__c, 'External Connection didn\'t update to 100%');		
	}


	@IsTest
	private static void multipleExternalConnections(){
		Contact testContact = [Select Id From Contact where LastName = 'Test Name' LIMIT 1];

		External_Connection__c extCon = [Select Id FROM External_Connection__c WHERE Name = 'Test Connection'];

		insert new Contact_External_Connection__c(Type__c = 'Video', Contact__c = testContact.id, External_Connection__c = extCon.id);

		List<Contact_External_Connection__c> contExternalConnectionList = new List<Contact_External_Connection__c>();
		contExternalConnectionList.add(new Contact_External_Connection__c(Type__c = 'Video', Contact__c = testContact.id, External_Connection__c = extCon.id, Active_ContactExternalConnection__c = true));
		contExternalConnectionList.add(new Contact_External_Connection__c(Type__c = 'Video', Contact__c = testContact.id, External_Connection__c = extCon.id, Active_ContactExternalConnection__c = true));
		contExternalConnectionList.add(new Contact_External_Connection__c(Type__c = 'Video', Contact__c = testContact.id, External_Connection__c = extCon.id, Active_ContactExternalConnection__c = true));

		insert contExternalConnectionList;

		Contact_Profile_Completion__c contProfile = [Select External_Connection__c From Contact_Profile_Completion__c Where Contact__c =: testContact.Id];
		
		System.assertEquals(100, contProfile.External_Connection__c, 'External Connection didn\'t stay at 100%');			
	}	
}