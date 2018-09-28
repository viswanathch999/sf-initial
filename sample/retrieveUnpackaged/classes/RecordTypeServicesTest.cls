/**
 * RecordTypeServicesTest is a test class for RecordTypeServices
 * @author Malay Desai
 */
@isTest
private class RecordTypeServicesTest {

	static final String CONST_CONTACT = 'Contact';
	static final Id CONST_RT_ID = [select Id, Name, DeveloperName, SObjectType from RecordType LIMIT 1].Id;
	static final String CONST_CHILD = 'Child';
    
   /*
    * Test method for testing the static variable assignments
    */	
    static testMethod void recordTypeTest() {
        
        List<RecordType> recordTypesForSObject = RecordTypeServices.getRecordTypesForSObjectType(CONST_CONTACT);
        RecordType recordTypesByName = RecordTypeServices.getRecordTypeByName(CONST_CHILD,CONST_CONTACT);
        RecordType recordTypesByDevName = RecordTypeServices.getRecordTypeByDeveloperName(CONST_CHILD,CONST_CONTACT);
        RecordType recordTypesById = RecordTypeServices.getRecordTypeById(CONST_RT_ID);
        
        recordTypesByName = RecordTypeServices.getRecordTypeByName('ABC','Dummy');
        recordTypesByDevName = RecordTypeServices.getRecordTypeByDeveloperName('ABC','Dummy');
        recordTypesById = RecordTypeServices.getRecordTypeById('0014B000002zpHH');
        
        System.assertEquals(recordTypesByName,null);
        System.assertEquals(recordTypesByDevName,null);
        System.assertEquals(recordTypesById,null);
    }
}