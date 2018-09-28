/**
 * ChapterUserAccessBatchScheduler is scheduler which will run daily to provide access to Chapter admin users
 * This is to provide extra access to Chapter Admin records.  
 *
 * @author Shri K
 */
global class ChapterAdditionalUserAccessBatch implements Database.Batchable<CA_Setting__c>{
   
    global List<CA_Setting__c> start(Database.BatchableContext BC)
	{
     	return [SELECT Chapter__c, User__c FROM CA_Setting__c WHERE isActive__c = true AND Role__c != 'Chapter Chair'];
   	}
    
   	global void execute(Database.BatchableContext BC, List<CA_Setting__c> lstCASetting)
   	{
    	List<User> lstUser = new List<User>();
    	List<Id> lstAccountId = new List<Id>();
    	for(CA_Setting__c oCASetting: lstCASetting)
    	{
    		lstUser.add(new User(Id = oCASetting.User__c));	
    		lstAccountId.add(oCASetting.Chapter__c);
    	}
    	UserServices.shareContact(lstUser, lstAccountId);
	}

   	global void finish(Database.BatchableContext BC)
   	{
   	
   	}
}