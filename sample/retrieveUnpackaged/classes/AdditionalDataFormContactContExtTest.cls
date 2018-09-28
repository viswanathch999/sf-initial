/**
* "Given" defines the preconditions, "When" defines what happens, and 
* "Then" defines the result of the scenario. Or in other words: 
* "Given" describes the start state, and "When" the steps 
* necessary to reach the accepting state (= "Then").
* AdditionalDataFormContactContExtTest is serving as test class for AdditionalDataFormContactContExt class and its methods.
* 
* @author: Shri K
*/
@isTest
private class AdditionalDataFormContactContExtTest {
    static String CONST_CONTACT = 'Contact';
    static  String CONST_SPOUSE = 'Spouse_Partner';
    static  String CONST_Relationship = 'Relationship';
    static String CONST_Account = 'Account';
    static Id spouseRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_SPOUSE, CONST_CONTACT).Id;
    static Id relationshipRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_Relationship, CONST_Account).Id;
    
    static testMethod void givenContactSpouseChild_WhenSaveCalled_thenContactChildSpouseSavedtoDB() {
        
        Account oAccount = TestServices.createAccount('AdditonalDataFormContact');
        insert oAccount;
        
        Contact oContact = TestServices.createContact(oAccount.Id);
        insert oContact;   
        
        Account oAccountHousehold = TestServices.createAccount('AdditonalDataFormContact-Household');
        oAccountHousehold.Type = 'Relationship';
        insert oAccountHousehold;
        
        Relationship__c oRelationship = TestServices.createRelationship(oContact.Id, oAccountHousehold.Id, 'Spouse');
        insert oRelationship;
        
        List<Relationship__c> lstRelationship = [SELECT Id, Account__c, Contact__c, Relationship_Type__c FROM Relationship__c]; 
        //system.assertEquals(2, lstRelationship.size()); // There will be 2 Relationship on insert considering reverse 
        
        Set<Id> existingRelationshipId = new Set<Id>();
        for(Relationship__c r: lstRelationship){
            existingRelationshipId.add(r.Id);
        }
        
        Apexpages.StandardController oStandardContactCon = new Apexpages.StandardController(oContact);
        AdditionalDataFormContactContExt oAdditionalDataFormContactContExt = new AdditionalDataFormContactContExt(oStandardContactCon);
        oAdditionalDataFormContactContExt.addSpouse();
        oAdditionalDataFormContactContExt.addChild();
        oAdditionalDataFormContactContExt.lstSpouse[0].FirstName = 'FN';
        oAdditionalDataFormContactContExt.lstSpouse[0].LastName = 'LN';
        oAdditionalDataFormContactContExt.lstSpouse[0].Email = 'test@test.com';
       
        oAdditionalDataFormContactContExt.lstSpouse[0].Gender__c = 'Male';
        oAdditionalDataFormContactContExt.lstSpouse[0].Birthdate = System.today().addDays(-8);
        
        oAdditionalDataFormContactContExt.lstChild[0].FirstName = 'FN';
        oAdditionalDataFormContactContExt.lstChild[0].LastName = 'LN';
        oAdditionalDataFormContactContExt.lstChild[0].Email = 'test1@test.com';
        oAdditionalDataFormContactContExt.lstSpouse[0].Gender__c = 'Male';
        oAdditionalDataFormContactContExt.lstSpouse[0].Birthdate = System.today().addDays(-7);
        // oAdditionalDataFormContactContExt.getRelationshipForMember(); // Added on 20 Feb 2016
        
        Test.startTest();
        oAdditionalDataFormContactContExt.saveSpouseAndChild();
        Test.stopTest();
        
        List<Contact> lstContact = [SELECT Id FROM Contact WHERE Id != :oContact.Id];
        system.assertEquals(2, lstContact.size());
        
        List<Relationship__c> lstRelationshipTest = [SELECT Account__c, Contact__c, Relationship_Type__c FROM Relationship__c where Id !=:existingRelationshipId]; 
        system.assertEquals(2, lstRelationshipTest.size());
        
    }
    
    static testMethod void givenContact_WhenSaveCalled_thenAccountAffiliationSavedtoDB() {
        
        Account oAccount = TestServices.createAccount('AdditonalDataFormContact');
        insert oAccount;
        
        Account oAccountForAffiliation = TestServices.createAccount('AdditonalDataFormContact');
        oAccountForAffiliation.Type = 'Network';
        oAccountForAffiliation.Category__c = 'Business';
        insert oAccountForAffiliation;
        
        Contact oContact = TestServices.createContact(oAccount.Id);
        insert oContact;   
        Account oTestAccount = TestServices.createAccount('AdditonalDataFormTestContact');
        oTestAccount.RecordTypeId = relationshipRecordTypeId;
        insert oTestAccount;
        Contact oTestContact = TestServices.createContact(oAccount.Id);
        oTestContact.FirstName = 'Test';
        oTestContact.LastName = 'Contact';
        oTestContact.Gender__c = 'Male';
        oTestContact.Email = 'test@gmail.com';
        oTestContact.RecordTypeId = spouseRecordTypeId;
        oTestContact.Birthdate = System.today().addDays(-8);
        insert oTestContact;
        Relationship__c rel = TestServices.createRelationship(oContact.Id, oTestAccount.Id, 'Spouse/Partner', true, true);
        
        Apexpages.StandardController oStandardContactCon = new Apexpages.StandardController(oContact);
        AdditionalDataFormContactContExt oAdditionalDataFormContactContExt = new AdditionalDataFormContactContExt(oStandardContactCon);
        
        Test.startTest();
        oAdditionalDataFormContactContExt.oAccountAffiliation.Account__c = oAccountForAffiliation.Id; 
        oAdditionalDataFormContactContExt.calcDisabledFlag();
        oAdditionalDataFormContactContExt.saveSpouseAndChild();
        Test.stopTest();
        
        //Account_Affiliation__c oAccAffiliation = [SELECT Id, Account__c, Contact__c FROM Account_Affiliation__c];
        //system.assertEquals(oContact.Id, oAccAffiliation.Contact__c);
        //system.assertEquals(oAccountForAffiliation.Id, oAccAffiliation.Account__c);
        
    }
    
    static testMethod void givenContactSpouseChild_WhenSpouseRemoved_thenSpouseRemovedFromlist() {
        
        Account oAccount = TestServices.createAccount('AdditonalDataFormContact');
        insert oAccount;
        
        Contact oContact = TestServices.createContact(oAccount.Id);
        insert oContact;   
        
        Account oAccountHousehold = TestServices.createAccount('AdditonalDataFormContact-Household');
        oAccountHousehold.Type = 'Relationship';
        insert oAccountHousehold;
        
        Relationship__c oRelationship = TestServices.createRelationship(oContact.Id, oAccountHousehold.Id, 'Spouse');
        insert oRelationship;
        
        Apexpages.StandardController oStandardContactCon = new Apexpages.StandardController(oContact);
        AdditionalDataFormContactContExt oAdditionalDataFormContactContExt = new AdditionalDataFormContactContExt(oStandardContactCon);
        oAdditionalDataFormContactContExt.addSpouse();
        oAdditionalDataFormContactContExt.lstSpouse[0].FirstName = 'FN';
        oAdditionalDataFormContactContExt.lstSpouse[0].LastName = 'LN';
        oAdditionalDataFormContactContExt.lstSpouse[0].Email = 'test@test.com';
        
        oAdditionalDataFormContactContExt.addSpouse();
        oAdditionalDataFormContactContExt.lstSpouse[0].FirstName = 'FN';
        oAdditionalDataFormContactContExt.lstSpouse[0].LastName = 'LN';
        oAdditionalDataFormContactContExt.lstSpouse[0].Email = 'test1@test.com';
        
        oAdditionalDataFormContactContExt.addChild();
        oAdditionalDataFormContactContExt.lstChild[0].FirstName = 'FN';
        oAdditionalDataFormContactContExt.lstChild[0].LastName = 'LN';
        oAdditionalDataFormContactContExt.lstChild[0].Email = 'test1@test.com';        
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('rowNumber', '0'); // As there could not be multiple spouse row in list
        oAdditionalDataFormContactContExt.removeSpouse();
        Test.stopTest();
        
        system.assertEquals(null, oAdditionalDataFormContactContExt.lstSpouse); // Since there is only one spouse & thats even removed so list will be null
        system.assertEquals(1, oAdditionalDataFormContactContExt.lstChild.size());
        
    }
    
    static testMethod void givenContactSpouseChild_WhenChildRemoved_thenChildRemovedFromlist() {
        
        Account oAccount = TestServices.createAccount('AdditonalDataFormContact');
        insert oAccount;
        
        Contact oContact = TestServices.createContact(oAccount.Id);
        insert oContact;   
        
        Account oAccountHousehold = TestServices.createAccount('AdditonalDataFormContact-Household');
        oAccountHousehold.Type = 'Relationship';
        insert oAccountHousehold;
        
        Relationship__c oRelationship = TestServices.createRelationship(oContact.Id, oAccountHousehold.Id, 'Spouse');
        insert oRelationship;
        
        Apexpages.StandardController oStandardContactCon = new Apexpages.StandardController(oContact);
        AdditionalDataFormContactContExt oAdditionalDataFormContactContExt = new AdditionalDataFormContactContExt(oStandardContactCon);
        oAdditionalDataFormContactContExt.addSpouse();
        oAdditionalDataFormContactContExt.lstSpouse[0].FirstName = 'FN';
        oAdditionalDataFormContactContExt.lstSpouse[0].LastName = 'LN';
        oAdditionalDataFormContactContExt.lstSpouse[0].Email = 'test@test.com';
        
        oAdditionalDataFormContactContExt.addChild();
        oAdditionalDataFormContactContExt.lstChild[0].FirstName = 'FN';
        oAdditionalDataFormContactContExt.lstChild[0].LastName = 'LN';
        oAdditionalDataFormContactContExt.lstChild[0].Email = 'test1@test.com';
        
        oAdditionalDataFormContactContExt.addChild();
        oAdditionalDataFormContactContExt.lstChild[0].FirstName = 'FN';
        oAdditionalDataFormContactContExt.lstChild[0].LastName = 'LN';
        oAdditionalDataFormContactContExt.lstChild[0].Email = 'test1@test.com';
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('rowNumber', '1');
        oAdditionalDataFormContactContExt.removeChild();
        Test.stopTest();
        
        system.assertEquals(1, oAdditionalDataFormContactContExt.lstSpouse.size());
        system.assertEquals(1, oAdditionalDataFormContactContExt.lstChild.size());
        
    }
    
    static testMethod void givenContactSpouseChild_WhenAllChildSpouseRemoved_thenChildSpouselistWillbeNull() {
        
        Account oAccount = TestServices.createAccount('AdditonalDataFormContact');
        insert oAccount;
        
        Contact oContact = TestServices.createContact(oAccount.Id);
        insert oContact;   
        
        Account oAccountHousehold = TestServices.createAccount('AdditonalDataFormContact-Household');
        oAccountHousehold.Type = 'Relationship';
        insert oAccountHousehold;
        
        Relationship__c oRelationship = TestServices.createRelationship(oContact.Id, oAccountHousehold.Id, 'Spouse');
        insert oRelationship;
        
        Apexpages.StandardController oStandardContactCon = new Apexpages.StandardController(oContact);
        AdditionalDataFormContactContExt oAdditionalDataFormContactContExt = new AdditionalDataFormContactContExt(oStandardContactCon);
        oAdditionalDataFormContactContExt.addSpouse();
        oAdditionalDataFormContactContExt.lstSpouse[0].FirstName = 'FN';
        oAdditionalDataFormContactContExt.lstSpouse[0].LastName = 'LN';
        oAdditionalDataFormContactContExt.lstSpouse[0].Email = 'test@test.com';
        
        oAdditionalDataFormContactContExt.addChild();
        oAdditionalDataFormContactContExt.lstChild[0].FirstName = 'FN';
        oAdditionalDataFormContactContExt.lstChild[0].LastName = 'LN';
        oAdditionalDataFormContactContExt.lstChild[0].Email = 'test1@test.com';
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('rowNumber', '0');
        oAdditionalDataFormContactContExt.removeChild();
        
        ApexPages.currentPage().getParameters().put('rowNumber', '0');
        oAdditionalDataFormContactContExt.removeSpouse();
        Test.stopTest();
        
        system.assertEquals(null, oAdditionalDataFormContactContExt.lstSpouse);
        system.assertEquals(null, oAdditionalDataFormContactContExt.lstChild);
        
    }
    
    static testMethod void givenNoRelationshipToMember_WhenAddedSpouse_thenErrorShown() {
        
        Account oAccount = TestServices.createAccount('AdditonalDataFormContact');
        insert oAccount;
        
        Contact oContact = TestServices.createContact(oAccount.Id);
        insert oContact;   
        Account oTestAccount = TestServices.createAccount('AdditonalDataFormTestContact');
        oTestAccount.RecordTypeId = relationshipRecordTypeId;
        insert oTestAccount;
        Id childRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Child', 'Contact').Id;
        Contact oTestContact = TestServices.createContact(oAccount.Id);
       // oTestContact.FirstName = 'Test';
        oTestContact.LastName = 'Contact';
        oTestContact.Gender__c = 'Male';
        //oTestContact.Email = 'test@gom';
        oTestContact.RecordTypeId = childRecordTypeId;
        oTestContact.Birthdate = System.today().addDays(-8);
       // insert oTestContact;
        Relationship__c rel = TestServices.createRelationship(oContact.Id, oTestAccount.Id, 'Spouse/Partner', true, true);
        Apexpages.StandardController oStandardContactCon = new Apexpages.StandardController(oContact);
        AdditionalDataFormContactContExt oAdditionalDataFormContactContExt = new AdditionalDataFormContactContExt(oStandardContactCon);
        
        Test.startTest();
        oAdditionalDataFormContactContExt.addSpouse();
        oAdditionalDataFormContactContExt.lstSpouse[0].FirstName = 'FN';
        oAdditionalDataFormContactContExt.lstSpouse[0].LastName = 'LN';
        oAdditionalDataFormContactContExt.lstSpouse[0].Email = 'test@';
        
        oAdditionalDataFormContactContExt.saveSpouseAndChild();
        Test.stopTest();
        
        system.assertEquals(1, oAdditionalDataFormContactContExt.lstSpouse.size()); // One Spouse record will be added to list as error will be thrown on insert
        
        List<Contact> lstContact = [SELECT Id FROM Contact WHERE Id != :oContact.Id And RecordTypeId != :spouseRecordTypeId];
        system.assertEquals(0, lstContact.size());        // There wont be any spouse inserted as data is incorrect
    }
    
    static testMethod void givenNullContact_WhenLoadedPage_thenExceptionThrown() {
        
        Account oAccount = TestServices.createAccount('AdditonalDataFormContact');
        insert oAccount;
        
        Contact oContact = new Contact();  
        
        Apexpages.StandardController oStandardContactCon = new Apexpages.StandardController(oContact);
        
        Test.startTest();
        try{
            AdditionalDataFormContactContExt oAdditionalDataFormContactContExt = new AdditionalDataFormContactContExt(oStandardContactCon);     
            system.assert(false);
        }catch(Exception oException){
            
            system.assertEquals(Label.Id_Not_Present, oException.getMessage()); 
        }
        Test.stopTest();
    }
    
    static testMethod void givenInvalidEmailId_WhenSaveChildCalled_thenError() {
        
        Account oAccount = TestServices.createAccount('AdditonalDataFormContact');
        insert oAccount;
        
        Contact oContact = TestServices.createContact(oAccount.Id);
        insert oContact;   
        
        Account oAccountHousehold = TestServices.createAccount('AdditonalDataFormContact-Household');
        oAccountHousehold.Type = 'Relationship';
        insert oAccountHousehold;
        
        Relationship__c oRelationship = TestServices.createRelationship(oContact.Id, oAccountHousehold.Id, 'Spouse');
        insert oRelationship;
        
        Apexpages.StandardController oStandardContactCon = new Apexpages.StandardController(oContact);
        AdditionalDataFormContactContExt oAdditionalDataFormContactContExt = new AdditionalDataFormContactContExt(oStandardContactCon);
        
        oAdditionalDataFormContactContExt.addChild();
        oAdditionalDataFormContactContExt.lstChild[0].FirstName = 'FN';
        oAdditionalDataFormContactContExt.lstChild[0].LastName = 'LN';
        oAdditionalDataFormContactContExt.lstChild[0].Email = 'test134';
        
        Test.startTest();
        oAdditionalDataFormContactContExt.saveSpouseAndChild();
        Test.stopTest();
        
        List<Contact> lstContact = [SELECT Id FROM Contact WHERE Id != :oContact.Id ];
        system.assertEquals(0, lstContact.size());
        
    }
    static testMethod void TestRequiredAllSchoolFieldsNotPopulated(){
        Account oAccount = TestServices.createAccount('AdditonalDataFormContact');
        insert oAccount;
        
        Contact oContact = TestServices.createContact(oAccount.Id);
        insert oContact;   
        Account oTestAccount = TestServices.createAccount('AdditonalDataFormTestContact');
        oTestAccount.RecordTypeId = relationshipRecordTypeId;
        insert oTestAccount;
        Contact oTestContact = TestServices.createContact(oAccount.Id);
        oTestContact.FirstName = 'Test';
        oTestContact.LastName = 'Contact';
        oTestContact.Gender__c = 'Male';
        oTestContact.Email = 'test@gmail.com';
        oTestContact.RecordTypeId = spouseRecordTypeId;
        oTestContact.Birthdate = System.today().addDays(-8);
        insert oTestContact;
        Relationship__c rel = TestServices.createRelationship(oContact.Id, oTestAccount.Id, 'Spouse/Partner', true, true);
        Apexpages.StandardController oStandardContactCon = new Apexpages.StandardController(oContact);
        AdditionalDataFormContactContExt oAdditionalDataFormContactContExt = new AdditionalDataFormContactContExt(oStandardContactCon);
        try
        {
            oAdditionalDataFormContactContExt.oContact.school_name__c = 'SchoolTest';
            oAdditionalDataFormContactContExt.saveSpouseAndChild();
        }
        catch (Exception e) {
            System.assert(e.getMessage().contains('If School Name is populated then please fill up other school fields too'), 'message=' + e.getMessage());
        }
    }
    
    static testMethod void TestRequiredAllSchoolFieldsPopulated(){
        Account oAccount = TestServices.createAccount('AdditonalDataFormContact');
        insert oAccount;
        
        Contact oContact = TestServices.createContact(oAccount.Id);
        insert oContact;   
        Account oTestAccount = TestServices.createAccount('AdditonalDataFormTestContact');
        oTestAccount.RecordTypeId = relationshipRecordTypeId;
        insert oTestAccount;
        Contact oTestContact = TestServices.createContact(oAccount.Id);
        oTestContact.FirstName = 'Test';
        oTestContact.LastName = 'Contact';
        oTestContact.Gender__c = 'Male';
        oTestContact.Email = 'test@gmail.com';
        oTestContact.RecordTypeId = spouseRecordTypeId;
        oTestContact.Birthdate = System.today().addDays(-8);
        insert oTestContact;
        Relationship__c rel = TestServices.createRelationship(oContact.Id, oTestAccount.Id, 'Spouse/Partner', true, true);
        Apexpages.StandardController oStandardContactCon = new Apexpages.StandardController(oContact);
        AdditionalDataFormContactContExt oAdditionalDataFormContactContExt = new AdditionalDataFormContactContExt(oStandardContactCon);
        
        oAdditionalDataFormContactContExt.oContact.school_name__c = 'SchoolTest';
        oAdditionalDataFormContactContExt.oContact.School_Type__c = 'High School';
        oAdditionalDataFormContactContExt.oContact.Degree_Type__c = 'AA';
        oAdditionalDataFormContactContExt.oContact.Field_of_Study__c = 'Science';
        oAdditionalDataFormContactContExt.oContact.Graduation_Year__c = '2016';
        oAdditionalDataFormContactContExt.oContact.School_City__c = 'Mumbai';
        oAdditionalDataFormContactContExt.oContact.School_State__c = 'Maharashtra';
        oAdditionalDataFormContactContExt.oContact.School_Country__c = 'India';
        oAdditionalDataFormContactContExt.saveSpouseAndChild();
        Account acc =[Select id, Name from Account where name =: 'SchoolTest'];
        System.assertEquals('SchoolTest', acc.Name);
        //Account_Affiliation__c aff =[Select id, account__c from Account_Affiliation__c where account__c =:acc.id ];
    }
    static testMethod void TestSchoolAccountLookup(){
        Account oAccount = TestServices.createAccount('AdditonalDataFormContact');
        insert oAccount;
        Contact oContact = TestServices.createContact(oAccount.Id);
        insert oContact;
     	 Account oTestAccount = TestServices.createAccount('AdditonalDataFormTestContact');
        oTestAccount.RecordTypeId = relationshipRecordTypeId;
        insert oTestAccount;
        Contact oTestContact = TestServices.createContact(oAccount.Id);
        oTestContact.FirstName = 'Test';
        oTestContact.LastName = 'Contact';
        oTestContact.Gender__c = 'Male';
        oTestContact.Email = 'test@gmail.com';
        oTestContact.RecordTypeId = spouseRecordTypeId;
        oTestContact.Birthdate = System.today().addDays(-8);
        insert oTestContact;
        Relationship__c rel = TestServices.createRelationship(oContact.Id, oTestAccount.Id, 'Spouse/Partner', true, true);
        Apexpages.StandardController oStandardContactCon = new Apexpages.StandardController(oContact);
        AdditionalDataFormContactContExt oAdditionalDataFormContactContExt = new AdditionalDataFormContactContExt(oStandardContactCon);
        RecordType schoolRecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName = 'School'];
        Account schoolAccount = TestServices.createAccount('SchoolAccount');
        schoolAccount.RecordTypeId = schoolRecType.Id;
        insert schoolAccount;
        try{
            oAdditionalDataFormContactContExt.oContact.school__c = schoolAccount.Id;
            oAdditionalDataFormContactContExt.saveSpouseAndChild();
        }
        catch (Exception e) {
            System.assert(e.getMessage().contains('Field of Study'), 'message=' + e.getMessage());
            System.debug('Required field errors'+ e.getMessage());
        }
    }
}