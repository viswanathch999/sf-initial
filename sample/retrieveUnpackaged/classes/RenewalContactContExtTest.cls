/*
 * 
 * RenewalContactContExtTest is a Test suite for various methods
 * that are part of RenewalContactContExt class
 *
 * @author Malay Desai
 */

@isTest
public class RenewalContactContExtTest {
    
    private static Account getAccount(String name,String type){
        Account oAccount= new Account();
        oAccount.name=name;
        oAccount.Type = type; //'chapter';
        oAccount.YPOI_Type__c = 'YPO'; 
        oAccount.BillingStreet = 'Test Street';
        oAccount.BillingCity = 'Test city';
        oAccount.BillingState = 'California';
        oAccount.BillingPostalCode = '22345';
        oAccount.BillingCountry = 'United States';
        oAccount.BillingLatitude = 23.45;
        oAccount.BillingLongitude = 24.56;
        
        return oAccount;   
    }
    private static Account getMemberAccount(String name){
        Account oAccount= new Account();
        oAccount.name=name;
        oAccount.Type = 'Relationship';
        oAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship').getRecordTypeId();
        return oAccount;    
    }
    
    private static Account getRegionAccount(String name){
        Account oAccount= new Account();
        oAccount.name=name;
        oAccount.Type = 'Region';
         return oAccount;    
    }
     private static Account getChapterAccount(String name,Account parent){
        Account oAccount= new Account();
        oAccount.name=name;
        oAccount.Type = 'Chapter';
        oAccount.Status__c ='Active';
        oAccount.ParentId = parent.id;
        oAccount.New_Member_Status__c = 'Accepting New Members';
        oAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chapter').getRecordTypeId();
        return oAccount;    
    }
    private static Opportunity getOpportunity(String name,String stageName,String certificationType,Date closeDate){
        Opportunity oOpp = new Opportunity();
        oOpp.name = name;
        oOpp.StageName = stageName;
        oOpp.Certification_Type__c = certificationType;
        oOpp.CloseDate = closeDate;
        /*** TO DO ***/
        /*Change this back to: System.Today().year(), 7, 1 */
        oOpp.Fiscal_Date_Start__c = Date.newInstance(System.Today().year(), 7, 1);
        oOpp.KGRenewal__IsActiveCart__c = TRUE;
        return oOpp;
        
    }
    private static Account_Affiliation__c getAccountAffiliation(Account oAccount,Contact oContact){
        Account_Affiliation__c oAccAff = new Account_Affiliation__c(Account__c=oAccount.id,Contact__c=oContact.id,
                                                                   IsActive__c = TRUE, start_date__c = system.today());
        return oAccAff;
    }
    @isTest
    public static void testRelationship(){
        Account regAccount = getRegionAccount('Test US');
        regAccount.RecordTypeId = RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        insert regAccount;
        
        Account ChapterAccount = getChapterAccount('WPO Test Chapter',regAccount);
        ChapterAccount.Start_Date__c = System.today();
        insert chapterAccount;
        
        Account testChapParentAccount = getAccount('Parent Chapter','Chapter');
        insert testChapParentAccount;
        
        Account oAccount = getAccount('Needs Chapter','Chapter');
        oAccount.recordtypeid=  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        oAccount.parentId = regAccount.id;
       // oAccount.Firm_Type__c ='Public';
        oAccount.Industry = 'Technology';
        oAccount.Sub_Category__c ='Warehousing & Storage';
        oAccount.Is_Subsidiary__c = TRUE;
        oAccount.Parent_Company__c='Test parent';
        insert oAccount;
        System.debug('>> oAccount.parentId : '+oAccount.ParentId);
        
        Account relAccount = getMemberAccount('Test Relationhip Account');
        insert relAccount;
        
        
        Contact oContact = new Contact();
        oContact.AccountId = oAccount.Id;
        oContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        oContact.lastname = 'Test Member Contact';
        oContact.householdId__c =relAccount.id;
        oContact.YPO_WPO__c = 'YPO';
        oContact.Transition_Status__c =  'Eligible for early transition';
        //oContact.Grace_Years_Accrued__c = 10;
        oContact.Grace_Accrued_FY17__c = 10;
        oContact.Is_Grace_Used__c = FALSE;
        oContact.Date_Last_Grace_Year_Used__c = Date.newInstance(System.Today().year(), 8, 1);
        oContact.Join_date__c = Date.newInstance(2000, 1, 1);
        insert oContact; 
        system.debug('>>oContact.householdId__c : '+oContact.householdId__c );
        
        Contact spouseContact = new Contact();
        spouseContact.AccountId = oAccount.Id;
        spouseContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Spouse/Partner').getRecordTypeId();
        spouseContact.lastname = 'Test Spouse Contact';
        spouseContact.householdId__c =relAccount.id;
        insert spouseContact; 
        system.debug('>>spouseContact.householdId__c : '+spouseContact.householdId__c );
        
        Contact childContact = new Contact();
        childContact.AccountId = oAccount.Id;
        childContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Child').getRecordTypeId();
        childContact.lastname = 'Test Child Contact';
        childContact.householdId__c =relAccount.id;
        insert childContact; 
        
        List<Relationship__c> listRelationship = new List<Relationship__c>();
        Relationship__c spouseRel = new Relationship__c();
        spouseRel.Is_Active__c = TRUE;
        spouseRel.Contact__c = spouseContact.id;
        spouseRel.Account__c = relAccount.id;
        listRelationship.add(spouseRel);
               
        Relationship__c memberRel = new Relationship__c();
        memberRel.Is_Active__c = TRUE;
        memberRel.Contact__c = oContact.id;
        memberRel.Account__c = relAccount.id;
        listRelationship.add(memberRel);
        
        Relationship__c childRel = new Relationship__c();
        childRel.Is_Active__c = TRUE;
        childRel.Contact__c = childContact.id;
        childRel.Account__c = relAccount.id;
        listRelationship.add(childRel);
        
        insert listRelationship;
        
        Account accForAff = getAccount('Affiliated Account','Business');
        //accForAff.Firm_Type__c = 'Public';
        insert accForAff;
        
        Account_Affiliation__c accAff = getAccountAffiliation(accForAff,oContact);
        insert accAff;
        
        Opportunity oOpp= getOpportunity('Test Oppty','Cycle Open','Third Party Certify',Date.today().addYears(2));
        oOpp.AccountId = oAccount.id;
        oOpp.Qualifying_Company__c='Test Company';
        oOpp.Organization_Type__c ='Sales';
        oOpp.AnnualRevenue__c =4;
        oOpp.Total_Employee_Compensation__c = 2;
        oOpp.NumberOfEmployees__c = 1;
        oOpp.Enterprise_Value__c = 5;
        oOpp.Title__c ='Other';
        oOpp.Title_Other__c ='xyz';
        oOpp.Birthdate__c = Date.today().addyears(-20);
        oOpp.President_Type__c ='Owner';
        oOpp.Business_Scope__c = 'National';
        oOpp.Business_Description__c = 'Test Description';
        oOpp.Transition_Via_Renewal_Form__c = TRUE;
        oOpp.Third_Party_Firm__c = 'Test Firm';
        oOpp.Third_Party_Name__c = 'Test Third Party';
        oOpp.Third_Party_Email__c ='test@example.com';
        oOpp.Chapter_Membership_Officer__c = userinfo.getUserId();
        oOpp.KGRenewal__Contact__c = oContact.Id;
        insert oOpp;
           
        OpportunityContactRole oppConRole = new OpportunityContactRole(Contactid=oContact.id,OpportunityId=oOpp.id,IsPrimary=TRUE);
        insert oppConRole;
        
        Exception__c objException = new Exception__c();
        objException.Contact__c = oContact.id;
        objException.Opportunity__c = oOpp.id;
        objException.Account__c = testChapParentAccount.id;
        objException.Exception_Category__c = 'Waiver';
        objException.Type_of_Waiver__c = '	Grace Extension';
        insert objException;
        
        DocusignCustomSetting__c docSign = new DocusignCustomSetting__c(name='Docusign',DocusignAccountID__c='testAccId',TemplateId__c='testTemplateId');
        insert docSign;
        
        Attachment attachOne = new Attachment(name='test attachment');
        attachOne.body = Blob.valueOf('Test attachment');
        Attachment attachTwo = new Attachment(name='test attachment 2');
        attachTwo.body = Blob.valueOf('Test attachment');
        
        Membership_History__c memberHistory = new Membership_History__c(Status__c='Member',Contact__c=oContact.Id);
        insert memberHistory; 
        
        //As HouseHoldId is updated after inserting relationship, we are fetching again the contact record
        List<Contact> refreshContactList = [SELECT Id,Name,RecordtypeId,HouseHoldID__c,Lastname,YPO_WPO__c,AccountId,Account.ParentId,Contact.Grace_Years_Available__c,Is_Grace_Used__c, Grace_Years_Used__c,
                                            Title,Number_of_Employees1__c,Total_Employee_Compensation__c,Last_Renewals_Page__c,Annual_Revenue__c,Enterprise_Value__c, Join_Date__c,
                                            Transition_Status__c,Number_of_Employees__c,Last_Renewals_Form__c FROM Contact WHERE Id=:oContact.id];
        
        System.debug('>> Parent ID : '+refreshContactList[0].Account.ParentId);
        Contact contactSO = refreshContactList[0];
        
        
        Test.startTest();
        ApexPages.StandardController sController = new ApexPages.StandardController(contactSO);
        RenewalContactContExt ext = new RenewalContactContExt(sController);
        
        PageReference pageRef = Page.welcomepage;
        Test.setCurrentPage(pageRef);
        
        System.assert(ContactServices.getChildrenAndSpouse(contactSO) != NULL);
        ext.init();
        System.assert(ext.selectedDesiredWPORegion == regAccount.id);
        
        System.assert(!ext.isOverdueForTransition); 
        ext.makeQualifyingCompanyEditable();
        System.assert(!ext.isQualifyingCompanyEditable);
        
        //WPO Check
        PageReference pg = ext.beginRenewals();
        //System.assert(pg == Page.WPOTransition);
        ext.requestGrace();
        
        ext.redirectTo();
        ext.redirectToLastPage();

        ext.uploadThirdPartyVerifier();
        System.assert(ext.isEmailSent);
        
        ext.attachmentOne = attachOne;
        ext.attachmentTwo = attachTwo;
        ext.uploadThirdPartyCertificationDocuments();
        
        
        Exception_Reason__c exReason = new Exception_Reason__c(name='Grace Extension',category__c=' Grace');
        insert exReason;
        System.assert(ext.graceReasons2.size() >1);
        
        //Use case when grace reason is not selected
        ext.graceReasonSelected = 'None';
        System.assert(ext.createGracecase()==NULL);
        
        //use case when grace reason is selected
        System.debug('>> ext.graceReasons2 : '+ext.graceReasons2);
        ext.graceReasonSelected = ext.graceReasons2.get(1).getValue();
        ext.createGracecase();
        
        List<Case> listGraceCase = [SELECT id,Subject FROM Case WHERE ContactId =: oContact.Id];
        if(!listGraceCase.isEmpty()){
            System.assert(listGraceCase[0].Subject == 'Grace');
            List<Exception__c> listEx = [SELECT Name,Description__c FROM Exception__c WHERE CaseId__c =: listGraceCase[0].id];
            if(!listEx.isEmpty()){
                System.assert(listEx[0].Description__c.equalsIgnoreCase('Came in from Renewals'));
            }
        }
        
        ext.saveDesiredWPOChapter();
        
        List<Opportunity> listOppty = [SELECT Name,Certification_status__c,Transition_Via_Renewal_Form__c  FROM Opportunity WHERE id=:oOpp.id];
        if(!listOppty.isEmpty()){
            System.assert(listOppty[0].Certification_status__c == 'Received'); //updated in uploadThirdPartyCertificationDocuments()
            System.assert(listOppty[0].Transition_Via_Renewal_Form__c); //updated in saveDesiredWPOChapter()
        }
        
        ext.requestTransition();
        ext.toMemberPortal();
        
        ext.saveOnRecertification();
        ext.checkQualificationCriteria();
        ext.changeQualifyingCompany();
        ext.toContactMemberServices();
        ext.toThirdPartyCertification();
        ext.toThirdPartyCertificationUpload();
        ext.toThirdPartyCertificationVerifier();
        
        Test.stopTest();
    }
    
