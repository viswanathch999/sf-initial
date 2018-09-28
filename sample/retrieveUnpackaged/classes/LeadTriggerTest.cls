@isTest
private class LeadTriggerTest {
	
	static final String CONST_PARTNER_USER = Label.Partner_User_Custom;
	static final String CONST_CHAPTER = 'Chapter';
	static final String CONST_ACCOUNT = 'Account';
	
	static final String STATUS_NEW = 'New';
	static final String STATUS_NOT_PURSUE = 'Will not pursue';
	static final String ACCESS_EDIT = 'Edit';
	static final String ACCESS_NONE = 'None';
	static final Integer DEFAULT_NUMBER = 1;
	static final List<String> SAMPLE_COUNTRIES = new List<String>{
		'Algeria',
			LeadServices.CONST_US_COUNTRY
			};
	static User adminUser;
	static User adminUser2;
	static User adminUser3;

	@testSetup static void setup(){
		//setupGeoRequirements();
		Id chapterAcctRType = RecordTypeServices.getRecordTypeByDeveloperName('Chapter', 'Account').id;
		Id profileId = [SELECT id FROM Profile WHERE Name =: 'QA Access'].id;
		
		Id prospectContRType = RecordTypeServices.getRecordTypeByDeveloperName('Prospect', 'Contact').id;
		
		List<Contact> newContacts = new List<Contact>();

		Account chapter = TestServices.createAccount('Test-Account1');
		chapter.RecordTypeId = chapterAcctRType;
		chapter.Type = 'Chapter';
		chapter.Status__c = 'Active';

		Account chapter2 = TestServices.createAccount('Test-Account1');
		chapter2.RecordTypeId = chapterAcctRType;
		chapter2.Type = 'Chapter';
		chapter2.Status__c = 'Active';

		insert new List<Account> {chapter,chapter2};

		//Contact oContact1 = TestServices.createContact(chapter.id, prospectContRType, false);
		//oContact1.Active__c = false; //to prevent auto creation of customer community user in contact trigger
		//newContacts.add(oContact1);
		
		//Contact oContact3 = TestServices.createContact(chapter.id, prospectContRType, false);
		//oContact3.Active__c = false; //to prevent auto creation of customer community user in contact trigger
		//newContacts.add(oContact3);

		
		//Contact oContact2 = TestServices.createContact(chapter.id, prospectContRType, false);
		//oContact2.Active__c = false;//to prevent auto creation of customer community user in contact trigger
		//newContacts.add(oContact2);

		//insert newContacts;
		
		List<User> newUsers = new List<User>();

		//adminUser = TestServices.createPartnerCommunityUser(null, profileId);
		//newUsers.add(adminUser);
		//adminUser3 = TestServices.createPartnerCommunityUser(null, profileId);
		//newUsers.add(adminUser3);
		//adminUser2 = TestServices.createPartnerCommunityUser(null, profileId);

		for(integer x = 0; x <= 3; x++){
			newUsers.add(new User(
						Profileid=profileId,
						Email='Test'+x+'@YPOTEST.org',
						Username= 'Test'+x+'@YPOTEST.org',
						Alias= 'Test'+x,
						CommunityNickName='userCom1' + x,
						TimeZoneSidKey='America/New_York', 
						LocaleSidKey='en_US', 
						EmailEncodingKey='ISO-8859-1',
						LanguageLocaleKey='en_US', 
						FirstName='TestUser1', 
						LastName='User1',
						IsActive = true ));
		}

		

		insert newUsers;
		
		Lead_and_Contact_Sharing_CA_Roles__c leadContSharingRole = new Lead_and_Contact_Sharing_CA_Roles__c();
		leadContSharingRole.Name = 'Chapter Administrator';
		insert leadContSharingRole;
		
		List<CA_Setting__c> newCASettings = new List<CA_Setting__c>();

		newCASettings.add(TestServices.createCASetting(chapter.id, newUsers[0].id, true, false));
		newCASettings.add(TestServices.createCASetting(chapter.id, newUsers[1].id, true, false));
		newCASettings.add(TestServices.createCASetting(chapter2.id, newUsers[2].id, true, false));

		insert newCASettings;

		List<Lead_Share_Settings__c> leadShareSettings = new List<Lead_Share_Settings__c>();

		leadShareSettings.add(TestServices.createLead_Share_Settings(STATUS_NEW, ACCESS_EDIT, false));
		leadShareSettings.add(TestServices.createLead_Share_Settings(STATUS_NOT_PURSUE, ACCESS_NONE, false));

		insert leadShareSettings;
	}

