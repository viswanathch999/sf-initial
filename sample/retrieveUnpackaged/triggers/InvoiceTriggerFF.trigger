trigger InvoiceTriggerFF on KGRenewal__Invoice__c (before insert, before update) 
{
    Set<Id> oppIds = new Set<Id>();
	for(KGRenewal__Invoice__c invoice : Trigger.new)
    {
        oppIds.add(invoice.KGRenewal__Opportunity__c);
    }
    
    if(oppIds.size() == 0) return;
    
    // query Opps
    Map<Id,Opportunity> opps = new Map<Id,Opportunity>([SELECT KGRenewal__Contact__c FROM Opportunity WHERE Id IN :oppIds AND KGRenewal__Contact__c != null]);

    Set<Id> contactIds = new Set<Id>();
	for(Opportunity opp : opps.values())
    {
        contactIds.add(opp.KGRenewal__Contact__c);
    }    
    
    if(contactIds.size() == 0) return;
    
    Map<Id,Contact> contacts = new Map<Id,Contact>([SELECT Id, (SELECT Account__c FROM Academic_History__r WHERE Relationship_Type__c = 'Member') FROM Contact WHERE Id IN :contactIds]);

	for(KGRenewal__Invoice__c invoice : Trigger.new)
    {
        Opportunity opp = opps.get(invoice.KGRenewal__Opportunity__c);
        if(opp != null && opp.KGRenewal__Contact__c != null)
        {
			Contact contact = contacts.get(opp.KGRenewal__Contact__c);
            if(contact != null && contact.Academic_History__r != null && contact.Academic_History__r.size() == 1)
            {
                invoice.Account_Chapter__c = contact.Academic_History__r[0].Account__c;
            }
        }
    }
    
}