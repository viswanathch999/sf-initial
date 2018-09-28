@isTest
public class InvoiceTriggerFFTest 
{
    @isTest
	static void testTrigger()
    {
        Account account = new Account();
        account.Name = 'KG Invoice Test Account';
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'KG';
        contact.LastName = 'Invoice';
        insert contact;
        
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'KG Invoice Test Opp';
        opportunity.StageName = 'Prospecting';
        opportunity.AccountId = account.Id;
        opportunity.KGRenewal__Contact__c = contact.Id;
        opportunity.CloseDate = System.today();
        insert opportunity;
            
	    KGRenewal__Invoice__c inv = new KGRenewal__Invoice__c(KGRenewal__Account__c = account.Id, KGRenewal__Opportunity__c = opportunity.Id);
    	insert inv;
    
             
        
    }
}