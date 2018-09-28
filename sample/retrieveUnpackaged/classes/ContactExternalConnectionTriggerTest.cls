@isTest 
private class ContactExternalConnectionTriggerTest {

	@isTest
	private static void guidTest() {
		Contact cont = new Contact(FirstName = 'Test', LastName = 'Contact');
		insert cont;

		External_Connection__c extCon = new External_Connection__c(
			Name = 'TestExtConnection',
			RecordType = RecordTypeServices.getRecordTypesForSObjectType('External_Connection__c')[0],
			Is_Active__c = true
		);
		insert extCon;

		Contact_External_Connection__c contExtCon = new Contact_External_Connection__c(
			Contact__c = cont.Id, 
			External_Connection__c = extCon.Id,
			Type__c = Contact_External_Connection__c.Type__c.getDescribe().getPicklistValues()[0].getValue()
		);
		insert contExtCon;

		System.assert(!String.isBlank([SELECT GUID__c FROM Contact_External_Connection__c WHERE Id = :contExtCon.Id LIMIT 1].GUID__c), 'GUID should be generated on save');
	}
}