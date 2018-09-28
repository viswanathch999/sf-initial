public with sharing class SetProductServices {
	
	private final static string MEMBER = 'Member';
	private final static string HONORARY_MEMBER = 'Honorary Member';
	private final static string PROSPECT = 'Prospect';
	private final static string LIFE_TIME_PAID = 'Completed Payment Cycle';
	private final static string LIFE_TIME_PAYING = 'In Payment Cycle';
	
	public Opportunity opp {get; set;}
	public List<Error_Log__c> errorLogs {get {if(errorLogs == null) errorLogs = new List<Error_Log__c>(); return errorLogs; } set;}
	public Boolean processComplete {get; set;}
	
	
	//Item - 07042
	private List<PriceBookEntry> getallLifeTimeProductsPriceBookEnt{
		get{ 
			if(getallLifeTimeProductsPriceBookEnt == null)
				getallLifeTimeProductsPriceBookEnt = new List<PriceBookEntry>([Select Id, Product2Id, UnitPrice, Product2.Fiscal_Date_Start__c, Product2.Tier_Number__c, Product2.Country__c, Product2.Account__c from PriceBookEntry where Product2.isActive = true AND Product2.Family='Lifetime Dues' AND Product2.Product_Type__c='Paid in Full' AND IsActive = true]);
			return getallLifeTimeProductsPriceBookEnt; 
		}
		set;
	}
	  
	//Item - 07042
	private List<OpportunityLineItem> allYPOLifeTimePaidProducts(Opportunity oppty){
		List<OpportunityLineItem> ypoAnnualDueLines = new List<OpportunityLineItem>();
		
		for(PriceBookEntry pbe :getallLifeTimeProductsPriceBookEnt){
			ypoAnnualDueLines.add(new OpportunityLineItem(OpportunityId = opp.id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice, KGRenewal__ContractEffectiveDate__c = pbe.Product2.Fiscal_Date_Start__c));
		}
		return ypoAnnualDueLines;
	}
	
	/*
	//Item - 07042
	private List<OpportunityLineItem> allCountryDevaluationProducts(Opportunity oppty){
		List<OpportunityLineItem> ypoNextYearCountryDev = new List<OpportunityLineItem>();
		if(oppty.KGRenewal__Contact__r.Address1_Type__c != 'Home' && oppty.KGRenewal__Contact__r.Address2_Type__c != 'Home'){
			errorLogs.add(createErrorLog(oppty.Id, Label.No_Home_Business_Address));
			return ypoNextYearCountryDev;
		}
		
		if(oppty.KGRenewal__Contact__r.Address1_Type__c == 'Home') {
			for(PriceBookEntry pbe :getallYOPNextYearCountryDevaluationPriceBookEnt){
				if(oppty.KGRenewal__Contact__r.Member_Tier__c == pbe.Product2.Tier_Number__c && oppty.Fiscal_Date_Start__c != null && oppty.Fiscal_Date_Start__c == pbe.Product2.Fiscal_Date_Start__c && pbe.Product2.Country__c == oppty.KGRenewal__Contact__r.MailingCountry)
					ypoNextYearCountryDev.add(new OpportunityLineItem(OpportunityId = opp.id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice));
			}
		}
		
		else if(oppty.KGRenewal__Contact__r.Address2_Type__c == 'Home') {
			for(PriceBookEntry pbe :getallYOPNextYearCountryDevaluationPriceBookEnt){
				if(oppty.KGRenewal__Contact__r.Member_Tier__c == pbe.Product2.Tier_Number__c && oppty.Fiscal_Date_Start__c != null && oppty.Fiscal_Date_Start__c == pbe.Product2.Fiscal_Date_Start__c && pbe.Product2.Country__c == oppty.KGRenewal__Contact__r.OtherCountry)
					ypoNextYearCountryDev.add(new OpportunityLineItem(OpportunityId = opp.id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice));
			}
		}
		return ypoNextYearCountryDev;
	}
	
	private List<OpportunityLineItem> allCountryDevaluationProducts(Opportunity oppty, String memberTier) {
		List<OpportunityLineItem> ypoNextYearCountryDev = new List<OpportunityLineItem>();
		if(oppty.KGRenewal__Contact__r.Address1_Type__c != 'Home' && oppty.KGRenewal__Contact__r.Address2_Type__c != 'Home'){
			errorLogs.add(createErrorLog(oppty.Id, Label.No_Home_Business_Address));
			return ypoNextYearCountryDev;
		}
		
		if(oppty.KGRenewal__Contact__r.Address1_Type__c == 'Home') {
			for(PriceBookEntry pbe :getallYOPNextYearCountryDevaluationPriceBookEnt){
				if(memberTier == pbe.Product2.Tier_Number__c && oppty.Fiscal_Date_Start__c != null && oppty.Fiscal_Date_Start__c == pbe.Product2.Fiscal_Date_Start__c && pbe.Product2.Country__c == oppty.KGRenewal__Contact__r.MailingCountry)
					ypoNextYearCountryDev.add(new OpportunityLineItem(OpportunityId = opp.id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice));
			}
		}
		
		else if(oppty.KGRenewal__Contact__r.Address2_Type__c == 'Home') {
			for(PriceBookEntry pbe :getallYOPNextYearCountryDevaluationPriceBookEnt){
				if(memberTier == pbe.Product2.Tier_Number__c && oppty.Fiscal_Date_Start__c != null && oppty.Fiscal_Date_Start__c == pbe.Product2.Fiscal_Date_Start__c && pbe.Product2.Country__c == oppty.KGRenewal__Contact__r.OtherCountry)
					ypoNextYearCountryDev.add(new OpportunityLineItem(OpportunityId = opp.id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice));
			}
		}
		return ypoNextYearCountryDev;
	}
	*/

	//Item - 07042
	private List<OpportunityLineItem> allYPOHonoraryAnnualDuesProducts(Opportunity oppty){
		List<OpportunityLineItem> ypoAnnualDueLines = new List<OpportunityLineItem>();
		
		for(PriceBookEntry pbe :getallYPOAnnualDuesPriceBookEnt){
			
			if(oppty.Fiscal_Date_Start__c != null && oppty.Fiscal_Date_Start__c == pbe.Product2.Fiscal_Date_Start__c && pbe.Product2.Product_Type__c == 'Honorary')
				ypoAnnualDueLines.add(new OpportunityLineItem(OpportunityId = opp.id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice, KGRenewal__ContractEffectiveDate__c = pbe.Product2.Fiscal_Date_Start__c));
		}
		return ypoAnnualDueLines;
	}
  
	//Item - 07042
	private List<OpportunityLineItem> allYPOAnnualDuesProductsOnTier(Opportunity oppty){
		List<OpportunityLineItem> ypoAnnualDueLines = new List<OpportunityLineItem>();
		
		for(PriceBookEntry pbe :getallYPOAnnualDuesPriceBookEnt){
			if(oppty.KGRenewal__Contact__r.Member_Tier__c == pbe.Product2.Tier_Number__c && oppty.Fiscal_Date_Start__c != null && oppty.Fiscal_Date_Start__c == pbe.Product2.Fiscal_Date_Start__c && pbe.Product2.Product_Type__c != 'Honorary')
				ypoAnnualDueLines.add(new OpportunityLineItem(OpportunityId = opp.id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice, KGRenewal__ContractEffectiveDate__c = pbe.Product2.Fiscal_Date_Start__c));
		}
		
		return ypoAnnualDueLines;
	}
	
	//Item - 07042
	private List<OpportunityLineItem> allYPOAnnualDuesProductsOnTier(Opportunity oppty, String memberTier){
		List<OpportunityLineItem> ypoAnnualDueLines = new List<OpportunityLineItem>();
		
		for(PriceBookEntry pbe :getallYPOAnnualDuesPriceBookEnt){
			if(memberTier == pbe.Product2.Tier_Number__c && oppty.Fiscal_Date_Start__c != null && oppty.Fiscal_Date_Start__c == pbe.Product2.Fiscal_Date_Start__c && pbe.Product2.Product_Type__c != 'Honorary')
				ypoAnnualDueLines.add(new OpportunityLineItem(OpportunityId = opp.id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice, KGRenewal__ContractEffectiveDate__c = pbe.Product2.Fiscal_Date_Start__c));
		}
		
		return ypoAnnualDueLines;
	}
	
	//Item - 07042 && Item - 07044
	private List<PriceBookEntry> getallYPOAnnualDuesPriceBookEnt{
		get{
			if(getallYPOAnnualDuesPriceBookEnt == null)
				getallYPOAnnualDuesPriceBookEnt = new List<PriceBookEntry>([Select Id, Product2Id, UnitPrice, Product2.Fiscal_Date_Start__c, Product2.Tier_Number__c, Product2.Product_Type__c from PriceBookEntry where Product2.isActive = true AND Product2.Family = 'Annual Dues' AND Product2.Country__c = '' AND IsActive = true]);
			return getallYPOAnnualDuesPriceBookEnt; 
		}
		set;
	}
	
	/*
	//Item - 07043
	private List<PriceBookEntry> getallYOPNextYearCountryDevaluationPriceBookEnt{
		get{
			if(getallYOPNextYearCountryDevaluationPriceBookEnt == null)
				getallYOPNextYearCountryDevaluationPriceBookEnt = new List<PriceBookEntry>([Select Id, Product2Id, UnitPrice, Product2.Fiscal_Date_Start__c, Product2.Tier_Number__c, Product2.Country__c from PriceBookEntry where Product2.isActive = true AND Product2.Country__c != '' AND IsActive = true]);
			
			return getallYOPNextYearCountryDevaluationPriceBookEnt; 
		}
		set;
	}
	*/
		
	//Item - 07043
	private List<OpportunityLineItem> allYPOAnnualDuesProducts(Opportunity oppty){
		List<OpportunityLineItem> ypoAnnualDueLines = new List<OpportunityLineItem>();
		
		for(PriceBookEntry pbe :getallYPOAnnualDuesPriceBookEnt){
			if(oppty.KGRenewal__Contact__r.Member_Tier__c == pbe.Product2.Tier_Number__c && oppty.Fiscal_Date_Start__c != null && oppty.Fiscal_Date_Start__c.addYears(1) == pbe.Product2.Fiscal_Date_Start__c && pbe.Product2.Product_Type__c != 'Honorary')
				ypoAnnualDueLines.add(new OpportunityLineItem(OpportunityId = opp.id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice, KGRenewal__ContractEffectiveDate__c = pbe.Product2.Fiscal_Date_Start__c));
		}
		
		return ypoAnnualDueLines;
	}

	/*
	//Item - 07043 
	private List<OpportunityLineItem> allNextYearCountryDevaluationProducts(Opportunity oppty){
		List<OpportunityLineItem> ypoNextYearCountryDev = new List<OpportunityLineItem>();
		if(oppty.KGRenewal__Contact__r.Address1_Type__c != 'Home' && oppty.KGRenewal__Contact__r.Address2_Type__c != 'Home'){
			errorLogs.add(createErrorLog(oppty.Id, Label.No_Home_Business_Address));
			return ypoNextYearCountryDev;
		}
		
		if(oppty.KGRenewal__Contact__r.Address1_Type__c == 'Home') {
			for(PriceBookEntry pbe :getallYOPNextYearCountryDevaluationPriceBookEnt){
				if(oppty.KGRenewal__Contact__r.Member_Tier__c == pbe.Product2.Tier_Number__c && oppty.Fiscal_Date_Start__c != null && oppty.Fiscal_Date_Start__c.addYears(1) == pbe.Product2.Fiscal_Date_Start__c && pbe.Product2.Country__c == oppty.KGRenewal__Contact__r.MailingCountry)
					ypoNextYearCountryDev.add(new OpportunityLineItem(OpportunityId = opp.id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice));
			}
		}
		
		else if(oppty.KGRenewal__Contact__r.Address2_Type__c == 'Home') {
		   for(PriceBookEntry pbe :getallYOPNextYearCountryDevaluationPriceBookEnt){
				if(oppty.KGRenewal__Contact__r.Member_Tier__c == pbe.Product2.Tier_Number__c && oppty.Fiscal_Date_Start__c != null && oppty.Fiscal_Date_Start__c.addYears(1) == pbe.Product2.Fiscal_Date_Start__c && pbe.Product2.Country__c == oppty.KGRenewal__Contact__r.OtherCountry)
					ypoNextYearCountryDev.add(new OpportunityLineItem(OpportunityId = opp.id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice));
			}
		}
		
		return ypoNextYearCountryDev;
	}
	*/
	
	//Item - 07044
	private List<PriceBookEntry> getallPrimaryChapterProductsPriceBookEnt{
		get{ 
			if(getallPrimaryChapterProductsPriceBookEnt == null)
				getallPrimaryChapterProductsPriceBookEnt = new List<PriceBookEntry>([Select Id, Product2Id, UnitPrice, Product2.Fiscal_Date_Start__c,  Product2.Country__c, Product2.Account__c, Product2.Chapter_Dues__c from PriceBookEntry where Product2.isActive = true AND Product2.Family='Chapter Dues' AND Product2.Product_Type__c='Primary' AND IsActive = true]);
			
			return getallPrimaryChapterProductsPriceBookEnt; 
		}
		set;
	}
	
	//Item - 07044
	private List<PriceBookEntry> getallSecondaryChapterProductsPriceBookEnt{
		get{ 
			if(getallSecondaryChapterProductsPriceBookEnt == null)
				getallSecondaryChapterProductsPriceBookEnt = new List<PriceBookEntry>([Select Id, Product2Id, UnitPrice, Product2.Fiscal_Date_Start__c,  Product2.Country__c, Product2.Account__c from PriceBookEntry where Product2.isActive = true AND Product2.Family='Chapter Dues' AND Product2.Product_Type__c='Secondary' AND IsActive = true]);
			return getallSecondaryChapterProductsPriceBookEnt; 
		}
		set;
	}
	
	//Item-07045
	private List<PriceBookEntry> getallUniversalMemberBenefitPriceBookEntry{
		get{
			if(getallUniversalMemberBenefitPriceBookEntry == null)
				getallUniversalMemberBenefitPriceBookEntry = new List<PriceBookEntry>([Select Id, Product2Id, UnitPrice, Product2.Fiscal_Date_Start__c from PriceBookEntry where Product2.isActive = true AND Product2.YPO_Universal_Member_Benefit__c = true AND IsActive = true]);
			return getallUniversalMemberBenefitPriceBookEntry; 
		}
		set;
	}
	//Item-07045
	private List<OpportunityLineItem> allYPOUniversalMemberProducts(Opportunity oppty){
		List<OpportunityLineItem> ypoMemberBenefitLines = new List<OpportunityLineItem>();
		for(PriceBookEntry pbe :getallUniversalMemberBenefitPriceBookEntry){
			//US8721 - Limit Benefit products to the Opportunity Current and Next Fiscal Start Date for Prospects
			if (oppty.Opportunity_Type__c == PROSPECT && (oppty.Fiscal_Date_Start__c == pbe.Product2.Fiscal_Date_Start__c || oppty.Fiscal_Date_Start__c.addYears(1) == pbe.Product2.Fiscal_Date_Start__c)) {
				ypoMemberBenefitLines.add(new OpportunityLineItem(OpportunityId = oppty.id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice, KGRenewal__ContractEffectiveDate__c = pbe.Product2.Fiscal_Date_Start__c));
			} else {
				//US8721 - Limit Benefit products to the Opportunity Fiscal Start Date.
				if (oppty.Fiscal_Date_Start__c == pbe.Product2.Fiscal_Date_Start__c) {
					ypoMemberBenefitLines.add(new OpportunityLineItem(OpportunityId = oppty.id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice, KGRenewal__ContractEffectiveDate__c = pbe.Product2.Fiscal_Date_Start__c));
				}
			}
		}
		return ypoMemberBenefitLines;
	}
	
	
	
	
	//Item - 07046
	private List<PriceBookEntry> getAnnualDuesInitiationPriceBookEnt{
		get{
			if(getAnnualDuesInitiationPriceBookEnt == null)
				getAnnualDuesInitiationPriceBookEnt = new List<PriceBookEntry>([Select Id, Product2Id, UnitPrice, Product2.Fiscal_Date_Start__c, Product2.Tier_Number__c, Product2.Product_Type__c from PriceBookEntry where Product2.isActive = true AND Product2.Family = 'Annual Dues' AND Product2.Product_Type__c = 'Initiation' AND IsActive = true]);
			return getAnnualDuesInitiationPriceBookEnt; 
		}
		set;
	}
	//Item - 07046
	private List<OpportunityLineItem> allYPOAnnualDuesInitiationProducts(Opportunity oppty){
		List<OpportunityLineItem> ypoAnnualDueLines = new List<OpportunityLineItem>();
		
		for(PriceBookEntry pbe :getAnnualDuesInitiationPriceBookEnt){
			if(oppty.Fiscal_Date_Start__c != null && oppty.Fiscal_Date_Start__c == pbe.Product2.Fiscal_Date_Start__c)
				ypoAnnualDueLines.add(new OpportunityLineItem(OpportunityId = opp.id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice, KGRenewal__ContractEffectiveDate__c = pbe.Product2.Fiscal_Date_Start__c));
		}
		
		return ypoAnnualDueLines;
	}
	
	//Item - 07047
	private List<PriceBookEntry> getallChapterProductsPriceBookEnt{
		get{ 
			if(getallChapterProductsPriceBookEnt == null)
				getallChapterProductsPriceBookEnt = new List<PriceBookEntry>([Select Id, Product2Id, UnitPrice, Product2.Fiscal_Date_Start__c, Product2.Tier_Number__c, Product2.Country__c, Product2.Account__c from PriceBookEntry where Product2.isActive = true AND Product2.Family='Chapter Dues' AND Product2.Product_Type__c='Primary Initiation' AND IsActive = true]);
			
			return getallChapterProductsPriceBookEnt; 
		}
		set;
	}
	
	private List<OpportunityLineItem> allChapterInitiationFeesForProspects(Opportunity oppty, List<Account_Affiliation__c> relatedAccAff) {
		List<OpportunityLineItem> ypoChapterInitiationProducts = new List<OpportunityLineItem>();
		for(PriceBookEntry pbe :getallChapterProductsPriceBookEnt){
			for(Account_Affiliation__c accAff : relatedAccAff) {
				if(pbe.Product2.Account__c == accAff.Account__c && pbe.Product2.Fiscal_Date_Start__c == oppty.Fiscal_Date_Start__c){
					ypoChapterInitiationProducts.add(new OpportunityLineItem(OpportunityId = opp.id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice, KGRenewal__ContractEffectiveDate__c = pbe.Product2.Fiscal_Date_Start__c));
				}
			}
		}
		return ypoChapterInitiationProducts;
	}
	
	// Item - 07047
	private List<OpportunityLineItem> addchapterProducts(Opportunity oppty, List<Account_Affiliation__c> relatedAccAff){
		List<OpportunityLineItem> ypoChapterProducts = new List<OpportunityLineItem>();
		for(PriceBookEntry pbe :getallPrimaryChapterProductsPriceBookEnt){
			for(Account_Affiliation__c accAff : relatedAccAff) {
				//Account from Product never equals Account from Account Affliation Start Dates are a year apart
				if(pbe.Product2.Account__c == accAff.Account__c && pbe.Product2.Fiscal_Date_Start__c == oppty.Fiscal_Date_Start__c){
					if(isProspect(oppty) && (pbe.Product2.Chapter_Dues__c == 'All Members' ||  pbe.Product2.Chapter_Dues__c == 'New Members Only')){
						ypoChapterProducts.add(new OpportunityLineItem(OpportunityId = opp.id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice, KGRenewal__ContractEffectiveDate__c = pbe.Product2.Fiscal_Date_Start__c));
					}else if((isMember(oppty) || isHonoraryMember(oppty) || isSpouseMember(oppty)) && (pbe.Product2.Chapter_Dues__c == 'All Members' ||  pbe.Product2.Chapter_Dues__c == 'Renewing Members only')){
						ypoChapterProducts.add(new OpportunityLineItem(OpportunityId = opp.id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice, KGRenewal__ContractEffectiveDate__c = pbe.Product2.Fiscal_Date_Start__c));
					}                
				}
			}
		}
		return ypoChapterProducts;
	}
	
	// Item - 07047
	private List<OpportunityLineItem> addSecondaryChapterProducts(Opportunity oppty, List<Account_Affiliation__c> relatedAccAff){
		List<OpportunityLineItem> ypoSecondaryChapterProducts = new List<OpportunityLineItem>();
		for(PriceBookEntry pbe :getallSecondaryChapterProductsPriceBookEnt){
			for(Account_Affiliation__c accAff : relatedAccAff) {
				if(pbe.Product2.Account__c == accAff.Account__c && pbe.Product2.Fiscal_Date_Start__c == oppty.Fiscal_Date_Start__c){
					if(isMember(oppty) || isHonoraryMember(oppty) || isSpouseMember(oppty) && ((pbe.Product2.Chapter_Dues__c == 'All Members' ||  pbe.Product2.Chapter_Dues__c == 'Renewing Members'))){
						ypoSecondaryChapterProducts.add(new OpportunityLineItem(OpportunityId = opp.id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice, KGRenewal__ContractEffectiveDate__c = pbe.Product2.Fiscal_Date_Start__c));					
					}
				}
			}
		}
		return ypoSecondaryChapterProducts;
	}
	
	// Item - 07047
	private List<OpportunityLineItem> addNextYearChapterProducts(Opportunity oppty, List<Account_Affiliation__c> relatedAccAff){
		List<OpportunityLineItem> ypoChapterProducts = new List<OpportunityLineItem>();
		for(PriceBookEntry pbe :getallPrimaryChapterProductsPriceBookEnt){
			for(Account_Affiliation__c accAff : relatedAccAff) {
				if(pbe.Product2.Account__c == accAff.Account__c && pbe.Product2.Fiscal_Date_Start__c == oppty.Fiscal_Date_Start__c.addYears(1)){
					if(isQ4Prospect(oppty) && (pbe.Product2.Chapter_Dues__c == 'All Members' ||  pbe.Product2.Chapter_Dues__c == 'New Members Only')){
						ypoChapterProducts.add(new OpportunityLineItem(OpportunityId = opp.id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice, KGRenewal__ContractEffectiveDate__c = pbe.Product2.Fiscal_Date_Start__c));					
					}
				}
			}
		}
		return ypoChapterProducts;
	}
	
	
	
	public SetProductServices(ApexPages.StandardController controller) {
		this.opp = [SELECT Id, AccountId, Opportunity_Type__c, KGRenewal__Contact__c, Fiscal_Date_Start__c, 
					KGRenewal__Contact__r.HouseholdID__c, KGRenewal__Contact__r.Membership_Status__c, KGRenewal__Contact__r.MailingCountry, 
					KGRenewal__Contact__r.OtherCountry, KGRenewal__Contact__r.Address1_Type__c,KGRenewal__Contact__r.Address2_Type__c, 
					KGRenewal__Contact__r.Is_Spouse_Member__c, KGRenewal__Contact__r.Lifetime_Dues_Status__c, Created_in_Fiscal_Q4__c, KGRenewal__Contact__r.Member_Tier__c
					FROM Opportunity WHERE Id = :controller.getId() ];
		processComplete = false;
	}
	
	//Dummy function for a button on the page.
    public void saveOpp() {   

    }
    
	public void deleteCurrentProducts(List<Opportunity> opps) {
		List<OpportunityLineItem> opportunityProducts = new List<OpportunityLineItem>([SELECT Id FROM OpportunityLineItem WHERE OpportunityId IN :opps AND Product2.Family != 'Lifetime Dues' AND Product2.Product_Type__c != 'Installment']);
		try {
			delete opportunityProducts;
		}
		catch (DMLException ex) {
			for( Integer errorIndex = 0; errorIndex < ex.getNumDml(); errorIndex++ )
			{
				for(Opportunity errorOpp: opps){
					errorLogs.add(ErrorLogUtil.createErrorLogWithOppLookup('Set Products', String.valueOf(errorOpp.Id), ex.getDmlMessage(errorIndex), errorOpp.Id));
				}
			}
		}
	}
	
	public void updateOpportunities(List<Opportunity> listOfOpportunities) {
		
		try {
			List<Database.saveResult> saveResult = Database.update(listOfOpportunities,false);
			for(Database.saveResult sr : saveResult) {
				if(!sr.isSuccess()){
					String errorMessages = '';
					for(Database.Error err : sr.getErrors()) {
						errorMessages += err.getMessage() + ' ';
					}
					errorLogs.add(createErrorLog(sr.getId(), errorMessages));
				}
			} 
			if(!errorLogs.isEmpty()) {
				ErrorLogUtil.insertErrorLogs(errorLogs);
			}
		}
		catch(Exception ex) {
			System.debug('Catastrophic error in updateOpportunities(): '+ex);
			for( Integer errorIndex = 0; errorIndex < ex.getNumDml(); errorIndex++ )
			{
				for(Opportunity errorOpp: listOfOpportunities){
					errorLogs.add(ErrorLogUtil.createErrorLogWithOppLookup('Set Products', String.valueOf(errorOpp.Id), ex.getDmlMessage(errorIndex), errorOpp.Id));
				}
			}
		}
	}
	
	public void insertOpportunitiyLine(List<OpportunityLineItem> listOfOpportunityLines) {
		
		try {
			List<Database.saveResult> saveResult = Database.insert(listOfOpportunityLines,false);
			for(Database.saveResult sr : saveResult) {
				if(!sr.isSuccess()){
					String errorMessages = '';
					for(Database.Error err : sr.getErrors()) {
						errorMessages += err.getMessage() + ' ';
					}
					errorLogs.add(createErrorLog(sr.getId(), errorMessages));
				}
			} 
			if(!errorLogs.isEmpty()) {
				ErrorLogUtil.insertErrorLogs(errorLogs);
			}
		}
		catch(Exception ex) {
			System.debug('Catastrophic error in insertOpportunityLineItem(): '+ex);
			for( Integer errorIndex = 0; errorIndex < ex.getNumDml(); errorIndex++ )
			{
				for(OpportunityLineItem errorOpp: listOfOpportunityLines){
					errorLogs.add(ErrorLogUtil.createErrorLogWithOppLookup('Set Products', String.valueOf(errorOpp.Id), ex.getDmlMessage(errorIndex), errorOpp.Id));
				}
			}
		}
	}
	
	public static Error_Log__c createErrorLog(Id oppId, String errorMessage) {
		return ErrorLogUtil.createErrorLogWithOppLookup('Set Products', oppId, errorMessage, oppId);
	}
	 
	public void flowControl() {
		List<Opportunity> opps = new List<Opportunity>();
		opps.add(opp);
		flowControl(opps);
	}
	
	public void flowControl(List<Opportunity> listOfOpps) {
		Savepoint sp = Database.setSavepoint();
		List<OpportunityLineItem> lineItemsToInsert = new List<OpportunityLineItem>();
		try {       
			deleteCurrentProducts(listOfOpps);
			
			List<String> householdIds = new List<String>();
			List<Id> contactIds = new List<Id>();
			Map<Id, Id> oppIdToContactId = new Map<Id,Id>();
			for(Opportunity oppty : listOfOpps){
				householdIds.add(oppty.KGRenewal__Contact__r.HouseholdID__c);
				contactIds.add(oppty.KGRenewal__Contact__c);
				oppIdToContactId.put(oppty.Id, oppty.KGRenewal__Contact__c);
			}
			// query for AAs 
			List<Account_Affiliation__c> allAccAffPrim = new List<Account_Affiliation__c>();
			List<Account_Affiliation__c> allAccAffSec = new List<Account_Affiliation__c>();
			List<Account_Affiliation__c> allProspectAccAff = new List<Account_Affiliation__c>();																	  
			List<Account_Affiliation__c> allAccAff = new List<Account_Affiliation__c>([SELECT Account__c, Contact__c, Contact__r.RecordType.DeveloperName, IsActive__c, Is_Primary__c, Transfer_Flag__c, End_Date__c, Type__c
																					   FROM Account_Affiliation__c 
																					   WHERE Contact__c IN :contactIds AND Type__c='Chapter' ]);
																   
			for(Account_Affiliation__c accAff : allAccAff) {
				System.debug('AcctAff Record: ' + accAff.Contact__r.RecordType.DeveloperName + '/' + accAff.Type__c + '/' + accAff.Is_Primary__c + '/' + accAff.IsActive__c);
				if(accAff.IsActive__c && accAff.Is_Primary__c && accAff.Type__c == 'Chapter') {
					allAccAffPrim.add(accAff);
				}
				
				if(accAff.IsActive__c && !accAff.Is_Primary__c && accAff.Type__c == 'Chapter') {
					allAccAffSec.add(accAff);
				}
				
				if(accAff.Contact__r.RecordType.DeveloperName == 'Prospect' && accAff.Type__c == 'Chapter' && accAff.Is_Primary__c && !accAff.IsActive__c) {
					allProspectAccAff.add(accAff);
				}
			}
			
			
			//Con relationship
			List<Relationship__c> relationships = new List<Relationship__c>([SELECT Id, Account__c, Contact__c, Contact__r.Membership_Status__c, Contact__r.Lifetime_Dues_Status__c, Contact__r.Member_Tier__c, Relationship_Type__c FROM Relationship__c WHERE Contact__c IN: contactIds AND Relationship_Type__c != 'Child']);

			List<Relationship__c> memberRelsAlt = new List<Relationship__c>([SELECT Id, Account__c, Contact__c, Contact__r.Membership_Status__c,Contact__r.Lifetime_Dues_Status__c, Contact__r.Member_Tier__c, Relationship_Type__c FROM Relationship__c WHERE Account__c IN: Pluck.Ids('Account__c', relationships) AND Relationship_Type__c = 'Member']);

			Map<Id, List<Relationship__c>> householdAccIdToRels = GroupBy.Ids('Account__c', memberRelsAlt);
			Map<Id, List<Relationship__c>> conIdToRels = GroupBy.Ids('Contact__c', relationships);
			//Map OppId -> Contact
			//Map HouseholdId -> List Rels
			//Map ConId -> List Rels
			
			for(Opportunity oppty : listOfOpps){
				
				List<Contact> relCons = new List<Contact>();
				Id con = oppIdToContactId.get(oppty.Id);
				Id householdAccId = conIdToRels.get(con)[0].Account__c;
				for(Relationship__c rel : conIdToRels.get(con)) {
					if(rel.Relationship_Type__c == 'Spouse/Partner') {
						householdAccId = rel.Account__c;
					}
				}
				for(Relationship__c rel : householdAccIdToRels.get(householdAccId)) {
					if((rel.Contact__r.Membership_Status__c == 'Member' || rel.Contact__r.Membership_Status__c == 'Resigned') && rel.Contact__r.Lifetime_Dues_Status__c == 'Completed Payment Cycle') {
						
						Contact relCon = new Contact();
						relCon.Id = rel.Contact__c;
						relCon.Membership_Status__c = rel.Contact__r.Membership_Status__c;
						relCon.Lifetime_Dues_Status__c = rel.Contact__r.Lifetime_Dues_Status__c;
						relCons.add(relCon);
					}
				}
				
				
				String survivingSPTier;
				Boolean isLifetimePaidSurvivingSP = false;
				Boolean isLifetimePayingSurvivingSP = false;
				
				if(isSurvivingSpousePartner(oppty)) {
					for(Relationship__c rel : memberRelsAlt){
						if(rel.Account__c == householdAccId) {
							survivingSPTier = rel.Contact__r.Member_Tier__c;                    
							isLifetimePaidSurvivingSP = rel.Contact__r.Lifetime_Dues_Status__c == LIFE_TIME_PAID;                    
							isLifetimePayingSurvivingSP = rel.Contact__r.Lifetime_Dues_Status__c == LIFE_TIME_PAYING;                    
						}
					}
				} 
				List<Account_Affiliation__c> relatedPrimaryAccAffs = new List<Account_Affiliation__c>();
				for(Account_Affiliation__c accAff : allAccAffPrim){
					if(oppty.KGRenewal__Contact__c == accAff.Contact__c) {
						relatedPrimaryAccAffs.add(accAff);
					}
				}
				
				List<Account_Affiliation__c> relatedSecondaryAccAffs = new List<Account_Affiliation__c>();
				for(Account_Affiliation__c accAff : allAccAffSec){
					if(oppty.KGRenewal__Contact__c == accAff.Contact__c) {
						relatedSecondaryAccAffs.add(accAff);
					}
				}
				
				List<Account_Affiliation__c> relatedProspectAccAffs = new List<Account_Affiliation__c>();
				for(Account_Affiliation__c accAff : allProspectAccAff){
					if(oppty.KGRenewal__Contact__c == accAff.Contact__c) {
						relatedProspectAccAffs.add(accAff);
					}
				}                                                              
				
				if( isHonoraryMember(oppty) ) {  
					lineItemsToInsert.addAll(allYPOHonoraryAnnualDuesProducts(oppty));
				} 
				else if( ( isSurvivingSpousePartner(oppty) || isMember(oppty) ) && (isLifetimePaid(oppty) || isSurvivingSpousePartnerLifeTime(oppty, relCons))) {      // (I OR A) AND G
					lineItemsToInsert.addAll(allYPOLifeTimePaidProducts(oppty));
				} 
				else if(isLifetimeStillPaying(oppty) || isLifetimePayingSurvivingSP){                                                            // F
					errorLogs.add(createErrorLog(oppty.Id, Label.No_Lifetime_Product));
				} 
				else {
					 if(survivingSPTier == null)
						lineItemsToInsert.addAll(allYPOAnnualDuesProductsOnTier(oppty));
					 
					 else
						lineItemsToInsert.addAll(allYPOAnnualDuesProductsOnTier(oppty, survivingSPTier));
				
				}
				
				//Item-7600 removal of Devaluation product loads
				//if((isMember(oppty) || isSpouseMember(oppty) || isSurvivingSpousePartner(oppty)) && (!isLifetimePaid(oppty) && !isLifetimeStillPaying(oppty) && !isLifetimePayingSurvivingSP && !isLifetimePaidSurvivingSP)) {
					//if(survivingSPTier == null)
						//lineItemsToInsert.addAll(allCountryDevaluationProducts(oppty));
						
					//else 
						//lineItemsToInsert.addAll(allCountryDevaluationProducts(oppty, survivingSPTier));
				   
				//}
				
				if(isQ4Prospect(oppty)) {
					// Add Next Fy Annual Due based on Tier //Item - 07043
					lineItemsToInsert.addAll(allYPOAnnualDuesProducts(oppty));
					// Add Next Year Country Deval based on Home Address //Item - 07043
					//lineItemsToInsert.addAll(allNextYearCountryDevaluationProducts(oppty)); //Item-7600 removal of Devaluation product loads
					// Add Next Year Chapter Due
					if(allProspectAccAff.size() == 1)
						lineItemsToInsert.addAll(addNextYearChapterProducts(oppty,allProspectAccAff));
					else {
						//errorLogs.add(createErrorLog(oppty.Id, Label.One_Primary_AA));
					}
				}
				if(!isProspect(oppty)) {  
					if(relatedPrimaryAccAffs.size() == 1) {
						lineItemsToInsert.addAll(addchapterProducts(oppty,relatedPrimaryAccAffs));
					} else {
						errorLogs.add(createErrorLog(oppty.Id, Label.One_Primary_AA));
					}
				}

				if(isProspect(oppty)) {                                                                 // C
					//ProspectChapterDues
					lineItemsToInsert.addAll(addchapterProducts(oppty, relatedProspectAccAffs));
					//YPO Initiation Fee
					lineItemsToInsert.addAll(allYPOAnnualDuesInitiationProducts(oppty));
					//Chapter Initiation Fee
					lineItemsToInsert.addAll(allChapterInitiationFeesForProspects(oppty, relatedProspectAccAffs));
					
				}
				if( !( isSurvivingSpousePartner(oppty) || isSurvivingSpousePartnerLifeTime(oppty, relCons) ) ) {          //  NOT (H OR I)
					List<OpportunityLineItem> ypoUniversalMemberBenefitProducts = allYPOUniversalMemberProducts(oppty);
					if(ypoUniversalMemberBenefitProducts.size() > 0)
						lineItemsToInsert.addAll(ypoUniversalMemberBenefitProducts);
				
				}


				lineItemsToInsert.addAll(addSecondaryChapterProducts(oppty,relatedSecondaryAccAffs));
				oppty.KGRenewal__IsActiveCart__c = true;
			}
			
			updateOpportunities(listOfOpps);
			if(lineItemsToInsert.size() > 0) {
				Set<OpportunityLineItem> oppLineItemSet = new Set<OpportunityLineItem>(lineItemsToInsert);
				insertOpportunitiyLine(new List<OpportunityLineItem>(oppLineItemSet));
				
			}    
			if(errorLogs.isEmpty()) {
				ApexPages.Message successMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Set products was successful!');
				ApexPages.addMessage(successMsg);
			}
			else {
				for(Error_Log__c errLg : errorLogs) {
					ApexPages.Message failMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errLg.Error_String__c);
					ApexPages.addMessage(failMsg);
				}
			}
			processComplete = true;
			
		}
		catch(Exception ex) {
			System.debug('**** ' + ex + ' ' + ex.getLineNumber());
			Database.rollback(sp);
			for(Error_Log__c errLg : errorLogs) {
				ApexPages.Message failMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errLg.Error_String__c);
				ApexPages.addMessage(failMsg);
			}
			processComplete = true;
		}
	}
	
	private boolean isMember(Opportunity oppty){
		return oppty.KGRenewal__Contact__r.Membership_Status__c == MEMBER;
	}
	
	private boolean isHonoraryMember(Opportunity oppty){
		return oppty.KGRenewal__Contact__r.Membership_Status__c == HONORARY_MEMBER;
	}
	
	private boolean isProspect(Opportunity oppty){
		return oppty.KGRenewal__Contact__r.Membership_Status__c == PROSPECT;
	}
	
	private boolean isQ4Prospect(Opportunity oppty){
		return oppty.KGRenewal__Contact__r.Membership_Status__c == PROSPECT && oppty.Created_in_Fiscal_Q4__c;
	}
	
	private boolean isSpouseMember(Opportunity oppty){
		return oppty.KGRenewal__Contact__r.Membership_Status__c == MEMBER && oppty.KGRenewal__Contact__r.Is_Spouse_Member__c;
	}
	
	private boolean isLifetimeStillPaying(Opportunity oppty){
		return oppty.KGRenewal__Contact__r.Lifetime_Dues_Status__c == LIFE_TIME_PAYING;
	}
	
	private boolean isLifetimePaid(Opportunity oppty){
		return oppty.KGRenewal__Contact__r.Lifetime_Dues_Status__c == LIFE_TIME_PAID;
	}
	
	private boolean isSurvivingSpousePartner(Opportunity oppty){
		return oppty.KGRenewal__Contact__r.Membership_Status__c == 'Surviving Spouse/Partner';
	}
	
	private boolean isSurvivingSpousePartnerLifeTime(Opportunity oppty, List<Contact> relatedMembersOfHousehold){
		if(oppty.KGRenewal__Contact__r.Membership_Status__c == 'Surviving Spouse/Partner'){
			if(relatedMembersOfHousehold != null && !relatedMembersOfHousehold.isEmpty()) {
				return true;
			}
		}
		return false;
	}
}