global class StartAffiliationsDailyBatchScheduler implements Schedulable{
    global void execute(SchedulableContext ctx) {        
        Database.executeBatch( new StartAffiliationsDailyBatch(), Integer.valueOf(Label.Account_Affiliations_Batch_Size) );        
    }   
}