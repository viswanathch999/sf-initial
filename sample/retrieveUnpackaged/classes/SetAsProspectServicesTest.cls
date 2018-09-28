/**
* Class Name: SetAsProspectServicesTest
*  Description : Test class for SetAsProspectServices
* @author IBM 
*/
@isTest
private class SetAsProspectServicesTest
{
    @testSetup
    static void setUp()
    {
        Id recordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Chapter', 'Account').Id;

		Account oAccount2 = TestServices.createAccount('Needs Chapter');
        //oAccount2.ParentId = mockRegion.Id;
        oAccount2.RecordTypeId = recordTypeId;
        oAccount2.Type = 'Chapter';
        oAccount2.Start_Date__c = system.today();
		insert oAccount2;

        Lead lead=new Lead(	LastName='Doe',
							FirstName='John',
							Company='Test',
							Status='New',
							Email='hey1@ypo.com',
							Verify_3rd_Party_Status__c='Validated',
							//6751 - Address components
							Country = 'United States',
							State = 'Alabama',
							City = 'Montgomry',
							Postalcode = '54684',
							Street = '546 Anystreet',

							Spouse_Partner_Name__c= 'Test', 
							Spouse_Partner_Last_Name__c ='lead', 
							Spouse_Partner_Email__c = 'test@ypo.com',
							Waiver_Status__c ='Approved',
							Type_of_Waiver__c = 'Volume',

							President_Type__c = 'Family Business Operator',
							Business_Description__c = 'Sushi Manufacturer',
							Industry = 'Manufacturing - Food and Bev',
							Sub_Category__c = 'Food Manufacturing',
							Firm_Type__c = 'Private for Profit',
							Business_Scope__c = 'Local',
							Title__c = 'President',
							Title_Other__c = '',
							Website = '',
							
							Pursue_Status__c = 'Pending', Referred_by_Chapter__c = oAccount2.id
							);
        insert lead;                
        //Creation of Geographic Requirement
        Geographic_Requirements__c geo = new Geographic_Requirements__c(Country__c= 'United States' ,Number_of_Employees_Opt_1__c = 100 ,Annual_Revenue__c = 104.00, Annual_Fees__c = 103.00 );
        insert geo; 
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Closed - Converted'); 
        Database.LeadConvertResult lcr = Database.convertLead(lc);
    }    
    //test method to check funtionality of FlowControl
    static testMethod void SetAsProspectSvcExtn()
    {
        Lead ld= [select  id,ConvertedContactId,Lead_Opportunity_Name__c,President_Type__c,Business_Description__c,Industry,Sub_Category__c,Firm_Type__c,Business_Scope__c,Title__c,Title_Other__c,
                  Website,convertedOpportunityId,ConvertedAccountId from lead where LastName='Doe' and Verify_3rd_Party_Status__c='Validated' limit 1];
        ID optyID = ld.convertedOpportunityId;
        
        Opportunity opty=[select id,AccountId from Opportunity where id=:optyID];
        Account acc=[select id from Account where id=:ld.ConvertedAccountId];
        
        PageReference pref=Page.SetAsProspectPopup;
        Test.setCurrentPage(pref);
        ApexPages.currentPage().getParameters().put('id',optyID);
        ApexPages.StandardController sc = new ApexPages.StandardController(opty);
        SetAsProspectServices extnC=new SetAsProspectServices(sc);
        test.startTest();
            extnC.flowControl();
			extnC.getAllAAs(opty.AccountId);
        test.StopTest();

		System.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR),'Page reported messages: ' + ApexPages.getMessages());
    }
    
    //Test method for creation of Business Account Affiliation
    static testMethod void createBuisnessAAsTest(){
        Lead ld= [select  id,ConvertedContactId,President_Type__c,Business_Description__c,Industry,Sub_Category__c,Firm_Type__c,Business_Scope__c,Title__c,Title_Other__c,
                  Website,convertedOpportunityId,ConvertedAccountId from lead where LastName='Doe' and Verify_3rd_Party_Status__c='Validated' limit 1];
        ID optyID = ld.convertedOpportunityId;
        
        Opportunity opty=[select id,AccountId from Opportunity where id=:optyID];
        Account acc=[select id,Name from Account where id=:ld.ConvertedAccountId];
        List<OpportunityContactRole> ocr = [SELECT Id, OpportunityId, ContactId FROM OpportunityContactRole WHERE OpportunityId =: optyID LIMIT 1];
        Contact contactfrmLead = [SELECT id,Name,AccountId,Active__c,Membership_Status__c,RecordTypeID,Tier_Number__c from Contact where id=:ocr[0].ContactId];  
        PageReference pref=Page.SetAsProspectPopup;
        Test.setCurrentPage(pref);
        ApexPages.currentPage().getParameters().put('id',optyID);
        ApexPages.StandardController sc = new ApexPages.StandardController(opty);
        opty.id =sc.getId();
        SetAsProspectServices extnC=new SetAsProspectServices(sc);
        test.startTest();
            Account_Affiliation__c recAccAff=extnC.createBuisnessAAs(extnC.opp.AccountId);
        test.stopTest();
        
        System.assert(recAccAff != null, 'Business AA is not created');
    }
    
    //Item 7113-Test method for creation of HouseholdAccount
    static testMethod void createHouseholdAccountTest()
    {
        Lead ld= [select  id,ConvertedContactId,President_Type__c,Business_Description__c,Industry,Sub_Category__c,Firm_Type__c,Business_Scope__c,Title__c,Title_Other__c,
                  Website,convertedOpportunityId,ConvertedAccountId from lead where LastName='Doe' and Verify_3rd_Party_Status__c='Validated' limit 1];
        ID optyID = ld.convertedOpportunityId;
        
        Opportunity opty=[select id,AccountId from Opportunity where id=:optyID];
        Account acc=[select id,Name from Account where id=:ld.ConvertedAccountId];
        List<OpportunityContactRole> ocr = [SELECT Id, OpportunityId, ContactId FROM OpportunityContactRole WHERE OpportunityId =: optyID LIMIT 1];
        Contact contactfrmLead = [SELECT id,Name,AccountId,Active__c,Membership_Status__c,RecordTypeID,Tier_Number__c from Contact where id=:ocr[0].ContactId];  
        PageReference pref=Page.SetAsProspectPopup;
        Test.setCurrentPage(pref);
        ApexPages.currentPage().getParameters().put('id',optyID);
        ApexPages.StandardController sc = new ApexPages.StandardController(opty);
        opty.id =sc.getId();
        SetAsProspectServices extnC=new SetAsProspectServices(sc);
        extnC.leadConverted = ld;
        extnC.opp =opty;
        test.startTest();
        extnC.createHouseholdAccount();
        test.Stoptest();
        system.assertEquals((contactfrmLead.Name + 'Household'),string.valueof([select name from Account where name =: (contactfrmLead.Name + 'Household')].name),'Account is not created'); 
        system.assertNotEquals(null,string.valueof([select name from Relationship__c where Account__c = :acc.Id]),'Relationship is not inserted');  
    }
    
    //Test method for updatecontact method
    static testMethod void  updateContactRecTest()
    {
        Lead ld= [SELECT id,ConvertedOpportunityId,ConvertedAccountId,Waiver_Status__c,ConvertedContactId,President_Type__c,Business_Description__c,
                  Industry,Sub_Category__c,Firm_Type__c,Business_Scope__c,Title__c,Title_Other__c,Website,
                  QC_Country__c,Type_of_Waiver__c,QC_Enterprise_Value__c,QC_Number_of_Employees_Opt_1__c,
                  Tot_Empl_Comp__c,Corp_Type__c,QC_Annual_Assets__c,QC_Annual_Fees__c,QC_Annual_Revenue__c
                  FROM Lead 
                  WHERE LastName='Doe' and Verify_3rd_Party_Status__c='Validated' limit 1];
        
        ID optyID = ld.convertedOpportunityId;
        Opportunity opty=[select id,AccountId from Opportunity where id=:optyID];
        Account acc=[select id from Account where id=:ld.ConvertedAccountId];
        List<OpportunityContactRole> ocr = [SELECT Id, OpportunityId, ContactId FROM OpportunityContactRole WHERE OpportunityId =: optyID LIMIT 1];
        Contact contactfrmLead = [SELECT id,AccountId,Active__c,RecordTypeID,Tier_Number__c,
                                  Membership_Status__c,
                                  QC_Number_of_Employees_Opt_1__c,
                                  QC_Number_of_Employees_Opt_2__c,
                                  QC_Total_Employee_Compensation_Opt_2__c,
                                  QC_Annual_Fees__c,
                                  QC_Annual_Assets__c,
                                  QC_Annual_Revenue__c,
                                  QC_Enterprise_Value__c,
                                  Tot_Empl_Comp__c
                                  FROM Contact where id=:ocr[0].ContactId];                         
        PageReference pref=Page.SetAsProspectPopup;
        Test.setCurrentPage(pref);
        ApexPages.currentPage().getParameters().put('id',optyID);
        ApexPages.StandardController sc = new ApexPages.StandardController(opty);
        opty.id =sc.getId();
        
        //updating Type_of_Waiver__c of lead to test scenarios
        ld.Waiver_Status__c = 'Approved';
        ld.Type_of_Waiver__c ='Volume';
        ld.Corp_Type__c = 'Financial Institution';
        update ld;
        
        SetAsProspectServices extnC=new SetAsProspectServices(sc);
        extnC.leadConverted = ld;
        extnC.opp =opty;
        test.starttest();
            Contact conrecord = extnC.updateContactRec(contactfrmLead);
        test.stoptest();
        System.assertEquals(conrecord.QC_Annual_Assets__c, ld.AnnualRevenue, 'Values of fields of contact and lead should be equal'); 
    }
    
    //Test method for creation of Spouse/Partner Contact
    static testMethod void createContactSpousePartnerTest(){
        Lead ld= [select  id,ConvertedContactId,Lead_Opportunity_Name__c,President_Type__c,Business_Description__c,Industry,Sub_Category__c,Firm_Type__c,Business_Scope__c,Title__c,Title_Other__c,
                  Website,convertedOpportunityId,ConvertedAccountId,Spouse_Partner_Name__c,Spouse_Partner_Gender__c,Spouse_Partner_Email__c,Spouse_Partner_Last_Name__c from lead where LastName='Doe' and Verify_3rd_Party_Status__c='Validated' limit 1];
        ID optyID = ld.convertedOpportunityId;
        
        
        ID recTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chapter').getRecordTypeID();
        
        //Updating fields of Account and Opportunity for test data of this method
        Account acc=[select id,Name from Account where id=:ld.ConvertedAccountId];
        acc.RecordTypeId = recTypeId;
        acc.Start_Date__c = System.Today()+5;
        acc.Date_Board_Approved__c = System.Today() + 10;
        update acc;
        
        Opportunity opty=[select id,Referred_by_Chapter__c,AccountId from Opportunity where id=:optyID];
        opty.Referred_by_Chapter__c = opty.AccountId;
        update Opty;
        
        ID recTypeSpouse= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Spouse/Partner').getRecordTypeID();
        System.debug('!!!!'+recTypeSpouse);    
        System.debug('######Referredbychapter'+opty.Referred_by_Chapter__c);
        System.debug('###AccountId'+opty.AccountId);
        List<OpportunityContactRole> ocr = [SELECT Id, OpportunityId, ContactId FROM OpportunityContactRole WHERE OpportunityId =: optyID LIMIT 1];
        Contact contactfrmLead = [SELECT id,Name,AccountId,Active__c,Membership_Status__c,RecordTypeID,Tier_Number__c from Contact where id=:ocr[0].ContactId];  
        PageReference pref=Page.SetAsProspectPopup;
        Test.setCurrentPage(pref);
        ApexPages.currentPage().getParameters().put('id',optyID);
        ApexPages.StandardController sc = new ApexPages.StandardController(opty);
        opty.id =sc.getId();
        SetAsProspectServices extnC=new SetAsProspectServices(sc);
        extnC.leadConverted = ld;
        extnC.opp = opty;
        test.startTest();
            extnC.createHouseholdAccount();
            extnC.createContactSpousePartner();
        test.Stoptest();
        List<Contact>SpouseContact= [Select id ,AccountId,Active__c,RecordTypeId from Contact ];
        System.assert(!SpouseContact.isEmpty(),'Spouse/Partner Contact is not created' );
    }  
    
    //Test method for Creation of Chapter AA
    static testMethod void  createChapterAATest(){
        Lead ld= [select  id,ConvertedContactId,President_Type__c,Business_Description__c,Industry,Sub_Category__c,Firm_Type__c,Business_Scope__c,Title__c,Title_Other__c,
                  Website,convertedOpportunityId,ConvertedAccountId from lead where LastName='Doe' and Verify_3rd_Party_Status__c='Validated' limit 1];
        ID optyID = ld.convertedOpportunityId;
        
        Opportunity opty=[select id,AccountId from Opportunity where id=:optyID];
        //Account acc=[select id,Name from Account where id=:ld.ConvertedAccountId];
        List<OpportunityContactRole> ocr = [SELECT Id, OpportunityId, ContactId FROM OpportunityContactRole WHERE OpportunityId =: optyID LIMIT 1];
        Contact contactfrmLead = [SELECT id,Name,AccountId,Active__c,Membership_Status__c,RecordTypeID,Tier_Number__c from Contact where id=:ocr[0].ContactId];
        ID recTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chapter').getRecordTypeID();
        
        //Updating fields of Account and Lead for test data of this method
        Account acc=[select id,Name from Account where id=:ld.ConvertedAccountId];
        acc.RecordTypeId = recTypeId;
        acc.Start_Date__c = System.Today()+5;
        acc.Date_Board_Approved__c = System.Today() + 10;
        acc.Status__c = 'Active';
        acc.Type = 'Chapter';
        update acc;        
        
        ld.Referred_by_Chapter__c = acc.Id;
        update ld;
        
        PageReference pref=Page.SetAsProspectPopup;
        Test.setCurrentPage(pref);
        ApexPages.currentPage().getParameters().put('id',optyID);
        ApexPages.StandardController sc = new ApexPages.StandardController(opty);
        opty.id =sc.getId();
        SetAsProspectServices extnC=new SetAsProspectServices(sc);
        extnC.leadConverted = ld;
        extnC.opp =opty;
        
        test.startTest();
            List<Account_Affiliation__c>AccAff = extnC.createChapterAA();
        test.stopTest();
        
        System.assert(!AccAff.isEmpty(),'Chapter AA is not created');
    }
    
    //Test method for Update of Opportunity and Opportunity contact role
    static testMethod void updateOpportunityContactRoleTest(){
        Lead ld= [select  id,ConvertedContactId,President_Type__c,Business_Description__c,Lead_Opportunity_Name__c,Industry,Sub_Category__c,Firm_Type__c,Business_Scope__c,Title__c,Title_Other__c,
                  Website,convertedOpportunityId,ConvertedAccountId from lead where LastName='Doe' and Verify_3rd_Party_Status__c='Validated' limit 1];
        ID optyID = ld.convertedOpportunityId;
        Account acc=[select id,Name from Account where id=:ld.ConvertedAccountId];
        List<OpportunityContactRole> ocr = [SELECT Id,Role, OpportunityId, ContactId FROM OpportunityContactRole WHERE OpportunityId =: optyID LIMIT 1];
        Contact contactfrmLead = [SELECT id,Name,AccountId,Active__c,Membership_Status__c,RecordTypeID,Tier_Number__c from Contact where id=:ocr[0].ContactId];  
        Opportunity opty=[select id,Contact__c ,AccountId from Opportunity where id=:optyID];
        opty.Contact__c = contactfrmLead.Id;
        Update opty;
        
        PageReference pref=Page.SetAsProspectPopup;
        Test.setCurrentPage(pref);
        ApexPages.currentPage().getParameters().put('id',optyID);
        ApexPages.StandardController sc = new ApexPages.StandardController(opty);
        SetAsProspectServices extnC=new SetAsProspectServices(sc);
        test.startTest();
        List<OpportunityContactRole>UpdatedOcr = extnC.updateOpportunityContactRole();
        test.StopTest();
        opty = extnC.opp;
        
        System.assertEquals(UpdatedOcr[0].Role, 'Business User' ,'Role should be Business User'); 
        System.assertEquals(opty.Chapter_Acceptance_Status__c ,'Approved','The value of Chapter_Acceptance_Status__c should be Approved');
        System.assertEquals(opty.Opportunity_Type__c,'Prospect' ,'The value of Opportunity_Type__c should be Prospect');
        system.assertNotEquals(opty.StageName, 'Closed Won' ,'The Stage of Opportunity should not be Closed Won');
		System.assert(String.isNotBlank(opty.QC_StreetAddress1__c),'Address did not get loaded into QC Opty address');
    } 
    
    //Test method for creation of WaiverException
    static testMethod void  createWaiverExceptionTest(){
        Lead ld= [select  id,Waiver_Status__c,ConvertedContactId,President_Type__c,Business_Description__c,Industry,Sub_Category__c,Firm_Type__c,Business_Scope__c,Title__c,Title_Other__c,
                  Website,convertedOpportunityId,ConvertedAccountId,Type_of_Waiver__c,Waiver_Decision_Date__c,Add_Waiver_Request_comments_or_cl__c,Age_Question_1__c,Age_Question_2__c,
                  All_Question_1__c,All_Question_2__c,Title_Question_1__c,Title_Question_2__c from lead where LastName='Doe' and Verify_3rd_Party_Status__c='Validated' limit 1];
        ID optyID = ld.convertedOpportunityId;
        
        Opportunity opty=[select id,AccountId from Opportunity where id=:optyID];
        
        List<OpportunityContactRole> ocr = [SELECT Id, OpportunityId, ContactId FROM OpportunityContactRole WHERE OpportunityId =: optyID LIMIT 1];
        Contact contactfrmLead = [SELECT id,Name,AccountId,Active__c,Membership_Status__c,RecordTypeID,Tier_Number__c from Contact where id=:ocr[0].ContactId];
        ID recTypeaccId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chapter').getRecordTypeID();  
        //Updating fields of Account and Lead for test data of this method
        Account acc=[select id,Name from Account where id=:ld.ConvertedAccountId];
        acc.RecordTypeId = recTypeaccId;
        acc.Start_Date__c = System.Today()+5;
        acc.Date_Board_Approved__c = System.Today() + 10;
        acc.Status__c = 'Active';
        acc.Type = 'Chapter';
        update acc;        
        
        ld.Referred_by_Chapter__c = acc.Id;
        update ld;
        
        PageReference pref=Page.SetAsProspectPopup;
        Test.setCurrentPage(pref);
        ApexPages.currentPage().getParameters().put('id',optyID);
        ApexPages.StandardController sc = new ApexPages.StandardController(opty);
        opty.id =sc.getId();
        SetAsProspectServices extnC=new SetAsProspectServices(sc);
        extnC.leadConverted = ld;
        extnC.opp =opty;
        
        test.startTest();
        list<Exception__c>lstexecption  = extnC.createWaiverException();
        test.StopTest();               
        System.assert(!lstexecption.isEmpty(),'Exception Records got created');
    }
}