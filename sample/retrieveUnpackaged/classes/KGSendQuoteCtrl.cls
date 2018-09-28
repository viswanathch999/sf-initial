public with sharing class KGSendQuoteCtrl {

    // Constructor - this only really matters if the autoRun function doesn't work right
    public KGSendQuoteCtrl(ApexPages.StandardController stdController) {
      
    }
     
    // Code we will invoke on page load.
    public PageReference autoRun() {
 
      String opportunityId = ApexPages.currentPage().getParameters().get('id');
      //Boolean customerQuote = Boolean.valueOf(ApexPages.currentPage().getParameters().get('customerQuote'));

      if (opportunityId == null) {
          // Display the Visualforce page's content if no Id is passed over
          return null;
      }

      //Set SendQuote__c to true. This will kick off a workflow and a trigger.
      Opportunity o = [SELECT Id FROM Opportunity WHERE Id =: opportunityId];
      o.SendQuote__c = true;
      update o;
      
      // Redirect the user back to the original page
      PageReference pageRef = new PageReference('/' + opportunityId);
      pageRef.setRedirect(true);
      return pageRef; 
    }
}