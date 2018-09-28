@isTest
private class ErrorLogUtilTest {
	static final Integer LO_COUNT = 1;
	static final Integer HI_COUNT = 10;
	static Boolean insertCustomSetting = true;
	
	static final List<String> ERROR_EMAIL_RECIPIENTS = new List<String>{'test@tester.com', 'test2@tester.com'}; // ask about this in unit test line 107
	static final String EMAIL_RECIPIENT_RAW = 'test@tester.com;test2@tester.com';
	
	static final String EMAIL_BODY = 'This is the correct email error body text.';
	
	static final String ERROR_TYPE = 'Chapter Health Batch';
	static final String ERROR_STRING = 'Test Method Error String';
	static final String ERROR_RECORD_ID = 'Test Method Error Record Id';
	static final String LONG_TEXT_AREA_TO_FORCE_ERROR = 'BlVsujrXDmoEbcQ46D5al0yrpExDJCsHHTChzBE0TCKNXovsLaTyW0FPb80uYUEjWhKp1sSgiBSmgwn2Bhv9XL5lSw9JbVjGSH4khn' +
														'6MffnLfQE30u8BE59a5QuhgL86IYvikmgCIGtxhEn0GrqBn2x5YpPCfQBqXGhsqQR7fD88WJ1IeW9tTmTi8z98Nhz5FCpmaqoUSeuV' +
														'qpqILuce056ViJP7zmq7sNoVIazVi3l2cGxyYaPnr1zLTVCXhfWFGHRD';
	
	public static void setupEmailSettings(Boolean insertCustomSetting){
		UnitTest.addData((List<Chapter_Health_Batch_Error_Email_Setting__c>) SObjectFactory.build(LO_COUNT, Chapter_Health_Batch_Error_Email_Setting__c.SObjectType))
				.tag('Chapter Health Batch Error Email Setting')
				.property('SetupOwnerId').assign(UserInfo.getOrganizationId())
				.property('Error_Email_Recipients__c').assign(EMAIL_RECIPIENT_RAW);
		System.debug('@#@# email recip' + UnitTest.get('Chapter Health Batch Error Email Setting'));
		if(insertCustomSetting){
			UnitTest.get('Chapter Health Batch Error Email Setting').insertAll();
		}
	}

	static void addData() {
		Account testAccount = new Account(
            Name = 'testAccount',
            CurrencyIsoCode = 'USD',
            BillingPostalCode = '91320',
            Industry = 'Banking'
        );
        insert testAccount;
        
        Contact testContact = new Contact(
            LastName = 'contact',
            AccountId = testAccount.Id,
            Email = 'test@email.com'
        );
        insert testContact;
        
         Opportunity opp = new Opportunity(
            Name = 'testOpty',
            AccountId = testAccount.Id,
            StageName = 'Prospect',
            Type = 'Renewal',
            CloseDate = System.today(),
            ForecastCategoryName = 'Pipeline',
            LeadSource = 'Adwords',
            KGRenewal__Contact__c = testContact.Id
        );
        insert opp;
	}


    static testMethod void chapterHealthErrorEmailSettingTest_Fail() {
    	insertCustomSetting = false;
        setupEmailSettings(insertCustomSetting);
        
        Test.startTest();
        	List<String> actualCustomSetting = ErrorLogUtil.chapterHealthErrorEmailSetting; 
        Test.stopTest();

        System.assert(actualCustomSetting.isEmpty(), 'The custom setting should be null');
        
        List<Error_Log__c> actualErrorRecord = [SELECT Id, Error_String__c, Error_Type__c, Record_Id__c FROM Error_Log__c];

        System.assert(!actualErrorRecord.isEmpty(), 'An error record should have been created');
        System.assertEquals(1, actualErrorRecord.size(), 'There should only have been 1 error created');
        System.assertEquals(ErrorLogUtil.CUSTOM_SETTING_ERROR_STRING, actualErrorRecord[0].Error_String__c, 'The error string field should be properly set');
        System.assertEquals(ErrorLogUtil.CUSTOM_SETTING_ERROR_TYPE, actualErrorRecord[0].Error_Type__c, 'The error type field should be properly set');
        System.assertEquals(ErrorLogUtil.CUSTOM_SETTING_ERROR_RECORD_ID, actualErrorRecord[0].Record_Id__c, 'The error record field should be properly set to blank');
        
    }

    static testMethod void createErrorLogTest(){
    	Test.startTest();
    		Error_Log__c actualErrorLog = ErrorLogUtil.createErrorLog(ERROR_TYPE, ERROR_RECORD_ID, ERROR_STRING);
    	Test.stopTest();

    	System.assertEquals(ERROR_TYPE, actualErrorLog.Error_Type__c, 'The error type should be correct');
    	System.assertEquals(ERROR_RECORD_ID, actualErrorLog.Record_Id__c, 'The error string should be correct');
    	System.assertEquals(ERROR_STRING, actualErrorLog.Error_String__c, 'The error record id should be correct');
    }
    
