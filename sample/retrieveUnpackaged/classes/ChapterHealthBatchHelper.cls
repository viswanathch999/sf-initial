/**
* This class is called by the schedulable class ChapterHealthBatchScheduler.
* 
* It runs one Chapter Health calculation per batch, using the batchable
* class ChapterHealthDailyBatch to calculate for each Chapter.
* 
* Once the batch completes for all Chapters, ChapterHealthDailyBatch calls 
* this class again and runs the next calc.
* 
* Once all calcs are complete, this class starts RegionHealthBatchHelper 
* to calculate the Regional values.
*/ 
global class ChapterHealthBatchHelper implements Schedulable {
	
	global void execute(SchedulableContext ctx) {
		List<Chapter_Health_Batch__c> chapterBatch = new List<Chapter_Health_Batch__c>();
		chapterBatch = [SELECT Name, Function__c, Object__c, SOQL_Query__c, Target_Field_API_Name__c, Chapter_Lookup_Field_API_Name__c, Field_to_Aggregate__c
								FROM Chapter_Health_Batch__c 
								WHERE Is_Active__c = true
								AND Auto_Calculate__c = true 
								AND Processed__c = YESTERDAY];
		System.debug('Chapter batches remaining: ' + chapterBatch.size());
		if (!chapterBatch.isEmpty()) Database.executeBatch(new ChapterHealthDailyBatch(chapterBatch[0]));
		else {
			RegionHealthBatchHelper helperRH = new RegionHealthBatchHelper();
			helperRH.execute(null);
		}
	}

}