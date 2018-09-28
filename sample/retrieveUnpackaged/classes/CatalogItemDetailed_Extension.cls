/**
* Author: Vasu
* Description: 
* Created Date:
* Modified Date
**/
global without sharing class CatalogItemDetailed_Extension
{
    public String selectedContactId {get;set;}
    public Contact con {get;set;}
    static final String CONST_CONTACT = 'Contact';
    static final String CONST_SPOUSE = 'Spouse_Partner';
    static final String CONST_CHILD = 'Child';
	static final String CONST_MEMBER = 'Member';
    public Contact oContact{get;set;}
    list<Relationship__c> oRelationships;
	Relationship__c oRelationship;
	public boolean hasAspouse {get;set;}
    public String CurrencyCode {get;set;}
	static final Integer minAge = 18;
	static final Integer maxAge = 30;
	public string Birthdate_Month {get;set;}
	public string Birthdate_Year {get;set;}
	public string Birthdate_Day {get;set;}

    public String SpousePartnerChildRecordTypeId {get;set;}
    
    public Id childRecordTypeId{
        get{
            if(childRecordTypeId == null)
            {
                childRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_CHILD, CONST_CONTACT).Id;
            }
            return childRecordTypeId;
        }set;
    }
    
    public Id spouseRecordTypeId{
        get{
            if(spouseRecordTypeId == null)
            {
                spouseRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_SPOUSE, CONST_CONTACT).Id;
            }
            return spouseRecordTypeId;         
        }set;}    
    
    public Id memberRecordTypeId{
        get{
            if(memberRecordTypeId == null)
            {
                memberRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_MEMBER, CONST_CONTACT).Id;
            }
            return memberRecordTypeId;
        }set;
    }
    
    private final KGRenewal.VenueDetailController venueCtrl { get; set; }
    /*****************************************************************************/
    public List<String> imageList {
        get {
            if(imageList == null) {
                imageList = setupImageList(venueCtrl.item.record);
            }
            return imageList;
        }
        private set;
    }
    
    public boolean cameFromLifetimePage {
        get{
                if(cameFromLifetimePage == null){
                        
                        if(ApexPages.currentPage().getParameters().get('lifetime') == 'true'){
                                cameFromLifetimePage = true;
                        }else{
                                cameFromLifetimePage = false;
                        }
                }
                return cameFromLifetimePage;
        }set;
    }
    
    /*****************************************************************************/
    public CatalogItemDetailed_Extension(KGRenewal.VenueDetailController v)
    {
        venueCtrl = v;
        Id thiscontactId = KGRenewal.Cart.getContactId();
        CurrencyCode = UserInfo.getDefaultCurrency();
        con = new Contact();
        //imageList = setupImageList(venueCtrl.item.record);
        oContact = [SELECT LastName,AccountId FROM Contact WHERE Id =: thiscontactId];
        Relationship__c Household = [SELECT Id, Account__c, Relationship_Type__c FROM Relationship__c WHERE Contact__c = :oContact.id AND Is_Active__c = true LIMIT 1];
		oRelationships = [SELECT Id, Account__c, Relationship_Type__c FROM Relationship__c WHERE Account__c = :Household.Account__c AND Is_Active__c = true];
		System.debug('Household.Account__c: ' + Household.Account__c);
		System.debug('Relationship List size: ' + oRelationships.size());
		hasAspouse = false;
		for (Relationship__c oRelationship : oRelationships) {
			if (oRelationship.Relationship_Type__c == 'Spouse/Partner') {
				hasAspouse = true;
				System.debug('hasAspouse marked as true');
			}
		}
    }
    /*****************************************************************************/
    
    //public PageReference addToCartSave(){
        //try{
            //con = updatePhoneCountryCodeBasedOnType(con);
            //upsert con;
        //}catch(Exception e){
            //system.debug('**********addToCartSave in CatalogItemDetailed_Extension **********'+e.getMessage());
        //}        
        //return null;
    //}
    
    @TestVisible
    private List<String> setupImageList(Product2 record)
    {
        List<String> imageList = new List<String>();
        
        if (String.isNotBlank(record.KGRenewal__MainImageSmall__c)) {
            imageList.add(record.KGRenewal__MainImageSmall__c);
        }
        if (String.isNotBlank(record.KGRenewal__SecondImageSmall__c)) {
            imageList.add(record.KGRenewal__SecondImageSmall__c);
        }
        if (String.isNotBlank(record.KGRenewal__ThirdImageSmall__c)) {
            imageList.add(record.KGRenewal__ThirdImageSmall__c);
        }
        if (String.isNotBlank(record.KGRenewal__FourthImageSmall__c)) {
            imageList.add(record.KGRenewal__FourthImageSmall__c);
        }
        if (String.isNotBlank(record.KGRenewal__MainImageMed__c)) {
            imageList.add(record.KGRenewal__MainImageMed__c);
        }
        if (String.isNotBlank(record.KGRenewal__SecondImageMed__c)) {
            imageList.add(record.KGRenewal__SecondImageMed__c);
        }
        if (String.isNotBlank(record.KGRenewal__ThirdImageMed__c)) {
            imageList.add(record.KGRenewal__ThirdImageMed__c);
        }
        if (String.isNotBlank(record.KGRenewal__FourthImageMed__c)) {
            imageList.add(record.KGRenewal__FourthImageMed__c);
        }
        if (String.isNotBlank(record.KGRenewal__MainImageLarge__c)) {
            imageList.add(record.KGRenewal__MainImageLarge__c);
        }
        if (String.isNotBlank(record.KGRenewal__SecondImageLarge__c)) {
            imageList.add(record.KGRenewal__SecondImageLarge__c);
        }
        if (String.isNotBlank(record.KGRenewal__ThirdImageLarge__c)) {
            imageList.add(record.KGRenewal__ThirdImageLarge__c);
        }
        if (String.isNotBlank(record.KGRenewal__FourthImageLarge__c)) {
            imageList.add(record.KGRenewal__FourthImageLarge__c);
        }
        return imageList;
    }
    /*****************************************************************************/
    public List<SelectOption> getContactOptions()
    {
        //SelectOption option = new SelectOption(value, label, isDisabled);
        
        List<SelectOption> contactOptions = new List<SelectOption>();
        //contactOptions.add(new SelectOption('', 'Select a household member', true));
        try
        {
            /*
            Id userId = UserInfo.getUserId();
            Id accountId = [SELECT AccountId FROM User WHERE Id = :userId].AccountId;
            List<Contact> contactList = [SELECT Name FROM Contact WHERE AccountId = :AccountId ORDER BY Name];
            for(Contact con : contactList)
            {
            contactOptions.add(new SelectOption(con.Id, con.Name));
            }
            Id theProductId = ApexPages.currentPage().getParameters().get('id');
            contactOptions = KGServiceClass.getListOfEligibleContacts(theProductId);
            */
            contactOptions = KGServiceClass.getListOfEligibleContacts(venueCtrl.item.record);
            
            system.debug('-------venueCtrl.item.record--------'+venueCtrl.item.record);
        }
        catch(exception e)
        {}
        
        System.debug('###contactOptions: ' + contactOptions);
        return contactOptions;
    }
    /*****************************************************************************/
    public boolean hasAvailableContactOptions {
        get {
            return KGServiceClass.hasAvailableContactOptions(getContactOptions());
        }
        set;
    }
    /*****************************************************************************/
    public PageReference setProspectOppAsCart()
    {
        //return KGServiceClass.setProspectOppAsCart();
        //        PageReference pr;
        PageReference pr;
        PageReference ncp = Page.NullCheckPage;
         pr = KGServiceClass.setProspectOppAsCart();
         if(pr.getURL() != ncp.getURL())
         {
          pr.setRedirect(TRUE);
          return pr;
         }
         return null;
    }
    /*****************************************************************************/
    /*****************************************************************************/
    // Sets Opportunity.KGRenewal__isActiveCart__c = TRUE on Renewal Opp
    public void activateRenewal()
    {
        System.debug('***************************** ENTER: v_detailControllerExt.activateRenewal()');
        /*Id cartId = KGRenewal.Cart.getOpportunityId();
        Opportunity thisCart = [SELECT Referred_by_Chapter__c,
        Record_Type_Name__c,
        KGRenewal__Contact__c
        FROM Opportunity
        WHERE Id = :cartId];
        Map<String, Object> params = new Map<String, Object>();
        params.put('varOpptyID', thisCart.Id);
        params.put('varRefChapID', thisCart.Referred_by_Chapter__c);
        params.put('varOppRecordType', thisCart.Record_Type_Name__c);
        params.put('varContactID', thisCart.KGRenewal__Contact__c);
        Flow.Interview.Set_Products setProductsFlow = new Flow.Interview.Set_Products(params);
        setProductsFlow.start();
        */
        //Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        Id contactId = KGRenewal.Cart.getContactId();
        if( contactId == null)
        {
            return;
        }
        
        List<OpportunityContactRole> ocrList = [SELECT Opportunity.KGRenewal__isActiveCart__c,
                                                Opportunity.KGRenewal__PreviousSale__c,
                                                Opportunity.KGRenewal__ContractEndDate__c,
                                                Opportunity.Probability,
                                                Opportunity.IsClosed
                                                FROM OpportunityContactRole
                                                WHERE ContactId = :contactId
                                                AND IsPrimary = true
                                                ORDER BY CreatedDate DESC];
        
        List<Opportunity> oppsToUpate = new List<Opportunity>();
        Set<Id> oppIdSet = new Set<Id>();
        boolean foundCurrentRenewalOpp = false;
        Integer length = ocrList.size();
        for(Integer i = 0; i < length; i++)
        {
            Opportunity opp = ocrList[i].Opportunity;
            if( ! oppIdSet.add(opp.Id) )
            {
                // already processed this Opp, continue to next Opp
                continue;
            }
            
            if( foundCurrentRenewalOpp == false
               && opp.KGRenewal__PreviousSale__c != null
               && opp.Probability != 100
               && ! opp.IsClosed
               && opp.KGRenewal__ContractEndDate__c != null
               && opp.KGRenewal__ContractEndDate__c.year() == System.today().year() + 1 )
            {
                foundCurrentRenewalOpp = true;
                if( ! opp.KGRenewal__isActiveCart__c )
                {
                    oppsToUpate.add( new Opportunity(Id = opp.Id,
                                                     KGRenewal__isActiveCart__c = true) );
                }
                continue;
            }
            
            if( opp.KGRenewal__isActiveCart__c )
            {
                oppsToUpate.add( new Opportunity(Id = opp.Id,
                                                 KGRenewal__isActiveCart__c = false) );
            }
        }
        if( foundCurrentRenewalOpp )
        {
            update oppsToUpate;
        }
        System.debug('***************************** EXIT: v_detailControllerExt.activateRenewal()');
    }
    //Josh Add method to populate selected contact fields
    public void getselContact(){
        if(selectedContactId!=''){
            con=[SELECT Id,Name,LastName,FirstName,Email,Birthdate,Preferred_Phone__c,Country_Code__c,phone, HomePhone,Home_Phone_Country_Code__c, 
                 MobilePhone,Mobile_Phone_Country_Code__c,OtherPhone,Other_Phone_Country_Code__c,Phone_Map__c,Country_Code_Map__c,
                 RecordTypeId,RecordType.Name FROM Contact WHERE ID=:selectedContactId];
            selectedContactId=con.Id;
        }else{
            con=new Contact(AccountId = oContact.AccountId, RecordTypeId = childRecordTypeId, LastName = oContact.LastName);
        }
    }

	@TestVisible
	private void Phone_Realignment() {
		if(con.Preferred_Phone__c == null)
			con.Preferred_Phone__c = 'Mobile Phone';

		System.debug('Updating of ' + con.Preferred_Phone__c);
		System.debug('Phone: ' + con.Country_Code__c + '-' + con.Phone);
        con.MobilePhone = con.Phone_Map__c;
        con.Mobile_Phone_Country_Code__c = con.Country_Code_Map__c;
        //con.Phone = null;
        //con.Country_Code__c = null;
	}
    
    public PageReference updateContactRecord(){
        system.debug(Logginglevel.ERROR+'********** Contact Record:*********\n '+ con);
        system.debug('Contact ID: '+ con.Id);
		if (String.isNotEmpty(Birthdate_Year)) { // We have a date to convert
			con.Birthdate = Date.newInstance(Integer.valueOf(Birthdate_Year),Integer.valueOf(Birthdate_Month),Integer.valueOf(Birthdate_Day));
			System.debug('con.Birthdate: ' + con.Birthdate);
			Birthdate_Year = Birthdate_Month = Birthdate_Day = null;
		}
                
        if(String.isNotBlank(con.Id) ){            
            System.debug('###Contact Update: ' + con);
			Phone_Realignment();

			try {
				update con;
			} catch (Exception Excpt) {
				System.debug('Error Updating contact: ' + Excpt.getMessage());
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Excpt.getMessage()));
			}
        }else { 
            system.debug('###Contact Insert: ' + con);
            if(oRelationship == null){
				try {
					oRelationship = [SELECT Id, Account__c, Relationship_Type__c FROM Relationship__c WHERE Contact__c = :oContact.id AND Is_Active__c = true LIMIT 1];
				} catch (Exception Excpt) {
					System.debug('Error finding primary relationship: ' + Excpt.getMessage());
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Excpt.getMessage()));
				}
            }
            try{
                con.id=null;
                con.recordtypeid = SpousePartnerChildRecordTypeId;
                con.AccountId = oContact.AccountId;
				//RMB renewal defect(174) - code change to work with current workflow related with phones (01Q61000000ZZCv)
				con.Preferred_Phone__c = 'Mobile Phone';
				con.Country_Code__c = con.Country_Code_Map__c;
				con.Phone = con.Phone_Map__c;
                System.debug('### con insert: ' + con);
                insert con;
                //selectedContactId = con.Id;
				if(con <> null && con.Id <> null && oRelationship <> null && oRelationship.Account__c <> null){
					if (con.RecordTypeId == childRecordTypeId) {
						Relationship__c rel = Utility.createRelationship(con.id, oRelationship.Account__c, 'Child');
						insert rel;
					} else { //must be a spouse record
						Relationship__c rel = Utility.createRelationship(con.id, oRelationship.Account__c, 'Spouse/Partner');
						insert rel;
						hasAspouse = true;
					}
				}
            }catch(Exception Excpt){
				System.debug('Error Inserting contact: ' + Excpt.getMessage());
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Excpt.getMessage()));
            }
        }
		return null;
    }
    
    @RemoteAction
    global static String updateCatalogItemContact(String itemdetailConId){
        if(itemdetailConId <> null  && itemdetailConId <> ''){
            Contact c = [select Id, FirstName, LastName,Gender__c, Email, Birthdate, 
                         Preferred_Phone__c, Country_Code__c, Phone, HomePhone,Home_Phone_Country_Code__c, MobilePhone, Mobile_Phone_Country_Code__c, OtherPhone, Other_Phone_Country_Code__c,
                         Phone_Map__c, Country_Code_Map__c, RecordTypeId, Record_Type_Name__c FROM Contact WHERE Id =:itemdetailConId];
			System.debug('Users Birthday: ' + c.Birthdate);

            ////The screen is to be displaying only the Mobile phone according to design specifications for Renewal screens
            //if(c.Preferred_Phone__c == 'Business Phone'){
				//c.phone = c.phone; // Business Phone captured from UI
                //c.Country_Code__c = c.Country_Code__c; // Business Country Code captured from UI
            //}else if(c.Preferred_Phone__c == 'Home Phone'){
                //c.phone = c.HomePhone;
                //c.Country_Code__c = c.Home_Phone_Country_Code__c;               
            //}else if(c.Preferred_Phone__c == 'Mobile Phone'){
                c.Phone_Map__c = c.MobilePhone;
                c.Country_Code_Map__c = c.Mobile_Phone_Country_Code__c;
            //}else if(c.Preferred_Phone__c == 'Other Phone'){
                //c.phone = c.OtherPhone;
                //c.Country_Code__c = c.Other_Phone_Country_Code__c;
            //}else if(c.Preferred_Phone__c == 'Business Fax'){
                //c.phone = c.Fax;
                //c.Country_Code__c = c.Fax_Country_Code__c;
            //}else if(c.Preferred_Phone__c == 'Home Fax'){
                //c.phone = c.HomeFax__c;
                //c.Country_Code__c = c.Home_Fax_Country_Code__c;
            //}
            
            return JSON.serialize(c);
            
        }else{
            return null;
        }        
    }

    @RemoteAction
    global static Boolean isFiscalAge(string DateOfBirth){
		//Date must be in format of YYYY-MM-DD HH:nn:ss
		System.debug('DOB: ' + DateOfBirth);
		if(DateOfBirth != null) {
			try {
				date Birthdate = Date.valueOf(DateOfBirth);
				date DateToday = Date.today();
				//date NextFiscalyeardate = FiscalDateUtility.startOfNextFiscal;
				date FiscalYearDate = Date.newInstance(Date.today().year(),7,1);

				//should coincide with Product_Eligibility__c field on the Contact object.
				if (Birthdate.month() < 7) {
					//Use Fiscal date to determine eligibility
					return DOBCheck(FiscalYearDate,Birthdate);
				} else {
					return DOBCheck(DateToday,Birthdate);
				}
			} catch (Exception Expt) {
				System.debug('Invalid Date');
				return false;
			}
		} else {
			return false;
		}
    }

	@TestVisible
	private static Boolean DOBCheck(date Marker_Date, date DOB) {
		if (Marker_Date.month() > DOB.month()) {
			//Birthday is greater by the month
			integer Age = Marker_Date.year() - DOB.year();
			System.debug('Current Year: ' + Marker_Date.year() + ' BOD Year: ' + DOB.year());
			System.debug('DOB Less then current month: ' + age);
			if (age >= minAge && age <= maxAge)
				return true;
			else
				return false;
		} else if (Marker_Date.month() == DOB.month() && Marker_Date.day() <= DOB.day()) {
			//Birthday is within the same month but still greater by the day
			integer Age = Marker_Date.year() - DOB.year();
			System.debug('Current Year: ' + Marker_Date.year() + ' BOD Year: ' + DOB.year());
			System.debug('DOB Less then or equal to current day: ' + age);
			if (age >= minAge && age <= maxAge)
				return true;
			else
				return false;
		} else {
			//Birthday has not occurred, lower the age by one year.
			integer Age = Marker_Date.year() - DOB.year() - 1;
			System.debug('Current Year: ' + Marker_Date.year() + ' BOD Year: ' + DOB.year());
			System.debug('DOB Greater then current month: ' + age);
			if (age >= minAge && age <= maxAge)
				return true;
			else
				return false;
		}
	}

    @RemoteAction
    global static Boolean isDuplicataEMail(String emailId, String contactId){
        System.debug('isDuplicataEmail - emailId: ' + emailId + ' ContactId:' + contactId);
        Boolean isDuplicate= false;
		List<Contact> dupEmailConList = new List<Contact>();
        if(emailId <> null && emailId <> ''){
			if(contactId == null || contactId == '') 
				dupEmailConList = [select Id,Name,Email FROM Contact Where Email=: emailId];
			else
				dupEmailConList = [select Id,Name,Email FROM Contact Where Email=: emailId AND Id!=: contactId];
            
            if(dupEmailConList.size()>0)
               isDuplicate = true;
        }
        System.debug('###isDuplicate: ' + isDuplicate);
        return isDuplicate;

    }    
    /*****************************************************************************/
}