	static testMethod void givenCASettings_WhenLeadIsInserted_thenLeadShareRecordsUpdated() {
		Account acct = [Select ID FROM Account LIMIT 1];

		List<User> adminUsers = [Select ID from User Where LastName =  'User1' LIMIT 3];

		System.assert(adminUsers.size() == 3);
		
		Lead testLead = TestServices.createLead('Test Lead', STATUS_NEW, acct.Id, false);
		testLead.Country = SAMPLE_COUNTRIES[0];
		testLead.State = '';
		Test.startTest();
		insert testLead;
		Test.stopTest();

  
		List<LeadShare> insertedShares = [Select Id from LeadShare where leadId =: testLead.id and 
											UserOrGroupId IN :adminUsers and LeadAccessLevel =: ACCESS_EDIT];

		System.assert(insertedShares.size() > 0, 'Lead share record with edit access should be created for chapter admin');

	}

	static List<Geographic_Requirements__c> setupGeoRequirements() {
		List<Geographic_Requirements__c> testGeoReqs = new List<Geographic_Requirements__c>();
		Integer i = 0;
		for(String country : SAMPLE_COUNTRIES) {
			testGeoReqs.add(new Geographic_Requirements__c(
				Country__c = country,
				Annual_Assets__c = DEFAULT_NUMBER + i,
				Annual_Fees__c = DEFAULT_NUMBER + i,
				Annual_Revenue__c = DEFAULT_NUMBER + i,
				Enterprise_Value__c = DEFAULT_NUMBER + i,
				Number_of_Employees_Opt_1__c = DEFAULT_NUMBER + i,
				Number_of_Employees_Opt_2__c = DEFAULT_NUMBER + i,
				Total_Employee_Compensation_Opt_1__c = DEFAULT_NUMBER + i,
				Total_Employee_Compensation_Opt_2__c = DEFAULT_NUMBER + i,
				Start_Date__c = Date.today(),
				End_Date__c = Date.today().addYears(1)
			));
			i++;
		}
		
		return testGeoReqs;
	}
	
	static testMethod void givenCASettings_WhenLeadsChapterIsUpdated_thenLeadShareRecordsUpdated() {
		Account acct = [Select ID FROM Account LIMIT 1];
		Account acct2 = [Select ID FROM Account Where id <> :acct.id LIMIT 1];

		Lead testLead = TestServices.createLead('Test Lead', STATUS_NEW, acct.Id, false);
		testLead.Country = SAMPLE_COUNTRIES[0];
		testLead.State = '';
		insert testLead;
		List<LeadShare> insertedShares = [Select Id, leadId, UserOrGroupId, LeadAccessLevel from LeadShare where leadId =: testLead.id and LeadAccessLevel =: ACCESS_EDIT];        
		System.assert(insertedShares.size() > 0, 'Lead share record with edit access should be created for chapter admins');

		Test.startTest();
			testLead.Referred_by_Chapter__c = acct2.id;
			update testLead;
		Test.stopTest();

		List<LeadShare> deletedShares = [Select Id from LeadShare where leadId =: testLead.id and UserOrGroupId = :insertedShares[0].UserOrGroupId and LeadAccessLevel =: ACCESS_EDIT];
		System.assertEquals(0, deletedShares.size(), 'Lead share record with edit access for admin1 should be deleted');
	}

