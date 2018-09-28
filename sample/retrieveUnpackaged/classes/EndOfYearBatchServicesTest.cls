@isTest
public with sharing class EndOfYearBatchServicesTest {

	static testMethod void testSetActiveCart(){
		
		Account tAcct = TestServices.createAccount('TAcct');
		insert tAcct;
		
		Contact testContact = TestServices.createContact(tAcct.Id);
		insert testContact;
		
		Opportunity tOpp = TestServices.createOpp(tAcct.Id, false);
		tOpp.KGRenewal__IsActiveCart__c = false;
		tOpp.StageName = 'New';
		
		KGRenewal__Subscription__c script = new KGRenewal__Subscription__c();
		script.KGRenewal__Account__c = tAcct.Id;
		script.KGRenewal__StartDate__c = System.today();
		insert script;
		
		tOpp.KGRenewal__Subscription__c = script.Id;
		tOpp.KGRenewal__Contact__c = testContact.id;
		insert tOpp;
		
		Test.startTest();
			EndOfYearBatchServices.setActiveCart(new List<Opportunity> {tOpp});
		Test.stopTest();
		
		List<Opportunity> resultOpps = [Select Id, KGRenewal__IsActiveCart__c FROM Opportunity ];
		System.assertEquals(true, resultOpps[0].KGRenewal__IsActiveCart__c, 'We expect the opp active cart flag to be set true');
	}

	static testMethod void testSetActiveCart_Batch(){
		
		Account tAcct = TestServices.createAccount('TAcct');
		insert tAcct;
		
		Contact testContact = TestServices.createContact(tAcct.Id);
		insert testContact;
		
		Opportunity tOpp = TestServices.createOpp(tAcct.Id, false);
		tOpp.KGRenewal__IsActiveCart__c = false;
		tOpp.StageName = 'New';
		
		KGRenewal__Subscription__c script = new KGRenewal__Subscription__c();
		script.KGRenewal__Account__c = tAcct.Id;
		script.KGRenewal__StartDate__c = System.today();
		insert script;
		
		tOpp.KGRenewal__Subscription__c = script.Id;
		tOpp.KGRenewal__Contact__c = testContact.id;
		insert tOpp;
		
		Test.startTest();
			Database.executeBatch(new EndOfYearBatch());
		Test.stopTest();
		
		List<Opportunity> resultOpps = [Select Id, KGRenewal__IsActiveCart__c FROM Opportunity ];
		System.assertEquals(true, resultOpps[0].KGRenewal__IsActiveCart__c, 'We expect the opp active cart flag to be set true');
	
	}
}