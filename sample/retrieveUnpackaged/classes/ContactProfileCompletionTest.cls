@isTest
private class ContactProfileCompletionTest  {

	@TestSetup static void setup(){
		insert new Profile_Completion_Criteria__c(Name = 'Initial Criteria', Primary_Address__c = 1, Business_Phone__c = 1, Mobile_Phone__c = 1, Primary_Email__c = 1, Biography__c = 1, Profile_Picture_Upload__c = 1, Social_Media__c = 1);
		
		Account testAccount = new Account(Name = 'Test Account', Type = 'Chapter');
		insert testAccount;

		Contact testContact = new Contact(LastName = 'Test Name', AccountId = testAccount.id);
		insert testContact;	
	}

	@IsTest
	private  static void newContact(){
		Account testAccount = [Select Id From Account where Name = 'Test Account'];

		Contact testContact = new Contact();
		testContact.LastName = 'Test Name';
		testContact.AccountId = testAccount.id;
		testContact.MailingStreet = '123 1st';
		testContact.Is_Address1_Primary__c = true;
		testContact.Phone = '5555555555';
		testContact.MobilePhone = '1111111111';
		testContact.Email = 'test@test.com';
		testContact.Biography__c = 'Something';
		testContact.Profile_Picture_Uploaded__c = true;
		testContact.Skype__c = 'username';

		insert testContact;
		
		Contact_Profile_Completion__c contProfile = [Select Primary_Address__c, Business_Phone__c, Mobile_Phone__c, Primary_Email__c, Biography__c, Profile_Picture_Upload__c, Social_Media__c From Contact_Profile_Completion__c Where Contact__c =: testContact.Id];
		System.assertEquals(100, contProfile.Primary_Address__c);
		System.assertEquals(100, contProfile.Business_Phone__c);	
		System.assertEquals(100, contProfile.Mobile_Phone__c);	
		System.assertEquals(100, contProfile.Primary_Email__c);
		System.assertEquals(100, contProfile.Biography__c);					
		System.assertEquals(100, contProfile.Profile_Picture_Upload__c);
		System.assertEquals(100, contProfile.Social_Media__c);				
	}

	@IsTest
	private static void newContactProfileInformation(){
		Contact cont = [Select ID from Contact where lastname = 'Test Name' limit 1];
		
		cont.MailingStreet = '123 1st';
		cont.Is_Address1_Primary__c = true;
		cont.Phone = '5555555555';
		cont.MobilePhone = '1111111111';
		cont.Email = 'test@test.com';
		cont.Biography__c = 'Something';
		cont.Profile_Picture_Uploaded__c = true;
		cont.Skype__c = 'username';
		update cont;

		Contact_Profile_Completion__c contProfile = [Select Primary_Address__c, Business_Phone__c, Mobile_Phone__c, Primary_Email__c, Biography__c, Profile_Picture_Upload__c, Social_Media__c From Contact_Profile_Completion__c Where Contact__c =: cont.Id];
		System.assertEquals(100, contProfile.Primary_Address__c);
		System.assertEquals(100, contProfile.Business_Phone__c);	
		System.assertEquals(100, contProfile.Mobile_Phone__c);	
		System.assertEquals(100, contProfile.Primary_Email__c);
		System.assertEquals(100, contProfile.Biography__c);					
		System.assertEquals(100, contProfile.Profile_Picture_Upload__c);
		System.assertEquals(100, contProfile.Social_Media__c);			
	}

	@IsTest
	private static void updateContactProfileInformation(){
		Contact cont = [Select ID from Contact where lastname = 'Test Name' limit 1];
		
		cont.MailingStreet = '123 1st';
		cont.Is_Address1_Primary__c = true;
		cont.Phone = '5555555555';
		cont.MobilePhone = '1111111111';
		cont.Email = 'test@test.com';
		cont.Biography__c = 'Something';
		cont.Profile_Picture_Uploaded__c = true;
		cont.Skype__c = 'username';
		update cont;

		cont.MailingStreet = null;
		cont.Is_Address1_Primary__c = false;
		cont.Phone = null;
		cont.MobilePhone = null;
		cont.Email = null;
		cont.Biography__c = null;
		cont.Profile_Picture_Uploaded__c = false;
		cont.Skype__c = null;
		update cont;

		Contact_Profile_Completion__c contProfile = [Select Primary_Address__c, Business_Phone__c, Mobile_Phone__c, Primary_Email__c, Biography__c, Profile_Picture_Upload__c, Social_Media__c From Contact_Profile_Completion__c Where Contact__c =: cont.Id];
		System.assertEquals(0, contProfile.Primary_Address__c);	
		System.assertEquals(0, contProfile.Mobile_Phone__c);	
		System.assertEquals(0, contProfile.Primary_Email__c);
		System.assertEquals(0, contProfile.Biography__c);					
		System.assertEquals(0, contProfile.Profile_Picture_Upload__c);
		System.assertEquals(0, contProfile.Social_Media__c);		
	}

	@isTest
	private static void toggleUpdate(){
		Account testAccount = [Select Id From Account where Name = 'Test Account'];

		Contact testContact = new Contact();
		testContact.LastName = 'Test Name';
		testContact.AccountId = testAccount.id;
		testContact.MailingStreet = '123 1st';
		testContact.Is_Address1_Primary__c = true;
		testContact.Phone = '5555555555';
		testContact.MobilePhone = '1111111111';
		testContact.Email = 'test@test.com';
		testContact.Biography__c = 'Something';
		testContact.Profile_Picture_Uploaded__c = true;
		testContact.Skype__c = 'username';

		insert testContact;
		
		Contact_Profile_Completion__c contProfile = [Select Primary_Address__c, Business_Phone__c, Mobile_Phone__c, Primary_Email__c, Biography__c, Profile_Picture_Upload__c, Social_Media__c From Contact_Profile_Completion__c Where Contact__c =: testContact.Id];

		contProfile.Primary_Address__c = 0;
		contProfile.Business_Phone__c = 0;
		contProfile.Mobile_Phone__c = 0;
		contProfile.Primary_Email__c = 0;
		contProfile.Biography__c = 0;
		contProfile.Profile_Picture_Upload__c = 0;
		contProfile.Social_Media__c = 0;

		update contProfile;

		testContact.Biography_Enntered__c = true;

		update testContact;

		contProfile = [Select Primary_Address__c, Business_Phone__c, Mobile_Phone__c, Primary_Email__c, Biography__c, Profile_Picture_Upload__c, Social_Media__c From Contact_Profile_Completion__c Where Contact__c =: testContact.Id];

		System.assertEquals(100, contProfile.Primary_Address__c);
		System.assertEquals(100, contProfile.Business_Phone__c);	
		System.assertEquals(100, contProfile.Mobile_Phone__c);	
		System.assertEquals(100, contProfile.Primary_Email__c);
		System.assertEquals(100, contProfile.Biography__c);					
		System.assertEquals(100, contProfile.Profile_Picture_Upload__c);
		System.assertEquals(100, contProfile.Social_Media__c);		
	}
}