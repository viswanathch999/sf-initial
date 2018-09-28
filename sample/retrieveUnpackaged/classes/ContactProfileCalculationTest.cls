@isTest
public class ContactProfileCalculationTest {
    @isTest static void profilePercentage(){
        Map<Id, String> updatedCriteria = new Map<Id, String>();
        
		insert new Profile_Completion_Criteria__c(Name = 'Test Criteria', Primary_Address__c = 1, Biography__c = 1, Business_Phone__c = 1, Mobile_Phone__c = 1,
                                                 	Primary_Email__c = 1, Profile_Picture_Upload__c = 1, Social_Media__c = 1);
        
        Account testAccount = new Account(Name = 'Test Account', Type = 'Chapter');
		insert testAccount;

		Contact testContact = new Contact(LastName = 'Test Name', MailingStreet = 'Some Street', Is_Address1_Primary__c = true, Phone = '5555555555',
                                          MobilePhone = '1111111111', Email = 'test@test.com', Biography__c = 'test bio', Profile_Picture_uploaded__c = true,
                                          Skype__c = 'someUsername', AccountId = testAccount.id);
		insert testContact;
       
        testContact.Is_Address1_Primary__c = false;
        testContact.Phone = null;
        testContact.MobilePhone = null;
        testContact.Email = null;
        testContact.Biography__c = null;
        testContact.Profile_Picture_uploaded__c = false;
        testContact.Skype__c = null;
        
        update testContact;
    }
}