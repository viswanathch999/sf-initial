public class CustomAddressExtension {
	
	public Account_Affiliation__c AA {get; set;}
	public Account dummyAcct {get; set;}
	private ID recordId;
	private Boolean isUpdate = false;

	public customAddressExtension(ApexPages.StandardController stdController) {
		this.AA = (Account_Affiliation__c)stdController.getRecord();

		if(ApexPages.currentPage().getParameters().containsKey('Id')){
			recordId = ApexPages.currentPage().getParameters().get('Id');
			isUpdate = true;
		}else{
			this.AA.Contact__c = ApexPages.currentPage().getParameters().get('contactId');
			this.AA.Account__c = ApexPages.currentPage().getParameters().get('accountId');		
		}

		if(recordId != null){
			this.AA = [Select Id, Account__c, Contact__c, Contact__r.FirstName, Job_Title__c, Title_Other__c, Company_Name__c, Description__c, Is_Primary__c, Founded_In__c, Order__c, Company_Size__c,
					   IsPublic__c, Organization_Type__c, IsActive__c, Business_Role__c, Start_Date__c, Scope_of_Business__c, End_Date__c, Reason_for_Leaving__c, Website__c,
					   Is_Youth_Internship__c, Industry_Category_1__c, Industry_Category_3__c, Industry_Sub_Category_1__c, Industry_Sub_Category_3__c, Industry_Category_2__c, Industry_Sub_Category_2__c,
					   Street__c, City__c, Postal_Code__c, Country__c, Country_Code__c, State__c, State_Code__c From Account_Affiliation__c where ID = :recordId];					
		}

		if(ApexPages.currentPage().getParameters().get('cancelURL') != NULL){
			this.AA.Contact__c = ApexPages.currentPage().getParameters().get('cancelURL').remove('/');
		}
		this.dummyAcct = new Account(BillingCountryCode = this.AA.Country_Code__c, BillingStateCode = this.AA.State_Code__c,
											BillingCountry = this.AA.Country__c, BillingState = this.AA.State__c);

	}

	public Account_Affiliation__c getAA(Account_Affiliation__c AA){
		this.AA = AA;
		return AA;
	}
	
	public PageReference saveRecord(){
		this.AA = getAA(AA);
		this.AA.State__c = dummyAcct.BillingState;
		this.AA.State_Code__c = dummyAcct.BillingStateCode;
		this.AA.Country__c = dummyAcct.BillingCountry;
		this.AA.Country_Code__c = dummyAcct.BillingCountryCode;	
		try{
			if(isUpdate){
				update this.AA;
			}else{
				this.AA.Id = null;
				insert this.AA;
			}
			PageReference returnURL = new PageReference('/' + this.AA.Id);
			returnURL.setRedirect(true);
			return returnURL;
		}catch(DMLException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
			System.debug(e);
		}

	   return null;
	}
}