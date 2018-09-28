/*
 * 
 * TestServices is a service class for settingup test data for any test method.  
 * Generic test setup methods should be added here.
 *
 * @author Shri K
 */
 
@isTest
public class TestServices {
    
    static final String CONST_CHAPTER_HEALTH = 'Chapter_Health__c';
    static final String CONST_REGIONAL_HEALTH = 'Region_Health__c';
    static final String HISTORY = 'History';
    static final String CURRENT = 'Current';
    
    /**
     * instantiates test account. 
     * 
     * @param: sName is String variable for account name
     * @return: newly instantiated Account object.
     */
    public static Account createAccount(String sName)
    {
        Account oAccount = new Account();
        oAccount.Name = sName;
        oAccount.Annual_Compensation__c = 100;        
        oAccount.Status__c = 'Active';
        oAccount.Start_Date__c = system.today();
        return oAccount; 
    }
    
    /**
     * instantiates test contact for given account. 
     * 
     * @param: accountId is id of the account whose contacts need to be instantiated.
     * @param: LastName of the contact
     * @return: newly instantiated Contact object.
     */
    public static Account_Affiliation__c createAccountAffiliation(Id accountId, Id contactId)
    {
        Account_Affiliation__c oAccAff = new Account_Affiliation__c();
        oAccAff.Account__c = accountId;
        oAccAff.Contact__c = contactId;
        oAccAff.Start_Date__c = system.today();
        oAccAff.RecordTypeId = RecordTypeServices.getRecordTypeByName('Chapter','Account_Affiliation__c').Id;
        return oAccAff; 
    }
    /**
     * instantiates test Relationship__c record. 
     * 
     * @param: contactId is id of the contact for whom relationship is to be created.
     * @param: accountId is id of the household account.
     * @param: sRelationshipType is the type of relationship that needs to be created.
     * @return: newly instantiated Relationship record.
     */
    public static Relationship__c createRelationship(Id contactId, Id accountId, String sRelationshipType)
    {
        return createRelationship(contactId, accountId, sRelationshipType, true, false);
    }
    public static Relationship__c createRelationship(Id contactId, Id accountId, String sRelationshipType, Boolean isActive, Boolean doInsert)
    {
        Relationship__c rel = new Relationship__c(Contact__c = contactId, Account__c = accountId, Is_Active__c = isActive, Relationship_Type__c = sRelationshipType);
        if(doInsert)insert rel;
        return rel;
    }
    public static Contact createContactForMarketingSegmentation(Id accountId)
    {
        Contact oContact = createContact(accountId);
        oContact.Int_Arts_and_Entertainment__c = 'Antiques; Art Collecting; Dance; Film; Music; Opera; Painting; Theatre'; 
        /*oContact.Int_Lifestyle__c ='Sustainable Development';
        oContact.Exp_Business__c = 'Doing Business in India';
        oContact.Exp_Management_Team__c = 'Chapter Health';
        oContact.Exp_Business_Travel_Frequency__c = 'Travel Rarely (0-5)';
        oContact.Int_Outdoor__c = 'Climbing';
        oContact.Int_Community_Service__c = 'Benefit';
        oContact.Exp_Regional_Contacts__c = 'Canada Regional Contacts';
        oContact.Exp_Family__c = 'Family Finances';*/
        oContact.Int_Sports__c = 'Ice Hockey; Running; Surfing; Swimming; Tennis; Water Skiing; Windsurfing';
        //oContact.Exp_Family_Leisure_Travel_Frequency__c = 'Travel Rarely (0-5)';
        //oContact.Int_Team_Sports__c = 'Football';
        oContact.Int_General__c = 'Collecting Wines; Cooking; Film; Fine Dining; History; Investing; Photography';
        /*oContact.Int_Travel__c = 'Adventure Travel';
        oContact.Int_Health__c = 'Fitness;Stress Management';
        oContact.Exp_YPO__c = 'Champion a Seminar;Champion an Experience';
        oContact.Exp_Leadership__c = 'Executive;Family Leadership';
        oContact.Exp_YPO_Internal__c = 'Non-Complaint';
        oContact.Int_Learning_More__c = 'Leadership';*/ 
        return oContact;
    }
    
    /**
     * instantiates test Interest__c record. 
     * 
     * @param: contactId is id of the contact for whom Interest is to be created.
     * @param: sCategory category of the interest.
     * @param: sInterest is the name of the interests ; seperated. 
     * @return: newly instantiated Interest record.
     */
    public static Interest__c createInterest(Id contactId, String sCategory, String sInterest)
    {
        Interest__c oInterest = new Interest__c();
        oInterest.Category__c = sCategory;
        oInterest.Interest__c = sInterest;
        oInterest.Contact__c = contactId;
        return oInterest; 
    }
    