    @isTest
    public static void testSpouseAndChildOperations(){
        Account regAccount = getRegionAccount('Test US');
        insert regAccount;
        Account ChapterAccount = getChapterAccount('WPO Test Chapter',regAccount);
        ChapterAccount.Start_Date__c = System.today();
        insert chapterAccount;
        
        Account oAccount = getAccount('Needs Chapter','Chapter');
        oAccount.parentId = regAccount.id;
       // oAccount.Firm_Type__c ='Public';
        oAccount.Industry = 'Technology';
        oAccount.Sub_Category__c ='Warehousing & Storage';
        oAccount.Is_Subsidiary__c = TRUE;
        oAccount.Parent_Company__c='Test parent';
        oAccount.recordtypeid=  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        insert oAccount;
        System.debug('>> oAccount.parentId : '+oAccount.ParentId);
        
        Account relAccount = getMemberAccount('Test Relationhip Account');
        insert relAccount;
        
        
        Contact oContact = new Contact();
        oContact.AccountId = oAccount.Id;
        oContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        oContact.lastname = 'Test Member Contact';
        oContact.householdId__c =relAccount.id;
        oContact.YPO_WPO__c = 'YPO';
        oContact.Transition_Status__c =  'Overdue for transition';
        //oContact.Grace_Years_Accrued__c = 10;
        oContact.Grace_Accrued_FY17__c =10;
        oContact.Is_Grace_Used__c = FALSE;
        oContact.Date_Last_Grace_Year_Used__c = Date.newInstance(System.Today().year(), 8, 1);
        insert oContact; 
        system.debug('>>oContact.householdId__c : '+oContact.householdId__c );
        
        //As HouseHoldId is updated after inserting relationship, we are fetching again the contact record
        List<Contact> refreshContactList = [SELECT Id,Name,RecordtypeId,HouseHoldID__c,Lastname,YPO_WPO__c,AccountId,Account.ParentId,Contact.Grace_Years_Available__c,Is_Grace_Used__c, Grace_Years_Used__c,
                                            Title,Number_of_Employees1__c,Total_Employee_Compensation__c,Last_Renewals_Page__c,Annual_Revenue__c,Enterprise_Value__c,
                                            Transition_Status__c,Number_of_Employees__c,Last_Renewals_Form__c FROM Contact WHERE Id=:oContact.id];
        
        System.debug('>> Parent ID : '+refreshContactList[0].Account.ParentId);
        Contact contactSO = refreshContactList[0];
        
        Test.startTest();
        ApexPages.StandardController sController = new ApexPages.StandardController(contactSO);
        RenewalContactContExt ext = new RenewalContactContExt(sController);
        
        PageReference pageRef = Page.welcomepage;
        Test.setCurrentPage(pageRef);
        //Call related to child and spouse
        ext.addSpouse();
        ext.addChild();
        System.assert(!ext.lstChild.isEmpty());
        System.assert(!ext.lstSpouse.isEmpty());
        
        ext.addSpouse();
        System.assert(ext.isSpouseAvailabe);
        
        ext.saveSpouseAndChild();
        
        List<Relationship__c> listRelationship = [SELECT Id, Is_Active__c, Account__c FROM Relationship__c WHERE account__c = :relAccount.Id AND Is_Active__c = true];
        System.assert(!listRelationship.isEmpty());
        
        ext.rownumber = 0;
        ext.removeChild();
        System.assert(ext.lstChild == null);
        ext.removeSpouse();
        System.assert(ext.lstSpouse == null);
        ext.WPOCheck();
        
        Test.stopTest();
    } 
    
