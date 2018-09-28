public without sharing class CatalogExtension_YPO {

	public KGRenewal.VenueCatalogController venueCtrl { get; set; }

	// The select options for each product
	public Map<Id, List<SelectOption>> optionsMap { get; set; }

	public Map<Id, Boolean> hasAvailableContactOptionsMap { get; set; }
	public static final Id prospectRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Prospect', 'Opportunity').Id;
	public Opportunity theOpp { get; set; }
	public String CurrencyCode { set; get; }

	public Boolean hasGrace {
		get {
			if (hasGrace == null) {
				hasGrace = false;
				Integer count = 0;
				count = [Select count() from Exception__c where contact__C = :contactId and opportunity__c = :KGRenewal.Cart.getOpportunityId() and(Type_of_Waiver__c = 'Grace Extension' OR Exception_Category__c = 'Waiver' OR Exception_Category__c = 'Grace')];
				if (count > 0) {
					hasGrace = true;
				}

			}
			System.debug('*** hasGrace: ' + hasGrace);
			return hasGrace;
		} set;
	}

	@TestVisible Id contactId
	{
		get
		{
			if (contactId == null) {
				try { //Item-07341
					contactid = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
					if (contactid == null) throw new CustomException('Current User does not have a corresponding member Contact record!');
				} catch(CustomException e) {
					System.debug(e.getMessage());
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, e.getMessage()));
				}
			}
			return contactId;
		}
		set;
	}

	public Contact oContact {
		get {
			if (oContact == null) {
				try { //Item-07341
					List<Contact> lstContact = [SELECT Id, Membership_Status__c, Join_Date__c, Lifetime_Dues_Status__c, YPO_WPO_Formula__c, RecordTypeId FROM Contact WHERE Id = :contactId LIMIT 1];
					if (lstContact.size() > 0) {
						oContact = lstContact[0];
					} else {
						throw new CustomException('Current User does not have a corresponding member Contact record!');
					}
				} catch(CustomException e) {
					System.debug(e.getMessage());
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, e.getMessage()));
				}
			}
			return oContact;
		} set;
	}

	public Boolean lifetimeDuesStatusFlag {
		get {
			if (lifetimeDuesStatusFlag == null) {
				if (oContact.Lifetime_Dues_Status__c == null) {
					lifetimeDuesStatusFlag = false;
				} else {
					lifetimeDuesStatusFlag = true;
				}
			}
			return lifetimeDuesStatusFlag;
		} set;
	}

	public Boolean isYPOGold {
		get {
			if (isYPOGold == null) {
				isYPOGold = false;
				if (oContact.Transition_Status__c != Null) {
					if (oContact.YPO_WPO_Formula__c == 'YPO Gold') {
						isYPOGold = true;
					}
				}
			}
			return isYPOGold;
		} set;
	}

	public Boolean isTransitioning {
		get {
			if (isTransitioning == null) {
				isTransitioning = theOpp.Transition_Flag__c;
			}

			return isTransitioning;
		} private set;
	}

	public Boolean isGraceNeeded {
		get {
			if (isGraceNeeded == null) {
				isGraceNeeded = (theOpp.Grace_Status__c != 'No Grace Needed');
			}

			return isGraceNeeded;
		} private set;
	}

	public boolean cameFromLifetimePage {
		get {
			if (cameFromLifetimePage == null) {

				if (ApexPages.currentPage().getParameters().get('lifetime') == 'true') {
					cameFromLifetimePage = true;
				} else {
					cameFromLifetimePage = false;
				}
			}
			return cameFromLifetimePage;
		} set;

	}

	public boolean displayTransitionModal {
		get {
			if (displayTransitionModal == null) {

				if (ApexPages.currentPage().getParameters().get('Modal') == 'Transition') {
					displayTransitionModal = true;
				} else {
					displayTransitionModal = false;
				}
			}
			return displayTransitionModal;
		} set;
	}

	public boolean displayGraceModal {
		get {
			if (displayGraceModal == null) {

				if (ApexPages.currentPage().getParameters().get('Modal') == 'Grace') {
					displayGraceModal = true;
				} else {
					displayGraceModal = false;
				}
			}
			return displayGraceModal;
		} set;
	}

	public List<product2> prod2 { set; get; }
	List<Id> itemId = new List<Id> ();

	public CatalogExtension_YPO(KGRenewal.VenueCatalogController venueCatalogCntrl) {
		if (KGRenewal.Cart.getOpportunityId() != null) {
			system.debug('*** Came from lifetime : ' + cameFromLifetimePage);
			System.debug(LOGGINGLEVEL.DEBUG, 'Error after this');
			CurrencyCode = UserInfo.getDefaultCurrency();
			venueCartCtrl = new KGRenewal.VenueCartController();
			System.debug(LOGGINGLEVEL.DEBUG, 'Error before this');
			optionsMap = new Map<Id, List<SelectOption>> ();
			hasAvailableContactOptionsMap = new Map<Id, Boolean> ();
			urldeleteItem = ApexPages.currentPage().getParameters().get('q');
			venueCtrl = venueCatalogCntrl;
			theOpp = [Select Id, Certification_Type__c, Dues_Page_Status_Exchange__c, Transition_Flag__c, Referred_by_Chapter__c, RecordTypeId, Record_Type_Name__c, Amount, Grace_Status__c, StageName, CartToken__c From Opportunity Where Id = :KGRenewal.Cart.getOpportunityId()];
			isTransitioning = theOpp.Transition_Flag__c;
			if (venueCtrl != null && venueCtrl.ProductDisplayItems != null) {
				for (KGRenewal.ProductDisplayItem item : venueCtrl.productDisplayItems) {
					if (item<> null) {
						//system.debug('^^^^^^^^^^^^^^^^^^^^^^item.record^^^^^^^^^^^^^^^^^^'+item.record.id + '--' +venueCtrl.productDisplayItems.size());
						List<SelectOption> optionsList = KGServiceClass.getListOfEligibleContacts(item.record);
						itemId.add(item.record.id);
						system.debug(Logginglevel.debug, 'optionsList  :' + optionsList);
						optionsMap.put(item.productId, optionsList);
						hasAvailableContactOptionsMap.put(item.productId, KGServiceClass.hasAvailableContactOptions(optionsList));
						system.debug(Logginglevel.debug, 'hasAvailableContactOptionsMap:' + hasAvailableContactOptionsMap);
					}
				}
				prod2 = [select id, name, PDF_Link__c from product2 where id in :itemId];
				for (product2 proditem : prod2) {
					if (prodItem.PDF_Link__c != '' && prodItem.PDF_Link__c != null) {
    					if (!proditem.PDF_Link__c.contains('http')) {
    						proditem.PDF_Link__c = GetResourceURL(proditem.PDF_Link__c);
							System.debug('proditem.PDF_Link__c: ' + proditem.PDF_Link__c);
    					}
					}
				}

				// update cart line items with the Contact's name
				if( venueCartCtrl.cartId != null && venueCartCtrl.lineItems != null && venueCartCtrl.lineItems.size() > 0 )
				{
					Map<Id, OpportunityLineItem> oliMap;
					oliMap = new Map<Id, OpportunityLineItem>( [SELECT Contact__r.Name 
																	FROM OpportunityLineItem 
																	WHERE OpportunityId = :venueCartCtrl.cartId] );
					for( KGRenewal.Cart.LineItem item : venueCartCtrl.lineItems )
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
		}
	}
	/*****************************************************************************/
	// strips namespace
	public PageReference doSearch2() {
		return venueCtrl.doSearch();
	}
	/*****************************************************************************/
	//Apply the search term as a url parameter
	public PageReference doSearch3() {
		PageReference newPage = new PageReference(System.URL.getCurrentRequestUrl().getPath().replace('', '').replace('', ''));

		for (String m : ApexPages.CurrentPage().getParameters().keySet()) {
			if (!m.startsWith('j_id') && !m.startsWith('com.salesforce')) {
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
	public PageReference setProspectOppAsCart()	{
		PageReference pr;
		PageReference ncp = Page.NullCheckPage;
		pr = KGServiceClass.setProspectOppAsCart();
		if (pr.getURL() != ncp.getURL())
		{
			pr.setRedirect(TRUE);
			return pr;
		}
		return null;
		//return KGServiceClass.setProspectOppAsCart();
	}

	public PageReference back()
	{
		PageReference pr = null;
		if (theOpp.RecordTypeId != prospectRecordTypeId) { //This is a Member Renewal
			if (theOpp.Transition_Flag__c == true) {
				pr = null; // Marked to stay on the same page; Should never get here (See page Java Script)
			} else if (oContact.Lifetime_Dues_Status__c == 'Eligible for Lifetime') {
				pr = Page.LifetimeOption_ypo; //Send back to Lifetime page
			} else if (theOpp.Certification_Type__c == 'Self Certify') {
				pr = Page.Recertification_Screen; //YPO Certification
			} else if (theOpp.Certification_Type__c == 'Third Party Certify') {
				pr = Page.ThirdPartyCertification_screens_ypo;
			} else {
				pr = Page.Recertification_Screen;
			}

			if (pr != null) {
				pr.setRedirect(true);
				pr.getParameters().put('Id', contactId);
			}
		} else { // This must be a Prospect member
			pr = page.ChooseANetwork_YPO;
			pr.setRedirect(true);
			pr.getParameters().put('Id', contactId);
		}

		return pr;
	}

	public PageReference SaveAndContinue()
	{ //Item-07405
		PageReference pr = null;
		if (theOpp.RecordTypeId != prospectRecordTypeId) { //This is a Member Renewal
			System.debug('Not Prospect with Amount of: ' + theOpp.Amount);
			if (theOpp.Amount == 0) {
				//Send to Thankyou page
				Try {
					// Item-07484
					theOpp.Dues_Page_Status_Exchange__c = 'Complete';
					theOpp.StageName = 'Payment Received';
					update theOpp;

					pr = page.Splashscreen_Thankyou;
					pr.setRedirect(true);
					pr.getParameters().put('Id', oContact.Id);
				} catch(DmlException DmlEx) {
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Unable to update your Opportunity Cart record.  Please contact member Services! - ' + DmlEx.getDmlMessage(0)));
				}
			} else {
				//Send to Payment Screen
				try
				{
					theOpp.Dues_Page_Status_Exchange__c = 'In Progress';
					update theOpp;

					pr = Page.Checkout_Check_Wire_YPO;
					pr.setRedirect(true);
					if (!string.isBlank(theOpp.CartToken__c)) {
						pr.getParameters().put('ct', EncodingUtil.urlDecode(theOpp.CartToken__c, 'UTF-8'));
					}
				}
				catch(DMLException DmlEx)
				{
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Unable to update your Opportunity Cart record.  Please contact member Services! - ' + DmlEx.getDmlMessage(0)));
				}
			}
		} else { // This must be a Prospect member
			try
			{
				theOpp.Dues_Page_Status_Exchange__c = 'In Progress';
				update theOpp;

				pr = page.ShoppingCart_YPO;
				pr.setRedirect(true);
			}
			catch(DMLException DmlEx)
			{
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Unable to update your Opportunity Cart record.  Please contact member Services! - ' + DmlEx.getDmlMessage(0)));
			}
		}
		return pr;
	}

	/*****************************************************************************/

	public KGRenewal.VenueCartController venueCartCtrl {get; set;}

	public Boolean hasTerm { get; set; }
	// Estimate Tax
	public String zipCode { get; set; }
	// Errors
	public String zipCodeError { get; set; }

	public Integer totalItemCount
	{
		get
		{
			Integer count = 0;
			for (KGRenewal.Cart.LineItem item : venueCartCtrl.lineItems)
			{
				count += Integer.valueOf(item.quantity);
			}
			return count;
		}
	}

	public void CatalogModel_CartContrl() {
		hasTerm = false;
		zipCodeError = null;
	}

	/**************************updateQuantity**************************/
	public String deleteItem { set; get; }
	public String urldeleteItem { set; get; }
	String urlItem;
	public void updateQuantity()
	{
		// used to load Prospect (record type) Opportunity if no Cart found
		PageReference pr1 = setProspectOppAsCart();
		system.debug('-------deleteItem--------' + deleteItem);

		urlItem = ApexPages.currentPage().getParameters().get('q');

		system.debug('-------urlItem--------' + urlItem);

		if (deleteItem<> null && deleteItem<> '')
		urlItem = deleteItem;


		if (String.isNotBlank(urlItem))
		{
			Id urlId = (Id) urlItem;
			//Decimal urlQuantity = Decimal.valueOf( urlItem.substringAfter(':') );
			for (KGRenewal.Cart.LineItem item : venueCartCtrl.lineItems)
			{
				if (item.recordId == urlId)
				{
					delete(item.record);
					//update( item.record );
					break;
				}
			}
		}
		showPopup();
	}
	public PageReference removeCatalgogItem() {
		updateQuantity();
		PageReference p = Page.Catalog_YPO;
		//p.getParameters().put('q', deleteItem);
		p.getParameters().put('q', urlItem);
		p.setRedirect(true);
		return p;
	}

	public PageReference closeCatalgogItem() {
		CatalogModel_CartContrl();
		PageReference p = Page.Catalog_YPO;
		p.setRedirect(true);
		return p;
	}


	/*****************************updateQuantity**********************/

	public boolean displayPopup { get; set; }

	public void closePopup() {
		displayPopup = false;
	}
	public void showPopup() {
		displayPopup = true;
	}

	public static String GetResourceURL(String resourceName) {
		//https://developer.salesforce.com/forums/?id=906F00000008vv5IAA
		String URLPath = '';
		List<StaticResource> resourceList = [
		   SELECT Name, NamespacePrefix, SystemModStamp
		   FROM StaticResource
		   WHERE Name = :resourceName];
        
		System.debug('resourceList.size: ' + resourceList.size());
		if (resourceList.size() == 1) {
			System.debug('resourceList[0].name: ' + resourceList[0].name);
		   String namespace = resourceList[0].NamespacePrefix;
		   URLPath = '/members/resource/'
			  + resourceList[0].SystemModStamp.getTime() + '/'
			  + (namespace != null && namespace != '' ? namespace + '__' : '')
			  + resourceName;
		}

		System.debug('URLPath: ' + URLPath);
		return URLPath;
 
	}

}