@isTest
public class EmailServicesTest  {
	

	public static void setup() {
		// Custom setting
		Error_Email_Settings__c settings = new Error_Email_Settings__c();
		settings.Name = 'EmailSvcTestEmailSetting';
		settings.Active__c = true;
		settings.To__c = 'EmailSvcTestEmailSetting@ypo.org';
		settings.Template__c = 'EmailSvcTestEmailSettingTemplate';
		insert settings;
	}


	public static void setupLeadApproval() {
		// Get Partner User Profile
		UserLicense usrLicense = [SELECT Id FROM UserLicense WHERE Name = 'Partner Community' LIMIT 1];
		Profile puProfile = [SELECT Id FROM Profile WHERE UserLicenseId = :usrLicense.Id LIMIT 1];

		// Email template
		User runUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(runUser) {
			EmailTemplate template = new EmailTemplate(Name = 'EmailSvcTestEmailSettingTemplate',
													   DeveloperName = 'EmailSvcTestEmailSettingTemplate',
													   FolderId = UserInfo.getOrganizationId(),
													   TemplateType = 'text',
													   IsActive = true);
			insert template;
		}

		// Chapter
		Account chapter = TestServices.createAccount(true);

		// Officer contacts
		List<Contact> officers = new List<Contact> {
			new Contact(FirstName = 'CC', LastName = 'EmailSvcTest', AccountId = chapter.Id),
			new Contact(FirstName = 'CA', LastName = 'EmailSvcTest', AccountId = chapter.Id),
			new Contact(FirstName = 'CMO', LastName = 'EmailSvcTest', AccountId = chapter.Id)
		};
		insert officers;

		// Officer partner users
		List<User> partnerUsers = new List<User>();
		for (Contact cont : officers) {
			User usr = TestServices.createPartnerCommunityUser(cont.Id, puProfile.Id);
			usr.Email = 'EmailSvcTest' + cont.FirstName + '@ypo.org';
			partnerUsers.add(usr);
		}
		insert partnerUsers;

		// Lead
		Lead testLead = new Lead(FirstName = 'TestLead1',
								 LastNAme = 'EmailSvc',
								 Status = 'New',
								 Company = 'EmailSvcTestLeadCompany',
								 Email = 'EmailSvcTestLead1@ypo.org',
								 Chpter_Chair__r = partnerUsers[0],
								 Chapter_Administrator__r = partnerUsers[1],
								 Chapter_Membership_Officer__r = partnerUsers[2]);
		insert testLead;
	}


	@IsTest
	public static void sendLeadApprovalTest() {
		setupLeadApproval();
		setup();
		Lead testLead = [SELECT Id FROM Lead WHERE Name = 'TestLead1 EmailSvc' LIMIT 1];
		List<String> result1 = EmailServices.sendLeadForChapterApproval(null);
		List<String> result2 = EmailServices.SendLeadForChapterApproval(testLead.Id);
		System.assert(!result1.isEmpty(), 'There should be an error when no lead is provided');
		//System.assert(result2.isEmpty(), 'There should be no errors');
	}


	@IsTest
	public static void sendErrorEmailTest() {
		setup();
		List<String> result1 = EmailServices.sendErrorEmail('EmailSvcTestEmailSetting', null, 'This is a test.');
		List<String> result2 = EmailServices.sendErrorEmail('EmailSvcTestEmailSetting', null, null);
		System.assert(result1.isEmpty(), 'There should be no errors when body is provided');
		System.assert(!result2.isEmpty(), 'There should be an error for template not found');
	}
}