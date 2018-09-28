@isTest
public class TestYNG_OlisContactInfoUpdatePageExt {
    static Contact contactOnOpportunity;  
    static OpportunityLineItem oli;
    static Contact contactOnOli; 
    public static void setup(){
        Account acc = TestServices.createAccount('TestAccount');
        insert acc;
        contactOnOpportunity = TestServices.createContact(acc.Id);
        insert contactOnOpportunity;
        Account accOli = TestServices.createAccount('OliAccount');
        insert accOli;
        contactOnOli = TestServices.createContact(accOli.Id, 'tester', true);
    
        Opportunity opp = TestServices.createOpp(acc.Id,false);
        opp.KGRenewal__Contact__c = contactOnOpportunity.id;
        opp.KGRenewal__IsActiveCart__c = true;
        insert opp;
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create your product
        Product2 prod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            isActive = true,
            Exclusive__c='YNG'
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        oli = new OpportunityLineItem(OpportunityId=opp.Id, Contact__c=contactOnOli.id, Quantity = 1,PricebookEntryId = pbEntry.Id
                                      ,TotalPrice = pbEntry.UnitPrice );
        insert oli;
    }
    
    static testMethod void TestOliContactFieldsGetUpdated(){
        setup();
        Apexpages.StandardController oStandardContactCon = new Apexpages.StandardController(contactOnOpportunity);
        YNG_OlisContactInfoUpdatePageExt ext = new YNG_OlisContactInfoUpdatePageExt(oStandardContactCon);
        ext.onLoad();
        ext.yngOLIs[0].contact__r.LastName='Test Passed';
        Test.startTest();
        ext.saveProductsContact();
        Test.stopTest();
        String updatedLastName = [Select lastname from contact where id=:contactOnOli.id][0].lastname;
        System.assertEquals('Test Passed', updatedLastName);
    }
}