    /**
     * instantiates test Skillset record. 
     * 
     * @param: contactId is id of the contact for whom Skillset is to be created.
     * @param: sCategory category of the interest.
     * @param: sSubCategory is the name of the sub category 
     * @param: sExpertise is the name of the expertise  ; seperated.
     * @return: newly instantiated Skillset record.
     */
    public static M2MX_Skillsets__c createSkillset(Id contactId, String sCategory, String sSubCategory, String sExpertise)
    {
        M2MX_Skillsets__c oSkillset = new M2MX_Skillsets__c();
        oSkillset.Category__c = sCategory;
        oSkillset.Sub_Category__c = sSubCategory;
        oSkillset.Expertise__c = sExpertise;
        oSkillset.Contact__c = contactId;
        return oSkillset; 
    }
    
    /**
     * instantiates test Marketing Segmentation custom setting records. 
     * 
     * @param: sName is name of the customsetting. This should be unique across.
     * @param: sInterestValue Name of the interest.
     * @param: sMultificationFactor is the multiplication factor for interest. 
     * @param: sSegmentFactor is the segmentation factor for given segmentation.
     * @return: newly instantiated marketing segmentation custom setting.
     */
    public static Marketing_Segmentation__c createMarketingSegmentation(String sName, String sInterestValue, String sMultificationFactor, String sSegmentFactor)
    {
        Marketing_Segmentation__c oMarketingSegmentation = new Marketing_Segmentation__c();
        oMarketingSegmentation.Name = sName;
        oMarketingSegmentation.Interest_Value__c = sInterestValue;
        oMarketingSegmentation.Multiplication_Factor__c = String.isBlank(sMultificationFactor) ? 0 : Decimal.valueOf(sMultificationFactor);
        oMarketingSegmentation.Segment_Factor__c = String.isBlank(sSegmentFactor) ? 0 : Decimal.valueOf(sSegmentFactor);
        return oMarketingSegmentation;
    }
    
