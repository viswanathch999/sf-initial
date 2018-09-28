@isTest
public class JSONUtilsTest {
	
	public final static String TEST_ACCOUNT_NAME = 'Test Account1';
	public final static String TEST_ACCOUNT_WEBSITE = 'https://www.test.com';
	
	public static testMethod void testCreateSObject(){
		
		Datetime nowReference = Datetime.now();
		
		Map<String, Object> expectedFields = new Map<String, Object>{
			'Name' => TEST_ACCOUNT_NAME,
			'Website' => TEST_ACCOUNT_WEBSITE,
			'LastModifiedDate' => nowReference.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')
		};
		
		Test.startTest();
		
			SObject acct = JSONUtils.createSObject(Account.getSobjectType(), expectedFields);
		
		Test.stopTest();
		
		System.assertNotEquals(null, acct, 'We expect to have an SObject instance created. ');
		System.assertEquals(Account.getSobjectType(), acct.getSobjectType(), 'We expect to have an instance of Account. ');
		for (String fieldName : expectedFields.keySet()){
			if (fieldName != 'LastModifiedDate'){
				System.assertEquals(expectedFields.get(fieldName), acct.get(fieldName), 
					'We expect to have the correct value on the Sobject created for field: ' + fieldName);
			}
			else {
				System.assertEquals(nowReference, acct.get(fieldName), 
					'We expect to have the correct value on the Sobject created for field: ' + fieldName);
			}
		}
		
	}
	
	public static testMethod void testCreateSObjects(){
		
		Integer NUM_OF_ACCOUNTS = 50; 
		
		Datetime nowReference = Datetime.now();
		
		Map<String, Object> expectedFields = new Map<String, Object>{
			'Name' => TEST_ACCOUNT_NAME,
			'Website' => TEST_ACCOUNT_WEBSITE,
			'LastModifiedDate' => nowReference.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')
		};
		
		Test.startTest();
		
			List<SObject> accts = JSONUtils.createSObjects(NUM_OF_ACCOUNTS, Account.getSobjectType(), expectedFields);
		
		Test.stopTest();
		
		System.assertEquals(NUM_OF_ACCOUNTS, accts.size(), 'We expect to have the correct number of accounts created.');
		for (Sobject acct : accts){
			System.assertNotEquals(null, acct, 'We expect to have an SObject instance created. ');
			System.assertEquals(Account.getSobjectType(), acct.getSobjectType(), 'We expect to have an instance of Account. ');
			for (String fieldName : expectedFields.keySet()){
				if (fieldName != 'LastModifiedDate'){
					System.assertEquals(expectedFields.get(fieldName), acct.get(fieldName), 
						'We expect to have the correct value on the Sobject created for field: ' + fieldName);
				}
				else {
					System.assertEquals(nowReference, acct.get(fieldName), 
						'We expect to have the correct value on the Sobject created for field: ' + fieldName);
				}
			}
		}
	}
	

}