	static testMethod void insertErrorLogsTest_Fail(){
    	setupEmailSettings(insertCustomSetting);
    	addData(); 
		Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;

    	Test.startTest();
    		Integer emailInvocationsBefore = Limits.getEmailInvocations();
    			List<Error_Log__c> errors = new List<Error_Log__c>();
				errors.add(ErrorLogUtil.createErrorLog(ERROR_TYPE, LONG_TEXT_AREA_TO_FORCE_ERROR, LONG_TEXT_AREA_TO_FORCE_ERROR));
				errors.add(new Error_Log__c (
					Error_String__c = ERROR_STRING, 
					Error_Type__c = ERROR_TYPE, 
					Record_Id__c = ERROR_RECORD_ID, 
					Opportunity__c = oppId
				));
    			ErrorLogUtil.insertErrorLogs(errors);
    		Integer emailInvocationsAfter = Limits.getEmailInvocations();
    	Test.stopTest();
    	
    	List<Error_Log__c> actualErrorRecord = [SELECT Id, Error_String__c, Error_Type__c, Record_Id__c FROM Error_Log__c];
    	
    	//System.assert(actualErrorRecord.isEmpty(), 'No error logs should have been inserted.');
    	//System.assertEquals(emailInvocationsBefore + 1, emailInvocationsAfter, 'An email should have been sent' );
    		
    }

    static testMethod void buildAndInsertErrorLogsTest_Success(){
    	setupEmailSettings(insertCustomSetting);
    	
    	Test.startTest();
    		Integer emailInvocationsBefore = Limits.getEmailInvocations();
    			Error_Log__c actualErrorLog = ErrorLogUtil.createErrorLog(ERROR_TYPE, ERROR_RECORD_ID, ERROR_STRING);
    			ErrorLogUtil.insertErrorLogs(new List<Error_Log__c>{actualErrorLog});
    		Integer emailInvocationsAfter = Limits.getEmailInvocations();
    	Test.stopTest();
    	List<Error_Log__c> actualErrorRecords = [SELECT Id, Error_String__c, Error_Type__c, Record_Id__c FROM Error_Log__c];
    	System.debug('@#@# actualErrorLog: '+actualErrorLog);
    	System.debug('@#@# actualErrorRecords: '+actualErrorRecords);
    	
    	System.assert(!actualErrorRecords.isEmpty(), 'An error log should have been inserted');
    	System.assertEquals(1, actualErrorRecords.size(), '1 error log should have been inserted');
    	
    	for(Error_Log__c actual : actualErrorRecords){
    		System.assertEquals(ERROR_TYPE, actualErrorLog.Error_Type__c, 'The error type should be correct');
	    	System.assertEquals(ERROR_RECORD_ID, actualErrorLog.Record_Id__c, 'The error string should be correct');
	    	System.assertEquals(ERROR_STRING, actualErrorLog.Error_String__c, 'The error record id should be correct');
    	}

    	System.assertEquals(emailInvocationsBefore, emailInvocationsAfter, 'No emails should have been sent');	
    }
    static testMethod void buildAndInsertErrorLogsWithOppTest_Success(){
    	setupEmailSettings(insertCustomSetting);
    	addData();
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;

    	Test.startTest();
    		Integer emailInvocationsBefore = Limits.getEmailInvocations();
    			Error_Log__c actualErrorLog = ErrorLogUtil.createErrorLogWithOppLookup(ERROR_TYPE, ERROR_RECORD_ID, ERROR_STRING, oppId);
    			ErrorLogUtil.insertErrorLogs(new List<Error_Log__c>{actualErrorLog});
    		Integer emailInvocationsAfter = Limits.getEmailInvocations();
    	Test.stopTest();
    	List<Error_Log__c> actualErrorRecords = [SELECT Id, Error_String__c, Error_Type__c, Record_Id__c, Opportunity__c FROM Error_Log__c];
    	System.debug('@#@# actualErrorLog: '+actualErrorLog);
    	System.debug('@#@# actualErrorRecords: '+actualErrorRecords);
    	
    	System.assert(!actualErrorRecords.isEmpty(), 'An error log should have been inserted');
    	System.assertEquals(1, actualErrorRecords.size(), '1 error log should have been inserted');
    	
    	for(Error_Log__c actual : actualErrorRecords){
    		System.assertEquals(ERROR_TYPE, actualErrorLog.Error_Type__c, 'The error type should be correct');
	    	System.assertEquals(ERROR_RECORD_ID, actualErrorLog.Record_Id__c, 'The error string should be correct');
	    	System.assertEquals(ERROR_STRING, actualErrorLog.Error_String__c, 'The error record id should be correct');
	    	System.assertEquals(oppId, actualErrorLog.Opportunity__c, 'The error opportunity id should be correct');
    	}

    	System.assertEquals(emailInvocationsBefore, emailInvocationsAfter, 'No emails should have been sent');	
    }
    static testMethod void  buildErrorEmailTest(){
    	setupEmailSettings(insertCustomSetting);
    	
    	Test.startTest();
    		 Messaging.SingleEmailMessage actualEmailMessage = ErrorLogUtil.buildErrorEmail(EMAIL_BODY);
    	Test.stopTest();
    	
    	System.assert(actualEmailMessage != null, 'There should be an email message returned');
    	System.assertEquals(ErrorLogUtil.EMAIL_SUBJECT, actualEmailMessage.getSubject(), 'The subject should be correctly set');
    	System.assertEquals(EMAIL_BODY, actualEmailMessage.getPlainTextBody(), 'The body should be correctly set');
    	System.assertEquals(ERROR_EMAIL_RECIPIENTS, actualEmailMessage.getToAddresses(), 'The to addresses should be correctly set');
    }
    
}