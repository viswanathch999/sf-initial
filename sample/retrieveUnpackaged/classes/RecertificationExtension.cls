public without sharing class RecertificationExtension {
    
    public String loadOpportunityId {set;get;}    
    public Contact opportunityStateCountry {set;get;}
    public Boolean isProfileCertificationPagesCompleted {set;get;}
    public Opportunity oOpp{get; set;}
    public Account oAcc{get;set;}
    public Contact oContact {set;get;}
    public Boolean isGraceAvailable{get;private set;}
    Relationship__c oRelationship;
    public Boolean bRelationshipPresent{get; private set;}
    public Boolean isTransitionAvailable{get;private set;}
    public Boolean isQualifyingCompanyEditable{get;set;}
    public Boolean isfieldValidationPassed{get;set;}
    public String prevQualifyingCompany='';
    public Boolean isMember{get;set;}
    public Boolean isYPO{get; private set;}
    public Boolean isYPO_GoldMember{get;set;}
    public Boolean isTransition{get;set;}
    public Opportunity originalOpp {get;set;}
    public String CurrencyCode {set;get;}
    
    static final String CONST_CONTACT = 'Contact';
    static final String CONST_MEMBER = 'Member';
    static final String CONST_FORMER_MEMBER = 'Former_Member';
    static final Set<String> lifetimeEligibleStatus = new Set<String> {'Eligible for early transition', 'Scheduled for transition'};
    @testVisible static final String UPDATED_CRITERIA_TITLE = 'Updated Title';
    @testVisible static final String UPDATED_CRITERIA_COMPANY = 'Updated Qualification Company';
    @testVisible static final String UPDATED_CRITERIA_BOTH = 'Updated Qualifying Company and Title';

	@testVisible static final String CEXCHANGE_NOTSTARTED = 'Not Started';
	@testVisible static final String CEXCHANGE_INPROGRESS = 'In Progress';
	@testVisible static final String CEXCHANGE_COMPLETE = 'Complete';

	@testVisible static final String CSTATUS_INCOMPLETE = 'Incomplete';
	@testVisible static final String CSTATUS_REQUESTED = 'Requested';
	@testVisible static final String CSTATUS_RECEIVED = 'Received';
	@testVisible static final String CSTATUS_COMPLETE = 'Complete';

	@testVisible static final String CTYPE_SELF = 'Self Certify';
	@testVisible static final String CTYPE_THIRDPARTY = 'Third Party Certify';
	@testVisible static final String CTYPE_NOT_NEEDED = 'No Certification Needed';

    public Boolean hasGrace{
        get{
                if(hasGrace == null) {
                        Integer count = 0;
                                                hasGrace = false;
                        count = [Select count() from Exception__c where contact__C =: oContact.id and opportunity__c =: oOpp.Id and (Type_of_Waiver__c='Grace Extension' OR Exception_Category__c = 'Waiver' OR Exception_Category__c='Grace')];
                        if(count > 0) {
                            hasGrace = true;
                        }
                }
                System.debug('*** has Grace?'+ hasGrace);
                return hasGrace;
        } private set;
    }
            
    Id memberRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_MEMBER, CONST_CONTACT).Id;
    Id formerMemberRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_FORMER_MEMBER, CONST_CONTACT).Id;
    
    Id contactId;
    public RecertificationExtension(ApexPages.StandardController oStandardController){
                try {
                        if((Contact)oStandardController.getRecord()!= new Contact()){
                                oContact = (Contact)oStandardController.getRecord();
                                contactId = oContact.id;
                        } else {
                                User oUser = [Select Id,ContactId from User where Id =: UserInfo.getUserId()];
                                if (oUser.ContactId != null) {
                                        contactId =  oUser.ContactId;
                                } else {
                                        throw new CustomException('No member Contact record found!');
                                }
                        }
                        getContactWithAllFields();
        
                        isMember = true; //((oContact.RecordTypeId==memberRecordTypeId || oContact.RecordTypeId==formerMemberRecordTypeId)?true:false);
        
                        isYPO = (oContact.YPO_WPO_Formula__c=='YPO'?true:false); 
                        isYPO_GoldMember = isMember && (oContact.YPO_WPO_Formula__c=='YPO Gold'?true:false );
                } catch (CustomException CExcp) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, CExcp.getMessage()));
                } Finally {
                        isGraceAvailable = false;
                        isTransitionAvailable = false;
                        isTransition = false;
                        isQualifyingCompanyEditable = false;
                        isfieldValidationPassed = true;        
                        CurrencyCode = UserInfo.getDefaultCurrency();

                        oOpp = new Opportunity();
                        opportunityStateCountry = new Contact();
                }
    }

    @testVisible
    private void setupOpportunityForPage()
    {
        
        if(isTransition){
            Opp_PresidentType = oOpp.President_Type__c;
            Opp_CorporationType = oOpp.Organization_Type__c;
            Opp_BusinessScope = oOpp.Business_Scope__c;
            AnnualRevenue = oOpp.AnnualRevenue__c;
        }else {
            Opp_QualifyingCompany = oOpp.Qualifying_Company__c;
            Opp_Industry = oOpp.Organization_Type__c;
            Opp_CorporationType = oOpp.Organization_Type__c;
            Opp_FirmType = oOpp.Firm_Type__c;
            Opp_BusinessScope = oOpp.Business_Scope__c;
            Opp_PresidentType = oOpp.President_Type__c;
            Opp_Title = oOpp.Title__c;
            NumberOfEmployees = Integer.valueOf(oOpp.NumberOfEmployees__c);
            TotalEmployeeCompensation =  oOpp.Total_Employee_Compensation__c;
            
            AnnualRevenue = oOpp.AnnualRevenue__c;
            EnterpriseValue = oOpp.Enterprise_Value__c;
            Opp_EnterpriseType = oOpp.Enterprise_Type__c;
            originalOpp = oOpp.clone(true/*perseve Id*/,true/*isDeepClone*/,true/*preserveReadOnlyTimeStamps*/,true/*preserveAutoNumber*/);
        }
    }

    /*
    *  Method checks for the relationship record associated with contact. 
    *  If relationship record is not present then error message is thrown to the page.
    */
    public void init(){
        if(oRelationship == null){

            try{
                oRelationship = ContactServices.getRelationship(oContact);
                //bRelationshipPresent = (oRelationship==null)?false:true;
            } catch(Exception oDmlException){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_Relationship_Record_Found));
                bRelationshipPresent = false;
            }
            try{
                oOpp = ContactServices.getOpportunities(oContact);
                loadOpportunityId = oOpp.id;
                                System.debug('-------loadOpportunityId----------'+loadOpportunityId + oOpp.Transition_flag__c);
                                Integer exceptionCount = [Select count() from Exception__c where contact__C =: oContact.id and Opportunity__c =:loadOpportunityId and (Type_of_Waiver__c='Grace Extension' OR Exception_Category__c = 'Waiver' OR Exception_Category__c='Grace')];
                                
                isGraceAvailable = ContactServices.isGraceAvailable(oContact) ;
                System.debug('*** grace avail? '+ isGraceAvailable + ' count '+exceptionCount);
                isTransitionAvailable = ContactServices.isTransitionAvailable(oContact);                
                isTransition = oOpp.Transition_Flag__c == true || (oOpp.Certification_Type__c == 'No Certification Needed' || oOpp.Certification_Type__c == null);
                
				if(oOpp.QC_Country__c != null || oOpp.QC_Country__c != '') {
					oOpp.QC_CountryCode__c  = ContactServices.getCountryCodeValue(oOpp.QC_Country__c);
				}

				if (oOpp.QC_CountryCode__c != null) {
					opportunityStateCountry.MailingCountryCode = oOpp.QC_CountryCode__c;
				}
				
				if (oOpp.QC_State__c != null || oOpp.QC_State__c != '') {
					oOpp.QC_StateCode__c  = ContactServices.getStateCodeValue(oOpp.QC_State__c);
				}

				if (oOpp.QC_StateCode__c != null) {
					opportunityStateCountry.MailingStateCode = oOpp.QC_StateCode__c;
				}
                
                if(oOpp.Profile_Page_Status_Exchange__c == 'Complete' && (oOpp.Certification_Page_Status_Exchange__c == 'Complete' || oOpp.Certification_Page_Status_Exchange__c == 'In Progress'))
                     isProfileCertificationPagesCompleted = true;
                else isProfileCertificationPagesCompleted = false;
                
                setupOpportunityForPage();
                
            } catch(Exception oDmlException){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_Opportunity_Record_Found));
            }
            //try{
                //oAcc = ContactServices.getAssociatedAccount(oContact);
                //oAcc.BillingStatecode = oOpp.QC_StateCode__c;
                //oAcc.BillingCountrycode = oOpp.QC_CountryCode__c;
                
            //} catch(Exception oDmlException){
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Account Error While Retrieving'));
            //}
        }
    }    
    /**
    *  Method to request transition
    *  TODO: Not being used, remove later
    */
    public PageReference requestTransition(){
        if(oContact.Transition_Status__c == 'Overdue for transition')
            return toDesiredWPOChapter();
        else return WPOTransition();
    }
    public PageReference toDesiredWPOChapter() {
        PageReference pageRef = Page.DesiredWPOChapter;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;    
    }
    public PageReference WPOTransition(){
        PageReference pageRef = Page.Gold_Transition_Option_YPO;//WPOTransition;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;
    }

    public PageReference toUpdateProfilePage()
    {
        PageReference pageRef = Page.UpdateProfileInfo_YPO;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;   
    }

    public PageReference goBack()
    {
        System.debug('###isMember: '+isMember+' isYPO: '+isYPO+' isYPOGOLD: '+isYPO_GoldMember );
        if(isMember){
            if(isYPO_GoldMember){
                System.debug('ya gold');
                return toUpdateProfilePage();
            }
            else
            {
                System.debug('ya not gold');                
                return WPOTransition();
            }
        }
        else{
            return null;
        }
    }
    
    /**
    *  Method to check if the Grace can be availed 
    */
    public PageReference requestGrace(){
        saveCurrentPage();
        PageReference pageRef = Page.Grace_YPO;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;
    }
    
    /* TODO: CLEAN UP --> Functionality copied to UpdateProfileInfoController_YPO Class. */
    private void saveCurrentPage(){
        PageReference pg = ApexPages.currentPage();
        Id id = pg.getParameters().get('Id');
        pg.getParameters().clear(); // To get rid of view state
        pg.getParameters().put('Id', id);
        
        oContact.Last_Renewals_Page__c = pg.getURL();
        oContact.Date_Last_Profile_Updated__c = System.today();
        try{
            update oContact;
        } catch(Exception oDmlException){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Page_Not_Saved));
        }
    }
    
    @testVisible
    private Boolean hasOpportunintyBeModified()
    {
        for(Schema.FieldSetMember field: Schema.SObjectType.Opportunity.FieldSets.Fields_for_Recertification.getFields())
        {
            if(oOpp.get(field.getFieldPath())!= null && oOpp.get(field.getFieldPath()) != originalOpp.get(field.getFieldPath()) )
            {
                return true;
            }
        }
        return false; 
    }

    @testVisible
    private void updatedQualifyingCriteria()
    {
        System.debug('###oOpp: ' + oOpp);
        
        Opportunity currOpp = [Select Id, Title_Other__c, Qualifying_Company__c, Updated_Qualifying_Criteria__c From Opportunity Where Id =:oOpp.Id Limit 1];
        
        System.debug('***oOpp: ' + oOpp + 'original: ' + originalOpp + Opp_Title + Opp_QualifyingCompany);
        
        System.debug('###originalOpp: ' + originalOpp);
        
        if(currOpp <> null && originalOpp <> null ) {
        
            if(/*oOpp.Title__c*/ currOpp.Title_Other__c != originalOpp.Title_Other__c  &&  currOpp.Qualifying_Company__c != originalOpp.Qualifying_Company__c)
            {
                currOpp.Updated_Qualifying_Criteria__c = UPDATED_CRITERIA_BOTH;
            }
            else if(currOpp.Title_Other__c != originalOpp.Title_Other__c)
            {
                currOpp.Updated_Qualifying_Criteria__c = UPDATED_CRITERIA_TITLE;
            }
            else if(currOpp.Qualifying_Company__c  != originalOpp.Qualifying_Company__c)
            {
                currOpp.Updated_Qualifying_Criteria__c = UPDATED_CRITERIA_COMPANY;
            }
            update currOpp;
        }
    }

    public PageReference saveOnRecertification() {
        Boolean isTransitioning = false;
        
        System.debug('Entered saveOnRecertification ');

        updatedQualifyingCriteria();
        System.debug('***********saveOnRecertification2222*************');
                
        // This is go to next page either ThirdPartyCertification_YPO , Catalog_YPO , ShoppingCart_YPO ,ContactMemberServices_YPO based on conditions
                
        // GET A FRESH OPPORTUNITY AGAIN BCZ IT WAS UPDATED IN REMOTE ACTION VISUALFORCE
        oOpp = ContactServices.getOpportunities(oContact);
        isTransitioning = oOpp.Transition_Flag__c;
                                
        System.debug('###oOpp: ' + oOpp);
        System.debug('###isYPO: ' + isYPO + ', isQualified: ' + ContactServices.isQualified(oContact,oOpp,prevQualifyingCompany));
        
		// Update certification statuses
		if (oOpp.Certification_Type__c == CTYPE_SELF) {
			oOpp.Certification_status__c = CSTATUS_COMPLETE;
			oOpp.Certification_Page_Status_Exchange__c = CEXCHANGE_COMPLETE;
		} 
		else if (oOpp.Certification_Type__c == CTYPE_THIRDPARTY) {
			oOpp.Certification_Page_Status_Exchange__c = CEXCHANGE_INPROGRESS;
		} 
		else if (oOpp.Certification_Type__c == CTYPE_NOT_NEEDED) {
			oOpp.Certification_Status__c = CSTATUS_COMPLETE;
			oOpp.Certification_Page_Status_Exchange__c = CEXCHANGE_COMPLETE;
		} 
		else { //Would hope we would never get here
			oOpp.Certification_Status__c = CSTATUS_INCOMPLETE;
			oOpp.Certification_Page_Status_Exchange__c = CEXCHANGE_NOTSTARTED;
		}

		// Update opp and navigate to correct page
		try{
			update oOpp;
			If(isTransition == true) { //YPO Gold
				if (oOpp.StageName == 'Cycle Open') {
					if(oContact.Lifetime_Dues_Status__c == 'Eligible for Lifetime'){
						PageReference pgrf = Page.LifetimeOption_YPO;
						pgrf.setRedirect(true);
						pgrf.getParameters().put('Id', oContact.Id);
						return pgrf;
					} else {
						//Send to Catalog page
						PageReference pr = Page.Catalog_YPO;
						pr.setRedirect(true);
						if (!string.isBlank(oOpp.CartToken__c)) {
								pr.getParameters().put('ct',EncodingUtil.urlDecode(oOpp.CartToken__c, 'UTF-8'));
						}
						return pr;
					}
				} else if (oOpp.StageName == 'Payment Pending') {
					//Goto Invoice page
					PageReference pr = Page.v_invoices;
					pr.setRedirect(true);
					if (!string.isBlank(oOpp.CartToken__c)) {
							pr.getParameters().put('ct',EncodingUtil.urlDecode(oOpp.CartToken__c, 'UTF-8'));
					}
					return pr;
				} else { 
					//Payment has been completed, goto Thank you page
					PageReference pr = page.splashscreen_thankyou;
					pr.setRedirect(true);
					pr.getParameters().put('Id', oContact.Id);
					return pr;
				}
			} else { //Normal Recertification
				if(oOpp.Certification_Type__c == CTYPE_SELF ){
					if(oContact.Lifetime_Dues_Status__c == 'Eligible for Lifetime'){ //|| lifetimeEligibleStatus.contains(oContact.Transition_Status__c)
						PageReference pgrf = Page.LifetimeOption_YPO;
						pgrf.setRedirect(true);
						pgrf.getParameters().put('Id', oContact.Id);
						return pgrf;
					} else if (oOpp.StageName == 'Cycle Open') {
						//Send to Catalog page
						PageReference pr = Page.Catalog_YPO;
						pr.setRedirect(true);
						if (!string.isBlank(oOpp.CartToken__c)) {
								pr.getParameters().put('ct',EncodingUtil.urlDecode(oOpp.CartToken__c, 'UTF-8'));
						}
						return pr;
					} else if (oOpp.StageName == 'Payment Pending') {
						//Goto invoices page
						PageReference pr = Page.v_invoices;
						pr.setRedirect(true);
						if (!string.isBlank(oOpp.CartToken__c)) {
								pr.getParameters().put('ct',EncodingUtil.urlDecode(oOpp.CartToken__c, 'UTF-8'));
						}
						return pr;
					} else {
						//Payment has been completed, goto Thank you page
						PageReference pr = page.splashscreen_thankyou;
						pr.setRedirect(true);
						pr.getParameters().put('Id', oContact.Id);
						return pr;
					}
				} else if(oOpp.Certification_Type__c == CTYPE_THIRDPARTY) {
					return toThirdPartyCertification();
				} else{
					//Should never get here!
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'You have gotten here with an unexpected Certification Type code.  Please contact member services to address this issue.'));
					return null;
				}
			}
		}catch(DMLException oDmlException){
			System.debug('###inside catch update opp');
			System.debug('**Exception : '+ oDmlException);
			for(Integer i =0; i < oDmlException.getNumDml(); i++)
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getDmlMessage(i)));
			return null;
		}
    }
    
    private Boolean isQualifyingCompanyBlank() {
        return (oContact.Date_Last_Grace_Year_Used__c != Date.newInstance(System.Today().year(), 7, 1) && String.isBlank(oOpp.Qualifying_Company__c));  
    }
    
    /**
     * Method to check if the member meets the qualification criteria
     * This is to continue to next page after click on Submit in the Recertification.page
    */
    //public PageReference checkQualificationCriteria(){
        ////return Page.ThirdPartyCertification_Screens;
        //if(ContactServices.isQualified(oContact,oOpp,prevQualifyingCompany)){
            ////ContactServices.checkAssociatedAccount(oOpp.Qualifying_Company__c, oContact); // Check where an account record with Qualifying company name exist, if not create one and create Acc Aff.
            //System.debug('** entered qc check** ');
            //if(oOpp.Certification_Type__c == 'Third Party Certify'){
                //return toThirdPartyCertification();
            //} else if(oOpp.Certification_Type__c == 'Self Certify') {
                                //if(oOpp.Dues_Page_Status_Exchange__c=='Not Started') {
                                        //if (oContact.Lifetime_Dues_Status__c == 'Eligible for Lifetime' && oOpp.KGRenewal__BilledAmount__c==0) {
                                                ////send to Lifetime page
                                        //} else {
                                                ////send to Catalog page
                                        //}
                                //} else if(oOpp.Dues_Page_Status_Exchange__c=='In Progress') {
                                        ////send to Invoice?
                                //} else {
                                        ////oOpp.Dues_Page_Status_Exchange__c=='Completed'
                                        ////send to Thankyou page
                                //}
                        //} else {
                                ////oOpp.Certification_Type__c is either 'No Certification Needed' or Null;
                //oOpp.Certification_status__c = 'Complete';
                //try{
                    //update oOpp;
                                        //if (oOpp.Grace_Status__c=='Requested') {
                                                ////send to grace
                                        //} else if (oContact.Transition_Status__c=='Scheduled for transition') {
                                                ////send to Transition
                                        //} else
                                                //return toVenuePage();
                                        //}
                //}catch(DMLException oDmlException){
                        //System.debug('**Exception : '+ oDmlException);
                    //for(Integer i =0; i < oDmlException.getNumDml(); i++)
                        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getDmlMessage(i)));
                    //return null;
                //}
                                
            //}
        //} else{
            //return toContactMemberServices(); 
        //}
    //}    
    
    public PageReference toThirdPartyCertification() {
        PageReference pageRef = Page.ThirdPartyCertification_screens_ypo;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;    
    }
    
    /**
     * Method to go to the Venue page
     **/
    public PageReference toVenuePage(){
        PageReference pageRef;
        if(String.isBlank(oOpp.CartToken__c)){
            pageRef = Page.Catalog_YPO;
        } else {
            pageRef = Page.Checkout_Check_Wire_YPO;
            pageRef.getParameters().put('ct',EncodingUtil.urlDecode(oOpp.CartToken__c, 'UTF-8'));
        }
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference toRecertificationPage(){
        saveCurrentPage();
        PageReference pageRef = Page.Recertification_Screen;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;
    }
    
    /**
     * Method to go to the Contact Member Service page
     **/
    public PageReference toContactMemberServices(){
        saveCurrentPage();
        PageReference pageRef = Page.ContactMemberServices_YPO;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;
    }
    public PageReference toVCatalog() {
                PageReference pageRef = null;
                saveCurrentPage();
                if (oOpp.StageName == 'Cycle Open') {
                        //Send to Catalog page
                        pageRef = Page.Catalog_YPO;
                        pageRef.setRedirect(true);
                        pageRef.getParameters().put('Id',oContact.Id);
                        pageRef.getParameters().put('lifetime','true');
                } else if (oOpp.StageName =='Payment Pending') {
                        //Send to Invoice page
                        pageRef = Page.v_invoices;
                        pageRef.setRedirect(true);
                        if (!string.isBlank(oOpp.CartToken__c)) {
                                pageRef.getParameters().put('ct',EncodingUtil.urlDecode(oOpp.CartToken__c, 'UTF-8'));
                        }
                } else {
                        // Send to Thankyou page
                        pageRef = Page.Splashscreen_Thankyou;
                        pageRef.setRedirect(true);
                        pageRef.getParameters().put('Id',oContact.Id);
                }

        return pageRef;    
    }
    public PageReference toConfirmation() {
        Contact tCont = new Contact(Id=oContact.Id, Interested_in_Lifetime_Member_Option__c =true );
        try{
                update tCont;
        }catch(DMLException dmlex ){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, dmlex.getMessage()));
                return null;
        }
        PageReference pageRef = Page.SplashScreen_Thankyou;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;    
    }

    public PageReference exitAction()
    {
        return Page.Splash_ypo;
    }

    public PageReference backLifetime()
    {
        If (oOpp.Grace_Status__c != 'No Grace Needed') {
            //Stay on Lifetime - Shouldn't get here; see page script function.
            Return null;
        } else if (oOpp.Transition_Flag__c) {
            //Display Gold Screen
            return toRecertificationPage();
        } else if (oOpp.Certification_Type__c == 'Self Certify') {
            //Certification screen
            return toRecertificationPage();
        } else if(oOpp.Certification_Type__c == 'Third Party Certify') {
            return toThirdPartyCertification();
        } else {
			//presuming Certification_type__c == 'No Certification needed'
            return toRecertificationPage();
        }
    }

    public PageReference backGold() {
        Boolean isTransitioning = oOpp.Transition_Flag__c;
        PageReference pageRef = Page.UpdateProfileInfo_YPO;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        if(isTransitioning) {
                pageRef = Page.Recertification_Screen;
        }
        
        return pageRef;    
    }

    /**
     * @Author: Vasudevu
     * @Create Date: FEB 27 2017
     * @Description: This is used to update Opportunity from the VF by Each Section Save button.
     * */    
    @RemoteAction
    public static Boolean updateOpportunityEachSec(String opportynityJSONStr){
        System.debug('opportynityJSONStr '+ opportynityJSONStr);
        Opportunity OppSave = (Opportunity) JSON.deserialize(opportynityJSONStr, Opportunity.class);
        System.debug('-------Before Updated Opportunity Fields-------\n'+OppSave);
        try{
            update OppSave;
            System.debug('-------Updated Opportunity Fields-------\n'+OppSave);
            return true;
        }catch(Exception e){
            System.debug('-------Exception in updateOpportunityEachSec Method---------'+e.getMessage());
            return false;
        }
    }
    
    /**
     * @Author: Vasudevu
     * @Create Date: JAN 18 2017
     * @Description: This is used for the get the Account Object from the ContactService.cls
     * */    
    @RemoteAction
    public static Account getAnAccount(String contactJSONStr){
        Account oAcc1 = null;
        Contact oCon = (Contact) JSON.deserialize(contactJSONStr, Contact.class);
        try{
            oAcc1 = ContactServices.getAssociatedAccount(oCon);
            system.debug('---oAcc1---'+oAcc1);
        } catch(Exception oDmlException){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Account_Not_Found));
        }
        return oAcc1;
    }
    /**
     * @Author: Vasudevu
     * @Create Date: JAN 18 2017
     * @Description: This is used for the get the Opportunity Object from the ContactService.cls
     * */    
    @RemoteAction
    public static Opportunity getAnOpportunity(String contactJSONStr){
        Opportunity opprt = null;
        Contact oCon = (Contact) JSON.deserialize(contactJSONStr, Contact.class);
        try{
            opprt = ContactServices.getOpportunities(oCon);
            if(opprt.QC_CountryCode__c == null || opprt.QC_CountryCode__c == '')
                opprt.QC_CountryCode__c  = ContactServices.getCountryCodeValue(opprt.QC_Country__c);
            
            if(opprt.QC_StateCode__c == null || opprt.QC_StateCode__c == '')
                opprt.QC_StateCode__c  = ContactServices.getStateCodeValue(opprt.QC_State__c);
                
        } catch(Exception oDmlException){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_Opportunity_Record_Found));
        }
       return opprt;
    }

        /**
     * @Author: Ross
     * @Create Date: MAR 20 2017
     * @Description: This is used for the get the Previous year Opportunity Object from the ContactService.cls
     * */
    @RemoteAction
    public static Opportunity getPreviousOpportunity(String contactJSONStr){
        Opportunity opprt = null;
        Contact oCon = (Contact) JSON.deserialize(contactJSONStr, Contact.class);
        try{
            opprt = ContactServices.getPreviousOpportunity(oCon);
            system.debug('---opprt---'+opprt);
        } catch(Exception oDmlException){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_Opportunity_Record_Found));
        }
       return opprt;
    }
    
    /**
     * @Author: Vasudevu
     * @Create Date: JAN 27 2017
     * @Description: It returns the Indusstry picklist values from the Opportunity
     * */    
    Opportunity opp = new Opportunity();
    public String Opp_QualifyingCompany {set;get;}
    public String CompanyWebsite {set;get;}
    Public String Opp_Industry {set;get;}
    Public String Opp_CorporationType {set;get;}
    Public String Opp_FirmType {set;get;}
    Public String Opp_BusinessScope {set;get;}
    Public String Opp_PresidentType {set;get;}
    Public String Opp_Title {set;get;}
    
    public Integer NumberOfEmployees {set;get;} 
    // oOpp.NumberOfEmployees__c
    
    public Decimal TotalEmployeeCompensation {set;get;} 
    // oOpp.Total_Employee_Compensation__c
    
    public Decimal AnnualRevenue {
		set{
			if (value == null) {
				AnnualRevenue = 0;
			} else {
				AnnualRevenue = value;
			}
		}
		get;
	} 
    // oOpp.AnnualRevenue__c
    
    public Decimal EnterpriseValue {set;get;} 
    // oOpp.Enterprise_Value__c
    
    public String Opp_EnterpriseType {set;get;}
    
    Public List<SelectOption> getIndustry(){    
        String fld = 'Organization_Type__c';
        return getPicklistValues(opp,fld);
    }
    Public List<SelectOption> getCorporationType(){
        String fld = 'Organization_Type__c';
        return getPicklistValues(opp,fld);
    }
    Public List<SelectOption> getFirmType(){
        String fld = 'Firm_Type__c';
        return getPicklistValues(opp,fld);
    }
    Public List<SelectOption> getBusinessScope(){
        String fld = 'Business_Scope__c';
        return getPicklistValues(opp,fld);
    }
    Public List<SelectOption> getPresidentType(){
        String fld = 'President_Type__c';
        return getPicklistValues(opp,fld);
    }
    Public List<SelectOption> getTitle(){
        String fld = 'Title__c';
        return getPicklistValues(opp,fld);
    }
    Public List<SelectOption> getEnterpriseType(){
        String fld = 'Enterprise_Type__c';
        return getPicklistValues(opp,fld);
    }
    
    public Opportunity getMappedOpportunity(){
        oOpp.Qualifying_Company__c = Opp_QualifyingCompany;
        //oOpp.Organization_Type__c = Opp_Industry;
        //oOpp.Organization_Type__c = Opp_CorporationType;
        //oOpp.Firm_Type__c = Opp_FirmType;
        oOpp.Business_Scope__c = Opp_BusinessScope;
        oOpp.President_Type__c = Opp_PresidentType;
        oOpp.Title__c = Opp_Title;        
        //oOpp.NumberOfEmployees__c = NumberOfEmployees;
        //oOpp.Total_Employee_Compensation__c = TotalEmployeeCompensation;        
        //oOpp.AnnualRevenue__c = AnnualRevenue;
        //oOpp.Enterprise_Value__c = EnterpriseValue;
        //oOpp.Enterprise_Type__c = Opp_EnterpriseType;        
        return oOpp;
    }
    
    /**
     * @Author: Vasudevu
     * @Create Date: JAN 27 2017
     * @Description: It returns the list of picklist values from the sObject based field.
     * */     
    Public list<SelectOption> getPicklistValues(SObject obj, String fld){
        list<SelectOption> options = new list<SelectOption>();
        // Get the object type of the SObject.
        Schema.sObjectType objType = obj.getSObjectType(); 
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
        // Get a map of fields for the SObject
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        // Get the list of picklist values for this field.
        list<Schema.PicklistEntry> values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values){ 
            options.add(new SelectOption(a.getLabel(), a.getValue())); 
        }
        return options;
    }
    public void getContactWithAllFields(){
        System.debug('--------contactId----------'+contactId);
    oContact = [SELECT Name, LastName, Account.ParentId, Account.YPOI_Type__c, HouseHoldID__c, AccountId,YPO_WPO_Formula__c,YPO_WPO__c,Grace_Years_Available__c,
                            Is_Grace_Used__c, Grace_Years_Used__c, Title,Number_of_Employees1__c,Total_Employee_Compensation__c,Last_Renewals_Page__c,
                            Annual_Revenue__c, Enterprise_Value__c,Transition_Status__c,Number_of_Employees__c,Last_Renewals_Form__c,
                            Age_Current__c, Number_Years_a_Member__c,RecordTypeId, Lifetime_dues_status__c, Interested_in_Lifetime_Member_Option__c,
                            Number_of_Employees_Opt_2__c, Join_Date__c, Annual_Fees__c, Annual_Assets__c
                             FROM Contact WHERE Id =: contactId];      
    }
}