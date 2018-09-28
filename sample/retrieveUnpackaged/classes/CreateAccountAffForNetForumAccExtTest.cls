@isTest
public class CreateAccountAffForNetForumAccExtTest {
    public static Account networkAcc;
    public static Account forumAcc;
    static final String CONST_CHAPTER = 'Chapter';
    static final String CONST_ACCOUNT = 'Account';
    static final String CONST_MEMBER = 'Member';
    static final String CONST_CONTACT = 'Contact';
    public static Contact testCont;
    public static void setup(){
        Id recordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_CHAPTER, CONST_ACCOUNT).Id;
        Account mockRegion = TestServices.createAccount('Test Region Chapter');
        mockRegion.Type = 'Region';
        mockRegion.RecordTypeId = recordTypeId;
        insert mockRegion;
        
        Account chapterAccount = TestServices.createAccount('Test-Account');
        chapterAccount.ParentId = mockRegion.Id;
        chapterAccount.RecordTypeId = recordTypeId;
        chapterAccount.Type = 'Chapter';
        insert chapterAccount;
        networkAcc= new Account(name='test', RecordTypeId = CreateAccountAffForNetForumAccExt.networkAccRecordTypeId);       
        forumAcc= new Account(name='test', RecordTypeId = CreateAccountAffForNetForumAccExt.forumAccRecordTypeId, parentid=chapterAccount.id);
        insert new List<Account>{networkAcc, forumAcc};       
            testCont = new Contact(firstname='Test Contact', lastname='Me');
            testCont.email = 'theTesterEmail@abc.com';
            testCont.RecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_MEMBER, CONST_CONTACT).Id;
        insert testCont;
    }
    public static testMethod void testCreateAccAffForNetwork(){
        setup();
        searchAndProcessRecords(networkAcc, 'Test');
    }
    public static testMethod void testCreateAccAffForForum(){
        setup();
        searchAndProcessRecords(forumAcc, 'Test');
    }
    public static void searchAndProcessRecords(Account acc, String searchString){        
        PageReference pageRef = Page.CreateAccountAffForNetForumAcc;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        CreateAccountAffForNetForumAccExt controllerExtension = new CreateAccountAffForNetForumAccExt(sc);
        ApexPages.currentPage().getParameters().put('id', controllerExtension.acc.Id);
        controllerExtension.acc.name = searchString;
        CreateAccountAffForNetForumAccExt.wrapContact wrapCon = new CreateAccountAffForNetForumAccExt.wrapContact(testCont);
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = testCont.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        controllerExtension.getRelatedContactsToAccViaSOSL();
        controllerExtension.wrapContactList[0].selected = true; 
        Test.startTest();       
        controllerExtension.processSelected();
        Test.stopTest();    
        List<Account_Affiliation__c> accAff = [Select id from Account_Affiliation__c where account__c =: controllerExtension.acc.id];
        //System.assertEquals(accAff.size(), 1);
    }
}