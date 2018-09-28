@isTest
private class ContactProfileCheckTest  {

	@TestSetup static void setup(){
		insert new Profile_Completion_Criteria__c(Name = 'Initial Criteria', Primary_Address__c = 1, Business_Phone__c = 1, Mobile_Phone__c = 1, Primary_Email__c = 1, 
												  Biography__c = 1, Profile_Picture_Upload__c = 1, Social_Media__c = 1);
		
		Account testAccount = new Account(Name = 'Test Account', Type = 'Chapter');
		insert testAccount;

		insert new Contact(LastName = 'Test Name', AccountId = testAccount.id);
	}

	@IsTest
	private  static void newContact(){
		Account testAccount = [Select Id From Account where Name = 'Test Account' LIMIT 1];

		Contact testContact = new Contact();
		testContact.LastName = 'Test Name';
		testContact.AccountId = testAccount.id;

		testContact.MailingStreet = '123 1st';
		testContact.MailingCity = 'Somewhere';
		testContact.MailingCountry = 'United States';
		testContact.MailingState = 'Texas';
		testContact.MailingPostalCode = '11111';
		testContact.Is_Address1_Primary__c = true;
		
		testContact.Phone = '5555555555';
		testContact.MobilePhone = '1111111111';
		testContact.Email = 'test@test.com';
		testContact.Biography__c = 'Something';
		testContact.Profile_Picture_Uploaded__c = true;
		testContact.Skype__c = 'username';

		insert testContact;

		Contact_Profile_Completion__c contProfile = [Select Primary_Address__c, Business_Phone__c, Mobile_Phone__c, Primary_Email__c, Biography__c, Profile_Picture_Upload__c, Social_Media__c 
														From Contact_Profile_Completion__c Where Contact__c =: testContact.Id];
		
		System.assertEquals(100, contProfile.Primary_Address__c, 'Primary Address Didn\'t Update to 100%');
		System.assertEquals(100, contProfile.Business_Phone__c, 'Business Phone Didn\'t Update to 100%');	
		System.assertEquals(100, contProfile.Mobile_Phone__c, 'Mobile Phone Didn\'t Update to 100%');	
		System.assertEquals(100, contProfile.Primary_Email__c, 'Primary Email Didn\'t Update to 100%');
		System.assertEquals(100, contProfile.Biography__c, 'Biography__c Didn\'t Update to 100%');					
		System.assertEquals(100, contProfile.Profile_Picture_Upload__c, 'Primary Address Didn\'t Update to 100%');
		System.assertEquals(100, contProfile.Social_Media__c, 'Social Media Didn\'t Update to 100%');				
	}

	@IsTest
	private static void newContactProfileInformation(){
		Contact testContact = [Select ID from Contact where lastname = 'Test Name' LIMIT 1];

		Contact_Profile_Completion__c contProfile = [Select Primary_Address__c, Business_Phone__c, Mobile_Phone__c, Primary_Email__c, Biography__c, Profile_Picture_Upload__c, Social_Media__c From Contact_Profile_Completion__c Where Contact__c =: testContact.Id];
		
		System.assertEquals(0, contProfile.Primary_Address__c, 'Primary Address isn\'t defaulted to 0%');
		System.assertEquals(0, contProfile.Business_Phone__c, 'Business Phone isn\'t defaulted to 0%');	
		System.assertEquals(0, contProfile.Mobile_Phone__c, 'Mobile Phone isn\'t defaulted to 0%');	
		System.assertEquals(0, contProfile.Primary_Email__c, 'Primary Email isn\'t defaulted to 0%');
		System.assertEquals(0, contProfile.Biography__c, 'Biography__c isn\'t defaulted to 0%');					
		System.assertEquals(0, contProfile.Profile_Picture_Upload__c, 'Profile Picture Upload isn\'t defaulted to 0%');
		System.assertEquals(0, contProfile.Social_Media__c, 'Social Media isn\'t defaulted to 0%');	        

		testContact.MailingStreet = '123 1st';
		testContact.MailingCity = 'Somewhere';
		testContact.MailingCountry = 'United States';
		testContact.MailingState = 'Texas';
		testContact.MailingPostalCode = '11111';
		testContact.Is_Address1_Primary__c = true;
		
		testContact.Phone = '5555555555';
		testContact.MobilePhone = '1111111111';
		testContact.Email = 'test@test.com';
		testContact.Biography__c = 'Something';
		testContact.Profile_Picture_Uploaded__c = true;
		testContact.Skype__c = 'username';
		
		update testContact;

		contProfile = [Select Primary_Address__c, Business_Phone__c, Mobile_Phone__c, Primary_Email__c, Biography__c, Profile_Picture_Upload__c, Social_Media__c From Contact_Profile_Completion__c Where Contact__c =: testContact.Id];
		System.assertEquals(100, contProfile.Primary_Address__c, 'Primary Address didn\'t update to 100%');
		System.assertEquals(100, contProfile.Business_Phone__c, 'Business Phone didn\'t update to 100%');	
		System.assertEquals(100, contProfile.Mobile_Phone__c, 'Mobile Phone didn\'t update to 100%');	
		System.assertEquals(100, contProfile.Primary_Email__c, 'Primary Email didn\'t update to 100%');
		System.assertEquals(100, contProfile.Biography__c, 'Biography didn\'t update to 100%');					
		System.assertEquals(100, contProfile.Profile_Picture_Upload__c, 'Profile Picture Upload didn\'t update to 100%');
		System.assertEquals(100, contProfile.Social_Media__c, 'Social Media didn\'t update to 100%');			
	}

