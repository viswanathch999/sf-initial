/*
 * 
 * ContactServices acts as an orchestrator and pulls together task or process  
 * logic typically utilising multiple object data.  
 * 
 * Class provides a strict encapsulation of code 
 * implementing business tasks, calculations & processes 
 * and is a key entry point to other layers.
 *
 * @author Shri K
*/
public without sharing class ContactServices
{

	/** Singleton instance created upon class loading */
	public static final String CONST_CONTACT = 'Contact';
	public static final String CONST_OPPORTUNITY = 'Opportunity';
	public static final String CONST_SPOUSE = 'Spouse_Partner';
	public static final String CONST_CHILD = 'Child';
	public static final String CONST_MEMBER = 'Member';
	public static final String CONST_REINSTATEMENT = 'Reinstatement';
	public static final String CONST_PROSPECT = 'Prospect';
	public static final String CONST_RENEWAL = 'Renewal';
	public static final String CONST_EXCEPTION = 'Exception__c';
	public static final String CONST_WAIVER = 'Waiver';
	public static final String CONST_CUSTOMER_COMMUNITY_USER = Label.Customer_Community_User_Custom;

	Final static Map<Id, List<CA_Setting__c>> globalChapterToCASetting = GroupBy.ids('Chapter__c', [Select User__c, Chapter__c from CA_Setting__c where isActive__c = true]);

	final public static ContactDAO contactDAO;
	final public static Id spouseRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_SPOUSE, CONST_CONTACT).Id;
	final public static Id childRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_CHILD, CONST_CONTACT).Id;
	final public static Id memberRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_MEMBER, CONST_OPPORTUNITY).Id;
	final public static Id prospectRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_PROSPECT, CONST_OPPORTUNITY).Id;
	final public static Id prospectRTCont = RecordTypeServices.getRecordTypeByDeveloperName(CONST_PROSPECT, CONST_CONTACT).Id;
	final public static Id customerCommunityUserProfileId = [SELECT Id FROM Profile WHERE Name = :CONST_CUSTOMER_COMMUNITY_USER].Id;

	static
	{
		contactDAO = new ContactDAO(DAOStrategyType.DMLDAOStrategy);
	}

	/**
	 * Updates the contact record GUID field with the GUID format.  
	 * 
	 * @param: lstContact List of contacts for GUID generation.
	 */
	public static void generateGUID(List<Contact> lstContact)
	{

		final List<Schema.SObjectField> fieldsToUpdate =
		new List<Schema.SObjectField> { Contact.GUID__c };

		List<ContactModel> contactModels = new List<ContactModel> ();
		ContactModel oContactModel;
		for (Contact oContactNew : lstContact)
		{
			if (String.isBlank(oContactNew.GUID__c))
			{
				oContactModel = new ContactModel(new Contact(Id = oContactNew.Id));

				oContactModel.record.put('GUID__c',
				                         GUIDServices.newGUID((String) (oContactModel.record.get('Id'))));
				contactModels.add(oContactModel);
			}
		}

		if (!contactModels.isEmpty())
		contactDAO.modify(contactModels, fieldsToUpdate);
	}

	public static Boolean isGraceExtension(Contact oContact) {
		return(oContact.Grace_Years_Available__c > 0 && !oContact.Is_Grace_Used__c);
	}

	public static Boolean isWaiver(Contact oContact) {
		return(oContact.Grace_Years_Available__c == 0 && oContact.Is_Grace_Used__c);
	}
	//5410 ND 15/12/16
	public static Boolean isGraceAvailable(Contact oContact) {
		Integer count = 0;
		count = [Select count() from Exception__c where contact__C = :oContact.id and(Type_of_Waiver__c = 'Grace Extension' AND Exception_Category__c = 'Waiver')];

		if (oContact.Grace_Years_Available__c > 0 || (oContact.Grace_Years_Used__c > 0 && count == 0)) {
			return true;
		}

		else {
			return false;
		}
	}

	public static Boolean isTransitionAvailable(Contact oContact) {
		System.debug('Transition Status: ' + oContact.Transition_Status__c + ' Returning: ' + (oContact.Transition_Status__c == 'Eligible for early transition' ||
		                                                                                       oContact.Transition_Status__c == 'Scheduled for transition'));
		return(oContact.Transition_Status__c == 'Eligible for early transition' ||
		       oContact.Transition_Status__c == 'Scheduled for transition');
	}

	public static Boolean isJoinDateInThirdQuarter(Contact oContact) {
		if (oContact.Join_Date__c != null && oContact.Join_Date__c.month() >= 1 && oContact.Join_Date__c.month() <= 3 && oContact.Join_Date__c.year() == Date.Today().year()) {
			System.debug('###Join_Date__c: ' + oContact.Join_Date__c);
			System.debug('###true');
			return true;
		}
		else {
			System.debug('###false');
			return false;
		}

	}

	public static List<Contact> getChildrenAndSpouse(Contact oContact) {
		/* List<Schema.SObjectField> oContactFields = new List<Schema.SObjectField> {Contact.Id, Contact.HouseHoldID__c, Contact.AccountId, Contact.FirstName, Contact.LastName, 
		  Contact.Gender__c, Contact.BirthDate, Contact.Email, Contact.RecordTypeId};
		 
		  List<SObjectModel> lstSObjectModel = contactDAO.getChildrenAndSpouse(oContactFields,  oContact.AccountId, oContact.HouseHoldID__c,
		  new List<Id>{spouseRecordTypeId,childRecordTypeId});*/

		system.debug('oContact id ' + oContact.id + 'accountId = :  ' + oContact.accountId
		             + ' AND householdId__c =: ' + oContact.HouseHoldID__c);
		List<Contact> lstContact = new List<Contact> ();
		if (oContact.HouseHoldID__c != null) {
			String fifteenDigitHouseHoldId = oContact.HouseHoldID__c.substring(0, 15) + '%';
			List<Contact> lstContactTemp = [SELECT id, RecordTypeId, name, FirstName, LastName, Gender__c, BirthDate, Email, HouseHoldID__c, AccountId FROM Contact WHERE accountId = :oContact.accountId
			                                AND householdId__c Like :fifteenDigitHouseHoldId and recordtype.DeveloperName IN('Spouse/Partner', 'Spouse_Partner', 'Child')];
			Map<Id, Contact> mapContact = new Map<Id, Contact> ();
			if (!lstContactTemp.isEmpty()) {
				for (Contact contact : lstContactTemp) {
					// Contact temp = ((Contact)contactModel.record);
					mapContact.put(contact.Id, contact);
				}
			}

			for (List<Relationship__c> lstRel :[SELECT Id, Is_Active__c, Contact__c FROM Relationship__c WHERE Contact__c IN :mapContact.keySet()]) {
				for (Relationship__c rel : lstRel) {
					if (rel != null && rel.Is_Active__c) {
						lstContact.add(mapContact.get(rel.Contact__c));
					}

				}
			}
		}
		return lstContact;
	}

	public static Relationship__c getRelationship(Contact oContact) {
		try {
			List<Relationship__c> lstRelationship = [SELECT Id, Is_Active__c, Account__c FROM Relationship__c WHERE Contact__c = :oContact.Id AND Is_Active__c = true LIMIT 1];

			return(lstRelationship.IsEmpty() ? null : lstRelationship.get(0));
		} catch(Exception ex) {
			return null;
		}
	}

	public static List<OpportunityContactRole> getOpportunityContactRoles(Id contactId)
	{
		Date nextFiscalStartDate = Date.newInstance(System.Today().year(), 7, 1);
		// Check to see if this contact is a prospect
		// if so look for the "New" Opportunity; otherwise look for the "Cycle Open" renewal opportunity
		set<string> StageToken = New set<String>{'Cycle Open', 'Payment Pending', 'Payment Received', 'Closed Won'};
		try {
			id ContactRecordTypeId = [Select RecordTypeId From Contact Where id = :contactId limit 1].RecordTypeId;
			if (ContactRecordTypeId == prospectRTCont) {	
				StageToken = New set<String>{'New'};
			} 
		} catch (Exception Expt) {
			System.debug('Error retrieving Contact record by ID');
			System.debug(Expt.getMessage());
			System.debug(Expt.getStackTraceString());
		}

		String queryString = 'SELECT id, ContactId, OpportunityId, ';

		for (FieldSetMember field : Schema.SObjectType.Opportunity.FieldSets.Fields_for_Recertification.getFields())
		{
			queryString += 'Opportunity.' + field.getFieldPath() + ', ';
		}

		queryString += 'Opportunity.Birthdate__c,Opportunity.Business_Description__c, Opportunity.Parent_Account__r.Id,Opportunity.Parent_Account__r.Name, Opportunity.Grace_Status__c, ' +
		'Opportunity.CreatedDate, Opportunity.Fiscal_Date_Start__c, Opportunity.Transition_Via_Renewal_Form__c, Opportunity.Certification_Documentation_URL__c, ' +
		'Opportunity.Which_Chapter__c,Opportunity.Certification_Type__c,Opportunity.Third_Party_Name__c,Opportunity.Third_Party_Firm__c,Opportunity.Type_of_3rd_Party_Verifier__c, ' +
		'Opportunity.Third_Party_Phone__c,Opportunity.Third_Party_Email__c,Opportunity.Third_Party_Firm_Website__c,Opportunity.CartToken__c, Opportunity.X3rd_Party_Certification_Option_Chosen__c, ' +
		'Opportunity.Account.Name, Opportunity.Account.Industry, Opportunity.Account.Sub_Category__c, Opportunity.Opportunity_Type__c, Opportunity.KGRenewal__IsActiveCart__c, ' +
		'Opportunity.Account.Is_Subsidiary__c,Opportunity.Account.Parent_Company__c,Opportunity.Account.Type, Opportunity.Certification_Status__c, Opportunity.StageName,' +
		'Opportunity.Certification_Page_Status_Exchange__c, Opportunity.Profile_Page_Status_Exchange__c , Opportunity.Dues_Page_Status_Exchange__c, Opportunity.Transition_flag__c ';

		queryString += 'FROM OpportunityContactRole WHERE ContactId =: contactId AND Opportunity.StageName in :StageToken AND Opportunity.Opportunity_Type__c in (\'Prospect\',\'Renewal\',\'Reinstatement\') ' +
			'Order by Opportunity.Fiscal_Date_Start__c DESC LIMIT 1 ';

		//Item-07341
		//Item-07609 - Adding in the extra stage types and checking status'
		List<OpportunityContactRole> oOpptContRole = Database.query(queryString);
		if (oOpptContRole.size() == 0) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'There is no open opportunity available. Please contact Member Services to verify that everything is properly setup.'));
		} else {
			//Should be just Prospects and Reinstatements within the Current Fiscal year.
			if (oOpptContRole[0].Opportunity.Opportunity_Type__c != CONST_RENEWAL) {
				if (oOpptContRole[0].Opportunity.Fiscal_Date_Start__c == FiscalDateUtility.startOfCurrentFiscal) {
					if (oOpptContRole[0].Opportunity.StageName == 'New' && oOpptContRole[0].Opportunity.KGRenewal__IsActiveCart__c == true) {
						return oOpptContRole;
					} else 
					If (oOpptContRole[0].Opportunity.StageName == 'Cycle Open' && oOpptContRole[0].Opportunity.KGRenewal__IsActiveCart__c == true) {
						return oOpptContRole;
					} else 
					if ((oOpptContRole[0].Opportunity.StageName == 'Payment Pending' || oOpptContRole[0].Opportunity.StageName == 'Payment Received')) {
						return oOpptContRole;
					} else {
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The Opportunity Staging is not properly configured.  Please contact Member Services to correct.'));
					}
				} else {
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The current Fiscal Year Opportunity start date is not the most recent Opportunity.  Please contact Member Services to correct.'));
				}
			} else {
			// Just Renewal Opportunity Types all within the Next Fiscal Year
				if (oOpptContRole[0].Opportunity.Fiscal_Date_Start__c == nextFiscalStartDate) {
					//Current Renewal staging
					if (oOpptContRole[0].Opportunity.StageName == 'Cycle Open' && oOpptContRole[0].Opportunity.KGRenewal__IsActiveCart__c == true) {
						return oOpptContRole;
					} else
					//Completed payment but following up on Third-Party Recertification
					if ((oOpptContRole[0].Opportunity.StageName == 'Payment Pending' || oOpptContRole[0].Opportunity.StageName == 'Payment Received' || oOpptContRole[0].Opportunity.StageName == 'Closed Won')) {
						return oOpptContRole;
					} else {
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The Opportunity Staging is not properly configured.  Please contact Member Services to correct.'));
					}
				} else {
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The Renewal Fiscal Year Opportunity start date is not the most recent Opportunity.  Please contact Member Services to correct.'));
				}
			}
		}
		return null;
	}

	public static List<OpportunityContactRole> getPrevOpportunityContactRoles(Id contactId)
	{
		//Has to be the Current Fiscal Year since this is for Renewal Recertification for the Next fiscal year
		Date prevFiscalStartDate = FiscalDateUtility.startOfCurrentFiscal;
		String queryString = '';


		queryString += 'SELECT id, ContactId, OpportunityId, ';

		for (FieldSetMember field : Schema.SObjectType.Opportunity.FieldSets.Fields_for_Recertification.getFields())
		{
			queryString += 'Opportunity.' + field.getFieldPath() + ', ';
		}

		queryString += 'Opportunity.Birthdate__c,Opportunity.Business_Description__c, Opportunity.Parent_Account__r.Id,Opportunity.Parent_Account__r.Name, ' +
		'Opportunity.CreatedDate, Opportunity.Fiscal_Date_Start__c, Opportunity.Transition_Via_Renewal_Form__c, ' +
		'Opportunity.Which_Chapter__c,Opportunity.Certification_Type__c,Opportunity.Third_Party_Name__c,Opportunity.Third_Party_Firm__c, ' +
		'Opportunity.Third_Party_Phone__c,Opportunity.Third_Party_Email__c,Opportunity.Third_Party_Firm_Website__c,Opportunity.CartToken__c, ' +
		'Opportunity.Account.Name,Opportunity.Account.Industry,Opportunity.Account.Sub_Category__c, ' +
		'Opportunity.Account.Is_Subsidiary__c,Opportunity.Account.Parent_Company__c,Opportunity.Account.Type,Opportunity.Grace_Status__c, Opportunity.StageName ';

		queryString += 'FROM OpportunityContactRole WHERE ContactId =: contactId ' +
		'AND Opportunity.Fiscal_Date_Start__c  =: prevFiscalStartDate AND Opportunity.KGRenewal__Subscription__c  != NULL LIMIT 1 ';

		//Item-07341
		List<OpportunityContactRole> oOpptContRole = Database.query(queryString);
		if (oOpptContRole.size() == 0) ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Current Fiscal year opportunity missing. Verify Fiscal Year/Subscription.'));
		return oOpptContRole;
	}

	public static Opportunity getOpportunities(Contact oContact) {
		Opportunity oOpp = null;
		/*List<OpportunityContactRole> oContactRolelist =  [SELECT id, ContactId, OpportunityId, 
		  Opportunity.Account.Name, Opportunity.Qualifying_Company__c, Opportunity.Organization_Type__c, Opportunity.AnnualRevenue__c,
		  Opportunity.Total_Employee_Compensation__c, Opportunity.NumberOfEmployees__c,
		  Opportunity.Enterprise_Value__c, Opportunity.Title__c, Opportunity.Birthdate__c, Opportunity.President_Type__c, 
		  Opportunity.Business_Scope__c,Opportunity.Business_Description__c, Opportunity.Enterprise_Type__c,
		  Opportunity.Firm_Type__c, Opportunity.Account.Industry, Opportunity.Account.Sub_Category__c, Opportunity.Account.Is_Subsidiary__c, 
		  Opportunity.Account.Parent_Company__c,Opportunity.Account.Type,Opportunity.CreatedDate, Opportunity.Fiscal_Date_Start__c, Opportunity.Transition_Via_Renewal_Form__c,
		  Opportunity.Which_Chapter__c,Opportunity.Certification_Type__c,Opportunity.Third_Party_Name__c,Opportunity.Third_Party_Firm__c,
		  Opportunity.Third_Party_Email__c,Opportunity.CartToken__c
		  FROM OpportunityContactRole WHERE ContactId =: oContact.Id AND Opportunity.StageName = 'Cycle Open'
		  AND Opportunity.Fiscal_Date_Start__c  = :nextFiscalStartDate AND Opportunity.KGRenewal__IsActiveCart__c  = true LIMIT 1 ];*/
		List<OpportunityContactRole> oContactRolelist = getOpportunityContactRoles(oContact.Id);
		System.debug('###oContactRolelist: ' + oContactRolelist);

		OpportunityContactRole oContactRole = null;
		if (oContactRolelist<> null && (!oContactRolelist.isEmpty()) && oContactRolelist.size() > 0) {
			oContactRole = oContactRolelist[0];
		}
		if (oContactRole != null) {
			Account acc;
			oOpp = new Opportunity(Id = oContactRole.OpportunityId);
			try {
				oOpp.Qualifying_Company__c = oContactRole.Opportunity.Qualifying_Company__c;
				acc = new Account(Id = oContactRole.Opportunity.AccountId);
				acc.Name = oContactRole.Opportunity.Account.Name;
				//  acc.Firm_Type__c = oContactRole.Opportunity.Account.Firm_Type__c ;
				acc.Industry = oContactRole.Opportunity.Account.Industry;
				acc.Sub_Category__c = oContactRole.Opportunity.Account.Sub_Category__c;
				acc.Is_Subsidiary__c = oContactRole.Opportunity.Account.Is_Subsidiary__c;
				acc.Parent_Company__c = oContactRole.Opportunity.Account.Parent_Company__c;
				acc.Type = oContactRole.Opportunity.Account.Type;
				oOpp.Account = acc;
				oOpp.AccountId = acc.Id;
				oOpp.Account.Name = acc.Name;
				oOpp.Firm_Type__c = oContactRole.Opportunity.Firm_Type__c;
				oOpp.Account.Industry = oContactRole.Opportunity.Account.Industry;
				oOpp.Account.Sub_Category__c = acc.Sub_Category__c;
				oOpp.Account.Is_Subsidiary__c = acc.Is_Subsidiary__c;
				oOpp.Account.Parent_Company__c = acc.Parent_Company__c;
				oOpp.Account.Type = acc.Type;
				oOpp.Organization_Type__c = oContactRole.Opportunity.Organization_Type__c;
				oOpp.AnnualRevenue__c = oContactRole.Opportunity.AnnualRevenue__c;
				oOpp.Total_Employee_Compensation__c = oContactRole.Opportunity.Total_Employee_Compensation__c;
				oOpp.NumberOfEmployees__c = oContactRole.Opportunity.NumberOfEmployees__c;
				oOpp.Enterprise_Value__c = oContactRole.Opportunity.Enterprise_Value__c;
				oOpp.Enterprise_type__c = oContactRole.Opportunity.Enterprise_type__c;
				oOpp.Title__c = oContactRole.Opportunity.Title__c;
				oOpp.Title_Other__c = oContactRole.Opportunity.Title_Other__c;
				oOpp.Birthdate__c = oContactRole.Opportunity.Birthdate__c;
				oOpp.President_Type__c = oContactRole.Opportunity.President_Type__c;
				oOpp.Business_Scope__c = oContactRole.Opportunity.Business_Scope__c;
				oOpp.Business_Description__c = oContactRole.Opportunity.Business_Description__c;
				oOpp.Fiscal_Date_Start__c = oContactRole.Opportunity.Fiscal_Date_Start__c;
				oOpp.Transition_Via_Renewal_Form__c = oContactRole.Opportunity.Transition_Via_Renewal_Form__c;
				oOpp.Third_Party_Email__c = oContactRole.Opportunity.Third_Party_Email__c;
				oOpp.Third_Party_Name__c = oContactRole.Opportunity.Third_Party_Name__c;
				oOpp.Third_Party_Firm__c = oContactRole.Opportunity.Third_Party_Firm__c;
				oOpp.Third_Party_Phone__c = oContactRole.Opportunity.Third_Party_Phone__c;
				oOpp.Third_Party_Firm_Website__c = oContactRole.Opportunity.Third_Party_Firm_Website__c;
				oOpp.Certification_Type__c = oContactRole.Opportunity.Certification_Type__c;
				oOpp.CartToken__c = oContactRole.Opportunity.CartToken__c;
				oOpp.QC_StreetAddress1__c = oContactRole.Opportunity.QC_StreetAddress1__c;
				oOpp.QC_StreetAddress2__c = oContactRole.Opportunity.QC_StreetAddress2__c;
				oOpp.QC_City__c = oContactRole.Opportunity.QC_City__c;
				oOpp.QC_State__c = oContactRole.Opportunity.QC_State__c;
				oOpp.QC_StateCode__c = oContactRole.Opportunity.QC_StateCode__c;
				oOpp.QC_PostalCode__c = oContactRole.Opportunity.QC_PostalCode__c;
				oOpp.QC_Country__c = oContactRole.Opportunity.QC_Country__c;
				oOpp.QC_CountryCode__c = oContactRole.Opportunity.QC_CountryCode__c;
				oOpp.Subsidiary__c = oContactRole.Opportunity.Subsidiary__c;
				oOpp.Parent_Account__c = oContactRole.Opportunity.Parent_Account__c;
				System.debug('**** Contact StageName ' + oContactRole.Opportunity.StageName);
				oOpp.StageName = oContactRole.Opportunity.StageName;
				//oOpp.Parent_Account__r = oContactRole.Opportunity.Parent_Account__r;
				//oOpp.Parent_Account__r.Id = oContactRole.Opportunity.Parent_Account__r.Id;
				//oOpp.Parent_Account__r.Name = oContactRole.Opportunity.Parent_Account__r.Name;
				oOpp.Parent_Company__c = oContactRole.Opportunity.Parent_Company__c;
				oOpp.Certification_Documentation_URL__c = oContactRole.Opportunity.Certification_Documentation_URL__c;
				oOpp.Type_of_3rd_Party_Verifier__c = oContactRole.Opportunity.Type_of_3rd_Party_Verifier__c;
				oOpp.Certification_Page_Status_Exchange__c = oContactRole.Opportunity.Certification_Page_Status_Exchange__c;
				oOpp.Profile_Page_Status_Exchange__c = oContactRole.Opportunity.Profile_Page_Status_Exchange__c;
				oOpp.Dues_Page_Status_Exchange__c = oContactRole.Opportunity.Dues_Page_Status_Exchange__c;
				oOpp.Transition_flag__c = oContactRole.Opportunity.Transition_flag__c;
				oOpp.Certification_Status__c = oContactRole.Opportunity.Certification_Status__c;
				oOpp.X3rd_Party_Certification_Option_Chosen__c = oContactRole.Opportunity.X3rd_Party_Certification_Option_Chosen__c;
				oOpp.Grace_Status__c = oContactRole.Opportunity.Grace_Status__c;
				oOpp.Id = oContactRole.OpportunityId;
			} catch(Exception ex) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
			}
		}

		return oOpp;
	}

	@remoteAction
	public static Opportunity getPreviousOpportunity(Contact oContact) {
		Opportunity oOpp = null;
		Date prevFiscalStartDate = Date.newInstance(System.Today().year() - 1, 7, 1);
		/*List<OpportunityContactRole> oContactRolelist =  [SELECT id, ContactId, OpportunityId, 
		  Opportunity.Account.Name, Opportunity.Qualifying_Company__c, Opportunity.Organization_Type__c, Opportunity.AnnualRevenue__c,
		  Opportunity.Total_Employee_Compensation__c, Opportunity.NumberOfEmployees__c,
		  Opportunity.Enterprise_Value__c, Opportunity.Title__c, Opportunity.Birthdate__c, Opportunity.President_Type__c, 
		  Opportunity.Business_Scope__c,Opportunity.Business_Description__c, Opportunity.Enterprise_Type__c,
		  Opportunity.Firm_Type__c, Opportunity.Account.Industry, Opportunity.Account.Sub_Category__c, Opportunity.Account.Is_Subsidiary__c, 
		  Opportunity.Account.Parent_Company__c,Opportunity.Account.Type,Opportunity.CreatedDate, Opportunity.Fiscal_Date_Start__c, Opportunity.Transition_Via_Renewal_Form__c,
		  Opportunity.Which_Chapter__c,Opportunity.Certification_Type__c,Opportunity.Third_Party_Name__c,Opportunity.Third_Party_Firm__c,
		  Opportunity.Third_Party_Email__c,Opportunity.CartToken__c
		  FROM OpportunityContactRole WHERE ContactId =: oContact.Id AND Opportunity.StageName = 'Cycle Open'
		  AND Opportunity.Fiscal_Date_Start__c  = :prevFiscalStartDate AND Opportunity.KGRenewal__IsActiveCart__c  = true LIMIT 1 ];*/
		List<OpportunityContactRole> oContactRolelist = getPrevOpportunityContactRoles(oContact.Id);

		OpportunityContactRole oContactRole = null;
		if (oContactRolelist<> null && (!oContactRolelist.isEmpty()) && oContactRolelist.size() > 0) {
			oContactRole = oContactRolelist[0];
		}
		if (oContactRole != null) {
			Account acc;
			oOpp = new Opportunity(Id = oContactRole.OpportunityId);
			try {
				oOpp.Qualifying_Company__c = oContactRole.Opportunity.Qualifying_Company__c;
				acc = new Account(Id = oContactRole.Opportunity.AccountId);
				acc.Name = oContactRole.Opportunity.Account.Name;
				//  acc.Firm_Type__c = oContactRole.Opportunity.Account.Firm_Type__c ;
				acc.Industry = oContactRole.Opportunity.Account.Industry;
				acc.Sub_Category__c = oContactRole.Opportunity.Account.Sub_Category__c;
				acc.Is_Subsidiary__c = oContactRole.Opportunity.Account.Is_Subsidiary__c;
				acc.Parent_Company__c = oContactRole.Opportunity.Account.Parent_Company__c;
				acc.Type = oContactRole.Opportunity.Account.Type;
				oOpp.Account = acc;
				oOpp.AccountId = acc.Id;
				oOpp.Account.Name = acc.Name;
				oOpp.Firm_Type__c = oContactRole.Opportunity.Firm_Type__c;
				oOpp.Account.Industry = oContactRole.Opportunity.Account.Industry;
				oOpp.Account.Sub_Category__c = acc.Sub_Category__c;
				oOpp.Account.Is_Subsidiary__c = acc.Is_Subsidiary__c;
				oOpp.Account.Parent_Company__c = acc.Parent_Company__c;
				oOpp.Account.Type = acc.Type;
				oOpp.Organization_Type__c = oContactRole.Opportunity.Organization_Type__c;
				oOpp.AnnualRevenue__c = oContactRole.Opportunity.AnnualRevenue__c;
				oOpp.Total_Employee_Compensation__c = oContactRole.Opportunity.Total_Employee_Compensation__c;
				oOpp.NumberOfEmployees__c = oContactRole.Opportunity.NumberOfEmployees__c;
				oOpp.Enterprise_Value__c = oContactRole.Opportunity.Enterprise_Value__c;
				oOpp.Enterprise_type__c = oContactRole.Opportunity.Enterprise_type__c;
				oOpp.Title__c = oContactRole.Opportunity.Title__c;
				oOpp.Title_Other__c = oContactRole.Opportunity.Title_Other__c;
				oOpp.Birthdate__c = oContactRole.Opportunity.Birthdate__c;
				oOpp.President_Type__c = oContactRole.Opportunity.President_Type__c;
				oOpp.Business_Scope__c = oContactRole.Opportunity.Business_Scope__c;
				oOpp.Business_Description__c = oContactRole.Opportunity.Business_Description__c;
				oOpp.Fiscal_Date_Start__c = oContactRole.Opportunity.Fiscal_Date_Start__c;
				oOpp.Transition_Via_Renewal_Form__c = oContactRole.Opportunity.Transition_Via_Renewal_Form__c;
				oOpp.Third_Party_Email__c = oContactRole.Opportunity.Third_Party_Email__c;
				oOpp.Third_Party_Name__c = oContactRole.Opportunity.Third_Party_Name__c;
				oOpp.Third_Party_Firm__c = oContactRole.Opportunity.Third_Party_Firm__c;
				oOpp.Third_Party_Phone__c = oContactRole.Opportunity.Third_Party_Phone__c;
				oOpp.Third_Party_Firm_Website__c = oContactRole.Opportunity.Third_Party_Firm_Website__c;
				oOpp.Certification_Type__c = oContactRole.Opportunity.Certification_Type__c;
				oOpp.CartToken__c = oContactRole.Opportunity.CartToken__c;
				oOpp.QC_StreetAddress1__c = oContactRole.Opportunity.QC_StreetAddress1__c;
				oOpp.QC_StreetAddress2__c = oContactRole.Opportunity.QC_StreetAddress2__c;
				oOpp.QC_City__c = oContactRole.Opportunity.QC_City__c;
				oOpp.QC_State__c = oContactRole.Opportunity.QC_State__c;
				oOpp.QC_StateCode__c = oContactRole.Opportunity.QC_StateCode__c;
				oOpp.QC_PostalCode__c = oContactRole.Opportunity.QC_PostalCode__c;
				oOpp.QC_Country__c = oContactRole.Opportunity.QC_Country__c;
				oOpp.QC_CountryCode__c = oContactRole.Opportunity.QC_CountryCode__c;
				oOpp.Subsidiary__c = oContactRole.Opportunity.Subsidiary__c;
				oOpp.Parent_Account__c = oContactRole.Opportunity.Parent_Account__c;
				//oOpp.Parent_Account__r = oContactRole.Opportunity.Parent_Account__r;
				//oOpp.Parent_Account__r.Id = oContactRole.Opportunity.Parent_Account__r.Id;
				//oOpp.Parent_Account__r.Name = oContactRole.Opportunity.Parent_Account__r.Name;
				oOpp.Parent_Company__c = oContactRole.Opportunity.Parent_Company__c;


				oOpp.Id = oContactRole.OpportunityId;
			} catch(Exception ex) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
			}
		}

		return oOpp;
	}

	public static Relationship__c createRelationship(Id contactId, Id householdAccountId, String type) {
		return Utility.createRelationship(contactId, householdAccountId, type);
	}

	public static Account getAssociatedAccount(Contact oContact) {
		Account oAcc = null;
		try {
			List<Account_Affiliation__c> lstAccAff = [SELECT Id, Account__c, /*Account__r.Firm_Type__c,*/ Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState,
			                                          Account__r.BillingCountry, Account__r.BillingPostalCode, Account__r.BillingStateCode, Account__r.BillingCountryCode, Account__r.BillingLatitude,
			                                          Account__r.BillingLongitude, Account__r.Industry, Account__r.Phone, Account__r.Website
			                                          FROM Account_Affiliation__c WHERE Contact__c = :oContact.Id
			                                          AND Account_Type__c = 'Business' AND IsActive__c = true AND RecordType.Name = 'Business' LIMIT 1];
			// AND RecordType.Name = 'Business'

			if (!lstAccAff.isEmpty()) {
				Account_Affiliation__c oAccAff = lstAccAff.get(0);
				oAcc = new Account(Id = oAccAff.Account__c);
				oAcc.Phone = oAccAff.Account__r.Phone;
				oAcc.Website = oAccAff.Account__r.Website;
				oAcc.BillingStreet = oAccAff.Account__r.BillingStreet;
				oAcc.Industry = oAccAff.Account__r.Industry;
				oAcc.BillingCity = oAccAff.Account__r.BillingCity;
				oAcc.BillingState = oAccAff.Account__r.BillingState;
				oAcc.BillingStateCode = oAccAff.Account__r.BillingStateCode;
				oAcc.BillingPostalCode = oAccAff.Account__r.BillingPostalCode;
				oAcc.BillingCountry = oAccAff.Account__r.BillingCountry;
				oAcc.BillingCountryCode = oAccAff.Account__r.BillingCountryCode;
				oAcc.BillingLatitude = oAccAff.Account__r.BillingLatitude;
				oAcc.BillingLongitude = oAccAff.Account__r.BillingLongitude;
				// oAcc.Firm_Type__c = oAccAff.Account__r.Firm_Type__c;

			}
		} catch(Exception oDmlException) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_Account_Affiliation_Record_Found));
			return null;
		}
		return oAcc;
	}

	public static Boolean isQualified(Contact oContact, Opportunity oOpp, String previousQualifyingCompany) {
		if (oOpp.Transition_Flag__c) {
			return true;
		}
		Boolean validation1 = false, validation2 = false, validation2a = false,
		validation2b = false, qualifyingCompanyNotChanged = false;
		Boolean n1, n2, n3, n4, b1, b2, b3, b4, b5, b6, b7, b8, b9;
		Boolean m1, m2, m3, m4, c1, c2, c3, c4, c5, c6, c7, c8, c9;
		previousQualifyingCompany = previousQualifyingCompany.equals('') ? oOpp.Qualifying_Company__c : previousQualifyingCompany;
		if (oOpp.Fiscal_Date_Start__c == null) {
			validation1 = false;
		} else {
			Integer currentYear = oOpp.Fiscal_Date_Start__c.year();
			Integer nextYear = currentYear + 1;
			Integer existingOppCount = [SELECT count() FROM Opportunity WHERE Qualifying_Company__c = :oOpp.Qualifying_Company__c
			                            AND RecordTypeId in(:memberRecordTypeId, :prospectRecordTypeId) AND(CALENDAR_YEAR(Fiscal_Date_Start__c) = :currentYear
			                                                                                                OR CALENDAR_YEAR(Fiscal_Date_Start__c) = :(nextYear))];

			if (existingOppCount == 1) {

				validation1 = true; // existingOpportinity 
				System.debug('@@ Validation 1' + validation1);
			}
		}

		//Requirement A Section (per backlog reqs)
		//if(validation1){
		//Switch the QS__c to the COntact QC Fields. 
		QS__c cQS = QS__c.getOrgDefaults(); //Check the not null check. put it in try catch
		if (cQS != null) {
			String orgType = (oOpp.Organization_Type__c != null ? oOpp.Organization_Type__c : '');
			n1 = (oOpp.NumberOfEmployees__c != null);
			n2 = (oOpp.NumberOfEmployees__c != null && oOpp.Total_Employee_Compensation__c != null);
			n3 = (oOpp.Enterprise_Value__c != null);
			n4 = (oOpp.AnnualRevenue__c != null);

			System.debug('###b1: ' + b1);
			b1 = (n1 && oOpp.NumberOfEmployees__c >= oContact.Number_of_Employees__c); //A.a
			System.debug('###oContact.Join_date__c.year(): ' + oContact.Join_date__c.year());
			System.debug('###oOpp.NumberOfEmployees__c: ' + oOpp.NumberOfEmployees__c);
			System.debug('###oContact.Number_of_Employees_Opt_2__c: ' + oContact.Number_of_Employees_Opt_2__c);
			System.debug('###oOpp.Total_Employee_Compensation__c: ' + oOpp.Total_Employee_Compensation__c);
			System.debug('###oContact.Total_Employee_Compensation__c: ' + oContact.Total_Employee_Compensation__c);
			b2 = (oContact.Join_date__c.year() <= 2000 || //A.b
			(n2 && (oOpp.NumberOfEmployees__c >= oContact.Number_of_Employees_Opt_2__c
			        && oOpp.Total_Employee_Compensation__c >= oContact.Total_Employee_Compensation__c)));

			System.debug('***REQ A Validations ---> A.a : ' + b1 + ' A.b : ' + b2);
			if ((b1 || b2)) { // && ((b3 || ((b7 && b4) || (b8 && b5) || (b9 && b6))))
				validation2a = true;
				System.debug('@@ validation2a' + validation2a);
			}
		}

		//Requirement B Section
		//if(!validation2a){
		//qualifyingCompanyNotChanged = ((oOpp.Qualifying_Company__c != null) && previousQualifyingCompany.equalsIgnoreCase(oOpp.Qualifying_Company__c));
		//if(qualifyingCompanyNotChanged){
		m1 = (oOpp.AnnualRevenue__c != null); //Dollar Business Volume
		m2 = (oOpp.Organization_Type__c != null); //Corporation Type Picklist
		//m3 = (oContact.Enterprise_Value__c != null);
		//m4 = (oContact.Annual_Revenue__c != null);


		/// B1
		Boolean Bb1 = false;
		Set<String> annualRevOrgTypes = new Set<String> { 'Sales', 'Service', 'Manufacturing' };
		if (m1 && m2 && annualRevOrgTypes.contains(oOpp.Organization_Type__c)) {
			Bb1 = oOpp.AnnualRevenue__c >= oContact.Annual_Revenue__c;
		} else if (m1 && m2 && oOpp.Organization_Type__c == 'Agency-Type') {
			Bb1 = oOpp.AnnualRevenue__c >= oContact.Annual_Fees__c;
		} else if (m1 && m2 && oOpp.Organization_Type__c == 'Financial Institution') {
			Bb1 = oOpp.AnnualRevenue__c >= oContact.Annual_Assets__c;
		}
		//}


		if (Bb1) {
			validation2b = true;
		} else if (oOpp.Enterprise_Type__c != null && oOpp.Enterprise_Value__c >= oContact.Enterprise_Value__c) {
			validation2b = true;
		} else {
			validation2b = false;
		}
		System.debug('***REQ B Validations ---> B.1 : ' + Bb1 + ' B.2 : ' + validation2b);
		//}
		//}
		validation2 = (validation2a && validation2b);
		return(/*validation1 &&*/ validation2);
	}

	/*public static void checkAssociatedAccount(String qualifyingCompanyName, Contact oContact){
	  List<Account> newAccount = [SELECT id, Name FROM Account WHERE Name =:qualifyingCompanyName LIMIT 1];
	  if(newAccount.isEmpty()){
	  Account oAcc = new Account(Name=qualifyingCompanyName, Type='Business');
	  try{
	  insert oAcc;
	  Account_Affiliation__c oAccAff = new Account_Affiliation__c(Account__c = oAcc.Id,Contact__c = oContact.Id);
	 
	  try{
	  insert oAccAff;
	  } catch(DMLException oDmlException){
	  for(Integer i =0; i < oDmlException.getNumDml(); i++)
	  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getDmlMessage(i)));
	  }
	  } catch(DMLException oDmlException){
	  for(Integer i =0; i < oDmlException.getNumDml(); i++)
	  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oDmlException.getDmlMessage(i)));
	  }
	  } else{
	 
	  }
	  }*/
	public static Map<String, String> rtToAccess {
		get {
			if (rtToAccess == null) {
				rtToAccess = new Map<String, String> ();
				for (Contact_Share_Settings__c ContactSharesetting : Contact_Share_Settings__c.getAll().values()) {
					rtToAccess.put(ContactSharesetting.Contact_RecordType_DeveloperName__c, ContactSharesetting.CA_Access_Level__c);
				}
			}
			return rtToAccess;
		} set;
	}

	public void createContactSharesPB(List<Id> contactIds) {
		List<Contact> conts = [Select Id, accountId, RecordType.DeveloperName, RecordTypeId, OwnerId From Contact Where Id IN :contactIds];
		createContactShareRecordEdit(conts, true);
	}
	public void createContactSharesPB(List<Contact> contacts) {
		createContactShareRecordEdit(contacts, true);
	}

	private Map<Id, List<CA_Setting__c>> filterChapterCASetting(Set<Id> chapterIds) {
		Map<Id, List<CA_Setting__c>> filterChapterToCASetting = new Map<Id, List<CA_Setting__c>> ();

		for (Id i : chapterIds) {
			if (globalChapterToCASetting.containsKey(i)) {
				filterChapterToCASetting.put(i, globalChapterToCASetting.get(i));
			}
		}

		return filterChapterToCASetting;
	}


	public void createContactShareRecordEdit(List<Contact> newContacts, Boolean isUpdate) {
		List<ContactShare> ContactSharesToInsert = new List<ContactShare> ();
		List<ContactShare> ContactSharesToDelete = new List<ContactShare> ();
		Map<Id, List<CA_Setting__c>> chapterToCASetting = filterChapterCASetting(Pluck.ids('AccountId', newContacts));

		System.debug('*** createContactShareRecordEdit() ***');
		System.debug('newContacts: ' + newContacts);
		System.debug('rtToAccess: ' + rtToAccess);
		System.debug('chapterToCASetting: ' + chapterToCASetting);

		Boolean hasDeleteShareRecords = false;
		Boolean first = true;
		String query = 'Select Id, UserOrGroupId from ContactShare where ';

		for (Contact newContact : newContacts) {

			System.debug('newContact: ' + newContact);
			String rt = newContact.RecordType.DeveloperName;
			System.debug('newContact RT: ' + rt);

			if (rtToAccess.containsKey(rt)) {
				String accessLevel = rtToAccess.get(rt);

				System.debug('accessLevel: ' + accessLevel);

				if (chapterToCASetting.containsKey(newContact.accountId)) {
					for (CA_Setting__c caSet : chapterToCASetting.get(newContact.accountId)) {
						if (caSet.User__c != null && caSet.User__c != newContact.OwnerId) {
							if (accessLevel != 'None') {
								ContactSharesToInsert.add(new ContactShare(ContactId = newContact.Id,
								                                           UserOrGroupId = caSet.User__c,
								                                           ContactAccessLevel = accessLevel
								));
							}
							else if (isUpdate) {
								hasDeleteShareRecords = true;
								if (!first) { query += 'OR'; }
								query += '(contactId =\'' + newContact.Id + '\' and UserOrGroupId =\'' + caSet.User__c + '\')';
								first = false;
							}
						}
					}
				}
			}
		}
		if (!ContactSharesToInsert.isEmpty()) {
			try {
				insert ContactSharesToInsert;
			}
			catch(Dmlexception dEx) {
				Map<Id, Contact> errorAdder = new Map<Id, Contact> (newContacts);
				for (Integer i = 0; i<dEX.getNumDML(); i++)
				{
					errorAdder.get(ContactSharesToInsert[dEX.getDmlIndex(i)].contactId).addError(dEX.getDmlMessage(i));
				}
			}
		}
		if (hasDeleteShareRecords) {
			system.debug('ContactSharesToDelete query ' + query);
			ContactSharesToDelete = Database.query(query);
			if (!ContactSharesToDelete.isEmpty()) {

				if (System.isFuture() || System.isBatch())
				deleteContactShares(alm_pm2.Pluck.ids('id', ContactSharesToDelete));
				else
				deleteContactSharesFuture(alm_pm2.Pluck.ids('id', ContactSharesToDelete));

			}
		}
	}

	public void createContactShareRecords(List<Contact> newContacts, Boolean isUpdate) {
		if (UserInfo.getProfileId() == [Select Id From Profile Where Name = :Label.Customer_Community_User_Custom LIMIT 1].Id) {
			return;
		}

		List<ContactShare> ContactSharesToInsert = new List<ContactShare> ();
		List<ContactShare> ContactSharesToDelete = new List<ContactShare> ();
		Map<Id, List<CA_Setting__c>> chapterToCASetting = filterChapterCASetting(Pluck.ids('AccountId', newContacts));
		Boolean hasDeleteShareRecords = false;
		Boolean first = true;
		String query = 'Select Id, UserOrGroupId from ContactShare where ';
		for (Contact newContact : newContacts) {
			String rt = newContact.RecordType.DeveloperName;
			if (rtToAccess.containsKey(rt)) {
				String accessLevel = rtToAccess.get(rt);
				if (chapterToCASetting.containsKey(newContact.accountId)) {
					for (CA_Setting__c caSet : chapterToCASetting.get(newContact.accountId)) {
						Id adminId = caSet.User__c;
						if (adminId != null && adminId != newContact.OwnerId)
						{
							if (accessLevel != 'None') {
								ContactSharesToInsert.add(new ContactShare(ContactId = newContact.id,
								                                           UserOrGroupId = adminId,
								                                           ContactAccessLevel = accessLevel
								)
								);
							}
							else if (isUpdate) {
								hasDeleteShareRecords = true;
								if (!first) { query += 'OR'; }
								query += '(contactId =\'' + newContact.id + '\' and UserOrGroupId =\'' + adminId + '\')';
								first = false;
							}
						}
					}
				}
			}
		}
		if (!ContactSharesToInsert.isEmpty()) {
			try {
				insert ContactSharesToInsert;
			}
			catch(Dmlexception dEx) {
				Map<Id, Contact> errorAdder = new Map<Id, Contact> (newContacts);
				for (Integer i = 0; i<dEX.getNumDML(); i++)
				{
					errorAdder.get(ContactSharesToInsert[dEX.getDmlIndex(i)].contactId).addError(dEX.getDmlMessage(i));
				}
			}
		}
		if (hasDeleteShareRecords) {
			ContactSharesToDelete = Database.query(query);
			if (!ContactSharesToDelete.isEmpty()) {

				if (System.isFuture() || System.isBatch())
				deleteContactShares(alm_pm2.Pluck.ids('id', ContactSharesToDelete));
				else
				deleteContactSharesFuture(alm_pm2.Pluck.ids('id', ContactSharesToDelete));


			}
		}
	}
	//private static Map<Id, List<CA_Setting__c>> getChapterToCA(Set<Id> chapterIds){
	//return GroupBy.ids('Chapter__c', [Select User__c, Chapter__c from CA_Setting__c where Chapter__c =:chapterIds and isActive__c = true AND Role__c != 'Chapter Chair']);        
	//}
	public void deleteOldCreateNewShareRecords(List<Contact> newContacts, Map<Id, Contact> oldContacts) {
		List<ContactShare> ContactSharesToInsert = new List<ContactShare> ();
		List<Contact> contactsForContactShareInsert = new List<Contact> ();
		Map<Id, Id> contactIdToDeleteChapterId = new Map<Id, Id> ();
		Set<Id> allChapterIds = new Set<Id> ();
		for (Contact aContact : newContacts) {
			Id oldChapterId = oldContacts.get(aContact.id).accountId;
			if (aContact.accountId != oldChapterId) {
				contactsForContactShareInsert.add(aContact);
				if (oldChapterId != null) contactIdToDeleteChapterId.put(aContact.id, oldChapterId);
			}
		}
		if (!contactsForContactShareInsert.isEmpty()) {
			deleteContactShares(contactIdToDeleteChapterId, newContacts);
			createContactShareRecords(contactsForContactShareInsert, false);
		}
	}
	public void deleteContactShares(Map<Id, Id> contactIdToDeleteChapterId, List<Contact> newContacts) {
		Map<Id, Contact> newContactsMap = new Map<Id, Contact> (newContacts);

		Map<Id, List<CA_Setting__c>> chapterToCASetting = filterChapterCASetting(new Set<Id> (contactIdToDeleteChapterId.values()));
		Set<Id> ContactSharesToDelete = new Set<Id> ();
		String query = 'Select Id, ContactId, UserOrGroupId from ContactShare where ';
		Boolean first = true;
		Boolean hasDeleteShareRecords = false;
		for (Id contactId : contactIdToDeleteChapterId.keyset()) {
			Id chapterId = contactIdToDeleteChapterId.get(contactId);
			system.debug('chapterId ' + chapterId);
			if (chapterToCASetting.containsKey(chapterId))
			{
				hasDeleteShareRecords = true;
				for (CA_Setting__c caSet : chapterToCASetting.get(chapterId)) {
					if (!first) { query += 'OR'; }
					query += '(contactId =\'' + contactId + '\' and UserOrGroupId =\'' + caSet.User__c + '\')';
					first = false;
				}
			}
		}
		if (hasDeleteShareRecords) {
			for (ContactShare aContactShare : Database.query(query)) {
				if (aContactShare.UserOrGroupId != newContactsMap.get(aContactShare.contactId).ownerid)
				contactSharesToDelete.add(aContactShare.id);
			}
			if (!ContactSharesToDelete.isEmpty()) {
				if (System.isFuture() || System.isBatch())
				deleteContactShares(ContactSharesToDelete);
				else
				deleteContactSharesFuture(ContactSharesToDelete);

			}
		}
	}

	public static void deleteContactShares(Set<Id> contactShareIDs) {
		try {
			delete[Select Id from ContactShare where id in : contactShareIDs];
		}
		catch(Dmlexception dEx) {
			String sMessage = 'ERROR: An exception has occurred. Please contact your System Administrator quoting the following message -- '
			+ dEx.getTypeName() + ':' + dEx.getMessage() + ':' + dEx.getLineNumber() + ':' + dEx.getStackTraceString();


			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = Chapter_Health_Batch_Error_Email_Setting__c.getInstance().Error_Email_Recipients__c.split(';');
			//mail.setTreatTargetObjectAsRecipient(false);
			mail.setToAddresses(toAddresses);
			mail.setSubject('Exception occurred while deleting Contact Shares');

			String body = '<html lang="ja"><body>' +
			'<br><br>' +
			'This email alert is to bring to your notice that exception occured  while deleting leadshares' +
			'<br><br>' +
			'<b>' +
			'Here is detail of Exception ' +
			'</b>' +
			'<br><br>' + sMessage +
			'</body></html>';
			mail.setHtmlBody(body);
			//Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}
	@future
	public static void deleteContactSharesFuture(Set<Id> contactShareIDs) {
		deleteContactShares(contactShareIDs);
	}

	private static List<Contact> filterContactForCommunityUserCreation(List<Contact> contactList)
	{
		List<User> relatedUsers = [SELECT ContactId FROM User WHERE ContactId IN :contactList];
		Map<Id, List<User>> contactIdToUserMap = !relatedUsers.isEmpty() ? GroupBy.ids('ContactId', relatedUsers) : new Map<Id, List<User>> ();
		List<Contact> filteredContacts = new List<Contact> ();
		for (Contact thisContact : contactList)
		{
			//System.debug('in filter: active?:' + thisContact.Active__c + ' rtype:'+thisContact.RecordTypeId);
			if (thisContact.Active__c &&
			    thisContact.RecordTypeId == prospectRTCont &&
			    !contactIdToUserMap.containsKey(thisContact.Id))
			{
				filteredContacts.add(thisContact);
			}
		}
		return filteredContacts;
	}

	@TestVisible
	public static List<User> createCommunityUserForContact(List<Contact> contactList)
	{
		List<User> communityUserList = new List<User> ();

		for (Contact thisContact : contactList)
		{
			if (thisContact.Email != null) {
				String nkname = thisContact.Email.substring(0, thisContact.Email.indexOf('@')) + Datetime.now().getTime();
				if (nkName.length()> 40) {
					nkname = nkname.left(40);
				}
				String lName = '';
				if (thisContact.LastName.length()> 7) {
					lName = thisContact.LastName.substring(0, 7);
				} else {
					lName = thisContact.LastName;
				}
				communityUserList.add(new User(
				                               Alias = lName,
				                               Email = thisContact.Email,
				                               EmailEncodingKey = 'ISO-8859-1',
				                               FirstName = thisContact.FirstName,
				                               LastName = thisContact.LastName,
				                               LanguageLocaleKey = 'en_US',
				                               LocaleSidKey = 'en_us',
				                               ContactId = thisContact.Id,
				                               TimezoneSidKey = 'America/Chicago',
				                               Username = thisContact.Email,
				                               CommunityNickname = nkname,
				                               ProfileId = customerCommunityUserProfileId,
				                               IsActive = true,
				                               FederationIdentifier = thisContact.GUID__c.toLowerCase()
				));
			}
		}

		return communityUserList;
	}

	@TestVisible
	public static void insertCommunityUsers(List<User> userList, Map<Id, Contact> relatedContactMap)
	{
		Database.DMLOptions dmlOptions = new Database.DMLOptions();
		dmlOptions.EmailHeader.triggerUserEmail = false;
		dmlOptions.EmailHeader.triggerOtherEmail = false;
		dmlOptions.EmailHeader.triggerAutoResponseEmail = false;
		dmlOptions.OptAllOrNone = false;
		System.debug('UserList object: ' + userlist);

		List<Database.SaveResult> dmlResults = Database.insert(userList, dmlOptions);
		for (Integer i = 0; i<dmlResults.size(); i++)
		{
			Database.SaveResult dmlResult = dmlResults[i];
			if (!dmlResult.isSuccess())
			{
				String errorMessage = '';
				for (Database.Error error : dmlResult.getErrors())
				{
					errorMessage += error.getStatusCode() + ': ' + error.getMessage() + ';';
				}
				relatedContactMap.get(userList[i].ContactId).addError(errorMessage);
			}
		}
	}

	public static void contactCommunityUserCreation(Map<Id, Contact> contactMap)
	{
		List<Contact> filteredContacts = filterContactForCommunityUserCreation(contactMap.values());
		if (!filteredContacts.isEmpty())
		{
			insertCommunityUsers(createCommunityUserForContact(filteredContacts), contactMap);
		}
	}

	public static String getCountryCodeValue(String CountryLabel) {
		String CountryCode = '';
		if (CountryLabel<> null && CountryLabel<> '') {
			Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for (Schema.PicklistEntry f : ple) {
				if (CountryLabel == f.getLabel()) {
					CountryCode = f.getValue();
					break;
				}
			}
		}
		return CountryCode;
	}

	public static String getStateCodeValue(String StateLabel) {
		String StateCode = '';
		if (StateLabel<> null && StateLabel<> '') {
			Schema.DescribeFieldResult fieldResult = User.statecode.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for (Schema.PicklistEntry f : ple) {
				if (StateLabel == f.getLabel()) {
					StateCode = f.getValue();
					break;
				}
			}
		}
		return StateCode;
	}

	public static boolean displayGraceModal(Opportunity Oppt) {
		if(Oppt.Grace_Status__c != 'No Grace Needed'){
			return true;
		} else {
			return false;
		}
    }

	public static boolean displayTransitionModal(Opportunity Oppt) {
		if(Oppt.Transition_Flag__c == true){
			return true;
		} else {
			return false;
		}
    }

}