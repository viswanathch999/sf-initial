/**
 * DatabaseDAOStrategyTest class contains unit tests for validating the behavior of 
 * DatabaseDAOStrategy
 *
 * "Given" defines the preconditions, "When" defines what happens, and 
 * "Then" defines the result of the scenario. Or in other words: 
 * "Given" describes the start state, and "When" the steps 
 * necessary to reach the accepting state (= "Then").
 *
 * @author Naveen Hiremath
 */
@isTest
public class DatabaseDAOStrategyTest {
    
    private static final List<SObjectModel> accountModels;
    private static final databaseDAOStrategy database;
    static {
        accountModels = new List<SObjectModel>();
        SObjectModelMock mockAccount = new SObjectModelMock(
                                   new Account(Name='DatabaseDAOStrategyTest Mock'));
        accountModels.add(mockAccount);
        
        database = (databaseDAOStrategy)DAOStrategyFactory.getInstance(
                                                DAOStrategyType.DatabaseDAOStrategy, 
                                                Account.SObjectType);
    }
    
    @isTest
    public static void givenNullSObject_whenNewModel_thenThrowException() {
        SObjectModel.ModelException modelException;
        
        Test.startTest();
        try{
            SObjectModelMock mockModel = new SObjectModelMock(null);
        } catch(SObjectModel.ModelException e) {
            modelException = e;
        }
        
        System.assertNotEquals(null, modelException, 'An exception should be ' +
                            'thrown when null sobject is used to create a model.');  
        /*System.assertEquals('Sobject is required for model instantiaton.', 
                            modelException.getMessage(), 'A thrown ' +
                            'exception should have a message.');*/
        Test.stopTest();
    }
    
    @isTest
    public static void givenModelsAndFieldsToSet_whenCreated_thenAccountsShouldBeInserted() {
        final List<Schema.SObjectField> fieldsToSet = 
                                    new List<Schema.SObjectField>{Account.Name};
        
        Test.startTest();
        accountModels[0].record.put('Name', 'DatabaseDAOStrategyTest Mock Changed');
        List<Database.SaveResult> createResult = database.create(accountModels, 
                                                            fieldsToSet);
        
        System.assertNotEquals(null, createResult, 'Database method returns save result');        
        System.assertEquals(1, getAccountCount('databaseDAOStrategyTest Mock Changed'),
                                         'Inserted record should be available');
        /*System.assertEquals(true, accountModels.get(0).isCommitted(), 
            'isCommitted() should return true');*/
        System.assertNotEquals(null, accountModels.get(0).toJSON(), 
            'toJSON() on a record should not be null');
        System.assertNotEquals(null, accountModels.get(0).toString(), 
            'toString() on a record should not be null');                
        Test.stopTest();    
        
    }
    
    @isTest
    public static void givenNullModelsAndFieldsToSet_whenCreated_thenThrowException() {
        final List<Schema.SObjectField> fieldsToSet = 
                                    new List<Schema.SObjectField>{Account.Name};
        SObjectDAO.DAOException genericException;
                
        Test.startTest();
        try {
            database.create(null, fieldsToSet);
        } catch(SObjectDAO.DAOException daoException) {
            genericException = daoException;
        }
        
        System.assert(genericException instanceof SObjectDAO.InvalidArgumentException,
                 'InvalidArgumentException should fire when models is null');
        Test.stopTest();                            
        
    }
    
    @isTest
    public static void givenEmptyModelsAndFieldsToSet_whenCreated_thenThrowException() {
        final List<Schema.SObjectField> fieldsToSet = 
                                    new List<Schema.SObjectField>{Account.Name};
        SObjectDAO.DAOException genericException;
        
        accountModels.clear(); //empty models
        
        Test.startTest();
        try {
            database.create(accountModels, fieldsToSet);
        } catch(SObjectDAO.DAOException daoException) {
            genericException = daoException;
        }
        
        System.assert(genericException instanceof SObjectDAO.InvalidArgumentException,
                 'InvalidArgumentException should fire when models is empty');
        Test.stopTest();                            
        
    }
    
