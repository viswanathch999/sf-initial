public with sharing class M2MXCaseSearchCaseContExt {
    
    public String caseId{get;set;}
    public Integer noOfDays{get;set;}
    public String selectedTemplate{get;set;}
    public String searchString{get;set;}
    public Boolean renderTable{get;set;}
    public Boolean pageMessage{get;set;}
    public M2MX_Skillsets__c skillSetRecord{get;set;}
    public List<SearchResult> searchResultsList{get;set;}
    
    public static final Integer MAX_DAY_SINCE_LAST_MODIFIED = 30;
    public static final String CONST_TASK = 'Task';
    public static final String CONST_M2MX = 'M2MX';
    public static final String CONST_CATEGORY = 'Category__c';
    public static final String CONST_SUB_CATEGORY = 'Sub_Category__c';
    public static final String CONST_EXPERTISE = 'Expertise__c';
    public static final String CONST_CONTACT = 'Contact';
    public static final String CONST_CONTACT_RELATION = CONST_CONTACT+ '__c';
    public static final String CONST_INTEREST = 'Interest__c';
    public static final String CONST_M2MX_SKILLSETS = 'M2MX_Skillsets__c';
    public static final String CONST_SUBJECT = 'M2MX Request';
    public static final String CONST_PRIORITY = 'Normal';
    public static final String CONST_STATUS_OPEN = 'Open';
    public static final String CONST_STATUS_COMPLETED = 'Completed';
    public static final String CONST_PRIVATE_TEMPLATE = 'Private';
    public static final String CONST_PRIVATE_TEMPLATE_NAME = 'Request_Email_Anonymous_do_not_include_Requestor_Information';
    public static final String CONST_PUBLIC_TEMPLATE = 'Public';
    public static final String CONST_PUBLIC_TEMPLATE_NAME = 'Request_for_Assistance_Email_with_Requestor_Information';
    public static final String CONST_CONTACT_FIELDS_TO_QUERY = 'Id, Email, Name, MailingCity, MailingCountry, Gender__c, Date_Last_M2MX_Request_Email__c';
    public static final String CONST_CONTACT_REL_FIELDS_TO_QUERY = 'Contact__r.Id, Contact__r.Email, Contact__r.Name, Contact__r.MailingCity, Contact__r.MailingCountry, Contact__r.Gender__c, Contact__r.Date_Last_M2MX_Request_Email__c';
   
    public M2MXCaseSearchCaseContExt(ApexPages.StandardController controller){
    
        caseId = controller.getId();
        searchString = '';
        selectedTemplate = '';
        pageMessage = false;
        renderTable = false;  
        skillSetRecord = new M2MX_Skillsets__c();
    }
    public PageReference saveSkillset(){
        //skillSetRecord.Contact__c = ;/Confirm with Ross
        try{
            insert skillSetRecord;
        }
        catch(DmlException dEx){
                ApexPages.addmessages(dEx);
            return null;
        }    
        return new PageReference('/'+skillSetRecord.id);
    }
    public PageReference getSearchResults(){
       /*renderTable = true;
       String sosl;
       searchResultsList = new List<SearchResult>();
       String objectListWithFields = '';
       List<String> lstObjects = new List<String>();
       List<Schema.DescribeSObjectResult> lstDescribeSObjectResult;
       List<List<SObject>> searchList;
       Date d = System.Today() - noOfDays;
       String whereClauseForContact =  ' WHERE Date_Last_M2MX_Request_Email__c = null OR Date_Last_M2MX_Request_Email__c <= :d';
       String whereClauseForOthers =  ' WHERE Contact__r.Date_Last_M2MX_Request_Email__c = null OR Contact__r.Date_Last_M2MX_Request_Email__c <= :d';
       
       List<M2MX_Skillset_Search_Objects__c> lstCS = M2MX_Skillset_Search_Objects__c.getAll().values(); // List Custom setting containing the list of object to search in.
       
        if(!lstCS.isEmpty()){
            for(M2MX_Skillset_Search_Objects__c cs : lstCS){
                    if(cs.API_Name__c.equals(CONST_CONTACT)){
                        objectListWithFields += cs.API_Name__c +'(' + CONST_CONTACT_FIELDS_TO_QUERY + whereClauseForContact  + '),';
                    } else if(cs.API_Name__c.equals(CONST_INTEREST)){
                        objectListWithFields += cs.API_Name__c +'(' + CONST_CATEGORY + ',' + CONST_CONTACT_REL_FIELDS_TO_QUERY + whereClauseForOthers + '), ';
                    } else if(cs.API_Name__c.equals(CONST_M2MX_SKILLSETS)){
                        objectListWithFields += cs.API_Name__c +'(' + CONST_CATEGORY + ',' + CONST_SUB_CATEGORY + ',' + CONST_EXPERTISE + ','  + CONST_CONTACT_REL_FIELDS_TO_QUERY + whereClauseForOthers + '), ';
                    } else{
                        objectListWithFields += cs.API_Name__c +'(' + CONST_CONTACT_REL_FIELDS_TO_QUERY + whereClauseForOthers + '), ';
                    }
                    lstObjects.add(cs.API_Name__c);
            }        
            
            lstDescribeSObjectResult = Schema.describeSObjects(lstObjects);
            objectListWithFields = objectListWithFields.substringBeforeLast(','); 
            if(searchString.equals('') || searchString.length() < 2 || searchString == null){
                pageMessage = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Search_String_Blank_Message));
                return null;
            } else{
                sosl = 'FIND \'' +searchString + '\' IN ALL FIELDS RETURNING ' + objectListWithFields;  
                system.debug('SOSL##' + sosl);
                searchList =  Search.query(sosl);
            }
        }
       List<Contact> lstContact = new List<Contact>();
       if(searchList != null && !searchList.isEmpty()){
           for(Integer i =0; i < searchList.size(); i++){
                    List<SObject> lstSObj;
                    String objName = lstCS.get(i).API_Name__c;
                    if(!lstDescribeSObjectResult.isEmpty()){
                        for(Schema.DescribeSObjectResult dSOR : lstDescribeSObjectResult){
                            if(dSOR.getName().equals(objName)){
                                lstSObj = searchList.get(i);
                                if(objName.equalsIgnoreCase(CONST_CONTACT)){
                                    buildSearchResults(lstContact,objName );
                                } else{
                                    buildSearchResults(lstSObj,objName );
                                }
                            }
                        }                       
                    }                                       
           }
       }*/
                     
       return null;
        
    }
    
    private void buildSearchResults(List<SObject> lstSObject, String objectAPIName){
        /*Date d = System.Today() - noOfDays;
        if(!lstSObject.isEmpty()){
            if(objectAPIName.equals(CONST_CONTACT)){
                for(Contact c : (List<Contact>)lstSObject){
                    searchResultsList.add(new SearchResult(c.Id, c.Email,c.Name,c.MailingCity, c.MailingCountry,
                                            c.Gender__c,null,null,null,objectAPIName,c.Date_Last_M2MX_Request_Email__c));
                }
                
            } else if(objectAPIName.equals(CONST_INTEREST)){
                for(Interest__c c : (List<Interest__c>)lstSObject){
                    searchResultsList.add(new SearchResult(c.Contact__r.Id, c.Contact__r.Email,c.Contact__r.Name,c.Contact__r.MailingCity, c.Contact__r.MailingCountry,
                                            c.Contact__r.Gender__c,c.Category__c,null,null,objectAPIName,c.Contact__r.Date_Last_M2MX_Request_Email__c));
                }
                    
            } else if(objectAPIName.equals(CONST_M2MX_SKILLSETS)){
                for(M2MX_Skillsets__c c : (List<M2MX_Skillsets__c>)lstSObject){
                    searchResultsList.add(new SearchResult(c.Contact__r.Id, c.Contact__r.Email,c.Contact__r.Name,c.Contact__r.MailingCity, c.Contact__r.MailingCountry,
                                            c.Contact__r.Gender__c,c.Category__c,c.Sub_Category__c,c.Expertise__c,objectAPIName,c.Contact__r.Date_Last_M2MX_Request_Email__c)); 
                }
            } else {
                for(SObject c : (List<SObject>)lstSObject){
                    searchResultsList.add(new SearchResult((Id)c.getSObject('Contact__r').get('Id'),(String)c.getSObject('Contact__r').get('Email'),
                                            (String)c.getSObject('Contact__r').get('Name'),(String)c.getSObject('Contact__r').get('MailingCity'), 
                                            (String)c.getSObject('Contact__r').get('MailingCountry'),(String)c.getSObject('Contact__r').get('Gender__c')
                                            ,null,null,null,objectAPIName,(Date)c.getSObject('Contact__r').get('Date_Last_M2MX_Request_Email__c')));    
                }
            }
        }*/
    }
       
    public PageReference sendEmail() {
        
        /*List<SearchResult> selectedRecords = new List<SearchResult>();
        String templateName = (selectedTemplate.equalsIgnoreCase(CONST_PRIVATE_TEMPLATE))?CONST_PRIVATE_TEMPLATE_NAME:CONST_PUBLIC_TEMPLATE_NAME;        
        EmailTemplate templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :templateName];
                
        for(SearchResult result : searchResultsList){
            if(result.isChecked){
                selectedRecords.add(result);
            }
                
        }
                
        if(selectedRecords.size() > 0){
            for(SearchResult sr : selectedRecords){
                if (sr.email != null ) {
    
                  EmailUtil eUtil = EmailUtil.to(new List<String>{sr.email});
                  eUtil.templateId(templateId.Id);
                  eUtil.targetObjectId(sr.contactId);
                  eUtil.stashForBulk();                  
               }
            }
            EmailUtil.sendBulkEmail();
        
        // create task on Contact and Case records when mails are sent
        createActivities(selectedRecords); 
        }*/
        
        return null;
    }
    
    @TestVisible
    private void createActivities(List<SearchResult> selectedRecords){
        /*final String M2MX_TASK_RECORDTYPEID = RecordTypeServices.getRecordTypeByName(CONST_M2MX,CONST_TASK).Id; 
        final TaskDAO oTaskDAO = new TaskDAO(DAOStrategyType.DatabaseDAOStrategy);
        List<Task> taskList = new List<Task>();
        for(SearchResult sr : selectedRecords){
            //Create one task each on related Contact and Case record
            Task taskOnContact =  new Task();
            taskOnContact.WhoId = sr.contactId;
            taskOnContact.Status = CONST_STATUS_COMPLETED;
            taskOnContact.Subject = CONST_SUBJECT;
            taskOnContact.Priority = CONST_PRIORITY;
            taskOnContact.recordTypeId = M2MX_TASK_RECORDTYPEID;
            taskList.add(taskOnContact);
            
            Task taskOnCase = new Task();
            taskOnCase.WhatId = caseId;
            taskOnCase.Status = CONST_STATUS_OPEN;  //Since the case is open
            taskOnCase.Subject = CONST_SUBJECT;
            taskOnCase.Priority = CONST_PRIORITY;
            taskOnCase.recordTypeId = M2MX_TASK_RECORDTYPEID;
            taskList.add(taskOnCase);
        
        }
        
        if(taskList.size() > 0){
            List<TaskModel> lstTaskModels = new List<TaskModel>();
            for(Task task : taskList){
                lstTaskModels.add(new TaskModel(task));
            }
            
            final List<Schema.SObjectField> taskFields = new List<Schema.SObjectField> {Task.WhoId, Task.WhatId, Task.Status, Task.Subject, Task.Priority, Task.recordTypeId};
            
             
            Database.saveResult[] srList = oTaskDAO.create(lstTaskModels,taskFields);
            for(Database.saveResult sr : srList){
                if(!sr.IsSuccess()){
                    for(Database.Error err : sr.getErrors()){
                        System.debug('Error occurred in Fields : ' + err.getFields());
                        System.debug('Error Message : ' + err.getMessage());
                        System.debug('Status Code : ' + err.getStatusCode());
                    }
                }            
            }
        }*/
    
    }
        
    public List<SelectOption> getLastModifiedByDays(){
        List<SelectOption> options = new List<SelectOption>();
        for(Integer i = 0; i < MAX_DAY_SINCE_LAST_MODIFIED; i++){
            String iStr = String.valueOf(i);
            options.add(new SelectOption(iStr ,iStr) );
        }
        
        return options;
    }
        
    public List<SelectOption> getTemplates(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(CONST_PRIVATE_TEMPLATE,CONST_PRIVATE_TEMPLATE));
        options.add(new SelectOption(CONST_PUBLIC_TEMPLATE,CONST_PUBLIC_TEMPLATE) );
        
        return options;
    } 
        
    public class SearchResult{
        public Id contactId{get;set;}
        public String email{get;set;}
        public String fullName{get;set;}
        public String city{get;set;}
        public String country{get;set;}
        public String gender{get;set;}
        public String category{get;set;}
        public String subCategory{get;set;}
        public String expertise{get;set;}
        public String objectName{get;set;}
        public Date lastContactedDate{get;set;}
        public Boolean isChecked{get;set;}
        
        public SearchResult(Id cId, String cEmail, String cfullName,String cCity,String cCountry,String cGender,
                              String cCategory,String cSubCategory, String cExpertise, String cObjectName, Date lastContacted){
            this.contactId = cId;
            this.email = cEmail;
            this.fullName = cfullName;
            this.city = cCity;
            this.country = cCountry;
            this.gender = cGender;
            this.category = cCategory;
            this.subCategory = cSubCategory;
            this.expertise = cExpertise;
            this.lastContactedDate = lastContacted;
            this.objectName = cObjectName;
            this.isChecked = false;
        }    
    }

}