	static testMethod void givenCASettings_WhenLeadsStatusIsUpdated_thenLeadShareRecordsUpdated() {
		Account acct = [Select ID FROM Account LIMIT 1];

		Lead testLead = TestServices.createLead('Test Lead', STATUS_NEW, acct.Id, false);
		testLead.Country = SAMPLE_COUNTRIES[0];
		testLead.State = '';
		insert testLead;
		//List<LeadShare> insertedShares = [Select Id from LeadShare where leadId =: testLead.id and UserOrGroupId =: adminUser.id and LeadAccessLevel =: ACCESS_EDIT];
		//TODO FIX TESTS FOR PROD
		//System.assertEquals(1, insertedShares.size(), 'Lead share record with edit access should be created for chapter admin');
		
		Test.startTest();
		testLead.status = STATUS_NOT_PURSUE;
		update testLead;
		Test.stopTest();
		//List<LeadShare> deletedSharesForAdmin1 = new List<LeadShare>();
		//deletedSharesForAdmin1 = 
			//[Select Id from LeadShare where leadId =: testLead.id and 
			 //UserOrGroupId =: adminUser.id];
		//System.assertEquals(0, deletedSharesForAdmin1.size(), 'Lead share record with edit access for admin1 should be deleted');
	}
	
	
	static testMethod void testLeadGeoSync_Insert()
	{
		List<Geographic_Requirements__c> testGeoReqs = setupGeoRequirements();
		insert testGeoReqs;
		
		Account acct = [Select ID FROM Account LIMIT 1];
		
		List<Lead> testLeads = new List<Lead>();
		for(String country : SAMPLE_COUNTRIES)
		{
			Lead testLead = TestServices.createLead('Test Lead '+country, STATUS_NEW, acct.Id, false);
			testLead.Country = country;
			testLead.State = '';
			testLead.Email = 'test1@abc.com';
			testLeads.add(testLead);
		}
		
		Test.startTest();
		insert testLeads;
		Test.stopTest();
		
		//List<Lead> actualLeads = [SELECT QC_Annual_Assets__c,QC_Annual_Fees__c,QC_Annual_Revenue__c,
								  //QC_Enterprise_Value__c,QC_Number_of_Employees_Opt_1__c,
								  //QC_Number_of_Employees_Opt_2__c,QC_Qualifying_Country__c,
								  //QC_Total_Employee_Compensation_Opt_1__c,QC_Total_Employee_Compensation_Opt_2__c,
								  //Country
								  //FROM Lead
								  //WHERE Id IN : testLeads];
		
		//Map<String,List<Geographic_Requirements__c>> geoReqsMap = GroupBy.strings('Country__c',testGeoReqs);
		//for(Lead testLead : actualLeads)
		//{
			//System.assert(geoReqsMap.containsKey(testLead.Country),'We expect to have a matching Geo Req for this lead');
			//System.assertEquals(geoReqsMap.get(testLead.Country)[0].Annual_Assets__c, testLead.QC_Annual_Assets__c,'We expect these values to be the same');
			//System.assertEquals(geoReqsMap.get(testLead.Country)[0].Annual_Fees__c, testLead.QC_Annual_Fees__c,'We expect these values to be the same');
			//System.assertEquals(geoReqsMap.get(testLead.Country)[0].Annual_Revenue__c, testLead.QC_Annual_Revenue__c,'We expect these values to be the same');
			//System.assertEquals(geoReqsMap.get(testLead.Country)[0].Enterprise_Value__c, testLead.QC_Enterprise_Value__c,'We expect these values to be the same');
			//System.assertEquals(geoReqsMap.get(testLead.Country)[0].Number_of_Employees_Opt_1__c, testLead.QC_Number_of_Employees_Opt_1__c,'We expect these values to be the same');
			//System.assertEquals(geoReqsMap.get(testLead.Country)[0].Number_of_Employees_Opt_2__c, testLead.QC_Number_of_Employees_Opt_2__c,'We expect these values to be the same');
			//System.assertEquals(geoReqsMap.get(testLead.Country)[0].Country__c, testLead.QC_Qualifying_Country__c,'We expect these values to be the same');
			//System.assertEquals(geoReqsMap.get(testLead.Country)[0].Total_Employee_Compensation_Opt_1__c, testLead.QC_Total_Employee_Compensation_Opt_1__c,'We expect these values to be the same');
			//System.assertEquals(geoReqsMap.get(testLead.Country)[0].Total_Employee_Compensation_Opt_2__c, testLead.QC_Total_Employee_Compensation_Opt_2__c,'We expect these values to be the same');
		//}
		
	}
	

