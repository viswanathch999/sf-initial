global class RegionalHealthDailyBatch implements Database.Stateful, Database.Batchable<sObject>{
    static FINAL String CURRENT_REGION_HEALTH_RT = 'Current';   
    global List<String> rhbToErrorMessage = new List<String>();
	private final String BATCH_JOB_Name = 'UpdRegionalHealthDailyBatch'; 
    public Chapter_Health_Batch__c rhbToBeCalculated;
	public String query;
    
    public RegionalHealthDailyBatch(Chapter_Health_Batch__c rhb) {
		rhbToBeCalculated = rhb;
        query = 'SELECT Id, Name, ' +
					'(SELECT Id ' +
					' FROM Region_Health__r ' +
					' WHERE Report_Quarter__c = \'' + FiscalDateUtility.currentFiscalQuarter + '\'' +
					' AND RecordType.DeveloperName = \'' + CURRENT_REGION_HEALTH_RT + '\'' +
					' AND Report_Year__c = ' + FiscalDateUtility.endOfCurrentFiscal.year() + ') ' + 
				'FROM Account ' +
				'WHERE Type = \'Region\'' +
				'AND Status__c = \'Active\'';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {      
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        System.debug('Region batch: ' + rhbToBeCalculated.Name);
		System.debug('Scope: ' + scope.size() + ' accounts');
		rhbToErrorMessage.addAll(UpdChapterHealthDailyBatchServices.calculateAndUpdateRegionalHealth(scope, rhbToBeCalculated));
    }
    
    global void finish(Database.BatchableContext BC) {
        String errorMessage = '';
        if (!rhbToErrorMessage.isEmpty()) {
            errorMessage = String.join(rhbToErrorMessage, ' \n ');
			UpdChapterHealthDailyBatchServices.sendBatchEmailNotification(bc.getJobId(), BATCH_JOB_Name,
                                                                          Label.Batch_Error_Message+'\n Region Health Batch record :'+
                                                                          rhbToBeCalculated.Name+'\n Error: '+errorMessage);
		}        
        rhbToBeCalculated.Processed__c = system.today();
        rhbToBeCalculated.Error_Message__c  = errorMessage;
        update rhbToBeCalculated;

        RegionHealthBatchHelper helper = new RegionHealthBatchHelper();
        helper.execute(null);
    }
}