    @isTest
    public static void givenModelsAndNullFieldsToSet_whenCreated_thenThrowException() {
        SObjectDAO.DAOException genericException;
        Test.startTest();
        try {
            database.create(accountModels, null);
        } catch(SObjectDAO.DAOException daoException) {
            genericException = daoException;
        }
        
        System.assert(genericException instanceof SObjectDAO.InvalidArgumentException, 
             'InvalidArgumentException should fire when fields to set is null');
        Test.stopTest();                            
        
    }
    
    @isTest
    public static void givenModelsAndEmptyFieldsToSet_whenCreated_thenThrowException() {
        final List<Schema.SObjectField> fieldsToSet = 
                                    new List<Schema.SObjectField>();
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        try {
            database.create(accountModels, fieldsToSet);
        } catch(SObjectDAO.DAOException daoException) {
            genericException = daoException;
        }
        
        System.assert(genericException instanceof SObjectDAO.InvalidArgumentException, 
            'InvalidArgumentException should fire when fields to set is empty');
        Test.stopTest();                            
        
    }
    
    @isTest
    public static void givenModelsAndFieldsToSet_whenCreatedAsReadOnly_thenThrowException() {
       final List<Schema.SObjectField> fieldsToSet = 
                                    new List<Schema.SObjectField>{Account.Name};
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        accountModels[0].record.put('Name', 'DatabaseDAOStrategyTest Mock Changed');
        final User readOnlyUser = getTestUser('Read Only');
        System.runAs(readOnlyUser) {
            try {
                new databaseDAOStrategy(Account.SObjectType).create(accountModels, fieldsToSet);
            } catch(SObjectDAO.DAOException daoException) {
                genericException = daoException;
            }
        
            System.assert(genericException instanceof SObjectDAO.CRUDException,
                 'CRUDException should fire when read only user attempts to ' +
                 ' create an account but got ' + genericException.getTypeName());
        }   
        Test.stopTest();
        
    }
    
    @isTest
    public static void givenCreatedSObject_whenRead_thenModelsShouldBeReturned() {
        final List<Schema.SObjectField> fieldsToSet = 
                                    new List<Schema.SObjectField>{Account.Name};
        
        Account mockAccount = new Account(Name='DatabaseDAOStrategyTest Mock');
        insert mockAccount;
        
        Test.startTest();
        List<SObjectModel> am = database.read(
            System.Database.query('Select Id,Name From Account Where Id =\'' 
                                                      + mockAccount.Id + '\''));
        
        System.assertEquals(1, am.size(), 
                           'Model should have only a single record');
        System.assertNotEquals(null, am.get(0).record, 
                           'Record should not be null');
        System.assertEquals(mockAccount.Id, am.get(0).record.get('Id'), 
                           'Inserted record ID should match that of the model');
        System.assertEquals(mockAccount.Name, am.get(0).record.get('Name'), 
                           'Inserted name should match that of the model');
        Test.stopTest();
    }
    
    /*@isTest
    public static void givenNullSObjects_whenRead_thenThrowException() {
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        try {
            database.read(null);
        } catch(SObjectDAO.DAOException daoException) {
            genericException = daoException;
        }
        
        System.assert(genericException instanceof SObjectDAO.InvalidArgumentException,
                 'InvalidArgumentException should fire when list of sobjects is null');
        Test.stopTest();
    }
    
    @isTest
    public static void givenEmptySObjects_whenRead_thenThrowException() {
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        try {
            database.read(new List<Account>());
        } catch(SObjectDAO.DAOException daoException) {
            genericException = daoException;
        }
        
        System.assert(genericException instanceof SObjectDAO.InvalidArgumentException,
                 'InvalidArgumentException should fire when list of sobjects is empty');
        Test.stopTest();
    }*/
    
