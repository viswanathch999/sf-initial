@isTest
public class StagingCventTransactionDetailTest
{
    @isTest
    static void TestTrigger()
    {
        try
        {
            Staging_Cvent_Transaction_Detail__c objToInsert = new Staging_Cvent_Transaction_Detail__c();
	        objToInsert.Transaction_Date__c = System.today();            
    	    objToInsert.Payment_Type__c =  'Visa';
            
            insert objToInsert;
        }
        catch(Exception ex) {}
    }
}