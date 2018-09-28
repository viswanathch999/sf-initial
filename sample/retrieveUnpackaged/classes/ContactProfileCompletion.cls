public class ContactProfileCompletion {

	Map<Id, Contact> newCollection = new Map<Id, Contact> ();
	Map<Id, Contact> oldCollection = new Map<Id, Contact> ();
	Boolean isInsert;
	Map<Id, Contact> contactToggle = new Map<Id, Contact>();
	Map<Id, String> jsonMap = new Map<Id, String> ();

	public void handle(Map<Id, Contact> newCollection, Map<Id, Contact> oldCollection, Boolean isInsert) {
		this.newCollection = newCollection;
		this.isInsert = isInsert;

		if (!isInsert) {
			this.oldCollection = oldCollection;
		}

		sortUpdates();

		System.debug('JSON Map: ' + jsonMap);
		if(jsonMap.size() > 0 && !jsonMap.isEmpty()){
			ProfileCompletionUtility.ProfileCompletionUtility(jsonMap);		
		}
	}

	private void sortUpdates(){
		for(Contact c : newCollection.values()){
			if(c.Biography_enntered__c){
				contactToggle.put(c.Id, c);
			}
		}
		profileCompleteCheck();

		if(contactToggle.size() > 0){
			toggleCheck();
		}	
	}

	private void profileCompleteCheck() {
		Boolean vaildUpdate = false;
		Profile_Completion_Criteria__c updateCompletion;

		if (isInsert) {
			for (Id i : newCollection.keySet()) {
				updateCompletion = new Profile_Completion_Criteria__c();
				if ((newCollection.get(i).MailingStreet != null && newCollection.get(i).Is_Address1_Primary__c == true) || ((newCollection.get(i).OtherStreet != null && newCollection.get(i).Is_Address2_Primary__c == true))) {
					updateCompletion.Primary_Address__c = 1;
				} else {
					updateCompletion.Primary_Address__c = 0;
				}

				if (newCollection.get(i).Phone != null) {
					updateCompletion.Business_Phone__c = 1;
				}

				if (newCollection.get(i).MobilePhone != null) {
					updateCompletion.Mobile_Phone__c = 1;
				} else {
					updateCompletion.Mobile_Phone__c = 0;
				}

				if (newCollection.get(i).Email != null) {
					updateCompletion.Primary_Email__c = 1;
				} else {
					updateCompletion.Primary_Email__c = 0;
				}
				if (newCollection.get(i).Biography__c != null) {
					updateCompletion.Biography__c = 1;
				} else {
					updateCompletion.Biography__c = 0;
				}

				if (newCollection.get(i).Profile_Picture_uploaded__c == true) {
					updateCompletion.Profile_Picture_Upload__c = 1;
				} else {
					updateCompletion.Profile_Picture_Upload__c = 0;
				}

				if ((newCollection.get(i).Skype__c != null) || (newCollection.get(i).LinkedIn__c != null) || (newCollection.get(i).Twitter__c != null) || (newCollection.get(i).WhatsApp__c != null)
				    || (newCollection.get(i).WeChat__c != null) || (newCollection.get(i).Instagram__c != null) || (newCollection.get(i).YouTube__c != null) || (newCollection.get(i).Facebook_Messenger__c != null)
				    || (newCollection.get(i).QQ__c != null) || (newCollection.get(i).VK__c != null) || (newCollection.get(i).Zoom__c != null)) {
					updateCompletion.Social_Media__c = 1;
				} else {
					updateCompletion.Social_Media__c = 0;
				}

				jsonMap.put(i, JSON.serialize(updateCompletion));
			}
		} else {
			for (Id i : newCollection.keySet()) {
				updateCompletion = new Profile_Completion_Criteria__c();
				if ((newCollection.get(i).MailingStreet != null && oldCollection.get(i).MailingStreet == NULL && newCollection.get(i).Is_Address1_Primary__c == true) ||
				(newCollection.get(i).OtherStreet != null && oldCollection.get(i).OtherStreet == NULL && newCollection.get(i).Is_Address2_Primary__c == true)) {
					vaildUpdate = true;
					updateCompletion.Primary_Address__c = 1;
				} else if ((oldCollection.get(i).MailingStreet != null && newCollection.get(i).MailingStreet == NULL && newCollection.get(i).Is_Address1_Primary__c == false) ||
				(oldCollection.get(i).OtherStreet != null && newCollection.get(i).OtherStreet == NULL && newCollection.get(i).Is_Address2_Primary__c == false)) {
					vaildUpdate = true;
					updateCompletion.Primary_Address__c = 0;
				}
				if (newCollection.get(i).Phone != null && oldCollection.get(i).Phone == null) {
					vaildUpdate = true;
					updateCompletion.Business_Phone__c = 1;
				} else if (oldCollection.get(i).Phone != null && newCollection.get(i).Phone == null) {
					vaildUpdate = true;
					updateCompletion.Business_Phone__c = 0;
				}

				if (newCollection.get(i).MobilePhone != null && oldCollection.get(i).MobilePhone == null) {
					vaildUpdate = true;
					updateCompletion.Mobile_Phone__c = 1;
				} else if (oldCollection.get(i).MobilePhone != null && newCollection.get(i).MobilePhone == null) {
					vaildUpdate = true;
					updateCompletion.Mobile_Phone__c = 0;
				}

				if (newCollection.get(i).Email != null && oldCollection.get(i).Email == null) {
					vaildUpdate = true;
					updateCompletion.Primary_Email__c = 1;
				} else if (oldCollection.get(i).Email != null && newCollection.get(i).Email == null) {
					vaildUpdate = true;
					updateCompletion.Primary_Email__c = 0;
				}

				if (newCollection.get(i).Biography__c != null && oldCollection.get(i).Biography__c == null) {
					vaildUpdate = true;
					updateCompletion.Biography__c = 1;
				} else if (oldCollection.get(i).Biography__c != null && newCollection.get(i).Biography__c == null) {
					vaildUpdate = true;
					updateCompletion.Biography__c = 0;
				}

				if (newCollection.get(i).Profile_Picture_Uploaded__c == true && oldCollection.get(i).Profile_Picture_Uploaded__c == false) {
					vaildUpdate = true;
					updateCompletion.Profile_Picture_Upload__c = 1;
				} else if (oldCollection.get(i).Profile_Picture_Uploaded__c == false && newCollection.get(i).Profile_Picture_Uploaded__c == false) {
					vaildUpdate = true;
					updateCompletion.Profile_Picture_Upload__c = 0;
				}

				if ((newCollection.get(i).Skype__c != null && oldCollection.get(i).Skype__c == null) ||
				(newCollection.get(i).LinkedIn__c != null && oldCollection.get(i).LinkedIn__c == null) ||
				(newCollection.get(i).Twitter__c != null && oldCollection.get(i).Twitter__c == null) ||
				(newCollection.get(i).WhatsApp__c != null && oldCollection.get(i).WhatsApp__c == null) ||
				(newCollection.get(i).WeChat__c != null && oldCollection.get(i).WeChat__c == null) ||
				(newCollection.get(i).Instagram__c != null && oldCollection.get(i).Instagram__c == null) ||
				(newCollection.get(i).YouTube__c != null && oldCollection.get(i).YouTube__c == null) ||
				(newCollection.get(i).Facebook_Messenger__c != null && oldCollection.get(i).Facebook_Messenger__c == null) ||
				(newCollection.get(i).QQ__c != null && oldCollection.get(i).QQ__c == null) ||
				(newCollection.get(i).VK__c != null && oldCollection.get(i).VK__c == null) ||
				(newCollection.get(i).Zoom__c != null && oldCollection.get(i).Zoom__c == null)) {
					vaildUpdate = true;
					updateCompletion.Social_Media__c = 1;
				} else if ((oldCollection.get(i).Skype__c != null && newCollection.get(i).Skype__c == null) ||
				(oldCollection.get(i).LinkedIn__c != null && newCollection.get(i).LinkedIn__c == null) ||
				(oldCollection.get(i).Twitter__c != null && newCollection.get(i).Twitter__c == null) ||
				(oldCollection.get(i).WhatsApp__c != null && newCollection.get(i).WhatsApp__c == null) ||
				(oldCollection.get(i).WeChat__c != null && newCollection.get(i).WeChat__c == null) ||
				(oldCollection.get(i).Instagram__c != null && newCollection.get(i).Instagram__c == null) ||
				(oldCollection.get(i).YouTube__c != null && newCollection.get(i).YouTube__c == null) ||
				(oldCollection.get(i).Facebook_Messenger__c != null && newCollection.get(i).Facebook_Messenger__c == null) ||
				(oldCollection.get(i).QQ__c != null && newCollection.get(i).QQ__c == null) ||
				(oldCollection.get(i).VK__c != null && newCollection.get(i).VK__c == null) ||
				(oldCollection.get(i).Zoom__c != null && newCollection.get(i).Zoom__c == null)) {
					vaildUpdate = true;
					updateCompletion.Social_Media__c = 0;
				}
				if (vaildUpdate) {
					jsonMap.put(i, JSON.serialize(updateCompletion));
				}
			}
		}
	}

	private void toggleCheck() {
		Profile_Completion_Criteria__c updateCompletion;
		for (Id i : contactToggle.keySet()) {
			updateCompletion = new Profile_Completion_Criteria__c();
			if ((newCollection.get(i).MailingStreet != null && newCollection.get(i).Is_Address1_Primary__c == true) || ((newCollection.get(i).OtherStreet != null && newCollection.get(i).Is_Address2_Primary__c == true))) {
				updateCompletion.Primary_Address__c = 1;
			} else {
				updateCompletion.Primary_Address__c = 0;
			}

			if (newCollection.get(i).Phone != null) {
				updateCompletion.Business_Phone__c = 1;
			}

			if (newCollection.get(i).MobilePhone != null) {
				updateCompletion.Mobile_Phone__c = 1;
			} else {
				updateCompletion.Mobile_Phone__c = 0;
			}

			if (newCollection.get(i).Email != null) {
				updateCompletion.Primary_Email__c = 1;
			} else {
				updateCompletion.Primary_Email__c = 0;
			}
			if (newCollection.get(i).Biography__c != null) {
				updateCompletion.Biography__c = 1;
			} else {
				updateCompletion.Biography__c = 0;
			}

			if (newCollection.get(i).Profile_Picture_uploaded__c == true) {
				updateCompletion.Profile_Picture_Upload__c = 1;
			} else {
				updateCompletion.Profile_Picture_Upload__c = 0;
			}

			if ((newCollection.get(i).Skype__c != null) || (newCollection.get(i).LinkedIn__c != null) || (newCollection.get(i).Twitter__c != null) || (newCollection.get(i).WhatsApp__c != null)
			    || (newCollection.get(i).WeChat__c != null) || (newCollection.get(i).Instagram__c != null) || (newCollection.get(i).YouTube__c != null) || (newCollection.get(i).Facebook_Messenger__c != null)
			    || (newCollection.get(i).QQ__c != null) || (newCollection.get(i).VK__c != null) || (newCollection.get(i).Zoom__c != null)) {
				updateCompletion.Social_Media__c = 1;
			} else {
				updateCompletion.Social_Media__c = 0;
			}

			jsonMap.put(i, JSON.serialize(updateCompletion));
		}
	}
}