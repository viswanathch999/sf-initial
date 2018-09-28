public with sharing class v_catalogExt {

    public KGRenewal.VenueCatalogController venueCtrl {get;set;}

    // The select options for each product
    public Map<Id, List<SelectOption>> optionsMap {get;set;}

    public Map<Id, Boolean> hasAvailableContactOptionsMap {get;set;}
/*****************************************************************************/
    // Constructor
    public v_catalogExt(KGRenewal.VenueCatalogController v) {
        venueCtrl = v;

        optionsMap = new Map<Id, List<SelectOption>>();
        hasAvailableContactOptionsMap = new Map<Id,Boolean>();
        for(KGRenewal.ProductDisplayItem item : venueCtrl.productDisplayItems) {
          List<SelectOption> optionsList = KGServiceClass.getListOfEligibleContacts(item.record);
          optionsMap.put(item.productId, optionsList);
          hasAvailableContactOptionsMap.put(item.productId, KGServiceClass.hasAvailableContactOptions(optionsList));
        }
    }
/*****************************************************************************/
    // strips namespace
    public PageReference doSearch2(){
        return venueCtrl.doSearch();
    }
/*****************************************************************************/
    //Apply the search term as a url parameter
    public PageReference doSearch3() {
        PageReference newPage = new PageReference(System.URL.getCurrentRequestUrl().getPath().replace('', '').replace('', ''));

        for(String m : ApexPages.CurrentPage().getParameters().keySet()) {
            if(!m.startsWith('j_id') && !m.startsWith('com.salesforce')) {
                newPage.getParameters().put(m, ApexPages.CurrentPage().getParameters().get(m));
            }
        }

        newPage.getParameters().put('search-term', venueCtrl.searchTerm);
        newPage.getParameters().put('page-number', String.valueOf(1));
        newPage.setRedirect(true);
        //System.Debug(newPage);
        return newPage;
    }
/*****************************************************************************/
    public PageReference setProspectOppAsCart()
    {
        return KGServiceClass.setProspectOppAsCart();
    }
/*****************************************************************************/
}