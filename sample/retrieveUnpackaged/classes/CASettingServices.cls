/*
* 
* CASettingServices acts as an orchestrator and pulls together task or process  
* logic typically utilising multiple object data.  
* 
* Class provides a strict encapsulation of code 
* implementing business tasks, calculations & processes 
* and is a key entry point to other layers.
*
* This class is serving as service layer for all the operation layer over "CA Setting" object
* @author Shri K
*/
public class CASettingServices {
    
    public final static String CONST_SHARING_METHOD = 'Rule';
    public final static String CONST_CHAP_CHAIR = 'Chapter Chair';
    public final static String CONST_CHAP_MEM_OFF = 'Chapter Membership Officer';
    public final static String CONST_CHAP_ADMIN = 'Chapter Administrator';
    public final static String CONST_PEDNING = 'Pending';
    public static void validateAndMarkPrimary(List<CA_Setting__c> lstNewCASetting, Map<Id, CA_Setting__c> mapOldCASetting){
        List<CA_Setting__c> filteredCASetting = new List<CA_Setting__c>();
        if(Trigger.isUpdate){
            for(CA_Setting__c aNewCASetting: filteredCASetting){
                if((aNewCASetting.Primary__c && (aNewCASetting.Primary__c != mapOldCASetting.get(aNewCASetting.id).Primary__c))
                   ||(aNewCASetting.Chapter__c != mapOldCASetting.get(aNewCASetting.id).Chapter__c))
                    filteredCASetting.add(aNewCASetting);
            }
        }
        else if(Trigger.isInsert){
            filteredCASetting = lstNewCASetting;
        }
        if(!filteredCASetting.isEmpty()){
            Map<Id, Map<String, CA_Setting__c>> chapterToRoleToActivePrimaryCASetting = new Map<Id, Map<String, CA_Setting__c>>();                                  
            for(CA_Setting__c existingCASetting: [Select Chapter__c, Role__c From CA_Setting__c 
                                                  Where Chapter__c IN:Pluck.ids('Chapter__c', filteredCASetting) 
                                                  AND isActive__c = true AND Primary__c =true]){
                                                      if(!chapterToRoleToActivePrimaryCASetting.containsKey(existingCASetting.id)){
                                                          chapterToRoleToActivePrimaryCASetting.put(existingCASetting.Chapter__c, new Map<String, CA_Setting__c>());
                                                          chapterToRoleToActivePrimaryCASetting.get(existingCASetting.Chapter__c)
                                                              .put(existingCASetting.Role__c, existingCASetting);
                                                      }          
                                                  }                       
            for(CA_Setting__c newCASetting: filteredCASetting){
                if(newCASetting.isActive__c){
                    Boolean hasExistingPrimary = false;
                    if(chapterToRoleToActivePrimaryCASetting.containsKey(newCASetting.Chapter__c) 
                       && chapterToRoleToActivePrimaryCASetting.get(newCASetting.Chapter__c).containsKey(newCASetting.Role__c))
                        hasExistingPrimary = true; 
                    if(hasExistingPrimary){
                        if(newCASetting.Primary__c)
                        {
                            newCASetting.addError(Label.Only_One_Primary_CA_Setting);
                        }
                    }else{
                        newCASetting.Primary__c = true;
                    }
                }
            }   
        }
    }
    public static void shareRecordsWithPartnerUser(List<CA_Setting__c> lstNewCASetting, Map<Id, CA_Setting__c> mapOldCASetting)
    {
    	
    	System.debug('###lstNewCASetting: ' + lstNewCASetting);
    	System.debug('###mapOldCASetting: ' + mapOldCASetting);
    	
    	
        List<User> lstUser = new List<User>();
        Map<Id, Id> mapUserAccountId = new Map<Id, Id>();
        List<Id> lstAccountId = new List<Id>();
        
        
        
        for(CA_Setting__c oCASetting: lstNewCASetting)
        {
            //if(oCASetting.Role__c != CONST_CHAP_CHAIR){
                if(oCASetting.isActive__c && (Trigger.isInsert || Trigger.isUpdate && !((CA_Setting__c)mapOldCASetting.get(oCASetting.Id)).isActive__c))
                {
                    lstUser.add(new User(Id = oCASetting.User__c));
                    lstAccountId.add(oCASetting.Chapter__c);
                }
                else if(Trigger.isDelete || (Trigger.isUpdate && ((CA_Setting__c)mapOldCASetting.get(oCASetting.Id)).isActive__c && !oCASetting.isActive__c))
                {
                    mapUserAccountId.put(oCASetting.User__c, oCASetting.Chapter__c);
                }
            //}
        }
        
        if(!lstUser.isEmpty())
        {
            UserServices.shareContact(lstUser, lstAccountId);
            shareLeads(lstAccountId);
        }
        
        if(!mapUserAccountId.isEmpty())
        {
            //how to identify records which are manually shared with users.
            revokeAccessFromAllTheRecords(mapUserAccountId);
        }
    }
    
