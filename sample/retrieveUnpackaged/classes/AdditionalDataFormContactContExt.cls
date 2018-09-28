/*
* 
* AdditionalDataFormContactContExt is a extension class for additional data form. 
* This class will cater addition of spouse, child setting up business network. 
*
* @author Shri K
*/

public with sharing class AdditionalDataFormContactContExt {
    
    static final String CONST_CONTACT = 'Contact';
    static final String CONST_SPOUSE = 'Spouse_Partner';
    static final String CONST_CHILD = 'Child';
    public static FINAL String MEMBER ='Member';
    public Boolean isEditable{ get;set;}
    public Boolean isEditableSchool{ get;set;}
    
    
    public List<Contact> lstSpouse{get{ System.debug('The spouse: '+ lstSpouse);
                                       return lstSpouse;
                                      } private set;}
    public List<Contact> lstChild{get; private set;}
    public Account_Affiliation__c oAccountAffiliation{get; private set;}
    public boolean bRelationshipPresent{get; private set;}
    public boolean bDisableSave{get; private set;}
    
    public Contact oContact{get;set;}
    
    Account oHouseHoldAccount;
    Relationship__c oRelationship;
    Id spouseRecordTypeId{
        get{
            if(spouseRecordTypeId == null)
            {
                spouseRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_SPOUSE, CONST_CONTACT).Id;
            }
            return spouseRecordTypeId;         
        }set;}
    Id childRecordTypeId{
        get{
            if(childRecordTypeId == null)
            {
                childRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_CHILD, CONST_CONTACT).Id;
            }
            return childRecordTypeId;
        }set;}
    String sLastName;
    
    public AdditionalDataFormContactContExt(Apexpages.StandardController oStandardController)
    {
        isEditable = false;
        isEditableSchool = false;
        lstSpouse = new List<Contact>();
        lstChild = new List<Contact>();
        if(!Test.isRunningTest()){ // Added on 20 Feb 2016
            List<String> addlFields = new List<String>{'LastName', 'AccountId'};
                for(Schema.FieldSetMember field : SObjectType.Contact.FieldSets.School.getFields()) {
                    addlFields.add(field.getFieldPath());
                }
            oStandardController.addFields(addlFields);
        }
        oContact = (Contact)oStandardController.getRecord();
        if(String.isEmpty(oContact.Id))
        {
            throw new CustomException(Label.Id_Not_Present);
        }
        
        oAccountAffiliation = new Account_Affiliation__c(Contact__c = oContact.Id);
        bDisableSave = false;
        populateExistingSpouseAndChildrens();       
    }
    public void populateExistingSpouseAndChildrens(){
        if(oRelationship == null)
        {
            try{
                oRelationship = [SELECT Id, Account__c FROM Relationship__c WHERE Contact__c = :oContact.Id AND Is_Active__c = true Limit 1]; 
                bRelationshipPresent = true;
            }catch(Exception oDmlException){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_Relationship_Record_Found));
                bRelationshipPresent = false;
            }
        }
        Set<String> spouseAndChildrenFields = new Set<String>(); 
        for(Schema.FieldSetMember field : SObjectType.Contact.FieldSets.Spouse.getFields()) {
            spouseAndChildrenFields.add(field.getFieldPath());
        }
        for(Schema.FieldSetMember field : SObjectType.Contact.FieldSets.Child.getFields()) {
            spouseAndChildrenFields.add(field.getFieldPath());
        }
        spouseAndChildrenFields.add('recordtypeid');
        spouseAndChildrenFields.add('Birthdate');
        lstSpouse = new List<Contact>();
        lstChild = new List<Contact>();
        
        if(oContact.AccountId!=null){
            List<Contact> spouseAndChildrenContacts = new List<Contact>(); 
            spouseAndChildrenContacts = Database.query('Select '+ String.join(new List<String>(spouseAndChildrenFields), ',')+
                                                       ' from Contact where accountid = \''+ oRelationship.Account__c+'\''+
                                                       ' and id != \''+ oContact.Id+'\'');
            if(!spouseAndChildrenContacts.isEmpty()){
                for(Contact aCon: spouseAndChildrenContacts){
                    System.debug(aCon);
                    if(aCon.recordTypeId == spouseRecordTypeId)
                        lstSpouse.add(aCon);
                    else if(aCon.recordTypeId == childRecordTypeId)
                        lstChild.add(aCon);
                }
            }
        }
        
    }
    
    public void calcDisabledFlag(){
        bDisableSave = false;
        if(lstSpouse != null){
            for(Contact oSpouse: lstSpouse){
                for(Schema.FieldSetMember field : SObjectType.Contact.FieldSets.Spouse.getFields())
                {
                    if(oSpouse.get(field.getFieldPath()) == null) 
                        bDisableSave = true;
                }
                if(oSpouse.birthDate== null)
                    bDisableSave = true;   
            }
        }
        system.debug('diable -'+bDisableSave + 'spouses'+ lstSpouse); 
        if(lstChild!=null){
            for(Contact oChild: lstChild){
                for(Schema.FieldSetMember field : SObjectType.Contact.FieldSets.Child.getFields())
                {
                    if(oChild.get(field.getFieldPath()) == null) 
                        bDisableSave = true;
                }
                if(oChild.birthDate== null)
                    bDisableSave = true;            
            }
        }
        
        system.debug('diable -'+bDisableSave + 'child'+ lstChild);
    }
    public String businessNetworkDocLink { get 
    {
        if(businessNetworkDocLink == null){
            Id pdfId = [Select Id From Document Where Name = 'Business Networks Document' Limit 1].Id;
            businessNetworkDocLink = '/servlet/servlet.FileDownload?file='+ pdfId;
        }
        return businessNetworkDocLink;
    } 
                                          set; 
                                         }
    
    /*
* Method to add spouse to the contact.
* By default spouse record type id and parent contact id are assigned to the new instance.
*/
    public void addSpouse()
    {
        if(lstSpouse == null)
        {
            lstSpouse = new List<Contact>();
        }else if(lstSpouse.size() >= 1)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Only one spouse/partner can be added'));
            return; 
        }
        
        
        
        lstSpouse.add(createContact(oContact.AccountId, spouseRecordTypeId, oContact.LastName));
        bDisableSave = true;
    }
    
    /*
* Method to add child to the contact.
* By default child record type id and parent contact id are assigned to the new instance.
*/
    public void addChild()
    {
        if(lstChild == null)
        {
            lstChild = new List<Contact>();
        }
        lstChild.add(createContact(oContact.AccountId, childRecordTypeId, oContact.LastName));
        bDisableSave = true;
    }
    
    /*
Method to create contact record with relationship type.
*/
    private Contact createContact(Id accountId, Id recordType, String sLastName)
    {
        return new Contact(AccountId = accountId, RecordTypeId = recordType, LastName = sLastName);
    }
    
    /*
*  Method checks for the relationship record associated with contact. 
*  If relationship record is not present then error message is thrown to the page.

public void getRelationshipForMember()
{
if(oRelationship == null)
{
try{
oRelationship = [SELECT Id, Account__c FROM Relationship__c WHERE Contact__c = :oContact.Id Limit 1]; 
bRelationshipPresent = true;
}catch(Exception oDmlException){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_Relationship_Record_Found));
bRelationshipPresent = false;
}
}
}
*/
    public PageReference updateContact(){
        try{
            update oContact;    
        }catch(Exception oDmlException){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getMessage()));
            return null;
        }
        return null;
    }
    /*
* Method to save the updated contact details, spouse and childs.
* Method is adding new contacts for spouse and child to the system.    
*/
    public PageReference saveSpouseAndChild()
    {
        updateContact();
        Boolean isSchoolNamePop = false;
        Boolean areAllOtherFieldsPop = true;
        Account school = new Account();
        Boolean createSchoolAff = false;
        if(oContact.school__c != null){
            school.id = oContact.school__c;
            createSchoolAff= true;
        }
        else{
            for(Schema.FieldSetMember field : SObjectType.Contact.FieldSets.School.getFields()){
                String fieldname = field.getFieldPath();
                System.debug('Fieldset fields'+ fieldname);
                if(fieldName =='school_name__c'){
                    if(oContact.get(fieldName) != null)
                        isSchoolNamePop = true;
                }
                else if(oContact.get(fieldName) == null){
                    areAllOtherFieldsPop= false;
                    
                }
            }
            
            if(isSchoolNamePop){
                if(!areAllOtherFieldsPop){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'If School Name is populated then please fill up other school fields too');//Same old drama 
                    ApexPages.addMessage(myMsg);
                    return null;
                }
                else{
                    //Create account
                    RecordType schoolRecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName = 'School'];
                    school.Name = oContact.school_name__c;
                    school.BillingCity = oContact.School_City__c;
                    school.BillingState = oContact.School_State__c;
                    school.BillingCountry = oContact.School_Country__c;
                    school.RecordTypeId = schoolRecType.Id;
                    school.Type = oContact.School_Type__c;
                    insert school;
                    createSchoolAff = true;
                }
            }
        }
        
        //create school affiliation
        if(createSchoolAff){
            RecordType schoolRecType = [Select Id From RecordType  Where SobjectType = 'Account_Affiliation__c' and DeveloperName = 'School'];
            try{
                insert new Account_Affiliation__c(account__c = school.id, contact__c = oContact.id, Organization_Type__c = oContact.School_Type__c, Degree_Type__c = oContact.Degree_Type__c,
                                                  Graduation_Year__c = oContact.Graduation_Year__c, Field_of_Study__c = oContact.Field_of_Study__c, Start_Date__c = System.today(), RecordTypeId = schoolRecType.Id);
            }
            catch(DmlException dex){
                ApexPages.addMessages(dex);
            }
        }
        for(Contact spouse: lstSpouse){
            if(spouse.id==null && !(String.isBlank(spouse.firstname) || String.isBlank(spouse.lastname))){
                if(String.isBlank(spouse.firstname) || 
                   String.isBlank(spouse.lastname)  || 
                   String.isBlank(spouse.Email) || 
                   String.isBlank(spouse.Gender__c) || 
                   spouse.birthdate == null){
                       ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, Label.MandatorySpouseFields));
                       return null;
                   }
            }
        }
        List<Contact> lstSpouseAndChild = new List<Contact>();
        if(lstChild != null)
        {
            lstSpouseAndChild.addAll(lstChild);
        }
        
        if(lstSpouse != null)
        {
            lstSpouseAndChild.addAll(lstSpouse);
        }
        
        try{
            system.debug('lstSpouseAndChild '+lstSpouseAndChild);
            upsert lstSpouseAndChild;   
        }catch(Exception oDmlException){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getMessage()));
        }
        
        if(!lstSpouseAndChild.isEmpty() && oRelationship != null && oRelationship.Account__c != null)
        {
            List<Relationship__c> lstrelationship = createRelationship(lstSpouseAndChild, oRelationship.Account__c);
            if(lstrelationship != null)
                
            {
                try{
                    insert lstrelationship;
                }catch(Exception oDmlException){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getMessage()));
                    return null;
                }
            }
        }
        
        try{
            /* This is new memeber and combination of contact and Account will not be present in system*/
            if(oRelationship != null && oRelationship.Account__c != null)
                oAccountAffiliation.Account__c = oRelationship.Account__c;
            oAccountAffiliation.Start_Date__c = system.today();
            //oAccountAffiliation.RecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Relationship', 'Account_Affiliation__c').Id;
            //insert oAccountAffiliation;
        }catch(Exception oDmlException){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getMessage()));
            return null;
        }
        
        // set Prospect's opportunity stageName to 'Applied'
        this.updateOpportunity();
        
        return new PageReference('/apex/ThankYouForm');
    }
    
    private void updateOpportunity() {
        List<OpportunityContactRole> prospectOpp = [Select OpportunityId 
                                                    From OpportunityContactRole 
                                                    Where ContactId = :oContact.Id
                                                    And role='Business User' 
                                                    And Contact.RecordType.DeveloperName = :MEMBER  
                                                    And Opportunity.RecordType.DeveloperName = 'Prospect'
                                                    Limit 1]; 
        if(!prospectOpp.isEmpty()) {
            Opportunity oppToUpdate = new Opportunity(Id=prospectOpp.get(0).OpportunityId, StageName='Applied');
            update oppToUpdate;
        }
    }
    
    /*
* Method to remove selected child from the page.
*/
    public void removeChild()
    {
        String sRowNumber = Utility.getPageParameterValue('rowNumber');
        
        lstChild.remove(Integer.valueOf(sRowNumber));   
        
        if(lstChild.isEmpty())
        {
            lstChild = null;    
        }
    }
    
    /*
* Method to remove selected spouse from the page.
*/    
    public void removeSpouse()
    {
        String sRowNumber = Utility.getPageParameterValue('rowNumber');
        
        lstSpouse.remove(Integer.valueOf(sRowNumber));  
        
        if(lstSpouse.isEmpty())
        {
            lstSpouse = null;   
        }
    }
    
    private List<Relationship__c> createRelationship(List<Contact> lstSpouseAndChild, Id householdAccountId)
    {
        List<Relationship__c> lstRelationship = new List<Relationship__c>();
        String sRelationshipType; 
        Relationship__c oRelationship;
        for(Contact oContact: lstSpouseAndChild)
        {
            sRelationshipType = oContact.RecordTypeId == spouseRecordTypeId ? RelationshipServices.CONST_SPOUSE : CONST_CHILD;
            oRelationship = Utility.createRelationship(oContact.Id, householdAccountId, sRelationshipType);
            if(oRelationship != null)
            {
                if(oRelationship.Relationship_Type__c == CONST_SPOUSE)oRelationship.Is_Active__c = true;
                lstRelationship.add(oRelationship);
            }
        }
        return lstRelationship;
    }
    public void doToggleEditMode() {
        isEditable = !isEditable;
    }
    public void doToggleEditModeSchool() {
        isEditableSchool = !isEditableSchool;
    }
}