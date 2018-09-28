/**
* AccountAffiliationRLContactContExt is an extension class for a VF page which mimics the  
* Account Affiliation related list on Contact Detail Page
*
* @author Malay Desai
*/
public with sharing class AccountAffiliationRLContactContExt {
	
	public Contact record;
	public String newURL{get;set;}
	public String baseSOQL;
	public String aType{get;set;}
	public String selectedRecordTypeId{get;set;}
	public static FINAL STRING ALL_RT ='000000000000000';
	
	public List<Account_Affiliation__c> filteredRecords{
		get{
			if(filteredRecords == null)filteredRecords = allRecords;
			return filteredRecords;
		}
		set;}
	public List<Account_Affiliation__c> allRecords{
		get{
			if(allRecords == null)
				allRecords = getAffiliationsByRT(record.Id, null);
			return allRecords;
		}
		set;}
	
	public List<SelectOption> accAffRecTypes{
		get {
			if (accAffRecTypes == null) {            
				accAffRecTypes = new List<SelectOption>();
				accAffRecTypes.add(new SelectOption(ALL_RT, 'All'));
				String objectAPIName = 'Account_Affiliation__c' ; //any object api
				Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
				List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
				for(Schema.RecordTypeInfo info : recordTypeInfo)
				{
					String label = info.getName();
					if(!label.equalsIgnoreCase('Relationship') && !label.equalsIgnoreCase('Master')){
						accAffRecTypes.add(new SelectOption(info.getRecordTypeId(), info.getName()));
					}
				}
			}
			return accAffRecTypes;          
		}
		set;
	}
	static final private AccountAffiliationDAO oAccountAffiliationDAO = new AccountAffiliationDAO(DAOStrategyType.DatabaseDAOStrategy);
	static final String CONST_CONTACT_FIELD_ID = '00N61000007Nncj';
	static final String CONST_ACCOUNT_AFFILIATION_OBJECT_ID = '01I61000000CZH2';
	static final String CONST_RELATIONSHIP = 'Relationship';
	static final String CONST_ACCOUNT = 'Account';
	static final String CONST_NONE = '--None--';
	static final String CONST_KEY_PREFIX = Schema.getGlobalDescribe().get('Account_Affiliation__c').getDescribe().getKeyPrefix();
	static final String CONST_ACCOUNT_RECORDTYPE_ID = RecordTypeServices.getRecordTypeByName(CONST_RELATIONSHIP,CONST_ACCOUNT).Id;  //Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship').getRecordTypeId();
	
	public AccountAffiliationRLContactContExt(ApexPages.StandardController controller) {
		record = (Contact)controller.getRecord();
		//Contrust the URL for New Account Affiliation button
		String beginSaveNewURL;
		System.debug(Site.getPathPrefix());
		beginSaveNewURL = (Site.getPathPrefix() != null) ? 
			Site.getPathPrefix() + '/' + CONST_KEY_PREFIX + '/e': 
		'/'+ CONST_KEY_PREFIX + '/e';
		
		String recordURL;
		recordURL = (Site.getPathPrefix() != null) ?
			Site.getPathPrefix() +'/'+ record.Id:
		'/'+ record.Id;
		
		PageReference save_new_page = new PageReference(beginSaveNewURL);
		save_new_page.getParameters().put('CF'+CONST_CONTACT_FIELD_ID , record.Name); 
		save_new_page.getParameters().put('CF'+CONST_CONTACT_FIELD_ID+'_lkid' , record.Id);   
		save_new_page.getParameters().put('saveURL', recordURL);
		save_new_page.getParameters().put('retURL', recordURL);
		save_new_page.getParameters().put('cancelURL', recordURL); 
		String recTypeUrl = '/apex/AccountAffliationRecordType';
		String redirectUrl ='';
		if(Site.getPathPrefix() != null){
			redirectUrl = URL.getSalesforceBaseUrl().toExternalForm() + Site.getPathPrefix() + recTypeUrl;
		}
		else{
			redirectUrl = recTypeUrl;
		}
		// build the reference to the recordtype selection screen
		PageReference  returnPR = new PageReference(redirectUrl);
		
		// set the entity type for the recordtype screen
		returnPR.getParameters().put('ent', CONST_ACCOUNT_AFFILIATION_OBJECT_ID);
		
		// add the two page URLs to the recordtype screen URL
		returnPR.getParameters().put('retURL', recordURL);
		returnPR.getParameters().put('cancelURL', recordURL); 
		returnPR.getParameters().put('save_new_url', save_new_page.getURL());
		
		newURL = returnPR.getURL();
		aType = CONST_NONE;
		selectedRecordTypeId = CONST_NONE;
	}      
	
	public void queryResultsByRT(){
		if(selectedRecordTypeId == ALL_RT){
			filteredRecords = allRecords;
		} else{
			filteredRecords = new List<Account_Affiliation__c>();
			for(Account_Affiliation__c anAff: allRecords){
				if(anAff.recordTypeId == selectedRecordTypeId)filteredRecords.add(anAff);
			}
		}
	}
	private static List<Account_Affiliation__c> getAffiliationsByRT(Id contactId, Id accountRecordTypeId){
		Schema.FieldSet RLFieldSet = Schema.SobjectType.Account_Affiliation__c.FieldSets.Related_List_Fields;
		List<Schema.SObjectField> otherAffFields = new List<Schema.SObjectField> {Account_Affiliation__c.Id, Account_Affiliation__c.Name
			, Account_Affiliation__c.Contact__c, Account_Affiliation__c.recordtypeid};
				
				List<Account_Affiliation__c> lstRecords = new List<Account_Affiliation__c>();
		List<SObjectModel> lstSObjectModel = oAccountAffiliationDAO.getFilteredRecords(RLFieldSet, otherAffFields, contactId, accountRecordTypeId);
		if(!lstSObjectModel.isEmpty()){
			for(SObjectModel som: lstSObjectModel){
				lstRecords.add((Account_Affiliation__c)som.record);
			}
		}
		return lstRecords;
	}
	
	/**
* Method that execute upon clicking ShowAll at the bottom. 
* @return Reference to the new page which displays all filtered records.
*/
	public PageReference queryAllResults() {         
		filteredRecords = allRecords;
		PageReference pageRef = Page.DisplayQueryResults;
		return pageRef;
	}
	
	/**
* Method used as a dummy method.  
* @return null
*/
	public void dummy() {                   
	}
}