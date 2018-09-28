@isTest
public class RelationshipServicesTest {
    static String CONST_CONTACT = 'Contact';
    static String CONST_SPOUSE = 'Spouse/Partner';
	static String CONST_EX_SPOUSE = 'Ex Spouse/Partner';
    static String CONST_Member = 'Member';
    static String CONST_Relationship = 'Relationship';
    static String CONST_Business = 'Business';
    static String CONST_NETWORK = 'Network';
    static String CONST_CHAPTER = 'Chapter';
    static String CONST_Account = 'Account';
    static Id memberRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_Member, CONST_CONTACT).Id;
    static Id spouse_partnerConRTId = RecordTypeServices.getRecordTypeByName(CONST_SPOUSE, CONST_CONTACT).Id;
    static Id businessAffRTId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_Business, 'Account_Affiliation__c').Id;
    static Id chapterAffRTId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_CHAPTER, 'Account_Affiliation__c').Id;
    static Id businessAccRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_Business, CONST_Account).Id;
    static Id relationshipAccRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_Relationship, CONST_Account).Id;
    static Relationship__c spouse_PartnerRel;
    static Relationship__c memberRel;
    static Account testHouseholdAccount;
    static Account testBusinessAccount;
	static Account testChapterAccount;
    static Contact testMemberContact;
    static Contact testSpousePartnerContact;
    static Account_Affiliation__c testUpdateAccAff;
    static Account_Affiliation__c testInsertMemberAccAff;
	static Contact_Position__c testSpousePosition;
	static List<Account> lstAccounts = new List<Account>();
	static List<Contact> lstContacts = new List<Contact>();
    
    public static void setup(){
		//Add Accounts
		testChapterAccount = TestServices.createChapterAccount('My Chapter',null);
		lstAccounts.add(testChapterAccount);

        testHouseholdAccount = TestServices.createAccount('Household');
        testHouseholdAccount.Type = CONST_Relationship;
        testHouseholdAccount.RecordTypeId = relationshipAccRecordTypeId;
        lstAccounts.add(testHouseholdAccount);

        testBusinessAccount = TestServices.createAccount('Business');
        testBusinessAccount.Type = CONST_Business;
        testBusinessAccount.RecordTypeId = businessAccRecordTypeId;
        lstAccounts.add(testBusinessAccount);

		insert lstAccounts;

		//Add Contacts
        testMemberContact = TestServices.createContact(testChapterAccount.Id);
        testMemberContact.RecordTypeId = memberRecordTypeId;
        lstContacts.add(testMemberContact); 
        
		testSpousePartnerContact = TestServices.createContact(testChapterAccount.Id);
        testSpousePartnerContact.RecordTypeId = spouse_partnerConRTId;
        lstContacts.add(testSpousePartnerContact);
        
		insert lstContacts;

		//Add in Relationships
		TestServices.createAccountAffiliation(lstAccounts[0].Id,lstContacts[0].Id,true,chapterAffRTId,true);
        TestServices.createRelationship(lstContacts[0].Id, lstAccounts[1].Id,CONST_Member, true, true);
    }
    
    public static testMethod void testUpdateRelationship(){
        setup();

		//Create active Spouse relationship, then deactivate.  Chapter AA should be deactivated as well.
		spouse_PartnerRel = TestServices.createRelationship(lstContacts[1].Id, lstAccounts[1].Id,CONST_SPOUSE, true, true);
		spouse_PartnerRel.Is_Active__c = false;

		Test.startTest();
			update spouse_PartnerRel;
		Test.stopTest();

        Account_Affiliation__c updatedTestAccAff = [Select id, IsActive__c from Account_Affiliation__c where Contact__c = :lstContacts[1].Id];
        System.assertEquals(false, updatedTestAccAff.IsActive__c);
    }
    public static testMethod void testInsertRelationship(){
        setup();

		//Create active Spouse relationship, then AA Chapter records should be cloned from the member.
        testInsertMemberAccAff = TestServices.createAccountAffiliation(lstAccounts[2].Id, lstContacts[1].Id,
                                                                       true, businessAffRTId, true);
        Test.startTest();
			spouse_PartnerRel = TestServices.createRelationship(lstContacts[1].Id, lstAccounts[1].Id,CONST_SPOUSE, true, true);
        Test.stopTest();

        List<Account_Affiliation__c> totalAccAff = [Select id, account__c from Account_Affiliation__c where Contact__c = :lstContacts[1].id];
        System.assertEquals(2, totalAccAff.size());
    }
	public static testmethod void testExSpousedeactivation() {
		setup();

		//Create active Spouse relationship, then change to and Ex-Spouse.
		spouse_PartnerRel = TestServices.createRelationship(lstContacts[1].Id, lstAccounts[1].Id,CONST_SPOUSE, true, true);

        Position__c pos = 
            new Position__c(Position_Category__c ='Chapter',
                            Title__c = 'Forum Chair',
                            Position_Status__c = 'Active',
                            Member_Type__c = CONST_SPOUSE,
                            Start_Date__c = System.today());
		insert pos;

		testSpousePosition = TestServices.createContactPosition(lstAccounts[0].Id,lstContacts[1].Id,pos.id,'Current',true);

		//Flip the relationship.
		spouse_PartnerRel.Relationship_Type__c = CONST_EX_SPOUSE;

		Test.startTest();
			update spouse_PartnerRel;
		Test.stopTest();

		//Validate that the Relationship has been deactivated
		spouse_PartnerRel = [Select id, Contact__c, Account__c, Relationship_Type__c, Is_Active__c 
										From Relationship__c 
										Where Contact__c = :lstContacts[1].id];
		System.assertEquals(CONST_EX_SPOUSE,spouse_PartnerRel.Relationship_Type__c);
		System.assertEquals(false, spouse_PartnerRel.Is_Active__c);

		//Validate that the ContactPosition has been marked as 'Past'
		testSpousePosition = [Select id, Status__c from contact_position__c where id = :testSpousePosition.id];
		System.assertequals('Past',testSpousePosition.Status__c);
	}
}