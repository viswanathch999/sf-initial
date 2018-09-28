global without sharing class UpdateProfileInfoController_YPO {

	public Contact con { set; get; }
	//public Relationship__c RelationAccount { set; get; }
	public Relationship__c RelationSpouse { set; get; }
	public Contact Spousecontact { set; get; }
	//public List<Relationship__c> relationChild {set;get;} 
	public List<Contact> Childcontact { set; get; }

	//public Contact AddFamilyMemberContact { set; get; }
	//public Contact UpdatedSpouseChild { set; get; }
	public Boolean isProfileCertificationPagesCompleted { set; get; }
	public Contact StateCountryContact { set; get; }
	public String RelationshipAccId { set; get; }
	public String AddressLine1 { set; get; }
	public String AddressLine2 { set; get; }
	public Opportunity relatedOpp { get; set; }
	Id conId = null;
	public static final String CONST_CONTACT = 'Contact';
	public static final String CONST_SPOUSE = 'Spouse_Partner';
	public static final String CONST_CHILD = 'Child';
	public static final String CONST_MEMBER = 'Member';
	public static final String CONST_PROSPECT = 'Prospect';
	@TestVisible static final String TRANSITION_STATUS_OVERDUE = 'Scheduled for transition';
	public static final Id prospectRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_PROSPECT, CONST_CONTACT).Id;
	public static final String PROFILE_STATUS_NOT_STARTED = 'Not Started';
	public static final String PROFILE_STATUS_IN_PROGRESS = 'In Progress';
	public static final String PROFILE_STATUS_COMPLETE = 'Complete';
	public static final String CONST_ACCOUNT = 'Account';
	public static final String HOUSEHOLD_ACCOUNT_RECORDTYPE_NAME = 'Relationship';
	Id AccountHouseHoldRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(HOUSEHOLD_ACCOUNT_RECORDTYPE_NAME, CONST_ACCOUNT).Id;

	//public List<Contact> lstSpouse { get { System.debug('The spouse: ' + lstSpouse);
			//return lstSpouse;
		//} private set; }
	//public List<Contact> lstChild { get; private set; }
	//public List<Contact> lstFamilyMember { set; get; }
	//public boolean bRelationshipPresent { get; private set; }
	Account oHouseHoldAccount;
	Relationship__c oRelationship;

	public Id spouseRecordTypeId {
		get {
			if (spouseRecordTypeId == null)
			{
				spouseRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_SPOUSE, CONST_CONTACT).Id;
			}
			return spouseRecordTypeId;
		} set; }
	Public Id childRecordTypeId {
		get {
			if (childRecordTypeId == null)
			{
				childRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_CHILD, CONST_CONTACT).Id;
			}
			return childRecordTypeId;
		} set; }
	String sLastName;

	public UpdateProfileInfoController_YPO(ApexPages.StandardController oStandardController) {
        try {
            if((Contact)oStandardController.getRecord()!= new Contact()){
                conId = (id)oStandardController.getid();
            } else {
                User oUser = [Select Id,ContactId from User where Id =: UserInfo.getUserId()];
                if (oUser.ContactId != null) {
					conId =  oUser.ContactId;
                } else {
					conId = null;
                    throw new CustomException('No member Contact record found!');
                }
            }
			queryContact();

        } catch (CustomException CExcp) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, CExcp.getMessage()));
        } 

	}

	public PageReference saveOpportunity() {
		PageReference pr = null;
		Opportunity tOpp = ContactServices.getOpportunities(con);
		System.debug('###tOpp inside saveOpportunity(): ' + tOpp);

		if (tOpp != null) {

			if (con.RecordTypeId != prospectRecordTypeId) {
				//Item-07406 (Item-07405)
				System.debug('Grace Status: ' + tOpp.Grace_Status__c);
				System.debug('Transition Flag: ' + tOpp.Transition_Flag__c);
				System.debug('Certification Type: ' + tOpp.Certification_Type__c);
				System.debug('Transition Status: ' + con.Transition_Status__c);
				System.debug('Dues Page Status (Exchange): ' + tOpp.Dues_Page_Status_Exchange__c);
				if (tOpp.Grace_Status__c != null && tOpp.Grace_Status__c != 'No Grace Needed') {
					System.debug('#####tOpp - Marked for Grace: ' + tOpp.Grace_Status__c);
					if (tOpp.Dues_Page_Status_Exchange__c == 'In Progress') {
						//Goto Invoice page
						pr = Page.Checkout_Check_Wire_YPO;
						pr.setRedirect(true);
						if (!string.isBlank(tOpp.CartToken__c)) {
							pr.getParameters().put('ct', EncodingUtil.urlDecode(tOpp.CartToken__c, 'UTF-8'));
						}
						pr.getParameters().put('Modal', 'Grace');
					} 
					else if (tOpp.Dues_Page_Status_Exchange__c == 'Complete') {
						//Payment has been completed, goto Thank you page
						pr = page.splashscreen_thankyou;
						pr.setRedirect(true);
						pr.getParameters().put('Id', con.Id);
						pr.getParameters().put('Modal', 'Grace');
					} 
					else {
						// tOpp.Dues_Page_Status_Exchange__c == 'Not Started')
						pr = Page.Catalog_YPO;
						pr.setRedirect(true);
						if (!string.isBlank(tOpp.CartToken__c)) {
							pr.getParameters().put('ct', EncodingUtil.urlDecode(tOpp.CartToken__c, 'UTF-8'));
						}
						pr.getParameters().put('Modal', 'Grace');
					}
				} 
				else if (tOpp.Transition_Flag__c == true) {
					System.debug('#####tOpp - Marked for Transition: ' + tOpp.Transition_Flag__c);
					if (tOpp.Dues_Page_Status_Exchange__c == 'In Progress') {
						//Goto Invoice page
						pr = Page.Checkout_Check_Wire_YPO;
						pr.setRedirect(true);
						if (!string.isBlank(tOpp.CartToken__c)) {
							pr.getParameters().put('ct', EncodingUtil.urlDecode(tOpp.CartToken__c, 'UTF-8'));
						}
						pr.getParameters().put('Modal', 'Transition');
					} 
					else if (tOpp.Dues_Page_Status_Exchange__c == 'Complete') {
						//Payment has been completed, goto Thank you page
						pr = page.splashscreen_thankyou;
						pr.setRedirect(true);
						pr.getParameters().put('Id', con.Id);
						pr.getParameters().put('Modal', 'Transition');
					} 
					else {
						// tOpp.Dues_Page_Status_Exchange__c == 'Not Started')
						pr = Page.Catalog_YPO;
						pr.setRedirect(true);
						if (!string.isBlank(tOpp.CartToken__c)) {
							pr.getParameters().put('ct', EncodingUtil.urlDecode(tOpp.CartToken__c, 'UTF-8'));
						}
						pr.getParameters().put('Modal', 'Transition');
					}
				} 
				else if (tOpp.Certification_Type__c == 'No Certification Needed' || tOpp.Certification_Type__c == null) {
					System.debug('#####tOpp - Marked for No Certification: ' + tOpp.Certification_Type__c);
					//Send to YPO Gold
					pr = Page.Recertification_Screen;
					pr.setRedirect(true);
					pr.getParameters().put('Id', con.Id);
				} 
				else if (con.Transition_Status__c == 'Scheduled for transition') {
					System.debug('#####tOpp - Marked for Scheduled Transition');
					//Send to YPO Gold
					pr = Page.Gold_Transition_Option_YPO;
					pr.setRedirect(true);
					pr.getParameters().put('Id', con.Id);
				} 
				else {
					System.debug('#####tOpp - Marked for Recertification');
					//Send to Cert Screen
					pr = Page.Recertification_Screen;
					pr.setRedirect(true);
					pr.getParameters().put('Id', con.Id);
				}

			} 
			else if (con.RecordTypeId == prospectRecordTypeId) {
				pr = Page.ChooseANetwork_YPO;
				pr.setRedirect(true);
				pr.getParameters().put('Id', con.Id);
			}
		} 
		else {
			pr = null;
		}

		try {
			tOpp.Profile_Page_Status_Exchange__c = PROFILE_STATUS_COMPLETE;
			update tOpp;

		} catch(Exception expt) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'We are having an issue updating your Opportunity record.  Please contact member Services!'));
		}

		return pr;
	}

	public void queryContact() {
		if (conId<> null) {
			try {
				con = [select Id, Name, AccountId, Date_Last_Profile_Updated__c, HomePhone, Home_Phone_Country_Code__c, Home_Phone_Extension__c, Business_Phone_Ext__c, FirstName, LastName, Email, MobilePhone, Phone, salutation, suffix__c, middle_name__c, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, MailingStateCode, MailingCountryCode,
					   Account.Name, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingCountry, Account.BillingPostalCode, Account.Phone, Country_Code__c, Mobile_Phone_Country_Code__c,
					   RecordTypeId, Membership_Status__c, Join_Date__c, Transition_Status__c, YPO_WPO_Formula__c, Address1_Type__c, Address2_Type__c, IS_Address1_Private__c, Is_Address1_Primary__c, Is_Address2_Primary__c, OtherStreet, OtherCity, OtherState, OtherCountry, OtherPostalCode, OtherStateCode, OtherCountryCode FROM Contact WHERE Id = :conId];
				StateCountryContact = con;
				if (con.Is_Address2_Primary__c == true) {
					StateCountryContact.Address1_Type__c = con.Address2_Type__c;
					StateCountryContact.MailingCountryCode = con.OtherCountryCode;
					//StateCountryContact.MailingCountry = con.OtherCountry;
					StateCountryContact.MailingStreet = con.OtherStreet;
					StateCountryContact.MailingCity = con.OtherCity;
					StateCountryContact.MailingStateCode = con.OtherStateCode;
					//StateCountryContact.MailingState = con.OtherState;
					StateCountryContact.MailingPostalCode = con.OtherPostalCode;
					StateCountryContact.Is_Address1_Private__c = con.Is_Address2_Private__c;
				}

				System.debug('MailingStreet: ' + StateCountryContact.MailingStreet );
				If (StateCountryContact.MailingStreet != null && StateCountryContact.MailingStreet != '') {
					String[] addressLines = StateCountryContact.MailingStreet.split('\r\n');

					for (Integer i = 0; i<addressLines.size(); i++)
					{
						if (i == 0) {
							AddressLine1 = addressLines[0];
						}

						if (i == 1) {
							AddressLine2 = addressLines[1];
						}
					}
				}
			System.debug('Address Breakup 1:' + AddressLine1 + ' 2:' + AddressLine2);

				try {
					List<Relationship__c> oRelationshiplist = [SELECT Id, Account__c FROM Relationship__c WHERE Contact__c = :conId AND Is_Active__c = true AND Relationship_Type__c = :CONST_MEMBER Limit 1];

					if (oRelationshiplist<> null && oRelationshiplist.size() > 0) {
						oRelationship = oRelationshiplist[0];
					} else {
						throw new CustomException('No member Relationship record found! Please Contact member services.'); 
					}

					RelationshipAccId = oRelationship.Account__c;
					//relationAccount = [select id, Contact__c, Account__c from relationship__c where Relationship_Type__c = 'Member' and contact__c = :con.Id Limit 1];
				}
				catch(Exception ex) {
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
				}

				try {
					relationSpouse = [select id, Relationship_Type__c, Contact__c, Account__c from relationship__c where Relationship_Type__c = 'Spouse/Partner' and account__c = :RelationshipAccId and Is_Active__c = true Limit 1];
					Spousecontact = [select id, gender__c, salutation, FirstName, middle_name__c, LastName, Email, MobilePhone, suffix__c, Phone, HomePhone, home_phone_country_code__c, home_phone_extension__c, birthdate, Portal_Access_Level__c from contact where id = :relationSpouse.Contact__c Limit 1];
				}
				catch(Exception ex) {

				}

				try {
					Childcontact = [select id, gender__c, salutation, FirstName, middle_name__c, LastName, Email, MobilePhone, suffix__c, HomePhone, home_phone_country_code__c, home_phone_extension__c, birthdate, Portal_Access_Level__c, Active__c from contact where id in(select contact__c from relationship__c where Relationship_Type__c = 'Child' and account__c = :RelationshipAccId and Is_Active__c = true)];
				}
				catch(Exception ex) {

				}
			} catch (Exception ex) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'We are having an issue finding your contact record.  Please contact member Services!'));
			}
		}

	}

	//public void populateExistingSpouseAndChildrens() {
		//system.debug('----oRelationship----' + oRelationship);
		//if (oRelationship == null)
		//{
			//try {
				//List<Relationship__c> oRelationshiplist = [SELECT Id, Account__c FROM Relationship__c WHERE Contact__c = :conId AND Is_Active__c = true AND Relationship_Type__c = :CONST_MEMBER Limit 1];

				//if (oRelationshiplist<> null && oRelationshiplist.size()> 0) {
					//oRelationship = oRelationshiplist[0];
				//}

				//system.debug('----try block  122 ----' + oRelationship);

				////TODO - remove creation of household (it will ALWAYS exist)
				//// Create a house hold account if no relationship exist to the profile contact:
				//if (oRelationship == null) {
					//Account householdAcc = new Account();
					//householdAcc.Name = con.Name + ' Household';
					//householdAcc.RecordTypeId = AccountHouseHoldRecordTypeId;
					//householdAcc.Type = 'Relationship';
					//insert householdAcc;

					//system.debug('---- householdAcc  133 ----' + householdAcc);

					//RelationshipAccId = householdAcc.Id;
					//Relationship__c remoteRelationship = Utility.createRelationship(conId, RelationshipAccId, 'Member');

					//insert remoteRelationship;

					//system.debug('---- remoteRelationship  139 ----' + householdAcc);

					//oRelationship = remoteRelationship;
				//}
				//else {
					//RelationshipAccId = oRelationship.Account__c;
				//}
				//bRelationshipPresent = true;

			//}
			//catch(Exception oDmlException) {
				//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_Relationship_Record_Found));
				//bRelationshipPresent = false;
			//}
		//}
		//system.debug('&&&&&&&&&&&&&oRelationship&&&&&&&&&&&&&&&&&&' + oRelationship);
		//Set<String> spouseAndChildrenFields = new Set<String> ();
		//for (Schema.FieldSetMember field : SObjectType.Contact.FieldSets.Spouse.getFields()) {
			//spouseAndChildrenFields.add(field.getFieldPath());
		//}
		//for (Schema.FieldSetMember field : SObjectType.Contact.FieldSets.Child.getFields()) {
			//spouseAndChildrenFields.add(field.getFieldPath());
		//}
		//spouseAndChildrenFields.add('recordtypeid');
		//spouseAndChildrenFields.add('Birthdate');
		//lstSpouse = new List<Contact> ();
		//lstChild = new List<Contact> ();
		//lstFamilyMember = new List<Contact> ();

		//if (con.AccountId != null && oRelationship<> null) {
			//List<Contact> spouseAndChildrenContacts = new List<Contact> ();
			//spouseAndChildrenContacts = Database.query('Select Id, ' + String.join(new List<String> (spouseAndChildrenFields), ',') +
			                                           //' from Contact where accountid = \'' + oRelationship.Account__c + '\'' +
			                                           //' and id != \'' + conId + '\'');
			//if (!spouseAndChildrenContacts.isEmpty()) {
				//for (Contact aCon : spouseAndChildrenContacts) {
					//System.debug(aCon);
					//if (aCon.recordTypeId == spouseRecordTypeId)
					//lstSpouse.add(aCon);
					//else if (aCon.recordTypeId == childRecordTypeId)
					//lstChild.add(aCon);
				//}
			//}
		//}
	//}

	/**
	 * Remote Action for the Spouse Child
	 * */

	@RemoteAction
	global static void updateContactProfile(String contactJSONStr) {
		system.debug('*******contactJSONStr******' + contactJSONStr);
		try {
			Contact c = (Contact) JSON.deserialize(contactJSONStr, Contact.class);

			system.debug('*******Contact C******' + c);
			c.Date_Last_Profile_Updated__c = System.today();
			if (c<> null && c.Id<> null) {
				update c;
			}

		} catch(Exception e) {
			system.debug('**********updateContactProfile in Remote Action ************' + e);
		}

	}

	public void updateLastProfileUpdatedOnContact()
	{
		// Update Contact Last Profile Updated Field
		//try {
			//populateExistingSpouseAndChildrens();

			// Update Related Opportunity Profile Status            
			try {
				relatedOpp = ContactServices.getOpportunities(con);
				System.debug('###relatedOpp in try: ' + relatedOpp);
				if (relatedOpp.Profile_Page_Status_Exchange__c<> PROFILE_STATUS_COMPLETE) {
					relatedOpp.Profile_Page_Status_Exchange__c = PROFILE_STATUS_IN_PROGRESS;
					update relatedOpp;
				}
				if (relatedOpp.Profile_Page_Status_Exchange__c == PROFILE_STATUS_COMPLETE &&
				(relatedOpp.Certification_Page_Status_Exchange__c == PROFILE_STATUS_COMPLETE || relatedOpp.Certification_Page_Status_Exchange__c == PROFILE_STATUS_IN_PROGRESS))
				isProfileCertificationPagesCompleted = true;
				else isProfileCertificationPagesCompleted = false;

			} catch(DMLException dmlExc) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, dmlExc.getMessage()));
			} catch(Exception exc) {
				//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Current Fiscal Year Opportunity missing or could not be retrieved.'));
				//Reported from ContactServices.getOpportunities
			}
		//} catch(Exception Excpt) {
			//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Contact missing or could not be updated. Please contact Member Services. '));
		//}

	}

	@RemoteAction
	global static List<Contact> getAllSpouseChilds(String conId, String accId) {
		List<Relationship__c> relationships = [SELECT Contact__c FROM Relationship__c WHERE Is_Active__c = true AND Account__c = :accId AND Contact__c != :conId];

		List<Contact> con = [Select Id, AccountId, recordTypeId, FirstName, LastName, Email, MobilePhone, Phone, Birthdate, Gender__c,
		                     MailingStreet, MailingCity, MailingStateCode, MailingCountryCode, MailingPostalCode, Mobile_Phone_Country_Code__c, Portal_Access_Level__c
		                     FROM Contact WHERE Id IN :PLuck.ids('Contact__c', relationships)];
		return con;
	}
	@RemoteAction
	global static Contact getAContact(String conId) {
		Contact con = [Select Id, Salutation, FirstName, Middle_Name__c, LastName, Suffix__c, Email, Home_Phone_Country_Code__c, HomePhone, Home_Phone_Extension__c,
		               Mobile_Phone_Country_Code__c, MobilePhone, Country_Code__c, Phone, Business_Phone_Ext__c, AccountId, recordTypeId, Date_Last_Profile_Updated__c,
		               Is_Address1_Primary__c, Address1_Type__c, Is_Address1_Private__c, MailingStreet, MailingCity, MailingState, MailingStateCode, MailingCountry, MailingCountryCode, MailingPostalCode,
		               Is_Address2_Primary__c, Address2_Type__c, Is_Address2_Private__c, OtherStreet, OtherCity, OtherState, OtherStateCode, OtherCountry, OtherCountryCode, OtherPostalCode,
		               Salesforce_Access_from_Exchange__c, Gender__c, Birthdate FROM Contact WHERE Id = :conId limit 1];
		return con;
	}


	@RemoteAction
	global static Boolean isDuplicateEMail(String emailId, String contactId) {
		Boolean isDuplicate = false;
		if (emailId<> null && emailId<> '') {
			Id contactIdCheck = null;
			if (contactId<> null && contactId<> '')
			contactIdCheck = contactId;
			List<Contact> dupEmailConList = [select Id, Name, Email FROM Contact Where Email = :emailId AND Id<> :contactIdCheck];

			if (dupEmailConList<> null && (!dupEmailConList.isEmpty()) && dupEmailConList.size() > 0)
			isDuplicate = true;
		}
		return isDuplicate;
	}


	//TODO : update to take in additional accountId param (chapter account id NOT household account id) and populate this ID on the contact AcctId for all s/p or children.
	@RemoteAction
	global static void updateSpouseChild(String firstName, String lastName, String gender, String email, String phone, String portalAccesslevel, String spchconId,
	                                     String SpouseChildRecordTypeId, String sposeChildRelationshipType, String RelationshipAccountId, String ChapterAccountId,
	                                     String Active, String Prefix, String MiddleName, String Suffix, String PhoneCC, String PhoneExt, String dob) {

		Contact oCon = new Contact();
		//System.debug('-----spchconId------'+spchconId);
		//System.debug('-----SpouseChildRecordTypeId------'+SpouseChildRecordTypeId);
		System.debug('-----sposeChildRelationshipType------' + sposeChildRelationshipType);
		System.debug('-----RelationshipAccountId------' + RelationshipAccountId);
		System.debug('-----firstName------' + firstName);
		System.debug('-----ChapterAccountId------' + ChapterAccountId);
		//System.debug('-----dob------'+dob);        
		if (spchconId<> null && spchconId<> '') {
			oCon.id = spchconId;
			//Can only de-activate an existing individual.
			if (Active == 'false') {
				relationship__c InActiveContact = [select Id, Is_Active__c from relationship__c where contact__c = :spchconId];
				InActiveContact.Is_Active__c = false;

				update InActiveContact;
			}
		} else {
			oCon.RecordTypeId = (Id) SpouseChildRecordTypeId;
			oCon.AccountId = (Id) ChapterAccountId;
		}
		oCon.FirstName = firstName;
		oCon.LastName = lastName;
		oCon.Gender__c = gender;
		oCon.Portal_Access_Level__c = portalAccesslevel;
		Date birthdate;
		if (dob<> null && dob<> '') {
			oCon.Birthdate = Date.valueOf(dob);
		}
		oCon.Email = email;
		oCon.HomePhone = phone;
		oCon.Salutation = Prefix;
		oCon.Middle_Name__c = MiddleName;
		oCon.Suffix__c = Suffix;
		oCon.Home_Phone_Country_Code__c = PhoneCC;
		oCon.Home_Phone_Extension__c = PhoneExt;

		try {
			upsert oCon;
			if (spchconId<> null && spchconId<> '') {

			}
			else {
				Relationship__c remoteRelationship = Utility.createRelationship(oCon.Id, (Id) RelationshipAccountId, sposeChildRelationshipType);
				insert remoteRelationship;
			}
		} catch(Exception e) { system.debug('------@RemoteAction---updateSpouseChild----' + e.getMessage()); }
	}
}