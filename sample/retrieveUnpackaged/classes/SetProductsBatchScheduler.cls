global class SetProductsBatchScheduler implements Schedulable {
    
    global void execute(SchedulableContext ctx) {        
        
        SetProductsBatch spb = new SetProductsBatch();
		Database.executeBatch(spb, 3);       
        
    }
}