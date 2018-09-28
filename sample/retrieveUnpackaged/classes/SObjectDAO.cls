/**
 * SObjectDAO is an abstract class that encapsulates current user's permissions, 
 * field-level security for all the CRUD operations around accessing the 
 * persistence layer. It uses template methods to implement the 
 * invariant parts(CRUD/FLS) once and leave it up to subclasses to implement
 * the behaviour around DML operations. 
 *
 * Sharing rules are distinct from object-level and field-level permissions. 
 * However, they can coexist.
 * 
 * @author Naveen Hiremath
 */
public abstract class SObjectDAO {
    
    private final Schema.sObjectType SObjectType;
    private final Schema.DescribeSObjectResult SObjectDescribe;
    @TestVisible private final List<Schema.SObjectField> selectFields;
    
    private final AccessControl objectAccessControl;
    
    protected SObjectDAO(final Schema.sObjectType SObjectType) {
        this.SObjectType = SObjectType;
        this.SObjectDescribe = this.SObjectType.getDescribe();
        
        this.selectFields = new List<Schema.SObjectField>();
        
        this.objectAccessControl = new AccessControl(this.SObjectDescribe);
    }
    
    /**
     * Add operation customization hook to be implemented by the subclass 
     *  
     * @param records List of SObjects to create
     * @return result of add operation
     */
    protected abstract List<Database.SaveResult> doBuild(
                                                   final List<SObject> records);
                                             
    /**
     * Modify operation customization hook to be implemented by the subclass 
     *  
     * @param records List of SObjects to modify
     * @return result of modify operation
     */
    protected abstract List<Database.SaveResult> doWrite(
                                                   final List<SObject> records);
                                            
    /**
     * Remove operation customization hook to be implemented by the subclass 
     *  
     * @param records List of SObjectModels to remove
     * @return result of remove operation
     */
    protected abstract List<Database.DeleteResult> doDestroy(
                                            final List<SObject> records);
    
    /**
     * Template method that performs an add operation on the database records
     * via hook that a subclass implements  
     *  
     * @param models List of SObjectModel to create
     * @param fieldsToSet list of fields to assign a value
     * @return result of add operation
     * @throws CRUDException if the running user lcaks object create rights
     * @throws FLSException if the running user lacks field create rights
     * @throws InvalidArgumentException if the arguments are invalid
     */
    protected List<Database.SaveResult> build(
                                 final List<SObjectModel> models,
                                 final List<Schema.SObjectField> fieldsToSet) {
       if(models == null || models.isEmpty() || 
           fieldsToSet == null || fieldsToSet.isEmpty()) {
            throw new InvalidArgumentException(
                        'System.Label.Invalid_Argument_Exception');
       }
      
       if(!this.objectAccessControl.isCreateable()) {
           throw new CRUDException('System.Label.Create_Object_Exception');
       }
      
       final List<SObject> records = this.getRecords(models);
        
       // We can't just create an array of sObjects and add the objects 
       // using devObj.getSObjectType().newSObject(); because it will fail on
       // insert. The error will be: System.TypeException: DML not allowed on 
       // abstract class SObject
       List<SObject> cleanSObjects = records.clone();
       cleanSObjects.clear();
      
       for(SObject eachSObject :records) {
         // start from a fresh sObject and only set fields the user is
         // allowed to set 
         final SObject cleanSObject = eachSObject.getSObjectType().newSObject();
         for(Schema.SObjectField eachField :fieldsToSet) {
             if(!eachField.getDescribe().isCreateable()) {
                 throw new FLSException('System.Label.Create_Field_Exception');
             } else {
                 // user has permission to set fieldName. However, if the developer 
                 // did not set this field and it is required, we should get an  
                 // exception when we set it here, or when we perform the actual 
                 // insert.
                 cleanSObject.put(eachField, eachSObject.get(eachField));           
             }
         }
         cleanSObjects.add(cleanSObject);
       }
      
       final List<Database.SaveResult> resultSet = this.doBuild(cleanSObjects);
       // DML insert automatically sets the ID value of all new SObjects. Bring
       // this ID over to it's model.
       
       //TODO: Name unique key constraint issue in this method.
       //this.associateId(models, cleanSObjects);
       
       return resultSet;
    }
    