    @isTest
    public static void givenCreatedSObject_whenReadAsReadOnly_thenThrowException() {
       final List<Schema.SObjectField> selectFields= 
                                    new List<Schema.SObjectField>{Account.Name};
        Account mockAccount = new Account(Name='DatabaseDAOStrategyTest Mock');
        insert mockAccount;
        
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        accountModels[0].record.put('Name', 'DatabaseDAOStrategyTest Mock Changed');
        final User readOnlyUser = getTestUser('Chatter External User');
        System.runAs(readOnlyUser) {
            try {
                DAOStrategy databaseDAO = new DatabaseDAOStrategy(Account.SObjectType);
              final String accQuery = String.format('SELECT {0} FROM {1}', 
                new List<String>{
                databaseDAO.addFields(selectFields).getFieldListString(),
                databaseDAO.getFromSObjectName()});
            } catch(SObjectDAO.DAOException daoException) {
                genericException = daoException;
            }
        
            System.assert(genericException instanceof SObjectDAO.FLSException,
                 'FLSException should fire when read only user attempts to ' + 
                 ' read an account but got ' + genericException.getTypeName());
        }   
        Test.stopTest();
        
    }
    
    @isTest
    public static void givenModelsAndFieldsToUpdate_whenModified_thenSObjectsShouldBeUpdated() {
        final List<Schema.SObjectField> fieldsToUpdate = 
                                    new List<Schema.SObjectField>{Account.Name};
        
        Account mockAccount = new Account(Name='DatabaseDAOStrategyTest Mock');
        insert mockAccount;
        
        accountModels.clear();
        accountModels.addAll(database.read(
            System.Database.query('Select Id,Name From Account Where Id =\'' 
                                                     + mockAccount.Id + '\'')));
        
        Test.startTest();
        accountModels[0].record.put('Name', 'DatabaseDAOStrategyTest Mock Updated');
        List<Database.SaveResult> modifyResult = database.modify(accountModels, 
                                                            fieldsToUpdate);
                                                            
        System.assertNotEquals(null, modifyResult, 'Database method returns save result');
        System.assertEquals(1, Limits.getDMLStatements(), 
                                       'Single database insert should get executed');
        System.assertEquals(1, getAccountCount('DatabaseDAOStrategyTest Mock Updated'),
                                         'updated record should be available');
        Test.stopTest();    
        
    }
    
    @isTest
    public static void givenNullModelsAndFieldsToUpdate_whenModified_thenThrowException() {
        final List<Schema.SObjectField> fieldsToUpdate = 
                                    new List<Schema.SObjectField>{Account.Name};
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        try {
            database.modify(null, fieldsToUpdate);
        } catch(SObjectDAO.DAOException daoException) {
            genericException = daoException;
        }
        
        System.assert(genericException instanceof SObjectDAO.InvalidArgumentException,
                 'InvalidArgumentException should fire when models is null');
        Test.stopTest();  
        
    }
    
    @isTest
    public static void givenEmptyModelsAndFieldsToUpdate_whenModified_thenThrowException() {
        final List<Schema.SObjectField> fieldsToUpdate = 
                                    new List<Schema.SObjectField>{Account.Name};
        accountModels.clear();
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        try {
            database.modify(accountModels, fieldsToUpdate);
        } catch(SObjectDAO.DAOException daoException) {
            genericException = daoException;
        }
        
        System.assert(genericException instanceof SObjectDAO.InvalidArgumentException,
                 'InvalidArgumentException should fire when models is null');
        Test.stopTest();  
        
    }
    
    @isTest
    public static void givenModelsAndNullFieldsToUpdate_whenModified_thenThrowException() {
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        try {
            database.modify(accountModels, null);
        } catch(SObjectDAO.DAOException daoException) {
            genericException = daoException;
        }
        
        System.assert(genericException instanceof SObjectDAO.InvalidArgumentException,
                 'InvalidArgumentException should fire when models is null');
        Test.stopTest();  
        
    }
    
    @isTest
    public static void givenModelsAndEmptyFieldsToUpdate_whenModified_thenThrowException() {
        final List<Schema.SObjectField> fieldsToUpdate = 
                                            new List<Schema.SObjectField>();
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        try {
            database.modify(accountModels, fieldsToUpdate);
        } catch(SObjectDAO.DAOException daoException) {
            genericException = daoException;
        }
        
        System.assert(genericException instanceof SObjectDAO.InvalidArgumentException,
                 'InvalidArgumentException should fire when models is null');
        Test.stopTest();  
        
    }
    
