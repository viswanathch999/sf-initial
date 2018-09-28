@isTest
/**
 * Utility methods to assist in testing Venue code.
 */
public class v_TestUtil {
/*****************************************************************************/
  public static void createSiteConfig() {

    KGRenewal__SiteConfiguration__c siteConfig;

    try {
      siteConfig = [SELECT Id
                      FROM KGRenewal__SiteConfiguration__c
                      WHERE KGRenewal__SiteName__c = 'Default_Site'];
    }
    catch(System.QueryException qe) {
      siteConfig = (KGRenewal__SiteConfiguration__c)KGRenewal__SiteConfiguration__c.getSObjectType().newSObject(null, true);
    }
    siteConfig.Name = 'Default_Site';
    siteConfig.KGRenewal__SiteName__c = 'Default_Site';
    siteConfig.KGRenewal__DefaultPageSize__c = 10;
    upsert siteConfig;
  }
/*****************************************************************************/
  /**
   * Create a new customer community user. This will also create an Account and
   * Contact for the user. The user will be assigned the 'Venue Community User'
   * Profile.
   */
  public static User createCustomerUser() {
    RecordType rt = [SELECT Id
                      FROM RecordType
                      WHERE SObjectType='Account'
                        AND Name='Chapter'
                      LIMIT 1];
    Account acc = new Account(Name = 'KG Chapter',
                               RecordType = rt,
                               Type = 'Chapter',
                               Date_Board_Approved__c = KGServiceClass.getFirstDayOfFiscalYear(),
                               Start_Date__c = System.Today(),
                               KGRenewal__Pricebook2__c = Test.getStandardPricebookId());
    insert acc;

	Account oRelationshipAcct = new Account(Name = 'Test-Household',
								Type = 'Relationship',
								Record_Type__c = RecordTypeServices.getRecordTypeByName('Relationship','Account').Id);
    insert oRelationshipAcct;

	Profile prof = [SELECT Id
                      FROM Profile
                      WHERE Name = :Label.Customer_Community_User_Custom
                      LIMIT 1];

    Contact con = new Contact(AccountId = acc.id,
                            FirstName = 'Customer Portal Manager',
                            LastName = 'Custom',
                            Email = 'test-user@fakeemail.com',
							RecordTypeId = RecordTypeServices.getRecordTypeByName('Member','Contact').Id,
							Preferred_Phone__c = 'Mobile Phone',
							Phone = '1234567890',
							Country_Code__c = '1',
                            Active__c = false);
    insert con;
	
	Relationship__c rel = Utility.createRelationship(con.id, oRelationshipAcct.id, 'Member');
	insert rel;

    User customerUser = new User(
        Email = 'test-user@fakeemail.com',
        ContactId = con.id,
        ProfileId = prof.id,
        UserName = 'test-user@fakeemail.com',
        Alias = 'customer',
        LocaleSidKey = 'en_US',
        CommunityNickName = 'customer',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'ISO-8859-1',
        LanguageLocaleKey = 'en_US',
        FirstName = 'Customer Portal Manager',
        LastName = 'Custom');
    insert customerUser;

	//Spouse
	con = new Contact(AccountId = acc.id,
                            FirstName = 'Customer Portal Spouse',
                            LastName = 'Custom',
                            Email = 'test-Spouse@fakeemail.com',
							RecordTypeId = RecordTypeServices.getRecordTypeByName('Spouse/Partner','Contact').Id,
                            Active__c = false);
    insert con;
	rel = Utility.createRelationship(con.id, oRelationshipAcct.id, 'Spouse/Partner');
	insert rel;

	//Child
	con = new Contact(AccountId = acc.id,
                            FirstName = 'Customer Portal Child',
                            LastName = 'Custom',
                            Email = 'test-Child@fakeemail.com',
							RecordTypeId = RecordTypeServices.getRecordTypeByName('Child','Contact').Id,
                            Active__c = false);
    insert con;
	rel = Utility.createRelationship(con.id, oRelationshipAcct.id, 'Child');
	insert rel;

    return customerUser;
  }
/*****************************************************************************/
}