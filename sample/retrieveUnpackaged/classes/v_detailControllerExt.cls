/** copyright kinetic growth inc */

public class v_detailControllerExt
{
    private final KGRenewal.VenueDetailController venueCtrl { get; set; }
/*****************************************************************************/
    public List<String> imageList {
        get {
            if(imageList == null) {
                imageList = setupImageList(venueCtrl.item.record);
            }
            return imageList;
        }
        private set;
    }
/*****************************************************************************/
    public v_DetailControllerExt(KGRenewal.VenueDetailController v)
    {
        venueCtrl = v;
        //imageList = setupImageList(venueCtrl.item.record);
    }
/*****************************************************************************/
    @TestVisible
    private List<String> setupImageList(Product2 record)
    {
        List<String> imageList = new List<String>();

        if (String.isNotBlank(record.KGRenewal__MainImageSmall__c)) {
            imageList.add(record.KGRenewal__MainImageSmall__c);
        }
        if (String.isNotBlank(record.KGRenewal__SecondImageSmall__c)) {
            imageList.add(record.KGRenewal__SecondImageSmall__c);
        }
        if (String.isNotBlank(record.KGRenewal__ThirdImageSmall__c)) {
            imageList.add(record.KGRenewal__ThirdImageSmall__c);
        }
        if (String.isNotBlank(record.KGRenewal__FourthImageSmall__c)) {
            imageList.add(record.KGRenewal__FourthImageSmall__c);
        }
        if (String.isNotBlank(record.KGRenewal__MainImageMed__c)) {
            imageList.add(record.KGRenewal__MainImageMed__c);
        }
        if (String.isNotBlank(record.KGRenewal__SecondImageMed__c)) {
            imageList.add(record.KGRenewal__SecondImageMed__c);
        }
        if (String.isNotBlank(record.KGRenewal__ThirdImageMed__c)) {
            imageList.add(record.KGRenewal__ThirdImageMed__c);
        }
        if (String.isNotBlank(record.KGRenewal__FourthImageMed__c)) {
            imageList.add(record.KGRenewal__FourthImageMed__c);
        }
        if (String.isNotBlank(record.KGRenewal__MainImageLarge__c)) {
            imageList.add(record.KGRenewal__MainImageLarge__c);
        }
        if (String.isNotBlank(record.KGRenewal__SecondImageLarge__c)) {
            imageList.add(record.KGRenewal__SecondImageLarge__c);
        }
        if (String.isNotBlank(record.KGRenewal__ThirdImageLarge__c)) {
            imageList.add(record.KGRenewal__ThirdImageLarge__c);
        }
        if (String.isNotBlank(record.KGRenewal__FourthImageLarge__c)) {
            imageList.add(record.KGRenewal__FourthImageLarge__c);
        }
        return imageList;
    }
/*****************************************************************************/
    public List<SelectOption> getContactOptions()
    {
        //SelectOption option = new SelectOption(value, label, isDisabled);

        List<SelectOption> contactOptions = new List<SelectOption>();
        //contactOptions.add(new SelectOption('', 'Select a household member', true));
        try
        {
/*
            Id userId = UserInfo.getUserId();
            Id accountId = [SELECT AccountId FROM User WHERE Id = :userId].AccountId;
            List<Contact> contactList = [SELECT Name FROM Contact WHERE AccountId = :AccountId ORDER BY Name];
            for(Contact con : contactList)
            {
                contactOptions.add(new SelectOption(con.Id, con.Name));
            }
            Id theProductId = ApexPages.currentPage().getParameters().get('id');
            contactOptions = KGServiceClass.getListOfEligibleContacts(theProductId);
*/
            contactOptions = KGServiceClass.getListOfEligibleContacts(venueCtrl.item.record);
        }
        catch(exception e)
        {}
        return contactOptions;
    }
/*****************************************************************************/
    public boolean hasAvailableContactOptions {
      get {
         return KGServiceClass.hasAvailableContactOptions(getContactOptions());
      }
      set;
    }
/*****************************************************************************/
    public PageReference setProspectOppAsCart()
    {
        return KGServiceClass.setProspectOppAsCart();
    }
/*****************************************************************************/
/*
    public PageReference setProspectOppAsCart()
    {
        System.debug('***************************** ENTER: v_detailControllerExt.loadProspectOpp()');
        PageReference pr;
        Id cartId = KGRenewal.Cart.getOpportunityId();
        if( cartId == null )
        {
            Id contactId = KGRenewal.Cart.getContactId();
            String ocrRole = KGRenewal__VenueSettings__c.getOrgDefaults().KGRenewal__BuyerRole__c;
            List<OpportunityContactRole> ocrList = [SELECT OpportunityId 
                                                    FROM OpportunityContactRole 
                                                    WHERE ContactId = :contactId 
                                                        AND Role = :ocrRole 
                                                        AND Opportunity.KGRenewal__IsActiveCart__c = true 
                                                    ORDER BY IsPrimary];
            if( ocrList.size() > 0 ) {
                PageReference nextPage = Page.v_catalog;
                return KGRenewal.Ecommerce.setOpportunityAsCart(ocrList[0].OpportunityId, nextPage);
            }
        }
        System.debug('***************************** EXIT: v_detailControllerExt.loadProspectOpp()');
        return pr;
    }
*/
/*****************************************************************************/
// Sets Opportunity.KGRenewal__isActiveCart__c = TRUE on Renewal Opp
    public void activateRenewal()
    {
        System.debug('***************************** ENTER: v_detailControllerExt.activateRenewal()');
        /*Id cartId = KGRenewal.Cart.getOpportunityId();
        Opportunity thisCart = [SELECT Referred_by_Chapter__c,
                                        Record_Type_Name__c,
                                        KGRenewal__Contact__c
                                 FROM Opportunity
                                 WHERE Id = :cartId];
        Map<String, Object> params = new Map<String, Object>();
        params.put('varOpptyID', thisCart.Id);
        params.put('varRefChapID', thisCart.Referred_by_Chapter__c);
        params.put('varOppRecordType', thisCart.Record_Type_Name__c);
        params.put('varContactID', thisCart.KGRenewal__Contact__c);
        Flow.Interview.Set_Products setProductsFlow = new Flow.Interview.Set_Products(params);
        setProductsFlow.start();
        */
        //Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        Id contactId = KGRenewal.Cart.getContactId();
        if( contactId == null)
        {
            return;
        }

        List<OpportunityContactRole> ocrList = [SELECT Opportunity.KGRenewal__isActiveCart__c,
                                                        Opportunity.KGRenewal__PreviousSale__c,
                                                        Opportunity.KGRenewal__ContractEndDate__c,
                                                        Opportunity.Probability,
                                                        Opportunity.IsClosed
                                                    FROM OpportunityContactRole
                                                    WHERE ContactId = :contactId
                                                        AND IsPrimary = true
                                                    ORDER BY CreatedDate DESC];

        List<Opportunity> oppsToUpate = new List<Opportunity>();
        Set<Id> oppIdSet = new Set<Id>();
        boolean foundCurrentRenewalOpp = false;
        Integer length = ocrList.size();
        for(Integer i = 0; i < length; i++)
        {
            Opportunity opp = ocrList[i].Opportunity;
            if( ! oppIdSet.add(opp.Id) )
            {
                // already processed this Opp, continue to next Opp
                continue;
            }

            if( foundCurrentRenewalOpp == false
                && opp.KGRenewal__PreviousSale__c != null
                && opp.Probability != 100
                && ! opp.IsClosed
                && opp.KGRenewal__ContractEndDate__c != null
                && opp.KGRenewal__ContractEndDate__c.year() == System.today().year() + 1 )
            {
                foundCurrentRenewalOpp = true;
                if( ! opp.KGRenewal__isActiveCart__c )
                {
                    oppsToUpate.add( new Opportunity(Id = opp.Id,
                                                KGRenewal__isActiveCart__c = true) );
                }
                continue;
            }

            if( opp.KGRenewal__isActiveCart__c )
            {
                oppsToUpate.add( new Opportunity(Id = opp.Id,
                                                KGRenewal__isActiveCart__c = false) );
            }
        }
        if( foundCurrentRenewalOpp )
        {
            update oppsToUpate;
        }
        System.debug('***************************** EXIT: v_detailControllerExt.activateRenewal()');
    }
/*****************************************************************************/
}