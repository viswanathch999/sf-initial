public class ContactProfileCalculation {
  public static void profileCompleteCheck(Map<Id, Contact> newCollection){
    Map<Id, String> jsonMap = new Map<Id, String>();
  
    Profile_Completion_Criteria__c updateCompletion;
    for(Id i : newCollection.keySet()){
      updateCompletion = new Profile_Completion_Criteria__c();
        
      if(newCollection.get(i).MailingStreet != null && newCollection.get(i).Is_Address1_Primary__c == true){
        updateCompletion.Primary_Address__c = 1;
      }else{
        updateCompletion.Primary_Address__c = 0;
      }

      if(newCollection.get(i).Phone != null){
        updateCompletion.Business_Phone__c = 1;
      }else{
        updateCompletion.Business_Phone__c = 0;
      }

      if(newCollection.get(i).MobilePhone != null){
        updateCompletion.Mobile_Phone__c = 1;
      }else{
        updateCompletion.Mobile_Phone__c = 0;
      }

      if(newCollection.get(i).Email != null){
        updateCompletion.Primary_Email__c = 1;
      }else{
        updateCompletion.Primary_Email__c = 0;
      }

      if(newCollection.get(i).Biography__c != null){
        updateCompletion.Biography__c = 1;
      }else{
        updateCompletion.Biography__c = 0;
      }

      if(newCollection.get(i).Profile_Picture_uploaded__c == true){
        updateCompletion.Profile_Picture_Upload__c = 1;
      }else{
        updateCompletion.Profile_Picture_Upload__c = 0;
      }

      if((newCollection.get(i).Skype__c != null) || (newCollection.get(i).LinkedIn__c != null) || (newCollection.get(i).Twitter__c != null)  || (newCollection.get(i).WhatsApp__c != null)
        || (newCollection.get(i).WeChat__c != null) || (newCollection.get(i).Instagram__c != null) || (newCollection.get(i).YouTube__c != null) || (newCollection.get(i).Facebook_Messenger__c != null)
        || (newCollection.get(i).QQ__c != null) || (newCollection.get(i).VK__c != null) || (newCollection.get(i).Zoom__c != null)){
          updateCompletion.Social_Media__c = 1;
      }else{
        updateCompletion.Social_Media__c = 0;
      }
      jsonMap.put(i, JSON.serialize(updateCompletion));
    }

    if(!jsonMap.isEmpty()){
      ProfileCompletionUtility.ProfileCompletionUtility(jsonMap);
    }
  }
}