/*
 * 
 * PublicInterestManagerInterestContExt is a extension class for public interest manager page. 
 * This class will cater addition/removal of interest for contact.
 *
 * @author Shri K
 */
public with sharing class PublicInterestManagerInterestContExt {
    
    Id contactId;
    @TestVisible static Id testContactId;
    public Contact oContact{get; set;}
    
    public Interest__c oInterest{get; set;}
    List<Schema.SObjectField> lstSobjectField = new List<Schema.SObjectField>{Interest__c.type__c, Interest__c.Category__c, Interest__c.Interest__c, Interest__c.Contact__c};
    List<Schema.SObjectField> lstSelectFieldsContact = new List<Schema.SObjectField>{Contact.Golf_Clubs__c, Contact.Other_Languages__c, Contact.Consulates__c};
    static InterestDAO oInterestDAO;
    static ContactDAO oContactDAO;
    
    static 
    {
        oInterestDAO = new InterestDAO(DAOStrategyType.DMLDAOStrategy);    
        oContactDAO = new ContactDAO(DAOStrategyType.DMLDAOStrategy);
    }
    
    public List<Interest__c> lstInterests
    { 
        get
        {
            if(String.isNotEmpty(contactId))
            {
                return [SELECT Id, Category__c, type__c, Interest__c, Contact__c FROM Interest__c WHERE Contact__c =: contactId ORDER BY Category__c];        
            }else{
                return null;
            }
        } 
        private set;
    }
    
    public PublicInterestManagerInterestContExt(ApexPages.StandardController oInterestController)
    {
        if(!Test.isRunningTest())
        {
            oInterestController.addFields(new List<String>{'Contact__c'});
            contactId = ((Interest__c)oInterestController.getRecord()).Contact__c;
        }else{
            contactId = testContactId;
        }
        
        if(String.isNotEmpty(contactId))
        {
            oContact = [SELECT Id, Golf_Clubs__c, Other_Languages__c, Consulates__c,
            Other_Interest_1__c, Other_Interest_2__c, Other_Interest_3__c, Other_Interest_4__c, Other_Interest_5__c FROM Contact WHERE Id =: contactId];
        }
        resetInterest();
    }
    
    public void saveInterest()
    {
        //insert oInterest;
        SobjectModel oInterestModel = new InterestModel(oInterest);
        oInterestDAO.create(new List<SobjectModel>{oInterestModel}, lstSobjectField);
        resetInterest();
    }
    
    public PageReference saveContact()
    {
        saveAndContinueContact();
        return returnToContact();    
    }
    public void saveAndContinueContact()
    {
        ContactModel oContactModel = new ContactModel(oContact);
        oContactDAO.modify(new List<SobjectModel>{oContactModel}, lstSelectFieldsContact);
    }
    
    public PageReference returnToContact()
    {
        return new PageReference('/' + contactId);
    }
    
    private void resetInterest()
    {
        oInterest = new Interest__c(Contact__c = contactId);    
    }
}