public class KGRenewalInvoiceServices {
    
    public static List<KGRenewal__Invoice__c> 
        filterCheckOrWireTranferInvoice(List<KGRenewal__Invoice__c> newInvoices, Map<Id, KGRenewal__Invoice__c> oldInvoices){
            List<KGRenewal__Invoice__c> filteredNotifications = new List<KGRenewal__Invoice__c>();
            Boolean isUpdate = false;
            if(!oldInvoices.isEmpty())isUpdate = true;
            for(KGRenewal__Invoice__c newInvoice :newInvoices){
                if(newInvoice.Payment_Type__c == Label.Check_or_Wire_Payment){
                    if(isUpdate && newInvoice.Payment_Type__c != oldInvoices.get(newInvoice.id).Payment_Type__c)
                        filteredNotifications.add(newInvoice);
                    else if(!isUpdate)
                        filteredNotifications.add(newInvoice);
                }
            }
            return filteredNotifications;
        }
    Static Final String TEMPLATE_NAME= 'Instructions_to_complete_check_wire_transfer';
    public static void sendEmails(List<KGRenewal__Invoice__c> filteredInvoices){
        Id instructionTemplateId = [Select Id from EmailTemplate where DeveloperName =:TEMPLATE_NAME][0].id;
        List<Messaging.SingleEmailMessage> messagesToBeSent = new List<Messaging.SingleEmailMessage>();
        Map<Id, Set<Id>> MapofHouseHoldIdToMemberIds = getMapofHouseHoldIdToMemberIds(alm_pm2.Pluck.ids('KGRenewal__Account__c', filteredInvoices));
        for(KGRenewal__Invoice__c newInvoice :filteredInvoices){
            for(Id memberId :mapofHouseHoldIdToMemberIds.get(newInvoice.KGRenewal__Account__c)){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setWhatId(newInvoice.id);
                email.setTemplateId(instructionTemplateId);
                email.setTargetObjectId(memberId);
                email.setSaveAsActivity(true);
                messagesToBeSent.add(email);
            }
            KGRenewal.EncoreAPI.sendInvoiceEmail( newInvoice.Id );
        }
        Messaging.sendEmail(messagesToBeSent);
    }
    public static Map<Id, Set<Id>> getMapofHouseHoldIdToMemberIds(Set<Id> houseHoldAccIds){
        Map<Id, Set<Id>> houseHoldIdToMemberIds = new Map<Id, Set<Id>>();
        for(Relationship__c rel : [Select Contact__r.Email, Contact__c, Account__c From Relationship__c Where Relationship_Type__c = 'Member' AND Account__c IN: houseHoldAccIds])
        {
            if(!houseHoldIdToMemberIds.containsKey(rel.Account__c))                      
                houseHoldIdToMemberIds.put(rel.Account__c, new Set<Id>());
            houseHoldIdToMemberIds.get(rel.Account__c).add(rel.Contact__c);  
        }
        return houseHoldIdToMemberIds;
    }
}