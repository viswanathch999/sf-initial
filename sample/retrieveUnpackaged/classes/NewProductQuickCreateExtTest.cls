@isTest
public class NewProductQuickCreateExtTest {
    public static Product2 testProd;
    public static Contact testCon;
    public static User portalUser;
    public static Account aAccount;
    static void setup(){
        Id memberRTId = RecordTypeServices.getRecordTypeByName('Member','Contact').Id; 
        
        aAccount = TestServices.createAccount('TestAcc');
        aAccount.Type = 'Relationship';
        insert aAccount;
        testCon = TestServices.createContact(aAccount.Id);
        testCon.RecordTypeId = memberRTId;
        insert testCon;
        system.debug('con id'+testCon.id);
        
        Profile partnerUserProfile = [Select Id from Profile where name = 'Partner User'][0];
        portalUser = new User( email='genelia.dsouza@gmail.com',
                              profileid = partnerUserProfile.id, 
                              UserName='sdgia.dsodfdguza@fafil.codfdm', 
                              Alias = 'GDS',
                              TimeZoneSidKey='America/New_York',
                              EmailEncodingKey='ISO-8859-1',
                              LocaleSidKey='en_US', 
                              LanguageLocaleKey='en_US',
                              ContactId = testCon.Id,
                              PortalRole = 'Manager',
                              FirstName = 'Genelia',
                              LastName = 'Dsouza',                             
                              CommunityNickname = 'testUser123');
        insert portalUser;
        Relationship__c aRel  = new Relationship__c(account__c= aAccount.id, Is_Active__c = true, 
                                                    Relationship_Type__c = 'Member', contact__c = testCon.id);
        insert aRel;
        KGRenewal__VenueSettings__c settings = KGRenewal__VenueSettings__c.getOrgDefaults();
        settings.KGRenewal__OpportunityStageOnInsertion__c = 'TEST STAGE';
        upsert settings;
        Opportunity opp = new Opportunity(
            StageName = 'Payment Received', 
            Certification_Status__c = 'Complete', 
            Grace_Status__c = 'No Grace Needed',
            Name = 'TestOpp',
            CloseDate = System.today(),
            accountid= aAccount.id,
            KGRenewal__IsActiveCart__c = true,
            KGRenewal__ContractEffectiveDate__c = system.today(),
            KGRenewal__Contact__c = testCon.Id
        );
        opp = (Opportunity)JSONUtils.setField(opp, 'Record_Type_Name__c', 'Member');
        System.debug('###newprod: ' + opp);
        insert opp ;
        System.debug('*** AonCardPDFExportControllerTest1: opp: ' + opp) ;
        
        OpportunityContactRole ocr = new OpportunityContactRole(
            OpportunityId = opp.Id, 
            ContactId = testCon.Id, 
            Role = 'Other'
        ) ;
        insert ocr ;
        
        testProd = new Product2(
            IsActive = true,
            ProductCode = 'TEST',
            CurrencyIsoCode = 'USD',
            Name = 'TEST NAME',
            KGRenewal__IsTaxable__c = true,
            Exclusive__c = 'YNG',
            Worldaware_benefit__c = true
        );
        insert testProd;
        PricebookEntry testEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProd.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert testEntry;
        OpportunityLineItem oli = new OpportunityLineItem(Contact__c = testCon.id,
                                                          PricebookEntryId = testEntry.id,
                                                          OpportunityId = opp.id,
                                                          Quantity = 1,
                                                          TotalPrice = 1 * testEntry.UnitPrice);
        insert oli;
    }
    static testMethod void TestNewProductQuickCreateExtConstructor() {
        setup();
        PageReference pageRef = Page.NewProductQuickCreate;
        pageRef.getParameters().put('Id',testProd.Id);        
        Test.setCurrentPage(pageRef);    
        ApexPages.StandardController controller = new ApexPages.StandardController(testProd);
        String member = NewProductQuickCreateExt.MEMBER;
        String nonmember = NewProductQuickCreateExt.NON_MEMBER;
        String child = NewProductQuickCreateExt.CHILD;
        Test.startTest();
        NewProductQuickCreateExt controllerExt = new  NewProductQuickCreateExt(controller); 
        Map<String, Id> conRecTypeDevNameToId = controllerExt.conRecTypeDevNameToId; 
        List<SelectOption> relationshipTypes = controllerExt.relationshipTypes;
        controllerExt.newContact.firstname = 'Test';
        controllerExt.newContact.lastname = 'Testsf';   
        controllerExt.newContact.GUID__c = '123456';
        controllerExt.newRelationShip.Relationship_Type__c ='Member';
        controllerExt.newRelationship.Contact__c = testCon.id;
        controllerExt.newRelationship.Account__c = aAccount.id;
        controllerExt.saveCont();
        System.assert(conRecTypeDevNameToId !=null, 'conRecTypeDevNameToId should be properly retrieved');
        System.assert(relationshipTypes !=null, 'relationshipTypes should be properly retrieved');
        
        Test.stopTest();
    }    
}