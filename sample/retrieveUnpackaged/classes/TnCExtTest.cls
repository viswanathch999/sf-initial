@isTest
public class TnCExtTest {
    
	@TestSetup
    public static void setup(){
        user PartnerUser = v_TestUtil.createCustomerUser();

		Profile AdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		User AdminUser = new User(
			IsActive = true,
			Email = 'admin@fakeemail.com',
			ProfileId = AdminProfile.id,
			UserName = 'admin@fakeemail.com',
			Alias = 'admin',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Los_Angeles',
			EmailEncodingKey = 'ISO-8859-1',
			LanguageLocaleKey = 'en_US',
			FirstName = 'Manager',
			LastName = 'Admin');
		insert AdminUser;
				
		Contact con = [SELECT Id, Name, AccountId FROM Contact WHERE Id = :PartnerUser.ContactId];

        Opportunity opp = TestServices.CreateOpp('Cycle Open',con.AccountId,con.Id,true);
		System.debug('Opp created: ' + opp.id + ' for ' + opp.Contact__c);

    }

    public static testMethod void NoContactTest(){
		User AdminUser = [Select id from user where Email = 'admin@fakeemail.com'];

		System.runAs(AdminUser) {
			Test.startTest();
				Test.setCurrentPage(page.CodeofConduct_YPO);
				ApexPages.StandardController stdCon = new ApexPages.StandardController(new contact());
				TnCExt controller = new TnCExt(stdCon);
				System.assert(ApexPages.hasMessages(),'Should have errored out because no contact should have been found. \r\n ' + ApexPages.getMessages());
			Test.stopTest();
		}
	}

	public static testmethod void UncheckedSave() {
		User PartnerUser = [Select id, ContactId from user where Email = 'test-user@fakeemail.com'];
		Contact con = [SELECT Id, Name, AccountId FROM Contact WHERE Id = :PartnerUser.ContactId];

		System.runAs(PartnerUser) {
			Test.startTest();
				Test.setCurrentPage(page.CodeofConduct_YPO);
				ApexPages.StandardController stdCon = new ApexPages.StandardController(con);
				TnCExt controller = new TnCExt(stdCon);
				System.assert(!ApexPages.hasMessages(),'Should not have errored out. \r\n ' + ApexPages.getMessages());
				controller.save();
				System.assert(ApexPages.hasMessages(),'Should have errored out because COD was not set. \r\n ' + ApexPages.getMessages());

				controller.goBack();
			Test.stopTest();
		}
	}

	public static testmethod void CheckedSave() {
		User PartnerUser = [Select id, contactid from user where Email = 'test-user@fakeemail.com'];
		Contact con = [SELECT Id, Name, AccountId FROM Contact WHERE Id = :PartnerUser.ContactId];

		System.runAs(PartnerUser) {
			Test.startTest();
				Test.setCurrentPage(page.CodeofConduct_YPO);
				ApexPages.StandardController stdCon = new ApexPages.StandardController(new Contact());
				TnCExt controller = new TnCExt(stdCon);
				System.assert(!ApexPages.hasMessages(),'Should not have errored out. \r\n ' + ApexPages.getMessages());
				controller.con.Accept_Code_Conduct__c = true;
				controller.save();
				System.assert(!ApexPages.hasMessages(),'Should not have errored out because COD was set. \r\n ' + ApexPages.getMessages());
			Test.stopTest();
		}

        Opportunity updatedOpp = [Select Code_of_Conduct_Accepted__c from Opportunity where KGRenewal__Contact__c = :con.id];
        System.assertEquals(true, updatedOpp.Code_of_Conduct_Accepted__c, 'Code_of_Conduct_Accepted__c Checkbox should be checked');
    }
}