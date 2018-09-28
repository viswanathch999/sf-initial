/**
* FlattenMultiSelectPicklistFieldBatch is scheduler which will run daily and translate and copy
*  the data from multiple multiselect picklists defined 
* in custom setting M2MXSkillsetSearchObject
* into a text field containing the concatenation from all the multiselect fields specific to object
*
* @author Nikunj Doshi
*/
global class FlattenMultiSelectPicklistFieldBatch implements Schedulable, Database.Stateful, Database.Batchable<sObject>{
    String query;       
    /**
* Contructor takes in the objectName, constructs the start query for the ame dynamically 
* using field api names from custom setting 
* @param objectName API Name of the object
*/
    public FlattenMultiSelectPicklistFieldBatch(String objectName){
        query = 'Select Id, ';
        query += String.join(FlattenMultiSelectPicklistFieldServices.getMultiSelectFieldNames(objectName), ',')+' , MultiSelectPicklists_Text__c ';
        query +=' From '+objectName;// +' Where lastmodifieddate = TODAY';
    }
    
    /**
* start method of batchable interface.
* Method queries on all the Objects modified today and returning to execute
* @param BC batchable context variable.
* @return Database.QueryLocator.
*/
    global Database.QueryLocator start(Database.BatchableContext BC){      
        system.debug('query '+query);
        return Database.getQueryLocator(query);
    }
    
    /**
* execute method of batchable interface.
* calls convertMultiSelectToText method of FlattenMultiSelectPicklistFieldServices
* responsible for updating text field on records with
* concatenation of value from all the multiselect fields specific to an object 
* @param BC batchable context variable.
* @param scope List<sObject> returned by Start method.
* @return null.
*/
    global void execute(Database.BatchableContext BC, List<sObject> scope) {        
        FlattenMultiSelectPicklistFieldServices.convertMultiSelectToText(scope);
    }
    
    /**
* finish method of batchable interface.
* @param BC batchable context variable.
* @return null.
*/
    global void finish(Database.BatchableContext BC){
    }
    
    /**
* start method of schedulable interface. 
* Method internally calls batch for the objects defined in custom setting.  
*/
    global void execute( SchedulableContext sc ) {        
        
        for(String objectName :FlattenMultiSelectPicklistFieldServices.mappingMap.keyset()){
            List<String> fieldList = FlattenMultiSelectPicklistFieldServices.getMultiSelectFieldNames(objectName);
            if(!fieldList.isEmpty())
            {
                FlattenMultiSelectPicklistFieldBatch job = new FlattenMultiSelectPicklistFieldBatch(objectName); 
                Database.executeBatch(job);
            }
        }
    }
}