    /**
     * Converts native SObject records into relevant Models
     *  
     * @param records queried SObject records
     * @return list of SObjectModel records from native SObjects
     */
    protected List<SObjectModel> take(final List<SObject> records) {
        /*if(records == null || records.isEmpty()) {
            throw new InvalidArgumentException(
                        'System.Label.Invalid_Argument_Exception');
        }*/
        
        final List<SObjectModel> models = new List<SObjectModel>();
        final String sObjectName = this.getSObjectName();
        for(SObject eachSObject :records) {
            models.add(SObjectModelFactory.getInstance(sObjectName,eachSObject));
        }
        
        return models;
    }
    
    /**
     * Template method that performs a modify operation on the database records
     * via hook that a subclass implements
     *  
     * @param models List of SObjectModels to modify
     * @param fieldsToSet list of fields to modify
     * @return result of modification operation
     * @throws CRUDException if the running user lacks object modify rights
     * @throws FLSException if the running user lacks field modify rights
     * @throws InvalidArgumentException if the arguments are invalid
     */
    protected List<Database.SaveResult> write(
                            final List<SObjectModel> models,
                            final List<Schema.SObjectField> fieldsToUpdate) {
        if(models == null || models.isEmpty() || 
            fieldsToUpdate == null || fieldsToUpdate.isEmpty()) {
             throw new InvalidArgumentException(
                        'System.Label.Invalid_Argument_Exception');
        }
        
        if(!this.objectAccessControl.isUpdateable()) {
            throw new CRUDException('System.Label.Update_Object_Exception');
        }
        
        final List<SObject> records = this.getRecords(models);
        
        // We can't just create an array of sObjects and add the objects 
        // using devObj.getSObjectType().newSObject(); because it will fail on
        // insert. The error will be: System.TypeException: DML not allowed on 
        // abstract class SObject
        List<SObject> cleanSObjects = records.clone();
        cleanSObjects.clear();
      
        for(SObject eachSObject :records) {
            // start from a fresh sObject and only set fields the user is 
            // allowed to set  
            final SObject cleanSObject = eachSObject.clone(true); //preserve Id       
            for(Schema.SObjectField eachField :fieldsToUpdate) {
                if(!eachField.getDescribe().isUpdateable()) {
                    throw new FLSException('System.Label.Update_Field_Exception');
                } else {
                    // user has permission to set fieldName. However, if the developer 
                    // did not set this field and it is required, we should get an  
                    // exception when we set it here, or when we perform the actual 
                    // insert.
                    cleanSObject.put(eachField, eachSObject.get(eachField));            
                }
            }
            cleanSObjects.add(cleanSObject);
        }
      
        return this.doWrite(cleanSObjects);
    }
        
    /**
     * Template method that performs a remove operation on the database records
     * via hook that a subclass implements
     *  
     * @param records List of SObjectModels to remove
     * @return result of remove operation
     * @throws CRUDException if the running user does not have remove rights
     */
    protected List<Database.DeleteResult> destroy(final List<SObjectModel> models) {
        if(models == null || models.isEmpty()) {
             throw new InvalidArgumentException(
                        'System.Label.Invalid_Argument_Exception');
        }
        
        if(!this.objectAccessControl.isDeleteable()) {
            throw new CRUDException('System.Label.Delete_Object_Exception');
        }
        
        return this.doDestroy(this.getRecords(models));
    }
    
    /**
     * Add fields to be SOQL queried
     *  
     * @param selectFields list of Schema.SObject fields
     */
    protected void addSelectFields(final List<Schema.SObjectField> selectFields) {
        if(selectFields != null) {
           this.selectFields.addAll(selectFields);
        }
    }
    
    /**
     * Accessor for the SObject name
     *  
     * @return string representation of the SObject name
     * @throws CRUDException if the running user does not have query access
     */
    protected String getSObjectName() {
        if(!this.objectAccessControl.isQueryable()) {
            throw new CRUDException('System.Label.Read_Object_Exception');
        }
        
        return this.SObjectDescribe.getName();
    }
    
