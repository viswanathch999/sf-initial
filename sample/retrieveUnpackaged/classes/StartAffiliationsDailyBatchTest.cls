@isTest
private class StartAffiliationsDailyBatchTest{
    
    public static Contact testMemberContact, testSpouseContact;
    public static Account oAccountHousehold;
    public static Account testChapter, testChapter2;
    public static Account_Affiliation__c testExistingPrimaryAff,testExistingActiveAff,testNewPrimaryAff;
    public static Id chapterId;
    
    static void setup(){
        Account mockRegion = TestServices.createAccount('Test Region Chapter');
        mockRegion.Type = 'Region';
        mockRegion.RecordTypeId = RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        insert mockRegion;
        testChapter = TestServices.createAccount('Test Account Name');
        testChapter.Type = 'Chapter';
        testChapter.YPOI_Type__c = 'YPO Chapter';
        testChapter.RecordTypeId =  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        testChapter.ParentId = mockRegion.Id; 
        insert testChapter;
        testChapter2 = TestServices.createAccount('Test Account');
        testChapter2.Type = 'Chapter';
        testChapter2.YPOI_Type__c = 'YPO Chapter';
        testChapter2.is_Integrated__c = true;
        testChapter2.RecordTypeId =  RecordTypeServices.getRecordTypeByName('Chapter','Account').Id;
        testChapter2.ParentId = mockRegion.Id; 
        insert testChapter2;
        testMemberContact = TestServices.createContact('Test Last Name', testChapter.Id);
        testMemberContact.RecordTypeId =  RecordTypeServices.getRecordTypeByName('Member','Contact').Id; 
        testMemberContact.Membership_Status__c = 'Member';
        insert testMemberContact;
        Opportunity testOpp = new Opportunity();
        testOpp.StageName = 'Cycle Open';
        testOpp.KGRenewal__Contact__c = testMemberContact.Id;
        testOpp.Name = 'TestOpp';
        testOpp.CloseDate = System.today().addDays(10);
        insert testOpp;
        KGRenewal__Invoice__c inv = new KGRenewal__Invoice__c();
		inv.KGRenewal__Account__c = testChapter.Id;
		inv.KGRenewal__Opportunity__c = testOpp.Id;
		insert inv;
		KGRenewal__InvoiceItem__c invItem = new KGRenewal__InvoiceItem__c();
		invItem.KGRenewal__Invoice__c = inv.Id;
		invItem.KGRenewal__Amount__c = 100;
		insert invItem;
		KGRenewal__Transaction__c trans = new KGRenewal__Transaction__c (
                 KGRenewal__Amount__c = 0,
                 KGRenewal__Contact__c =  testMemberContact.Id,
                 KGRenewal__Opportunity__c = testOpp.Id, 
                 KGRenewal__Invoice__c = inv.id, 
                 KGRenewal__Status__c = 'Success',
                 KGRenewal__TransactionMethod__c = 'Offline',
                 KGRenewal__TransactionMethodDetails__c = 'Check or wire payment pending'
           );

        insert trans;
        testSpouseContact = TestServices.createContact(testChapter2.Id);
        insert testSpouseContact;        
        oAccountHousehold = TestServices.createAccount('AdditonalDataFormContact-Household');
        oAccountHousehold.Type = 'Relationship';
        insert oAccountHousehold;
        TestServices.createRelationship(testSpouseContact.Id, oAccountHousehold.Id, 'Spouse_Partner', true , true);
        TestServices.createRelationship(testMemberContact.Id, oAccountHousehold.Id, 'Member', true , true);    
        chapterId =  RecordTypeServices.getRecordTypeByName('Chapter','Account_Affiliation__c').Id;        
    }
    static testMethod void testStartAffiliationsDailyBatch_NewPrimaryTest() {
        setup(); 
        Id profileId = [SELECT id FROM Profile WHERE Name =:Label.Partner_User_Custom].id;
        User oUser1 = TestServices.createPartnerCommunityUser(testMemberContact.id, profileId);
        insert oUser1;
        CA_Setting__c oCASetting = TestServices.createCASetting(testChapter.id, oUser1.id, true);
        oCASetting.Primary__c = true;
        oCASetting.Role__c = 'Chapter Administrator';
        insert oCASetting;
        Test.startTest();
	        testExistingPrimaryAff = TestServices.createAccountAffiliation(testChapter2.Id,testMemberContact.Id, System.today().addDays(-10), true, true, chapterId, true);
	        testExistingActiveAff = TestServices.createAccountAffiliation(testChapter.Id,testMemberContact.Id, System.today().addDays(-10), true, false, chapterId, true);
	        testNewPrimaryAff = TestServices.createAccountAffiliation(testChapter.Id, testMemberContact.Id, System.today(), false, true, chapterId, false);
	        testNewPrimaryAff.Reason_for_Leaving__c = 'test';
	        testNewPrimaryAff.Start_Date__c = system.today();
	        testNewPrimaryAff.Chapter_Approval_Status__c = 'Approved';
        	testNewPrimaryAff.Transfer_Flag__c = 'Transfer';
	        testNewPrimaryAff.IsActive__c = false;
	        
        	insert testNewPrimaryAff;
	        Database.executeBatch(new StartAffiliationsDailyBatch());
	        testExistingPrimaryAff = [Select IsActive__c, Is_Primary__c from Account_Affiliation__c where 
	                                  id =:testExistingPrimaryAff.id];
	        testExistingActiveAff = [Select IsActive__c, end_date__c from Account_Affiliation__c where 
	                                 id =:testExistingActiveAff.id];
	        system.assertEquals(true ,testExistingPrimaryAff.IsActive__c, 
	                            'Existing Primary Affiliation should remain active');
        Test.stopTest();
    }
    static testMethod void testStartAffiliationsDailyBatch_TranisitionTest() {
        setup();
        Id profileId = [SELECT id FROM Profile WHERE Name =:Label.Partner_User_Custom].id;
        User oUser1 = TestServices.createPartnerCommunityUser(testMemberContact.id, profileId);
        insert oUser1;
        CA_Setting__c oCASetting = TestServices.createCASetting(testChapter.id, oUser1.id, true);
        oCASetting.Primary__c = true;
        oCASetting.Role__c = 'Chapter Administrator';
        insert oCASetting;
        
        Test.startTest();
        testExistingPrimaryAff = TestServices.createAccountAffiliation(testChapter2.Id,testMemberContact.Id, System.today().addDays(-10), true, true, chapterId, true);
        testExistingActiveAff = TestServices.createAccountAffiliation(testChapter.Id,testMemberContact.Id, System.today().addDays(-10), true, false, chapterId, true);
        testNewPrimaryAff = TestServices.createAccountAffiliation(testChapter.Id, testMemberContact.Id, System.today(), false, true, chapterId, false);
        testNewPrimaryAff.Reason_for_Leaving__c = 'test';
        testNewPrimaryAff.Start_Date__c = system.today();
        testNewPrimaryAff.End_Date__c = system.today().addDays(100);
        testNewPrimaryAff.Chapter_Approval_Status__c = 'Approved';
        testNewPrimaryAff.Transfer_Flag__c = 'Renewal Transition';        
        
	        insert testNewPrimaryAff;
	        Database.executeBatch(new StartAffiliationsDailyBatch());
        Test.stopTest();
    }

