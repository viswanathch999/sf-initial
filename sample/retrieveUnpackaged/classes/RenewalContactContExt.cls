/*
 * 
 * RenewalContExt is a extension class for multiple pages of Renewal. 
 * This class will qualification criteria for different stages. 
 *
 * @author Malay Desai
 */
public with sharing class RenewalContactContExt {

    public static final String CONST_CONTACT = 'Contact';
    public static final String CONST_SPOUSE = 'Spouse_Partner';
    public static final String CONST_CHILD = 'Child';
    public static final String CONST_MEMBER = 'Member';
    public static final String TRANSITION_STATUS_OVERDUE = 'Overdue for transition';
    public static final String TRANSITION_STATUS_ELIGIBLE = 'Eligible for early transition';
    public static final String CERTIFICATION_STATUS_RECEIVED = 'Received';
    
    public String prevQualifyingCompany='';
    public List<ContactWrapper> lstSpouse{get; private set;}
    public List<ContactWrapper> lstChild{get; private set;}
    public List<Relationship__c> lstRelationship{get; private set;}
    public Opportunity oOpp{get; private set;}
    public Account oAcc{get;private set;}
    public Boolean bRelationshipPresent{get; private set;}
    public Boolean isGraceAvailable{get;private set;}
    public Boolean isTransitionAvailable{get;private set;}
    public Boolean isYPO{get; private set;}
    public Boolean isYPOToWPO{get;set;}
    public Boolean isMember{get;set;}
    public Boolean isSavedWithoutError{get;set;}
    public Boolean isfieldValidationPassed{get;set;}
    public Boolean isEmailSent{get;set;}
    public Boolean isQualifyingCompanyEditable{get;set;}
    public Boolean isSpouseAvailabe{get; private set;}
    public String acceptOrNot{get; private set;}
    public Integer rowNumber{get;set;}
    public Exception__c oException{get;set;}
    public String selectedDesiredWPORegion { get; set; }
    public List<SelectOption> desiredWPOChapters { get; private set; }
    public String selectedDesiredWPOChapter { get; set; }
    public String graceReasonSelected{get; set;}
    public Attachment attachmentOne {
        get {
            if(attachmentOne == null)
                attachmentOne = new Attachment();
            
            return attachmentOne;
        }
        set;
    }
    public Attachment attachmentTwo {
        get {
            if(attachmentTwo == null)
                attachmentTwo = new Attachment();
            
            return attachmentTwo;
        }
        set;
    }
    
    public List<SelectOption> desiredWPORegions { 
        get {
            if(desiredWPORegions == null) {
                desiredWPORegions = new List<SelectOption>();
                String defaultRegion;
                for(Account eachAcc: [SELECT id,name FROM account WHERE TYPE = 'region' ORDER BY Name]) {
                    if(oContact.Account.ParentId == eachAcc.Id) { 
                        defaultRegion = eachAcc.Id;
                    }
                    desiredWPORegions.add(new SelectOption(eachAcc.Id,eachAcc.Name));
                }
                this.selectedDesiredWPORegion = defaultRegion;
            }
            return desiredWPORegions;
        } 
        private set; 
    }
    
    public List<SelectOption> graceReasons2{
    get {
      if (graceReasons2 == null) {

        graceReasons2 = new List<SelectOption>();
        
        graceReasons2.add(new SelectOption('None','Please Select...'));
        String graceOrWaiver = getExceptionType();
        Set<String> reasons = Exception_Reason__c.getAll().keySet();
        List<Exception_Reason__c> lstExceptionReason = [SELECT id, Name, Category__c FROM Exception_Reason__c WHERE Category__c=:graceOrWaiver ORDER BY Name];
        if(!lstExceptionReason.isEmpty()){  
            for (Exception_Reason__c exReason : lstExceptionReason){
                graceReasons2.add(new SelectOption(exReason.Name,exReason.Name)); 
            }
        }
    }
      return graceReasons2;          
  }
    set;
  }
    public Boolean isOverdueForTransition {
        get {
            return oContact.Transition_Status__c == TRANSITION_STATUS_OVERDUE;
        }
        private set;
    }
    
    final Contact oContact;
    ContactModel oContactModel;
    Account oHouseHoldAccount;
    Relationship__c oRelationship;
    Id spouseRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_SPOUSE, CONST_CONTACT).Id;
    Id childRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_CHILD, CONST_CONTACT).Id;
    Id memberRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_MEMBER, CONST_CONTACT).Id;
    String sLastName;
    
    public RenewalContactContExt(Apexpages.StandardController oStandardController){
        if(!Test.isRunningTest()) {
            oStandardController.addFields(new List<String>{'LastName','Account','Account.ParentId','HouseHoldID__c', 'AccountId','YPO_WPO__c','Grace_Years_Available__c',
                                                            'Is_Grace_Used__c', 'Grace_Years_Used__c', 'Title','Number_of_Employees1__c','Total_Employee_Compensation__c','Last_Renewals_Page__c',
                                                            'Annual_Revenue__c','Enterprise_Value__c','Transition_Status__c','Number_of_Employees__c','Last_Renewals_Form__c'});
        }
        oContact = (Contact)oStandardController.getRecord();
        isYPO = (oContact.YPO_WPO__c=='YPO'?true:false); 
        isMember = (oContact.RecordTypeId==memberRecordTypeId?true:false); 
        isGraceAvailable = false;
        isTransitionAvailable = false;
        isSpouseAvailabe = false;
        oException=new Exception__c();
        isQualifyingCompanyEditable = true;
        isSavedWithoutError = true;
        isfieldValidationPassed = true;
    }
    
    private String getExceptionType(){
        return ContactServices.isGraceExtension(oContact)?'Grace':'Waiver';
    }
    
    /*
     *  Method checks for the relationship record associated with contact. 
     *  If relationship record is not present then error message is thrown to the page.
     */
    public void init(){
        if(oRelationship == null){
                isGraceAvailable = ContactServices.isGraceAvailable(oContact);
                isTransitionAvailable = ContactServices.isTransitionAvailable(oContact);
                List<Id> rllist = new List<Id>{spouseRecordTypeId,childRecordTypeId};
                List<Contact> lstContact = ContactServices.getChildrenAndSpouse(oContact);
                if(!lstContact.isEmpty()){
                    Integer i=0;
                            
                     for(Contact con: lstContact){
                        if(con.RecordTypeId.equals(spouseRecordTypeId)){
                                lstSpouse = new List<ContactWrapper>{new ContactWrapper(con,0)};
                        }else{
                            if(lstChild == null){
                                    lstChild = new List<ContactWrapper>();
                            }
                            lstChild.add(new ContactWrapper(con,i++));
                        }
                     }
                }                                                                                                                                                                                                                                                                       
            try{
                oRelationship = ContactServices.getRelationship(oContact);  
                bRelationshipPresent = (oRelationship==null)?false:true;
            } catch(Exception oDmlException){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_Relationship_Record_Found));
                bRelationshipPresent = false;
            } 
            try{
                 oOpp = ContactServices.getOpportunities(oContact);
            } catch(Exception oDmlException){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_Opportunity_Record_Found));
            }
            try{
                 oAcc = ContactServices.getAssociatedAccount(oContact);
            } catch(Exception oDmlException){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Account_Not_Found));
            }
            saveLastVisitedPage();
            filterRegionChapters();
        }
    }
    
    public PageReference redirectTo(){
        PageReference pageRef = new PageReference(oContact.Last_Renewals_Page__c);
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;
    }
    private void saveCurrentPage(){
        PageReference pg = ApexPages.currentPage();
        Id id = pg.getParameters().get('Id');
        pg.getParameters().clear(); // To get rid of view state
        pg.getParameters().put('Id', id);
          
        oContact.Last_Renewals_Page__c = pg.getURL();
        try{
             update oContact;
        } catch(Exception oDmlException){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Page_Not_Saved));
        }
    }
    public PageReference redirectToLastPage(){
        PageReference pageRef = new PageReference(oContact.Last_Renewals_Form__c);
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;
    }
    private void saveLastVisitedPage(){
        PageReference pg = ApexPages.currentPage();
        Id id = pg.getParameters().get('Id');
        pg.getParameters().clear();  // To get rid of view state
        pg.getParameters().put('Id', id);
        oContact.Last_Renewals_Form__c = pg.getUrl();
        try{
             update oContact;
        } catch(Exception oDmlException){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Page_Not_Saved));
        }
    }
    public void filterRegionChapters() {
       for(SelectOption eachOption :desiredWPORegions) {
            if(oContact.Account.ParentId == eachOption.getValue()) { 
                selectedDesiredWPORegion = eachOption.getValue();
                break;
            }
        }
        
        desiredWPOChapters = new List<SelectOption>();
        for(Account eachAcc: [SELECT id,name FROM account WHERE ParentId = :selectedDesiredWPORegion AND Type='Chapter' AND Name LIKE 'WPO%' 
                                AND Status__c = 'Active' AND New_Member_Status__c != 'Closed to New Members' ORDER BY Name]) {
            desiredWPOChapters.add(new SelectOption(eachAcc.Id,eachAcc.Name));
        }
    }
    
    public void makeQualifyingCompanyEditable(){
        isQualifyingCompanyEditable = false;
        prevQualifyingCompany = oOpp.Qualifying_Company__c;
    }
    
    /**
     *  Method to move to MemberBio page from welcome page
     */
    public PageReference toMemberBio(){
        saveCurrentPage();
        PageReference pageRef = Page.MemberBio;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;
    }
    
    public PageReference beginRenewals() {
        return WPOCheck();    
    }
    
    /**
     *  Method for WPO Check
     */
    public PageReference WPOCheck(){
        PageReference pageRef;
        if(!isYPO) {
            pageRef = toMemberBio();
        } else {
            if(oContact.Transition_Status__c == TRANSITION_STATUS_ELIGIBLE || 
               oContact.Transition_Status__c == TRANSITION_STATUS_OVERDUE ){
                pageRef = WPOTransition();
            } else {
                pageRef = toMemberBio();
            }
        }
        return pageRef;
    }
    
    public PageReference WPOTransition(){
        PageReference pageRef = Page.WPOTransition;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;
    }
    
    /**
     *  Method to check if the Grace can be availed 
     */
    public PageReference requestGrace(){
        saveCurrentPage();
        PageReference pageRef = Page.RequestGrace;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;
    }
    
    private Boolean isThirdPartyVerifierBlank() {
        return (String.isBlank(oOpp.Third_Party_Name__c) || String.isBlank(oOpp.Third_Party_Firm__c) || oOpp.Third_Party_Email__c == null);
    }
    
    public void uploadThirdPartyVerifier(){
        isEmailSent = false;
        if(isThirdPartyVerifierBlank()){  
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Required_Field_Missing));
        } else{
            DocusignServices.envelopeDefinition ed = DocusignServices.getInstance().createEnvelope(new List<Opportunity>{oOpp});
            DocusignServices.SendResults sd= DocuSignServices.getInstance().sendEnvelope(ed);

            try {
                update oOpp;
                isEmailSent = true;  
            } catch(DMLException oDmlException){
                for(Integer i =0; i < oDmlException.getNumDml(); i++) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getDmlMessage(i)));
                }
            }
            
        }
    }
    
    
    public PageReference uploadThirdPartyCertificationDocuments() {
        List<Attachment> attachmentsToInsert = new List<Attachment>();
        
        if(attachmentOne.Body != null){
            attachmentOne.ParentId = oOpp.Id;
            attachmentsToInsert.add(attachmentOne);
        }
        if(attachmentTwo.Body != null){
            //attachmentOne.ParentId = oOpp.Id;
            attachmentTwo.ParentId = oOpp.Id;
            attachmentsToInsert.add(attachmentTwo);
        }
        
        if(oOpp != null) oOpp.Certification_status__c = CERTIFICATION_STATUS_RECEIVED;
        try{
           update oOpp;
        }catch(Exception oDmlException){
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getMessage()));
        }
        if(!attachmentsToInsert.isEmpty()) {
           insert attachmentsToInsert;  
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Document_Attachment_Error));
            return null;
        }    
        
        return toVenuePage();    
    }
   
    /**
     *  Method that will create a case records for accuring a grace on this cotact record
     */
    public PageReference createGracecase(){
        if(graceReasonSelected.equalsIgnoreCase('None')){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Reason_Is_Required));
            return null;
        }
        
        Case graceCase = new Case();
        graceCase.Subject = getExceptionType();
        graceCase.Origin = 'Web';
        graceCase.Status = 'Open';
        graceCase.Description = 'Came in from Renewals';
        graceCase.ContactId = oContact.Id;
        graceCase.AccountId = oContact.AccountId;

        try{
           insert graceCase;   
        }catch(Exception oDmlException){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getMessage()));
            return null;
        }
        
        Exception__c ex = new Exception__c();
        ex.Contact__c = oContact.Id;
        ex.Account__c = oContact.AccountId;
        ex.Opportunity__c = oOpp.Id;
        ex.Status__c = 'Received';
        ex.Exception_Category__c = getExceptionType();
        ex.Description__c = 'Came in from Renewals';
        ex.CaseId__c = graceCase.Id;
        
        try{
           insert ex;   
        }catch(Exception oDmlException){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getMessage()));
            return null;
        }
        
        return (oOpp.Certification_Type__c == 'Third Party Certify') ? toThirdPartyCertification() : toVenuePage();
    }
    
    public PageReference saveDesiredWPOChapter() {
        List<Membership_History__c> lstMembershipHistoryOld = [SELECT id, Date_Left__c,Status__c,Reason__c FROM Membership_History__c 
        WHERE Date_Left__c = null AND Status__c = 'Member' AND Contact__c = :oContact.Id];
        Membership_History__c oMembershipHistoryOld;
        if(!lstMembershipHistoryOld.IsEmpty() && lstMembershipHistoryOld.size() > 0){
            oMembershipHistoryOld = lstMembershipHistoryOld.get(0);
            oMembershipHistoryOld.Date_Left__c = Date.newInstance(System.Today().year(), 6, 30);
            oMembershipHistoryOld.Status__c = 'Resigned';
            oMembershipHistoryOld.Reason__c = 'Transitioned';
        } 
        
        Membership_History__c oMembershipHistoryNew = new Membership_History__c();
        oMembershipHistoryNew.Contact__c = oContact.Id;
        oMembershipHistoryNew.Status__c = 'Member';
        oMembershipHistoryNew.YPO_WPO__c = 'WPO';
        oMembershipHistoryNew.Join_Date__c = Date.newInstance(System.Today().year(), 7, 1);
        
        
        if(String.isBlank(selectedDesiredWPOChapter)) {
            oMembershipHistoryNew.Account__c = [SELECT Id FROM Account WHERE Name = 'Needs Chapter' LIMIT 1].Id;
        } else{
            oMembershipHistoryNew.Account__c = selectedDesiredWPOChapter;
        }
        if(oOpp != null) oOpp.Transition_Via_Renewal_Form__c = true;
        try{
            insert oMembershipHistoryNew;
            if(oMembershipHistoryOld != null) update oMembershipHistoryOld;
            if(oOpp != null) update oOpp;
        } catch (Exception oDmlException){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getMessage()));
            return null;
        }
        
        return toMemberBio();
    }
    
    /**
     *  Method to request transition
     *  TODO: Not being used, remove later
     */
    public PageReference requestTransition(){
        return toDesiredWPOChapter();
    }
    /**
     *  Method to go to the Venue page
     */
    public PageReference toVenuePage(){
        PageReference pageRef;
        if(String.isBlank(oOpp.CartToken__c)){
            pageRef = Page.v_catalog;
        } else{
            pageRef = Page.v_loadCart;
            pageRef.getParameters().put('ct',EncodingUtil.urlDecode(oOpp.CartToken__c, 'UTF-8'));
        }
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference toMemberPortal(){
        PageReference pageRef = new PageReference('https://www.ypowpo.org');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    private Boolean isQualifyingCompanyBlank() {
      return (oContact.Date_Last_Grace_Year_Used__c != Date.newInstance(System.Today().year(), 7, 1) && String.isBlank(oOpp.Qualifying_Company__c));  
    }
    
    public void saveOnRecertification() {
        if(!isQualifyingCompanyEditable){
            if(isQualifyingCompanyBlank()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Qualifying_Company_Error));
                return;
            }
        }
        //if(isQualifyingCompanyEditable){
        if(isfieldValidationPassed()){
            try{
                update oOpp;
                if(!isQualifyingCompanyEditable /*also check whether old and new company is different */) update oAcc; // if the qualifying company is not change, there no need to update account
            }catch(Exception oDmlException){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getMessage()));
            }
        } else{
            isfieldValidationPassed = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Required_Field_Missing));
        }
        //}
    }
    
    public Boolean isfieldValidationPassed(){
        return (oOpp.President_Type__c != null && oAcc.Firm_Type__c != null && oOpp.Organization_Type__c != null && 
                oOpp.Title__c != null && oOpp.NumberOfEmployees__c != null);
    } 
    
    /**
     *  Method to check if the member meets the qualification criteria
     */
    public PageReference checkQualificationCriteria(){
        if(ContactServices.isQualified(oContact,oOpp,prevQualifyingCompany)){
            //ContactServices.checkAssociatedAccount(oOpp.Qualifying_Company__c, oContact); // Check where an account record with Qualifying company name exist, if not create one and create Acc Aff.
            if((oOpp.Certification_Type__c == 'Third Party Certify')){
                return toThirdPartyCertification();
            }else{
                oOpp.Certification_status__c = 'Complete';
                try{
                    update oOpp;
                    return toVenuePage();
                }catch(DMLException oDmlException){
                    for(Integer i =0; i < oDmlException.getNumDml(); i++)
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getDmlMessage(i)));
                    return null;
                }
            }
        } else{
            return toContactMemberServices(); 
        }
    }
    
    public PageReference toContactMemberServices(){
        saveCurrentPage();
        PageReference pageRef = Page.ContactMemberServices;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;
    }
    
    /**
     *  Method to check if the Grace can be availed 
     */
    public PageReference changeQualifyingCompany(){
        PageReference pageRef;
        if(oOpp != null && oOpp.Transition_Via_Renewal_Form__c) {
            return toVenuePage();
        }
        if(!isSavedWithoutError) { 
            return toMemberBio();
        }
        pageRef = Page.ChangeQualifyingCompany;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;
    }
    
    public PageReference toDesiredWPOChapter() {
        PageReference pageRef = Page.DesiredWPOChapter;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;    
    }
	
	public PageReference toVCatalog() {
        PageReference pageRef = Page.v_catalog;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;    
    }
    
    public PageReference toThirdPartyCertification() {
        PageReference pageRef = Page.ThirdPartyCertification;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;    
    }
    
    public PageReference toThirdPartyCertificationUpload() {
        PageReference pageRef = Page.ThirdPartyCertificationUpload;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;    
    }
    
    public PageReference toThirdPartyCertificationVerifier() {
        PageReference pageRef = Page.ThirdPartyCertificationVerifier;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;    
    }
    
        
    /*
     * Method to add spouse to the contact.
     * By default spouse record type id and parent contact id are assigned to the new instance.
     */
    public void addSpouse(){
        if(lstSpouse == null || lstSpouse.IsEmpty()){
            lstSpouse = new List<ContactWrapper>();
        }else if(lstSpouse.size() >= 1){
            this.isSpouseAvailabe = true;
            return; 
        }
        lstSpouse.add(new ContactWrapper(createContact(oContact.AccountId, oContact.HouseHoldID__c, spouseRecordTypeId, oContact.LastName),lstSpouse.size()));
    }
    
    /*
     * Method to add child to the contact.
     * By default child record type id and parent contact id are assigned to the new instance.
     */
    public void addChild(){
        if(lstChild == null || lstChild.IsEmpty()){
            lstChild = new List<ContactWrapper>();
        }
        lstChild.add(new ContactWrapper(createContact(oContact.AccountId, oContact.HouseHoldID__c, childRecordTypeId, oContact.LastName),lstChild.size()));
    }
    
    /*
        Method to create contact record with relationship type.
     */
    private Contact createContact(Id accountId, Id householdId, Id recordType, String sLastName){
        return new Contact(AccountId = accountId, HouseHoldId__c = householdId, RecordTypeId = recordType, LastName = sLastName);
    }
    /*
     * Method to save the updated contact details, spouse and childs.
     * Method is adding new contacts for spouse and child to the system.    
     */
    public PageReference saveSpouseAndChild(){
        try{
            update oContact;
        } catch (DMLException oDmlException){
            for(Integer i =0; i < oDmlException.getNumDml(); i++)
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getDmlMessage(i)));
             isSavedWithoutError = false;
            return null;
        }
        List<Contact> lstChildCon = new List<Contact>();
        List<Contact> lstSpouseCon = new List<Contact>();
        if(lstChild != null) { 
            for(ContactWrapper cw : lstChild) {
                if(!String.isBlank(cw.birthDate)) {
                    cw.con.BirthDate = Date.parse(cw.birthDate);
                }
                lstChildCon.add(cw.con);   
            } 
        }
        if(lstSpouse != null) {
            for(ContactWrapper cw : lstSpouse) {
                if(!String.isBlank(cw.birthDate)) {
                    cw.con.Birthdate = Date.parse(cw.birthDate);
                }
                lstSpouseCon.add(cw.con);
            }
        }
        try{       
            lstRelationship = new List<Relationship__c>();  
            List<Database.UpsertResult> lstUr = Database.upsert(lstChildCon,true);
            for(Database.UpsertResult ur : lstUr){
                if(ur.created){
                    lstRelationship.add(ContactServices.createRelationship(ur.Id, oContact.HouseholdID__c,CONST_CHILD));
                }
            } 
            lstUr = Database.upsert(lstSpouseCon,true);
            for(Database.UpsertResult ur : lstUr){
                if(ur.created){
                    lstRelationship.add(ContactServices.createRelationship(ur.Id, oContact.HouseholdID__c,CONST_SPOUSE));
                }
            }  
             if(lstRelationship != null)
                insert lstRelationship;
        }catch(DMLException oDmlException){
            for(Integer i =0; i < oDmlException.getNumDml(); i++)
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getDmlMessage(i)));
             isSavedWithoutError = false;
            return null;
        }
        return null; 
    }
    
    /*
     * Method to remove selected child from the page.
     */
    public PageReference removeChild(){
              
        rowNumber = (rowNumber>=lstChild.size())?0:rowNumber;
        Relationship__c relationshipTemp = ContactServices.getRelationship(lstChild.get(rowNumber).con);
        if(relationshipTemp!=null){
            relationshipTemp.Is_Active__c = false;
            try{
                update relationshipTemp;   
            }catch(Exception oDmlException){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getMessage()));
            }
        }
        if(rownumber >= 0) lstChild.remove(rowNumber);   
        
        if(lstChild.isEmpty()){
            lstChild = null;    
        }
        return null;
    }
    
    /*
     * Method to remove selected spouse from the page.
     */    
    public PageReference removeSpouse(){
        Relationship__c relationshipTemp = ContactServices.getRelationship(lstSpouse.get(rowNumber).con);
        if(relationshipTemp != null){
            relationshipTemp.Is_Active__c = false;
            try{
                update relationshipTemp;   
            }catch(Exception oDmlException){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getMessage()));
            }
        }
        isSpouseAvailabe = false;
        lstSpouse.remove(rowNumber);   
        
        if(lstSpouse.isEmpty()){
            lstSpouse = null;    
        }
        return null;
    }
    
    public Class ContactWrapper{
        public Integer lineNo{get;set;}
        public Contact con{get;set;}
        public String birthDate { get; set;}
            
        public ContactWrapper(Contact con, Integer oLineNo){
            this.con = con;
            lineNo = oLineNo;
            if(con.Birthdate != null) {
                this.birthDate = con.Birthdate.format();
            }                
        }
    }
}