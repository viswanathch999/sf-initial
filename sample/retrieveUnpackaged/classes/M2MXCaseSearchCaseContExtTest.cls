/**
 * M2MXSkillsetSearchContTest is a Test class for M2MXCaseSearchCaseContExt and TaskServices
 * access from a button on Case Detail Page
 *
 * @author Naveen Hiremath */
@isTest
public class M2MXCaseSearchCaseContExtTest {
/*
    
    private static final String SEARCH_STRING = 'Member';
    private static final String ACCOUNT_AFFILIATION_ROLE = 'Member of Chapter';
    
    @testSetup
    private static void setup() {
        Account mockRegion = TestServices.createAccount('Test Region Chapter');
        mockRegion.Type = 'Region';
        mockRegion.RecordTypeId = RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        insert mockRegion;
        
        Account mockChapter = TestServices.createAccount('Test Account Chapter');
        mockChapter.Type = 'Chapter';
        mockChapter.RecordTypeId = RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        mockChapter.ParentId = mockRegion.Id; 
        insert mockChapter;
        
        Contact mockContact = TestServices.createContact('Test Last Name', mockChapter.Id);
        insert mockContact;
        
        Case mockCase = TestServices.createCase();
        insert mockCase;
    }
 */
 /*  
    @isTest
    public static void givenSearchResults_whenSendEmail_thenNoRedirection(){
        
        Account mockAccount = [Select Id From Account Where Type = 'Chapter'];
        Contact mockContact = [Select Id From Contact Where AccountId = :mockAccount.Id];
        
        Account_Affiliation__c mockAccAff = TestServices.createAccountAffiliation(mockAccount.Id,mockContact.Id);
        mockAccAff.Role__c = ACCOUNT_AFFILIATION_ROLE;
        insert mockAccAff;
        Id [] fixedSearchResults= new Id[1];
       fixedSearchResults[0] = mockAccAff.id;
       Test.setFixedSearchResults(fixedSearchResults);
        List<String> apiNames = new List<String>{'Account_Affiliation__c','M2MX_Skillsets__c','Relationship__c','Interest__c'};
        List<M2MX_Skillset_Search_Objects__c> lstskillsetSearchObject = TestServices.createM2MXSkillsetSearchObjects(apiNames);
        insert lstskillsetSearchObject;
        
        Case mockCase = [Select id from Case];
*/
        /*User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
                
        System.runAs (thisUser) {        
            EmailTemplate validEmailTemplate = new EmailTemplate();            
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'name';
            validEmailTemplate.DeveloperName = 'Request_Email_Anonymous_do_not_include_Requestor_Information';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            validEmailTemplate.Subject = 'Your Subject Here';
            insert validEmailTemplate;
        }*/
/*        
        Test.startTest();
        PageReference pageRef = Page.M2MXSkillsetSearch;
        pageRef.getParameters().put('Id',mockCase.Id);
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(mockCase);
        M2MXCaseSearchCaseContExt customController = new M2MXCaseSearchCaseContExt(controller);
        
        customController.noOfDays = 1;
        customController.selectedTemplate = M2MXCaseSearchCaseContExt.CONST_PRIVATE_TEMPLATE;
        customController.searchString = SEARCH_STRING;
        customController.getSearchResults();
        customController.searchResultsList[0].isChecked = true;
        customController.searchResultsList[0].email = 'test@test.coo';
        customController.sendEmail();
        customController.saveSkillset();
        EmailUtil mailSetting =EmailUtil.to(mockContact.id);
        Boolean hasMails =EmailUtil.hasEmailsToSend();
        Messaging.SendEmailResult[] last_sendEmail_result = EmailUtil.last_sendEmail_result;
        mailSetting.saveAsActivity(true);
        mailSetting.senderDisplayName('test');
        mailSetting.subject('test');
        mailSetting.htmlBody('test');
        mailSetting.whatId(mockAccount.id);
        mailSetting.useSignature(true);
        mailSetting.replyTo('test@test.coo');
        mailSetting.plainTextBody('test');
        mailSetting.fileAttachments(new List<Messaging.Emailfileattachment>());
        mailSetting.sendEmail();
        Test.stopTest();
        
        System.assertEquals(pageRef.getURL(), ApexPages.currentPage().getURL());
    }
    
    @isTest
    public static void givenSearchResults_whenCreateActivities_thenTaskShouldBeCreated() {
    
        Contact c = [Select Id From Contact Where AccountId In (Select Id From Account)];
        c.Email = 'test@xyz.com';
        c.MailingCity = 'Colorado Springs';
        c.MailingCountry = 'United States';
        c.Gender__c = 'Male';
        c.Date_Last_M2MX_Request_Email__c = System.today();
         c.MailingStreet  = 'tes';
        c.MailingPostalCode ='400101';
        update c;
                                            
        M2MXCaseSearchCaseContExt.SearchResult mockResult = 
            new M2MXCaseSearchCaseContExt.SearchResult(
                c.Id, c.Email,c.Name,c.MailingCity, c.MailingCountry, 
                c.Gender__c,null,null,null,'Contact',
                c.Date_Last_M2MX_Request_Email__c);
        List<M2MXCaseSearchCaseContExt.SearchResult> searchResults = 
        new List<M2MXCaseSearchCaseContExt.SearchResult>{mockResult};   
        
        Test.startTest();
        ApexPages.StandardController cont = new ApexPages.StandardController([Select Id From Case]);
        M2MXCaseSearchCaseContExt contExt = new M2MXCaseSearchCaseContExt(cont);
        contExt.createActivities(searchResults);
        Test.stopTest();
        
        System.assertEquals(2, [Select Count() From Task], 'A Task for Case & Contact should be created');
    }
    
    @isTest
    public static void givenCase_whenM2MXSkillsetSearchLoads_thenLastModifiedByDaysShouldBeAvailable() {
        
        Case mockCase = [Select Id From Case];
        
        Test.startTest();
        PageReference pageRef = Page.M2MXSkillsetSearch;
        pageRef.getParameters().put('Id',mockCase.Id);
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController cont = new ApexPages.StandardController(mockCase);
        M2MXCaseSearchCaseContExt contExt = new M2MXCaseSearchCaseContExt(cont);
        Test.stopTest();
        
        System.assertEquals(30, contExt.getLastModifiedByDays().size());
    }
    
    @isTest
    public static void givenCase_whenM2MXSkillsetSearchLoads_thenTemplatesShouldBeAvailable() {
        
        Case mockCase = [Select Id From Case];
        
        Test.startTest();
        PageReference pageRef = Page.M2MXSkillsetSearch;
        pageRef.getParameters().put('Id',mockCase.Id);
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController cont = new ApexPages.StandardController(mockCase);
        M2MXCaseSearchCaseContExt contExt = new M2MXCaseSearchCaseContExt(cont);
        Test.stopTest();
        
        System.assertEquals(2, contExt.getTemplates().size());
    }
*/
}