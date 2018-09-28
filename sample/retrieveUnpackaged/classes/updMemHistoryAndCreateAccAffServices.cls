public class updMemHistoryAndCreateAccAffServices {
    
    public static String updateMmembershipHistoryAndCreateAffiliations(List<Membership_History__c> scope){
        String errorMessage = '';
        //Assumption only one WPO memberhip hitory record with date left blank per contact
        Map<Id, Membership_History__c> contactToWPOMembership = new Map<Id, Membership_History__c>();
        for(Membership_History__c mh: scope)
            contactToWPOMembership.put(mh.contact__c, mh);
        
        errorMessage += createAffiliationsAndMarkOldAffInactive(contactToWPOMembership);
        errorMessage += updateContactRecords(contactToWPOMembership.values());
        errorMessage += updateMemebershipHistoryRecords(contactToWPOMembership.values());
        errorMessage += updateOpportunities(contactToWPOMembership);
        return errorMessage;
    }
    private static String createAffiliationsAndMarkOldAffInactive(Map<Id, Membership_History__c> contactToWPOMembership ){
        String errorMessage = '';
        List <Account_Affiliation__c> affiliationstoBeCreated = new List <Account_Affiliation__c>();
        Set<String> accConKey = new Set<String>();
        Set<Id> conSet = new Set<Id>();        
        for(Membership_History__c mh: contactToWPOMembership.values()){
            if(mh.Account__r.name != 'Needs Chapter'){
                affiliationstoBeCreated.add(createAffFromMembershipRecord(mh));
                accConKey.add(mh.Account__c +'_'+mh.Contact__c);
                conSet.add(mh.Contact__c);
            }
        }
        try{
            insert affiliationstoBeCreated;
            }
        catch(Dmlexception dEx){
            for(Integer i=0;i<dEX.getNumDML();i++)
                {
            errorMessage += dEx.getDmlMessage(i);
                }
        }
    List <Account_Affiliation__c> affiliationstoBeMarkedInactive = new List <Account_Affiliation__c>();
        
        for(Account_Affiliation__c aff:[Select Id from Account_Affiliation__c 
                                        where Account_Contact_Key__c not in:accConKey and contact__c in:contactToWPOMembership.keySet()
                                        and type__c ='Chapter']){
                                            affiliationstoBeMarkedInactive.add(
                                                new Account_Affiliation__c(Id = aff.id,
                                                                           IsActive__c = false));   
                                        }
        try{
            update affiliationstoBeMarkedInactive;
        }
        catch(Dmlexception dEx){
            for(Integer i=0;i<dEX.getNumDML();i++)
            {
                errorMessage += dEx.getDmlMessage(i);
            }
        }
        return errorMessage;
        //Formula field for acc + con formula field
    }
    private static Account_Affiliation__c createAffFromMembershipRecord(Membership_History__c mh){
        return new Account_Affiliation__c(Account__c = mh.Account__c,
                                          Contact__c = mh.Contact__c,
                                          IsActive__c = true,
                                          Is_Primary__c = true);
    }
    private static String updateContactRecords(List<Membership_History__c> memberships){
        String errorMessage = '';
        List <Contact> contactsToBeUpdated = new List <Contact>();
        Map<Id, Id> householdIdToMembershipHistoryAccount = new Map<Id, Id>();
        for(Membership_History__c mh: memberships){
            //contactsToBeUpdated.add(getUpdatedConRecordFromMembershipRecord(mh));
            if(mh.Contact__r.HouseholdID__c != null)householdIdToMembershipHistoryAccount.put(mh.Contact__r.HouseholdID__c, mh.Account__c);
        }
        for(Contact con: [Select HouseholdID__c from Contact where HouseholdID__c in:householdIdToMembershipHistoryAccount.keySet()]){
            contactsToBeUpdated.add(
                new Contact(id = con.id,
                            accountid = householdIdToMembershipHistoryAccount.get(con.HouseholdID__c),
                            YPO_WPO__c = 'WPO'));
        }
        try{
            update contactsToBeUpdated;
                }
        catch(Dmlexception dEx){
            for(Integer i=0;i<dEX.getNumDML();i++)
                {
            errorMessage += dEx.getDmlMessage(i);
                }
        }
        return errorMessage;
    }
    private static String updateMemebershipHistoryRecords(List<Membership_History__c> memberships){
        String errorMessage = '';
        List <Membership_History__c> memebershipHistoryRecordsToBeUpdated = new List <Membership_History__c>();
        for(Membership_History__c mh: memberships){
            memebershipHistoryRecordsToBeUpdated.add(new Membership_History__c(Id = mh.id,
                                                                               Date_Left__c = date.newInstance(System.today().year(), 6, 30),
                                                                               status__c = 'Resigned',
                                                                               reason__c = 'Transitioned'));
        }
        try{
        update memebershipHistoryRecordsToBeUpdated;
               }
        catch(Dmlexception dEx){
            for(Integer i=0;i<dEX.getNumDML();i++)
                {
            errorMessage += dEx.getDmlMessage(i);
                }
        }
        return errorMessage;
    }
    private static String updateOpportunities(Map<Id, Membership_History__c> contactToWPOMembership ){
        String errorMessage = '';
        List <Opportunity> oppsToBeUpdated = new List <Opportunity>();
        
        for(OpportunityContactRole ocr: [SELECT id, ContactId, OpportunityId, Opportunity.Account.Name, Opportunity.Qualifying_Company__c, Opportunity.Organization_Type__c
                                         FROM OpportunityContactRole WHERE ContactId in: contactToWPOMembership.keySet()
                                         AND Opportunity.StageName = 'New']){
                                             oppsToBeUpdated.add(new Opportunity(Id= ocr.OpportunityId,
                                                                                 StageName = 'Cycle Open',
                                                                                 KGRenewal__IsActiveCart__c = true));     
                                         }
        try{
        update oppsToBeUpdated;
           }
        catch(Dmlexception dEx){
            for(Integer i=0;i<dEX.getNumDML();i++)
                {
            errorMessage += dEx.getDmlMessage(i);
                }
        }
        return errorMessage;
    }
    public static void sendBatchEmailNotification(Id jobId, String batchJobTitle, String BATCH_JOB_Name, String errorMessage){
        
        AsyncApexJob job = [ SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
                            TotalJobItems, CreatedBy.Email, LastProcessedOffset
                            FROM AsyncApexJob 
                            WHERE Id =:jobId];
        List<AsyncApexJob> subJobs = [ SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
                                      TotalJobItems, CreatedBy.Email, LastProcessedOffset
                                      FROM AsyncApexJob 
                                      WHERE ParentJobId =:job.Id 
                                      ORDER BY CompletedDate desc, LastProcessedOffset desc LIMIT 1];
        
        String emailBody = batchJobTitle + ' processed ' + job.TotalJobItems 
            + ' batches with '+ job.NumberOfErrors + ' failures.';
        String emailSubject;
        if(errorMessage != null && errorMessage != ''){
            emailSubject = 'Failure:';
            emailBody += '\n\n Following Errors were Occurred: \n\n' + errorMessage;    
        }
        emailSubject += batchJobTitle + ' ' + System.Today().year() + '/' + System.Today().month() + '/' + System.Today().day();
        //send an email with results to the user, who run the batch
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        maiL.setTargetObjectId(userinfo.getUserId());
        mail.setSubject(emailSubject);
        mail.setsaveAsActivity(false);
        mail.setPlainTextBody(emailBody);
        Messaging.sendEmail( new Messaging.SingleEmailMessage[] { mail } );
    }                
}