	//TODO: Currently Failing Due to a Flow firing on Update
	static testMethod void testLeadGeoSync_Update()
	{
		List<Geographic_Requirements__c> testGeoReqs = setupGeoRequirements();
		insert testGeoReqs;
		
		Account acct = [Select ID FROM Account LIMIT 1];

		
		List<Lead> testLeads = new List<Lead>();
		for(String country : SAMPLE_COUNTRIES)
		{
			Lead testLead = TestServices.createLead('Test Lead '+country, STATUS_NEW, acct.Id, false);
			testLead.Country = country;
			testLead.State = '';
			testLead.Email = 'testLead@abc123.com';
			testLeads.add(testLead);
		}
		insert testLeads;
		
		String newCounty = testLeads[1].Country;
		testLeads[1].Country = testLeads[0].Country;
		testLeads[0].Country = newCounty;
		
		Test.startTest();
		update testLeads;
		Test.stopTest();
		
		List<Lead> actualLeads = [SELECT QC_Annual_Assets__c,QC_Annual_Fees__c,QC_Annual_Revenue__c,
								  QC_Enterprise_Value__c,QC_Number_of_Employees_Opt_1__c,
								  QC_Number_of_Employees_Opt_2__c,QC_Qualifying_Country__c,
								  QC_Total_Employee_Compensation_Opt_1__c,QC_Total_Employee_Compensation_Opt_2__c,
								  Country
								  FROM Lead
								  WHERE Id IN : testLeads];
		
		Map<String,List<Geographic_Requirements__c>> geoReqsMap = GroupBy.strings('Country__c',testGeoReqs);
		for(Lead testLead : actualLeads)
		{
			System.assert(geoReqsMap.containsKey(testLead.Country),'We expect to have a matching Geo Req for this lead');
			System.assertEquals(geoReqsMap.get(testLead.Country)[0].Annual_Assets__c, testLead.QC_Annual_Assets__c,'We expect these values to be the same');
			System.assertEquals(geoReqsMap.get(testLead.Country)[0].Annual_Fees__c, testLead.QC_Annual_Fees__c,'We expect these values to be the same');
			System.assertEquals(geoReqsMap.get(testLead.Country)[0].Annual_Revenue__c, testLead.QC_Annual_Revenue__c,'We expect these values to be the same');
			System.assertEquals(geoReqsMap.get(testLead.Country)[0].Enterprise_Value__c, testLead.QC_Enterprise_Value__c,'We expect these values to be the same');
			System.assertEquals(geoReqsMap.get(testLead.Country)[0].Number_of_Employees_Opt_1__c, testLead.QC_Number_of_Employees_Opt_1__c,'We expect these values to be the same');
			System.assertEquals(geoReqsMap.get(testLead.Country)[0].Number_of_Employees_Opt_2__c, testLead.QC_Number_of_Employees_Opt_2__c,'We expect these values to be the same');
			System.assertEquals(geoReqsMap.get(testLead.Country)[0].Country__c, testLead.QC_Qualifying_Country__c,'We expect these values to be the same');
			System.assertEquals(geoReqsMap.get(testLead.Country)[0].Total_Employee_Compensation_Opt_1__c, testLead.QC_Total_Employee_Compensation_Opt_1__c,'We expect these values to be the same');
			System.assertEquals(geoReqsMap.get(testLead.Country)[0].Total_Employee_Compensation_Opt_2__c, testLead.QC_Total_Employee_Compensation_Opt_2__c,'We expect these values to be the same');
		}
	}
	//TODO: Currently Failing Due to a Flow firing on Update
	static testMethod void testLeadGeoSync_UpdateToNull()
	{
		List<Geographic_Requirements__c> testGeoReqs = setupGeoRequirements();
		insert testGeoReqs;
		
		Account acct = [Select ID FROM Account LIMIT 1];
		
		List<Lead> testLeads = new List<Lead>();
		for(String country : SAMPLE_COUNTRIES)
		{
			Lead testLead = TestServices.createLead('Test Lead '+country, STATUS_NEW, acct.Id, false);
			testLead.Country = country;
			testLead.State = '';
			testLead.Email = 'abc@123.com';
			testLeads.add(testLead);
		}
		insert testLeads;
		
		for(Lead thisLead: testLeads)
		{
			thisLead.Country = null;
		}
		
		Test.startTest();
		update testLeads;
		Test.stopTest();
		
		List<Lead> actualLeads = [SELECT QC_Annual_Assets__c,QC_Annual_Fees__c,QC_Annual_Revenue__c,
								  QC_Enterprise_Value__c,QC_Number_of_Employees_Opt_1__c,
								  QC_Number_of_Employees_Opt_2__c,QC_Qualifying_Country__c,
								  QC_Total_Employee_Compensation_Opt_1__c,QC_Total_Employee_Compensation_Opt_2__c,
								  Country
								  FROM Lead
								  WHERE Id IN : testLeads];
		
		Map<String,List<Geographic_Requirements__c>> geoReqsMap = GroupBy.strings('Country__c',testGeoReqs);
		for(Lead testLead : actualLeads)
		{
			System.assertEquals(geoReqsMap.get(LeadServices.CONST_US_COUNTRY)[0].Annual_Assets__c, testLead.QC_Annual_Assets__c,'We expect these values to be the same');
			System.assertEquals(geoReqsMap.get(LeadServices.CONST_US_COUNTRY)[0].Annual_Fees__c, testLead.QC_Annual_Fees__c,'We expect these values to be the same');
			System.assertEquals(geoReqsMap.get(LeadServices.CONST_US_COUNTRY)[0].Annual_Revenue__c, testLead.QC_Annual_Revenue__c,'We expect these values to be the same');
			System.assertEquals(geoReqsMap.get(LeadServices.CONST_US_COUNTRY)[0].Enterprise_Value__c, testLead.QC_Enterprise_Value__c,'We expect these values to be the same');
			System.assertEquals(geoReqsMap.get(LeadServices.CONST_US_COUNTRY)[0].Number_of_Employees_Opt_1__c, testLead.QC_Number_of_Employees_Opt_1__c,'We expect these values to be the same');
			System.assertEquals(geoReqsMap.get(LeadServices.CONST_US_COUNTRY)[0].Number_of_Employees_Opt_2__c, testLead.QC_Number_of_Employees_Opt_2__c,'We expect these values to be the same');
			System.assertEquals(geoReqsMap.get(LeadServices.CONST_US_COUNTRY)[0].Country__c, testLead.QC_Qualifying_Country__c,'We expect these values to be the same');
			System.assertEquals(geoReqsMap.get(LeadServices.CONST_US_COUNTRY)[0].Total_Employee_Compensation_Opt_1__c, testLead.QC_Total_Employee_Compensation_Opt_1__c,'We expect these values to be the same');
			System.assertEquals(geoReqsMap.get(LeadServices.CONST_US_COUNTRY)[0].Total_Employee_Compensation_Opt_2__c, testLead.QC_Total_Employee_Compensation_Opt_2__c,'We expect these values to be the same');
		
		}
	}

