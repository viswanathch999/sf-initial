/**
 * Model Factory allows us to abstract the process of finding 
 * an appropriate model instance away from the business/presentation components.
 * 
 * SObjectModelFactory encapsulates the logic needed to decide which 
 * concrete SObject Model to instantiate.
 *
 * @author Naveen Hiremath
 */
public class SObjectModelFactory {
    
    /**
     * Factory method whose sole purpose is to build and 
     * return a model instance
     *  
     * @param SObjectName case insensitive name of the SObject
     * @param SObj an instance of the SObject record
     * @return an instance of concrete SObject model
     */
    public static SObjectModel getInstance(final String sObjectName, 
                                           final SObject sObj) {
        SObjectModel model; 
        
        // Cannot use reflection since Type class's newInstance does not support
        // parameterized constructor instantiation 
        if(sObjectName.equalsIgnoreCase(Account.sObjectType.getDescribe().getName())) {
            model = new AccountModel((Account)sObj);
        }else if(sObjectName.equalsIgnoreCase(Chapter_Health__c.sObjectType.getDescribe().getName()))
        {
            model = new ChapterHealthModel((Chapter_Health__c)sObj);
        }else if(sObjectName.equalsIgnoreCase(Region_Health__c.sObjectType.getDescribe().getName()))
        {
            model = new RegionalHealthModel((Region_Health__c)sObj);
        }
        else if(sObjectName.equalsIgnoreCase(Contact.sObjectType.getDescribe().getName()))
        {
            model = new ContactModel((Contact)sObj);
        }
        else if(sObjectName.equalsIgnoreCase(Task.sObjectType.getDescribe().getName()))
        {
            model = new TaskModel((Task)sObj);
        }
        else if(sObjectName.equalsIgnoreCase(Account_Affiliation__c.sObjectType.getDescribe().getName()))
        {
            model = new AccountAffiliationModel((Account_Affiliation__c)sObj);
        }else if(sObjectName.equalsIgnoreCase(Interest__c.sObjectType.getDescribe().getName()))
        {
            model = new InterestModel((Interest__c)sobj);
        }
        
        return model;
    }
    
}