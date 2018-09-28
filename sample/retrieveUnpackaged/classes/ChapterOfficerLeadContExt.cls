/*
 * 
 * ChapterOfficerLeadContExt is a extension class for chapter officer lead creation page. 
 * Page associated with this clas will be used by chapter officer to create leads.
 *
 * @author Shri K
 */

public with sharing class ChapterOfficerLeadContExt {
    
	public ChapterOfficerLeadContExt(Apexpages.StandardController oStandardController)
	{
		Lead oLead = (Lead)oStandardController.getRecord();		
		
		User oUser = [SELECT Id, AccountId FROM User WHERE Id =: UserInfo.getUserId() ];
		Account oAccount = [SELECT Name FROM Account WHERE Id =: oUser.AccountId];
		oLead.Organization__c = oAccount.Name;
	} 
}