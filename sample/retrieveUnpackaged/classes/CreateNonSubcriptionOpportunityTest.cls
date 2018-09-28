@isTest
private class CreateNonSubcriptionOpportunityTest {
	
	static final Integer RECORD_COUNT = 10;

	@isTest static void CreateNonSubcriptionOpportunityActionTest() {
		
		List<Account> testAccounts = new List<Account>();
		for(Integer i = 0; i < RECORD_COUNT; i++)
		{
			Account acct =  TestServices.createAccount('Test Account '+i);
			acct.Type = 'Chapter';
			acct.RecordTypeId = RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
			testAccounts.add(acct);
		}
		insert testAccounts;

		List<Contact> testContacts = new List<Contact>();
		for(Account testAccount : testAccounts)
		{
			testContacts.add(TestServices.createContact(testAccount.Id));
		}
		insert testContacts;


		List<Account_Affiliation__c> testAccAffs = new List<Account_Affiliation__c>();

		for(Integer i = 0; i < RECORD_COUNT; i++)
		{
			testAccAffs.add(TestServices.createAccountAffiliation(testAccounts[i].Id,testContacts[i].Id));
		}

		Test.startTest();
			CreateNonSubcriptionOpportunityAction.CreateNonSubcriptionOpportunityAction(testAccAffs);
		Test.stopTest();

		List<Opportunity> actualOpps = [SELECT Referred_by_Chapter__c, KGRenewal__Contact__c 
									    FROM Opportunity 
									    WHERE Referred_by_Chapter__c IN : testAccounts 
									    AND KGRenewal__Contact__c IN : testContacts ];

		System.assertEquals(actualOpps.size(),testAccAffs.size(),'There should be an Opportunity created for each Account Affiliation');
		Map<Id,List<Account_Affiliation__c>> acctAffByAccounts = GroupBy.ids('Account__c',testAccAffs);
		Map<Id,List<Account_Affiliation__c>> acctAffByContacts = GroupBy.ids('Contact__c',testAccAffs);
		for(Opportunity opp: actualOpps)
		{
			System.assert( acctAffByContacts.get(opp.KGRenewal__Contact__c)[0] == acctAffByAccounts.get(opp.Referred_by_Chapter__c)[0], 
				'We expect the Opportunity created to be linked to correct Contact and Account' );
		}
		
	}
	
	@isTest static void insertOpportunties_Failure() {
		Opportunity opp = new Opportunity();

		Test.startTest();
			try
			{
				CreateNonSubcriptionOpportunityAction.insertOpportunties(new List<Opportunity>{opp});
				System.assert(false,'We expect an error to be thrown');
			}
			catch(DmlException e)
			{
				//sucess
			}
        Test.stopTest();
	}
	
}