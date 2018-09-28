@isTest
private class BusinessAddressTest {
	@TestSetup static void setup(){
		Contact con = new Contact(lastName = 'TestName', Int_General__c = 'Male', Email = 'Test@test.com', RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId());
		insert con;

		Account acct = new Account(name = 'test123', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId());
		insert acct;

		Account_Affiliation__c AA = new Account_Affiliation__c(contact__c = con.Id, account__c = acct.Id, recordTypeId = Schema.SObjectType.Account_Affiliation__c.getRecordTypeInfosByName().get('Business').getRecordTypeId(), start_date__c = System.today());
		insert AA;
	}
    
	@isTest
	private static void editBusinessAA() {
		Account_Affiliation__c AA = [Select ID from Account_Affiliation__c where Start_Date__c = :System.today()];

		AA.Street__c = 'Some Street';
        AA.City__c = 'Nowhere';
        AA.State_Code__c = 'ZZ';
        
        update AA;
	}    
}