    private static void shareLeads(List<Id> accountIds)
    {
        List<Lead> leadsToShare = [Select Id, Status, Pursue_Status__c, Referred_by_Chapter__c, OwnerId FROM Lead WHERE Referred_By_Chapter__c IN: accountIds];
        LeadServices.createLeadShareRecords( leadsToShare, null, false );
    }
    
    private static void revokeAccessFromAllTheRecords(Map<Id, Id> mapUserAccountId)
    {
        set<Id> setAccountId = new set<Id>();
        setAccountId.addAll(mapUserAccountId.values());
        set<Id> setContactId = new set<Id>();
        set<Id> setLeadId = new set<Id>();
        
        for(Account_Affiliation__c oAccountAffiliation: [SELECT Id, Contact__c FROM Account_Affiliation__c WHERE Account__c IN: setAccountId])
        {
            setContactId.add(oAccountAffiliation.Contact__c);
        }
        
        List<Opportunity> listOfRelatedOpps = [SELECT Id, OwnerId, AccountId, KGRenewal__Contact__c FROM Opportunity WHERE KGRenewal__Contact__c IN : setContactId AND AccountId != null];
        Set<Id> setOpportunityId = Pluck.Ids('Id', listOfRelatedOpps);
        
        //household account Id
        for(Relationship__c oRelationship: [SELECT Account__c FROM Relationship__c WHERE Contact__c IN: setContactId])
        {
            setAccountId.add(oRelationship.Account__c);
        }
        
        for(Relationship__c oRelationship: [SELECT Contact__c FROM Relationship__c WHERE Account__c IN: setAccountId])
        {
            setContactId.add(oRelationship.Contact__c);
        }
        
        setLeadId = Pluck.ids([SELECT Id FROM Lead WHERE Referred_by_Chapter__c IN: setAccountId]);
        
        
        List<AccountShare> lstAccountShare = [SELECT Id FROM AccountShare WHERE UserOrGroupId IN: mapUserAccountId.keyset() AND AccountId IN: setAccountId
                                              and RowCause != 'ImplicitParent' AND RowCause != 'ImplicitChild' AND RowCause != 'Owner' ];
        delete lstAccountShare;
        
        List<ContactShare> lstConatctShare = [SELECT Id FROM ContactShare WHERE UserOrGroupId IN: mapUserAccountId.keyset() AND ContactId IN: setContactId
                                              and RowCause != 'ImplicitParent' AND RowCause != 'ImplicitChild' AND RowCause != 'Owner' ];
        delete lstConatctShare; 
        
        List<LeadShare> lstLeadShare = [SELECT Id FROM LeadShare WHERE UserOrGroupId IN: mapUserAccountId.keyset() AND LeadId IN: setLeadId
                                        and RowCause != 'ImplicitParent' AND RowCause != 'ImplicitChild' AND RowCause != 'Owner' ];
        delete lstLeadShare; 
        
        List<OpportunityShare> lstOpportunityShare = [SELECT Id FROM OpportunityShare WHERE UserOrGroupId IN: mapUserAccountId.keyset() AND OpportunityId IN: setOpportunityId
                                        and RowCause != 'ImplicitParent' AND RowCause != 'ImplicitChild' AND RowCause != 'Owner' ];
        delete lstOpportunityShare; 
    }
    
