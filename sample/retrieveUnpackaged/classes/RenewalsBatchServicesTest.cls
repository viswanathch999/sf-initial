@isTest
public with sharing class RenewalsBatchServicesTest {

	static testMethod void testSetActiveCart(){
		
		Account tAcct = TestServices.createAccount('TAcct');
		insert tAcct;
		
		Contact testContact = TestServices.createContact(tAcct.Id);
        testContact.Number_Years_a_Member__c = 10;
        testContact.Preferred_Phone__c = 'Business Phone';
        testContact.Country_Code__c = '1';
		insert testContact;
		
		Opportunity tOpp = TestServices.createOpp(tAcct.Id, false);
		tOpp.KGRenewal__IsActiveCart__c = false;
		tOpp.StageName = 'New';
		
		KGRenewal__Subscription__c script = new KGRenewal__Subscription__c();
		script.KGRenewal__Account__c = tAcct.Id;
		script.KGRenewal__StartDate__c = System.today();
		insert script;
		
		tOpp.KGRenewal__Subscription__c = script.Id;
        tOpp.KGRenewal__Contact__c = testContact.Id;
        tOpp.KGRenewal__Contact__r = testContact;
        tOpp.KGRenewal__Contact__r.Number_Years_a_Member__c = 10;
        tOpp.KGRenewal__Contact__r.Date_Last_Grace_Year_Used__c = system.today();
            
		insert tOpp;
		
		Test.startTest();
			RenewalsBatchServices.setActiveCart(new List<Opportunity> {tOpp});
		Test.stopTest();
		
		List<Opportunity> resultOpps = [Select Id, KGRenewal__IsActiveCart__c FROM Opportunity ];
		System.assertEquals(true, resultOpps[0].KGRenewal__IsActiveCart__c, 'We expect the opp active cart flag to be set true');
	}

	static testMethod void testSetActiveCart_Batch(){
		
		Account tAcct = TestServices.createAccount('TAcct');
		insert tAcct;
		
		Contact testContact = TestServices.createContact(tAcct.Id);
        testContact.Date_Last_Grace_Year_Used__c = system.today();
        testContact.Number_Years_a_Member__c = 10;
        testContact.Preferred_Phone__c = 'Business Phone';
        testContact.Country_Code__c = '1';
		insert testContact;
		
		Opportunity tOpp = TestServices.createOpp(tAcct.Id, false);
		tOpp.KGRenewal__IsActiveCart__c = false;
		tOpp.StageName = 'New';
		
		KGRenewal__Subscription__c script = new KGRenewal__Subscription__c();
		script.KGRenewal__Account__c = tAcct.Id;
		script.KGRenewal__StartDate__c = System.today();
		insert script;
        
        Account networkAcc= new Account(name='test', RecordTypeId = CreateAccountAffForNetForumAccExt.networkAccRecordTypeId);  
		networkAcc.Type ='Network';
        insert networkAcc;
		tOpp.KGRenewal__Subscription__c = script.Id;
        tOpp.KGRenewal__Contact__c = testContact.Id;
        tOpp.KGRenewal__Contact__r = testContact;
        tOpp.KGRenewal__Contact__r.Number_Years_a_Member__c = 10;
        tOpp.KGRenewal__Contact__r.Date_Last_Grace_Year_Used__c = system.today();
        tOpp.Referred_by_Chapter__c = networkAcc.Id;
		insert tOpp;
		
		Test.startTest();
			Database.executeBatch(new RenewalsBatch());
		Test.stopTest();
		
		List<Opportunity> resultOpps = [Select Id, KGRenewal__IsActiveCart__c FROM Opportunity ];
		//System.assertEquals(true, resultOpps[0].KGRenewal__IsActiveCart__c, 'We expect the opp active cart flag to be set true');
	
	}
}