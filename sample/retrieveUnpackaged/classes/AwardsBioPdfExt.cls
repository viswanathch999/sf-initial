public without sharing class AwardsBioPdfExt {
    public Contact cont{get; set;}
    public List<RelatedListWrapper> relatedListWrappersList {get; set;}
    public List<RelatedListWrapper> meetingListWrappersList {get; set;}
    public list<Relationship__c> householdFamilyMembers {get; set;}
    public AwardsBioPdfExt(ApexPages.StandardController stdController) {
        Map<Id, Id> memberContactToHouseholdAccId = new Map<Id,Id>();
        List<sObject> chapterContactPositions = new List<sObject>();
        List<sObject> committeeContactPositions = new List<sObject>();
        List<sObject> regionContactPositions = new List<sObject>();   
        List<sObject> eventsChampionedContactPositions = new List<sObject>();
        Contact stdContact = (Contact)stdController.getRecord();          
        String query = 'Select '+generateQueryFromFieldSets('Contact', 'AwardsBioPdfFields', null);
        query+=',(Select '+generateQueryFromFieldSets('Contact_Position__c', 
                                                      'AwardsBioPdfFields', 
                                                      new Set<String>{'Position_Category__c','Position_Title__c','Event__c'})
            +' from Contact_Positions__r), '+
            '(Select '+generateQueryFromFieldSets('Contact_Event__c', 
                                                  'AwardsBioPdfFields',
                                                  new Set<String>{'Program_Format__c'})+
            ' from Contact_Events__r where Program_Format__c != \'Chapter Event\'), '+
            '(Select '+generateQueryFromFieldSets('Contact_Achievement__c', 
                                                  'AwardsBioPdfFields',
                                                  new Set<String>{'RecordType.developername'})+
            ' from Contact_Achievements__r where RecordType.developername = \'Award\'), '+
            '(Select contact__c, Account__c '+
            ' from Academic_History__r where Relationship_Type__c=\'Member\'), '+
            '(Select '+generateQueryFromFieldSets('Account_Affiliation__c', 
                                                  'AwardsBioPdfFields',
                                                  new Set<String>{'RecordType.developername'})+
            ' from Account_Affiliations__r WHERE RecordType.developername = \'Network\') from Contact where id =\''+stdContact.id+'\'';
        cont = Database.query(query);
        chapterContactPositions = new List<Contact_Position__c>();
        committeeContactPositions = new List<Contact_Position__c>();        
        regionContactPositions = new List<Contact_Position__c>();        
        for(Contact_Position__c aCP: cont.Contact_Positions__r){
            if(aCP.Position_Category__c == 'Committee')committeeContactPositions.add(aCP);
            else if(aCP.Position_Category__c == 'Chapter')chapterContactPositions.add(aCP);
            else if(aCP.Position_Category__c == 'Region')regionContactPositions.add(aCP);
            if(aCP.Position_Title__c.contains('Chair') && aCP.Event__c != null)eventsChampionedContactPositions.add(aCP);
        }
        System.debug('Relationships'+ cont.Academic_History__r);
        for(Relationship__c rel: cont.Academic_History__r){
            memberContactToHouseholdAccId.put(rel.Contact__c, rel.Account__c);
        }
        
        householdFamilyMembers = new List<Relationship__c>();
        householdFamilyMembers = [Select Relationship_Type__c, contact__r.name from Relationship__c
                                   where account__c =: memberContactToHouseholdAccId.get(stdContact.id)];
        System.debug('memeberrs'+ householdFamilyMembers);
        relatedListWrappersList = new List<RelatedListWrapper>();
        //if(!committeeContactPositions.isEmpty())
            relatedListWrappersList.add(new RelatedListWrapper('Committees', 'AwardsBioPdfFields', committeeContactPositions, 'Contact_Position__c'));
        //if(!chapterContactPositions.isEmpty())
            relatedListWrappersList.add(new RelatedListWrapper('Chapter Officers', 'AwardsBioPdfFields', chapterContactPositions, 'Contact_Position__c'));
        //if(!regionContactPositions.isEmpty())
            relatedListWrappersList.add(new RelatedListWrapper('Region Officers', 'AwardsBioPdfFields', regionContactPositions, 'Contact_Position__c'));
        Map<String, List<sObject>> conEventsGroupedByProgFormat = GroupBy.strings('Program_Format__c', cont.Contact_Events__r);
        for(String progFormat : conEventsGroupedByProgFormat.keyset()){
            relatedListWrappersList.add(new RelatedListWrapper(progFormat, 'AwardsBioPdfFields', 
                                                               conEventsGroupedByProgFormat.get(progFormat), 'Contact_Event__c'));
        }   
            //if(!cont.Account_Affiliations__r.isEmpty())
                relatedListWrappersList.add(new RelatedListWrapper('Network Memberships', 'AwardsBioPdfFields', 
                                                               cont.Account_Affiliations__r, 'Account_Affiliation__c'));  
            //if(!cont.Contact_Achievements__r.isEmpty())
                relatedListWrappersList.add(new RelatedListWrapper('Awards', 'AwardsBioPdfFields', 
                                                               cont.Contact_Achievements__r, 'Contact_Achievement__c'));   
    }
    private String generateQueryFromFieldSets(String sObjectName,String fieldSetName,Set<String> additionalFields){  
        Set<String> fields = new Set<String>{'Id'};
            if(additionalFields!=null)  
            for( String fs : additionalFields ) {            
                if(!fields.contains(fs)){  
                    fields.add(fs);  
                }      
            }   
        Schema.DescribeSObjectResult res = Schema.getGlobalDescribe().get(sObjectName).getDescribe();  
        Map<String, Schema.FieldSet> fieldSetMap= res.fieldSets.getMap();  
        Schema.FieldSet fs = fieldSetMap.get(fieldSetName);  
        for(Schema.FieldSetMember fsm : fs.getFields()){    
            if(!fields.contains(fsm.getFieldPath())){   
                fields.add(fsm.getFieldPath());    
            }      
        }     
        return String.join(new List<String>(fields), ',');  
    }
    public Class RelatedListWrapper{
        public String header{get;set;}
        public List<sObject> filteredSObjects{get;set;}
        public String accFieldLabel{get;set;}
        public String fieldSetName{get;set;}
        public String objectName{get;set;}
        public String startDate{get;set;}
        public String endDate{get;set;}        
        public String columnsWidth{get;set;}
        /*public RelatedListWrapper(String header,String accFieldLabel,
                                  String fieldSetName, List<sObject> filteredSObjects, String programFormat){
                                      this(header, accFieldLabel, fieldSetName, filteredSObjects);                                      
                                      this.programFormat = programFormat;
                                  }*/
        public RelatedListWrapper(String accFieldLabel,
                                  String fieldSetName, List<sObject> filteredSObjects, String objectName){
                                      this.header = header;
                                      this.accFieldLabel = accFieldLabel;
                                      this.fieldSetName = fieldSetName;
                                      this.filteredSObjects = filteredSObjects;
                                      this.objectName = objectName;
                                      if(objectName == 'Contact_Position__c'){
                                          startDate = 'Begin Date';
                                          endDate = 'End Date';
                                          columnsWidth='40%,20%,20%,20%';
                                      }else if(objectName == 'Contact_Event__c'){
                                          startDate = 'Meeting Begin Date';
                                          endDate = 'Meeting End Date';                                          
                                          columnsWidth='60%,20%,20%,20%';
                                      }else if(objectName == 'Account_Affiliation__c'){
                                          startDate = 'Begin Date';
                                          endDate = 'End Date';                                          
                                          columnsWidth='60%,20%,20%';
                                      }else if(objectName == 'Contact_Achievement__c'){
                                          columnsWidth='60%,40%';
                                      }
                                  }
    }        
}