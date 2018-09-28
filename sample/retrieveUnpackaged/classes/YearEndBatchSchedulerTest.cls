@isTest
private class YearEndBatchSchedulerTest
{
	static final Id CONTACT_MEMBER_RECORDTYPE = SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
	static Integer recordCount = 15;
	static Date overdueBirthdate = Date.today().addYears(-52);
	static Date eligibleBirthDate = Date.today().addYears(-46);
	static Date notEligibleBirthDate = Date.today().addYears(-35);

	static String overdueStatus = 'Scheduled for transition'; 
	static String eligibleStatus = 'Eligible for early transition';
	static String notEligibleStaus = 'Not Eligible';
	static Map<Date,String> birthdateToExpectedStatus =  new Map<Date,String>
		{
			notEligibleBirthDate => notEligibleStaus,
			eligibleBirthDate => eligibleStatus,
			overdueBirthdate => overdueStatus
		};

	static void setupData()
	{
		UnitTest.addData(new SObjectBuilder(Contact.SObjectType)
										.put(Contact.RecordTypeId,CONTACT_MEMBER_RECORDTYPE)
										.put(Contact.Tenure_FY17_c__c,4)
										.put(Contact.Membership_Status__c,'Member')
										.put(Contact.Grace_Accrued_FY17__c,5)
										.put(Contact.YPO_WPO__c,'YPO')
										.count(recordCount)
										.build()
										.getRecords()
				)
				.tag('All Contacts')
				.branch(String.join(birthdateToExpectedStatus.values(),'|'));

		for(Date contactBirthDate : birthdateToExpectedStatus.keyset())
		{
			UnitTest.get(birthdateToExpectedStatus.get(contactBirthDate))
					.assign('Birthdate',contactBirthDate);
		}
		
		UnitTest.get('All Contacts').insertAll();
	}
	static testmethod void callTransitionFlowTest()
	{
		setupData();
		Test.startTest();
			YearEndBatchScheduler.callTransitionFlow(UnitTest.getIds('All Contacts'));
		Test.stopTest();

		List<Contact> updatedContacts = [SELECT Transition_Status__c, Birthdate 
										  FROM Contact 
										  WHERE Id IN :UnitTest.getIds('All Contacts')];

	  	System.assertEquals(recordCount,updatedContacts.size(),'We expect to get back the correct number of contacts');
	  	
	  	Map<Date,List<Contact>> updatedContactsByBirthDate = GroupBy.dates('Birthdate',updatedContacts);
	  	for(Date contactBirthDate : birthdateToExpectedStatus.keyset())
	  	{
	  		UnitTest.analyze(birthdateToExpectedStatus.get(contactBirthDate))
	  				.assertEquivalence(updatedContactsByBirthDate.get(contactBirthDate),
	  								   'We expect the two list to be the same');

	  		for(Contact updatedContact : updatedContactsByBirthDate.get(contactBirthDate))
	  		{
	  			System.assertEquals(birthdateToExpectedStatus.get(contactBirthDate),updatedContact.Transition_Status__c,
	  								'We expect the Contact to be updated to the correct status' + updatedContact);
	  		}
	  	}

	}

	static testmethod void testScheduledBatch_Scheduled()
	{
		setupData();
		String cronExp = '0 0 0 15 3 ? 2022';
		Test.startTest();
			String jobId = System.schedule('Test', cronExp, new YearEndBatchScheduler());
		Test.stopTest();

		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(cronExp, ct.CronExpression);
	}



}