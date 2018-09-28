public with sharing class AccountAffliatoinRecordTypeExtension {
	private Account_Affiliation__c AA;
	public Account dummyAcct { get; set; }
	public String recordTypeName { get; set; }
	public String retURL { get; set; }
	public String saveNewURL { get; set; }
	public String cancelURL { get; set; }
	public String ent { get; set; }
	public List<RecordType> recordTypeOptions {get; set;}

	static final String CONST_KEY_PREFIX = Schema.getGlobalDescribe().get('Account_Affiliation__c').getDescribe().getKeyPrefix();

	public AccountAffliatoinRecordTypeExtension(ApexPages.StandardController stdController) {
		this.AA = (Account_Affiliation__c) stdController.getRecord();
		if (this.AA.Id != NULL) {
			this.AA = [Select Name, Street__c, City__c, Postal_Code__c, Country__c, Country_Code__c, State__c, State_Code__c From Account_Affiliation__c where ID = :this.AA.Id];
			this.dummyAcct = new Account(BillingCountryCode = this.AA.Country_Code__c, BillingStateCode = this.AA.State_Code__c);
		}
		getRecordTypeOptions();

		cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
		ent = ApexPages.currentPage().getParameters().get('ent');
		saveNewURL = ApexPages.currentPage().getParameters().get('save_new_url');
	}

	public List<SelectOption> getItems() {
		List<SelectOption> op = new List<SelectOption> ();
		for (RecordTypeInfo rt : RecordTypeServices.getRecordType('Account_Affiliation__c').Values()) {
			if (rt.isAvailable() && !rt.isMaster()) {
				op.add(new SelectOption(rt.getRecordTypeId(), rt.getName()));
			}
		}
		return op;
	}

	public List<RecordType> getRecordTypeOptions(){
		this.recordTypeOptions  = new List<recordType>();
		for(RecordType r : [Select Id, DeveloperName, Description FROM RecordType where SobjectType = 'Account_Affiliation__c' and IsActive = true]){
			this.recordTypeOptions.add(r);
		}

		return this.recordTypeOptions;
	}

	public PageReference redirectRecordType() {

		PageReference returnURL;
		// Redirect if Record Type corresponds to custom VisualForce page

		IF (recordTypeName == '012610000005yaYAAQ') {

			returnURL = new PageReference('/apex/newBusinessAccountAffiliation');

		}

		ELSE {

			returnURL = new PageReference('/a0a/e?');

		}

		String CONST_CONTACT_FIELD_ID = '00N61000007Nncj';

		if (cancelURL != null) {
			returnURL.getParameters().put('CF00N61000007Nncj', [Select Name from Contact WHERE ID = :cancelURL.remove('/')].Name);
		}

		returnURL.getParameters().put('CF' + CONST_CONTACT_FIELD_ID + '_lkid', '');
		returnURL.getParameters().put('retURL', retURL);
		returnURL.getParameters().put('RecordType', recordTypeName);
		returnURL.getParameters().put('cancelURL', cancelURL);
		returnURL.getParameters().put('ent', ent);
		returnURL.getParameters().put('saveUrl', saveNewURL);
		returnURL.getParameters().put('nooverride', '1');

		returnURL.setRedirect(true);
		return returnURL;

	}
}