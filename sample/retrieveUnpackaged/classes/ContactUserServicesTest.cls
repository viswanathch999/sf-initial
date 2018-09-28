@isTest
private class ContactUserServicesTest {
    
    /**
* @desc Test the positive case of correct setup to require changing the user
* @author Matthew A
*/
    @isTest static void positiveDeactivateUserTestNoHouseHold() {
        UserRole oRole ;
        Profile oProfile ;
        User oUser ;
        
        User curUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()] ;
        
        // to avoid mixed DML calls run the user creat in another context
        // Create the portal account owner as a standard user
        System.runAs(curUser) {
            oRole = [SELECT Id FROM UserRole WHERE Name = 'YPO'] ;
            oProfile = [SELECT Id FROM Profile WHERE Name='Standard YPO MTM']; 
            oUser = new User(Alias = 'stando', Email='standarduser@testorg.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = oProfile.Id, UserRoleId = oRole.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_owner@testorg.com', 
                             IsActive = true);
            insert oUser ;
        }
        
        // Create the account for the portal users
        Account tAccount = TestServices.createAccount('TestAcc');
        tAccount.OwnerId = oUser.Id ;
        insert tAccount;
        System.debug('*** positiveDeactivateUserTest: tAccount: ' + tAccount) ;
        
        // Create the contact the portal user will be linked to
        Contact tContact = TestServices.createContact(tAccount.Id);
        tContact.Membership_Status__c = 'Member' ;
        insert tContact;
        System.debug('*** positiveDeactivateUserTest: tContact: ' + tContact) ;
        
        Profile tProfile ;
        User tUser ;
        