    @isTest
    public static void givenModelsAndFieldsToUpdate_whenModifiedAsReadOnly_thenThrowException() {
       final List<Schema.SObjectField> fieldsToSet = 
                                    new List<Schema.SObjectField>{Account.Name};
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        accountModels[0].record.put('Name', 'DatabaseDAOStrategyTest Mock Changed');
        final User readOnlyUser = getTestUser('Read Only');
        System.runAs(readOnlyUser) {
            try {
                new databaseDAOStrategy(Account.SObjectType).modify(accountModels, fieldsToSet);
            } catch(SObjectDAO.DAOException daoException) {
                genericException = daoException;
            }
        
            System.assert(genericException instanceof SObjectDAO.CRUDException,
                 'CRUDException should fire when read only user attempts to ' +
                 ' modify an account but got ' + genericException.getTypeName());
        }   
        Test.stopTest();
        
    }
    
    @isTest
    public static void givenModels_whenRemoved_thenSObjectsShouldBeDeleted() {
        Account mockAccount = new Account(Name='DatabaseDAOStrategyTest Mock');
        insert mockAccount;
        
        accountModels.clear();
        accountModels.addAll(database.read(
            System.Database.query('Select Id,Name From Account Where Id =\'' 
                                                     + mockAccount.Id + '\'')));
        
        Test.startTest();
        List<Database.DeleteResult> deleteResult = database.remove(accountModels);
        
        System.assertNotEquals(null, deleteResult, 'Database Statment returns delete result');
        System.assertEquals(1, Limits.getDMLStatements(), 
                                       'Single database delete should get executed');
        System.assertEquals(0, getAccountCount('databaseDAOStrategyTest Mock'),
                                         'Deleted record should not be available');                                      
        Test.stopTest();
    }
    
    @isTest
    public static void givenNullModels_whenRemoved_thenThrowException() {
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        try {
            database.remove(null);
        } catch(SObjectDAO.DAOException daoException) {
            genericException = daoException;
        }
        
        System.assert(genericException instanceof SObjectDAO.InvalidArgumentException,
                 'InvalidArgumentException should fire when models is null');
        Test.stopTest();
    }
    
    @isTest
    public static void givenModels_whenRemovedAsReadOnly_thenThrowException() {
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        accountModels[0].record.put('Name', 'DatabaseDAOStrategyTest Mock Changed');
        final User readOnlyUser = getTestUser('Read Only');
        System.runAs(readOnlyUser) {
            try {
                new databaseDAOStrategy(Account.SObjectType).remove(accountModels);
            } catch(SObjectDAO.DAOException daoException) {
                genericException = daoException;
            }
        
            System.assert(genericException instanceof SObjectDAO.CRUDException,
                 'CRUDException should fire when read only user attempts to ' + 
                 ' destory an account but got ' + genericException.getTypeName());
        }   
        Test.stopTest();
        
    }
    
    @isTest
    public static void givenSObjectField_whenAddFields_thenFieldsShouldBeAdded() {
        final List<Schema.SObjectField> fieldsToSet = 
                                    new List<Schema.SObjectField>{Account.Name};
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        database.addFields(fieldsToSet);
        System.assertEquals(1, database.selectFields.size(), 
            'A single field should have been added to the internal property');
        Test.stopTest();
    }
    
    @isTest
    public static void givenSObjectFields_whenGetFieldListString_thenCommaSeparatedFieldsShouldBeReturned() {
        final List<Schema.SObjectField> fieldsToSet = 
                                    new List<Schema.SObjectField>{Account.Name, 
                                                                  Account.Id};
        Test.startTest();
        String fieldString = database.addFields(fieldsToSet).getFieldListString();
        System.assertEquals(true, fieldString.contains(','), 
                                        'Fields should be separated by comma ');
        Test.stopTest();
    }
    
