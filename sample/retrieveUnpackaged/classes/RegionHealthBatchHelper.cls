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
global class RegionHealthBatchHelper implements Schedulable {

	global void execute(SchedulableContext ctx) {
		List<Chapter_Health_Batch__c> regionalBatch = new List<Chapter_Health_Batch__c>();
        regionalBatch = [SELECT Name, Function__c, Object__c, SOQL_Query__c, Target_Field_API_Name__c, Chapter_Lookup_Field_API_Name__c, Field_to_Aggregate__c
							 FROM Chapter_Health_Batch__c 
							 WHERE Is_Active__c = true  
							 AND Region_Health_Calculation__c = true 
							 AND Processed__c = YESTERDAY];
		System.debug('Region batches remaining: ' + regionalBatch.size());
        if (!regionalBatch.isEmpty()) Database.executeBatch(new RegionalHealthDailyBatch(regionalBatch[0]));
    }

}