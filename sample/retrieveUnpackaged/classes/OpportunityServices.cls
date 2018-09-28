public without sharing class OpportunityServices {
	Static Final String TEMPLATE_NAME = 'YNG_Notifications_to_Member_and_Child_Closed_Won';
	Static Final String YNG = 'YNG';
	Static Final String PAYMENT_RECEIVED = 'Payment Received';
	Static Final String STAGE_NEW = 'New';
	Static Final String STAGE_CYCLE_OPEN = 'Cycle Open';
	public Static Final String MEMBER = 'Member';
	Static Final String Prospect_Opp_RtName = 'Prospect';
	Static Final String Member_Opp_RtName = 'Member';
	Static Final String Former_Member_Opp_RtName = 'Former Member';
	Static FINAL String CLOSED_WON = 'Closed Won';
	static final string LIFE_TIME_PAYING = 'In Payment Cycle';
	Static Final Map<String, RecordTypeInfo> recordTypeMap = RecordTypeServices.getRecordType('Opportunity');
	Static Final Set<String> Cert_Status = new Set<String> { 'Complete', 'Validated' };
	Static Final Set<String> Grace_Status = new Set<String> { 'No Grace Needed', 'Approved' };
	//public static boolean runTrigger = false;

	public static boolean runTrigger {
		get {
			if (runTrigger == null) {
				runTrigger = false;
			}

			return runTrigger;
		} set;
	}

	public Static Id Opp_Memeber_RT_Id {
		get {
			if (Opp_Memeber_RT_Id == null)
			Opp_Memeber_RT_Id = RecordTypeServices.getRecordTypeByName(Member_Opp_RtName,'Opportunity').id;
			return Opp_Memeber_RT_Id;
		} private set; }

	public Static Id Opp_Prospect_RT_Id {
		get {
			if (Opp_Prospect_RT_Id == null)
			Opp_Prospect_RT_Id = RecordTypeServices.getRecordTypeByName(Prospect_Opp_RtName,'Opportunity').id;
			return Opp_Prospect_RT_Id;
		} private set; }

	public Static Id Opp_Former_Member_RT_Id {
		get {
			if (Opp_Former_Member_RT_Id == null)
			Opp_Former_Member_RT_Id = RecordTypeServices.getRecordTypeByName(Former_Member_Opp_RtName,'Opportunity').id;
			return Opp_Former_Member_RT_Id;
		} private set; }

	public Static Id Contact_Memeber_RT_Id {
		get {
			if (Contact_Memeber_RT_Id == null)
			Contact_Memeber_RT_Id = RecordTypeServices.getRecordType('Contact').get('Member').getRecordTypeId();
			return Contact_Memeber_RT_Id;
		} private set; }


	public static List<Opportunity> filterPaymentReceivedOpps(List<Opportunity> allOpportunities, Map<Id, Opportunity> oldOpportunities) {
		List<Opportunity> filteredOpportunities = new List<Opportunity> ();
		Boolean isUpdate = false;
		if (!oldOpportunities.isEmpty()) isUpdate = true;
		for (Opportunity newOpp : allOpportunities) {
			if (newOpp.stageName == CLOSED_WON && newOpp.stageName != oldOpportunities.get(newOpp.id).stageName)
			filteredOpportunities.add(newOpp);
		}
		return filteredOpportunities;
	}
	public static void sendEmails(List<Opportunity> filteredOpportunities) {
		if (filteredOpportunities != null && !filteredOpportunities.isEmpty()) {
			Id YNG_TemplateId;
			List<EmailTemplate> templates = [Select Id from EmailTemplate where DeveloperName = :TEMPLATE_NAME];
			if (!templates.isEmpty()) {
				YNG_TemplateId = templates[0].id;
				List<Messaging.SingleEmailMessage> messagesToBeSent = new List<Messaging.SingleEmailMessage> ();
				Map<Id, Set<Id>> mapOfOppIdToContactIds = new Map<Id, Set<Id>> ();
				mapOfOppIdToContactIds = getMapofOppIdToContactIds(alm_pm2.Pluck.ids('id', filteredOpportunities));
				for (Opportunity aOpp : filteredOpportunities) {
					if (mapOfOppIdToContactIds.containsKey(aOpp.id)) {
						for (Id memberId : mapOfOppIdToContactIds.get(aOpp.id)) {
							Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
							email.setWhatId(aOpp.id);
							email.setTemplateId(YNG_TemplateId);
							email.setTargetObjectId(memberId);
							email.setSaveAsActivity(true);
							messagesToBeSent.add(email);
						}
						//also send the email to the member on the opportunity
						Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
						email.setWhatId(aOpp.id);
						email.setTemplateId(YNG_TemplateId);
						email.setTargetObjectId(aOpp.KGRenewal__Contact__c);
						email.setSaveAsActivity(true);
						messagesToBeSent.add(email);
					}
				}

				try {
					Messaging.sendEmail(messagesToBeSent);
				}
				catch (System.EmailException ex) {
					if (ex.getDmlType(0) == StatusCode.EMAIL_ADDRESS_BOUNCED) { 
						System.debug('Error encountered in OpportunityServices.sendEmails: ' + ex.getMessage());
					}
				}
			}
		}
	}
	public static Map<Id, Set<Id>> getMapOfOppIdToContactIds(Set<Id> oppIds) {
		Map<Id, Set<Id>> mapOfOppIdToContactIds = new Map<Id, Set<Id>> ();
		System.debug('Pluckid Set returned: ' + oppIds.size());
		List<opportunitylineitem> Cartlist = [Select OpportunityId, Contact__c, Product2.Exclusive__c From OpportunityLineItem Where OpportunityId IN :oppIds];
		for (opportunitylineitem cartitem:cartlist) {
			System.debug('Cart item: ' + cartitem.OpportunityId + '/' + cartitem.Contact__c + '/' + cartitem.Product2.exclusive__c);
		}
		for (OpportunityLineItem aOLI :[Select OpportunityId, Contact__c From OpportunityLineItem Where Product2.Exclusive__c = :YNG AND OpportunityId IN :oppIds and Contact__c != null]){
			if (!mapOfOppIdToContactIds.containsKey(aOLI.OpportunityId)){
				mapOfOppIdToContactIds.put(aOLI.OpportunityId, new Set<Id> ());
			}
			mapOfOppIdToContactIds.get(aOLI.OpportunityId).add(aOLI.Contact__c);
		}
		return mapOfOppIdToContactIds;
	}
	public static List<Opportunity> filterOppsTobeMarkedClosedWon(List<Opportunity> allOpportunities, Map<Id, SObject> oldMap) {
		List<Opportunity> filteredOpportunities = new List<Opportunity> ();
		System.debug('oldMap status: ' + (oldMap == null));
		if (!runTrigger) {
			for (Opportunity newOpp : allOpportunities) {
				System.debug('Opp Name: ' + newOpp.name);
				System.debug('Stage: ' + newOpp.stageName);
				System.debug('RecordType: ' + newOpp.Record_Type_Name__c);
				System.debug('Cert Stat: ' + newOpp.Certification_Status__c);
				System.debug('Grace: ' + newOpp.Grace_Status__c);

				Boolean stage = newOpp.stageName == Payment_Received;
				Boolean rTypeProspect = newOpp.Record_Type_Name__c == Prospect_Opp_RtName;
				Boolean rTypeMember = newOpp.Record_Type_Name__c == Member_Opp_RtName;
				Boolean rTypeFormerMember = newOpp.Record_Type_Name__c == Former_Member_Opp_RtName;
				Boolean certStat = Cert_Status.contains(newOpp.Certification_Status__c);
				Boolean graceStat = Grace_Status.contains(newOpp.Grace_Status__c);

				Boolean stageChange = false;
				Boolean rTypeChange = false;
				Boolean certStatChange = false;
				Boolean graceChange = false;

				if (oldMap != null) {
					stageChange = newOpp.stageName != oldMap.get(newOpp.Id).get('stageName');
					rTypeChange = newOpp.Record_Type_Name__c != oldMap.get(newOpp.Id).get('Record_Type_Name__c');
					certStatChange = newOpp.Certification_Status__c != oldMap.get(newOpp.Id).get('Certification_Status__c');
					graceChange = newOpp.Grace_Status__c != oldMap.get(newOpp.Id).get('Grace_Status__c');
				}

				if (rTypeMember) {
					if (oldMap != null && (stage && rTypeMember && certStat && graceStat) && (stageChange || rTypeChange || certStatChange || graceChange)) {
						filteredOpportunities.add(newOpp);
					} else if (oldMap == null && (stage && rTypeMember && certStat && graceChange)) {
						filteredOpportunities.add(newOpp);
					}
				}
				else if (rTypeFormerMember) {
					if (oldMap != null && (stage && rTypeFormerMember && certStat && graceStat) && (stageChange || rTypeChange || certStatChange || graceChange)) {
						filteredOpportunities.add(newOpp);
					} else if (oldMap == null && (stage && rTypeFormerMember && certStat && graceChange)) {
						filteredOpportunities.add(newOpp);
					}
				}
				else if (rTypeProspect) {
					if (oldMap != null && (stage && rTypeProspect && certStat) && (stageChange || rTypeChange || certStatChange)) {
						filteredOpportunities.add(newOpp);
					} else if (oldMap == null && (stage && rTypeProspect && certStat)) {
						filteredOpportunities.add(newOpp);
					}
				}


			}
		}
		if (!filteredOpportunities.isEmpty())
		runTrigger = true;


		return filteredOpportunities;
	}
	@future
	public static void markOppsAsClosedWonFuture(List<Id> filteredOpportunityIds) {
		List<Opportunity> filteredOpportunities = [Select Id, Opportunity_Type__c, Organization_Type__c, President_Type__c, Firm_Type__c, Business_Scope__c, Enterprise_Type__c
													, Title__c, Title_Other__c, AccountId, StageName, Contact_Id__c, RecordTypeId, KGRenewal__Contact__c
												   From Opportunity Where Id IN :filteredOpportunityIds];
		markOppsAsClosedWon(filteredOpportunities);
	}

	public static void markOppsAsClosedWon(List<Opportunity> filteredOpportunities) {
		//This will call the method to execute the flow yng child update  if necessary 
		opportunityYNGChildFlow(filteredOpportunities);

		List<Contact> contactsToUpdate = new List<Contact> ();
		List<Opportunity> oppsToUpdate = new List<Opportunity> ();
		List<Membership_History__c> membershipHistoryRecordsToCreate = new List<Membership_History__c> ();
		Set<Id> filteredContactIds = new Set<Id> ();
		Map<Id, List<Opportunity>> contactToOpps = new Map<Id, List<Opportunity>> ();

		for (Opportunity filteredOpp : filteredOpportunities) {

			filteredOpp.stageName = CLOSED_WON;
			if (filteredOpp.recordTypeId != Opp_Memeber_RT_Id) {
				filteredOpp.Contact_ID__c = filteredOpp.KGRenewal__Contact__c;
				filteredOpp.recordTypeId = Opp_Memeber_RT_Id;
				oppsToUpdate.add(filteredOpp);
				if (!contactToOpps.containsKey(filteredOpp.KGRenewal__Contact__c))
				contactToOpps.put(filteredOpp.KGRenewal__Contact__c, new List<Opportunity> ());
				contactToOpps.get(filteredOpp.KGRenewal__Contact__c).add(filteredOpp);

				Contact updateContact = new Contact();
				updateContact.Id = filteredOpp.KGRenewal__Contact__c;
				updateContact.Join_Date__c = System.today();
				updateContact.Member_Forum_Status__c = 'Pending Placement';

				if (filteredOpp.Opportunity_Type__c == 'Prospect' || filteredOpp.Opportunity_Type__c == 'Renewal' || filteredOpp.Opportunity_Type__c == 'Reinstatement') {
					updateContact.President_Type__c = filteredOpp.President_Type__c;
					updateContact.Corporation_Type_Contact__c = filteredOpp.Organization_Type__c;
					updateContact.Firm_Type__c = filteredOpp.Firm_Type__c;
					updateContact.Business_Scope__c = filteredOpp.Business_Scope__c;
					updateContact.Enterprise_Type__c = filteredOpp.Enterprise_Type__c;
					if (filteredOpp.Title__c != null && filteredOpp.Title__c != '') {
						updateContact.Original_Title__c = filteredOpp.Title__c;
					}
					if (filteredOpp.Title_Other__c != null && filteredOpp.Title_Other__c != '') {
						updateContact.Title_Other__c = filteredOpp.Title_Other__c;
					}
				}


				if (filteredOpp.Record_Type_Name__c != Former_Member_Opp_RtName) {
					updateContact.Membership_Status__c = Member_Opp_RtName;
					updateContact.recordTypeId = Contact_Memeber_RT_Id;
				}
				contactsToUpdate.add(updateContact);
				membershipHistoryRecordsToCreate.add(new Membership_History__c(Contact__c = filteredOpp.KGRenewal__Contact__c,
																			   account__c = filteredOpp.AccountId,
																			   Join_Date__c = System.today(),
																			   status__c = Member_Opp_RtName,
																			   YPO_WPO__c = 'YPO'));
			} else {
				if (filteredOpp.Opportunity_Type__c == 'Prospect' || filteredOpp.Opportunity_Type__c == 'Renewal' || filteredOpp.Opportunity_Type__c == 'Reinstatement') {
					Contact updateContact = new Contact();
					updateContact.Id = filteredOpp.KGRenewal__Contact__c;
					updateContact.President_Type__c = filteredOpp.President_Type__c;
					updateContact.Corporation_Type_Contact__c = filteredOpp.Organization_Type__c;
					updateContact.Firm_Type__c = filteredOpp.Firm_Type__c;
					updateContact.Business_Scope__c = filteredOpp.Business_Scope__c;
					updateContact.Enterprise_Type__c = filteredOpp.Enterprise_Type__c;
					if (filteredOpp.Title__c != null && filteredOpp.Title__c != '') {
						updateContact.Original_Title__c = filteredOpp.Title__c;
					}
					if (filteredOpp.Title_Other__c != null && filteredOpp.Title_Other__c != '') {
						updateContact.Title_Other__c = filteredOpp.Title_Other__c;
					}
					contactsToUpdate.add(updateContact);
				}

			}
		}

		/*
		  //Item- 7057 Logic added to set contact fields 
		  map<id,Contact> mapId2Contact= new map<id,Contact>();
		  list<contact> lstNewContact2Update = new list<contact>();
		  if(!UpdateContactfields(filteredOpportunities).isEmpty()){
		  for(contact con:UpdateContactfields(filteredOpportunities)){
		  mapId2Contact.put(con.id,con);
		  }       
		  }
		  if(!contactsToUpdate.isEmpty()){
		  for(contact con:contactsToUpdate){
		  if(mapId2Contact.containsKey(con.id)){
		  con.President_Type__c = mapId2Contact.get(con.id).President_Type__c ;
		  con.Corporation_Type_Contact__c = mapId2Contact.get(con.id).Corporation_Type_Contact__c;
		  con.Firm_Type__c = mapId2Contact.get(con.id).Firm_Type__c;
		  con.Business_Scope__c = mapId2Contact.get(con.id).Business_Scope__c ;
		  con.Enterprise_Type__c = mapId2Contact.get(con.id).Enterprise_Type__c ;
		  con.Title = mapId2Contact.get(con.id).Title;
		  con.Title_Other__c = mapId2Contact.get(con.id).Title_Other__c;
		  }else{
		  if(!mapid2Contact.isEmpty()){
		  lstNewContact2Update.add(mapId2Contact.get(con.id));
		  }
		  }
		  }
		  if(!lstNewContact2Update.isEmpty()){
		  contactsToUpdate.addAll(lstNewContact2Update);
		  }
		  }else{
		  contactsToUpdate.addAll(mapId2Contact.values());  
		  }
		 */

		List<Account_Affiliation__c> accAffsToUpdate = new List<Account_Affiliation__c> ();
		for (Account_Affiliation__c anAff :[Select Id, Contact__c from Account_Affiliation__c where contact__c in :contactToOpps.keySet() and contact_Type__c = :Member_Opp_RtName and type__c = 'Chapter']) {
			anAff.Chapter_Dues_Paid__c = System.today();
			anAff.Start_Date__c = System.today();
			anAff.IsActive__c = true;
			anAff.Is_Primary__c = true;
			accAffsToUpdate.add(anAff);
		}
		Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity> (filteredOpportunities);

		List<opportunitylineitem> yngOLIs = new list<OpportunityLineItem> ();

		List<Error_Log__c> errorLogs = new List<Error_Log__c> ();
		Savepoint sp = Database.setSavepoint();

		try {
			update contactsToUpdate;
		}
		catch(DmlException dEx) {
			for (Integer errorIndex = 0; errorIndex<dEx.getNumDml(); errorIndex++)
			{
				for (Opportunity errorOpp : contactToOpps.get(contactsToUpdate[errorIndex].Id)) {
					errorLogs.add(ErrorLogUtil.createErrorLogWithOppLookup('KG Opportunity Trigger', String.valueOf(errorOpp.Id), 'contactsToUpdate - ' + dEx.getDmlMessage(errorIndex), errorOpp.Id));
				}
			}
		}
		try {
			insert membershipHistoryRecordsToCreate;
		}
		catch(DmlException dEx) {
			for (Integer errorIndex = 0; errorIndex<dEx.getNumDml(); errorIndex++)
			{
				for (Opportunity errorOpp : contactToOpps.get(membershipHistoryRecordsToCreate[errorIndex].Contact__c)) {
					errorLogs.add(ErrorLogUtil.createErrorLogWithOppLookup('KG Opportunity Trigger', String.valueOf(errorOpp.Id), 'membershipHistoryRecords - ' + dEx.getDmlMessage(errorIndex), errorOpp.Id));
				}
			}
		}
		try {
			update accAffsToUpdate;
		}
		catch(DmlException dEx) {
			for (Integer errorIndex = 0; errorIndex<dEx.getNumDml(); errorIndex++)
			{
				for (Opportunity errorOpp : contactToOpps.get(accAffsToUpdate[errorIndex].Contact__c)) {
					errorLogs.add(ErrorLogUtil.createErrorLogWithOppLookup('KG Opportunity Trigger', String.valueOf(errorOpp.Id), 'accAffsToUpdate - ' + dEx.getDmlMessage(errorIndex), errorOpp.Id));
				}
			}
		}

		try {
			upsert filteredOpportunities;
		}
		catch(DmlException dEx) {
			for (Integer errorIndex = 0; errorIndex<dEx.getNumDml(); errorIndex++)
			{
				for (Opportunity errorOpp : filteredOpportunities) {
					errorLogs.add(ErrorLogUtil.createErrorLogWithOppLookup('KG Opportunity Trigger', String.valueOf(errorOpp.Id), 'filteredOpportunities - ' + dEx.getDmlMessage(errorIndex), errorOpp.Id));
				}
			}
		}
		// Create or cancel AA's for member benefit products purchased (items 7063 and 7221)
		errorLogs.addAll(createCancelBenefitAA(filteredOpportunities));
		
		// Rollback all changes if any step failed
		if(!errorLogs.isEmpty()) {
			Database.rollback(sp);
			ErrorLogUtil.insertErrorLogs(errorLogs);
		}

	}
	public static void opportunityYNGChildFlow(List<Opportunity> theOpp) {

		List<OpportunityLineItem> olis = [SELECT Id, Product2.Exclusive__c, Contact__c FROM OpportunityLineItem WHERE OpportunityId IN :theOpp AND Product2.Exclusive__c = 'YNG'];
		Set<Id> childIds = Pluck.Ids('Contact__c', olis);

		List<Contact> conts = [SELECT Id, YNG_Member__c FROM Contact WHERE Id IN :childIds];

		for (Contact con : conts) {
			con.YNG_Member__c = true;
		}

		try {
			update conts;
		} catch(DMLException e) {

		}


		/*
		  for(Opportunity opp : theOpp ){
		  Map<String, Object> mapFlowInput = new Map<String, Object>{'VarOppID' => opp.Id};
		 
		  Flow.Interview.Update_YNG_Child transitionFlow = new Flow.Interview.Update_YNG_Child(mapFlowInput); 
		  transitionFlow.start();
		  }
		 */
	}

	public static void filterOppsForAddMemberYear(List<Opportunity> opps, Map<id, SObject> oldMap) {
		List<Opportunity> filteredOppsToIncrementYear = new List<Opportunity> ();
		for (Opportunity opp : opps) {
			if (opp.RecordtypeId == Opp_Memeber_RT_Id && opp.KGRenewal__Subscription__c != null && opp.StageName == PAYMENT_RECEIVED && opp.StageName != oldMap.get(opp.Id).get('StageName')) {
				filteredOppsToIncrementYear.add(opp);
			}
		}
		if (!filteredOppsToIncrementYear.isEmpty()) {
			incrementYearOnContact(filteredOppsToIncrementYear);
		}
	}

	public static void incrementYearOnContact(List<Opportunity> filteredOpps) {
		Map<Id, List<Opportunity>> contIdToOppMap = GroupBy.Ids('KGRenewal__Contact__c', filteredOpps);
		List<Contact> contsToIncrement = new List<Contact> ();
		List<Contact> contsToUpdate = [Select Id, Number_Years_a_member__c From Contact Where Id IN :Pluck.ids('KGRenewal__Contact__c', filteredOpps)];

		for (Contact cont : contsToUpdate) {
			if (cont.Number_Years_a_Member__c == null) {
				cont.Number_Years_a_member__c = 1;
			} else {
				cont.Number_Years_a_member__c += 1;
			}
			contsToIncrement.add(cont);
		}

		try {
			update contsToIncrement;
		} catch(DMLException dmlex) {
			System.assert(false, dmlex);
			for (Integer i = 0; i<dmlex.getNumDml(); i++) {
				contIdToOppMap.get(contsToIncrement[i].Id) [0].addError(dmlex.getDmlMessage(i));
			}
		}
	}

	public static List<Opportunity> filterReinstatementOpps(List<Opportunity> opps, Map<id, SObject> oldMap) {
		List<Opportunity> filterOpps = new List<Opportunity> ();

		for (Opportunity opp : opps) {

			if (opp.Opportunity_Type__c == 'Reinstatement' || (oldMap != null && opp.Opportunity_Type__c == 'Reinstatement' && opp.Opportunity_Type__c != oldMap.get(opp.Id).get('Opportunity_Type__c'))) {
				filterOpps.add(opp);
			}

		}

		return filterOpps;
	}

	public static Map<Id, Contact> generateContactMap(List<Opportunity> reinstatementOpps) {
		Set<Id> oppContactRoleIds = Pluck.ids('KGRenewal__Contact__c', reinstatementOpps);

		Map<ID, Contact> contactIdToContact = new Map<ID, Contact> ([SELECT Id, FirstName, LastName, Email, GUID__c FROM Contact WHERE Id IN :oppContactRoleIds]);
		return contactIdToContact;
	}

	public static List<Contact> filterContactForCommunityUserCreation(List<Contact> contactList){
		Set<String> contactGuids = Pluck.strings('GUID__C', contactList);
		List<User> activeUsers = new List<User> ();
		List<User> inactiveUsers = new List<User> ();
		for (User usr :[SELECT ContactId, isActive, FederationIdentifier FROM User WHERE FederationIdentifier IN :contactGuids]) {
			if (usr.isActive == true) {
				activeUsers.add(usr);
			}
			else if (usr.isActive == false) {
				inactiveUsers.add(usr);
			}
		}

		Map<Id, List<User>> contactIdToUserMap = !activeUsers.isEmpty() ? GroupBy.ids('ContactId', activeUsers) : new Map<Id, List<User>> ();

		List<Contact> filteredContacts = new List<Contact> ();
		List<User> usersToUpdate = new List<User> ();
		for (Contact thisContact : contactList)
		{
			if (!contactIdToUserMap.containsKey(thisContact.Id))
			{

				filteredContacts.add(thisContact);
			}
		}

		updateInactiveUserFederationIds(inactiveUsers);

		return filteredContacts;
	}

	static void updateInactiveUserFederationIds(List<User> inactiveUsers){
		for (User inactiveUsr : inactiveUsers) {
			inactiveUsr.FederationIdentifier = inactiveUsr.FederationIdentifier + Date.today();
		}

		try {
			update inactiveUsers;
		}
		catch(Dmlexception dEx) {
			String sMessage = 'ERROR: An exception has occurred. Please contact your System Administrator quoting the following message -- '
			+ dEx.getTypeName() + ':' + dEx.getMessage() + ':' + dEx.getLineNumber() + ':' + dEx.getStackTraceString();


			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = Chapter_Health_Batch_Error_Email_Setting__c.getInstance().Error_Email_Recipients__c.split(';');
			//mail.setTreatTargetObjectAsRecipient(false);
			mail.setToAddresses(toAddresses);
			mail.setSubject('Exception occurred while updating inactive users\' guids in the KG_Opp_Trigger.');

			String body = '<html lang="ja"><body>' +
			'<br><br>' +
			'This email alert is to bring to your notice that exception occured  while updating inactive users\' guids in the KG_Opp_Trigger.' +
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

	//Item #7057 - creating filter method to get Opportunities
	public static List<Opportunity> filterOppsMarkedAsClosedWon(List<Opportunity> allOpportunities, Map<Id, Opportunity> oldMap) {
		List<Opportunity> filteredOpps = new List<Opportunity> ();
		for (Opportunity oppRecord : allOpportunities) {
			if ((oppRecord.StageName == 'Closed Won')
				&& ((oppRecord.President_Type__c != oldMap.get(oppRecord.id).President_Type__c)
					|| (oppRecord.Organization_Type__c != oldMap.get(oppRecord.id).Organization_Type__c)
					|| (oppRecord.Firm_Type__c != oldMap.get(oppRecord.id).Firm_Type__c)
					|| (oppRecord.Business_Scope__c != oldMap.get(oppRecord.id).Business_Scope__c)
					|| (oppRecord.Enterprise_Type__c != oldMap.get(oppRecord.id).Enterprise_Type__c)
					|| (oppRecord.Title__c != oldMap.get(oppRecord.id).Title__c)
					|| (oppRecord.Title_Other__c != oldMap.get(oppRecord.id).Title_Other__c)
			)
				&& (oppRecord.Opportunity_Type__c == 'Prospect'
					|| oppRecord.Opportunity_Type__c == 'Renewal'
					|| oppRecord.Opportunity_Type__c == 'Reinstatement'
			)
				&& (oppRecord.Fiscal_Date_Start__c == FiscalDateUtility.startOfNextFiscal
					|| oppRecord.Fiscal_Date_Start__c == FiscalDateUtility.startOfCurrentFiscal
			)
				&& (oppRecord.recordTypeId == Opp_Memeber_RT_Id
					|| oppRecord.recordTypeId == Opp_Prospect_RT_Id
					|| oppRecord.recordTypeId == Opp_Former_Member_RT_Id
			)
			) {
				filteredOpps.add(oppRecord);
			}
		}
		return filteredOpps;
	}

	//Item #7057- Method to set contact fields and to get list of contacts which needs to be updated 
	public static List<Contact> UpdateContactfields(List<Opportunity> filteredOpps) {
		List<Contact> contactsToUpdate = new List<Contact> ();
		List<Opportunity> oppsToUpdate = new List<Opportunity> ();
		Map<Id, List<Opportunity>> contactToOpps = new Map<Id, List<Opportunity>> ();
		for (Opportunity Opp : filteredOpps) {
			if (opp.Opportunity_Type__c == 'Renewal' || opp.Opportunity_Type__c == 'Reinstatement' || opp.Opportunity_Type__c == 'Prospect') {
				if (!contactToOpps.containsKey(Opp.KGRenewal__Contact__c)) {
					contactToOpps.put(Opp.KGRenewal__Contact__c, new List<Opportunity> ());
					contactToOpps.get(Opp.KGRenewal__Contact__c).add(Opp);
				}
			}
		}
		Map<ID, Contact> conmap = new Map<ID, Contact> ([SELECT Id, Name, President_Type__c, Corporation_Type__c, Firm_Type__c, Business_Scope__c, Enterprise_Type__c, Title, Original_Title__c, Title_Other__c FROM Contact where id in :contactToOpps.keySet()]);
		for (Opportunity Opp : filteredOpps) {
			if (conmap.containsKey(Opp.KGRenewal__Contact__c)) {
				Contact con = conmap.get(Opp.KGRenewal__Contact__c);
				conmap.get(Opp.KGRenewal__Contact__c).President_Type__c = Opp.President_Type__c;
				conmap.get(Opp.KGRenewal__Contact__c).Corporation_Type_Contact__c = Opp.Organization_Type__c;
				conmap.get(Opp.KGRenewal__Contact__c).Firm_Type__c = Opp.Firm_Type__c;
				conmap.get(Opp.KGRenewal__Contact__c).Business_Scope__c = Opp.Business_Scope__c;
				conmap.get(Opp.KGRenewal__Contact__c).Enterprise_Type__c = Opp.Enterprise_Type__c;
				if (Opp.Title__c != null) {
					conmap.get(Opp.KGRenewal__Contact__c).Original_Title__c = Opp.Title__c;
				}
				if (Opp.Title_Other__c != null) {
					conmap.get(Opp.KGRenewal__Contact__c).Title_Other__c = Opp.Title_Other__c;
				}
				contactsToUpdate.add(con);
			}
		}
		return contactsToUpdate;
	}

	//Item #7057 - Method to update contacts
	public static void UpdateContact(List<Opportunity> filteredOpps) {
		List<Contact> contactsToUpdate = new List<Contact> ();
		Map<Id, List<Opportunity>> contactToOpps = new Map<Id, List<Opportunity>> ();

		contactsToUpdate = UpdateContactfields(filteredOpps);
		Update contactsToUpdate;

		List<Error_Log__c> errorLogs = new List<Error_Log__c> ();
		Savepoint sp = Database.setSavepoint();

		try {
			update contactsToUpdate;
		}
		catch(DmlException dEx) {

			for (Integer errorIndex = 0; errorIndex<dEx.getNumDml(); errorIndex++)
			{
				for (Opportunity errorOpp : contactToOpps.get(contactsToUpdate[errorIndex].Id)) {
					errorLogs.add(ErrorLogUtil.createErrorLogWithOppLookup('KG Opportunity Trigger', String.valueOf(errorOpp.Id), dEx.getDmlMessage(errorIndex), errorOpp.Id));
				}
			}
		}

	}

	//item 07086 - Add Network AA after opportunity Closed Won
	public static void opportunityBusinessNetwork(Map<Id, Opportunity> newCollection, Map<Id, Opportunity> oldCollection) {
		Map<String, Id> businessNetworkLookup = new Map<String, Id> ();
		List<Account_Affiliation__c> newAccountAffiliation = new List<Account_Affiliation__c> ();
		Map<Id, Opportunity> newOpps = new Map<Id, Opportunity> ();
		Set<Id> errorIds = new Set<Id> ();

		for (Opportunity opp : newCollection.values()) {
			if (opp.StageName.equals('Closed Won') && oldCollection.get(opp.Id).StageName != opp.StageName && opp.Opportunity_Type__c == 'Prospect') {
				newOpps.put(opp.Id, opp);
			}
		}

		if (!newOpps.isEmpty()) {
			//Refresh the map with the related list info of Contacts
			for (Opportunity opp :[Select Name, StageName, KGRenewal__Contact__r.Business_Network__c, KGRenewal__Contact__r.Id, KGRenewal__Contact__r.Join_Date__c from Opportunity where Id IN :newOpps.keySet()]) {
				newOpps.put(opp.Id, opp);
				businessNetworkLookup.put(opp.KGRenewal__Contact__r.Business_Network__c, null);
			}

			for (Account a :[Select Id, Name from Account where Name IN :businessNetworkLookup.keySet() and RecordType.Name = 'Network']) {
				businessNetworkLookup.put(a.Name, a.Id);
			}
			Account_Affiliation__c newAA;
			for (Opportunity opp : newOpps.values()) {
				//if statement to test for Error Log functionality
				if (Test.isRunningTest() && opp.Name.startsWith('Test')) {
					errorIds.add(opp.Id);
				}
				if (businessNetworkLookup.containsKey(opp.KGRenewal__Contact__r.Business_Network__c)) {
					newAA = new Account_Affiliation__c();

					newAA.Contact__c = opp.KGRenewal__Contact__r.Id;
					newAA.Account__c = businessNetworkLookup.get(opp.KGRenewal__Contact__r.Business_Network__c);
					newAA.Start_Date__c = opp.KGRenewal__Contact__r.Join_Date__c;
					newAA.RecordTypeId = RecordTypeServices.getRecordTypeByName('Network', 'Account_Affiliation__c').Id;
					newAA.IsActive__c = true;

					newAccountAffiliation.add(newAA);
				} else {
					errorIds.add(opp.KGRenewal__Contact__r.Id);
				}
			}

			if (newAccountAffiliation.size()> 0) {
				try {
					insert newAccountAffiliation;
				} catch(DmlException e) {
					System.debug(e);
				}
			}

			if (errorIds.size()> 0) {
				List<Error_Log__c> errorList = new List<Error_Log__c> ();
				for (id i : errorIds) {
					errorList.add(ErrorLogUtil.createErrorLog('KG Opportunity Trigger', i, 'Unable to find matching Account Network with Contact Business Network'));
				}
				try {
					insert errorList;
				} catch(DmlException e) {
					System.debug(e);
				}

				return;
			}
		}
	}

	/*
	  private void contactBusinessNetworkError(Set<Id> errorList){
	  ConnectApi.FeedItemInput feedItemInput;
	  ConnectApi.MentionSegmentInput mentionSegmentInput;
	  ConnectApi.MessageBodyInput messageBodyInput;
	  ConnectApi.TextSegmentInput textSegmentInput;
	 
	  for(Id i : errorList){
	  feedItemInput = new ConnectApi.FeedItemInput();
	  mentionSegmentInput = new ConnectApi.MentionSegmentInput();
	  messageBodyInput = new ConnectApi.MessageBodyInput();
	  textSegmentInput = new ConnectApi.TextSegmentInput();
	 
	  messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
	 
	  textSegmentInput.text = 'No matching network found. ';          
	 
	  messageBodyInput.messageSegments.add(textSegmentInput);
	 
	  mentionSegmentInput.id = UserInfo.getUserID();
	  messageBodyInput.messageSegments.add(mentionSegmentInput);
	 
	  feedItemInput.body = messageBodyInput;
	  feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
	  feedItemInput.subjectId = i;
	 
	  ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);                          
	  }
	  }
	 */

	@TestVisible
	public static void insertCommunityUsers(List<User> userList, Map<Id, List<Opportunity>> relatedOppMap)
	{
		Database.DMLOptions dmlOptions = new Database.DMLOptions();
		dmlOptions.EmailHeader.triggerUserEmail = false;
		dmlOptions.EmailHeader.triggerOtherEmail = false;
		dmlOptions.EmailHeader.triggerAutoResponseEmail = false;
		dmlOptions.OptAllOrNone = false;

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
				relatedOppMap.get(userList[i].ContactId) [0].addError(errorMessage);
			}
		}
	}

	//Item-07099(Item-3740) Determine if there is any Lifetime products with a positive unitprice listed on the Opportunity
	public static Boolean IsLifetimeProductIncluded(Opportunity Opp) {
		return IsLifetimeProductIncluded(Opp.Id);
	}

	public static Boolean IsLifetimeProductIncluded(Id oppId) { 
		Boolean foundLifetimeProduct = false;
		for(OpportunityLineItem oli: [SELECT Id, Product2.Family, UnitPrice, Quantity FROM OpportunityLineItem WHERE Opportunityid = :oppId]) {
			if (oli.Product2.Family == 'Lifetime Dues' && oli.UnitPrice > 0 && oli.Quantity > 0) {
				foundLifetimeProduct = true;
			}
		}
		return foundLifetimeProduct;
	}

	//Item-07266 need function to check for the CoC to be set.
	public static Boolean IsCodeOfConductAccepted(id OppID) {
		Opportunity Oppt = [Select id, Code_of_Conduct_Accepted__c From Opportunity Where ID= :OppID];
		Return Oppt.Code_of_Conduct_Accepted__c;
	}

	/**
	* @description Create or cancel a benefit account affiliation when member products are purchased or refunded (items 7063 and 7221)
	* @param filteredOpps - list of opportunities from markOppsAsClosedWon method
	* @return List of error messages to be inserted in Error_Log__c and/or emailed
	*/ 
	public static List<Error_Log__c> createCancelBenefitAA(List<Opportunity> filteredOpps) {
		List<Error_Log__c> errors = new List<Error_Log__c>();
		RecordType benefitRT = RecordTypeServices.getRecordTypeByDeveloperName('Benefit', 'Account_Affiliation__c');
		List<Account_Affiliation__c> acctAffsToUpdate = new List<Account_Affiliation__c>();
		List<OpportunityLineItem> oliNotFound = new List<OpportunityLineItem>();

		// Match benefit products with benefit accounts based on name
		Map<Id, Id> mapProdIdAcctId = new Map<Id, Id>();
		for (Product2 prod : [SELECT Id, Name FROM Product2 WHERE Family = 'Member Benefit' AND IsActive = TRUE]) {
			//System.debug([SELECT Id, Name, Status__c, RecordTypeId FROM Account]);
			for (Account acct : [SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'Benefit' AND Status__c = 'Active']) {
				System.debug('Name Compare: ' + prod.Name + ' : ' + acct.Name);
				if (prod.Name == acct.Name) { 
					mapProdIdAcctId.put(prod.Id, acct.Id);
				}
			}
		}

		// Get Benefit Account Affiliations for filteredOpps (first need a list of 
		// OLI contacts in case they do not match the Opp contact - children, S/P, etc.)
		Integer matchCount = 0;
		List<OpportunityLineItem> oliList = [SELECT Id, OpportunityId, Name, Contact__c, Opportunity.KGRenewal__Contact__r.Name, Opportunity.Name, Product_Name__c, 
													Product2Id, Product_Family__c, KGRenewal__ContractEffectiveDate__c, KGRenewal__ContractEndDate__c, Quantity, ListPrice
											 FROM OpportunityLineItem
											 WHERE OpportunityId IN :filteredOpps
											 AND Product_Family__c = 'Member Benefit'];
		
		List<Account_Affiliation__c> aaList = new List<Account_Affiliation__c>([SELECT Id, Name, Contact__c, Account__c, Start_Date__c, End_Date__c, IsActive__c
																				FROM Account_Affiliation__c
																				WHERE RecordType.DeveloperName = 'Benefit'
																				AND Account__c IN :mapProdIdAcctId.values()
																				AND (Contact__c IN :Pluck.ids('KGRenewal__Contact__c', filteredOpps)
																					OR Contact__c IN :Pluck.ids('Contact__c', oliList))]);
		
		for (OpportunityLineItem oli : oliList)	{
			System.debug(oli.Quantity + ' : ' + oli.ListPrice);
			if (oli.Quantity >= 0 && oli.ListPrice >= 0) {				
				// Verify benefit AA doesn't already exist for this opp and contact
				Boolean aaExists = false;
				for (Account_Affiliation__c aa : aaList) {
					if ((aa.Contact__c == oli.Contact__c || aa.Contact__c == oli.Opportunity.KGRenewal__Contact__c)
						 && aa.Account__c == mapProdIdAcctId.get(oli.Product2Id) 
						 && aa.Start_Date__c == oli.KGRenewal__ContractEffectiveDate__c) 
					{
						aaExists = true;
					}
				}

				// Create benefit AA
				if (!aaExists) {
					Account_Affiliation__c aff = new Account_Affiliation__c();
					aff.Account__c = mapProdIdAcctId.get(oli.Product2Id);
					aff.RecordTypeId = benefitRT.Id;
					aff.Contact__c = oli.Contact__c != null ? oli.Contact__c : oli.Opportunity.KGRenewal__Contact__c;
					aff.Start_Date__c = oli.KGRenewal__ContractEffectiveDate__c;
					if (oli.KGRenewal__ContractEndDate__c != null) {
						aff.End_Date__c = oli.KGRenewal__ContractEndDate__c;
					}
					else {
						aff.End_Date__c = FiscalDateUtility.getFiscalYear(oli.KGRenewal__ContractEffectiveDate__c).EndDate;
					}
					if (aff.Start_Date__c <= Date.today()) {
						aff.IsActive__c = true;
					}
					else {
						aff.IsActive__c = false;
					}
					acctAffsToUpdate.add(aff);
				}
			}

			// Refund - cancel existing Benefit AA (item 7221)
			else {
				Boolean aaMatch = false;
				for (Account_Affiliation__c aa : aaList) {
					if ((aa.Contact__c == oli.Contact__c || aa.Contact__c == oli.Opportunity.KGRenewal__Contact__c)
						 && aa.Account__c == mapProdIdAcctId.get(oli.Product2Id) 
						 && aa.Start_Date__c == oli.KGRenewal__ContractEffectiveDate__c
						 && aa.IsActive__c == true) 
					{
						aaMatch = true;
						aa.Reason_for_Leaving__c = 'Other';
						aa.Reason_Leaving_Other__c = 'Cancelled';
						aa.IsActive__c = false;
						if (aa.Start_Date__c > Date.today()) {
							aa.End_Date__c = aa.Start_Date__c;
						}
						else {
							aa.End_Date__c = Date.today();
						}
						acctAffsToUpdate.add(aa); 
					}
				}
				if (!aaMatch) { 
					oliNotFound.add(oli);
				}
			}
		}

		// If any OLIs were not matched to AAs, send email
		if (oliNotFound.size() > 0) {
			String body = 'Please review ' + oliNotFound[0].Opportunity.KGRenewal__Contact__r.Name + '\'s opportunity - "' 
						  + oliNotFound[0].Opportunity.Name + '" for the following products:<br/><br/>';
			for (OpportunityLineItem o : oliNotFound) {
				body += '     ' + o.Product_Name__c + '<br/>';
			}
			body += '<br/>The system could not find a matching Benefit Account Affiliation for the ' +
					'contact name and contract effective date specified on Product Detail line.';
			EmailServices.sendErrorEmail('Benefit AA Not Found', null, body);
		}
		
		// Insert AAs and return any errors that occur
		try {
			upsert acctAffsToUpdate;
		}
		catch (DmlException dEx) {
			for (Integer i = 0; i < dEx.getNumDml(); i++) {
				errors.add(new Error_Log__c(
					Record_Id__c = dEx.getDmlId(i), 
					Error_String__c = 'Error in OpportunityServices.createCancelBenefitAA(): ' + String.valueOf(dEx.getDmlType(i)) + ': ' + dEx.getDmlMessage(i))
				);
			}
		}
		return errors;
	}


	/**
	* @description Prevent opp probability from going to 99% when going to Payment Received (item 7605)
	* @param newOpps List of opportunities to evaluate (trigger.new)
	* @param oldOppMap Map of old opp Ids and opps (trigger.oldMap)
	*/ 
	public static void fixProbability(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
		for (Opportunity newOpp : newList) { 
			Opportunity oldOpp = oldMap.get(newOpp.Id);
			if (newOpp.StageName == 'Payment Received' && oldOpp.StageName == 'Payment Pending') {
				newOpp.Probability = 100;
			}
		}
	}

	/**
	* @description If opp is Payment Received, update probability to 100% (item 7605)
	* @param oppIds Set of opp Ids to process
	*/ 
	@Future
	public static void fixProbabilityFuture(Set<Id> oppIds) {
		List<Opportunity> oppsToUpdate = new List<Opportunity>();
		for (Opportunity opp : [SELECT Id, StageName, Probability FROM Opportunity WHERE Id IN :oppIds]) {
			if (opp.StageName == PAYMENT_RECEIVED && opp.Probability != 100) {
				oppsToUpdate.add(new Opportunity(Id = opp.Id, Probability = 100));
			}
		}
		update oppsToUpdate;
	}

}