    @isTest
    public static void givenSObject_whenGetSObjectName_thenSObjectNameShouldBeReturned() {
        Test.startTest();
        System.assertEquals('Account', database.getFromSObjectName(), 
                                        'Account should be returned');
        Test.stopTest();
    }
    
    /*
    @isTest
    public static void givenNonReadOnlySObject_whenGetSObjectName_thenThrowException() {
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        final User chatterOnlyUser = getTestUser('Chatter Only User');
        System.runAs(chatterOnlyUser) {
           try {
               new databaseDAOStrategy(Document.SObjectType).getFromSObjectName();
           }catch(SObjectDAO.DAOException daoException) {
               genericException = daoException;
           }
           System.assert(genericException instanceof SObjectDAO.CRUDException,
                 'CRUDException should fire when user with no object access ' + 
                 'attempts to read case but got ' + genericException.getTypeName());
        }
        Test.stopTest();
    }*/
    
    @isTest
    public static void givenDMLOptions_whenSetDMLOptions_thenSetDMLOptions() {
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        try {
            database.setDMLOptions(new Database.DMLOptions());
        } catch(SObjectDAO.DAOException daoException) {
            genericException = daoException;
        }
        System.assertNotEquals(null, database.getDMLOptions(), 'DML Options should be set.');
        Test.stopTest();    
    }
    
    @isTest
    public static void givenNullDMLOptions_whenSetDMLOptions_thenThrowException() {
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        try {
            database.setDMLOptions(null);
        } catch(SObjectDAO.DAOException daoException) {
            genericException = daoException;
        }
        System.assert(genericException instanceof SObjectDAO.InvalidArgumentException,
                 'InvalidArgumentException should fire when dmloptions is null');
        Test.stopTest();    
    }
    
    @isTest
    public static void givenNoDMLOptions_whenGetDMLOptions_thenReturnDefault() {
        Test.startTest();
        Database.DMLOptions defaultOptions = database.getDMLOptions();
        
        System.assertEquals(true, defaultOptions.optAllOrNone, 'Default should rollback if any record causes errors.');
        System.assertEquals(null, defaultOptions.AllowFieldTruncation, 'Default should be null.');
        System.assertEquals(null, defaultOptions.AssignmentRuleHeader.AssignmentRuleId, 'Default should be null.');
        System.assertEquals(null, defaultOptions.AssignmentRuleHeader.UseDefaultRule, 'Default should be null.');
        System.assertEquals(null, defaultOptions.DuplicateRuleHeader.AllowSave, 'Default should be null.');
        System.assertEquals(null, defaultOptions.EmailHeader.TriggerAutoResponseEmail, 'Default should be null.');
        System.assertEquals(null, defaultOptions.EmailHeader.TriggerOtherEmail, 'Default should be null.');
        System.assertEquals(null, defaultOptions.EmailHeader.TriggerUserEmail, 'Default should be null.');
        System.assertEquals(null, defaultOptions.LocaleOptions, 'Default should be null.');
        System.assertEquals(null, defaultOptions.LocalizeErrors, 'Default should be null.');
        Test.stopTest();    
    }
    
    private static Integer getAccountCount(final String name) {
        return [Select Count() From Account Where Name = :name];
    }
    
    private static User getTestUser(final String profileName){
        //username global uniqueness is still enforced in tests 
        //make sure we get something unique to avoid issues with parallel tests
        String uniqueness = DateTime.now()+':'+Math.random();
        try{ 
            throw new NullPointerException();
        }catch(Exception e){
            uniqueness += e.getStackTraceString(); //includes the top level test method name without having to pass it
        }
        Profile p = [SELECT id, Name FROM Profile WHERE Name = :profileName];
        User result = new User(
            username=UserInfo.getUserId()+'.'+uniqueness.HashCode()+'@'+UserInfo.getOrganizationId()+'.sfdcOrg',
            alias = 'testExec',
            email='apextests@example.com',
            emailencodingkey='UTF-8',
            lastname='Testing',
            languagelocalekey='en_US',
            localesidkey='en_US',
            profileid = p.Id,
            timezonesidkey='America/Los_Angeles'
        );
        //insert result;
        return result;
    }
    
    
}