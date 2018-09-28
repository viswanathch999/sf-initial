public class GoldTransitionOption_YPO {
    
    public Contact oContact {set;get;}
    public Opportunity oOpp {set;get;}
    public String selectedDesiredWPORegion { get; set; }
    public String selectedDesiredWPOChapter { get; set; }
    public String selectedDesiredWPORegionName ;
    public List<SelectOption> desiredWPOChapters { get; set; }
    public Map<String,String> desiredWPORegionIdToRegionName;
    @TestVisible static final String TRANSITION_STATUS_OVERDUE = 'Scheduled for transition';
    @TestVisible Id oContactId;
    
    public Boolean transitionFlag {
        get{
                if(transitionFlag == null) {
                        transitionFlag = false;
                }
                return transitionFlag;
        }set;
    }
    public GoldTransitionOption_YPO(ApexPages.StandardController oStandardController){
		try {
			if((Contact)oStandardController.getRecord()!= new Contact()) {
				oContact = (Contact)oStandardController.getRecord();
				getContactThroughSOQL(oContact.id);
			} else {
				User oUser = [Select Id,ContactId from User where Id =: UserInfo.getUserId()];
				if (oUser.ContactId != null) {
					getContactThroughSOQL(oUser.ContactId);
				} else {
					throw new CustomException('No member contact record found!');
				}
			}
		} catch (CustomException Cexpt) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Cexpt.getMessage()));
			oContact = null;
		}
    }
    
    public void init(){
		if (oContact!=Null) {
			oOpp = ContactServices.getOpportunities(oContact);
			if (oOpp!=null) transitionFlag = oOpp.Transition_Flag__c;
		}
    }
    
    public List<SelectOption> desiredWPORegions { 
        get {
            if(desiredWPORegions == null) {
                desiredWPORegions = new List<SelectOption>();
                String defaultRegion = '';
                desiredWPORegionIdToRegionName = new Map<String, String>();
				// 7658 - added in Record_Type_Name__c = 'Chapter' And Status__c = 'Active'  
                for(Account eachAcc: [SELECT id, name FROM account WHERE TYPE = 'Region' AND Record_Type_Name__c = 'Chapter' AND Status__c = 'Active' AND Include_in_Directory__c = true ORDER BY Name]) {
					if (oContact!=null) {
						if(oContact.Account.ParentId == eachAcc.Id) { 
							defaultRegion = eachAcc.Id;
						}
					}
                    desiredWPORegions.add(new SelectOption(eachAcc.Id,eachAcc.Name));
                    desiredWPORegionIdToRegionName.put(eachAcc.Id,eachAcc.Name);
                }
                
                this.selectedDesiredWPORegion = defaultRegion;
            }
            filterRegionChapters();
            return desiredWPORegions;
        } 
        private set; 
    }
    
    public PageReference saveOpportunity() {
		PageReference pr = null;

		pr = Page.Recertification_Screen;
		pr.setRedirect(true);
		pr.getParameters().put('Id',oContact.Id);
        return pr;
    }
    
    public void filterRegionChapters() {        
        System.debug('--------filterRegionChapters()--------');        
        /*for(SelectOption eachOption :desiredWPORegions) {
            if(oContact.Account.ParentId == eachOption.getValue()) { 
                selectedDesiredWPORegion = eachOption.getValue();
                break;
            }
        } */
        desiredWPOChapters = new List<SelectOption>();
		desiredWPOChapters.add(new SelectOption('','Select Option'));
        String defaultWPOChapter;
        if(selectedDesiredWPORegion <> null)
            selectedDesiredWPORegionName = desiredWPORegionIdToRegionName.get(selectedDesiredWPORegion);

        for(Account eachAcc: [SELECT id,name FROM account WHERE ParentId = :selectedDesiredWPORegion AND Status__c != 'Dissolved' AND ( YPOI_Type__c = 'YPO Gold Chapter' OR Is_Integrated__c = true ) ORDER BY Name])
        {  

            if(selectedDesiredWPORegionName <> null && eachAcc.Name.containsIgnoreCase(selectedDesiredWPORegionName) && eachAcc.Name.containsIgnoreCase('At Large')){
                defaultWPOChapter = eachAcc.Id;
                selectedDesiredWPOChapter = defaultWPOChapter;
            }
            
            //2602
            //Type='Chapter' AND Name LIKE 'WPO%' 
            //AND Status__c = 'Active' AND New_Member_Status__c != 'Closed to New Members' ORDER BY Name]) {
            desiredWPOChapters.add(new SelectOption(eachAcc.Id,eachAcc.Name));
        }

        System.debug('*** here '+oOpp.Transition_Flag__c);

		if (oContact!=null) {
			if(oOpp.Transition_Flag__c){
				//selectedDesiredWPORegion = oContact.Account.ParentId;
				this.selectedDesiredWPOChapter = oContact.AccountId;
			}else
				this.selectedDesiredWPOChapter = defaultWPOChapter;
        
			system.debug('-------selectedDesiredWPORegion--------'+selectedDesiredWPORegion);
			system.debug('-------selectedDesiredWPOChapter--------'+selectedDesiredWPOChapter);        
		}
    }
    
    public List<OpportunityLineItem> createNewOLIs(Id accountId, Id opportunityId) {
        Date nextFiscal = FiscalDateUtility.startOfNextFiscal;
        List<Product2> products = [SELECT Id FROM Product2 WHERE Family = 'Chapter Dues' AND Account__c =: accountId AND Product_Type__c = 'Primary' AND Fiscal_Date_Start__c =: nextFiscal AND IsActive = true];
        List<OpportunityLineItem> olisToInsert = new List<OpportunityLineItem>();
        List<PricebookEntry> pbes = [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry WHERE Product2Id IN: products AND IsActive = true];
                
                System.debug('###products: ' + products);
                System.debug('###pbes: ' + pbes);
                
                Map<Id, Id> prodToPBE = new Map<Id, Id>();
                Map<Id, Decimal> prodToPBEPrice = new Map<Id, Decimal>();
                
                for(PricebookEntry pbe: pbes) {
                        prodToPBE.put(pbe.Product2Id, pbe.id);
                        prodToPBEPrice.put(pbe.Product2Id, pbe.UnitPrice);
                }
                        
                System.debug('###prodToPBE: ' + prodToPBE);
        for(Product2 prod: products) {
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId = opportunityId;
                oli.PricebookEntryid = prodToPBE.get(prod.Id);
                oli.Quantity = 1;
                oli.UnitPrice = prodToPBEPrice.get(prod.Id);
            olisToInsert.add(oli);
        }
        
        System.debug('###olisToInsert: ' + olisToInsert);
        return olisToInsert;
    }
    
    public PageReference saveDesiredWPOChapter() {
        
        system.debug('-------selectedDesiredWPORegion--------'+selectedDesiredWPORegion);
        system.debug('-------selectedDesiredWPOChapter--------'+selectedDesiredWPOChapter);
        System.debug('--TransitinFlag---' + oOpp.Transition_Flag__c+ ' ' + selectedDesiredWPOChapter + oOpp.accountId);
		//Removed old Chapter reference
        if(oOpp.Transition_Flag__c && selectedDesiredWPOChapter != oOpp.accountId){
            List<Account_Affiliation__c> oldchoiceToDelete = [Select Id From Account_Affiliation__c 
                                                                        Where Contact__c=:oContact.Id 
                                                                        AND Account__c = :oOpp.accountId
                                                                        AND Is_Primary__c=True AND isActive__c = False 
                                                                        AND Transfer_Flag__c = 'Renewal Transition' Limit 1];
            try{
                if(!oldChoiceToDelete.isEmpty()){
                    delete oldChoiceToDelete;
                }
            }catch(DMLException dmlex){
                //TODO What happens if failure of old selection 
            }                                                           
        }else if(oOpp.Transition_Flag__c){
            return saveOpportunity();
        }
        
        Id chapterAccountId;
        if(String.isBlank(selectedDesiredWPOChapter)) {
            chapterAccountId = [SELECT Id FROM Account WHERE Name = 'Needs Chapter' LIMIT 1].Id;
        } else{
            chapterAccountId = selectedDesiredWPOChapter;
        }
        Savepoint sp = Database.setSavepoint();
        if(oOpp != null) {
            Id previousChapterId = oOpp.AccountId;
            
            oOpp.Transition_Via_Renewal_Form__c = true;
            oOpp.Referred_by_Chapter__c = chapterAccountId;
            oOpp.accountId = chapterAccountId;
            oOpp.Chapter_Acceptance_Status__c = 'Pending';
            oOpp.Transition_Flag__c = true;
            oOpp.Certification_Status__c = 'Complete';
            oContact.AccountId = chapterAccountId;
            
            List<OpportunityLineItem> olisToDelete = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: oOpp.Id AND Product2.Account__c =: previousChapterId /*AND Product2.Account__r.Is_Integrated__c = false*/ AND Product2.Family = 'Chapter Dues'];
            List<OpportunityLineItem> olisToInsert = createNewOLIs(chapterAccountId, oOpp.Id);
            
            System.debug('###olisToDelete: ' + olisToDelete);
            
            try{ 
                delete olisToDelete;
                update oOpp;
                update oContact;
                insert olisToInsert;
               
               } catch (Exception oDmlException){
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Experienced an issue performing the data save. ' + oDmlException.getMessage()));
				   Database.rollback(sp);
                   return null;
               }
            
        }
        Account_Affiliation__c newAffiliation = new Account_Affiliation__c();
        newAffiliation.Account__c = chapterAccountId;
        newAffiliation.Start_Date__c = FiscalDateUtility.startOfNextFiscal;
        newAffiliation.Is_Primary__c = true;
        newAffiliation.IsActive__c = false;
        newAffiliation.Contact__c = oContact.Id;
        newAffiliation.Transfer_Flag__c = 'Renewal Transition';
        newAffiliation.RecordTypeId = Schema.SObjectType.Account_Affiliation__c.getRecordTypeInfosByName().get('Chapter').getRecordTypeId();
        try{
            
            System.debug('###inside insert: ' + newAffiliation);
            insert newAffiliation;
            newAffiliation.Chapter_Approval_Status__c = 'Pending';
            
            update newAffiliation;
        } catch (Exception oDmlException){
            System.debug('###oDmlException: ' + oDmlException);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getMessage()));
            Database.rollback(sp);       
            return null;
        }        
        //5570
        //return toLifeTimeOption();
        return saveOpportunity(); // returns page ref to the appropriate page
    }
    
    public PageReference toLifeTimeOption() {
        PageReference pageRef = Page.lifetimeoption_ypo;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;    
    }
    
    public PageReference WPOTransition(){
        PageReference pageRef = Page.WPOTransition;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;
    }
    
    public PageReference goBack(){
        PageReference pageRef;
        
        if ( oContact.Transition_Status__c == 'Scheduled for Transition' ) {
            pageRef = Page.UpdateProfileInfo_YPO;
            
        } else {
            pageRef = Page.Recertification_Screen;
            
		}
		pageRef.setRedirect(true);
        pageRef.getParameters().put('Id',oContact.Id);
        return pageRef;
    }
    
    public void getContactThroughSOQL(id oCont){
        oContact = [SELECT Name, LastName, Account.ParentId, Account.YPOI_Type__c, HouseHoldID__c, AccountId,YPO_WPO__c,Grace_Years_Available__c,
                        Is_Grace_Used__c, Grace_Years_Used__c, Title,Number_of_Employees1__c,Total_Employee_Compensation__c,Last_Renewals_Page__c,
                        Annual_Revenue__c, Enterprise_Value__c,Transition_Status__c,Number_of_Employees__c,Last_Renewals_Form__c,
                        Age_Current__c, Number_Years_a_Member__c,Lifetime_Dues_Status__c FROM Contact WHERE Id = :oCont];

    }
}