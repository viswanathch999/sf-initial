public with sharing class TierBatchServices {

	public static void assessTiers( List<Relationship__c> conts ){
		
		Map<Id,Contact> contsToUpdate = new Map<Id,Contact>();
		
		Map<Id, List<Relationship__c>> contactsByAccount = GroupBy.ids('Account__c', [Select Id, Account__c, Contact__r.Member_Tier__c From Relationship__c Where Relationship_Type__c = 'Member' AND Account__c IN: Pluck.ids('Account__c',conts) ] );
		
		for(Relationship__c cont : conts){
			
			if(cont.Relationship_Type__c == 'Spouse/Partner' && cont.Contact__r.Membership_status__c == 'Surviving Spouse/Partner' && contactsByAccount.containskey(cont.Account__c)){
				for(Relationship__c famMember : contactsByAccount.get(cont.Account__c)){
					if(famMember.Id != cont.Id && cont.Contact__r.YNG_Member__c != true){
						Contact tempcont = new Contact(id=cont.contact__c);
						//compare surviving spouse and deceased members tier. 
						if(famMember.Contact__r.Member_Tier__c > cont.Contact__r.Member_Tier__c){
							tempcont.Tier_Number__c = famMember.Contact__r.Member_Tier__c;
						}else{
							tempcont.Tier_Number__c = cont.Contact__r.Member_Tier__c;
						}
						contsToUpdate.put(tempcont.Id, tempCont);
					}
				}
			}
		}
		
		if(!contsToUpdate.isEmpty()){
			
			try{
				update new List<Contact> (contsToUpdate.values());
			}catch(DMLException dmlex){
				System.assert(false, 'DML Error occurred updating contacts: '+ dmlex);
			}
		}
	}
}