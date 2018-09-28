public without sharing class ThirdPartyCertificationExt_YPO {

    public Contact oContact {set;get;}
    public Id OpportunityId {set;get;}
    public string opp_cert_URL {set;get;}
    public static Opportunity oOpp;
    Opportunity oppObj = new Opportunity();
    @TestVisible static final String CERTIFICATION_STATUS_RECEIVED = 'Received';
    @TestVisible static final String CERTIFICATION_STATUS_REQUESTED = 'Requested';
    static final Set<String> lifetimeEligibleStatus = new Set<String> {'Eligible for early transition', 'Scheduled for transition'};
    
    public ThirdPartyCertificationExt_YPO(ApexPages.StandardController oStandardController){
        Try {
            if((Contact)oStandardController.getRecord()!= new Contact()) {
                oContact = (Contact)oStandardController.getRecord();
                oContact = [SELECT Name, LastName, Account.ParentId, Account.YPOI_Type__c, HouseHoldID__c, AccountId,YPO_WPO__c,Grace_Years_Available__c,
                                    Is_Grace_Used__c, Title,Number_of_Employees1__c,Total_Employee_Compensation__c,Last_Renewals_Page__c,
                                    Annual_Revenue__c, Enterprise_Value__c,Transition_Status__c,Number_of_Employees__c,Last_Renewals_Form__c,
                                    Age_Current__c, Number_Years_a_Member__c,LifeTime_Dues_Status__c,YPO_WPO_Formula__c FROM Contact WHERE Id =: oContact.Id];
            } else {
                User oUser = [Select Id,ContactId from User where Id =: UserInfo.getUserId()];
                if (oUser.ContactId != null) {
                    oContact = [SELECT Name, LastName, Account.ParentId, Account.YPOI_Type__c, HouseHoldID__c, AccountId,YPO_WPO__c,Grace_Years_Available__c,
                                    Is_Grace_Used__c, Title,Number_of_Employees1__c,Total_Employee_Compensation__c,Last_Renewals_Page__c,
                                    Annual_Revenue__c, Enterprise_Value__c,Transition_Status__c,Number_of_Employees__c,Last_Renewals_Form__c,
                                    Age_Current__c, Number_Years_a_Member__c,LifeTime_Dues_Status__c,YPO_WPO_Formula__c FROM Contact WHERE Id =: oUser.ContactId];
                } else {
                        throw new CustomException('No member contact record found!');
                }
            }
        } catch (CustomException CExcp) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, CExcp.getMessage()));
        }
    }
    
    public void init(){
                if (oContact != null) {
                        oOpp = ContactServices.getOpportunities(oContact);
                        if(oOpp != null)
                                OpportunityId = oOpp.Id;
                } 
    }
    
    public static List<Attachment> allAttachments {
        get {
            if(allAttachments == null){
                allAttachments = new List<Attachment>();
            }
            return allAttachments;
        }
        set;
    }    
    
    Public String selectdCertificate {set;get;}
    public List<SelectOption> getCertificateOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new Selectoption('', 'Select Option'));
        /*
        options.add(new Selectoption('Email Criteria To a Verifier', 'Email Criteria To a Verifier'));
        options.add(new Selectoption('Link To Documentation', 'Link To Documentation'));
        options.add(new Selectoption('Upload Documents', 'Upload Documents'));
        options.add(new Selectoption('Print Documentation', 'Print Documentation'));
        */
        String fld = 'X3rd_Party_Certification_Option_Chosen__c';
        options.addAll(getPicklistValues(oppObj,fld));
        system.debug('-----------------------options----------------------'+options);
        return options;
    }
    
    Public String selectdDocumentType {set;get;}
    public List<SelectOption> getDocumentTypes(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new Selectoption('', 'Select Option'));
        options.add(new Selectoption('Copy of the third party recertification form that has been verified','Copy of the third party recertification form that has been verified'));
        options.add(new Selectoption('Annual Report','Annual Report'));
        options.add(new Selectoption('10K','10K'));
        return options;
    }
    
    
    Public String selectdTypeOfPartyVerifier {set;get;}
    Public List<SelectOption> getTypeOf3rdPartyVerifier(){        
        String fld = 'Type_of_3rd_Party_Verifier__c';
        return getPicklistValues(oppObj,fld);
    }
    
    /**
     * @Author: Vasudevu
     * @Create Date: FEB 02 2017
     * @Description: Update the third party opportunity fields:
     * */    
    @RemoteAction
    public static Boolean updateAnOpportunity(String oppJSONStr){
        Opportunity opprt = (Opportunity) JSON.deserialize(oppJSONStr, Opportunity.class);
        System.debug('updateAnOpportunity() json: ' + oppJSONStr);

		try{
			System.debug('updateAnOpportunity() entered try/catch');
            // This is to be sent an email
            if(opprt.Third_Party_Email__c <> null && opprt.Third_Party_Email__c <> '' ){
				DocusignServices.envelopeDefinition ed = DocusignServices.getInstance().createEnvelope(new List<Opportunity>{opprt});
                DocusignServices.SendResults sd= DocuSignServices.getInstance().sendEnvelope(ed);
                opprt.Certification_status__c = CERTIFICATION_STATUS_REQUESTED;
				System.debug('updateAnOpportunity() send email option chosen: ' + opprt);
            }
            // Commented bcz : Item-06698 on 25 APR 2017
            //if(opprt.Third_Party_Firm_Website__c <> null && opprt.Third_Party_Firm_Website__c <> ''){
                //opprt.Certification_status__c = CERTIFICATION_STATUS_RECEIVED;
                //opprt.Date_Third_Party_Validated__c = System.today();
            //}
            else if((opprt.Third_Party_Firm_Website__c <> null && opprt.Third_Party_Firm_Website__c <> '') 
					|| (opprt.certification_documentation_url__c <> null && opprt.certification_documentation_url__c <> '')){
				opprt.Certification_status__c = CERTIFICATION_STATUS_RECEIVED;
				System.debug('updateAnOpportunity() link to doc chosen: ' + opprt);
            }
			opprt.Certification_Page_Status_Exchange__c = 'In Progress';
            update opprt;
            Return true;
        }catch(Exception oDmlException){
            //TODO UPDATE ERROR MESSAGE
            System.debug('updateAnOpportunity() error: ' + oDmlException);
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_Opportunity_Record_Found));
            return false;
        }
    }
    
    public PageReference goTo(){
        
        Opportunity theOpp = ContactServices.getOpportunities(oContact);
        
        PageReference pg = null;

                if (theOpp.StageName == 'Cycle Open') {
                        if (oContact.Lifetime_Dues_Status__c == 'Eligible for Lifetime') {
                                //send to Lifetime
                                pg = Page.Lifetimeoption_YPO;
                                pg.setRedirect(true);
                                pg.getParameters().put('Id',oContact.Id);
                        } else {
                                pg = Page.catalog_YPO;
                                pg.setRedirect(true);
                                pg.getParameters().put('Id',oContact.Id);
                        }
                } else if (theOpp.StageName == 'Payment Pending') {
                        //Send to Invoices
                        pg = Page.v_invoices;
                        pg.setRedirect(true);
                        if (!string.isBlank(theOpp.CartToken__c)) {
                                pg.getParameters().put('ct',EncodingUtil.urlDecode(theOpp.CartToken__c, 'UTF-8'));
                        }
                } else {
                        // theOpp.Dues_Page_Status_Exchange__c == 'Complete'
                        //Send to Thankyou page
                        pg = Page.Splashscreen_Thankyou;
                        pg.setRedirect(true);
                        pg.getParameters().put('Id',oContact.Id);
                }
        
        return pg;
    }
    
    @RemoteAction
    public static Opportunity getAnOpportunity(String contactJSONStr){
        Opportunity opprt = null;
        Contact oCon = (Contact) JSON.deserialize(contactJSONStr, Contact.class);
        try{
            opprt = ContactServices.getOpportunities(oCon);
            system.debug('---opprt---'+opprt);
        } catch(Exception oDmlException){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_Opportunity_Record_Found));
        }
        return opprt;
    }
    
    
    @RemoteAction
    public static String doUploadAttachment(String oppId, String attachmentBody, String attachmentName, String attachmentId,String attachmentType,String documentType) {
		System.debug('Entered doUploadAttachment');
        if(oppId != null) {
            if(attachmentBody != null) {
                Attachment att = new Attachment();
                String newBody = '';
                if(att.Body != null) {
                    newBody = EncodingUtil.base64Encode(att.Body);
                }
                newBody += attachmentBody;
                att.Body = EncodingUtil.base64Decode(newBody);
                if(attachmentId == null) {
                    att.Name = attachmentName;
                    att.parentId = oppId;
                    att.ContentType = attachmentType;
                    att.Description = documentType;
                }
                
                
                // allAttachments.add(att);
                
                upsert att;
                
                try{
                    Opportunity updateOppCertStatus = [Select Id,Name,Certification_status__c,Date_Third_Party_Validated__c FROM Opportunity WHERE Id=:oppId ];
                    updateOppCertStatus.Certification_status__c = CERTIFICATION_STATUS_RECEIVED;
                    updateOppCertStatus.Date_Third_Party_Validated__c = System.today();
                    updateOppCertStatus.X3rd_Party_Certification_Option_Chosen__c = 'Upload Documents';
                    update updateOppCertStatus;
                    return att.Id;
                }catch(Exception e){
                    System.debug('-----------Exception in upload attachment when Update the Opportunity  ------------'+e);
                    return 'Opportunity Certification Status Error';
                }
                
            } else {
                return 'Attachment Body was null';
            }
        } else {
            return 'Account could not be found';
        }
    }
    
    @RemoteAction
    public static List<Attachment> getAllAttachmentstoOpp(String oppId){
        if(oppId <> null && oppId <> ''){
            List<Attachment> attlist = [ select Id, Name,ContentType FROM Attachment where ParentId =:oppId];
            System.debug('------attlist-------'+attlist);
            return attlist;
        }else { return null; }
    }
    @RemoteAction
    public static Boolean removeAttachment(String removeAttId){
        if(removeAttId <> null && removeAttId <> ''){
        Attachment att = [select Id From Attachment Where Id = :removeAttId limit 1];
            if(removeAttId <> null){
                
                delete att;
                return true;
                
                /*
                Integer i = 0;  
                for(Attachment theA : allAttachments){
                    if(theA.Id == removeAttId){
                        allAttachments.remove(i);
                        return true;
                    }else{
                        i++;
                    }
                } */
                
            }else return false;
        } return false;
    }
    
    @RemoteAction
    public static String submitUploadDocs(String oppId){
        try{
            upsert allAttachments;
            
            oOpp.Certification_Status__c = CERTIFICATION_STATUS_RECEIVED;
            update oOpp;
        }catch(DMLException dex){
            return 'There was an error: '+dex.getMessage();         
        }
        return 'Success';
    }

    @RemoteAction
    public static String submitDocumentationURL(String oppId, String theUrl){
        try{
            
            oOpp.Certification_Documentation_URL__c = theUrl;
            oOpp.Certification_Status__c = CERTIFICATION_STATUS_RECEIVED;
            update oOpp;
        }catch(DMLException dex){
            return 'There was an error updating the opportunity: '+dex.getMessage();        
        }
        return 'Success';
    }
    
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
    
}