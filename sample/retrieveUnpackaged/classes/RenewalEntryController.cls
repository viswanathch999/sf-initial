public without sharing class RenewalEntryController {
        
    // Status Values
    /* Opportunity Values */
    public static final String PROFILE_STATUS_NOT_STARTED = 'Not Started';
    public static final String PROFILE_STATUS_IN_PROGRESS = 'In Progress';
    public static final String PROFILE_STATUS_COMPLETE = 'Complete';
    public static final String CERTIFICATION_STATUS_COMPLETE = 'Complete';
    public static final String CERTIFICATION_STATUS_REQUESTED = 'Requested';
    public static final String CERTIFICATION_STATUS_REJECTED = 'Rejected';
    public static final String CERTIFICATION_STATUS_VALIDATED = 'Validated';
	public static final String CERTIFICATION_STATUS_RECEIVED = 'Received';
	public static final String CERTIFICATION_STATUS_INCOMPLETE = 'Incomplete';
    public static final String PAYMENT_STATUS_PAID = 'Payment Received';
    public static final String DUES_STATUS_COMPLETE = 'Complete';
    public static final String DUES_STATUS_NOT_STARTED = 'Not Started';
    public static final String DUES_STATUS_IN_PROGRESS = 'In Progress';
    public static final String STAGE_CLOSED_WON = 'Closed Won';
    public static final String STAGE_PAYMENT_PENDING = 'Payment Pending';
    public static final String STAGE_CYCLE_OPEN = 'Cycle Open';
    public static final String CERTIFICATION_TYPE_SELF = 'Self Certify';
    public static final String CERTIFICATION_TYPE_THIRD_PARTY = 'Third Party Certify';
    public static final String CERTIFICATION_TYPE_NOCERTNEEDED = 'No Certification Needed';
	public static final String CERTIFICATION_PAGE_STATUS_NOTSTARTED = 'Not Started';
	public static final String CERTIFICATION_PAGE_STATUS_INPROGRESS = 'In Progress';
	public static final String CERTIFICATION_PAGE_STATUS_COMPLETE = 'Complete';
    public static final String TRANSITION_SCHEDULED = 'Scheduled for transition';
    public static final String TRANSITION_TRANSITIONED = 'Transitioned';
    public static final String EXCEPTION_CATEGORY_GRACE = 'Grace';
	public static final string STAGENAME_PENDING = 'Payment Pending';
	public static final String STAGENAME_CYCLE = 'Cycle Open';
	public static final String STAGENAME_RECEIVED = 'Payment Received';
	public static final String STAGENAME_WON = 'Closed Won';
    
	@TestVisible 
    public Contact oContact;
	@TestVisible 
    public Opportunity relatedOpp { get; set; }

    private static Boolean isTransitioning = false; 
        
    public RenewalEntryController(ApexPages.StandardController StndContr)
    {
        User theUser = [Select Id, ContactId From User Where Id=:UserInfo.getUserId() LIMIT 1][0];
		Date ExpectedFiscalStartDate = Date.newInstance(Date.today().year(),7,1);
        
        oContact = [SELECT 
                        Id,Name, Date_Last_Profile_Updated__c, FirstName,LastName,Email,MobilePhone,Phone,MailingStreet,MailingCity,MailingState,MailingCountry,MailingPostalCode,MailingStateCode,MailingCountryCode ,
                        Account.Name,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingCountry,Account.BillingPostalCode,Account.Phone,Country_Code__c,Mobile_Phone_Country_Code__c,
                        RecordTypeId,Transition_Status__c,YPO_WPO_Formula__c,QC_Annual_Assets__c, QC_Annual_Fees__c, QC_Annual_Revenue__c, QC_Enterprise_Value__c, QC_Number_of_Employees_Opt_1__c,
                        QC_Number_of_Employees_Opt_2__c, QC_Total_Employee_Compensation_Opt_2__c, Join_Date__c, Number_of_Employees__c, Number_of_Employees_opt_2__c, 
                        Annual_Fees__c, Annual_Assets__c, Annual_Revenue__c, Enterprise_Value__c, Total_Employee_Compensation__c, Membership_Status__c 
                    FROM Contact 
                    WHERE Id =:theUser.ContactId]; 
        relatedOpp = ContactServices.getOpportunities(oContact);
        if(relatedOpp == null){
			if (oContact.Membership_Status__c == 'Pending Resignation') {
        		relatedOpp = [Select Id, Profile_Page_Status_Exchange__c,Certification_Page_Status_Exchange__c, Qualifying_Company__c, Fiscal_Date_Start__c, Dues_Page_Status_Exchange__c, Transition_Flag__c, StageName,
        					Certification_Type__c, Certification_Status__c, Organization_Type__c, NumberOfEmployees__c, Enterprise_Value__c, AnnualRevenue__c, Total_Employee_Compensation__c,
        					Enterprise_Type__c, CartToken__c, Grace_Status__c
        					 FROM Opportunity 
        					 Where KGRenewal__Contact__c =: oContact.Id 
								AND Opportunity_Type__c = 'Renewal' 
								AND (StageName not in ('New', 'Closed Lost') OR KGRenewal__IsActiveCart__c = true)
        						AND Fiscal_Date_Start__c =:FiscalDateUtility.startOfCurrentFiscal Limit 1 ][0];
			} else {
        		relatedOpp = [Select Id, Profile_Page_Status_Exchange__c,Certification_Page_Status_Exchange__c, Qualifying_Company__c, Fiscal_Date_Start__c, Dues_Page_Status_Exchange__c, Transition_Flag__c, StageName,
        					Certification_Type__c, Certification_Status__c, Organization_Type__c, NumberOfEmployees__c, Enterprise_Value__c, AnnualRevenue__c, Total_Employee_Compensation__c,
        					Enterprise_Type__c, CartToken__c, Grace_Status__c
        					 FROM Opportunity 
        					 Where KGRenewal__Contact__c =: oContact.Id 
								AND Opportunity_Type__c = 'Renewal' 
								AND (StageName not in ('New', 'Closed Lost') OR KGRenewal__IsActiveCart__c = true)
        						AND Fiscal_Date_Start__c =:ExpectedFiscalStartDate Limit 1 ][0];
			}
        } 
		isTransitioning = relatedOpp.Transition_flag__c;
    }
    
    public PageReference toNextPage() {
        if( relatedOpp != NULL ) {
			Status_Resets();

			if(relatedOpp.Profile_Page_Status_Exchange__c != PROFILE_STATUS_COMPLETE) {
	        	return WELCOME_PAGE();
	        } else if (relatedOpp.Certification_Page_Status_Exchange__c != CERTIFICATION_PAGE_STATUS_COMPLETE) { // == 'In Progress' ||  == 'Not Started'
				System.debug('relatedOpp.Certification_Page_Status_Exchange__c: ' + relatedOpp.Certification_Page_Status_Exchange__c);
				if (relatedOpp.Grace_Status__c != 'No Grace Needed') {
					if (relatedOpp.Dues_Page_Status_Exchange__c == DUES_STATUS_COMPLETE) {
						return THANKYOU_PAGE('Grace');
					} else if (relatedOpp.StageName == STAGE_PAYMENT_PENDING) {
						return INVOICE_PAGE('Grace');
					} else { //relatedOpp.Dues_Page_Status_Exchange__c == DUES_STATUS_NOT_STARTED
						return CATALOG_YPO_PAGE('Grace');
					}
				} else if (relatedOpp.Transition_Flag__c == true) {
					if (relatedOpp.Dues_Page_Status_Exchange__c == DUES_STATUS_COMPLETE) {
						return THANKYOU_PAGE('Transition');
					} else if (relatedOpp.StageName == STAGE_PAYMENT_PENDING) {
						return INVOICE_PAGE('Transition');
					} else { //relatedOpp.Dues_Page_Status_Exchange__c == DUES_STATUS_NOT_STARTED
						return CATALOG_YPO_PAGE('Transition');
					}
				} else if (oContact.Transition_Status__c == TRANSITION_SCHEDULED) {
					return TRANSITION_PAGE();
				} else if (relatedOpp.Certification_Type__c == CERTIFICATION_TYPE_NOCERTNEEDED) {
					return RECERTIFICATION_SCREEN_PAGE(); // flags determine the display shown the member.
				} else {
					return RECERTIFICATION_SCREEN_PAGE(); // flags determine the display shown the member.
				}
			} else { //relatedOpp.Certification_Page_Status_Exchange__c == CERTIFICATION_PAGE_STATUS_COMPLETE
				System.debug('relatedOpp.Certification_Page_Status_Exchange__c: ' + relatedOpp.Certification_Page_Status_Exchange__c);
				System.debug('relatedOpp.Dues_Page_Status_Exchange__c: ' + relatedOpp.Dues_Page_Status_Exchange__c);
				System.debug('relatedOpp.StageName' + relatedOpp.StageName);
				if (relatedOpp.Dues_Page_Status_Exchange__c != DUES_STATUS_COMPLETE) {
					if(relatedOpp.StageName == STAGE_PAYMENT_PENDING) {
						return INVOICE_PAGE('None');
					} else {
						return CATALOG_YPO_PAGE('None');
					}
				} else { //relatedOpp.Dues_Page_Status_Exchange__c == DUES_STATUS_COMPLETE
					return INVOICE_PAGE('None');
				}
			}
        }
		return null;
    }
    
    @TestVisible
    private void Status_Resets()
    {
		System.debug('*** RenewalEntryController/Status_Resets() ');

        List<Exception__c> graceExceptions = [SELECT Id, Exception_Category__c, Opportunity__c 
                                              FROM Exception__c 
                                              WHERE Exception_Category__c =: EXCEPTION_CATEGORY_GRACE AND Opportunity__c =: relatedOpp.Id];  
        
        if(relatedOpp.Profile_Page_Status_Exchange__c == null) {
        	relatedOpp.Profile_Page_Status_Exchange__c = 'Not Started';
        }
        if(relatedOpp.Certification_Page_Status_Exchange__c == null) {
        	relatedOpp.Certification_Page_Status_Exchange__c = 'Not Started';
        }
        if(relatedOpp.Dues_Page_Status_Exchange__c == null) {
        	relatedOpp.Dues_Page_Status_Exchange__c = 'Not Started';
        }
        	
		if(oContact.Membership_Status__c == 'Surviving Spouse/Partner' && relatedOpp.Certification_Type__c == CERTIFICATION_TYPE_SELF) {
        	relatedOpp.Certification_Page_Status_Exchange__c = CERTIFICATION_PAGE_STATUS_COMPLETE;
        }
        //else if( oContact.Membership_Status__c != 'Surviving Spouse/Partner' && relatedOpp.Certification_Type__c == CERTIFICATION_TYPE_SELF && ContactServices.isQualified(oContact, relatedOpp, '') )
        //{
            //relatedOpp.Certification_Page_Status_Exchange__c = CERTIFICATION_PAGE_STATUS_COMPLETE;
        //}
        else if( (graceExceptions.size() == 1 || oContact.Transition_Status__c == TRANSITION_SCHEDULED || isTransitioning) && relatedOpp.Certification_Status__c != CERTIFICATION_STATUS_COMPLETE )
        {
            relatedOpp.Certification_Page_Status_Exchange__c = CERTIFICATION_PAGE_STATUS_INPROGRESS;
        }
        else if( relatedOpp.Certification_Status__c == CERTIFICATION_STATUS_COMPLETE )
        {
            relatedOpp.Certification_Page_Status_Exchange__c = CERTIFICATION_PAGE_STATUS_COMPLETE;
        }
        else if( relatedOpp.Certification_Type__c == CERTIFICATION_TYPE_THIRD_PARTY && (relatedOpp.Certification_Status__c != CERTIFICATION_STATUS_VALIDATED || relatedOpp.Certification_Status__c != CERTIFICATION_STATUS_COMPLETE) )
        {
            relatedOpp.Certification_Page_Status_Exchange__c = CERTIFICATION_PAGE_STATUS_INPROGRESS;
        }
        /* 
	        SKIPPING Items I & J HERE FOR NOT VISITED 
	        AND K IS A DUPE OF F 
	        AND P FOR NON FACTOR
        */
        //else if( oContact.Membership_Status__c != 'Surviving Spouse/Partner' && relatedOpp.Certification_Type__c == CERTIFICATION_TYPE_SELF && !ContactServices.isQualified(oContact, relatedOpp, '') )
        //{
            //relatedOpp.Certification_Page_Status_Exchange__c = CERTIFICATION_PAGE_STATUS_INPROGRESS;
        //}
        else if( relatedOpp.Certification_Type__c == CERTIFICATION_TYPE_THIRD_PARTY && relatedOpp.Certification_Status__c == CERTIFICATION_STATUS_REJECTED)
        {
            relatedOpp.Certification_Page_Status_Exchange__c = CERTIFICATION_PAGE_STATUS_INPROGRESS;
        }
        
        if (( relatedOpp.StageName == PAYMENT_STATUS_PAID || relatedOpp.StageName == STAGE_CLOSED_WON) && relatedOpp.Dues_Page_Status_Exchange__c != DUES_STATUS_COMPLETE)
        {
            relatedOpp.Dues_Page_Status_Exchange__c = DUES_STATUS_COMPLETE;
        }
        else if( relatedOpp.StageName == STAGE_PAYMENT_PENDING && relatedOpp.Dues_Page_Status_Exchange__c != DUES_STATUS_IN_PROGRESS)
        {
            relatedOpp.Dues_Page_Status_Exchange__c = DUES_STATUS_IN_PROGRESS;
        }

	    try{
	        update relatedOpp;
	    }catch(DMLException dmlex){
	        System.debug('Exception updating opp: '+ dmlex.getMessage());
	    }
	}
	
    // Visualforce Page References
	private Pagereference WELCOME_PAGE() {
		PageReference pgRef = Page.WelcomePage;
		pgRef.getParameters().put('id',oContact.id);
        pgRef.setRedirect(true);
        return pgRef;
	}
    private Pagereference RECERTIFICATION_SCREEN_PAGE() {
		PageReference pgRef = Page.Recertification_Screen;
		pgRef.getParameters().put('id',oContact.id);
        pgRef.setRedirect(true);
        return pgRef;
	}
	private Pagereference TRANSITION_PAGE() {
		PageReference pgRef = Page.Gold_Transition_Option_YPO;
		pgRef.getParameters().put('id',oContact.id);
        pgRef.setRedirect(true);
        return pgRef;
	}
    private Pagereference CATALOG_YPO_PAGE(String modal) {
		PageReference pgRef = Page.Catalog_ypo;
        if (!string.isBlank(relatedOpp.CartToken__c)) {
            pgRef.getParameters().put('ct',EncodingUtil.urlDecode(relatedOpp.CartToken__c, 'UTF-8'));
        }
		if (modal == 'Grace')
			pgRef.getParameters().put('Modal','Grace');
		else if (modal == 'Transition')
			pgRef.getParameters().put('Modal','Transition');
        pgRef.setRedirect(true);
        return pgRef;
	}
	private Pagereference THANKYOU_PAGE(String modal) {
		PageReference pgRef = Page.Splashscreen_Thankyou;
		pgRef.getParameters().put('id',oContact.id);
        pgRef.setRedirect(true);
		if (modal == 'Grace')
			pgRef.getParameters().put('Modal','Grace');
		else if (modal == 'Transition')
			pgRef.getParameters().put('Modal','Transition');
        return pgRef;
	}

	private PageReference INVOICE_PAGE(String modal) {
	    Id invoiceId;
		PageReference pgRef = Page.v_invoice;
	    try{
	        invoiceId = [Select Id From KGRenewal__Invoice__c Where KGRenewal__Opportunity__c =:relatedOpp.Id Limit 1][0].ID;
	        		
	    }catch(DMLException dmlex){
	        //Do nothing - moving on.
	    }
		pgRef.getParameters().put('id',invoiceId);
		if (modal == 'Grace')
			pgRef.getParameters().put('Modal','Grace');
		else if (modal == 'Transition')
			pgRef.getParameters().put('Modal','Transition');
        pgRef.setRedirect(true);
	    return pgRef;
	}
}