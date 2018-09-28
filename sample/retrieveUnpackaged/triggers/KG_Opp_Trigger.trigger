trigger KG_Opp_Trigger on Opportunity(before insert, after update, before update)
{
	
	if (Trigger.isBefore) {
		if (Trigger.isUpdate) {
			OpportunityServices.fixProbability(trigger.new, trigger.oldMap);  // keep probability at 100% for pmt pend to pmt rec'd
			List<Opportunity> filteredOpps = OpportunityServices.filterOppsTobeMarkedClosedWon(Trigger.new, Trigger.oldMap);
			if (!filteredOpps.isEmpty()) {
				OpportunityServices.markOppsAsClosedWonFuture(new List<Id> (Pluck.Ids(filteredOpps)));
			}
			OpportunityServices.opportunityBusinessNetwork(Trigger.newMap, Trigger.oldMap);
		}
		else if (Trigger.isInsert) {
			List<Opportunity> filteredOpps = OpportunityServices.filterOppsTobeMarkedClosedWon(Trigger.new, Trigger.oldMap);
			if (!filteredOpps.isEmpty()) {
				OpportunityServices.markOppsAsClosedWonFuture(new List<Id> (Pluck.Ids(filteredOpps)));
			}
		}
	}


	if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			List<Opportunity> filteredReinstatementOpps = OpportunityServices.filterReinstatementOpps(Trigger.new, null);
			Map<Id, Contact> contactMapFromFilteredReinstatement = OpportunityServices.generateContactMap(filteredReinstatementOpps);
			List<Contact> filteredContactsFromOpp = OpportunityServices.filterContactForCommunityUserCreation(contactMapFromFilteredReinstatement.values());
			ContactServices.insertCommunityUsers(ContactServices.createCommunityUserForContact(filteredContactsFromOpp), contactMapFromFilteredReinstatement);
		}

		if (Trigger.isUpdate) {
			OpportunityServices.sendEmails(OpportunityServices.filterPaymentReceivedOpps(Trigger.new, Trigger.oldMap));
			OpportunityServices.filterOppsForAddMemberYear(Trigger.new, Trigger.oldMap);

			List<Opportunity> filteredReinstatementOpps = OpportunityServices.filterReinstatementOpps(Trigger.new, Trigger.oldMap);
			Map<Id, List<Opportunity>> oppMapFromFilteredReinstatement = GroupBy.ids('KGRenewal__Contact__c', trigger.new);
			Map<Id, Contact> contactMapFromFilteredReinstatement = OpportunityServices.generateContactMap(filteredReinstatementOpps);
			List<Contact> filteredContactsFromOpp = OpportunityServices.filterContactForCommunityUserCreation(contactMapFromFilteredReinstatement.values());
			OpportunityServices.insertCommunityUsers(ContactServices.createCommunityUserForContact(filteredContactsFromOpp), oppMapFromFilteredReinstatement);
			List<Opportunity> filteredOpps = OpportunityServices.filterOppsMarkedAsClosedWon(Trigger.new, Trigger.oldMap);
			if (!filteredOpps.isEmpty()) {
				OpportunityServices.UpdateContact(filteredOpps);
			}
			
			try {
				OpportunityServices.fixProbabilityFuture(Pluck.ids('Id', Trigger.new));
			}
			catch (Exception ex) {
				System.debug('fixProbabilityFuture()');
			}
		}
	}
	 
	
}