        // to avoid mixed DML calls run the user creat in another context
        System.runAs(curUser) {
            tProfile = [SELECT Id FROM Profile WHERE Name='Customer Community User(Custom)']; 
            tUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = tProfile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_test@testorg.com', 
                             ContactId = tContact.Id, IsActive = true);
            insert tUser ;
            System.debug('*** positiveDeactivateUserTest: tUser: ' + tUser) ;
        }
        
        // setup the user that we are going to be testing with. It's a standard user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard YPO MTM']; 
        User u = new User(Alias = 'standn', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_new@testorg.com');
        insert u;
        insert new ContactShare(UserOrGroupId = u.id,
                                ContactAccessLevel = 'Edit',
                                ContactId = tContact.id);
        // This begins the real test. The rest is setup of users, accounts and contacts.
        System.runAs(u) {
            Test.startTest(); 
            tContact.Membership_Status__c = 'Resigned' ;
            update tContact ;
            Test.stopTest();
        }
        tUser = getUser(tUser.Id) ;
        System.assertEquals(false, tUser.IsActive, 'User is not deactivated. Problem in test.') ;
    }
    
    /**
* @desc Test user not needing to be deactivated
*/
    @isTest static void negativeDeactivateUserTestNoHouseHold() {
        UserRole oRole ;
        Profile oProfile ;
        User oUser ;
        
        User curUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()] ;
        
        // to avoid mixed DML calls run the user creat in another context
        // Create the portal account owner as a standard user
        System.runAs(curUser) {
            oRole = [SELECT Id FROM UserRole WHERE Name = 'YPO'] ;
            oProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            oUser = new User(Alias = 'stando', Email='standarduser@testorg.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = oProfile.Id, UserRoleId = oRole.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_owner@testorg.com', 
                             IsActive = true);
            insert oUser ;
        }
        
        // Create the account for the portal users
        Account tAccount = TestServices.createAccount('TestAcc');
        tAccount.OwnerId = oUser.Id ;
        insert tAccount;
        System.debug('*** positiveDeactivateUserTest: tAccount: ' + tAccount) ;
        
        // Create the contact the portal user will be linked to
        Contact tContact = TestServices.createContact(tAccount.Id);
        tContact.Membership_Status__c = 'Member' ;
        insert tContact;
        System.debug('*** positiveDeactivateUserTest: tContact: ' + tContact) ;
        
        Profile tProfile ;
        User tUser ;
        
        // to avoid mixed DML calls run the user creat in another context
        System.runAs(curUser) {
            tProfile = [SELECT Id FROM Profile WHERE Name='Customer Community User(Custom)']; 
            tUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = tProfile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_test@testorg.com', 
                             ContactId = tContact.Id, IsActive = true);
            insert tUser ;
            System.debug('*** positiveDeactivateUserTest: tUser: ' + tUser) ;
        }
        
        // setup the user that we are going to be testing with. It's a standard user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standn', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_new@testorg.com');
        insert u;
        insert new ContactShare(UserOrGroupId = u.id,
                                ContactAccessLevel = 'Edit',
                                ContactId = tContact.id);
        // This begins the real test. The rest is setup of users, accounts and contacts.
        System.runAs(u) {
            system.Test.startTest(); 
            tContact.Membership_Status__c = 'Rejected' ;
            update tContact ;
            system.Test.stopTest();
        }
        tUser = getUser(tUser.Id) ;
        System.assertEquals(true, tUser.IsActive, 'User is not active. Problem in test.') ;
    }
    
    @isTest static void positiveDeactivateUserTestSpouse() {
        UserRole oRole ;
        Profile oProfile ;
        User oUser ;
        
        User curUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()] ;
        
        // to avoid mixed DML calls run the user creat in another context
        // Create the portal account owner as a standard user
        System.runAs(curUser) {
            oRole = [SELECT Id FROM UserRole WHERE Name = 'YPO'] ;
            oProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            oUser = new User(Alias = 'stando', Email='standarduser@testorg.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = oProfile.Id, UserRoleId = oRole.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_owner@testorg.com', 
                             IsActive = true);
            insert oUser ;
        }
        
        // Create the account for the portal users
        Account tAccount = TestServices.createAccount('TestAcc');
        tAccount.OwnerId = oUser.Id ;
        insert tAccount;
        Account tAccount1 = TestServices.createAccount('HouseAcc');
        tAccount1.type = 'Relationship' ;
        insert tAccount1;
        System.debug('*** positiveDeactivateUserTest: tAccount: ' + tAccount) ;
        
        // Create the contact the portal user will be linked to
        Contact tContact = TestServices.createContact(tAccount.Id);
        tContact.Membership_Status__c = 'Member' ;
        insert tContact;
        System.debug('*** positiveDeactivateUserTest: tContact: ' + tContact) ;
        
        // Household created for the contact
        /*String householdId = [
SELECT
HouseholdID__c
FROM Contact
WHERE Id = :tContact.Id LIMIT 1
].HouseholdID__c ;*/
        
        // Create the contact the spouse portal user will be linked to
        Contact sContact = TestServices.createContact(tAccount.Id);
        sContact.Membership_Status__c = 'Member' ;
        sContact.Portal_Access_Level__c = 'Full' ;
        insert sContact;
        System.debug('*** positiveDeactivateUserTest: sContact: ' + sContact) ;
        
        Relationship__c rel = new Relationship__c(Account__c = tAccount1.Id, 
                                                  Contact__c = sContact.Id, 
                                                  Relationship_Type__c = 'Spouse/Partner',
                                                  Is_Active__c = true
                                                 ) ;
        insert rel ;
        
        Profile tProfile ;
        User tUser ;
        
        // to avoid mixed DML calls run the user creat in another context
        System.runAs(curUser) {
            tProfile = [SELECT Id FROM Profile WHERE Name='Customer Community User(Custom)']; 
            tUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = tProfile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_test@testorg.com', 
                             ContactId = tContact.Id, IsActive = true);
            insert tUser ;
            System.debug('*** positiveDeactivateUserTest: tUser: ' + tUser) ;
        }
        
        // setup the user that we are going to be testing with. It's a standard user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standn', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_new@testorg.com');
        insert u;
        insert new ContactShare(UserOrGroupId = u.id,
                                ContactAccessLevel = 'Edit',
                                ContactId = tContact.id);
        // This begins the real test. The rest is setup of users, accounts and contacts.
        System.runAs(u) {
            system.Test.startTest(); 
            tContact.Membership_Status__c = 'Resigned' ;
            update tContact ;
            system.Test.stopTest();
        }
        sContact = getContact(sContact.Id) ;
        //System.assertEquals('None', sContact.Portal_Access_Level__c, 'Contact access not revoked. Problem in test.') ;
        rel = [
            SELECT
            Account__c,
            Contact__c,
            Relationship_Type__c,
            Is_Active__c
            FROM Relationship__c
            WHERE Id = :rel.Id
        ] ;
        //System.assertEquals(false, rel.Is_Active__c, 'Relationship not deactivate. Problem in test.') ;
    }
    
    private static Contact getContact(Id contactId)
    {
        return [
            SELECT 
            GUID__c,
            Portal_Access_Level__c
            FROM Contact 
            WHERE Id = :contactId
        ]; 
    }
    
    private static User getUser(Id userId)
    {
        return [
            SELECT 
            IsActive
            FROM User
            WHERE Id = :userId
        ] ; 
    }
}