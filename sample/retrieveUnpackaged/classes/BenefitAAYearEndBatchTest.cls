@isTest
private class BenefitAAYearEndBatchTest { 
    
	@isTest
	private static void insertBenefitAA() {      
        List<Account_Affiliation__c> lstAccountAffiliation = new List<Account_Affiliation__c>();
        
		Account testAccount = TestServices.createAccount('Test Chapter Name');
		testAccount.Type = 'Chapter';
		testAccount.RecordTypeId = [Select ID from RecordType where DeveloperName = 'Chapter' and sObjectType = 'Account'].Id;
		insert testAccount;
        
        Contact testContact = TestServices.createContact(testAccount.Id);
		testContact.RecordTypeId = [Select ID from RecordType where DeveloperName = 'Member' and sObjectType = 'Contact'].Id;
		insert testContact;

        String endOfFiscal = String.valueOf(FiscalDateUtility.getFiscalYear(Date.today()).EndDate);
        String startOfFiscal = String.valueOf(FiscalDateUtility.getFiscalYear(Date.today().addYears(1)).StartDate);        
		Id BenefitRecordId = [Select ID from RecordType where DeveloperName = 'Benefit' and sObjectType = 'Account_Affiliation__c'].Id;
        
        for(Integer i=0 ;i <100;i++){
			lstAccountAffiliation.add(new Account_Affiliation__c(Contact__c = testContact.Id, Account__c = testAccount.Id, RecordTypeId = BenefitRecordId, Start_Date__c = Date.valueOf(startOfFiscal), isActive__c = false));
        }
        
        for(Integer i=0 ;i <100;i++){
			lstAccountAffiliation.add(new Account_Affiliation__c(Contact__c = testContact.Id, Account__c = testAccount.Id, RecordTypeId = BenefitRecordId, Start_Date__c = Date.valueOf(startOfFiscal).addYears(-1), 
                                                                 End_Date__c = Date.valueOf(endOfFiscal), isActive__c = true));
        }        
        
        insert lstAccountAffiliation;
        
        Test.startTest();
 
		Database.executeBatch(new BenefitAccountAffiliationYearEndBatch());
        
        Test.stopTest();
    }
}