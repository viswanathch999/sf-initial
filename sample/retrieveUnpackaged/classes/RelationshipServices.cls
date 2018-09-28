public class RelationshipServices {
    
    public static final String CONST_SPOUSE = 'Spouse/Partner';
	public static final String CONST_EX_SPOUSE = 'Ex Spouse/Partner';
    public static Set<String> spouseTypes{
        get{
            if(spouseTypes==null){
                spouseTypes = new Set<String>{CONST_SPOUSE};
                    if(!Restrict_More_Than_One_Active_SpouseType__c.getAll().isempty())
                    spouseTypes.addAll(Restrict_More_Than_One_Active_SpouseType__c.getAll().keyset());
            }
            return spouseTypes;
        }set;
    }
    
    public static List<Relationship__c> filterSpouseRelationships(List<Relationship__c> newRelationships, Map<Id, Relationship__c> oldRelationships){
        List<Relationship__c> filteredRelationships = new List<Relationship__c>();
        for(Relationship__c newRelationship: newRelationships){
            if(newRelationship.Relationship_Type__c == CONST_SPOUSE )
            	//System.assert(false, oldRelationships + ' , '+ newRelationship);
                if((oldRelationships.isEmpty() && newRelationship.Is_Active__c )|| ( !oldRelationships.isEmpty()  && newRelationship.Is_Active__c != oldRelationships.get(newRelationship.id).Is_Active__c )){
                    filteredRelationships.add(newRelationship);
                }
        }
        return filteredRelationships;
    }   
    public static List<Relationship__c> filterActiveSpouseRelationship(List<Relationship__c> allRelationships, Map<Id,Relationship__c> oldRelationships){
        List<Relationship__c> filteredRelationships = new List<Relationship__c>();
        Boolean isUpdate = false;
        if(!oldRelationships.isEmpty()) isUpdate = true;
        for(Relationship__c aRel :allRelationships){
            if(aRel.is_active__c && spouseTypes.contains(aRel.Relationship_Type__c)){
                if(isUpdate){
                    if(aRel.is_active__c != oldRelationships.get(aRel.id).is_active__c) filteredRelationships.add(aRel);
                }
                else filteredRelationships.add(aRel);
            }
        }
        return filteredRelationships;
    }
    
    public static List<Relationship__c> filterForExSpouseRelationship(List<Relationship__c> allRelationships, Map<Id,Relationship__c> oldRelationships){
        List<Relationship__c> filteredRelationships = new List<Relationship__c>();

        for(Relationship__c aRel :allRelationships){
			System.debug('Relationship Types: ' + aRel.Relationship_Type__c + '/' + oldRelationships.get(aRel.id).Relationship_Type__c);
            if(aRel.Relationship_Type__c == CONST_EX_SPOUSE && oldRelationships.get(aRel.id).Relationship_Type__c == CONST_SPOUSE){
                filteredRelationships.add(aRel);
				System.debug(aRel);
            }
        }
        return filteredRelationships;
    }

    public static void restrictMoreThanOneActiveSpouse(List<Relationship__c> allRelationships){
        if(!allRelationships.isEmpty()){
            Set<Id> accs = alm_pm2.Pluck.ids('account__c',allRelationships);            
            Set<Id> conts = alm_pm2.Pluck.ids('contact__c',allRelationships);            
            Map<Id,Relationship__c> existingRels = new Map<Id,Relationship__c>([Select account__c, Contact__c from Relationship__c where Relationship_Type__c IN :spouseTypes
                                                                         and account__c IN: accs 
                                                                         and Is_Active__c =true
                                                                         and contact__c NOT IN: conts]);
            Set<Id> householdsHavingActiveSpouseRelationships = alm_pm2.Pluck.ids('account__c', existingRels.values());
            
            for(Relationship__c newSpouseRel: allRelationships){
                if(householdsHavingActiveSpouseRelationships.size()>0 && householdsHavingActiveSpouseRelationships.contains(newSpouseRel.account__c) )
                    newSpouseRel.addError(Label.Duplicate_Spouse_Error_Message);
            }
        }
    }
    /*public static void restrictMoreThanOneActiveSpouse(List<Relationship__c> allRelationships){
        if(!allRelationships.isEmpty()){
            Set<Id> accs = alm_pm2.Pluck.ids('account__c',allRelationships);
            Set<Id> activeSpouseRelationships = alm_pm2.Pluck.ids('id', [Select Id from Relationship__c where Relationship_Type__c IN :spouseTypes
                                                                         and account__c IN: accs 
                                                                         and Is_Active__c =true]);
            
            for(Relationship__c aRel: allRelationships){
                system.debug('activeSpouseRelationships '+activeSpouseRelationships+' aRel '+aRel);
                if(activeSpouseRelationships.size()>0 && !activeSpouseRelationships.contains(aRel.id))
                    aRel.addError(Label.Duplicate_Spouse_Error_Message);
            }
        }
    }*/
    public static Id chapterAccAffRTId{
        get{
            if(chapterAccAffRTId == null)
                chapterAccAffRTId = RecordTypeServices.getRecordTypeByDeveloperName('Chapter', 'Account_Affiliation__c').Id;
            return chapterAccAffRTId;
        }set;
    }
    public static void updateAccountAffiliations(List<Relationship__c> newRelationships){        
        List<Account_Affiliation__c> accAfftUpdated = new List<Account_Affiliation__c>();
        Set<Id> contactIds =new Set<Id>();
        contactIds = alm_pm2.Pluck.ids('Contact__c', newRelationships);// alm__pm2.pluck.ids();
        //ND 14/11/16 Only sync the Chapter account affiliations. 
        List<Account_Affiliation__c> accAfftobeUpdated = [Select id, contact__c, account__c, account__r.RecordType.DeveloperName , 
        													Start_Date__c, is_Primary__c, isActive__c, transfer_flag__c, chapter_approval_Status__c, 
        													end_Date__c, Reason_For_leaving__c 
        												from Account_Affiliation__c 
        												where Contact__c IN :contactIds 
        												and recordTypeId =:chapterAccAffRTId];
        
        for(Relationship__c rel : newRelationships){
            for(Account_Affiliation__c accAff : accAfftobeUpdated){
                if(rel.Is_Active__c && accAff.End_Date__c == null ){
                    accAff.IsActive__c = true;
                }
                else{
                    accAff.IsActive__c = false;
                    accAff.End_Date__c = Date.today();
                    accAff.Reason_For_leaving__c = 'Voluntary';
                }
                accAfftUpdated.add(accAff);
            }
        }
        update accAfftUpdated;
    }
    
    public static void insertAccountAffiliations(List<Relationship__c> newRelationships){
        
        System.debug('insertAccountAffiliations');
		Map<Id, List<Id>> houseHoldIdToSpouseIds = new Map<Id, List<Id>>();
        for(Relationship__c spouseRel: newRelationships){
            if(!houseHoldIdToSpouseIds.containsKey(spouseRel.account__c))
                houseHoldIdToSpouseIds.put(spouseRel.account__c, new List<Id>());
            houseHoldIdToSpouseIds.get(spouseRel.account__c).add(spouseRel.contact__c);
			System.debug('Spouse Account: ' + spouseRel.account__c + ' Spouse Contact: ' + spouseRel.Contact__c);
        }
        Map<Id, Id> memberIdToHouseHoldId = new Map<Id, Id>();
        Id memberRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Member', 'Contact').Id;
        Id prospectRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Prospect', 'Contact').Id;
        for(Relationship__c memberRel : [ Select id, contact__c, account__c from Relationship__c 
                                         where Account__c IN :houseHoldIdToSpouseIds.keySet()
                                         and ( Contact__r.RecordTypeId = :memberRecordTypeId OR Contact__r.RecordTypeId =:prospectRecordTypeId )]){
            memberIdToHouseHoldId.put(memberRel.contact__c, memberRel.account__c);
			System.debug('Member Account: ' + memberRel.account__c + ' Member Contact: ' + memberRel.Contact__c);
        }
        List<Account_Affiliation__c> clonedSpouseAffsToBeInserted = new List<Account_Affiliation__c>();
        //ND 14/11/16 Only sync the Chapter account affiliations. 
        List<Account_Affiliation__c> spouseAffsToBeCloned = [Select id, contact__c, account__c, account__r.RecordType.DeveloperName , Start_Date__c, End_Date__c, 
        													is_Primary__c, isActive__c, transfer_flag__c, chapter_approval_Status__c, Reason_For_leaving__c, Reason_Leaving_Other__c
        													from Account_Affiliation__c where 
                                                             contact__c IN :memberIdToHouseHoldId.keySet() and recordTypeId =:chapterAccAffRTId];
        for(Account_Affiliation__c toBeClonedMemberAff : spouseAffsToBeCloned){
            Id parentAccRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(toBeClonedMemberAff.account__r.RecordType.DeveloperName, 'Account_Affiliation__c').Id;
            
            for(Id spouseId: houseHoldIdToSpouseIds.get(memberIdToHouseHoldId.get(toBeClonedMemberAff.contact__c)))
            {
                Account_Affiliation__c clonedSpouseAff = toBeClonedMemberAff.clone(false, false);
                clonedSpouseAff.contact__c = spouseId;
                clonedSpouseAff.RecordTypeId = parentAccRecordTypeId;
                clonedSpouseAff.contact_type__c = CONST_SPOUSE;
                clonedSpouseAffsToBeInserted.add(clonedSpouseAff);
            }
        }
        insert clonedSpouseAffsToBeInserted;
    }

	//*************************
	// Feed in the filtered list of Relationship Spouse records that have been changed to Ex-Spouse/Partner
	// and deactivate the prescribed records to complete the backing out of the Ex-Spouse/Partner from 
	// the system.
	//
	// This is a before trigger type, so the field assignment of any relationship records do not require any updates
	//*************************
	public static Boolean deactivateExSpouse(List<Relationship__c> oFilteredExSpouses) {
		//Return variable
		Boolean varCheckedOut = false;

		//Definition of update lists
		List<Contact> lstContactsToUpdate = new List<Contact>();
		List<Account_Affiliation__c> lstAAsToUpdate = new List<Account_Affiliation__c>();
		List<Contact_Position__c> lstCPsToUpdate = new List<Contact_Position__c>();

		//Build maps of records to be updated
		set<Id> setFilteredExSpouses = Pluck.ids('Contact__c',oFilteredExSpouses);
		System.debug('setFilteredExSpouses: ' + setFilteredExSpouses.size());
		Map<Id,List<Contact>> mapContacts = GroupBy.ids('id',[Select Id, Active__c, Record_Type_Name__c, RecordTypeId 
															From Contact 
															Where id IN :setFilteredExSpouses]);

		Map<Id, List<Account_Affiliation__c>> mapAccountAffiliations = GroupBy.ids('Contact__c',[Select Id, Name, RecordTypeId, Contact__c, Account__c, End_Date__c, IsActive__c, Is_Primary__c, Start_Date__c, Type__c 
																							From Account_Affiliation__c 
																							Where Type__c IN ('Chapter','Network','Committee') and Contact__c IN :setFilteredExSpouses]);

		Map<Id, List<Contact_Position__c>> mapContactPositions = GroupBy.ids('Contact__c',[SELECT Id, Position__c, Contact__c, End_Date__c, Start_Date__c, Status__c, Position_Category__c, Position_Title__c, Account__c, Reason_for_Leaving__c 
																						FROM Contact_Position__c 
																						WHERE Status__c != 'Past' AND Contact__c IN :setFilteredExSpouses]);

		System.debug('Looping through the Relationships to complete the updates');
		//loop through the filtered list of spouses/partners
		for (Relationship__c oSpouseHousehold : oFilteredExSpouses) {
			//Deactivate the Relationship records sent in.
			oSpouseHousehold.Is_Active__c = false;
	
			//Capture the Contact records of the Spouse/Partner to deactivate.
			if(mapContacts.get(oSpouseHousehold.Contact__c) != null) {
				for(Contact oSpouseContact : mapContacts.get(oSpouseHousehold.Contact__c)) {
					oSpouseContact.Active__c = false;
					oSpouseContact.Type__c = CONST_SPOUSE;
					lstContactsToUpdate.add(oSpouseContact);
				}
			}

			//Capture the AA records of the Spouse/Partners to deactivate.
			if(mapAccountAffiliations.get(oSpouseHousehold.Contact__c) != null) {
				For (Account_Affiliation__c oAAofContact : mapAccountAffiliations.get(oSpouseHousehold.Contact__c)) {
					oAAofContact.IsActive__c = false;
					oAAofContact.End_Date__c = Date.today();
					oAAofContact.Reason_for_Leaving__c = 'Resigned';
					lstAAsToUpdate.add(oAAofContact);
				}
			}

			//Capture the ContactPosition records of the Spouse/Partners to deactivate.
			if(mapContactPositions.get(oSpouseHousehold.Contact__c) != null) {
				for (Contact_Position__c oCPofContact : mapContactPositions.get(oSpouseHousehold.Contact__c)) {
					oCPofContact.Status__c = 'Past';
					oCPofContact.End_Date__c = Date.today();
					lstCPsToUpdate.add(oCPofContact);
				}
			}
		}

		//Attempt to update all retrieved lists for deactivation.
		try {
			update lstContactsToUpdate;

			update lstAAsToUpdate;

			update lstCPsToUpdate;

			varCheckedOut = true;
		} catch (DmlException excpt) {
			List<String> errors = new List<String>();
			for(Integer i=0;i<excpt.getNumDml();i++) {
				errors.add('RelationshipServices: '+ excpt.getDmlType(i) +
							'<br/> Recordid: '+ excpt.getDmlid(i) +'<br/> <span style="color:red;"><b>Fields: '+excpt.getDmlFields(i)+' -- Error Message: '+ excpt.getDmlMessage(i)+'</b></span>');
			}

			if(errors.size()>0) {
				String sMessage= 'ERROR: An exception has occurred. Please contact your System Administrator quoting the following message <br/> '
					+ String.join(errors, '<br/>'); 
				
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage() ;
				String[] toAddresses = Chapter_Health_Batch_Error_Email_Setting__c.getInstance().Error_Email_Recipients__c.split(';');
				//mail.setTreatTargetObjectAsRecipient(false);
				mail.setToAddresses(toAddresses) ;
				mail.setSubject('Exception occurred while updating Ex-Spouses/Partners on Relationship records.');
				
				String body = '<html><body>'+
					'<br><br>'+
					'This email alert is to bring to your notice that exception occured while updating Ex-Spouses/Partners on Relationship records.'+
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

		return varCheckedOut;
	}
}