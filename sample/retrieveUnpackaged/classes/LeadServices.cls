public class LeadServices {

	public static final String CONST_US_COUNTRY = 'United States';

	public final static String CONST_CHAP_CHAIR = 'Chapter Chair';
	public final static String CONST_CHAP_MEM_OFF = 'Chapter Membership Officer';
	public final static String CONST_CHAP_ADMIN = 'Chapter Administrator';

	public static Map<String, String> statusToAccess {
		get {
			if (statusToAccess == null) {
				statusToAccess = new Map<String, String> ();
				for (Lead_Share_Settings__c leadShareSetting : Lead_Share_Settings__c.getAll().values()) {
					statusToAccess.put(leadShareSetting.Lead_Status__c, leadShareSetting.CA_Access_Level__c);
				}
			}
			return statusToAccess;
		} set;
	}

	public static void createLeadShareRecords(List<Lead> newLeads, Map<Id, Lead> oldMap, Boolean isUpdate) {
		List<LeadShare> leadSharesToInsert = new List<LeadShare> ();
		List<LeadShare> leadSharesToDelete = new List<LeadShare> ();
		List<Lead> leadsToUpdate = new List<Lead> ();
		Map<Id, List<CA_Setting__c>> chapterToCASetting = new Map<Id, List<CA_Setting__c>> ();

		for (Lead l : newLeads) {
			If (!isUpdate) {
				leadsToUpdate.add(l);
			} else if ((l.Status != oldMap.get(l.Id).Status || l.Pursue_Status__c != oldMap.get(l.Id).Pursue_Status__c || l.Referred_by_Chapter__c != oldMap.get(l.Id).Referred_by_Chapter__c)) {
				leadsToUpdate.add(l);
			}

		}
		if (leadsToUpdate.size() > 0) {
			chapterToCASetting = getChapterToCA(alm_pm2.Pluck.ids('Referred_by_Chapter__c', leadsToUpdate));
			Boolean hasDeleteShareRecords = false;
			Boolean first = true;
			String query = 'Select Id from LeadShare where ';
			for (Lead newLead : leadsToUpdate) {
				String status = newLead.status;
				String pursueStatus = newLead.Pursue_Status__c;
				if ((statusToAccess.containsKey(status) || statusToAccess.containsKey(pursueStatus))) {
					String accessLevel;
					if (isUpdate && status != oldMap.get(newLead.id).Status) {
						accessLevel = statusToAccess.get(status);
					} else if (isUpdate && pursueStatus != oldMap.get(newLead.Id).Pursue_Status__c && pursueStatus != null) {
						accessLevel = statusToAccess.get(pursueStatus);

					} else {
						accessLevel = statusToAccess.get(status);
					}
					Set<String> accessVals = new Set<String> { 'Read', 'Edit', 'None', 'All' };
					if (!accessVals.contains(accessLevel)) {
						continue;
					}
					if (chapterToCASetting.containsKey(newLead.Referred_by_Chapter__c)) {
						for (CA_Setting__c caSet : chapterToCASetting.get(newLead.Referred_by_Chapter__c)) {
							Id adminId = caSet.User__c;
							if (adminId != null && adminId != newLead.OwnerId) {
								if (accessLevel != 'None') {
									leadSharesToInsert.add(new LeadShare(LeadId = newLead.id,
									                                     UserOrGroupId = adminId,
									                                     LeadAccessLevel = accessLevel));
								} else if (isUpdate) {
									hasDeleteShareRecords = true;
									if (!first) { query += 'OR'; }
									query += '(leadId =\'' + newLead.id + '\' and UserOrGroupId =\'' + adminId + '\')';
									first = false;
								}
							}
						}
					}
				}
			}

			if (!leadSharesToInsert.isEmpty()) {
				try {
					insert leadSharesToInsert;
				}
				catch(Dmlexception dEx) {
					Map<Id, Lead> errorAdder = new Map<Id, Lead> (leadsToUpdate);
					for (Integer i = 0; i<dEX.getNumDML(); i++)
					{
						errorAdder.get(leadSharesToInsert[dEX.getDmlIndex(i)].leadId).addError(dEX.getDmlMessage(i));
					}
				}
			}
			if (hasDeleteShareRecords) {
				leadSharesToDelete = Database.query(query);
				if (!leadSharesToDelete.isEmpty()) {
					List<String> leadSharesToDeleteJSON = new List<String> ();
					for (LeadShare ls : leadSharesToDelete) {
						leadSharesToDeleteJSON.add(json.serialize(ls));
					}
					deleteLeadShares(leadSharesToDeleteJSON);
				}
			}
		} else {
			return;
		}
	}

	private static Map<Id, List<CA_Setting__c>> getChapterToCA(Set<Id> chapterIds) {
		return GroupBy.ids('Chapter__c', [Select User__c, Chapter__c from CA_Setting__c where Chapter__c = :chapterIds and isActive__c = true
		                   and role__c in :Lead_and_Contact_Sharing_CA_Roles__c.getAll().keyset()]);
		return new Map<Id, List<CA_Setting__c>> ();
	}


	public void deleteOldCreateNewShareRecords(Map<Id, Lead> newLeadsMap, Map<Id, Lead> oldLeads) {
		List<Lead> newLeads = newLeadsMap.values();
		List<LeadShare> leadSharesToInsert = new List<LeadShare> ();
		List<Lead> leadsForLeadShareInsert = new List<Lead> ();
		Map<Id, Id> leadIdToDeleteChapterId = new Map<Id, Id> ();
		Set<Id> allChapterIds = new Set<Id> ();
		for (Lead aLead : newLeads) {
			Id oldChapterId = oldLeads.get(aLead.id).Referred_by_Chapter__c;
			if (aLead.Referred_by_Chapter__c != oldChapterId) {
				leadsForLeadShareInsert.add(aLead);
				if (oldChapterId != null) {
					leadIdToDeleteChapterId.put(aLead.id, oldChapterId);
				}
			}
		}
		if (!leadsForLeadShareInsert.isEmpty()) {
			deleteLeadShares(leadIdToDeleteChapterId, newLeadsMap);
			createLeadShareRecords(leadsForLeadShareInsert, oldLeads, false);
		}
	}


	public static void deleteLeadShares(Map<Id, Id> leadIdToDeleteChapterId, Map<Id, Lead> newLeads) {
		Map<Id, List<CA_Setting__c>> chapterToCASetting;

		if (leadIdToDeleteChapterId.size()> 0) {
			chapterToCASetting = getChapterToCA(new Set<Id> (leadIdToDeleteChapterId.values()));
		}

		List<LeadShare> leadSharesToDelete = new List<LeadShare> ();
		String query = 'Select Id, LeadId, UserOrGroupId from LeadShare where ';
		Boolean first = true;
		Boolean hasDeleteShareRecords = false;

		for (Id leadId : leadIdToDeleteChapterId.keyset()) {
			Id chapterId = leadIdToDeleteChapterId.get(leadId);
			if (chapterToCASetting.containsKey(chapterId))
			{
				hasDeleteShareRecords = true;
				for (CA_Setting__c caSet : chapterToCASetting.get(chapterId)) {
					if (caSet.User__c != null) {
						if (!first) { query += 'OR'; }
						query += '(leadId =\'' + leadId + '\' and UserOrGroupId =\'' + caSet.User__c + '\')';
						first = false;
					}
				}
			}
		}
		if (hasDeleteShareRecords) {
			for (LeadShare aLeadShare : Database.query(query)) {
				if (aLeadShare.UserOrGroupId != newLeads.get(aLeadShare.leadid).ownerid)
				leadSharesToDelete.add(aLeadShare);
			}
			if (!leadSharesToDelete.isEmpty()) {
				List<String> leadSharesToDeleteJSON = new List<String> ();
				for (LeadShare ls : leadSharesToDelete) {
					leadSharesToDeleteJSON.add(json.serialize(ls));
				}
				deleteLeadShares(leadSharesToDeleteJSON);
			}
		}
	}

	//@future 
	public static void deleteLeadShares(List<String> leadSharesToDeleteJSON) {
		try {
			List<LeadShare> leadSharesToDelete = new List<LeadShare> ();
			for (String s : leadSharesToDeleteJSON) {
				JSON.deserializeStrict(s, LeadShare.class);
			}

			delete leadSharesToDelete;
		}
		catch(Dmlexception dEx) {
			String sMessage = 'ERROR: An exception has occurred. Please contact your System Administrator quoting the following message -- '
			+ dEx.getTypeName() + ':' + dEx.getMessage() + ':' + dEx.getLineNumber() + ':' + dEx.getStackTraceString();


			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = Chapter_Health_Batch_Error_Email_Setting__c.getInstance().Error_Email_Recipients__c.split(';');
			//mail.setTreatTargetObjectAsRecipient(false);
			mail.setToAddresses(toAddresses);
			mail.setSubject('Exception occurred while deleting Lead Shares');

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
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}


	private static List<Lead> filterLeadWithChangedCountry(List<Lead> leads, Map<Id, Lead> oldLeads) {
		//System.assert(false, Trigger.new + ' lead: '+ leads[0]);
		/*if(Trigger.isInsert && oldLeads == null){
		  leads = [Select Id, Country From Lead Where Id IN:leads];
		  }*/
		List<Lead> filteredLeads = new List<Lead> ();
		for (Lead thisLead : leads) {
			if ((oldLeads == null && thisLead.Country != null) ||
			(oldLeads != null && thisLead.Country != oldLeads.get(thisLead.Id).Country)) {
				filteredLeads.add(thisLead);
			}
		}
		return filteredLeads;
	}

	private static Map<String, List<Geographic_Requirements__c>> getRelatedGeoRequirements(List<Lead> leads) {
		Set<String> countries = Pluck.strings('Country', leads);
		countries.add(CONST_US_COUNTRY);
		List<Geographic_Requirements__c> geoReqs = [SELECT Annual_Assets__c, Annual_Fees__c, Annual_Revenue__c, Country__c,
		                                            Enterprise_Value__c, Number_of_Employees_Opt_1__c,
		                                            Number_of_Employees_Opt_2__c, Total_Employee_Compensation_Opt_1__c,
		                                            Total_Employee_Compensation_Opt_2__c
		                                            FROM Geographic_Requirements__c
		                                            WHERE Is_Current__c = true
		                                            AND Country__c IN :countries];
		return geoReqs.isEmpty() ? new Map<String, List<Geographic_Requirements__c>> () : GroupBy.Strings('Country__c', geoReqs);
	}

	private static void updateLeadBasedOnGeoRequirements(List<Lead> leads, Map<String, List<Geographic_Requirements__c>> relatedGeoReqs) {
		List<Lead> leadsToUpdate = new List<Lead> ();
		if (!relatedGeoReqs.isEmpty())
		{
			for (Lead thisLead : leads)
			{
				if (Trigger.isAfter && trigger.isInsert) {
					thisLead = new Lead(Id = thisLead.Id, Country = thisLead.Country);

				}

				if (String.isNotBlank(thisLead.Country) && relatedGeoReqs.containsKey(thisLead.Country) && relatedGeoReqs.get(thisLead.Country) != null)
				{
					Geographic_Requirements__c geoReq = relatedGeoReqs.get(thisLead.Country) [0];

					thisLead.QC_Annual_Assets__c = geoReq.Annual_Assets__c;
					thisLead.QC_Annual_Fees__c = geoReq.Annual_Fees__c;
					thisLead.QC_Annual_Revenue__c = geoReq.Annual_Revenue__c;
					thisLead.QC_Enterprise_Value__c = geoReq.Enterprise_Value__c;
					thisLead.QC_Number_of_Employees_Opt_1__c = geoReq.Number_of_Employees_Opt_1__c;
					thisLead.QC_Number_of_Employees_Opt_2__c = geoReq.Number_of_Employees_Opt_2__c;
					thisLead.QC_Qualifying_Country__c = geoReq.Country__c;
					thisLead.QC_Total_Employee_Compensation_Opt_1__c = geoReq.Total_Employee_Compensation_Opt_1__c;
					thisLead.QC_Total_Employee_Compensation_Opt_2__c = geoReq.Total_Employee_Compensation_Opt_2__c;

				}
				else
				{
					Geographic_Requirements__c geoReq = relatedGeoReqs.get(CONST_US_COUNTRY) [0];

					thisLead.QC_Annual_Assets__c = geoReq.Annual_Assets__c;
					thisLead.QC_Annual_Fees__c = geoReq.Annual_Fees__c;
					thisLead.QC_Annual_Revenue__c = geoReq.Annual_Revenue__c;
					thisLead.QC_Enterprise_Value__c = geoReq.Enterprise_Value__c;
					thisLead.QC_Number_of_Employees_Opt_1__c = geoReq.Number_of_Employees_Opt_1__c;
					thisLead.QC_Number_of_Employees_Opt_2__c = geoReq.Number_of_Employees_Opt_2__c;
					thisLead.QC_Qualifying_Country__c = geoReq.Country__c;
					thisLead.QC_Total_Employee_Compensation_Opt_1__c = geoReq.Total_Employee_Compensation_Opt_1__c;
					thisLead.QC_Total_Employee_Compensation_Opt_2__c = geoReq.Total_Employee_Compensation_Opt_2__c;
				}
				if (trigger.isAfter && trigger.isInsert) {
					leadsToUpdate.add(thisLead);
				}
			}
		}

		if (!leadsToUpdate.isEmpty() && Trigger.isInsert && Trigger.isAfter) {
			try {
				update leadsToUpdate;

			} catch(DMLException dEX) {
				Map<Id, Lead> errorAdder = new Map<Id, Lead> (leads);
				for (Integer i = 0; i<dEX.getNumDML(); i++)
				{
					errorAdder.get(leadsToUpdate[dEX.getDmlIndex(i)].Id).addError(dEX.getDmlMessage(i));

				}
			}
		}
	}

	public static void syncLeadwithGeoRequirements(List<Lead> leads, Map<Id, Lead> oldLeads)
	{
		List<Lead> filteredLeads = filterLeadWithChangedCountry(leads, oldLeads);
		if (!filteredLeads.isEmpty())
		{
			updateLeadBasedOnGeoRequirements(filteredLeads, getRelatedGeoRequirements(filteredLeads));
		}
	}

	public static void updateChapterUsers(List<Lead> newCollection, Map<Id, Lead> oldCollection) {
		Map<Id, Lead> updatedLeads = new Map<Id, Lead> ();
		if (Trigger.isUpdate) {
			for (Lead l : newCollection) {
				if (l.Referred_by_Chapter__c != oldCollection.get(l.id).Referred_by_Chapter__c && l.Referred_by_Chapter__c != NULL) {
					updatedLeads.put(l.Referred_by_Chapter__c, l);
				}
			}
		} else if (Trigger.isInsert) {
			for (Lead l : newCollection) {
				if (l.Referred_by_Chapter__c != NULL) {
					updatedLeads.put(l.Referred_by_Chapter__c, l);
				}
			}
		}

		if (!updatedLeads.isEmpty()) {
			Map<Id, Map<String, Id>> accountRoleLookup = new Map<Id, Map<String, Id>> ();

			for (CA_Setting__c ca :[SELECT Chapter__c, Primary__c, Role__c, User__c FROM CA_Setting__c WHERE isActive__c = true and Chapter__c IN :updatedLeads.keySet()]) {
				if (ca.Role__c.equals(CONST_CHAP_CHAIR) || ca.Role__c.equals(CONST_CHAP_MEM_OFF) || ca.Role__c.equals(CONST_CHAP_ADMIN)) {
					if (!accountRoleLookup.containsKey(ca.Chapter__c)) {
						accountRoleLookup.put(ca.Chapter__c, new Map<String, Id> ());
					}
					accountRoleLookup.get(ca.Chapter__c).put(ca.Role__c, ca.User__c);
				}
			}
			for (Lead l : updatedLeads.values()) {
				if (accountRoleLookup.containsKey(l.Referred_by_Chapter__c)) {
					l.Chpter_Chair__c = accountRoleLookup.get(l.Referred_by_Chapter__c).get(CONST_CHAP_CHAIR);
					l.Chapter_Membership_Officer__c = accountRoleLookup.get(l.Referred_by_Chapter__c).get(CONST_CHAP_MEM_OFF);
					l.Chapter_Administrator__c = accountRoleLookup.get(l.Referred_by_Chapter__c).get(CONST_CHAP_ADMIN);
				}
			}
		}
	}
}