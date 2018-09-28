@isTest
private class AddProductsForQ4ProspectsTest {

    static testMethod void testProductsForQ4Products() {
    	Id chapterRecordTypeId = RecordTypeServices.getRecordTypeByName('Chapter', 'Account').Id;
    	
    	Account targetChapter = (Account) SObjectFactory.build(Account.SObjectType);
    	targetChapter.RecordTypeId = chapterRecordTypeId;
    	targetChapter.Chapter_Dues__c = 'All Members';
    	insert targetChapter;
    	
    	Contact testContact = (Contact) SObjectFactory.create(Contact.SObjectType);
    	
        Opportunity testOpp = (Opportunity) SObjectFactory.build(Opportunity.SObjectType);
        testOpp.Fiscal_Date_Start__c = FiscalDateUtility.startOfnextFiscal;
        testOpp.Referred_by_Chapter__c = targetChapter.id;
        testOpp.KGRenewal__Contact__c = testContact.id;
        insert testOpp;
        
        List<Opportunity> opps = new List<Opportunity>();
        opps.add(testOpp);
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 stdPB = new Pricebook2(Id = pricebookId, IsActive = true);
        update stdPB;
        
        Product2 primProd = new Product2();
        primProd.Product_Type__c = 'Primary';
        primProd.Account__c = targetChapter.Id;
        primProd.IsActive = true;
        primProd.Family = 'Chapter Dues';
        primProd.Name = 'Chapter Dues Product';
        insert primProd;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.UnitPrice = 100;
        pbe.Product2Id = primProd.Id;
        pbe.Pricebook2Id = pricebookId;
        pbe.isActive = true;
        insert pbe;
        
        Test.startTest();
        	AddProductsForQ4Prospects.AddProductsForQ4(opps);
        Test.stopTest();
        
        List<OpportunityLineItem> relatedOLIs = [SELECT Id, PricebookEntryId, UnitPrice FROM OpportunityLineItem WHERE OpportunityId =: testOpp.Id];
        System.assertEquals(1, relatedOLIs.size(), 'We expect one oli to be created.');
        System.assertEquals(pbe.UnitPrice, relatedOLIs[0].UnitPrice, 'We expect the price to be correct.');
        
    }
}