    public static void updateLeads(List<CA_Setting__c> lstNewCASetting, Map<Id, CA_Setting__c> mapOldCASetting){
        Set<Id> filteredCASettingIds = new Set<Id>();
        for(CA_Setting__c aNewCASetting: lstNewCASetting){
            if(aNewCASetting.Primary__c && aNewCASetting.isActive__c){ 
                if(mapOldCASetting.isEmpty() ||(!mapOldCASetting.get(aNewCASetting.id).primary__c
                                                || aNewCASetting.Chapter__c != mapOldCASetting.get(aNewCASetting.id).Chapter__c
                                                || aNewCASetting.Role__c != mapOldCASetting.get(aNewCASetting.id).Role__c
                                               ))
                { 
                    filteredCASettingIds.add(aNewCASetting.Id);
                }
            }
        }
        updateLeadsFuture(filteredCASettingIds);
    }
    @future 
    public static void updateLeadsFuture(Set<Id> filteredCASettingIds){
        Map<Id, Map<String, Id>> chapterIdToRoleToAdminUserId = new Map<Id, Map<String, Id>>();
        Map<Id, List<CA_Setting__c>> errorAdderChapterToSettings = new Map<Id, List<CA_Setting__c>>();
        for(CA_Setting__c aNewCASetting: [Select Primary__c, Chapter__c, isActive__c, Role__c, User__c from CA_Setting__c where id in: filteredCASettingIds]){
            Id currentChapterId = aNewCASetting.Chapter__c;
            if(!chapterIdToRoleToAdminUserId.containsKey(currentChapterId))
                chapterIdToRoleToAdminUserId.put(currentChapterId, new Map<String, Id>());
            chapterIdToRoleToAdminUserId.get(currentChapterId).put(aNewCASetting.Role__c, aNewCASetting.User__c);
            if(!errorAdderChapterToSettings.containsKey(currentChapterId))
                errorAdderChapterToSettings.put(currentChapterId, new List<CA_Setting__c>());
            errorAdderChapterToSettings.get(currentChapterId).add(aNewCASetting);            
        }
        if(!chapterIdToRoleToAdminUserId.isEmpty()){
            List<Lead> leadsToBeUpdated = new List<Lead>();
            for(Lead aLead :[Select Id, Referred_by_Chapter__c from Lead where (NOT status like '%Closed%') and Referred_by_Chapter__c in :chapterIdToRoleToAdminUserId.keySet()]){
                Map<String, Id> roleToUserId = chapterIdToRoleToAdminUserId.get(aLead.Referred_by_Chapter__c);
                for(String aRole: roleToUserId.keyset()){
                    Id adminId = roleToUserId.get(aRole);
                    if(aRole.equalsIgnoreCase(CONST_CHAP_MEM_OFF))
                        aLead.Chapter_Membership_Officer__c = adminId;
                    else if(aRole.equalsIgnoreCase(CONST_CHAP_CHAIR))
                        aLead.Chpter_Chair__c = adminId;
                    else if(aRole.equalsIgnoreCase(CONST_CHAP_ADMIN))
                        aLead.Chapter_Administrator__c  = adminId;
                }
                leadsToBeUpdated.add(aLead);
            }
            
            Database.SaveResult[] saveResults = Database.update(leadsToBeUpdated, false);
            List<String> errors = new List<String>();
            for(Integer i = 0; i < saveResults.size(); i++) {
                Database.SaveResult saveResult = saveResults[i];                
                List<Database.Error> saveResultErrors = saveResult.getErrors();
                for(Integer j = 0; j < saveResultErrors.size(); j++) {
                    Database.Error saveResultError = saveResultErrors[j];
                    system.debug('saveResultError '+saveResultErrors);
                    errors.add('CA Setting record: '+ errorAdderChapterToSettings.get(leadsToBeUpdated[i].Referred_by_Chapter__c)+
                               '<br/> Lead: '+ leadsToBeUpdated[i] +'<br/> <span style="color:red;"><b>Fields: '+saveResultError.getFields()[0]+' -- Error Message: '+ saveResultError.getMessage()+'</b></span>');                    
                }
            }
            if(!errors.isEmpty()){
                String sMessage= 'ERROR: An exception has occurred. Please contact your System Administrator quoting the following message <br/> '
                    + String.join(errors, '<br/>'); 
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage() ;
                String[] toAddresses = Chapter_Health_Batch_Error_Email_Setting__c.getInstance().Error_Email_Recipients__c.split(';');
                //mail.setTreatTargetObjectAsRecipient(false);
                mail.setToAddresses(toAddresses) ;
                mail.setSubject('Exception occurred while updating Administration users on Lead records as per the inserted/updated CA setting');
                
                String body = '<html><body>'+
                    '<br><br>'+
                    'This email alert is to bring to your notice that exception occured while updating Administration users on Lead records as per the inserted/updated CA setting'+
                    '<br><br>'+
                    '<b>'+
                    'Here is detail of Exception '+
                    '</b>'+
                    '<br><br>'+ sMessage+
                    '</body></html>';
                mail.setHtmlBody(body);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            /* catch(DmlException dEx){
                for( Integer errorIndex = 0; errorIndex < dEx.getNumDml(); errorIndex++ )
                {
                    Id errorchapterId = leadsToBeUpdated[errorIndex].Referred_by_Chapter__c;
                    for(CA_Setting__c aSetting :errorAdderChapterToSettings.get(errorchapterId))
                        aSetting.addError(dEx.getDmlMessage(errorIndex));
                }
            }*/   
        }
    }

    public static void updateAccAff(List<CA_Setting__c> lstNewCASetting, Map<Id, CA_Setting__c> mapOldCASetting){
        Set<Id> filteredCASettingIds = new Set<Id>();
        for(CA_Setting__c aNewCASetting: lstNewCASetting){
            if(aNewCASetting.Primary__c && aNewCASetting.isActive__c){ 
                if(mapOldCASetting.isEmpty() ||(!mapOldCASetting.get(aNewCASetting.id).primary__c
                                                || aNewCASetting.Chapter__c != mapOldCASetting.get(aNewCASetting.id).Chapter__c
                                                || aNewCASetting.Role__c != mapOldCASetting.get(aNewCASetting.id).Role__c
                                               ))
                { 
                    filteredCASettingIds.add(aNewCASetting.Id);
                }
            }
        }
        updateAccAffFuture(filteredCASettingIds);
    }

    @future
    public static void updateAccAffFuture(Set<Id> filteredCASettingIds){
        Map<Id, Map<String, Id>> chapterIdToRoleToAdminUserId = new Map<Id, Map<String, Id>>();
        Map<Id, List<CA_Setting__c>> errorAdderChapterToSettings = new Map<Id, List<CA_Setting__c>>();
        for(CA_Setting__c aNewCASetting: [Select Primary__c, Chapter__c, isActive__c, Role__c, User__c from CA_Setting__c where id in: filteredCASettingIds]){
            Id currentChapterId = aNewCASetting.Chapter__c;
            if(!chapterIdToRoleToAdminUserId.containsKey(currentChapterId))
                chapterIdToRoleToAdminUserId.put(currentChapterId, new Map<String, Id>());
            chapterIdToRoleToAdminUserId.get(currentChapterId).put(aNewCASetting.Role__c, aNewCASetting.User__c);
            if(!errorAdderChapterToSettings.containsKey(currentChapterId))
                errorAdderChapterToSettings.put(currentChapterId, new List<CA_Setting__c>());
            errorAdderChapterToSettings.get(currentChapterId).add(aNewCASetting);            
        }
        if(!chapterIdToRoleToAdminUserId.isEmpty()){
            List<Account_Affiliation__c> accAffToBeUpdated = new List<Account_Affiliation__c>();
            for(Account_Affiliation__c accAff :[SELECT Id,Account__c FROM Account_Affiliation__c 
                                                WHERE Account__c IN :chapterIdToRoleToAdminUserId.keySet()
                                                      AND (Chapter_Approval_Status__c  =: CONST_PEDNING
                                                      OR IsActive__c    = false)]
               )
            {
                Map<String, Id> roleToUserId = chapterIdToRoleToAdminUserId.get(accAff.Account__c);
                for(String aRole: roleToUserId.keyset()){
                    Id adminId = roleToUserId.get(aRole);
                    if(aRole.equalsIgnoreCase(CONST_CHAP_MEM_OFF))
                    {
                        accAff.Chapter_Membership_Officer__c = adminId;
                    }
                    else if(aRole.equalsIgnoreCase(CONST_CHAP_CHAIR))
                    {
                        accAff.Chapter_Chair__c = adminId;
                    }
                    else if(aRole.equalsIgnoreCase(CONST_CHAP_ADMIN))
                    {
                        accAff.Chapter_Administrator__c  = adminId;
                    }
                }
                accAffToBeUpdated.add(accAff);
            }
            Database.SaveResult[] saveResults = Database.update(accAffToBeUpdated, false);
            List<String> errors = new List<String>();
            for(Integer i = 0; i < saveResults.size(); i++) {
                Database.SaveResult saveResult = saveResults[i];                
                List<Database.Error> saveResultErrors = saveResult.getErrors();
                for(Integer j = 0; j < saveResultErrors.size(); j++) {
                    Database.Error saveResultError = saveResultErrors[j];
                    system.debug('saveResultError '+saveResultErrors);
                    errors.add('CA Setting record: '+ errorAdderChapterToSettings.get(accAffToBeUpdated[i].Account__c)+
                               '<br/> Account Affiliation: '+ accAffToBeUpdated[i] +'<br/> <span style="color:red;"><b>Fields: '+saveResultError.getFields()+' -- Error Message: '+ saveResultError.getMessage()+'</b></span>');                    
                }
            }
            if(!errors.isEmpty()){
                String sMessage= 'ERROR: An exception has occurred. Please contact your System Administrator quoting the following message <br/> '
                    + String.join(errors, '<br/>'); 
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage() ;
                String[] toAddresses = Chapter_Health_Batch_Error_Email_Setting__c.getInstance().Error_Email_Recipients__c.split(';');
                //mail.setTreatTargetObjectAsRecipient(false);
                mail.setToAddresses(toAddresses) ;
                mail.setSubject('Exception occurred while updating Administration users on Account Affiliation records as per the inserted/updated CA setting');
                
                String body = '<html><body>'+
                    '<br><br>'+
                    'This email alert is to bring to your notice that exception occured while updating Administration users on Account Affiliation records as per the inserted/updated CA setting'+
                    '<br><br>'+
                    '<b>'+
                    'Here is detail of Exception '+
                    '</b>'+
                    '<br><br>'+ sMessage+
                    '</body></html>';
                mail.setHtmlBody(body);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }

    
}