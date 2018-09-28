global class TransitionStatusBatchScheduler implements Schedulable {
    
    global void execute(SchedulableContext ctx) {        
        
        Database.executeBatch( new TransitionStatusBatch() );        
        
    }   
}