	@IsTest
	private static void updateContactProfileInformation(){
		Contact testContact = [Select ID from Contact where lastname = 'Test Name' LIMIT 1];
		
		testContact.MailingStreet = '123 1st';
		testContact.MailingCity = 'Somewhere';
		testContact.MailingCountry = 'United States';
		testContact.MailingState = 'Texas';
		testContact.MailingPostalCode = '11111';
		testContact.Is_Address1_Primary__c = true;
		
		testContact.Phone = '5555555555';
		testContact.MobilePhone = '1111111111';
		testContact.Email = 'test@test.com';
		testContact.Biography__c = 'Something';
		testContact.Profile_Picture_Uploaded__c = true;
		testContact.Skype__c = 'username';
		update testContact;

		Contact_Profile_Completion__c contProfile = [Select Primary_Address__c, Business_Phone__c, Mobile_Phone__c, Primary_Email__c, Biography__c, Profile_Picture_Upload__c, Social_Media__c From Contact_Profile_Completion__c Where Contact__c =: testContact.Id];
		System.assertEquals(100, contProfile.Primary_Address__c, 'Primary Address didn\'t update to 100%');
		System.assertEquals(100, contProfile.Business_Phone__c, 'Business Phone didn\'t update to 100%');	
		System.assertEquals(100, contProfile.Mobile_Phone__c, 'Mobile Phone didn\'t update to 100%');	
		System.assertEquals(100, contProfile.Primary_Email__c, 'Primary Email didn\'t update to 100%');
		System.assertEquals(100, contProfile.Biography__c, 'Biography didn\'t update to 100%');					
		System.assertEquals(100, contProfile.Profile_Picture_Upload__c, 'Profile Picture Upload didn\'t update to 100%');
		System.assertEquals(100, contProfile.Social_Media__c, 'Social Media didn\'t update to 100%');        
		
		testContact.MailingStreet = null;
		testContact.Is_Address1_Primary__c = false;
		testContact.Phone = null;
		testContact.MobilePhone = null;
		testContact.Email = null;
		testContact.Biography__c = null;
		testContact.Profile_Picture_Uploaded__c = false;
		testContact.Skype__c = null;
		update testContact;

		contProfile = [Select Primary_Address__c, Business_Phone__c, Mobile_Phone__c, Primary_Email__c, Biography__c, Profile_Picture_Upload__c, Social_Media__c From Contact_Profile_Completion__c Where Contact__c =: testContact.Id];
		System.assertEquals(0, contProfile.Primary_Address__c, 'Primary Address didn\'t update to 0%');	
		System.assertEquals(0, contProfile.Mobile_Phone__c, 'Mobile Phone didn\'t update to 0%');	
		System.assertEquals(0, contProfile.Primary_Email__c, 'Primary Email didn\'t update to 0%');
		System.assertEquals(0, contProfile.Biography__c, 'Biography__c didn\'t update to 0%');					
		System.assertEquals(0, contProfile.Profile_Picture_Upload__c, 'Profile Picture Upload didn\'t update to 0%');
		System.assertEquals(0, contProfile.Social_Media__c, 'Social Media didn\'t update to 0%');		
	}

	@isTest
	private static void toggleUpdate(){
		Account testAccount = [Select Id From Account where Name = 'Test Account' LIMIT 1];

		Contact testContact = new Contact();
		testContact.LastName = 'Test Name';
		testContact.AccountId = testAccount.id;

		testContact.MailingStreet = '123 1st';
		testContact.MailingCity = 'Somewhere';
		testContact.MailingCountry = 'United States';
		testContact.MailingState = 'Texas';
		testContact.MailingPostalCode = '11111';
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

		System.assertEquals(100, contProfile.Primary_Address__c, 'Primary Address didn\'t update to 100%');
		System.assertEquals(100, contProfile.Business_Phone__c, 'Business Phone didn\'t update to 100%');	
		System.assertEquals(100, contProfile.Mobile_Phone__c, 'Mobile Phone didn\'t update to 100%');	
		System.assertEquals(100, contProfile.Primary_Email__c, 'Primary Email didn\'t update to 100%');
		System.assertEquals(100, contProfile.Biography__c, 'Biography didn\'t update to 100%');					
		System.assertEquals(100, contProfile.Profile_Picture_Upload__c, 'Profile Picture Upload didn\'t update to 100%');
		System.assertEquals(100, contProfile.Social_Media__c, 'Social Media didn\'t update to 100%');   	
	}
}