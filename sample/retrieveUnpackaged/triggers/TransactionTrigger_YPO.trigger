trigger TransactionTrigger_YPO on KGRenewal__Transaction__c (after insert) {
    
	Set<Id> transIds = Pluck.ids('Id', Trigger.new);

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
			TransactionTriggerServices.updateErrorMsg(transIds);
            TransactionTriggerServices.findOpportunity(transIds);
            TransactionTriggerServices.findInvoice(transIds);
        }
    } 

}