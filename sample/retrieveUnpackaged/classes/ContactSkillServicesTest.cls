@isTest 
private class ContactSkillServicesTest {

	@isTest
	private static void testGuid() {
        insert new Profile_Completion_Criteria__c(Name = 'Test Criteria', Primary_Address__c = 1, External_Connection__c = 1);
        
		Account testAccount = new Account(Name = 'Test Account', Type = 'Chapter');
		insert testAccount;

		Contact testContact = new Contact(LastName = 'Test Name', AccountId = testAccount.id);
		insert testContact;
        
		Contact_Skill_Option__c cso = new Contact_Skill_Option__c(
			Theme_Contact_Skill_Option__c = Contact_Skill_Option__c.Theme_Contact_Skill_Option__c.getDescribe().getPicklistValues()[0].getValue(),
			Category_Contact_Skill_Option__c = Contact_Skill_Option__c.Category_Contact_Skill_Option__c.getDescribe().getPicklistValues()[0].getValue(),
			Active_Contact_Skill_Option__c = true);
		insert cso;
        
		Contact_Skill__c cs = new Contact_Skill__c(
			Type_Contact_Skill__c = Contact_Skill__c.Type_Contact_Skill__c.getDescribe().getPicklistValues()[0].getValue(),
			Contact_Skill_Option_ID__c = cso.Id,
			Active_Contact_Skill__c = true,
        	Contact_on_Contact_Skill__c = testContact.Id);
        
		insert cs;
        
		Contact_Skill__c csInterest = new Contact_Skill__c(
			Type_Contact_Skill__c = 'Interest',
			Contact_Skill_Option_ID__c = cso.Id,
			Active_Contact_Skill__c = true,
        	Contact_on_Contact_Skill__c = testContact.Id);
        
		insert csInterest;		
        
        csInterest.Adhoc_Sub_Category__c = 'test';
        update csInterest;
        
        Contact_Skill__c csExpertise = new Contact_Skill__c(
			Type_Contact_Skill__c = 'Expertise',
			Contact_Skill_Option_ID__c = cso.Id,
			Active_Contact_Skill__c = true,
        	Contact_on_Contact_Skill__c = testContact.Id);
        
		insert csExpertise;

        csExpertise.Adhoc_Sub_Category__c = 'test';
        update csExpertise;        

		System.assert(!String.isBlank([SELECT GUID__c FROM Contact_Skill__c WHERE Id = :cs.Id LIMIT 1].GUID__c), 'GUID should be generated on save');
		System.assert(!String.isBlank([SELECT GUID__c FROM Contact_Skill_Option__c WHERE Id = :cso.Id LIMIT 1].GUID__c), 'GUID should be generated on save');
        
        //delete csInterest;
        //delete csExpertise; 
	}
}