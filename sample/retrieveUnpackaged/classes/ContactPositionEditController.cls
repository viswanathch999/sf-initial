public class ContactPositionEditController {
    
    ApexPages.StandardController sCont;
    public Contact_Position__c theCP { get; set; }
    public Id recordTypeId {get;set;}
    @TestVisible
    public Boolean saveAttempted { get;set;}
    @TestVisible
    public Boolean saveNewAttempted { get;set;}
    public Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    
    public ContactPositionEditController( ApexPages.StandardController stdController ) {
        
        if(!test.isRunningTest()){
        stdController.addFields(new List<String>{'Position__c', 'Contact__c', 'Account__c', 'Event__c', 'Is_Expert__c', 'Status__c','Start_Date__c',
            'End_Date__c', 'Identification_Status__c', 'Name', 'GUID__c', 'YPOI_Organizational_Code__c', 'Position_Title__c', 'Position_Category__c', 'Committee_Member_Type__c', 'Is_Officer_Position__c' });
        }
        sCont = stdController;
        theCp = (Contact_Position__c) sCont.getRecord();
        RecordTypeHelper rtHelper = new RecordTypeHelper('Contact_Position__c');
        recordTypeId = rtHelper.defaultRecordTypeId;
        saveAttempted = false;
        saveNewAttempted = false;
        System.debug('**** ' + theCP + ' ' + recordTypeId);
    }
    
    public PageReference saveCustom(){
        system.debug('@@ custom save called : '+saveAttempted);
        if(!saveAttempted){
            if(ContactPositionServices.validateDuplicatePositionRecords(new List<Contact_Position__c> { theCp } )){
                return sCont.save();
            }else{
                saveAttempted = true;
                return null;
            }
        }else{
            return sCont.save();
        }
    }
    
    public PageReference saveAndNew(){
        system.debug('@@ save and new'+ saveNewAttempted);
        
        if(!saveNewAttempted){
            if(ContactPositionServices.validateDuplicatePositionRecords(new List<Contact_Position__c> { theCp } )){
                return sCont.save();
            }else{
                saveNewAttempted = true;
                return null;
            }
        }else{
            sCont.save();
            return Page.ContactPositionEdit;
        }
        
    }
}