    @isTest
    public static void testExceptions(){
    
        Account regAccount = getRegionAccount('Test US');
        insert regAccount;
        
         Account testChapParentAccount = getAccount('Parent Chapter','Chapter');
        insert testChapParentAccount;
        
        Account oAccount = getAccount('Needs Chapter','Chapter');
        oAccount.parentId = regAccount.id;
        oAccount.Industry = 'Technology';
        oAccount.Sub_Category__c ='Warehousing & Storage';
        oAccount.Is_Subsidiary__c = TRUE;
        oAccount.Parent_Company__c='Test parent';
        oAccount.recordtypeid=  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
       // oAccount.Firm_Type__c='';
        insert oAccount;
        System.debug('>> oAccount.parentId : '+oAccount.ParentId);
        
        Contact oContact = new Contact();
        oContact.AccountId = oAccount.Id;
        oContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        oContact.lastname = 'Test Member Contact';
        oContact.YPO_WPO__c = 'YPO';
        oContact.Transition_Status__c =  'Overdue for transition';
        //oContact.Grace_Years_Accrued__c = 10;
        oContact.Grace_Accrued_FY17__c = 10;
        oContact.Is_Grace_Used__c = FALSE;
        oContact.Date_Last_Grace_Year_Used__c = Date.newInstance(System.Today().year(), 8, 1);
        insert oContact; 
        
        
        Opportunity oOpp= getOpportunity('Test Oppty','Cycle Open','Third Party Certify',Date.today().addYears(2));
        oOpp.AccountId = oAccount.id;
        oOpp.Qualifying_Company__c='Test Company';
        oOpp.Organization_Type__c ='Sales';
        oOpp.AnnualRevenue__c =4;
        oOpp.Title__c='';
        oOpp.NumberOfEmployees__c = null;
        oOpp.Total_Employee_Compensation__c = 2;
        oOpp.Enterprise_Value__c = 5;
        oOpp.Birthdate__c = Date.today().addyears(-20);
        oOpp.President_Type__c ='Owner';
        oOpp.Business_Scope__c = 'National';
        oOpp.Business_Description__c = 'Test Description';
        oOpp.Transition_Via_Renewal_Form__c = TRUE;
        oOpp.KGRenewal__Contact__c = oContact.Id;
        insert oOpp;
        
         
        OpportunityContactRole oppConRole = new OpportunityContactRole(Contactid=oContact.id,OpportunityId=oOpp.id,IsPrimary=TRUE);
        insert oppConRole;
        
        Account accForAff = getAccount('Affiliated Account','Business');
       // accForAff.Firm_Type__c = 'Public';
        //insert accForAff;
        //As HouseHoldId is updated after inserting relationship, we are fetching again the contact record
        List<Contact> refreshContactList = [SELECT Id,Name,RecordtypeId,HouseHoldID__c,Lastname,YPO_WPO__c,AccountId,Account.ParentId,Contact.Grace_Years_Available__c,Is_Grace_Used__c, Grace_Years_Used__c,
                                            Title,Number_of_Employees1__c,Total_Employee_Compensation__c,Last_Renewals_Page__c,Annual_Revenue__c,Enterprise_Value__c,
                                            Transition_Status__c,Number_of_Employees__c,Last_Renewals_Form__c FROM Contact WHERE Id=:oContact.id];
        
        System.debug('>> Parent ID : '+refreshContactList[0].Account.ParentId);
        Contact contactSO = refreshContactList[0];
        Test.startTest();
        ApexPages.StandardController sController = new ApexPages.StandardController(new Contact());
        RenewalContactContExt ext = new RenewalContactContExt(sController);
        
        PageReference pageRef = Page.welcomepage;
        Test.setCurrentPage(pageRef);
        
        Attachment attachOne = ext.attachmentOne;
        Attachment attachTwo = ext.attachmentTwo;
        ext.init();
        ext.WPOCheck();
        ext.uploadThirdPartyCertificationDocuments();
        ext.saveSpouseAndChild();
        ext.graceReasonSelected = 'Grace Reason';
        try{
            ext.createGracecase();
        }Catch(Exception ex){}
        
        RenewalContactContExt extnsn = new RenewalContactContExt(new ApexPages.StandardController(contactSO));
        extnsn.changeQualifyingCompany();
        
        Test.stopTest();
    }
    
