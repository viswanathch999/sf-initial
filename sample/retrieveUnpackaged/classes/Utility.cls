/*
 * 
 * Utility is a utility class. 
 * All the utility methods of the application should be present here. 
 *
 * @author Shri K
 */
public class Utility {
    
    /*
     * Method to get parameter passed to page 
     * @param sParamName is the Name of the parameter passed to page.
     * @return values of the parameter passed to page.
     */
    public static String getPageParameterValue(String sParamName)
    {
    	if(!String.isEmpty(sParamName))	
    	{
    		return ApexPages.currentPage().getParameters().get(sParamName);
    	}else{
    		return null;
    	}
    }
    
    /*
     * Method to get parameter passed to page 
     * @param contactId is the Contact Id of contact whose relationship needs to be created
     * @param accountId is the Account Id of the household account.
     * @return Relationship object
     */
    public static Relationship__c createRelationship(Id contactId, Id accountId, String sRelationshipType)
    {
    	if(!(String.isEmpty(contactId) || String.isEmpty(accountId)))
    	{
    		return new Relationship__c(Account__c = accountId, Is_Active__c=true, Contact__c = contactId, Relationship_Type__c = sRelationshipType);
    	}else{
    		return null;
    	}
    }
    
    /*
     * Method to navigate to any page with Id parameter 
     * @param pageName Name of the page to navigate to.
     * @param paramVal value of the Id being passed
     * @param redirect value of the redirect attribute
     * @return PageReference object
     */
     
     /*public static PageReference navigate(String pageName, Id paramVal, Boolean redirect){
     	PageReference pageRef = new PageReference('/apex/'+pageName);
        pageRef.getParameters().put('Id',paramVal);
        pageRef.setRedirect(redirect);
        return pageRef;
     }*/
}