    static testMethod void testBatch_TransititonContact_UpdateHistory()
    {
        setup();
        Id chapterRecordTypeId = RecordTypeServices.getRecordTypeByName('Chapter','Account_Affiliation__c').Id;
        Account_Affiliation__c testAccAff = TestServices.createAccountAffiliation(testChapter2.Id,
                                                                                  testMemberContact.Id,
                                                                                  System.today(),
                                                                                  false/*isActive*/,
                                                                                  false/*isPrimary*/,
                                                                                  chapterRecordTypeId,
                                                                                  false/*doInsert*/
                                                                                  );
        testAccAff.Reason_for_Leaving__c = 'test';
        testAccAff.Start_Date__c = system.today();
        testAccAff.Chapter_Approval_Status__c = 'Approved';
        testAccAff.Transfer_Flag__c = 'Renewal Transition';
        testAccAff.IsActive__c = false;
        insert testAccAff;
        
        Map<SObjectField,Object> activeHistoryFieldValues = new Map<SObjectField,Object>
        {
            Membership_History__c.Status__c => 'Member',
            Membership_History__c.Contact__c => testMemberContact.Id
        };
        Membership_History__c activeHistory = (Membership_History__c) SObjectFactory.create(Membership_History__c.SObjectType,
                                                                                            activeHistoryFieldValues);

        Test.startTest();
            Database.executeBatch(new StartAffiliationsDailyBatch());
        Test.stopTest();

        String expectedContactTransitionStatus = 'Transitioned';
        String expectedYPOStatus = 'YPO Gold';
        Contact updateMemberContact = [SELECT Id, Transition_Status__c,YPO_WPO_Formula__c
                                       FROM Contact
                                       WHERE Id = :testMemberContact.Id];

        Membership_History__c updatedActiveHistory = [SELECT Date_Left__c, Status__c, Reason__c 
                                                      FROM Membership_History__c
                                                      WHERE Id =: activeHistory.Id];

        Date expectedDateLeft =  Date.today().addDays(-1);
        String expectedReason = 'Transitioned';
        String expectedHistoryStatus = 'Resigned';
		
        List<Membership_History__c> newHistoryList = [SELECT Account__c,Status__c,YPO_WPO__c,Join_Date__c,Reason__c
                                                  FROM Membership_History__c
                                                  WHERE Id <>:activeHistory.Id];
    }
    
    
    static testmethod void testTransferScenario() {
    	setup(); 
        Id profileId = [SELECT id FROM Profile WHERE Name =:Label.Partner_User_Custom].id;
        User oUser1 = TestServices.createPartnerCommunityUser(testMemberContact.id, profileId);
        insert oUser1;
        CA_Setting__c oCASetting = TestServices.createCASetting(testChapter.id, oUser1.id, true);
        oCASetting.Primary__c = true;
        oCASetting.Role__c = 'Chapter Administrator';
        insert oCASetting;
        Test.startTest();
	        testExistingPrimaryAff = TestServices.createAccountAffiliation(testChapter2.Id,testMemberContact.Id, System.today().addDays(-10), true, true, chapterId, true);
	        testExistingActiveAff = TestServices.createAccountAffiliation(testChapter.Id,testMemberContact.Id, System.today().addDays(-10), true, false, chapterId, true);
	        testNewPrimaryAff = TestServices.createAccountAffiliation(testChapter.Id, testMemberContact.Id, System.today(), false, true, chapterId, false);
	        testNewPrimaryAff.Reason_for_Leaving__c = 'test';
	        testNewPrimaryAff.Start_Date__c = system.today();
	        testNewPrimaryAff.Chapter_Approval_Status__c = 'Approved';
	        testNewPrimaryAff.Transfer_Flag__c = 'Transfer';
	        testNewPrimaryAff.IsActive__c = false;
        
        	insert testNewPrimaryAff;
        
	        Database.executeBatch(new StartAffiliationsDailyBatch());
	        Account_Affiliation__c actualNewAff = [SELECT Id, isActive__c FROM Account_Affiliation__c WHERE ID =: testNewPrimaryAff.Id LIMIT 1];
        Test.stopTest();
        
        
        System.assert(actualNewAff.isActive__c = true, 'We expect the new aff to be active.');
    }
    
