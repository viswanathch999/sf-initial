global class ChapterHealthQuarterlyBatch implements Database.Batchable<sObject>{
	
	public String batchType;
	public List<String> chbToErrorMessage;
	public String regHealthCurrentRtId = RecordTypeServices.getRecordTypeByDeveloperName('Current', 'Region_Health__c').Id;
	private String query;
	public String currentFY;
	public String currentFQ;

    global ChapterHealthQuarterlyBatch(String bType, String fy, String fq) {
		batchType = bType;
		currentFY = fy;
		currentFQ = fq;
		query = 'SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = \'Chapter\' AND Type = \'Region\'';
		System.debug('Query: ' + query);
	}

    global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query); 
    }
    
	global void execute(Database.BatchableContext BC, List<Account> scope) {
		System.debug('Quarterly batch execute()');
		System.debug('Scope: ' + scope.size() + ' Regions');
		
		for (Account region : scope) {
			ChapterHealthCreationServices.createRegionHealth(region, batchType, currentFY, currentFQ);
		}
    }
    
    global void finish(Database.BatchableContext BC) {
		ChapterHealthBatchHelper daily = new ChapterHealthBatchHelper();
		daily.execute(null);
    }
    
}