    /**
     * Accessor that gets a comma separated string of fields added via 
     * addSelectFields() that can be referenced in a SOQL query
     *  
     * @return string of comma delimited field names
     * @throws FLSException if the running user does not have field access
     */
    protected String getSelectFieldsAsString() {
        if(!this.objectAccessControl.isAccessible(this.selectFields)) {
            throw new FLSException('System.Label.Read_Field_Exception');    
        }
        
        // weed out any duplicate field references from the list
        final Set<String> uniqueFields = new Set<String>();
        for(Schema.SObjectField eachField :this.selectFields) {
            uniqueFields.add(eachField.getDescribe().getName());
        }
        
        final List<String> fieldList = new List<String>();
        fieldList.addAll(uniqueFields);
        return String.join(fieldList, ',');
    }
    
    /**
     * Returns a list of Sobjects from their models
     *
     * @param sobjectModels list of models
     * @return list of sobjects
     */
    private List<SObject> getRecords(final List<SObjectModel> sobjectModels) {
        final List<SObject> records = new List<SObject>();
        for(SObjectModel eachModel :sobjectModels) {
            records.add(eachModel.record);
        }
        
        return records;
    }
    
    /**
     * Copies record Id from Sobject to its equivalent model record using
     * record 'Name' as the key
     *
     * @param sobjectModels list of models
     * @param records list of sobjects
     */
    private void associateId(final List<SObjectModel> models, 
                             final List<SObject> records) {
        for(SObjectModel eachModel :models) {
          for(SObject eachRecord :records) {
             if(String.valueOf(eachModel.record.get('Name')).equalsIgnoreCase(
                String.valueOf(eachRecord.get('Name')))) {                
                 eachModel.record.put('Id', eachRecord.get('Id'));
                 break;
             }
          }
       }
    }
    
    /** 
     * Apex doesn't enforce object-level and field-level permissions by default, 
     * and this class enforces these permissions by explicitly calling 
     * the sObject describe result methods (of Schema.DescribeSObjectResult) and 
     * the field describe result methods (of Schema.DescribeFieldResult) that 
     * check the current user's access permission levels for an sObject
     */
    private class AccessControl {
        
        // Although Java supports accessing an outer class's member variable
        // from an inner class, Apex does not support it since inner classes 
        // are implemented as "static inner classes" with no access to containing
        // class's instance varaibles.
        private final Schema.DescribeSObjectResult SObjectDescribe;
        
        private AccessControl(final Schema.DescribeSObjectResult SObjectDescribe) {
           this.SObjectDescribe = SObjectDescribe;  
        }
        
        /**
         * Checks SObject Create CRUD
         * 
         * @return true if SObject is creatable by the current user 
         */
        private Boolean isCreateable() {
            return this.SObjectDescribe.isCreateable();
        }
        
        /**
         * Checks SObject Read CRUD
         * 
         * @return true if SObject is queryable by the current user
         */
        private Boolean isQueryable() {
            return this.SObjectDescribe.isQueryable();
        }
        
        /**
         * Checks SObject Update CRUD
         * 
         * @return true if SObject is updateable by the current user
         */
        private Boolean isUpdateable() {
            return this.SObjectDescribe.isUpdateable();
        }
        
        /**
         * Checks SObject Delete CRUD
         * 
         * @return true if SObject is deleteable by the current user
         */
        private Boolean isDeleteable() {
            return this.SObjectDescribe.isDeletable();
        }
        
        /**
         * Checks if the supplied list of fields can be read
         * 
         * @param selectFields list of fields to read
         * @return true if the list of fields are readable by the current user
         */
        private Boolean isAccessible(final List<Schema.SObjectField> selectFields) {
            for(Schema.SObjectField eachField :selectFields) {
                if(!eachField.getDescribe().isAccessible()) {
                    return false;
                }
            }
            
            return true;
        }       
    }
    
    /** 
     * General exception class for the DAO layer. 
     */
    public abstract class DAOException extends Exception {}
   
    /**
     * CrudException represents a running user's lack of read/create/update/delete 
     * access at a profile (or permission set) level. 
     * Sharing and field level security issues will never cause this.
     */
    public class CRUDException extends DAOException {}
    
    /**
     * FLSException represents a running user's lack of field 
     * access at a profile (or permission set) level. 
     * Sharing and field level security issues will never cause this.
     */
    public class FLSException extends DAOException {}
    
    /**
     * InvalidArgumentException represents a lack of valid method arguments
     */
    public class InvalidArgumentException extends DAOException {}
    
}