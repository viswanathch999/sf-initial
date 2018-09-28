public class GraceExtension_YPO {
    
    public Contact oContact {set;get;}
    public String graceReasonSelected{get; set;}
    public Opportunity oOpp {set;get;}
    public String exceptionDesc {set;get;}
    
    public Boolean hasGrace{
        get{
                if(hasGrace == null) {
                        Integer count = 0;
                        count = [Select count() from Exception__c where contact__C =: oContact.id and opportunity__c =: oOpp.Id and (Type_of_Waiver__c='Grace Extension' OR Exception_Category__c = 'Waiver' OR Exception_Category__c='Grace')];
                        if(count > 0) {
                                hasGrace = true;
                        }
                        
                        hasGrace = false;
                }
                return hasGrace;
        }set;
    }
    
    public GraceExtension_YPO(ApexPages.StandardController oStandardController){
        try {
            if((Contact)oStandardController.getRecord()!= new Contact()){
                oContact = (Contact)oStandardController.getRecord();
                getContactThroughSOQL(oContact.id);
            }
            else{
                User oUser = [Select Id,ContactId from User where Id =: UserInfo.getUserId()];
                if (oUser.ContactId != null) {
                    getContactThroughSOQL(oUser.ContactId);
                } else {
                    throw new CustomException('No member Contact record found!');
                }
            }
        } catch (CustomException Cexcp) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, CExcp.getMessage()));
        }
    }
    public void init(){
		if (oContact != null) {
			oOpp = ContactServices.getOpportunities(oContact);
		}
    }
    
    public List<SelectOption> graceReasons2{
        get {
            if (graceReasons2 == null) {                
                graceReasons2 = new List<SelectOption>();                
                graceReasons2.add(new SelectOption('','Select Option'));
                String graceOrWaiver = getExceptionType();
                Set<String> reasons = Exception_Reason__c.getAll().keySet();
                List<Exception_Reason__c> lstExceptionReason = [SELECT id, Name, Category__c FROM Exception_Reason__c ORDER BY Name ];//WHERE Category__c=:graceOrWaiver ORDER BY Name];
                if(!lstExceptionReason.isEmpty()){
                    String otherName=null;
                    for (Exception_Reason__c exReason : lstExceptionReason){
                        if(exReason.Name <> 'Other'){
                                graceReasons2.add(new SelectOption(exReason.Name,exReason.Name)); 
                        }else{
                                                        otherName = exReason.Name;                         
                        }
                    }                    
                    if(otherName <> null ){
                        graceReasons2.add(new SelectOption(otherName,otherName)); 
                    }
                }
            }
            return graceReasons2;          
        }
        set;
    }
    private String getExceptionType(){
        return ContactServices.isGraceExtension(oContact)?'Grace':'Waiver';
    }
    
    public PageReference redirectTo(){
        PageReference pageRef = Page.Recertification_Screen;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;
    }
    
    /**
        *  Method that will create a case records for accuring a grace on this cotact record
        */
    public PageReference createGracecase(){
        
        
        System.debug('----oContact.AccountId---------'+oContact.AccountId);
        System.debug('----oOpp.AccountId---------'+oOpp.AccountId);
        
        Exception__c ex = new Exception__c();
            try{
                if(oContact.Grace_Years_Available__c > 0) {
                    //ex.Type_of_Waiver__c = 'Grace';]
                    ex.Exception_Category__c = 'Grace';
                } else if(oContact.Grace_Years_Available__c == 0){
                        ex.Type_of_Waiver__c = 'Grace Extension';
                        ex.Exception_Category__c = 'Waiver';
                }
                
                ex.Type__c = graceReasonSelected;
                ex.Contact__c = oContact.Id;
                ex.Account__c = oOpp.AccountId;
                ex.Opportunity__c = oOpp.Id;
                ex.Status__c = 'Needs Chapter Approval';
                ex.Description__c = exceptionDesc;
                //ex.Exception_Category__c = getExceptionType();
                
                oOpp.Grace_Status__c = 'Requested';
        
            insert ex;
            oOpp.Certification_Page_Status_Exchange__c = 'In Progress';
            oOpp.Certification_Status__c = 'In Progress';
            update oOpp;
          
            return toVenuePage();
        }catch(Exception oDmlException){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getMessage()));
            return null;
        }
        
        return null;
    }

    /**
    *  Method to go to the Venue page
    */
    public PageReference toVenuePage(){
        PageReference pageRef = Null;
        if (oOpp.StageName == 'Cycle Open') {
            if(oContact.Lifetime_Dues_Status__c=='Eligible for Lifetime') {
                //Send to lifetime page
                pageRef = Page.LifetimeOption_YPO;
                pageRef.setRedirect(true);
                pageRef.getParameters().put('Id', oContact.Id);
            } else {
                //Send to Catalog page
                if(String.isBlank(oOpp.CartToken__c)){
                    pageRef = Page.catalog_ypo;
                } else{
                    pageRef = Page.catalog_ypo; // catalog_ypo open default popup
                    pageRef.getParameters().put('ct',EncodingUtil.urlDecode(oOpp.CartToken__c, 'UTF-8'));
                }
                pageRef.setRedirect(true);
            }
        } else if (oOpp.StageName == 'Payment Pending') {
            //Send to Invoice page
            pageRef = Page.v_invoices;
            pageRef.setRedirect(true);
            if (!string.isBlank(oOpp.CartToken__c)) {
                pageRef.getParameters().put('ct',EncodingUtil.urlDecode(oOpp.CartToken__c, 'UTF-8'));
            }
        } else {
            // Send to Thankyou page
            pageRef = page.splashscreen_thankyou;
            pageRef.setRedirect(true);
            pageRef.getParameters().put('Id', oContact.Id);
        }
        
        return pageRef;
    }
    
    public void getContactThroughSOQL(id ConId){
        oContact = [SELECT Name, LastName, Account.ParentId, Account.YPOI_Type__c, HouseHoldID__c, AccountId,YPO_WPO__c,Grace_Years_Available__c,
                        Is_Grace_Used__c, Grace_Years_Used__c, Title,Number_of_Employees1__c,Total_Employee_Compensation__c,Last_Renewals_Page__c,
                        Annual_Revenue__c, Enterprise_Value__c,Transition_Status__c,Number_of_Employees__c,Last_Renewals_Form__c,
                        Age_Current__c, Number_Years_a_Member__c, Lifetime_Dues_Status__c FROM Contact WHERE Id = :ConId];
    }
    
}