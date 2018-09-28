/**
* Class Name: SetAsProspectServices
*  Description : 
* @author IBM 
*/
public class SetAsProspectServices{   
    ContactServices cs = new ContactServices();
    public Opportunity opp {get; set;}
    public List<Error_Log__c> errorLogs {get {if(errorLogs == null) errorLogs = new List<Error_Log__c>(); return errorLogs; } set;}
    public Boolean processComplete {get; set;} 
    public Lead leadConverted {get; set;} 
    public Contact contactfrmLead {get;set;}
    Account householdacct = new Account();
    
    public List<Account_Affiliation__c> existingBusinessAA {get{existingBusinessAA= new List<Account_Affiliation__c>(); return existingBusinessAA;}set;} 
    public List<Account_Affiliation__c> existingChapterAAs {get{existingChapterAAs= new List<Account_Affiliation__c>(); return existingChapterAAs;}set;}

    //Store converted lead here
    
    Public SetAsProspectServices(ApexPages.StandardController controller) {
        try {
			this.opp = [SELECT Id, AccountId, KGRenewal__Contact__c, Fiscal_Date_Start__c, KGRenewal__Contact__r.HouseholdID__c, Referred_by_Chapter__c, 
						KGRenewal__Contact__r.Membership_Status__c, KGRenewal__Contact__r.MailingCountry, KGRenewal__Contact__r.Address1_Type__c, 
						KGRenewal__Contact__r.Is_Spouse_Member__c, KGRenewal__Contact__r.Lifetime_Dues_Status__c, Created_in_Fiscal_Q4__c, 
						KGRenewal__Contact__r.Tier_Number__c
						FROM Opportunity 
						WHERE Id = :controller.getId() ];
		} catch (Exception excpt) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'A DML failure may have occurred. Contact your system Administrator with the following error message: ' + excpt.getMessage()));
		}
        processComplete = false;
        
        List<OpportunityContactRole> ocr = [SELECT Id, OpportunityId, ContactId FROM OpportunityContactRole WHERE OpportunityId =: this.opp.Id LIMIT 1];
        //Query for convertedLead here        
        //Store converted lead in property above
        if(!ocr.isEmpty() && ocr != null) {
			try {
				List<Lead> Leadlist = [SELECT id, Waiver_Status__c, Waiver_Decision_Date__c, Add_Waiver_Request_comments_or_cl__c, Age_Question_1__c, Age_Question_2__c, AnnualRevenue,
								Lead_Opportunity_Name__c, ConvertedContactId, President_Type__c, Business_Description__c, Spouse_Partner_Last_Name__c, 
								Industry, Sub_Category__c, Firm_Type__c, Business_Scope__c, Title__c, Title_Other__c, Website, All_Question_1__c, All_Question_2__c,
								Title_Question_1__c, Title_Question_2__c, QC_Country__c, Type_of_Waiver__c, Ent_Val__c, QC_Number_of_Employees_Opt_1__c, NumberOfEmployees, 
								Tot_Empl_Comp__c, Corp_Type__c, QC_Annual_Assets__c, QC_Annual_Fees__c, QC_Annual_Revenue__c, Spouse_Partner_Name__c, Spouse_Partner_Gender__c,
								Spouse_Partner_Email__c, Referred_by_Chapter__c, Number_of_Employees_Opp__c, 
								Street, City, State, Country, PostalCode, Address_Type__c //US6751 - QC address load.
								 FROM Lead 
								 WHERE ConvertedContactId = :ocr[0].ContactId];
				if(Leadlist.isEmpty()) {
					throw new CustomException('Converted Lead is missing. Be sure that the proper procedures have been followed in creating this New Member!');
				} else {
					leadConverted = Leadlist[0];
				}
           
				List<Contact> ContList = [SELECT id,name,AccountId,Active__c,RecordTypeID,Tier_Number__c,
								  Membership_Status__c,
								  Number_of_Employees__c,
								  Number_of_Employees_opt_2__c,
								  Total_Employee_Compensation__c,
								  Annual_Fees__c,
								  Annual_Assets__c,
								  Annual_Revenue__c,
								  Enterprise_Value__c,
								  Record_type_Name__c,
								  OwnerId
                              
								  FROM Contact 
								  WHERE id=:ocr[0].ContactId];
				if(ContList.isEmpty()) {
					throw new CustomException('The corresponding contact record is unavailable.  Be sure that the proper procedures have been followed in creating this Member!');
				} else {
					contactfrmLead = ContList[0];
				}
			} Catch (Exception excpt) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,excpt.getMessage()));
			}
        }
        else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No Opportunity Contact Role record exists for this opportunity.  Be sure that the proper procedures have been followed in creating this Member!'));
        }
        //getAllAAs(Opp.AccountId);
    }
    
	//Dummy function for a button on the page.
    public void saveOpp() {   
    }
    
	/* commented out this garbage //US6751
    //public void createRecords(Opportunity listOfOpps) {
        
    //}
    */

    //Method to get Business and Chapter Account Affiliation 
    public void getAllAAs(ID accID){
    
		ID recTypeIdBuis= Schema.SObjectType.Account_Affiliation__c.getRecordTypeInfosByName().get('Business').getRecordTypeID();
		ID recTypeIdChap= Schema.SObjectType.Account_Affiliation__c.getRecordTypeInfosByName().get('Chapter').getRecordTypeID(); 
		//ID recTypeCon= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeID(); 
    
        list<Account_Affiliation__c> allAAsFromQuery=new list<Account_Affiliation__c>();
        allAAsFromQuery = [SELECT Id, Account__c, RecordTypeId, IsActive__c, Is_Primary__c, Business_Role__c, Contact_Type__c, Contact__c, Description__c, 
                                Industry_Category_1__c, Industry_Sub_Category_1__c, Organization_Type__c, Scope_of_Business__c, Start_Date__c, Job_Title__c, 
                                Title_Other__c, Website__c
                            FROM Account_Affiliation__c
                            WHERE Contact_Type__c = 'Member'
                            AND Contact__c = :leadConverted.ConvertedContactId];
            //ID recTypeId= Schema.SObjectType.Account_Affiliation__c.getRecordTypeInfosByName().get('Business').getRecordTypeID(); 
            
            for(Account_Affiliation__c accAff : allAAsFromQuery)
            {
                /*if(accAff.Account__c == accID && 
                    accAff.RecordTypeId == recTypeIdBuis && 
                    accAff.IsActive__c == TRUE && 
                    accAff.Is_Primary__c == TRUE && 
                    accAff.Business_Role__c == leadConverted.President_Type__c)*/
                    if(accAff.Account__c == accId &&
                        accAff.RecordTypeId == recTypeIdBuis &&
                        accAff.IsActive__c == true  &&
                        accAff.Is_Primary__c == true &&
                        accAff.Business_Role__c == leadConverted.President_Type__c &&
                        accAff.Contact_Type__c == 'Member' &&
                        accAff.Contact__c == leadConverted.ConvertedContactId &&
                        accAff.Description__c == leadConverted.Business_Description__c && 
                        accAff.Industry_Category_1__c == leadConverted.Industry  &&
                        accAff.Industry_Sub_Category_1__c == leadConverted.Sub_Category__c  &&
                        accAff.Organization_Type__c == leadConverted.Firm_Type__c  &&
                        accAff.Scope_of_Business__c == leadConverted.Business_Scope__c  &&
                        accAff.Start_Date__c == date.today() &&
                        accAff.Job_Title__c == leadConverted.Title__c ) //&& accAff.Title_Other__c == Utility.SanitizeString(leadConverted.Title_Other__c) && accAff.Website__c == Utility.SanitizeString(leadConverted.Website)
                    {
                        existingBusinessAA.add(accAff); 
                    }
                    else if(accAff.RecordTypeId == recTypeIdChap &&
                            accAff.Account__c == leadConverted.Referred_by_Chapter__c &&
                            accAff.Contact_Type__c == 'Member' &&
                            accAff.Contact__c == contactfrmLead.Id &&          
                            accAff.IsActive__c == false &&
                            accAff.Is_Primary__c == true)
                    {
                       existingChapterAAs.add(accAff);
                    }
            }
    }

    public void flowControl() {
        flowControl(opp);
    }
    
    //Item 7110 - Flow control method
    public void flowControl(Opportunity Opty) {
        
        Savepoint sp = Database.setSavepoint();
        Account_Affiliation__c insertRecAccAff= new Account_Affiliation__c();
        List<sObject> listOfRecordsAA = new List<sObject>();
        List<sObject> listOfRecordsCon = new List<sObject>();
        List<sObject> recordsToInsert = new List<sObject>();
        List<sObject> recordsToUpdate = new List<sObject>();
        list<Contact> listContact4Sharing = new list<Contact>();
        listContact4Sharing.add(contactfrmLead);
        try {
            getAllAAs(Opty.AccountId);
            recordsToInsert.add(createBuisnessAAs(Opty.AccountId));   //Why is a Business AA record being created based off of the Referred_by_Chapter?
            recordsToInsert.addAll((List<SObject>)createChapterAA());       
            recordsToUpdate.add(updateContactRec(contactfrmLead));
            recordsToInsert.addAll((List<SObject>)createHouseholdAccount());
            
            if(!recordsToInsert.isEmpty())
                insertSObjects(recordsToInsert);
            
            if(!recordsToUpdate.isEmpty())
                updateSObjects(recordsToUpdate);
            
            recordsToUpdate.clear();
            recordsToInsert.clear();
            
            recordsToInsert.addAll((List<SObject>)createContactSpousePartner());
            recordsToInsert.addAll((List<SObject>)createWaiverException()); // 7118
            
            if(!recordsToInsert.isEmpty())
                insertSObjects(recordsToInsert);
            
            if(!recordsToUpdate.isEmpty())
                updateSObjects(recordsToUpdate);
            
            recordsToUpdate.clear();
            recordsToInsert.clear();
            
            //recordsToInsert.addAll((List<SObject>)createChapterAA());
            recordsToUpdate.addAll(updateOpportunityContactRole());
            
            if(!recordsToInsert.isEmpty())
                insertSObjects(recordsToInsert);
            
            if(!recordsToUpdate.isEmpty())
                updateSObjects(recordsToUpdate);
            
            cs.createContactSharesPB(listContact4Sharing);
            //System.assert(false, 'End of Set Products');
            if(errorLogs.isEmpty()) {
                ApexPages.Message successMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Set as prospect was successful!');
                ApexPages.addMessage(successMsg);
            }
            else {
                for(Error_Log__c errLg : errorLogs) {                    
                    ApexPages.Message failMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errLg.Error_String__c);
                    ApexPages.addMessage(failMsg);
                }
            }
            processComplete = true;
        }
        catch(Exception ex) {
            Database.rollback(sp);
            errorLogs.add(ErrorLogUtil.createErrorLogWithOppLookup('Set as Prospect', String.valueOf(opty.Id), ex.getMessage(), opty.Id));
            for(Error_Log__c errLg : errorLogs) {
                ApexPages.Message failMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errLg.Error_String__c);
                ApexPages.addMessage(failMsg);
            }
            processComplete = true;
        }
        processComplete = true;
        
    }
    
    public void insertSObjects(List<sObject> listOfRecords) {
        Schema.sObjectType opportunityType = Schema.Opportunity.getSObjectType();
        Boolean isOpportunity = listOfRecords[0].getSobjectType() == opportunityType;
        
        List<Database.SaveResult> saveResult = Database.insert(listOfRecords,true);
        for(Database.saveResult sr : saveResult) {
            if(!sr.isSuccess()){
                String errorMessages = '';
                for(Database.Error err : sr.getErrors()) {
                    if(isOpportunity) {
                        errorLogs.add(ErrorLogUtil.createErrorLogWithOppLookup('Set as Prospect', String.valueOf(sr.getId()), err.getMessage(), sr.getId()));
                    }
                    else {
                        errorLogs.add(ErrorLogUtil.createErrorLog('Set as Prospect', String.valueOf(sr.getId()), err.getMessage()));
                    }
                }
            }
        } 
        if(!errorLogs.isEmpty()) {
            ErrorLogUtil.insertErrorLogs(errorLogs);
        }
    }    
    
    public void updateSObjects(List<sObject> listOfRecords) {
        Schema.sObjectType opportunityType = Schema.Opportunity.getSObjectType();
        Boolean isOpportunity = listOfRecords[0].getSobjectType() == opportunityType;
        //List<id>LstId= new List<id>();
        List<Database.SaveResult> SaveResult = Database.update(listOfRecords,true);
        for(Database.SaveResult sr : SaveResult) {
            if(!sr.isSuccess()){
                String errorMessages = '';
                for(Database.Error err : sr.getErrors()) {
                    if(isOpportunity) {
                        errorLogs.add(ErrorLogUtil.createErrorLogWithOppLookup('Set as Prospect', String.valueOf(sr.getId()), err.getMessage(), sr.getId()));
                    }
                    else {
                        errorLogs.add(ErrorLogUtil.createErrorLog('Set as Prospect', String.valueOf(sr.getId()), err.getMessage()));
                    }
                }
            }
        } 
        
        
        if(!errorLogs.isEmpty()) {
            ErrorLogUtil.insertErrorLogs(errorLogs);
        }  
    }
    
    //Item 7111 - Creation of Account Affiliation
    public Account_Affiliation__c createBuisnessAAs(ID accId){
        //Check for exisitng AA
        ID recTypeId= Schema.SObjectType.Account_Affiliation__c.getRecordTypeInfosByName().get('Business').getRecordTypeID(); 
        Account_Affiliation__c CurrentAA = new Account_Affiliation__c();
                                                        
        if(existingBusinessAA.isEmpty()){
            // Create AA
            CurrentAA.Account__c = accId; 
            CurrentAA.RecordTypeId = recTypeId; 
            CurrentAA.IsActive__c = TRUE ;
            CurrentAA.Is_Primary__c = TRUE ;
            CurrentAA.Business_Role__c = leadConverted.President_Type__c ;
            CurrentAA.Contact_Type__c = 'Member' ;
            CurrentAA.Contact__c = leadConverted.ConvertedContactId;
            CurrentAA.Description__c = leadConverted.Business_Description__c; 
            CurrentAA.Industry_Category_1__c = leadConverted.Industry ;
            CurrentAA.Industry_Sub_Category_1__c = leadConverted.Sub_Category__c ;
            CurrentAA.Organization_Type__c = leadConverted.Firm_Type__c ;
            CurrentAA.Scope_of_Business__c = leadConverted.Business_Scope__c ;
            CurrentAA.Start_Date__c = date.today() ;
            CurrentAA.Job_Title__c = leadConverted.Title__c ;
            CurrentAA.Title_Other__c = leadConverted.Title_Other__c ;
            CurrentAA.Website__c = leadConverted.Website;
        }
        //Return AA  
        return CurrentAA;
    }    
    
    //Item 7112 - Method for updating the contacts
    public Contact updateContactRec(contact con)
    {
        ID recTypeId= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Prospect').getRecordTypeID(); 
        con.AccountId = opp.Referred_by_Chapter__c;
        con.Active__c = true;
        con.Membership_Status__c = 'Prospect';
        con.RecordTypeID = recTypeId;
        con.Tier_Number__c = '1';
        
        //Get Geographic Requirements
        List<Geographic_Requirements__c> lstGR =new List<Geographic_Requirements__c>();
        List<Geographic_Requirements__c> lstGRUS =new List<Geographic_Requirements__c>();
        boolean isExec=false;        
        Geographic_Requirements__c GeoReq =new Geographic_Requirements__c();
        
        String Country;
        if(leadConverted.Country!=null){
            Country = leadConverted.Country;
        }else{    
            Country = 'United States';
        }
        
        Set<String> grCountries = new Set<String>();
        grCountries.add(Country);
        grCountries.add('United States');
        
        lstGR = [SELECT id,Number_of_Employees_Opt_1__c,Number_of_Employees_Opt_2__c,Total_Employee_Compensation_Opt_2__c,
                 Annual_Fees__c,Annual_Assets__c,Annual_Revenue__c,Enterprise_Value__c, Country__c
                 FROM Geographic_Requirements__c 
                 WHERE Country__c IN :grCountries ];
                 
        Map<String, List<Geographic_Requirements__c>> countryToGR = GroupBy.Strings('Country__c', lstGr);
        System.debug('###countryToGR: ' + countryToGR);
        
        if(!lstGR.isEmpty())
        {
            isExec=true;
            GeoReq = lstGR[0];
            
            if(countryToGR.get(Country) != null) {
                GeoReq = countryToGR.get(Country)[0];
            }
            
            else {
                GeoReq = countryToGR.get('United States')[0];
            }
            
            System.debug('###GeoReq: ' + GeoReq);
        }                    
        
        if(isExec)
        {
            
            //Set QC requirements for CONTACT
            con.Number_of_Employees__c = GeoReq.Number_of_Employees_Opt_1__c;
            con.Number_of_Employees_opt_2__c = GeoReq.Number_of_Employees_Opt_2__c;
            con.Total_Employee_Compensation__c = GeoReq.Total_Employee_Compensation_Opt_2__c; 
            con.Annual_Fees__c = GeoReq.Annual_Fees__c;
            con.Annual_Assets__c = GeoReq.Annual_Assets__c;
            con.Annual_Revenue__c = GeoReq.Annual_Revenue__c;
            con.Enterprise_Value__c = GeoReq.Enterprise_Value__c;
            
            
        }
        if (leadConverted.Waiver_Status__c == 'Approved')
        {
            if (leadConverted.Type_of_Waiver__c == 'Enterprise')
            {
                con.Enterprise_Value__c = leadConverted.Ent_Val__c;
            }
            
            else if (leadConverted.Type_of_Waiver__c == 'Employee')
            {
                con.Number_of_Employees__c = leadConverted.NumberOfEmployees;
            }
            
            else if (leadConverted.Type_of_Waiver__c == 'Employee Compensation')
            {
                con.Total_Employee_Compensation__c = leadConverted.Tot_Empl_Comp__c;
            }                                                                
            
            else if (leadConverted.Type_of_Waiver__c == 'Volume')
            {
                if (leadConverted.Corp_Type__c == 'Financial Institution')
                {
                    con.Annual_Assets__c = leadConverted.AnnualRevenue;
                }
                
                else if (leadConverted.Corp_Type__c == 'Agency-type')
                {
                    con.Annual_Fees__c = leadConverted.AnnualRevenue;
                }
                else
                {
                    con.Annual_Revenue__c = leadConverted.AnnualRevenue;
                }        
            }
        }            
        return con;
    }
    
    //Item 7113- Creation of Household Account
    public List<Relationship__c> createHouseholdAccount(){
        ID recTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship').getRecordTypeID(); 
        //Check for Existing Household Accounts
        List<Account> householdAccs= new List<Account>([Select id,RecordTypeId,name from Account where RecordTypeId = :recTypeId and Name= : (contactfrmLead.Name + 'Household')]);
        List<Account>AccTobeCreated = new List<Account>();
        
        //Account acct = new Account();
        if(householdAccs.isEmpty()){
            houseHoldAcct.RecordTypeId= recTypeId;
            houseHoldAcct.Name= contactfrmLead.Name + 'Household';
            AccTobeCreated.add(houseHoldAcct);       
            insertSObjects(AccTobeCreated);
        }
        else {
            householdacct = householdAccs[0];
        }      
        //Create Relationship
        Relationship__c reln=new Relationship__c();
        List<Relationship__c> lstRel=new List<Relationship__c>();
        
        reln.Account__c = householdacct.Id;
        reln.Contact__c = contactfrmLead.Id;
        reln.Is_Active__c = TRUE;
        reln.Relationship_Type__c = 'Member';
        lstRel.add(reln);
        //insertSObjects(lstRel);
        return lstRel;
    }
    
    //Item 7114 - Create ContactSpouse/Partner
    public List<Relationship__c> createContactSpousePartner(){       
        Contact SpousePartner = new Contact();
        List<Contact>SPartner = new List<Contact>();
        ID recTypeId= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Spouse/Partner').getRecordTypeID();       
        Relationship__c relation =new Relationship__c();
        List<Relationship__c> ListRel=new List<Relationship__c>();
        
        if(leadConverted != null && (leadConverted.Spouse_Partner_Last_Name__c != null) && (leadConverted.Spouse_Partner_Email__c!= null)){
            SpousePartner.LastName = leadConverted.Spouse_Partner_Last_Name__c;
            SpousePartner.FirstName = leadConverted.Spouse_Partner_Name__c;
            SpousePartner.Gender__c = leadConverted.Spouse_Partner_Gender__c;
            SpousePartner.Email = leadConverted.Spouse_Partner_Email__c;
            SpousePartner.AccountId = opp.Referred_by_Chapter__c;
            SpousePartner.Active__c = TRUE ;
            SpousePartner.RecordTypeId = recTypeId ;
            //Adding SpousePartner contact to list
            SPartner.add(SpousePartner);
            insertSObjects(SPartner);    
            //Create Household Relationship     
            if(SpousePartner != null){
            relation.Account__c = houseHoldAcct.Id;
            relation.Contact__c = SpousePartner.Id;
            relation.Is_Active__c = True;
            relation.Relationship_Type__c = 'Spouse/Partner';
            //Adding record to list 
            ListRel.add(relation);
            }
        }  
        return listRel;
        //insertSObjects(ListRel);
    }
    
    //Item 7115- Create Chapter AA(For member)
    public List<Account_Affiliation__c> createChapterAA(){
        
        ID recTypeId= Schema.SObjectType.Account_Affiliation__c.getRecordTypeInfosByName().get('Chapter').getRecordTypeID(); 
        ID recTypeCon= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeID(); 
        
        //Check for exisitng chapter AA
        Account_Affiliation__c ChapterAA = new Account_Affiliation__c();
        List<Account_Affiliation__c> chapAccAff = new List<Account_Affiliation__c>();/*=[SELECT id FROM Account_Affiliation__c where RecordType.Id = :recTypeId
                                                  and Account__c =:Opp.AccountId
                                                  and Contact_Type__c = 'Member'
                                                  and Contact__c = :leadConverted.ConvertedContactId ];  */                                                                                                                   
        
        if(existingChapterAAs.isEmpty()/* && (contactfrmLead.RecordTypeId == recTypeCon)*/){
            //Create Chapter AA
            ChapterAA.RecordTypeId = recTypeId;
            ChapterAA.Account__c = leadConverted.Referred_by_Chapter__c;
            ChapterAA.Contact_Type__c = 'Member';
            ChapterAA.Contact__c = contactfrmLead.Id;          
            ChapterAA.IsActive__c = false;
            ChapterAA.Is_Primary__c = true;    
            //Adding to list
            chapAccAff.add(ChapterAA);
            //return chapAccAff;
            //insertSObjects(chapAccAff);
        }  
        
        return chapAccAff;
    }                             
    
    //Item 7116 - Update Opportunity Contact
    public List<SObject> updateOpportunityContactRole(){
        List<SObject> sObjectsToUpdate = new List<SObject>();
        
        ID recTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Prospect').getRecordTypeID();
        if(contactfrmLead.Id != null){
            List<OpportunityContactRole> oppConrole= [Select id,Role from OpportunityContactRole where ContactId =:contactfrmLead.Id AND OpportunityId = :opp.Id limit 1];        
            oppConrole[0].Role = 'Business User';
            sObjectsToUpdate.addAll((List<SObject>)oppConrole);
        } 
        
        //Update Opportunity
        List<Opportunity>OpptoUpdate = new List<Opportunity>();
        opp.Chapter_Acceptance_Status__c = 'Approved';
        opp.AccountId = opp.Referred_by_Chapter__c;
        opp.RecordTypeId = recTypeId;
        opp.Fiscal_Date_Start__c = FiscalDateUtility.startOfCurrentFiscal;
        opp.KGRenewal__BillingFrequency__c = 'Periodic';
        opp.KGRenewal__BillingPeriod__c = 999;
        opp.KGRenewal__Contact__c = contactfrmLead.Id;
        opp.Opportunity_Type__c = 'Prospect';
        opp.Name = leadConverted.Lead_Opportunity_Name__c;
        opp.StageName = 'New';
		//6751 - Push of Lead's Business address data to the opportunity QC address
		if(leadConverted.Address_Type__c.containsIgnoreCase('business')) {
			opp.QC_StreetAddress1__c = Utility.SanitizeString(leadConverted.Street);
			opp.QC_City__c = Utility.SanitizeString(leadConverted.City);
			if(Utility.SanitizeString(leadConverted.state) != '') {
				opp.QC_State__c = Utility.SanitizeString(leadConverted.State);
				opp.QC_StateCode__c = ContactServices.getStateCodeValue(opp.QC_State__c);
			}
			if(Utility.SanitizeString(leadConverted.Country) != '') {
				opp.QC_Country__c = Utility.SanitizeString(leadConverted.Country);
				opp.QC_CountryCode__c = ContactServices.getCountryCodeValue(opp.QC_Country__c);
			}
			opp.QC_PostalCode__c = Utility.SanitizeString(leadConverted.PostalCode);
		}
        OpptoUpdate.add(opp); 
        sObjectsToUpdate.addAll((List<SObject>)OpptoUpdate);
        return sObjectsToUpdate;  
    } 
    
    //Item 7118 - Create Waiver Exception 
    public list<Exception__c> createWaiverException()
    {
        list<Exception__c>lstException = new list<Exception__c>();
        if(leadConverted.Type_of_Waiver__c != null && leadConverted.Type_of_Waiver__c != '' && leadConverted.Waiver_Status__c =='Approved')
        {
            Exception__c recExcep=new Exception__c() ;
            recExcep.Account__c = leadConverted.Referred_by_Chapter__c;//Reference Chapter Account Id
            recExcep.Contact__c = contactfrmLead.Id;
            recExcep.Opportunity__c = opp.Id;
            recExcep.Exception_Category__c = 'Waiver';
            recExcep.Type_of_Waiver__c = leadConverted.Type_of_Waiver__c; //(Lead)
            recExcep.Status__c = 'Approved';
            recExcep.Decision_Date__c = leadConverted.Waiver_Decision_Date__c;
            recExcep.Add_Waiver_Request_comments_or_cl__c = leadConverted.Add_Waiver_Request_comments_or_cl__c;
            recExcep.Age_Question_1__c = leadConverted.Age_Question_1__c;// (Lead)
            recExcep.Age_Question_2__c = leadConverted.Age_Question_2__c;// (Lead)
            recExcep.All_Question_1__c = leadConverted.All_Question_1__c;// (Lead)
            recExcep.All_Question_2__c = leadConverted.All_Question_2__c;// (Lead)
            recExcep.Title_Question_1__c = leadConverted.Title_Question_1__c;// (Lead)
            recExcep.Title_Question_2__c = leadConverted.Title_Question_2__c;// (Lead)
            lstException.add(recExcep);
        }
        return lstException;
    }
    
}