/**
 * DMLDAOStrategyTest class contains unit tests for validating the behavior of 
 * DMLDAOStrategy
 *
 * "Given" defines the preconditions, "When" defines what happens, and 
 * "Then" defines the result of the scenario. Or in other words: 
 * "Given" describes the start state, and "When" the steps 
 * necessary to reach the accepting state (= "Then").
 *
 * @author Naveen Hiremath
 */
@isTest
public class DMLDAOStrategyTest {
    
    private static final List<SObjectModel> accountModels;
    private static final DMLDAOStrategy dml;
    static {
        accountModels = new List<SObjectModel>();
        SObjectModelMock mockAccount = new SObjectModelMock(
                                   new Account(Name='DMLDAOStrategyTest Mock'));
        accountModels.add(mockAccount);
        
        dml = (DMLDAOStrategy)DAOStrategyFactory.getInstance(
                                                DAOStrategyType.DMLDAOStrategy, 
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
        accountModels[0].record.put('Name', 'DMLDAOStrategyTest Mock Changed');
        List<Database.SaveResult> createResult = dml.create(accountModels, 
                                                            fieldsToSet);
        
        System.assertEquals(null, createResult, 'DML Statment returns nothing');
        System.assertEquals(1, getAccountCount('DMLDAOStrategyTest Mock Changed'),
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
            dml.create(null, fieldsToSet);
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
            dml.create(accountModels, fieldsToSet);
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
            dml.create(accountModels, null);
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
            dml.create(accountModels, fieldsToSet);
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
        accountModels[0].record.put('Name', 'DMLDAOStrategyTest Mock Changed');
        final User readOnlyUser = getTestUser('Read Only');
        System.runAs(readOnlyUser) {
            try {
                new DMLDAOStrategy(Account.SObjectType).create(accountModels, fieldsToSet);
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
        
        Account mockAccount = new Account(Name='DMLDAOStrategyTest Mock');
        insert mockAccount;
        
        Test.startTest();
        List<SObjectModel> am = dml.read(
            Database.query('Select Id,Name From Account Where Id =\'' 
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
            dml.read(null);
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
            dml.read(new List<Account>());
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
        Account mockAccount = new Account(Name='DMLDAOStrategyTest Mock');
        insert mockAccount;
        
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        accountModels[0].record.put('Name', 'DMLDAOStrategyTest Mock Changed');
        final User readOnlyUser = getTestUser('Chatter External User');
        System.runAs(readOnlyUser) {
            try {
                DAOStrategy dmlDAO = new DMLDAOStrategy(Account.SObjectType);
              final String accQuery = String.format('SELECT {0} FROM {1}', 
                new List<String>{
                dmlDAO.addFields(selectFields).getFieldListString(),
                dmlDAO.getFromSObjectName()});
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
        
        Account mockAccount = new Account(Name='DMLDAOStrategyTest Mock');
        insert mockAccount;
        
        accountModels.clear();
        accountModels.addAll(dml.read(
            Database.query('Select Id,Name From Account Where Id =\'' 
                                                     + mockAccount.Id + '\'')));
        
        Test.startTest();
        accountModels[0].record.put('Name', 'DMLDAOStrategyTest Mock Updated');
        List<Database.SaveResult> createResult = dml.modify(accountModels, 
                                                            fieldsToUpdate);
                                                            
        System.assertEquals(null, createResult, 'DML Statment returns nothing');
        System.assertEquals(1, Limits.getDMLStatements(), 
                                       'Single DML insert should get executed');
        System.assertEquals(1, getAccountCount('DMLDAOStrategyTest Mock Updated'),
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
            dml.modify(null, fieldsToUpdate);
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
            dml.modify(accountModels, fieldsToUpdate);
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
            dml.modify(accountModels, null);
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
            dml.modify(accountModels, fieldsToUpdate);
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
        accountModels[0].record.put('Name', 'DMLDAOStrategyTest Mock Changed');
        final User readOnlyUser = getTestUser('Read Only');
        System.runAs(readOnlyUser) {
            try {
                new DMLDAOStrategy(Account.SObjectType).modify(accountModels, fieldsToSet);
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
        Account mockAccount = new Account(Name='DMLDAOStrategyTest Mock');
        insert mockAccount;
        
        accountModels.clear();
        accountModels.addAll(dml.read(
            Database.query('Select Id,Name From Account Where Id =\'' 
                                                     + mockAccount.Id + '\'')));
        
        Test.startTest();
        List<Database.DeleteResult> deleteResult = dml.remove(accountModels);
        
        System.assertEquals(null, deleteResult, 'DML Statment returns nothing');
        System.assertEquals(1, Limits.getDMLStatements(), 
                                       'Single DML delete should get executed');
        System.assertEquals(0, getAccountCount('DMLDAOStrategyTest Mock'),
                                         'Deleted record should not be available');                                      
        Test.stopTest();
    }
    
    @isTest
    public static void givenNullModels_whenRemoved_thenThrowException() {
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        try {
            dml.remove(null);
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
        accountModels[0].record.put('Name', 'DMLDAOStrategyTest Mock Changed');
        final User readOnlyUser = getTestUser('Read Only');
        System.runAs(readOnlyUser) {
            try {
                new DMLDAOStrategy(Account.SObjectType).remove(accountModels);
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
        dml.addFields(fieldsToSet);
        System.assertEquals(1, dml.selectFields.size(), 
            'A single field should have been added to the internal property');
        Test.stopTest();
    }
    
    @isTest
    public static void givenSObjectFields_whenGetFieldListString_thenCommaSeparatedFieldsShouldBeReturned() {
        final List<Schema.SObjectField> fieldsToSet = 
                                    new List<Schema.SObjectField>{Account.Name, 
                                                                  Account.Id};
        Test.startTest();
        String fieldString = dml.addFields(fieldsToSet).getFieldListString();
        System.assertEquals(true, fieldString.contains(','), 
                                        'Fields should be separated by comma ');
        Test.stopTest();
    }
    
    @isTest
    public static void givenSObject_whenGetSObjectName_thenSObjectNameShouldBeReturned() {
        Test.startTest();
        System.assertEquals('Account', dml.getFromSObjectName(), 
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
               new DMLDAOStrategy(Document.SObjectType).getFromSObjectName();
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
    public static void givenSObject_whenSetDMLOptions_thenThrowException() {
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        try {
            dml.setDMLOptions(new Database.DMLOptions());
        } catch(SObjectDAO.DAOException daoException) {
            genericException = daoException;
        }
        System.assert(genericException instanceof SObjectDAO.CRUDException,
                 'CRUDException should fire when setDMLOptions() is invoked' + 
                 'but got ' + genericException.getTypeName());
        Test.stopTest();    
    }
    
    @isTest
    public static void givenSObject_whenGetDMLOptions_thenThrowException() {
        SObjectDAO.DAOException genericException;
        
        Test.startTest();
        try {
            dml.getDMLOptions();
        } catch(SObjectDAO.DAOException daoException) {
            genericException = daoException;
        }
        System.assert(genericException instanceof SObjectDAO.CRUDException,
                 'CRUDException should fire when getDMLOptions() is invoked' + 
                 'but got ' + genericException.getTypeName());
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