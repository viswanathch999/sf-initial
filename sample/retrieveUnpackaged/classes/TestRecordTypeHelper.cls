@isTest
private class TestRecordTypeHelper {

    static testMethod void testGetDefaultRecordtypeId() 
    {
		Test.StartTest();
			RecordTypeHelper testHelper = new RecordTypeHelper('Lead');
			Id defaultRTypeId = testHelper.defaultRecordTypeId;
		Test.StopTest();

		System.assertEquals( '012000000000000AAA', testHelper.MASTER_RECORDTYPE_ID, 'This property should be initialized');
		System.assertNotEquals( null, defaultRTypeId, 'We should have a default recordtype Id set for contact');
		
		if( defaultRTypeId != testHelper.MASTER_RECORDTYPE_ID )
			System.assert( !testHelper.useMasterRecordTypeId, 'We should not be using the master recordtype Id as our default');
		else
			System.assert( testHelper.useMasterRecordTypeId, 'The master recordtype Id is our default');
    }
    
    static testMethod void testGetNewObjectWithMasterRecordtypeId() 
    {
		RecordTypeHelper testHelper = new RecordTypeHelper('Account');
		
		Test.StartTest();
		    Sobject testAccount = testHelper.newSobjectWithRecordTypeId( testHelper.MASTER_RECORDTYPE_ID, true );  
		Test.StopTest();
        
        System.assertNotEquals( null, testAccount, 'A valid sobject should be returned');
        System.assertEquals( Account.getSobjectType(), testAccount.getSobjectType(), 'A valid account should be returned');
    }
    
}