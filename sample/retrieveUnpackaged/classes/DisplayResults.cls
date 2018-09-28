/**
 * 
 * DisplayResults is a controller class which is used to display all related Account Affiliation  
 * records filter by account type after clicking on Show All link on related list on Contact Detail Page
 *
 * @author Malay Desai
 */
public with sharing class DisplayResults {
    
    public String queryString = Apexpages.currentPage().getParameters().get('queryString');
    public List<Account_Affiliation__c> lstSObjects{get;set;}
    
    public DisplayResults(){    
        lstSObjects = Database.query(queryString);
    }
    
}