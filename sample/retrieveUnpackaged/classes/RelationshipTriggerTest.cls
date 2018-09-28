@isTest
public class RelationshipTriggerTest {
    static final String CONST_SPOUSE = 'Spouse/Partner';
    static Account oAccountHousehold;
    static Contact oContact1;
    static Contact oContact2;
    
    private static void setup(){
        Account oAccount = TestServices.createAccount('AdditonalDataFormContact');
        insert oAccount;
        
        oContact1 = TestServices.createContact(oAccount.Id);
        insert oContact1;   
        
        oContact2 = TestServices.createContact(oAccount.Id);
        insert oContact2;   
        
        oAccountHousehold = TestServices.createAccount('AdditonalDataFormContact-Household');
        oAccountHousehold.Type = 'Relationship';
        insert oAccountHousehold;
        
        Relationship__c oRelationship = TestServices.createRelationship(oContact1.Id, oAccountHousehold.Id, CONST_SPOUSE, true , true);
    }
    
    
    public static testMethod void testToRestrictMoreThanOneActiveSpouseOnInsert(){
        setup();
        Test.startTest();
        try{
            Relationship__c oRelationship2 = TestServices.createRelationship(oContact2.Id, oAccountHousehold.Id, CONST_SPOUSE, true , true); 
            system.assert(false, 'Exception should have been thrown');
        }
        catch(Exception e)
        {
            String xpectedExceptionThrown =  e.getMessage();
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.Duplicate_Spouse_Error_Message) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    public static testMethod void testToRestrictMoreThanOneActiveSpouseOnUpdate(){
        setup();
        Relationship__c oRelationship2 = TestServices.createRelationship(oContact2.Id, oAccountHousehold.Id, CONST_SPOUSE, false, true); 
        Test.startTest();
        try{
            oRelationship2.Is_Active__c = true;
            update oRelationship2;
            system.assert(false, 'Exception should have been thrown');
        }
        catch(Exception e)
        {
            String xpectedExceptionThrown =  e.getMessage();
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.Duplicate_Spouse_Error_Message) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
}