/*
 * 
 * AccountAffiliationServices acts as an orchestrator and pulls together task or process  
 * logic typically utilising multiple object data.  
 * 
 * Class provides a strict encapsulation of code 
 * implementing business tasks, calculations & processes 
 * and is a key entry point to other layers.
 *
 * @author Shri K
*/
public without sharing class AccountAffiliationServices {

    public static FINAL String MEMBER = 'Member';
    /** Singleton instance created upon class loading */
    final public static AccountAffiliationDAO oAccountAffiliationDAO;
    static {
        oAccountAffiliationDAO = new AccountAffiliationDAO(DAOStrategyType.DMLDAOStrategy);
    }
    public static Map<String, Schema.RecordTypeInfo> recordTypes = RecordTypeServices.getRecordType('Account_Affiliation__c');
    /**
     * Updates the Account affiliation record GUID field with the GUID format.  
     * 
     * @param: lstAccount List of accounts for GUID generation.
     */
    public static void generateGUID(List<Account_Affiliation__c> lstAccountAffiliations)
    {

        final List<Schema.SObjectField> fieldsToUpdate =
        new List<Schema.SObjectField> { Account_Affiliation__c.GUID__c };

        List<AccountAffiliationModel> lstAccountAffiliationModel = new List<AccountAffiliationModel> ();
        AccountAffiliationModel oAccountAffiliationModel;
        for (Account_Affiliation__c oAccountAffiliation : lstAccountAffiliations)
        {
            if (String.isBlank(oAccountAffiliation.GUID__c))
            {
                oAccountAffiliationModel = new AccountAffiliationModel(new Account_Affiliation__c(Id = oAccountAffiliation.Id));

                oAccountAffiliationModel.record.put('GUID__c',
                                                    GUIDServices.newGUID((String) (oAccountAffiliationModel.record.get('Id'))));
                lstAccountAffiliationModel.add(oAccountAffiliationModel);
            }
        }

        if (!lstAccountAffiliationModel.isEmpty()) {
            oAccountAffiliationDAO.modify(lstAccountAffiliationModel, fieldsToUpdate);
        }
    }
    public static void checkIfDuplicateAffExist(List<Account_Affiliation__c> newAccountAffiliations)
    {
        Set<String> existingAffKeys = new Set<String> ();
        for (Account_Affiliation__c similarActiveAffiliation :[Select Account__c, Contact__c from Account_Affiliation__c where IsActive__c = true
             and account__c in :alm_pm2.Pluck.ids('account__c', newAccountAffiliations)
             and Contact__c in :alm_pm2.Pluck.ids('Contact__c', newAccountAffiliations)]) {
            existingAffKeys.add(similarActiveAffiliation.Contact__c + '_' + similarActiveAffiliation.Account__c);
        }

        for (Account_Affiliation__c anAff : newAccountAffiliations) {
            if (anAff.IsActive__c && existingAffKeys.contains(anAff.Contact__c + '_' + anAff.Account__c)) {
                anAff.addError(Label.DuplicateAffiliationFound);
            }
        }
    }
    public static Map<Id, Id> getCAContactToCAUser(Set<Id> contactIds) {
        Map<Id, Id> caContactToCAUser = new Map<Id, Id> ();
        for (User portalCAUser :[Select Id, ContactId, (Select Id from CA_Settings__r) from User where ContactId in :contactIds]) {
            if (!portalCAUser.CA_Settings__r.isEmpty()) caContactToCAUser.put(portalCAUser.ContactId, portalCAUser.Id);
        }
        return caContactToCAUser;
    }

    public static List<Account_Affiliation__c> filterNetworkAffiliations(List<Account_Affiliation__c> newAccountAffiliations,
                                                                         Map<Id, Account_Affiliation__c> oldAccountAffiliations)
    {
        Id networkRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Network','Account_Affiliation__c').id;
        List<Account_Affiliation__c> filteredAffs = new List<Account_Affiliation__c> ();
        for (Account_Affiliation__c anAff : newAccountAffiliations) {
            if (anAff.recordTypeId == networkRecordTypeId) {
                if (oldAccountAffiliations == null || oldAccountAffiliations.isEmpty() ||
                (anAff.IsActive__c != oldAccountAffiliations.get(anAff.id).IsActive__c &&
                 !anAff.IsActive__c))
                filteredAffs.add(anAff);
            }
        }
        return filteredAffs;
    }
    public static void revokeCAToNetworkAccSharing(List<Account_Affiliation__c> filteredAccountAffiliations) {
        if (!filteredAccountAffiliations.isEmpty()) {
            Map<Id, Id> caContactToCAUser = getCAContactToCAUser(alm_pm2.Pluck.ids('Contact__c', filteredAccountAffiliations));
            Map<String, Account_Affiliation__c> errorAdder = new Map<String, Account_Affiliation__c> ();
            String deleteShareQuery = 'Select id from accountshare where ';
            List<String> whereClauses = new List<String> ();
            for (Account_Affiliation__c anAff : filteredAccountAffiliations) {
                if (caContactToCAUser.containsKey(anAff.Contact__c))
                whereClauses.add(' (AccountId = \'' + anAff.Account__c +
                                 '\' and UserOrGroupId = \'' + caContactToCAUser.get(anAff.Contact__c) + '\') ');
                errorAdder.put(anAff.Account__c + '_' + caContactToCAUser.get(anAff.Contact__c),
                               anAff);
            }
            if (!whereClauses.isEmpty()) {
                deleteShareQuery += String.join(whereClauses, ' or ');
                List<AccountShare> sharesToDelete = Database.query(deleteShareQuery);
                if (!sharesToDelete.isEmpty()) {
                    try {
                        delete sharesToDelete;
                    } catch(DmlException dEx) {
                        for (Integer errorIndex = 0; errorIndex<dEx.getNumDml(); errorIndex++)
                        {
                            String key = sharesToDelete[errorIndex].accountid + '_' + sharesToDelete[errorIndex].UserOrGroupId;
                            errorAdder.get(key).addError(dEx.getDmlMessage(errorIndex));
                        }
                    }
                }
            }
        }
    }
    public static Id memberContactRecordTypeId {
        get {
            if (memberContactRecordTypeId == null)
            memberContactRecordTypeId = RecordTypeServices.getRecordTypeByName(MEMBER, 'Contact').Id;
            return memberContactRecordTypeId; }
        set; }

    public static void addAccAffForSpouse(List<Account_Affiliation__c> newAccAffs) {
        Map<Id, List<Account_Affiliation__c>> memberIdToAffIds = new Map<Id, List<Account_Affiliation__c>> ();
        Map<Id, Set<Account_Affiliation__c>> householdIdToMemberAffs = new Map<Id, Set<Account_Affiliation__c>> ();

        for (Account_Affiliation__c anAff : newAccAffs) {
            //ND 14/11/16 Only sync the Chapter account affiliations. 
            if (anAff.RecordTypeId == RelationshipServices.chapterAccAffRTId) {
                if (!memberIdToAffIds.containsKey(anAff.contact__c))
                memberIdToAffIds.put(anAff.contact__c, new List<Account_Affiliation__c> ());
                memberIdToAffIds.get(anAff.contact__c).add(anAff);
            }
        }

        if (!memberIdToAffIds.isEmpty()) {
            Set<Id> memberContactsId = alm_pm2.Pluck.ids('contact__c', newAccAffs);
            for (Relationship__c houseHoldRel :[Select id, account__c, contact__c from Relationship__c where
                 Relationship_Type__c = :MEMBER and
                 contact__c IN :memberContactsId AND contact__r.recordtypeid = :memberContactRecordTypeId]) {
                //if(householdIdToMemberAffs != null && memberIdToAffIds != null && householdRel.Account__c != null && householdRel.contact__c != null){
                if (!householdIdToMemberAffs.containsKey(houseHoldRel.account__c))
                householdIdToMemberAffs.put(houseHoldRel.account__c, new Set<Account_Affiliation__c> ());
                householdIdToMemberAffs.get(houseHoldRel.account__c).addAll(memberIdToAffIds.get(houseHoldRel.contact__c));
                //}
            }
            Map<Id, Account_Affiliation__c> spouseIdToMemberAff = new Map<Id, Account_Affiliation__c> ();
            List<Account_Affiliation__c> spouseAccAffsToInsert = new List<Account_Affiliation__c> ();
            Set<Id> contactIds = new Set<Id> ();
            Set<Id> accountIds = new Set<Id> ();
            Map<String, Account_Affiliation__c> keyToSpouseAccAffsToInsert = new Map<String, Account_Affiliation__c> ();

            for (Relationship__c spouseRel :[Select id, contact__c, account__c from Relationship__c where
                 Relationship_Type__c = 'Spouse/Partner' and account__c IN :householdIdToMemberAffs.keyset()
                 AND Contact__r.Is_Spouse_Member__c != true AND Contact__r.RecordTypeId != :memberContactRecordTypeId]) {
                for (Account_Affiliation__c anAff : householdIdToMemberAffs.get(spouseRel.account__c)) {
                    Account_Affiliation__c spouseAccAff = anAff.clone(false, false);
                    spouseAccAff.contact__c = spouseRel.contact__c;
                    spouseAccAff.Contact_Type__c = 'Spouse/Partner';
                    spouseAccAff.Guid__c = null;
                    //spouseAccAffsToInsert.add(spouseAccAff);
                    contactIds.add(spouseRel.contact__c);
                    accountIds.add(spouseRel.Account__c);
                    keyToSpouseAccAffsToInsert.put(spouseRel.contact__c + '_' + anAff.Account__c, spouseAccAff);
                    spouseIdToMemberAff.put(spouseRel.contact__c, anAff);
                }
            }
            //ND 28/11/16 Remove if already a similar affiliation exists
            for (Account_Affiliation__c existingAff :[Select Account__c, contact__c from Account_Affiliation__c where Account__c in :accountIds and contact__c in :contactIds]) {
                keyToSpouseAccAffsToInsert.remove(existingAff.contact__c + '_' + existingAff.Account__c);
            }
            spouseAccAffsToInsert = keyToSpouseAccAffsToInsert.values();
            try {
                insert spouseAccAffsToInsert;
            }
            catch(DmlException dEx) {
                for (Integer errorIndex = 0; errorIndex<dEx.getNumDml(); errorIndex++)
                {
                    Id errorSpouseContactId = spouseAccAffsToInsert[errorIndex].contact__c;
                    spouseIdToMemberAff.get(errorSpouseContactId).addError(dEx.getDmlMessage(errorIndex));
                }
            }
        }
    }
    public static List<Account_Affiliation__c> filterAccAffsForSync(List<Account_Affiliation__c> newAccountAffiliations, Map<Id, Account_Affiliation__c> oldAccountAffiliations) {
        List<Account_Affiliation__c> filteredAffs = new List<Account_Affiliation__c> ();
        Boolean attributeGroupOneHaveChanged = false;
        Boolean attributesGroupTwoHaveChanged = false;

        for (Account_Affiliation__c anAff : newAccountAffiliations)
        {
            //ND 14/11/16 Only sync the Chapter account affiliations. 23/11/16 Not to sync affiliations whose Reason for Leaving is Transitioned
            if (anAff.Contact_Record_Type_Name__c == MEMBER && anAff.RecordTypeId == RelationshipServices.chapterAccAffRTId)
            {
                attributeGroupOneHaveChanged = (anAff.IsActive__c != oldAccountAffiliations.get(anAff.id).IsActive__c) || (anAff.Is_Primary__c != oldAccountAffiliations.get(anAff.id).Is_Primary__c) || (anAff.Start_Date__c != oldAccountAffiliations.get(anAff.id).Start_Date__c) ? true : false;
                attributesGroupTwoHaveChanged = (anAff.Transfer_Flag__c != oldAccountAffiliations.get(anAff.id).Transfer_Flag__c) || (anAff.Chapter_Approval_Status__c != oldAccountAffiliations.get(anAff.id).Chapter_Approval_Status__c) || (anAff.End_Date__c != oldAccountAffiliations.get(anAff.id).End_Date__c)
                || (anAff.Reason_for_Leaving__c != oldAccountAffiliations.get(anAff.id).Reason_for_Leaving__c) || (anAff.Reason_Leaving_Other__c != oldAccountAffiliations.get(anAff.id).Reason_Leaving_Other__c) ? true : false;

                if (attributeGroupOneHaveChanged || attributesGroupTwoHaveChanged)
                {
                    filteredAffs.add(anAff);
                }
            }
        }
        return filteredAffs;
    }

    public static List<Account_Affiliation__c> filterAccAffsMarkedPrimary(List<Account_Affiliation__c> newAccountAffiliations, Map<Id, Account_Affiliation__c> oldAccountAffiliations)
    {
        List<Account_Affiliation__c> filteredAffs = new List<Account_Affiliation__c> ();
        for (Account_Affiliation__c anAff : newAccountAffiliations) {
            if (anAff.Contact_Record_Type_Name__c == MEMBER && anAff.RecordTypeId == RelationshipServices.chapterAccAffRTId) {
                if (anAff.Is_Primary__c && anAff.Is_Primary__c != oldAccountAffiliations.get(anAff.id).Is_Primary__c)
                filteredAffs.add(anAff);
            }
        }
        return filteredAffs;
    }
    public static void syncSpouseAccAffs(List<Account_Affiliation__c> filteredMemberAffiliations, Map<Id, Account_Affiliation__c> oldAccountAffiliations) {

        if (filteredMemberAffiliations != null)
        {
            Map<Id, Set<Account_Affiliation__c>> householdIdToMemberAffs = getHouseholdIdToMemberAffsMap(filteredMemberAffiliations);

            //Assumption there wouldn`t be any two spouse affiliation with same chapter and with same start date.
            Map<Id, Map<Id, Map<Date, Account_Affiliation__c>>> mapSpouseIdAccIdToMemberAffs = new Map<Id, Map<Id, Map<Date, Account_Affiliation__c>>> ();

            for (Relationship__c spouseRel :[Select id, contact__c, account__c from Relationship__c
                 where Relationship_Type__c = 'Spouse/Partner' AND account__c IN :householdIdToMemberAffs.keyset()
                 AND Contact__r.Is_Spouse_Member__c != true AND Contact__r.RecordTypeId != :memberContactRecordTypeId])
            {
                for (Account_Affiliation__c memberAff : householdIdToMemberAffs.get(spouseRel.account__c))
                {
                    if (!mapSpouseIdAccIdToMemberAffs.containsKey(spouseRel.Contact__c))
                    {
                        mapSpouseIdAccIdToMemberAffs.put(spouseRel.Contact__c, new Map<Id, Map<Date, Account_Affiliation__c>> ());
                    }
                    Map<Id, Map<Date, Account_Affiliation__c>> accIdToAffs = mapSpouseIdAccIdToMemberAffs.get(spouseRel.Contact__c);
                    if (!accIdToAffs.containsKey(memberAff.account__c))
                    {
                        accIdToAffs.put(memberAff.account__c, new Map<Date, Account_Affiliation__c> ());
                    }
                    Date startDate = memberAff.Start_Date__c;

                    if (oldAccountAffiliations.containsKey(memberAff.id))
                    {
                        startDate = oldAccountAffiliations.get(memberAff.id).Start_Date__c;
                    }
                    accIdToAffs.get(memberAff.account__c).put(startDate, memberAff);
                    mapSpouseIdAccIdToMemberAffs.put(spouseRel.Contact__c, accIdToAffs);
                }
            }
            Map<Id, Account_Affiliation__c> spouseAccAffsToUpdate = new Map<Id, Account_Affiliation__c> ();
            Map<Id, Account_Affiliation__c> spouseAccAffsToDeActivate = new Map<Id, Account_Affiliation__c> ();

            for (Account_Affiliation__c spouseAff :[Select id, contact__c, account__c, isActive__c, is_Primary__c, Start_Date__c, createddate, reason_for_leaving__c,
                 Reason_Leaving_Other__c, End_date__c, Chapter_Approval_Status__c, Transfer_Flag__c, An_Affiliate__c
                 from Account_Affiliation__c
                 where contact__c IN :mapSpouseIdAccIdToMemberAffs.keySet()])
            {
                if (mapSpouseIdAccIdToMemberAffs.containsKey(spouseAff.contact__c))
                {
                    Map<Id, Map<Date, Account_Affiliation__c>> accToAffs = new Map<Id, Map<Date, Account_Affiliation__c>> ();
                    accToAffs = mapSpouseIdAccIdToMemberAffs.get(spouseAff.contact__c);

                    if (accToAffs.containsKey(spouseAff.account__c))
                    {
                        Map<Date, Account_Affiliation__c> startDateToAff = accToAffs.get(spouseAff.account__c);
                        if (startDateToAff.containsKey(spouseAff.Start_Date__c))
                        {
                            Account_Affiliation__c relatedMemberAff = startDateToAff.get(spouseAff.Start_Date__c);
                            spouseAff.isActive__c = relatedMemberAff.isActive__c;
                            spouseAff.is_Primary__c = relatedMemberAff.is_Primary__c;
                            spouseAff.Start_Date__c = relatedMemberAff.Start_Date__c;
                            spouseAff.Chapter_Approval_Status__c = relatedMemberAff.Chapter_Approval_Status__c;
                            spouseAff.Transfer_Flag__c = relatedMemberAff.Transfer_Flag__c;
                            spouseAff.End_Date__c = relatedMemberAff.End_Date__c;
                            spouseAff.Reason_for_leaving__c = relatedMemberAff.Reason_for_leaving__c;
                            spouseAff.Reason_Leaving_Other__c = relatedMemberAff.Reason_Leaving_Other__c;
                            spouseAff.Contact_Type__c = 'Spouse/Partner';
                            spouseAccAffsToUpdate.put(spouseAff.Id, spouseAff);
                        }
                    }
                }
            }
            try {
                update spouseAccAffsToUpdate.values();

            }
            catch(DmlException ex) {
                for (Integer i = 0; i<ex.getNumDml(); i++) {
                    oldAccountAffiliations.get(ex.getDmlId(i)).addError(ex.getDmlMessage(i));
                }
            }
        }
    }

    public static void updateContactChapterLookup(List<Account_Affiliation__c> filteredPrimaryMemberAffiliations) {
        if (filteredPrimaryMemberAffiliations != null) {
            Map<Id, Account_Affiliation__c> errorAdderConToAff = new Map<Id, Account_Affiliation__c> ();
            Map<Id, Set<Account_Affiliation__c>> householdIdToMemberAffs = getHouseholdIdToMemberAffsMap(filteredPrimaryMemberAffiliations);
            Map<Id, Contact> contactsToUpdateMap = new Map<Id, Contact> ();
            Set<string> relationshipsToExclude = new Set<String> { MEMBER, 'Ex Spouse/Partner', 'Member Spouse/Partner' };
            for (Relationship__c relatedRelationship :[Select id, contact__c, account__c, Relationship_Type__c from Relationship__c where Account__c IN :householdIdToMemberAffs.keyset()
                 and Relationship_Type__c not in :relationshipsToExclude]) {
                if (householdIdToMemberAffs.containsKey(relatedRelationship.account__c)) {
                    //Assumption only primary affiliation for a member
                    List<Account_Affiliation__c> primaryAffs =
                    new List<Account_Affiliation__c> (householdIdToMemberAffs.get(relatedRelationship.account__c));
                    contactsToUpdateMap.put(relatedRelationship.contact__c, new Contact(Id = relatedRelationship.contact__c,
                                                                                        accountId = primaryAffs[0].account__c));
                    errorAdderConToAff.put(relatedRelationship.contact__c, primaryAffs[0]);
                    contactsToUpdateMap.put(primaryAffs[0].contact__c, new Contact(Id = primaryAffs[0].contact__c,
                                                                                   accountId = primaryAffs[0].account__c));
                    errorAdderConToAff.put(primaryAffs[0].contact__c, primaryAffs[0]);
                }
            }
            List<Contact> contactsToUpdate = contactsToUpdateMap.values();
            if (!contactsToUpdate.isEmpty()) {
                try {
                    update contactsToUpdate;
                }
                catch(DmlException dEx) {
                    for (Integer errorIndex = 0; errorIndex<dEx.getNumDml(); errorIndex++)
                    {
                        errorAdderConToAff.get(contactsToUpdate[errorIndex].Id).addError(dEx.getDmlMessage(errorIndex));
                    }
                }
            }
        }
    }
    public static Map<Id, Set<Account_Affiliation__c>> getHouseholdIdToMemberAffsMap(List<Account_Affiliation__c> filteredMemberAffiliations) {
        Map<Id, List<Account_Affiliation__c>> memberIdToAffIds = new Map<Id, List<Account_Affiliation__c>> ();
        Map<Id, Set<Account_Affiliation__c>> householdIdToMemberAffs = new Map<Id, Set<Account_Affiliation__c>> ();
        for (Account_Affiliation__c anAff : filteredMemberAffiliations) {
            if (!memberIdToAffIds.containsKey(anAff.contact__c)) {
                memberIdToAffIds.put(anAff.contact__c, new List<Account_Affiliation__c> ());
            }
            memberIdToAffIds.get(anAff.contact__c).add(anAff);
        }
        Set<Id> memberContactsId = alm_pm2.Pluck.ids('contact__c', filteredMemberAffiliations);

        for (Relationship__c houseHoldRel :[Select id, account__c, contact__c from Relationship__c where
             Relationship_Type__c = :MEMBER and
             contact__c IN :memberContactsId AND contact__r.recordtypeid = :memberContactRecordTypeId]) {
            if (!householdIdToMemberAffs.containsKey(houseHoldRel.account__c))
            householdIdToMemberAffs.put(houseHoldRel.account__c, new Set<Account_Affiliation__c> ());
            householdIdToMemberAffs.get(houseHoldRel.account__c).addAll(memberIdToAffIds.get(houseHoldRel.contact__c));
        }
        return householdIdToMemberAffs;
    }

    //public void educationProfileCheck(Map<Id, Account_Affiliation__c> newCollection, Map<Id, Account_Affiliation__c> oldCollection, Boolean isdeleted) {
        //Map<Id, String> jsonMap = new Map<Id, String> ();

        //Profile_Completion_Criteria__c updateCompletion;
        //if (isdeleted) {
            //for (Id i : oldCollection.keySet()) {
                //updateCompletion = new Profile_Completion_Criteria__c();
                //if (oldCollection.get(i).RecordTypeId == recordTypes.get('School').getRecordTypeId()) {
                    //updateCompletion.Education__c = 0;
                    //jsonMap.put(oldCollection.get(i).Contact__c, JSON.serialize(updateCompletion));
                //}

            //}
        //} else {
            //for (Id i : newCollection.keySet()) {
                //updateCompletion = new Profile_Completion_Criteria__c();
                //if (newCollection.get(i).RecordTypeId == recordTypes.get('School').getRecordTypeId()) {
                    //updateCompletion.Education__c = 1;
                //}
                //jsonMap.put(newCollection.get(i).Contact__c, JSON.serialize(updateCompletion));
            //}
        //}


        //if (!jsonMap.isEmpty()) {
            //ProfileCompletionUtility.ProfileCompletionUtility(jsonMap);
        //}
    //}

    //public void businessProfileCheck(Map<Id, Account_Affiliation__c> newCollection, Map<Id, Account_Affiliation__c> oldCollection, Boolean isdeleted) {
        //Map<Id, String> jsonMap = new Map<Id, String> ();

        //Profile_Completion_Criteria__c updateCompletion;
        //if (isdeleted) {
            //for (Id i : oldCollection.keySet()) {
                //updateCompletion = new Profile_Completion_Criteria__c();
                //if (oldCollection.get(i).RecordTypeId == recordTypes.get('Business').getRecordTypeId() && oldCollection.get(i).is_Primary__c == true && oldCollection.get(i).isActive__c == true) {
                    //updateCompletion.Business_Role__c = 0;
                    //updateCompletion.Company_Name__c = 0;
                    //updateCompletion.Company_Industry_Category__c = 0;
                    //updateCompletion.Company_Type__c = 0;
                    //updateCompletion.Company_Address__c = 0;
                    //updateCompletion.Business_Scope__c = 0;
                    //updateCompletion.Type_of_President__c = 0;
                //}
                //jsonMap.put(oldCollection.get(i).Contact__c, JSON.serialize(updateCompletion));
            //}
        //} else {
            //for (Id i : newCollection.keySet()) {
                //updateCompletion = new Profile_Completion_Criteria__c();
                //if (newCollection.get(i).RecordTypeId == recordTypes.get('Business').getRecordTypeId() && newCollection.get(i).is_Primary__c == true && newCollection.get(i).isActive__c == true) {
                    //if (newCollection.get(i).Job_Title__c != null){
                        //updateCompletion.Business_Role__c = 1;
                    //}else{
                        //updateCompletion.Business_Role__c = 0;
                    //}

                    //if (newCollection.get(i).Account__c != null){
                        //updateCompletion.Company_Name__c = 1;
                    //}else{
                        //updateCompletion.Company_Name__c = 0;
                    //}

                    //if (newCollection.get(i).Industry_Category_1__c != null){
                        //updateCompletion.Company_Industry_Category__c = 1;
                    //}else{
                        //updateCompletion.Company_Industry_Category__c = 0;
                    //}

                    //if (newCollection.get(i).Organization_Type__c != null){
                        //updateCompletion.Company_Type__c = 1;
                    //}else{
                        //updateCompletion.Company_Type__c = 0;
                    //}

                    //if (newCollection.get(i).Street__c != null){
                        //updateCompletion.Company_Address__c = 1;
                    //}else{
                        //updateCompletion.Company_Address__c = 0;
                    //}

                    //if (newCollection.get(i).Scope_of_Business__c != null){
                        //updateCompletion.Business_Scope__c = 1;
                    //}else{
                        //updateCompletion.Business_Scope__c = 0;
                    //}

                    //if (newCollection.get(i).Business_Role__c != null){
                        //updateCompletion.Type_of_President__c = 1;
                    //}else{
                        //updateCompletion.Type_of_President__c = 0;
                    //}
                    //if (newCollection.get(i).Company_Size__c != null){
                        //updateCompletion.Company_Size__c = 1;
                    //}else{
                        //updateCompletion.Company_Size__c = 0;
                    //}                    
                //}
                //System.debug(updateCompletion);
                //jsonMap.put(newCollection.get(i).Contact__c, JSON.serialize(updateCompletion));
            //}
        //}
        //if (!jsonMap.isEmpty()) {
            //ProfileCompletionUtility.ProfileCompletionUtility(jsonMap);
        //}
    //}
}