    /**
     * instantiates test Region Health for given account. 
     * 
     * @param: accountId is id of the account whose Region Health need to be instantiated.
     * @return: newly instantiated Region Health object.
     */
    public static Region_Health__c createRegionHealth(Id accountId)
    {
        Region_Health__c oRegionHealth = new Region_Health__c();
        oRegionHealth.RecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CURRENT, CONST_REGIONAL_HEALTH).Id;
        oRegionHealth.Account__c = accountId;
        return oRegionHealth; 
    }
    
    /**
     * instantiates test Chapter Health for given Region Health. 
     * 
     * @param: regionHealthId is id of the account whose Chapter Health need to be instantiated.
     * @param: accountId is id of the account whose Region Health need to be instantiated.
     * @return: newly instantiated Chapter Health object.
     */
    public static Chapter_Health__c createChapterHealth(Id regionHealthId, Id accountId, Id chapterHealthCurrentRecordTypeId)
    {
        Chapter_Health__c oChapterHealth = new Chapter_Health__c();
        oChapterHealth.RecordTypeId = chapterHealthCurrentRecordTypeId;
        oChapterHealth.Account__c = accountId;
        oChapterHealth.Region_Health__c = regionHealthId;
        return oChapterHealth; 
    }
    
    /**
     * instantiates test Case record with no parameters. 
     * 
     * @return: newly instantiated Case object.
     */
    public static Case createCase(){
        Case testCase = new Case();
        return testCase;
    }
    
    /**
     * instantiates List of Custom Setting object M2MX_Skillset_Search_Objects__c. 
     * 
     * @param: List of API Names 
     * @return: newly instantiated List of M2MX_Skillset_Search_Objects__c.
     */
    public static List<M2MX_Skillset_Search_Objects__c> createM2MXSkillsetSearchObjects(List<String> lstAPIName){
        
        List<M2MX_Skillset_Search_Objects__c> lstCS = new List<M2MX_Skillset_Search_Objects__c>();
        for(String apiName : lstAPIName){
            M2MX_Skillset_Search_Objects__c cs = new M2MX_Skillset_Search_Objects__c();
            cs.Name = apiName.removeEnd('__c').replace('_',' ');
            cs.API_Name__c = apiName;
            lstCS.add(cs);
        }
        
        return lstCS;
    }
    /**
     * instantiates List of Custom Setting object M2MX_Skillset_Search_Objects__c. 
     * 
     * @param: objectName API Name of the object.
     * @param: MultiselectPicklist_Field_API_Name Comma seprated string of multiselect picklist fields.
     * @param: Text_Field_API_Name Field API name of text field where concatenation needs to be stored
     * @param: doInsert 
     * @return: newly instantiated List of M2MX_Skillset_Search_Objects__c.
     */
    public static M2MX_Skillset_Search_Objects__c createM2MXSkillsetSearchObject(String objectName, String MultiselectPicklist_Field_API_Name, String Text_Field_API_Name, Boolean doInsert){
        
        M2MX_Skillset_Search_Objects__c cs = 
            new M2MX_Skillset_Search_Objects__c(Name = objectName,
                                                API_Name__c = objectName,
                                                MultiselectPicklist_Field_API_Name__c = MultiselectPicklist_Field_API_Name,
                                                Text_Field_API_Name__c = Text_Field_API_Name
                                                );
           if(doInsert)
               insert cs;
        
        return cs;
    }
     /**
     * instantiates test partner community user. 
     * 
     * @param: contactId is id of the contact
     * @param: profileId is profile Id for partner
     * @return: newly instantiated partner community user.
     */
    public static user createPartnerCommunityUser(Id contactId, Id profileId)
    {
		Id  PartnerUserRole = [SELECT Id FROM UserRole WHERE PortalType = 'Partner' LIMIT 1].Id;

		contact oContact = new contact();
		if (string.isEmpty(profileId))
			profileId = [SELECT id FROM Profile WHERE Name = 'Partner User'].id;
		if (String.isEmpty(contactId)) {
			oContact = createContact(createChapterAccount('Test Chapter','').Id, true);
		} else {
			oContact = [SELECT Id, email FROM Contact WHERE id =: contactId];
		}

        User user1 = new User(
						userRoleId = PartnerUserRole,
                        contactid=oContact.id,
                        profileid=profileId,
                        email=oContact.Email,
                        Username=oContact.Email,
                        alias=oContact.Email.substring(18, 23), 
                        CommunityNickName='userCom1',
                        TimeZoneSidKey='America/New_York', 
                        LocaleSidKey='en_US', 
                        EmailEncodingKey='ISO-8859-1',
                        LanguageLocaleKey='en_US', 
                        FirstName='TestUser1', 
                        LastName='User1',
						IsActive = true );
		return user1;
    }

	@Future
    public static void createPartnerCommunityUserFuture(Id contactId, Id profileId)
    {
		insert createPartnerCommunityUser(contactId, profileId);
    }
    
    /**
     * instantiates test chapter account. 
     * 
     * @param: sName is String variable for chapter name
     * @param: chapterRecordTypeId is id of chapter Recordtype account
     * @return: newly instantiated Chapter Account object.
     */
    public static Account createChapterAccount(String sName, Id chapterRecordTypeId)
    {
        Account oAccount = new Account();
        oAccount.Name = sName;
        oAccount.Type = 'Chapter';
		if (string.isEmpty(chapterRecordTypeId))
			oAccount.RecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Chapter', 'Account').Id;
		else
			oAccount.RecordTypeId = chapterRecordTypeId;
        oAccount.Annual_Compensation__c = 10000000;
        return oAccount; 
    }
    
    /**
     * instantiates test CA Setting. 
     * 
     * @param: chapterId is Id for chapter account
     * @param: userId is id of user
     * @param: bActive is boolean for status active
     * @return: newly instantiated CA Setting object.
     */
    public static CA_Setting__c createCASetting(Id chapterId, Id userId, boolean bActive)
    {
        CA_Setting__c oCASetting = new CA_Setting__c();
        oCASetting.Chapter__c = chapterId;
        oCASetting.User__c = userId;
        oCASetting.isActive__c = bActive;
        oCASetting.Role__c= 'Chapter Administrator';
        return oCASetting; 
    }
     /**
     * instantiates List of object Contact_Position__c. 
     * 
     * @param: objectName API Name of the object.
     * @param: MultiselectPicklist_Field_API_Name Comma seprated string of multiselect picklist fields.
     * @param: Text_Field_API_Name Field API name of text field where concatenation needs to be stored
     * @param: doInsert 
     * @return: newly instantiated List of M2MX_Skillset_Search_Objects__c.
     */
    public static Contact_Position__c createContactPosition(Id Account, Id Contact, Id Position, String status, Boolean doInsert){
        
        Contact_Position__c cp = 
            new Contact_Position__c(Account__c = Account,
                                                Contact__c = Contact,
                                                Position__c = Position,
                                                Status__c = status,
                                                Start_Date__c = system.today(),
                                                End_Date__c = system.today().adddays(1),
                                                Committee_Member_Type__c= 'Member'
                                                );
           if(doInsert)
               insert cp;
        
        return cp;
    }
         /**
     * instantiates object Position__c. 
     * 
     * @param: doInsert 
     * @return: newly instantiated Position__c.
     */
    public static Position__c createPosition( Boolean doInsert){
        
        Position__c pos = 
            new Position__c(Position_Category__c ='Network',
                            Title__c = 'Title',
                            Position_Status__c = 'Active',
                            Member_Type__c = 'Member',
                            Start_Date__c = System.today());
                            
           if(doInsert)
               insert pos;
        
        return pos;
    }
    
    public static Account createAccount(Boolean doInsert){
        Account account = new Account();
        account.Name = 'Test Account' + System.now();
        account.YPOI_Type__c = 'YPO';
        account.Status__c = 'Active';
        account.Type = 'Chapter';
        account.Date_Board_Approved__c = System.today() - 7;
        
        if(doInsert){
            insert account;
        }
        
        return account;
    }
    
    public static Contact createContact(Id ChapterAccountId)
    {
		string lastname = 'TestContact';
		id RecTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Member','Contact').id;
		return createContact(ChapterAccountId,lastname,RecTypeId,false);
    }
    
    public static Contact createContact(String lastName, Id ChapterAccountId)
    {
		id RecTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Member','Contact').Id;
		return createContact(ChapterAccountId,lastname,RecTypeId,false);
    }
    
    public static Contact createContact(String ChapterAccountId, Boolean doInsert){
		string lastname = 'TestContact';
		id RecTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Member','Contact').id;
		return createContact(ChapterAccountId,lastname,RecTypeId,doInsert);
    }
    public static Contact createContact(Id ChapterAccountId, Id RecTypeId, Boolean doInsert){
		string lastname = 'TestContact';
		return createContact(ChapterAccountId,lastname,RecTypeId,doInsert);
    }

	public static Contact createContact(Id ChapterAccountId, String lastname, Boolean doInsert){
		id RecTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Member','Contact').id;
		return createContact(ChapterAccountId,lastname,RecTypeId,doInsert);
	}

    public static Contact createContact(Id ChapterAccountId, String LastName, id RecordTypeid, Boolean doInsert){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*100));
        String uniqueName = orgId + dateString + randomInt;
		
        Contact contact = new Contact();
        contact.recordTypeId = RecordTypeid;
        contact.LastName = LastName;    
        contact.YPO_WPO__c = 'YPO';
		contact.Number_Years_a_Member__c = 0;
		contact.Join_Date__c = Date.today().addYears(-1);
		contact.Number_of_Employees__c = 50;
		contact.Number_of_Employees_opt_2__c = 15;
		contact.Annual_Assets__c = 2000000;
        contact.Annual_Revenue__c = 9000000;
        contact.Total_Employee_Compensation__c = 2500000;
        contact.AccountId = ChapterAccountId;
        //contact.Grace_Years_Accrued__c = 3;
        contact.Grace_Accrued_FY17__c = 10;
        contact.Preferred_Phone__c = 'Home Phone';
		contact.Home_Phone_Country_Code__c = '1';
		contact.HomePhone = '(456) 987-1230';
        contact.Email = uniqueName + '@test' + orgId + '.org';
        contact.mailingcountry='United States';
        contact.MailingStreet = '123 Main St';
        contact.MailingState = 'Georgia';
        contact.MailingCity = 'Atlanta';
        contact.MailingPostalCode = '30363';
        contact.Othercountry='India';
        contact.OtherStreet = 'SV Road';
        contact.OtherState = 'Maharashtra';
        contact.OtherCity = 'Mumbai';
        contact.OtherPostalCode = '400101';
        if(doInsert){
            insert contact;
        }
        
        return contact;
    }

    /**
     * instantiates test contact in bulk for given account. 
     * 
     * @param: accountId is id of the account whose contacts need to be instantiated.
     * @param: iCount is integer specifies number of contact needs to be created.
     * @return: newly instantiated list of Contact objects.
     */
    public static List<Contact> createContacts(Id accountId, Integer iCount)
    {
        List<Contact> lstContact = new List<Contact>();
        for(Integer i=0; i<iCount; i++)
        {
            lstContact.add(createContact(accountId));    
        }
        
        return lstContact;
    }
    
    public static Opportunity createOpp(String accountId, Boolean doInsert){
        Opportunity opp = new Opportunity();
        opp.AccountId = accountId;
        opp.CartToken__c = '%2FM1F6b82rEcWIRpOdpi7uYhUR4065Ulw%2BRi%2Fp7o8hw7ybKRB%2FXc9biQ56WEB5ip%2F';
        opp.Amount = 17600;
        opp.AnnualRevenue__c = 90000000;
        opp.Enterprise_Value__c = 2500000;
        opp.Name = 'Test Opp' + System.now();
        opp.CloseDate = System.today() + 30;
        opp.StageName = 'Closed Won';
               
        if(doInsert){
            insert opp;
        }
        return opp;
    }

	public static Opportunity createOpp(string StageName, id ChapterAccountId, id ContactId, Boolean doInsert) {
        Opportunity opp = new Opportunity();
        opp.AccountId = ChapterAccountId;
        opp.CartToken__c = '%2FM1F6b82rEcWIRpOdpi7uYhUR4065Ulw%2BRi%2Fp7o8hw7ybKRB%2FXc9biQ56WEB5ip%2F';
        opp.Amount = 17600;
        opp.AnnualRevenue__c = 90000000;
        opp.Enterprise_Value__c = 2500000;
        opp.Name = 'Test Opp' + System.now();
        opp.StageName = StageName;
		opp.Contact__c = ContactId;
		opp.KGRenewal__Contact__c = ContactId;
		opp.KGRenewal__BillingFrequency__c = 'Single payment';
		if (StageName == 'Cycle Open') {
			opp.Profile_Page_Status_Exchange__c = 'Not Started';
			opp.Certification_Page_Status_Exchange__c = 'Not Started';
			opp.Dues_Page_Status_Exchange__c = 'Not Started';
			opp.Opportunity_Type__c = 'Renewal';
			opp.Fiscal_Date_Start__c = Date.newInstance(Date.today().year(),7,1);
			opp.CloseDate = opp.Fiscal_Date_Start__c.addYears(1);
			Opp.KGRenewal__ContractEffectiveDate__c = Date.newInstance(Date.today().year(),7,1);
			//Opp.KGRenewal__ContractEndDate__c = Opp.Fiscal_Date_Start__c.addYears(1) - 1;
			//opp.KGRenewal__BillingPeriod__c = 12;
			opp.KGRenewal__IsActiveCart__c = true;
		} else if (StageName == 'New') {
			opp.Profile_Page_Status_Exchange__c = 'Not Started';
			opp.Certification_Page_Status_Exchange__c = 'Not Started';
			opp.Dues_Page_Status_Exchange__c = 'Not Started';
			opp.Opportunity_Type__c = 'Prospect';
			opp.Fiscal_Date_Start__c = FiscalDateUtility.startOfCurrentFiscal;
			opp.CloseDate = opp.Fiscal_Date_Start__c.addYears(1);
			Opp.KGRenewal__ContractEffectiveDate__c = FiscalDateUtility.startOfCurrentFiscal;
			//Opp.KGRenewal__ContractEndDate__c = Opp.Fiscal_Date_Start__c.addYears(1) - 1;
			//opp.KGRenewal__BillingPeriod__c = 12;
			opp.KGRenewal__IsActiveCart__c = false;
		} else if (StageName == 'Payment Pending') {
			opp.Profile_Page_Status_Exchange__c = 'Complete';
			opp.Certification_Page_Status_Exchange__c = 'Complete';
			opp.Dues_Page_Status_Exchange__c = 'In Progress';
			opp.Opportunity_Type__c = 'Renewal';
			opp.Fiscal_Date_Start__c = Date.newInstance(Date.today().year(),7,1);
			opp.CloseDate = opp.Fiscal_Date_Start__c.addYears(1);
			Opp.KGRenewal__ContractEffectiveDate__c = Date.newInstance(Date.today().year(),7,1);
			//Opp.KGRenewal__ContractEndDate__c = Opp.Fiscal_Date_Start__c.addYears(1) - 1;
			//opp.KGRenewal__BillingPeriod__c = 12;
			opp.KGRenewal__IsActiveCart__c = false;
		} else {
			opp.Profile_Page_Status_Exchange__c = 'Complete';
			opp.Certification_Page_Status_Exchange__c = 'Complete';
			opp.Dues_Page_Status_Exchange__c = 'Complete';
			opp.Opportunity_Type__c = 'Renewal';
			opp.Fiscal_Date_Start__c = Date.newInstance(Date.today().year(),7,1);
			opp.CloseDate = opp.Fiscal_Date_Start__c.addYears(1);
			Opp.KGRenewal__ContractEffectiveDate__c = Date.newInstance(Date.today().year(),7,1);
			//Opp.KGRenewal__ContractEndDate__c = Opp.Fiscal_Date_Start__c.addYears(1) - 1;
			//opp.KGRenewal__BillingPeriod__c = 12;
			opp.KGRenewal__IsActiveCart__c = false;
		}
        if(doInsert){
			try{
				insert opp;
			} catch (Exception e) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
			}
			System.assert((contactid != null && opp.id != null),'Ids should not be null for Role creation.');
			createOppConRole(ContactId,opp.id);
        }
        return opp;
	}

	public static OpportunityContactRole createOppConRole(Id ContactId, id OpportId) {
		String ocrRole = KGRenewal__VenueSettings__c.getOrgDefaults().KGRenewal__BuyerRole__c;
        OpportunityContactRole oppConRole = new OpportunityContactRole(Contactid=ContactId,OpportunityId=OpportId,Role=ocrRole,IsPrimary=TRUE);
        insert oppConRole;
		return oppConRole;
	}

    public static Exception__c createException(String accountId, String contactId, String oppId, String status, Boolean doInsert){
        Exception__c exp = new Exception__c();
        exp.Account__c = accountId;
        exp.Contact__c = contactId;
        exp.Opportunity__c = oppId;
        exp.Annual_Revenue_Dollar_Business_Volume__c = 90000000;
        exp.Total_Employee_Compensation__c = 2500000;
        exp.Status__c = status;
        
        if(doInsert){
            insert exp;
        }
        
        return exp;
    }
    public static Lead createLead(String lastName, String status, Id chapterId, Boolean doInsert){
        Lead testLead = new Lead(
            lastName = lastName,
            status = status,
            Referred_by_Chapter__c = chapterId,
            Preferred_Phone__c = 'Business',
            Phone = '1234567890',
            Email = 'xyz@eee.org',
            Gender__c = 'Male',
            Address_Type__c = 'Business',
            Company = 'test',
            Street = 'MG Road',
            City = 'Mumbai',
            State = 'Maharashtra',
            PostalCode = '400101',
            Country = 'India');
        
        if(doInsert){
            insert testLead;
        }        
        return testLead;
    }
    public static CA_Setting__c createCASetting(Id chapterId, Id userId, boolean bActive, Boolean doInsert)
    {
        CA_Setting__c oCASetting = new CA_Setting__c();
        oCASetting.Chapter__c = chapterId;
        oCASetting.User__c = userId;
        oCASetting.isActive__c = bActive;
        oCASetting.Role__c = 'Chapter Administrator';
        if(doInsert){
            insert oCASetting;
        } 
        return oCASetting; 
    }
    public static Lead_Share_Settings__c createLead_Share_Settings(String leadStatus, String accessLevel, Boolean doInsert)
    {
        Lead_Share_Settings__c leadShareSetting = new Lead_Share_Settings__c(
            Name = LeadStatus,
            Lead_Status__c = leadStatus, 
            CA_Access_Level__c = accessLevel);
        
        if(doInsert){
            insert leadShareSetting;
        }        
        return leadShareSetting;
    }
    public static Contact_Share_Settings__c createContact_Share_Settings(String rtDevName, String accessLevel, Boolean doInsert)
    {
        Contact_Share_Settings__c contactShareSetting = new Contact_Share_Settings__c(
            Name = rtDevName,
            Contact_RecordType_DeveloperName__c = rtDevName, 
            CA_Access_Level__c = accessLevel);
        
        if(doInsert){
            insert contactShareSetting ;
        }        
        return contactShareSetting ;
    }
    public static Account_Affiliation__c createAccountAffiliation(Id accountId, Id contactId, Boolean isActive, Id rtId, Boolean doInsert)
    {
        Account_Affiliation__c oAccAff = new Account_Affiliation__c();
        oAccAff.Account__c = accountId;
        oAccAff.Contact__c = contactId;
        oAccAff.IsActive__c = IsActive;
        oAccAff.Start_Date__c = system.today();
        oAccAff.RecordTypeId = rtId;
        if(doInsert) insert oAccAff;
        return oAccAff; 
    }
    public static Account_Affiliation__c createAccountAffiliation(Id accountId, Id contactId, Date startDate, Boolean isActive, Boolean isPrimary, Id rtId, Boolean doInsert)
    {
        Account_Affiliation__c oAccAff = new Account_Affiliation__c();
        oAccAff.Account__c = accountId;
        oAccAff.Contact__c = contactId;
        oAccAff.IsActive__c = IsActive;
        oAccAff.Start_Date__c = startDate;
        oAccAff.RecordTypeId = rtId;
        oAccAff.Is_Primary__c = isPrimary;
        if(doInsert) insert oAccAff;
        return oAccAff;         
    }
    public static Region_Health__c createRegionHealth(Id accountID, Boolean doInsert){
        Region_Health__c regHealth = new Region_Health__c();
        regHealth.Account__c = accountID;
        if(doInsert) insert regHealth;
        return regHealth;
    }
    
    public static Chapter_Health__c createChapterHealth(Id regHealthID, Id accountID, Id recTypeID, Boolean doInsert){
        Chapter_Health__c chapHealth = new Chapter_Health__c();
        chapHealth.Region_Health__c = regHealthID;
        chapHealth.Account__c = accountID;
        chapHealth.RecordTypeId = recTypeID;
        chapHealth.Fiscal_year__c = '2014-2015';
        chapHealth.Report_Year__c = 2015;
        if(doInsert) insert chapHealth;
        return chapHealth;
            }
    
    public static Chapter_Health_Batch__c createChapterHealthBatch(String targetFieldAPIName,
                                                                   Boolean isBatchQuarterly, Boolean isBatchYearly,
                                                                   Boolean doInsert){
        Chapter_Health_Batch__c chapHealthBatch = new Chapter_Health_Batch__c();   
        chapHealthBatch.Target_Field_API_Name__c = targetFieldAPIName;                                
        chapHealthBatch.Keep_Quarterly__c = isBatchQuarterly;
        chapHealthBatch.Keep_Yearly__c = isBatchYearly;
        if(doInsert) insert chapHealthBatch;
        return chapHealthBatch;                                                       
       }


	/**
	* @description Create opportunity line items of the specified type
	* @param oppId Opportunity Id
	* @param count Number of records to create
	* @param prodFamily Product Family (Member Benefit, Lifetime, Annual Dues, etc.)
	* @param doInsert Insert records after creation
	*/ 
	public static List<OpportunityLineItem> createOppLineItems(Id oppId, Integer count, String prodFamily, Boolean doInsert) {
		if (count > 0) {
			Id pricebookId = Test.getStandardPricebookId();
			List<Product2> products = new List<Product2>();
			List<PriceBookEntry> prices = new List<PricebookEntry>();
			List<OpportunityLineItem> olis = new List<OpportunityLineItem>();

			for (Integer i = 0; i < count; i++) {
				products.add(new Product2(
					Name = 'TestProd - ' + prodFamily, 
					IsActive = true, 
					KGRenewal__eCommerceEnabled__c = true, 
					KGRenewal__AvailableForPurchase__c = true, 
					KGRenewal__Subscription__c = true, 
					KGRenewal__PriceTerm__c = 12, 
					Exclusive__c = prodFamily == 'Member Benefit' ? 'YNG' : '', 
					Family = prodFamily,
					Fiscal_Date_Start__c = Date.newInstance(Date.today().year(), 7, 1)
				));
				System.debug('added product: ' + products[i]);
			}
			insert products;

			for (Integer i = 0; i < count; i++) {
				prices.add(new PricebookEntry(
					IsActive = true, 
					Product2Id = products[i].id,
					Pricebook2Id = pricebookId, 
					UnitPrice = 1000
				)); 
				System.debug('added pricebook entry: ' + prices[i]);
			}
            insert prices;

			for (Integer i = 0; i < count; i++) {
				olis.add(new OpportunityLineItem(
					OpportunityId = oppId,
					Product2Id = products[i].Id, 
					PricebookEntryId = prices[i].id,
					Quantity = 1,
					UnitPrice = prices[i].UnitPrice,
					//TotalPrice = prices[i].UnitPrice, 
					KGRenewal__ContractEffectiveDate__c = Date.newInstance(Date.today().year(), 7, 1)
				));
				System.debug('added line item: ' + olis[i]);
			}
			if (doInsert) {
				insert olis;
			}
			return olis;
		}

		else {
			return null;
		}
	}


	public static void Build_OpportunityLineItem(id OpportID) {
		List<Product2> products;
		Id pricebookId = Test.getStandardPricebookId();

        // Create products and prices
        products = new List<Product2> {
            new Product2(Name = 'Test - YNG+ Benefit', IsActive = true, KGRenewal__eCommerceEnabled__c = true, KGRenewal__AvailableForPurchase__c = true, KGRenewal__Subscription__c = true, KGRenewal__PriceTerm__c = 12, Exclusive__c ='YNG', Family = 'Member Benefit'),
                new Product2(Name = 'Test - Aon WPO Complimentary Member Benefit (Worldaware)', IsActive = true, Complimentary_WPO_Product__c = true, Worldaware_benefit__c = true, KGRenewal__AvailableForPurchase__c = true, KGRenewal__Subscription__c = true, KGRenewal__PriceTerm__c = 12, Family = 'Member Benefit'),
                new Product2(Name = 'Test - YPO Member Benefit', IsActive = true, KGRenewal__eCommerceEnabled__c = true, KGRenewal__AvailableForPurchase__c = true, KGRenewal__Subscription__c = true, KGRenewal__PriceTerm__c = 12, Exclusive__c ='Member', Family = 'Member Benefit'),
                new Product2(Name = 'Test - Worldwide Dues 1', IsActive = true, KGRenewal__eCommerceEnabled__c = true, KGRenewal__AvailableForPurchase__c = true, KGRenewal__Subscription__c = true, KGRenewal__PriceTerm__c = 12, Family = 'Annual Dues', Tier_Number__c = '1', isProrate__c = true),
                new Product2(Name = 'Test - Worldwide Dues 2', IsActive = true, KGRenewal__eCommerceEnabled__c = true, KGRenewal__AvailableForPurchase__c = true, KGRenewal__Subscription__c = true, KGRenewal__PriceTerm__c = 12, Family = 'Annual Dues', Tier_Number__c = '2', isProrate__c = true),
                new Product2(Name = 'Test - Worldwide Dues 3', IsActive = true, KGRenewal__eCommerceEnabled__c = true, KGRenewal__AvailableForPurchase__c = true, KGRenewal__Subscription__c = true, KGRenewal__PriceTerm__c = 12, Family = 'Annual Dues', Tier_Number__c = '3', isProrate__c = true),
                new Product2(Name = 'Test - Worldwide Dues 4', IsActive = true, KGRenewal__eCommerceEnabled__c = true, KGRenewal__AvailableForPurchase__c = true, KGRenewal__Subscription__c = true, KGRenewal__PriceTerm__c = 12, Family = 'Annual Dues', Tier_Number__c = '4', isProrate__c = true)
                
                };
                    
        insert products;
        
        List<PriceBookEntry> prices = new List<PricebookEntry> {
            new PricebookEntry(IsActive = true, Product2Id = products[0].id,
                               Pricebook2Id = pricebookId, UnitPrice = 295),
                new PricebookEntry(IsActive = true, Product2Id = products[1].id,
                                   Pricebook2Id = pricebookId, UnitPrice = 0),
                new PricebookEntry(IsActive = true, Product2Id = products[2].id,
                                   Pricebook2Id = pricebookId, UnitPrice = 0),
                new PricebookEntry(IsActive = true, Product2Id = products[3].id,
                                   Pricebook2Id = pricebookId, UnitPrice = 3000),
                new PricebookEntry(IsActive = true, Product2Id = products[4].id,
                                   Pricebook2Id = pricebookId, UnitPrice = 3000),
                new PricebookEntry(IsActive = true, Product2Id = products[5].id,
                                   Pricebook2Id = pricebookId, UnitPrice = 3000),
                new PricebookEntry(IsActive = true, Product2Id = products[6].id,
                                   Pricebook2Id = pricebookId, UnitPrice = 3000)
                };
                    
        insert prices;
        
        List<OpportunityLineItem> testOli = new List<OpportunityLineItem>();
		testOli.add(new OpportunityLineItem(
             OpportunityId = OpportID,
             Quantity = 1,
             PricebookEntryId = prices[2].id,
             TotalPrice = 1 * prices[2].unitPrice,
			 KGRenewal__ContractEffectiveDate__c = Date.newInstance(Date.today().year(),7,1)
         ));
		 testOli.add(new OpportunityLineItem(
             OpportunityId = OpportID,
             Quantity = 1,
             PricebookEntryId = prices[3].id,
             TotalPrice = 1 * prices[3].unitPrice,
			 KGRenewal__ContractEffectiveDate__c = Date.newInstance(Date.today().year(),7,1)
         ));
        insert testOli;	

	}
}