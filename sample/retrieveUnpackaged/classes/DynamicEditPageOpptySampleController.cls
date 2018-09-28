public with sharing class DynamicEditPageOpptySampleController extends DetailPageHelper{
    public Opportunity myOpp{ get; set; }
    
    public DynamicEditPageOpptySampleController( ApexPages.StandardController stdController ){
         super( stdController );
         myOpp = (Opportunity) theSObject;      
    }
    
}