    @isTest
    public static void testProperties() {
    	Account oAccount = new Account();
        oAccount.recordtypeid=  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        oAccount.Industry = 'Technology';
        oAccount.Sub_Category__c ='Warehousing & Storage';
        oAccount.Is_Subsidiary__c = TRUE;
        oAccount.Parent_Company__c='Test parent';
        oAccount.Name = 'Acc';
        insert oAccount;
        
		Contact oContact = new Contact();
        oContact.AccountId = oAccount.Id;
        oContact.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member','Contact').Id;
        oContact = (Contact)JSONUtils.setField(oContact, 'Record_Type_Name__c', 'Member');
        oContact.lastname = 'Test Member Contact';
        oContact.YPO_WPO__c = 'YPO';
        oContact.Transition_Status__c =  'Eligible for early transition';
        //oContact.Grace_Years_Accrued__c = 10;
        oContact.Grace_Accrued_FY17__c = 10;
        oContact.Is_Grace_Used__c = FALSE;
        oContact.Date_Last_Grace_Year_Used__c = Date.newInstance(System.Today().year(), 8, 1);
        oContact.Join_date__c = Date.newInstance(2000, 1, 1);
        oContact.Number_of_Employees__c = 10;
        oContact.Annual_Assets__c = 10;
        oContact.Annual_Fees__c = 10;
        oContact.Annual_Revenue__c = 10;
        
        insert oContact; 
        
		Opportunity testOpp = (Opportunity) SObjectFactory.build(Opportunity.SObjectType);
		//testOpp.RecordTypeId = RecordTypeServices.getRecordTypeByName('Member','Opportunity').Id;
		testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Member').getRecordTypeId();
		testOpp.Fiscal_Date_Start__c = FiscalDateUtility.startOfNextFiscal;
		testOpp.NumberOfEmployees__c = 100;
		testOpp.Enterprise_Value__c = 100;
		testOpp.AnnualRevenue__c = 100;
		testOpp.NumberOfEmployees__c = 100;
		testOpp.Organization_Type__c = 'Agency-Type';
		testOpp.StageName = 'Cycle Open';
		testOpp.KGRenewal__IsActiveCart__c = true;
		testOpp.KGRenewal__Contact__c = oContact.Id;
		insert testOpp;
		
		OpportunityContactRole oppConRole = new OpportunityContactRole(Contactid=oContact.id,OpportunityId=testOpp.id,IsPrimary=TRUE);
        insert oppConRole;
        
    	String testStr;
    	PageReference pr;
    	
    	ApexPages.StandardController sController = new ApexPages.StandardController(oContact);
        RenewalContactContExt ext = new RenewalContactContExt(sController);
        
    	Test.startTest();
    		testStr = RenewalContactcontExt.CONST_CONTACT;
    		testStr = RenewalContactcontExt.CONST_SPOUSE;
    		testStr = RenewalContactcontExt.CONST_CHILD;
    		testStr = RenewalContactcontExt.CONST_MEMBER;
    		testStr = RenewalContactcontExt.TRANSITION_STATUS_OVERDUE;
    		testStr = RenewalContactcontExt.TRANSITION_STATUS_ELIGIBLE;
    		testStr = RenewalContactcontExt.CERTIFICATION_STATUS_RECEIVED;
    		
    		pr = ext.toVCatalog();
    	Test.stopTest();
    }
   }