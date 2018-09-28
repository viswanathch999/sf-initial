global class ChapterHealthDailyBatch implements Database.Stateful, Database.Batchable<sObject> {
    static FINAL String CHAPTER_HEALTH_RT = 'Current';
    String query;    
    private final String BATCH_JOB_Name = 'UpdChapterHealthDailyBatch';    
    global List<String> chbToErrorMessage = new List<String>();
    public Chapter_Health_Batch__c chbToBeCalculated;

	public ChapterHealthDailyBatch(Chapter_Health_Batch__c chb) {
        chbToBeCalculated = chb;
        query = 'SELECT Id, Name, CBMS__c, ' +
					'(SELECT Id ' +
					' FROM Chapter_Health__r ' +
					' WHERE Report_Quarter__c = \'' + FiscalDateUtility.currentFiscalQuarter + '\'' +
					' AND RecordType.DeveloperName = \'' + CHAPTER_HEALTH_RT + '\'' +
					' AND Report_Year__c = ' + FiscalDateUtility.currentFiscalYear + ') ' + 
				'FROM Account ' +
				'WHERE RecordType.DeveloperName = \'Chapter\'' +
				'AND Status__c = \'Active\'';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {      
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        System.debug('Chapter batch: ' + chbToBeCalculated.Name);
		System.debug('Scope: ' + scope.size() + ' accounts');
        chbToErrorMessage.addAll(UpdChapterHealthDailyBatchServices.calculateAndUpdateChapterHealth(scope, chbToBeCalculated));
    }
    
    global void finish(Database.BatchableContext BC) {
        String errorMessage = '';
        if (!chbToErrorMessage.isEmpty()) {
            errorMessage = String.join(chbToErrorMessage, ' \n ');
			UpdChapterHealthDailyBatchServices.sendBatchEmailNotification(bc.getJobId(), BATCH_JOB_Name,
                                                                       Label.Batch_Error_Message+'\n Chapter Health Batch record: '+
                                                                       chbToBeCalculated.Name+'\n Error: '+errorMessage);
        }
        chbToBeCalculated.Processed__c = System.today();
        chbToBeCalculated.Error_Message__c  = errorMessage;
        update chbToBeCalculated;

		ChapterHealthBatchHelper helper = new ChapterHealthBatchHelper();
        helper.execute(null);
    }

}