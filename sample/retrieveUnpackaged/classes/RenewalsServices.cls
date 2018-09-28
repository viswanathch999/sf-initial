public with sharing class RenewalsServices {
	
	public static PageReference lifetimeOptionCheck(Contact contactInfo)
	{
		PageReference returnPage;
		if( String.isBlank(contactInfo.Lifetime_Dues_Status__c) && 
			(contactInfo.Transition_Status__c == 'Eligible for early transition' ||
			 contactInfo.Transition_Status__c == 'Scheduled for transition' ||
			 contactInfo.Transition_Status__c == 'Transitioned'  
			)
		  )
		{
			returnPage = Page.LifetimeOption_ypo;
			returnPage.getParameters().put('Id',contactInfo.Id);	
		}
		else
		{
			returnPage = Page.Catalog_YPO;
			returnPage.getParameters().put('Id',contactInfo.Id);
		}
		return returnPage;
	}

}