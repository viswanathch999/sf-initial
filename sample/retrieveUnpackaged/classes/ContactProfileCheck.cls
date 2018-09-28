public class ContactProfileCheck implements MyTriggers.Handler {

	Map<Id, SObject> newCollection = new Map<Id, SObject> ();
	Map<Id, String> jsonMap = new Map<Id, String> ();

	public void handle() {
		profileCompleteCheck();

		if (jsonMap.size() > 0) {
			ProfileCompletionUtility.ProfileCompletionUtility(jsonMap);
		}
	}

	private void profileCompleteCheck() {
		Profile_Completion_Criteria__c updateCompletion;
		for (SObject s : Trigger.new) {
			updateCompletion = new Profile_Completion_Criteria__c();

			updateCompletion.Primary_Address__c = (checkAddress(s) ? 1 : 0);
			updateCompletion.Business_Phone__c = (s.get('Phone') != null ? 1 : 0);
			updateCompletion.Mobile_Phone__c = (s.get('MobilePhone') != null ? 1 : 0);
			updateCompletion.Primary_Email__c = (s.get('Email') != null ? 1 : 0);
			updateCompletion.Biography__c = (s.get('Biography__c') != null ? 1 : 0);
			updateCompletion.Profile_Picture_Upload__c = ((Boolean) s.get('Profile_Picture_uploaded__c') ? 1 : 0);
			updateCompletion.Social_Media__c = (checkSocialMedia(s) ? 1 : 0);
			jsonMap.put((Id) s.get('Id'), JSON.serialize(updateCompletion));
		}
	}

	private Boolean checkAddress(SObject cont) {
		return(((cont.get('MailingStreet') != NULL && cont.get('MailingCity') != NULL && cont.get('MailingCountry') != NULL
		        && (Boolean) cont.get('Is_Address1_Primary__c')) || (cont.get('OtherStreet') != NULL && cont.get('OtherCity') != NULL && cont.get('OtherCountry') != NULL
		        && (Boolean) cont.get('Is_Address2_Primary__c'))) ? true : false);
	}

	private Boolean checkSocialMedia(SObject cont) {
		return((cont.get('LinkedIn__c') != NULL || cont.get('Skype__c') != NULL || cont.get('Twitter__c') != NULL || cont.get('WhatsApp__c') != NULL || cont.get('Instagram__c') != NULL || cont.get('YouTube__c') != NULL ||
		        cont.get('Facebook_Messenger__c') != NULL || cont.get('WeChat__c') != NULL || cont.get('QQ__c') != NULL || cont.get('VK__c') != NULL || cont.get('Zoom__c') != NULL) || cont.get('Facebook__c') != NULL ? true : false);
	}
}