    static testmethod void testTransitionScenario() {
    	setup(); 
        Id profileId = [SELECT id FROM Profile WHERE Name =:Label.Partner_User_Custom].id;
        User oUser1 = TestServices.createPartnerCommunityUser(testMemberContact.id, profileId);
        insert oUser1;
        CA_Setting__c oCASetting = TestServices.createCASetting(testChapter.id, oUser1.id, true);
        oCASetting.Primary__c = true;
        oCASetting.Role__c = 'Chapter Administrator';
        insert oCASetting;
        Test.startTest();
	        testExistingPrimaryAff = TestServices.createAccountAffiliation(testChapter2.Id,testMemberContact.Id, System.today().addDays(-10), true, true, chapterId, true);
	        testExistingActiveAff = TestServices.createAccountAffiliation(testChapter.Id,testMemberContact.Id, System.today().addDays(-10), true, false, chapterId, true);
	        testNewPrimaryAff = TestServices.createAccountAffiliation(testChapter.Id, testMemberContact.Id, System.today(), false, true, chapterId, false);
	        testNewPrimaryAff.Reason_for_Leaving__c = 'test';
	        testNewPrimaryAff.Start_Date__c = system.today();
	        testNewPrimaryAff.Chapter_Approval_Status__c = 'Approved';
	        testNewPrimaryAff.Transfer_Flag__c = 'Renewal Transition';
	        testNewPrimaryAff.IsActive__c = false;
        
        	insert testNewPrimaryAff;
        
	        Database.executeBatch(new StartAffiliationsDailyBatch());
	        Account_Affiliation__c actualNewAff = [SELECT Id, isActive__c FROM Account_Affiliation__c WHERE ID =: testNewPrimaryAff.Id LIMIT 1];
        Test.stopTest();
        
        
        System.assert(actualNewAff.isActive__c = true, 'We expect the new aff to be active.');
    }
}