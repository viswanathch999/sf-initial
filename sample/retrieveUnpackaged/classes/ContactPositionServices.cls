public class ContactPositionServices {
    public static List<String> statusToConsider = new List<String>{'Current', 'Elect'};
    public static Boolean validateDuplicatePositionRecords(List<Contact_Position__c> newContactPositions){
        Map<String, String> keyToDuplicateContact= new Map<String, String>();
        for(Contact_Position__c aCP:  [Select Account__c, Status__c, Contact__c, Contact__r.name, Position__c, Id From Contact_Position__c Where 
                                       Account__c In : alm_pm2.Pluck.ids('Account__c', newContactPositions)
                                       AND Status__c In :statusToConsider
                                       AND Position__c In :alm_pm2.Pluck.ids('Position__c', newContactPositions)]){
                                           keyToDuplicateContact.put(aCP.Account__c+'_'+aCP.Position__c+'_'+aCP.Status__c, aCP.Contact__r.name);        
                                       }
        for(Contact_Position__c newCP: newContactPositions){
            String key = newCP.Account__c+'_'+newCP.Position__c+'_'+newCP.Status__c;
            system.debug( '@@ The map : '+ keyToDuplicateContact + ' Is empty? : '+ keyToDuplicateContact.isEmpty() + ' In map? : '+ keyToDuplicateContact.containsKey(key));
            if(  keyToDuplicateContact.containsKey(key)){
            	System.debug('@@ dupe found: ');
                //newCP.addError(Label.Duplicate_Contact_Position	+' '+keyToDuplicateContact.get(key));
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, Label.Duplicate_Contact_Position	+' '+keyToDuplicateContact.get(key)));
                return false;
            }
        }
        System.debug('@@ no dupe found');
        return true;
    }
}