	  @isTest static void LeadChapterInsert(){
		Integer emailCount = System.Limits.getEmailInvocations();

		Account acct = [Select ID FROM Account LIMIT 1];

		Lead testLead = TestServices.createLead('Test Lead', 'Initial Qualifying', acct.Id, false);
		testLead.Pursue_Status__c = 'Pending';
		insert testLead;

		//Lead updatedLead = [Select Chpter_Chair__c, Chapter_Membership_Officer__c, Chapter_Administrator__c, Notify_Prospect_Assigned_to_Chapter_Sent__c from Lead where id = :testLead.id limit 1];

		//System.assertEquals(updatedLead.Chpter_Chair__c, newUsers[0].id, 'Chapter Chair did not get the correct User!');
		//System.assertEquals(updatedLead.Chapter_Administrator__c, newUsers[1].id, 'Chapter Adminstrator did not get the correct User!');
		//System.assertEquals(updatedLead.Chapter_Membership_Officer__c, newUsers[2].id, 'Chapter Adminstrator did not get the correct User!');
		//System.assertEquals(updatedLead.Notify_Prospect_Assigned_to_Chapter_Sent__c, true,  'Checkbox to notify email was sent to Chapter Chair was not set!');

	}

	@isTest static void LeadChapterUpdate(){
		Integer emailCount = System.Limits.getEmailInvocations();

		Account acct = [Select ID FROM Account LIMIT 1];

		List<User> newUsers = new List<User>([Select ID FROM User LIMIT 3]);

		Lead testLead = TestServices.createLead('Test Lead', 'New', null, true);

		Lead updatedLead = [Select Status, Chpter_Chair__c, Chapter_Membership_Officer__c, Chapter_Administrator__c, Notify_Prospect_Assigned_to_Chapter_Sent__c from Lead where id = :testLead.id limit 1];

		System.assertNotEquals(newUsers[0].id, updatedLead.Chpter_Chair__c, 'Chapter Chair was set!');
		System.assertNotEquals(newUsers[1].id, updatedLead.Chapter_Administrator__c, 'Chapter Adminstrator was set!');
		System.assertNotEquals(newUsers[2].id, updatedLead.Chapter_Membership_Officer__c, 'Chapter Adminstrator was set!');
		System.assertNotEquals(true, updatedLead.Notify_Prospect_Assigned_to_Chapter_Sent__c,  'Checkbox to notify email was incorrectly turned to true!');
	
		List<CA_Setting__c> newCASettings = new List<CA_Setting__c>();
		newCASettings.add(TestServices.createCASetting(acct.id, newUsers[0].id, true));
		newCASettings[0].Role__c = CASettingServices.CONST_CHAP_CHAIR;
		newCASettings[0].Chapter__c = acct.id;
		newCASettings.add(TestServices.createCASetting(acct.id, newUsers[1].id, true));
		newCASettings[1].Role__c = CASettingServices.CONST_CHAP_ADMIN;
		newCASettings[1].Chapter__c = acct.id;
		newCASettings.add(TestServices.createCASetting(acct.id, newUsers[2].id, true));
		newCASettings[2].Role__c = CASettingServices.CONST_CHAP_MEM_OFF;
		newCASettings[2].Chapter__c = acct.id;
		insert newCASettings;

		testLead.Pursue_Status__c = 'Pending';
		testLead.Status = 'Initial Qualifying';
		testLead.Referred_by_Chapter__c = acct.Id;
		update testLead;

		//updatedLead = [Select Chpter_Chair__c, Chapter_Membership_Officer__c, Chapter_Administrator__c, Notify_Prospect_Assigned_to_Chapter_Sent__c from Lead where id = :testLead.id limit 1];

		//System.assertEquals(newUsers[0].id, updatedLead.Chpter_Chair__c, 'Chapter Chair did not get the correct User!');
		//System.assertEquals(newUsers[1].id, updatedLead.Chapter_Administrator__c, 'Chapter Adminstrator did not get the correct User!');
		//System.assertEquals(newUsers[2].id, updatedLead.Chapter_Membership_Officer__c, 'Chapter Adminstrator did not get the correct User!');
		//System.assertEquals(true, updatedLead.Notify_Prospect_Assigned_to_Chapter_Sent__c,  'Checkbox to notify email was sent to Chapter Chair was not set!');

	}
	
}