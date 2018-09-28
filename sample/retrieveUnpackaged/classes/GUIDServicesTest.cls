/**
 * GUIDServicesTest class contains unit tests for validating GUID generation
 * "Given" defines the preconditions, "When" defines what happens, and 
 * "Then" defines the result of the scenario. Or in other words: 
 * "Given" describes the start state, and "When" the steps 
 * necessary to reach the accepting state (= "Then").
 *
 * @author Shri K
 */
 
@isTest
private class GUIDServicesTest {

    static testMethod void givenSFId_whenNewGUIDCalled_thenGUIDgenerated() 
    {
		Test.startTest();
		String sGeneratedGUID = GUIDServices.newGUID('00Q4B0000010qJ7');
		Test.stopTest();
        
        system.assertEquals('30305134-4230-3030-3030-3130714a3700', sGeneratedGUID);
        //system.assertEquals('30305134-4230-3030-3030-3130714A3700', sGeneratedGUID); if touppercase() is uncommented in GuidServices class, switch the assertions
    }
    
    static testMethod void givenInvalidString_whenNewGUIDCalled_thenNullreturned() 
    {
		Test.startTest();
		String sGeneratedGUID = GUIDServices.newGUID('');
		Test.stopTest();
        
        system.assertEquals(null, sGeneratedGUID);
    }
    
}