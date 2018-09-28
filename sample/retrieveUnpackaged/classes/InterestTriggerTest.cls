/**
 * This class contains unit tests for validating the behavior of InterestTrigger
 * "Given" defines the preconditions, "When" defines what happens, and 
 * "Then" defines the result of the scenario. Or in other words: 
 * "Given" describes the start state, and "When" the steps 
 * necessary to reach the accepting state (= "Then").
 * InterestTriggerTest is service as test class for trigger written on Interest__c object.
 */
 
@isTest
private class InterestTriggerTest {

    static void instantiateCustomSetting()
    {       
        List<Marketing_Segmentation__c> lstMarketing = new List<Marketing_Segmentation__c>();
        //Custom Setting Insert 
        Marketing_Segmentation__c oMarketingSegmentation = TestServices.createMarketingSegmentation('S1', '', '', '-13.938690');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S2', '', '', '-12.907870');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S3', '', '', '-11.747160');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S4', '', '', '-11.481920');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S5', '', '', '-10.830110');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S6', '', '', '-3.390420');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S1/AdventureTravel', 'Adventure Travel', '0.720900' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S2/AdventureTravel', 'Adventure Travel', '0.720900' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S3/AdventureTravel', 'Adventure Travel', '0.720900' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S4/AdventureTravel', 'Adventure Travel', '0.720900' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S5/AdventureTravel', 'Adventure Travel', '0.720900' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S6/AdventureTravel', 'Adventure Travel', '0.720900' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S1/Cruise', 'Cruise', '0.101250' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S2/Cruise', 'Cruise', '0.101250' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S3/Cruise', 'Cruise', '0.101250' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S4/Cruise', 'Cruise', '0.101250' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S5/Cruise', 'Cruise', '0.101250' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S6/Cruise', 'Cruise', '0.101250' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        insert lstMarketing;
    }   

    static testMethod void testgivenInterestRecord_WhenInserted_thenUpdateMarketingSegmentationOnContact() {
        
        //Custom Setting Insert
        instantiateCustomSetting();
        
        Account oAccount = TestServices.createAccount('Test-Account');
        insert oAccount;
        Contact oContact = TestServices.createContact(oAccount.Id);
        insert oContact;
        
        Test.startTest();
        Interest__c oInterest = TestServices.createInterest(oContact.Id, 'Travel', 'Adventure Travel');
        insert oInterest;
        Test.stopTest();
        
        Contact oContactUpdated = getContact(oInterest.Contact__c);
        
        System.assertEquals(oContactUpdated.S1__c, -13.21779);
        System.assertEquals(oContactUpdated.S2__c, -12.18697);
        System.assertEquals(oContactUpdated.S3__c, -11.02626);
        System.assertEquals(oContactUpdated.S4__c, -10.76102);
        System.assertEquals(oContactUpdated.S5__c, -10.10921);
        System.assertEquals(oContactUpdated.S6__c, -2.66952);
        System.assertEquals(oContactUpdated.Segmentation_Sum__c, -59.97077);
        System.assertEquals(oContactUpdated.Marketing_Segment__c, 'S6');
                
    }

    static testMethod void testgivenInterestRecord_WhenUpdated_thenUpdateMarketingSegmentationOnContact() 
    {
        
        //Custom Setting Insert
        instantiateCustomSetting();
        
        Account oAccount = TestServices.createAccount('Test-Account');
        insert oAccount;
        Contact oContact = TestServices.createContact(oAccount.Id);
        insert oContact;
        Interest__c oInterest = TestServices.createInterest(oContact.Id, 'Travel', 'Adventure Travel');
        insert oInterest;
        
        Test.startTest();
        oInterest.Interest__c = 'Adventure Travel;Cruise';
        update oInterest;
        Test.stopTest();
        
        Contact oContactUpdated = getContact(oInterest.Contact__c);
        
        System.assertEquals(oContactUpdated.S1__c, -13.11654);
        System.assertEquals(oContactUpdated.S2__c, -12.08572);
        System.assertEquals(oContactUpdated.S3__c, -10.92501);
        System.assertEquals(oContactUpdated.S4__c, -10.65977);
        System.assertEquals(oContactUpdated.S5__c, -10.00796);
        System.assertEquals(oContactUpdated.S6__c, -2.56827);
        System.assertEquals(oContactUpdated.Segmentation_Sum__c, -59.36327);
        System.assertEquals(oContactUpdated.Marketing_Segment__c, 'S6');
                
    }
    
    static testMethod void testgivenInterestRecord_WhenDeleted_thenUpdateMarketingSegmentationOnContact() {
        
        //Custom Setting Insert
        instantiateCustomSetting();
        
        Account oAccount = TestServices.createAccount('Test-Account');
        insert oAccount;
        Contact oContact = TestServices.createContact(oAccount.Id);
        insert oContact;
        Interest__c oInterest = TestServices.createInterest(oContact.Id, 'Travel', 'Adventure Travel');
        insert oInterest;
        
        Test.startTest();
        delete oInterest;
        Test.stopTest();
        
        Contact oContactUpdated = getContact(oInterest.Contact__c);
        
        System.assertEquals(oContactUpdated.S1__c, null);
        System.assertEquals(oContactUpdated.S2__c, null);
        System.assertEquals(oContactUpdated.S3__c, null);
        System.assertEquals(oContactUpdated.S4__c, null);
        System.assertEquals(oContactUpdated.S5__c, null);
        System.assertEquals(oContactUpdated.S6__c, null);
        //System.assertEquals(oContactUpdated.Segmentation_Sum__c, 0);
        System.assertEquals(oContactUpdated.Marketing_Segment__c, null);   
    }

    static testMethod void testgivenInterestRecord_WhenUpdated_thenUpdateMarketingSegmentationOnContactForS0() {
        
        //Custom Setting Insert
        List<Marketing_Segmentation__c> lstMarketing = new List<Marketing_Segmentation__c>();
        //Custom Setting Insert
        Marketing_Segmentation__c oMarketingSegmentation = TestServices.createMarketingSegmentation('S1', '', '', '-13.938690');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S2', '', '', '-12.907870');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S3', '', '', '-11.747160');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S4', '', '', '-11.481920');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S5', '', '', '-10.830110');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S6', '', '', '-3.390420');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S1/AdventureTravel', 'Adventure Travel', '0.000000' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S2/AdventureTravel', 'Adventure Travel', '0.000000' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S3/AdventureTravel', 'Adventure Travel', '0.000000' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S4/AdventureTravel', 'Adventure Travel', '0.000000' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S5/AdventureTravel', 'Adventure Travel', '0.000000' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S6/AdventureTravel', 'Adventure Travel', '0.000000' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S1/Cruise', 'Cruise', '0.000000' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S2/Cruise', 'Cruise', '0.000000' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S3/Cruise', 'Cruise', '0.000000' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S4/Cruise', 'Cruise', '0.000000' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S5/Cruise', 'Cruise', '0.000000' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        oMarketingSegmentation = TestServices.createMarketingSegmentation('S6/Cruise', 'Cruise', '0.000000' , '');
        lstMarketing.add(oMarketingSegmentation);
        
        insert lstMarketing;
        
        Account oAccount = TestServices.createAccount('Test-Account');
        insert oAccount;
        
        Contact oContact = TestServices.createContact(oAccount.Id);
        insert oContact;
        
        Interest__c oInterest = TestServices.createInterest(oContact.Id, 'Travel', 'Adventure Travel');
        insert oInterest;
        
        Test.startTest();
        oInterest.Interest__c = 'Adventure Travel;Cruise';
        update oInterest;
        Test.stopTest();
        
        Contact oContactUpdated = getContact(oInterest.Contact__c);
        
        System.assertEquals(oContactUpdated.S1__c, -13.938690);
        System.assertEquals(oContactUpdated.S2__c, -12.907870);
        System.assertEquals(oContactUpdated.S3__c, -11.747160);
        System.assertEquals(oContactUpdated.S4__c, -11.481920);
        System.assertEquals(oContactUpdated.S5__c, -10.830110);
        System.assertEquals(oContactUpdated.S6__c, -3.390420);
        System.assertEquals(oContactUpdated.Segmentation_Sum__c, -64.29617);
        System.assertEquals(oContactUpdated.Marketing_Segment__c, 'S0');
                
    }
    
    static testMethod void negativetestgivenInterestRecord_WhenUpdatedBlank_thendonotUpdateMarketingSegmentationOnContact() 
    {
        
        //Custom Setting Insert
        instantiateCustomSetting();
        
        Account oAccount = TestServices.createAccount('Test-Account');
        insert oAccount;
        Contact oContact = TestServices.createContact(oAccount.Id);
        insert oContact;
        Interest__c oInterest = TestServices.createInterest(oContact.Id, 'Travel', 'Adventure Travel;Cruise');
        insert oInterest;
        
        Test.startTest();
        update oInterest;
        Test.stopTest();
        
        Contact oContactUpdated = getContact(oInterest.Contact__c);
        
        System.assertEquals(oContactUpdated.S1__c, -13.11654);
        System.assertEquals(oContactUpdated.S2__c, -12.08572);
        System.assertEquals(oContactUpdated.S3__c, -10.92501);
        System.assertEquals(oContactUpdated.S4__c, -10.65977);
        System.assertEquals(oContactUpdated.S5__c, -10.00796);
        System.assertEquals(oContactUpdated.S6__c, -2.56827);
        System.assertEquals(oContactUpdated.Segmentation_Sum__c, -59.36327);
        System.assertEquals(oContactUpdated.Marketing_Segment__c, 'S6');
                
    }
    
    static Contact getContact(Id contactId)
    {
        return [SELECT Id, S1__c, S2__c, S3__c, S4__c, S5__c, S6__c, Marketing_Segment__c, Segmentation_Sum__c 
                                FROM Contact
                                WHERE Id =: contactId
                                LIMIT 1];
    }
    
}