public with sharing class v_loadCartCtrl {

  public List<String> errorList {
    get {
      if (errorList == null){
        errorList = new List<String>();
      }
      return errorList;
    } set;
  }

  public Opportunity cart {get; set;}

// Constructor
  public v_loadCartCtrl() {
    System.debug( 'v_loadCartCtrl: page load 1' );
    String urlToken = ApexPages.currentPage().getParameters().get( 'ct' );
    String decryptedToken;
    if( String.isNotBlank(urlToken) )
    {
        decryptedToken = KGServiceClass.decryptString( urlToken );
    }
    System.debug( 'v_loadCartCtrl: page load 2' );
    System.debug( 'urlToken: ' + urlToken );
    System.debug( 'decryptedToken: ' + decryptedToken );
    if( String.isNotBlank(decryptedToken) )
    {
        try {
          cart = [SELECT Id, 
                          KGRenewal__Contact__c, 
                          AccountId, 
                          (SELECT ContactId, 
                                  Role, 
                                  IsPrimary 
                              FROM OpportunityContactRoles) 
                      FROM Opportunity 
                      WHERE Id = :decryptedToken];
        } 
        catch( Exception e ) 
        {
            errorList.add('There was a problem finding your cart');
        }
    }
    else
    {
        errorList.add('There was a problem finding your cart (no identifier provided)');
    }
  }

  //set Venue to use this Opportunity as the Cart
  public PageReference loadCart() {
    PageReference pr;
    if( errorList.size() == 0 )
    {
      try
      {
        KGServiceClass.activateCart( cart );
        KGServiceClass.setOpportunityContactRoles( cart );
        pr = Page.v_catalog;
        KGRenewal.Ecommerce.setOpportunityAsCart( cart.Id, pr );
        pr.setRedirect( true );
      } 
      catch( Exception e ) {
        System.debug( 'wooops enter catch' );
        errorList.add( e.getMessage() );
      }
    } 

    if( errorList.size() > 0 ) {
        pr = null;
    }

    return pr;
  }

}