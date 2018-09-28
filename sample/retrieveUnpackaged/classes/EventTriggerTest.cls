@isTest
public class EventTriggerTest {
    public static Event testEvent;
    public static User testUser;
    private static void setup() {
    }
    @isTest
    public static void givenUserWithNoAccess_whenTaskIsDeleted_thenValidationError(){
        testEvent = new Event(Subject='Test', 
        						DurationInMinutes = 1, 
        						ActivityDateTime = System.now());
        insert testEvent;
        User u = new User(id=userinfo.getUserId(), Able_to_Delete_Activities__c = false);
        update u;
        Boolean exceptionThrown = false;
        Test.startTest();
        System.runAs(u){
            try {
                delete testEvent;
            } catch (DmlException dEx) {
            	exceptionThrown=true;
                system.assert(dEx.getMessage().contains(Label.Cant_Delete_Task), 'Exception should have been thrown as user doesn`t have delete permissions');
            }
        }
        Test.stopTest();
    	System.assert(exceptionThrown, 'We expect the exception message to be thrown if the user does not have delete permissions');
    
    }
    @isTest
    public static void givenUserWithAccess_whenTaskIsDeleted_thenNoValidationError(){
        testEvent = new Event(Subject='Test', 
        						DurationInMinutes = 1,
        						ActivityDateTime = System.now());
        insert testEvent;
        User u = new User(id=userinfo.getUserId(), Able_to_Delete_Activities__c = true);
        update u;
        Boolean exceptionThrown = false;
        Test.startTest();
        System.runAs(u){
            try {
                delete testEvent;
            } catch (DmlException dEx) {
            	exceptionThrown = true;
                system.assert(false, 'No Exception should have been thrown as user have the delete permissions');
            }
        }
        Test.stopTest();
        System.assert(!exceptionThrown, 'We expect no exception message to be thrown if the user has activity delete permissions');
        
    }
}