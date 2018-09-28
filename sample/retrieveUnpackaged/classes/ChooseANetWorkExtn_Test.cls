@isTest
private class ChooseANetWorkExtn_Test {
    
    static final Id ACCOUNT_RECORDTYPEID = [select Id  from RecordType  WHERE SObjectType=:'Account' AND DeveloperName ='Network' LIMIT 1].Id;
    static final Id CONTACT_RECORDTYPEID = [select Id  from RecordType  WHERE SObjectType=:'Contact' AND DeveloperName ='Prospect' LIMIT 1].Id;

	@TestSetup static void setup() {
		Account ChapterAcct = TestServices.createChapterAccount('ChapterAcct',null);
		insert ChapterAcct;

        Account parentAcc = new Account();
        parentAcc.Name ='Business';
        parentAcc.Type = 'Business';
        parentAcc.Category__c = 'Public';
        parentAcc.RecordTypeId = ACCOUNT_RECORDTYPEID;        
		parentAcc.Status__c = 'Active';
		parentAcc.Start_Date__c = Date.today();
        insert parentAcc;         

		List<Account> AcctList = new List<Account>();
        Account acc = new Account();
        acc.Name ='Test Active Account';
        acc.ParentId = parentAcc.Id;
        acc.Type = 'Business';
        acc.Category__c = 'Public';
        acc.RecordTypeId = ACCOUNT_RECORDTYPEID;
		acc.Start_Date__c = Date.today();
		acc.Status__c = 'Active';
		AcctList.add(acc);

		acc = new Account();
        acc.Name ='Test Dissolved Account';
        acc.ParentId = parentAcc.Id;
        acc.Type = 'Business';
        acc.Category__c = 'Public';
        acc.RecordTypeId = ACCOUNT_RECORDTYPEID;
		acc.Status__c = 'Dissolved';
		acc.Start_Date__c = Date.today();
		acc.End_Date__c = Date.today();
		AcctList.add(acc);

		acc = new Account();
        acc.Name ='Test Inactive Account';
        acc.ParentId = parentAcc.Id;
        acc.Type = 'Business';
        acc.Category__c = 'Public';
        acc.RecordTypeId = ACCOUNT_RECORDTYPEID;
		acc.Start_Date__c = Date.today();
		acc.Status__c = 'Inactive';
		AcctList.add(acc);

		acc = new Account();
        acc.Name ='Test Indevelopment Account';
        acc.ParentId = parentAcc.Id;
        acc.Type = 'Business';
        acc.Category__c = 'Public';
        acc.RecordTypeId = ACCOUNT_RECORDTYPEID;
		acc.Status__c = 'In Development';
		acc.Start_Date__c = Date.today();
		AcctList.add(acc);

        insert AcctList;
        
        Contact con = new Contact();
        con.FirstName = 'Test First Name';
        con.Lastname = 'Test last Name';
        con.Gender__c = 'Male';
        con.Email = 'test.name@gmail.com';
        con.RecordTypeId = CONTACT_RECORDTYPEID;
        con.AccountId = ChapterAcct.Id;
		//con.Business_Network__c = 'Test Active Account';
        insert con;

        // Verify the account Id, either it is created or not.
        System.assertNotEquals(null, con.Id);

	}

    static testMethod void unitTestChooseaNetwork_WithoutSelection() {
		PageReference result;
		User ProspectUser = [Select Id, ContactId From User Where Email = 'test.name@gmail.com'];
		System.assertNotEquals(null,ProspectUser.Id,'Prospect user did not get created.');

        String expectedPageRef_Backward = Page.UpdateProfileInfo_YPO.getURL() + '?id=' + ProspectUser.Contactid;
                
        test.startTest();
			System.runAs(ProspectUser) {
				Test.setCurrentPage(page.ChooseANetWork_YPO);
				ApexPages.currentPage().getParameters().put('id',ProspectUser.ContactId);

				ApexPages.StandardController sc = new ApexPages.StandardController(new Contact());
				ChooseANetWorkExtn choosenet = new ChooseANetWorkExtn(sc);
				choosenet.updateContact();
				System.assert(ApexPages.hasMessages(ApexPages.Severity.Warning),'We should be receiving a page message since we have not selected a network.');

				result = choosenet.goBack();
				System.assertequals(expectedPageRef_Backward,result.getUrl(),'We missed our page landing');

				//US8552 - Validation of the Active only Business networks restriction
				System.assertEquals(1,choosenet.AccountBusinessNetwork.size(),'Should have only pulled one active Business Network.');
			}
        test.stopTest();
        
    }

    static testMethod void unitTestChooseaNetwork_withselection() {
		PageReference result;
		User ProspectUser = [Select Id, ContactId From User Where Email = 'test.name@gmail.com'];
		System.assertNotEquals(null,ProspectUser.Id,'Prospect user did not get created.');

        String expectedPageRef_Forward = Page.Catalog_YPO.getURL() + '?id=' + ProspectUser.Contactid;
                
        test.startTest();
			System.runAs(ProspectUser) {
				Test.setCurrentPage(page.ChooseANetWork_YPO);
				ApexPages.currentPage().getParameters().put('id',ProspectUser.ContactId);

				ApexPages.StandardController sc = new ApexPages.StandardController(new Contact());
				ChooseANetWorkExtn choosenet = new ChooseANetWorkExtn(sc);
				choosenet.selectedAccountId = choosenet.AccountBusinessNetwork[0].AccBusinessNetwork.id;
				result = choosenet.updateContact();
				System.assert(!ApexPages.hasMessages(ApexPages.Severity.Warning),'We should not be receiving a page message since we have selected a network.');
				System.assertequals(expectedPageRef_Forward,result.getUrl(),'We missed our page landing');

				//US8552 - Validation of the Active only Business networks restriction
				System.assertEquals(1,choosenet.AccountBusinessNetwork.size(),'Should have only pulled one active Business Network.');
			}
        test.stopTest();
        
    }

    public static testMethod void NoContactTest(){
		User AdminUser = [SELECT Id FROM User Where Profile.Name = 'System Administrator' and isActive=true LIMIT 1];

		System.runAs(AdminUser) {
			Test.startTest();
				Test.setCurrentPage(page.ChooseANetWork_YPO);

				ApexPages.StandardController stdCon = new ApexPages.StandardController(new contact());
				ChooseANetWorkExtn choosenet = new ChooseANetWorkExtn(stdCon);

				System.assert(ApexPages.hasMessages(),'Should have errored out because no contact should have been found. \r\n ' + ApexPages.getMessages());
			Test.stopTest();
		}
	}

}