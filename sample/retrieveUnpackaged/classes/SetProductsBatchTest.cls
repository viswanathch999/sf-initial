@isTest
public with sharing class SetProductsBatchTest {
  
  @testSetup 
  static void testProductsBatch() {

  }
  static testmethod void test(){
		Test.startTest();
        SetProductsBatch spb = new SetProductsBatch();
        Id batchId = Database.executeBatch(spb);
		//RenewalsBatchServices.opportunitySetProductFlow(new List<Opportunity> {tOpp});
        //Database.executeBatch(new SetProductsBatch());
        Test.stopTest();
      
     // System.AssertEquals(database.countquery('SELECT COUNT()'+' FROM Opportunity WHERE StageName = \'Baseball Open\' '), 0);
  }

  static testmethod void testopportunitySetProductFlow_Batch(){
		            		Account tAcct = TestServices.createAccount('TAcct');
		insert tAcct;
		
		Contact testContact = TestServices.createContact(tAcct.Id);
        testContact.Number_Years_a_Member__c = 10;
        testContact.Preferred_Phone__c = 'Business Phone';
        testContact.Country_Code__c = '1';
        testContact.Email = 'test@mailtytest2.com';
        testContact.YNG_Member__c = true;
		insert testContact;
		
		Opportunity tOpp = TestServices.createOpp(tAcct.Id, false);
		tOpp.KGRenewal__IsActiveCart__c = false;
		tOpp.StageName = 'Cycle Open';
		
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
			RenewalsBatchServices.opportunitySetProductFlow(new List<Opportunity> {tOpp});      
		Test.stopTest();
		
        System.AssertEquals(database.countquery('SELECT COUNT()'+' FROM Opportunity WHERE StageName = \'Baseball Open\' '), 0);
		//List<Opportunity> resultOpps = [Select Id, KGRenewal__IsActiveCart__c FROM Opportunity ];
	}
}