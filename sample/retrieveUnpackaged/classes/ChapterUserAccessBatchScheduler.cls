/**
 * ChapterUserAccessBatchScheduler is scheduler which will run daily to provide access to Chapter admin users
 * This is to provide extra access to Chapter Admin records.  
 *
 * @author Shri K
 */
global class ChapterUserAccessBatchScheduler implements Database.Batchable<User>, Schedulable{
    global String query;
    public static final String QUERY_STRING =
        'SELECT Id, AccountId FROM User WHERE IsActive = true AND UserType IN( \'Partner\', \'PowerPartner\')';
    
    global ChapterUserAccessBatchScheduler(){
    query = QUERY_STRING;
    }
    global ChapterUserAccessBatchScheduler(String userId){
    query = QUERY_STRING+' And Id =\''+userId+'\' ';
    }
    /**
     * start method of schedulable interface. 
     * Method internally calls batch which will invoke flows.  
     */
    public void execute(SchedulableContext oSchedulableContext)
    {
        executeBatch();         
    }
    
    global List<User> start(Database.BatchableContext BC)
    {
        return Database.query(query);
            //[SELECT Id, AccountId FROM User WHERE IsActive = true AND UserType IN( 'Partner', 'PowerPartner') ];
    }
    
    global void execute(Database.BatchableContext BC, List<User> lstUser)
    {
        UserServices.shareContact(lstUser, null);
    }

    global void finish(Database.BatchableContext BC)
    {
        DataBase.executeBatch(new ChapterAdditionalUserAccessBatch(), 1);
    }
    
    webservice static void executeBatch()
    {
        DataBase.executeBatch(new ChapterUserAccessBatchScheduler(), 1);
    }
}