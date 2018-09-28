@isTest
private class AonCardPDFExportControllerTest {
    
    @isTest 
    static void AonCardPDFExportControllerTest1() {
        Id memberRTId = RecordTypeServices.getRecordTypeByName('Member','Contact').Id; 
        Account tAccount = TestServices.createAccount('TestAcc');
        insert tAccount;
        System.debug('*** AonCardPDFExportControllerTest1: tAccount: ' + tAccount) ;
        
        // Create the contact the portal user will be linked to
        Contact tContact = TestServices.createContact(tAccount.Id);
        tContact.RecordTypeId = memberRTId;
        insert tContact;
        Contact aContact = TestServices.createContact(tAccount.Id);
        aContact.RecordTypeId = memberRTId;
        insert aContact;
        System.debug('*** AonCardPDFExportControllerTest1: tContact: ' + tContact);
        Account testAccount = new Account(
            Name = 'testAccount',
            CurrencyIsoCode = 'USD',
            BillingPostalCode = '91320',
            Industry = 'Banking'
        );
        insert testAccount;
        Contact testContact = TestServices.createContact(testAccount.Id);
        testContact.LastName = 'contact';
        testContact.Email = 'test@email.com';
        insert testContact;
        KGRenewal__VenueSettings__c settings = KGRenewal__VenueSettings__c.getOrgDefaults();
        settings.KGRenewal__OpportunityStageOnInsertion__c = 'TEST STAGE';
        upsert settings;
        Opportunity opp = new Opportunity(
            StageName = 'Payment Received', 
            Certification_Status__c = 'Complete', 
            Grace_Status__c = 'No Grace Needed', 
            Name = 'TestOpp',
            CloseDate = System.today(),
            KGRenewal__IsActiveCart__c = true,
            KGRenewal__ContractEffectiveDate__c = FiscalDateUtility.startOfCurrentFiscal,
            KGRenewal__Contact__c  = testContact.id
        );
        
        opp = (Opportunity)JSONUtils.setField(opp, 'Record_Type_Name__c', 'Member');
        System.debug('###aon: ' + opp);
        insert opp ;
        opp.StageName = 'Closed Won';
        update opp ;
        System.debug('*** AonCardPDFExportControllerTest1: opp: ' + opp) ;
        
        OpportunityContactRole ocr = new OpportunityContactRole(
            OpportunityId = opp.Id, 
            ContactId = tContact.Id, 
            Role = 'Other'
        ) ;
        insert ocr ;
        /*
Opportunity oppTest = new Opportunity(
StageName = 'Payment Received', 
Certification_Status__c = 'Complete', 
Name = 'TestOpp2',
CloseDate = System.today().addDays(-1)
);
insert oppTest ;
opp.StageName = 'Closed Won';
update oppTest ;
System.debug('*** AonCardPDFExportControllerTest1: oppTest: ' + oppTest) ;

ocr = new OpportunityContactRole(
OpportunityId = oppTest.Id, 
ContactId = tContact.Id, 
Role = 'Other'
) ;
insert ocr ;

oppTest = new Opportunity(
StageName = 'Payment Received', 
Certification_Status__c = 'Complete', 
Name = 'TestOpp3',
CloseDate = System.today().addDays(-1)
);
insert oppTest ;
opp.StageName = 'Closed Won';
update oppTest ;
System.debug('*** AonCardPDFExportControllerTest1: oppTest: ' + oppTest) ;

ocr = new OpportunityContactRole(
OpportunityId = oppTest.Id, 
ContactId = tContact.Id, 
Role = 'Other'
) ;
insert ocr ;
*/
        Product2 testProduct = new Product2(
            IsActive = true,
            ProductCode = 'TEST',
            CurrencyIsoCode = 'USD',
            Name = 'TEST NAME',
            KGRenewal__IsTaxable__c = true,
            Exclusive__c = 'YNG',
            Worldaware_benefit__c = true
        );
        insert testProduct;
        PricebookEntry testEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert testEntry;
        OpportunityLineItem oli = new OpportunityLineItem(Contact__c = aContact.id,
                                                          PricebookEntryId = testEntry.id,
                                                          OpportunityId = opp.id,
                                                          Quantity = 1,
                                                          TotalPrice = 1 * testEntry.UnitPrice);
        insert oli;
        ApexPages.StandardController sc = new ApexPages.StandardController(tContact);
        Test.startTest();
        AonCardPDFExportController acpec = new AonCardPDFExportController(sc);
        Test.stopTest();
        
        System.assertEquals(opp.Id, acpec.myOpp.Id, 'The Opportunities dont match. Please persue');
        System.assert(acpec.familyMembers.size() > 0, 'A Contact should have been retrieved');
    }
}