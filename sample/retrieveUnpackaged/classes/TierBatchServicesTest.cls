@isTest(SeeAllData=true)
public with sharing class TierBatchServicesTest {

	static testMethod void testAssessTiers(){
		
		Test.startTest();
			Database.executeBatch(new TierBatch());
		Test.stopTest();
	}
}