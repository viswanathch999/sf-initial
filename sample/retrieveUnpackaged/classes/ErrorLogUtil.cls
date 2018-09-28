public with sharing class ErrorLogUtil {
	
	@TestVisible final static String EMAIL_SUBJECT = 'Custom Error Insertion error';
	@TestVisible final static String CUSTOM_SETTING_ERROR_RECORD_ID = 'No Record Id Associated';
	@TestVisible final static String CUSTOM_SETTING_ERROR_TYPE = 'Chapter Health Batch';
	@TestVisible final static String CUSTOM_SETTING_ERROR_STRING = 'The Chapter_Health_Batch_Error_Email_Setting__c custom setting is not properly set up.';
    
    @TestVisible 
    static List<String> chapterHealthErrorEmailSetting{
    	get{
    		if(chapterHealthErrorEmailSetting == null){
				chapterHealthErrorEmailSetting = new List<String>();
    			Chapter_Health_Batch_Error_Email_Setting__c emailAddressOrgDefault = Chapter_Health_Batch_Error_Email_Setting__c.getOrgDefaults();
    			
    			if(emailAddressOrgDefault.Id != null){ 
	    			chapterHealthErrorEmailSetting.addAll(emailAddressOrgDefault.Error_Email_Recipients__c.split(';'));
    			}
    			else{
    				insertErrorLogs(new List<Error_Log__c>{createErrorLog(CUSTOM_SETTING_ERROR_TYPE, CUSTOM_SETTING_ERROR_RECORD_ID, CUSTOM_SETTING_ERROR_STRING)});
    			}
    		}
    		return chapterHealthErrorEmailSetting;
    	}
    	set;
    }
    

    public static void insertErrorLogs(List<Error_Log__c> errorLogsToInsert) {		
		try {
    		insert errorLogsToInsert;
    	} 
		catch (DmlException dex) {
			// If there was a DML error inserting the log, try moving the opp Id
			// to the record Id field and inserting again.  If that doesn't work, 
			// send error email instead.
			List<Error_Log__c> updates = new List<Error_Log__c>();
			for (Error_Log__c log : errorLogsToInsert) {
				if (log.Opportunity__c != null) {
					log.Record_Id__c = log.Opportunity__c;
					log.Opportunity__c = null;
					updates.add(log);
				}
			}
			try { 
				insert updates;
			}

			// If that didn't work, send error email
			catch (DmlException dex2) {
				String emailBody = 'The following exception(s) occured while inserting Error Log records: \n\n';
	    		for (Integer i = 0; i < dex2.getNumDml(); i++) {
	    			emailBody += 'DML Error ' + i + ': ' + dex2.getDmlMessage(i) + '. (' + dex2.getDmlType(i) + ') \n';
	    		}
    			List<Messaging.SingleEmailMessage> errorEmails = new List<Messaging.SingleEmailMessage> { buildErrorEmail(emailBody) };
    			sendEmails(errorEmails);
			}
		}
			
    }


    public static Error_Log__c createErrorLog(String errorType, String recordId, String errorString) {
    	Error_Log__c log = new Error_Log__c();
    	
    	log.Error_Type__c = errorType;
    	log.Record_Id__c = recordId;
    	log.Error_String__c = errorString;
    	
    	return log;
    }
    
    public static Error_Log__c createErrorLogWithOppLookup(String errorType, String recordId, String errorString, Id oppId) {
    	Error_Log__c log = new Error_Log__c();
    	
    	log.Error_Type__c = errorType;
    	log.Record_Id__c = recordId;
    	log.Error_String__c = errorString;
    	log.Opportunity__c = oppId;
    	
    	return log;
    }
    
    @TestVisible
    static Messaging.SingleEmailMessage buildErrorEmail(String emailBody){
    	Messaging.SingleEmailMessage errorEmail = new Messaging.SingleEmailMessage();
    	
    	errorEmail.setSubject(EMAIL_SUBJECT);
    	errorEmail.setPlainTextBody(emailBody);
    	errorEmail.setToAddresses(chapterHealthErrorEmailSetting);

    	return errorEmail;
    }
    @TestVisible
   	static void sendEmails(List<Messaging.SingleEmailMessage> errorEmails){
    	
    	List<Messaging.SendEmailResult> sendResult = Messaging.sendEmail(errorEmails, false);
    	String sendErrors = '';
    	
    	for(Messaging.SendEmailResult eachResult : sendResult){
    		if(!eachResult.isSuccess()){
    			for(Messaging.SendEmailError eachError : eachResult.getErrors()){
    				sendErrors += 'The status code is: ' + eachError.getStatusCode() + '. The error message is: ' + eachError.getMessage() + '. \n';
    			}
    			System.debug('!! There was a failure sending the email for a failed error log insertion in the ErrorLogUtil class.' + sendErrors);
    		}
    	}
    }
}