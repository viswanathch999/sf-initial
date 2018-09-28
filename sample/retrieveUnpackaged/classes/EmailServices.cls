global class EmailServices  {
	
	/**
	* @description Used by the button on leads to send for chapter approval (item 7127)
	* @param leadId - related lead ID for merge fields and TO/CC fields
	* @return List of strings of any error messages
	*/ 
	@TestVisible
	webservice static List<String> sendLeadForChapterApproval(String leadId) { 
		String TEMPLATE_NAME = 'Send Lead for Chapter Approval';
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		EmailTemplate template = new EmailTemplate();
		Lead currentLead = new Lead();
		List<String> toAddr = new List<String>();
		List<String> ccAddr = new List<String>();
		List<String> errorMessages = new List<String>();

		// Email template
		try { 
			template = [SELECT Id FROM EmailTemplate WHERE Name LIKE :TEMPLATE_NAME LIMIT 1];
		}
		catch (Exception ex) { 
			errorMessages.add('Could not find email template: ' + ex.getMessage());
		}

		// Lead
		try { 
			currentLead = [SELECT Id, Name, Chpter_Chair__r.Email, Chapter_Membership_Officer__r.Email, Chapter_Administrator__r.Email FROM Lead WHERE Id = :leadId];
		}
		catch (Exception ex) { 
			errorMessages.add('Lead not found: ' + ex.getMessage());
		}
		
		// TO: chapter chair
		if (currentLead.Chpter_Chair__r.Email != null)
			toAddr.add(currentLead.Chpter_Chair__r.Email);
		
		// TO: CMO
		if (currentLead.Chapter_Membership_Officer__r.Email != null) 
			toAddr.add(currentLead.Chapter_Membership_Officer__r.Email);
		
		// CC: chapter admin
		if (currentLead.Chapter_Administrator__r.Email != null) 
			ccAddr.add(currentLead.Chapter_Administrator__r.Email);

		// Set up message
		mail.setTemplateId(template.Id);
		mail.setTargetObjectId(leadId);
		mail.setTreatTargetObjectAsRecipient(false);
		mail.setSaveAsActivity(false);
		mail.setToAddresses(toAddr);
		mail.setCcAddresses(ccAddr);

		// Send message if no previous errors
		if (errorMessages.size() == 0) {
			try { 
				currentLead.CMO_Approval__c = null;
				currentLead.CC_Approval__c = null;
				currentLead.Chapter_Approval_Requested_Date__c = Date.today();
				update currentLead;
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			}
			catch (EmailException ex) {
				errorMessages.add('Error sending email: ' + ex.getDmlMessage(0));
			}
		}
		return errorMessages;
	}


	/**
	* @description Method to send batch error emails.  Uses Chapter_Health_Batch_Error_Email_Setting__c for list of recipients.
	* @param jobId 
	* @param BATCH_JOB_Name 
	* @param errorMessage 
	*/ 
	/* not yet implemented
	public static void sendBatchEmailNotification(Id jobId, String BATCH_JOB_Name, String errorMessage){
        
        if(Chapter_Health_Batch_Error_Email_Setting__c.getInstance().Error_Email_Recipients__c != null){
            String[] toAddress = Chapter_Health_Batch_Error_Email_Setting__c.getInstance().Error_Email_Recipients__c.split(';');
			//String[] toAddress = new String[] { 'mfrizzell@ypo.org' };
            AsyncApexJob job = [ SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
                                TotalJobItems, CreatedBy.Email, LastProcessedOffset
                                FROM AsyncApexJob 
                                WHERE Id =:jobId];
            //get accumulative statistics for the last subJob
            List<AsyncApexJob> subJobs = [ SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
                                          TotalJobItems, CreatedBy.Email, LastProcessedOffset
                                          FROM AsyncApexJob 
                                          WHERE ParentJobId =:job.Id 
                                          ORDER BY CompletedDate desc, LastProcessedOffset desc LIMIT 1];
            
            String emailBody = BATCH_JOB_Name + ' - ' + job.JobItemsProcessed + ' out of a total ' + job.TotalJobItems + ' were processed. \n\n';
            
            String emailSubject = 'Success: ';
            
            if(job.JobItemsProcessed != job.TotalJobItems) {
                emailBody += Label.UpdateChapterHealthDailyBatchProcessedJobsFailMessage;
                emailSubject = 'Failure: ';
            }
            if(errorMessage != null && errorMessage != ''){
                emailBody += errorMessage;
                emailSubject = 'Failure: ';
            }
            emailSubject += BATCH_JOB_Name + ' ' + System.Today().year() + '/' + System.Today().month() + '/' + System.Today().day();
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddress);        
            mail.setSaveAsActivity(false);
            mail.setSubject(emailSubject);     
            mail.setPlainTextBody(emailBody);
            If(!Test.isRunningTest())Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        }                
    }
	*/


	/**
	* @description - Sends an error email based on configuration in Error_Email_Setting__c custom setting
	* @param emailSetting Data set name in Error_Email_Setting__c custom setting
	* @param relatedId Id of related object for merge fields, if applicable
	* @param body Plain text or HTML to use for email body if no template specified
	* @return List of strings containing any errors that occurred
	*/ 
	public static List<String> sendErrorEmail(String emailSetting, Id relatedId, String body) {
		List<String> errorMessages = new List<String>();
		Error_Email_Settings__c settings = Error_Email_Settings__c.getValues(emailSetting);

		if (settings.Active__c == true) {
			
			// Get settings
			List<String> toAddr = settings.To__c == null ? null : settings.To__c.split(';');
			List<String> ccAddr = settings.CC__c == null ? null : settings.CC__c.split(';');
			List<String> bccAddr = settings.BCC__c == null ? null : settings.BCC__c.split(';');
			String templateName = settings.Template__c;
			Id templateId = null;
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

			
			
			// Construct email
			mail.setToAddresses(toAddr);
			mail.setCcAddresses(ccAddr);
			mail.setBccAddresses(bccAddr);
			if (body != null && body != '') { 
				// No template - use body string
				mail.setHtmlBody(body);
			}
			else { 
				// Use template
				try {
					templateId = [SELECT Id FROM EmailTemplate WHERE Name =:templateName LIMIT 1].Id;
					mail.setTemplateId(templateId);
					mail.setTargetObjectId(relatedId);
					mail.setTreatTargetObjectAsRecipient(false); // do not send to relatedId owner
				}
				catch (Exception ex) { 
					errorMessages.add('Could not find email template: ' + ex.getMessage());
				}
			}
			mail.setSaveAsActivity(false);
			
			// Send email
			if (errorMessages.size() == 0) {
				try { 
					Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
				}
				catch (EmailException ex) {
					errorMessages.add('Error sending email: ' + ex.getDmlMessage(0));
				}
			}
		}
		return errorMessages;
	}
	
}