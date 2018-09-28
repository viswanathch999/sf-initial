public class WelcomePageController_YPO {
    
    static final String CONST_MEMBER = 'Member';
    static final String CONST_FORMER_MEMBER = 'Former_Member';
    static final String CONST_CONTACT = 'Contact';
    
    public Boolean isMember{get;set;}
    public String contactId{get;set;}
    public Contact oContact;
    
    public static Boolean isThirdPartyCertify{
        get {
                if(isThirdPartyCertify == null) {
                        isThirdPartyCertify = false;
                }
                
                return isThirdPartyCertify;
        }
    set;}
    
    Id memberRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_MEMBER, CONST_CONTACT).Id;
    Id formerMemberRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_FORMER_MEMBER, CONST_CONTACT).Id;
    
    public WelcomePageController_YPO(Apexpages.StandardController oStandardController){
        try {
			if((Contact)oStandardController.getRecord()!= new Contact()){
				oContact = (Contact)oStandardController.getRecord();
				oContact = [SELECT Id, RecordTypeId, Membership_Status__c FROM Contact WHERE Id = :oContact.Id];
			}
			else{
				User oUser = [Select Id,ContactId from User where Id = :UserInfo.getUserId()];
        
				if (oUser.ContactId != null) {
					oContact = [SELECT Id, RecordTypeId, Membership_Status__c FROM Contact WHERE Id = :oUser.ContactId];
				} else {
					throw new CustomException('No member Contact record was found!');
				}
			}
			contactId = ocontact.Id;
			isMember = (oContact.RecordTypeId==memberRecordTypeId || oContact.RecordTypeId==formerMemberRecordTypeId ?true:false); 
        
			if(oContact.Membership_Status__c == 'Surviving Spouse/Partner')
					isMember = true;
        } Catch (CustomException cexp) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, cexp.getMessage()));
		}

        //Opportunity oOpp = ContactServices.getOpportunities(oContact);

        //if(oOpp != null && oOpp.Certification_Type__c == 'Third Party Certify') {
                //isThirdPartyCertify = true;
        //}
    }

}