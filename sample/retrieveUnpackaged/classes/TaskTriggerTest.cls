@isTest
public class TaskTriggerTest {
    public static Task testTask;
    public static User testUser;
    private static void setup() {
    }
    @isTest
    public static void givenUserWithNoAccess_whenTaskIsDeleted_thenValidationError(){
        testTask = new Task(Subject='Test',
                            Status='Not Started',
                            Priority='Normal');
        insert testTask;
        User u = new User(id=userinfo.getUserId(), Able_to_Delete_Activities__c = false);
        update u;
        Test.startTest();
        System.runAs(u){
            try {
                delete testTask;
            } catch (DmlException dEx) {
                system.assert(dEx.getMessage().contains(Label.Cant_Delete_Task), 'Exception should have been thrown as user doesn`t have delete permissions');
            }
        }
        Test.stopTest();
    }
    @isTest
    public static void givenUserWithAccess_whenTaskIsDeleted_thenNoValidationError(){
        testTask = new Task(Subject='Test',
                            Status='Not Started',
                            Priority='Normal');
        insert testTask;
        User u = new User(id=userinfo.getUserId(), Able_to_Delete_Activities__c = true);
        update u;
        Test.startTest();
        System.runAs(u){
            try {
                delete testTask;
            } catch (DmlException dEx) {
                system.assert(false, 'No Exception should have been thrown as user have the delete permissions');
            }
        }
        Test.stopTest();
    }
}