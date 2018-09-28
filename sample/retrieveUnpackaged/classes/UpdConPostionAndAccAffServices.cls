/**
* UpdConPostionAndAccAffServices used by UpdCurrentConPostionAndAccAffBatch abd UpdElectConPostionAndAccAffBatch for 
1) When Contact Position Records Status = 'Current'. 
Update Status to Past
Find Account Affiliation for Account__c on Contact Position and update end date to 6/30 year 
just finished and uncheck IsActive__c (make FALSE).
2) When Contact Position Records Status = 'Elect'
Update Status to Past
Find Account Affiliation for Account__c on Contact Position and update start date to 7/1 year 
just started and check IsActive__c (make TRUE)
*
* @author Nikunj Doshi
*/
public class UpdConPostionAndAccAffServices {
    static final string DELIMETER = ',';
    /**
* Updates contact position`s Status to past and related account affiliations IsActive__c and Start & End date as per contact position` status
* @param scope, List of Contact_Position__c to be updated
* @return null
*/ 
    public static void updateConPositionAndAccAffiliation(List<Contact_Position__c> contactPositions){
        String status = contactPositions[0].status__c;
        markConPosAsPast(contactPositions);
        List<Account_Affiliation__c> relatedAffiliations = 
            [Select Id from Account_Affiliation__c where Account__c in: alm_pm2.Pluck.ids('account__c',contactPositions)];
        updateAccAffiliations(relatedAffiliations, status);        
    }
     /**
* Updates contact position`s Status to past
* @param scope, List of Contact_Position__c to be updated
* @return null
*/
    private static void markConPosAsPast(List<Contact_Position__c> scope){
        List<Contact_Position__c> cpsToUpdate = new List<Contact_Position__c>();
        List<Contact> contactsToBeUpdated = new List<Contact>(); 
        Map<Id, Position__c> positionsToBeUpdated = new Map<Id, Position__c>(); 
        for(Contact_Position__c cp: scope){
            Contact con = new Contact(Id = cp.contact__c);
			if(cp.Contact__r.Number_Years_a_Member__c == null)con.Number_Years_a_Member__c = 1;
			else con.Number_Years_a_Member__c = cp.Contact__r.Number_Years_a_Member__c + 1;            
            contactsToBeUpdated.add(con);
            
            if(cp.status__c == 'Current'){
                cp.status__c = 'Past';
                //contactsToBeUpdated.add(new Contact(Id = cp.contact__c, Current_Officer_Position__c = true));
            }
            if(cp.status__c == 'Elect')
            {
                cp.status__c = 'Current';
                //contactsToBeUpdated.add(new Contact(Id = cp.contact__c, Current_Officer_Position__c = false));
            }
            cpsToUpdate.add(cp);
            positionsToBeUpdated.put(cp.Position__c, new Position__c(Id= cp.Position__c, Is_Officer_Position__c = true));
         }            
        update cpsToUpdate;
        update positionsToBeUpdated.values();
    	update contactsToBeUpdated;
        
    }
     /**
* Updates account affiliations IsActive__c and Start & End date fields as per status passed in
* @param status, status__c of Contact_Position__c passed in.
* @param relatedAffiliations, List of Account_Affiliation__c related to Account__c on Contact_Position__c
* @return null
*/
    private static void updateAccAffiliations(List<Account_Affiliation__c> relatedAffiliations, String status){
        List<Account_Affiliation__c> affsToUpdate = new List<Account_Affiliation__c>();
        for(Account_Affiliation__c aff: relatedAffiliations){
            if(status =='Current')
                affsToUpdate.add(new Account_Affiliation__c(Id = aff.id,
                                                            IsActive__c = false,
                                                            End_Date__c = date.newInstance(System.today().year(), 6, 30),
                                                           Reason_for_Leaving__c = 'Transition'));
            if(status =='Elect')
                affsToUpdate.add(new Account_Affiliation__c(Id = aff.id,
                                                            IsActive__c = true ,
                                                            Start_Date__c = date.newInstance(System.today().year(), 7, 1)));
            
        }            
        update affsToUpdate;
    }
}