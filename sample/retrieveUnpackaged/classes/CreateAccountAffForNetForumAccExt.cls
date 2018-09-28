public without sharing class CreateAccountAffForNetForumAccExt {
    public Account acc{get;set;}
    public List<WrapContact> wrapContactList {get; set;}
    public static Id networkAccRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Network', 'Account').Id;
    public static Id forumAccRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Forum', 'Account').Id;
    public static Id networkAffRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Network', 'Account_Affiliation__c').Id;
    public static Id forumAffRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Forum', 'Account_Affiliation__c').Id;
    
    public CreateAccountAffForNetForumAccExt(ApexPages.StandardController controller)
    {
        if(!Test.isRunningTest())controller.addFields(new List<String>{'RecordTypeId', 'RecordType.name', 'name'});
        acc = (Account)controller.getRecord(); 
        acc.name='';
        Id accRecordTypeId = acc.RecordTypeId;
        if(accRecordTypeId != networkAccRecordTypeId && accRecordTypeId != forumAccRecordTypeId){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Network/Forum accounts are only allowed'));
        }
        wrapContactList = new List<WrapContact>();
    }
    
    public void getRelatedContactsToAccViaSOSL(){
		//5674 ND 25/12/16
        List<List<sObject>> soslContactsHavingSearchString = new List<List<sObject>>();
        Set<Id> contactsAlreadyHavingAff = Pluck.ids('contact__c' ,[Select contact__c from Account_Affiliation__c where account__c =:acc.id]);
        try{
            soslContactsHavingSearchString = [FIND :acc.name IN ALL FIELDS RETURNING Contact(Name,AccountId,Email where id not in:contactsAlreadyHavingAff LIMIT 500)];
            
            // After attempting search, clear out current list of results whether we have new ones or not.
            wrapContactList = new List<WrapContact>();
        }
        catch(Exception ex){
            ApexPages.addmessages(ex);
            System.debug(ex.getMessage()); 
            return;
        }
        if(!soslContactsHavingSearchString.isEmpty()){
            List<Contact> contactsHavingSearchString = new List<Contact>();  
            contactsHavingSearchString = (List<Contact>)soslContactsHavingSearchString[0];
            for(Contact cont: contactsHavingSearchString) {
                wrapContactList.add(new WrapContact(cont));
            }
        }
    }
    
    public PageReference processSelected(){
        List<Account_Affiliation__c> accAffsToBeInserted = new List<Account_Affiliation__c>();
        for(WrapContact wrapContactObj : wrapContactList) {
            if(wrapContactObj.selected) {                
                Account_Affiliation__c accAff = new Account_Affiliation__c();  
                accAff.Contact__c = wrapContactObj.contact.Id;
                accAff.Account__c = acc.Id;
                accAff.Start_Date__c = System.today();
                if(acc.recordtypeId == networkAccRecordTypeId){
                    accAff.RecordTypeId = networkAffRecordTypeId;
                }
                else if(acc.recordtypeId == forumAccRecordTypeId){
                    accAff.RecordTypeId = forumAffRecordTypeId;
                }
                accAffsToBeInserted.add(accAff);
            }
        }
        try{
            insert accAffsToBeInserted;
        }
        catch(DmlException dEx){
            ApexPages.addmessages(dEx);
            System.debug('Exception occured :' + dEx.getMessage());
            //5674 ND 18/12/16
            return null;
        }
        PageReference accPage = new PageReference('/'+acc.Id);
        return accPage;
    }
    
    public class WrapContact {
        public Contact contact {get; set;}
        public Boolean selected {get; set;}        
        public WrapContact(Contact con) {
            Contact = con;
            selected = false;            
        }
    }
}