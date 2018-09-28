/*COPYRIGHT KINETIC GROWTH INC*/
/*v_CartControllerExt*/

public without sharing class v_CartControllerExt
{
    private KGRenewal.VenueCartController venueCtrl { get; set; }
    public Boolean hasTerm { get; set; }
    public String CurrencyCode {set;get;}
    public boolean prospectRType { 
    	get
    	{
    		if(prospectRType == null){
    			Id prospectId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
    			if(prospectId == [Select Contact.RecordTypeId From User Where Id=:UserInfo.getUserId()].Contact.RecordTypeId){
    				prospectRType = true;
    			}else{
    				prospectRType = false;
    			}
    		}
    		return prospectRType;
    	}
     	set; 
     } 

    // Estimate Tax
    public String zipCode { get; set; }

    // Errors
    public String zipCodeError { get; set; }

    public Integer totalItemCount
    {
        get
        {
            Integer count = 0;
            for (KGRenewal.Cart.LineItem item : venueCtrl.lineItems)
            {
                count += Integer.valueOf(item.quantity);
            }
            return count;
        }
    }
    
    public boolean cameFromLifetimePage {
    	get{
    		if(cameFromLifetimePage == null){
    			
    			if(ApexPages.currentPage().getParameters().get('lifetime') == 'true'){
    				cameFromLifetimePage = true;
    			}else{
    				cameFromLifetimePage = false;
    			}
    		}
    		return cameFromLifetimePage;
    	}set;
    	
    }
/*****************************************************************************/
    // Constructor
    public v_CartControllerExt( KGRenewal.VenueCartController v )
    {
        venueCtrl = v;
        hasTerm = false;
        zipCodeError = null;
        CurrencyCode = UserInfo.getDefaultCurrency();
        
        // update cart line items with the Contact's name
        if( venueCtrl.cartId != null && venueCtrl.lineItems != null && venueCtrl.lineItems.size() > 0 )
        {
            Map<Id, OpportunityLineItem> oliMap;
            oliMap = new Map<Id, OpportunityLineItem>( [SELECT Contact__r.Name 
                                                            FROM OpportunityLineItem 
                                                            WHERE OpportunityId = :venueCtrl.cartId] );
            for( KGRenewal.Cart.LineItem item : venueCtrl.lineItems )
            {
                String contactName = oliMap.get(item.recordId).Contact__r.Name;
                if( String.isNotBlank(contactName) )
                {
                    item.description = contactName;
                    //item.customFields.put('Contact__r.Name', oliMap.get(item.recordId).Contact__r.Name);
                }
            }
        }
    }
/*****************************************************************************/
    public PageReference updateQuantity()
    {
        // used to load Prospect (record type) Opportunity if no Cart found
        PageReference pr1 = setProspectOppAsCart();
        PageReference pr2 = Page.NullCheckPage;
        if( pr1.getURL() != pr2.getURL()) return pr1;

        PageReference pr = null;
        String urlItem = ApexPages.currentPage().getParameters().remove('q');
        if( String.isNotBlank(urlItem) )
        {
            Id urlId = (Id)urlItem.substringBefore(':');
            Decimal urlQuantity = Decimal.valueOf( urlItem.substringAfter(':') );
            for( KGRenewal.Cart.LineItem item : venueCtrl.lineItems )
            {
                if( item.recordId == urlId )
                {
                    if( urlQuantity == 0 )
                    {
                        delete( item.record );
                    }
                    else if( urlQuantity != item.quantity )
                    {
                        item.record.quantity = urlQuantity;
                        // dml not allowed in constructor
                        update( item.record );
                    }
                    // leave the loop once we find the line item
                    break;
                }
            }
            pr = Page.ShoppingCart_YPO;
            pr.setRedirect( true );
        }
        return pr;
    }
/*****************************************************************************/
    public PageReference setProspectOppAsCart()
    {
        return KGServiceClass.setProspectOppAsCart();
    }
/*****************************************************************************/
}