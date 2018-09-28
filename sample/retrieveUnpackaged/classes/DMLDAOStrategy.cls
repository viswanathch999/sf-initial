/** 
 * DMLDAOStrategy is a concrete implementation of DAOStrategy interface that  
 * performs data operations using Apex DML statements, which can result in  
 * exceptions that can be handled in code. It also does not support partial  
 * record processing, if errors are encountered.
 *
 * @author Naveen Hiremath
 */
public class DMLDAOStrategy extends SObjectDAO implements DAOStrategy {
     
    public DMLDAOStrategy(final Schema.sObjectType SObjectType) {
        super(SObjectType); 
    }
    
    /**
     * Add records to the database by delegating responsiblity to base 
     * class template method
     *  
     * @param models List of SObjectModels to create
     * @param fieldsToSet list of fields to assign a value
     * @return result of a DML statement insert that is null
     * @throws CRUDException when the running user lacks create rights
     * @throws FLSException if the running user lacks field create rights
     * @throws DMLException any problem with a DML statement
     * @throws InvalidArgumentException if the arguments are invalid
     */
    public List<Database.SaveResult> create(
                                final List<SObjectModel> models, 
                                final List<Schema.SObjectField> fieldsToSet) {
        return this.build(models, fieldsToSet);
    }
    
    /**
     * Queries records from the database by delegating responsiblity to base
     * class template method
     *  
     * @param records resultset of the SOQL query
     * @return list of SObjectModel records after executing the query 
     * @throws CRUDException when the running user does not have query rights
     */
    public List<SobjectModel> read(final List<SObject> records) {
        return this.take(records);
    }

    /**
     * Update records in the database by delegating responsiblity to base 
     * class template method
     *  
     * @param records List of SObjectModels to update
     * @param fieldsToUpdate list of fields to update
     * @return result of a DML statement update that is null
     * @throws CRUDException when the running user lacks object modify rights
     * @throws FLSException if the running user lacks field modify rights
     * @throws DMLException any problem with a DML statement
     * @throws InvalidArgumentException if the arguments are invalid
     */
    public List<Database.SaveResult> modify(
                                final List<SObjectModel> models,
                                final List<Schema.SObjectField> fieldsToUpdate) {
        return this.write(models, fieldsToUpdate);
    }
    
    /**
     * Remove records from the database by delegating responsiblity to base
     * class template method
     *  
     * @param records List of SObjectModels to remove
     * @return result of a DML statement update that is null
     * @throws CRUDException when the running user does not have delete rights
     * @throws DMLException any problem with a DML statement
     */
    public List<Database.DeleteResult> remove(final List<SObjectModel> models) {
        return this.destroy(models);
    }
    
    /**
     * Adds all the fields to be queried  
     *  
     * @param selectFields list of Schema.SObjectField to read
     * @return reference to itself  
     */
    public DAOStrategy addFields(final List<Schema.SObjectField> selectFields) {
        this.addSelectFields(selectFields);
        return this;
    }
    
    /**
     * Return the list of Schema.SObjectField as a string for use in SOQL query
     *  
     * @return string representation of Schema.SObjectFields list 
     * @throws FLSException if the running user does not have field access 
     */
    public String getFieldListString() {
        return this.getSelectFieldsAsString();
    }
    
    /**
     * Return the name of the current SObject
     *  
     * @return name of the SObject
     * @throws CRUDException if the running user does not have access rights  
     */
    public String getFromSObjectName() {
        return this.getSObjectName();
    }
    
    /**
     * Calling this method throws an exception as this is only supported 
     * for DatabaseDAOStrategy instance
     *
     * @throws CRUDException method not supported for DML statements
     */
    public void setDMLOptions(final Database.DMLOptions dmlOptions) {
        throw new SObjectDAO.CRUDException('System.Label.DMLOptions_Not_Supported');    
    }
    
    /**
     * Calling this method throws an exception as this is only supported 
     * for DatabaseDAOStrategy instance
     *
     * @throws CRUDException method not supported for DML statements
     */
    public Database.DMLOptions getDMLOptions() {
        throw new SObjectDAO.CRUDException('System.Label.DMLOptions_Not_Supported');
    }
    
    /**
     * Customized hook implements DML statment insert  
     *  
     * @param records List of SObjects to create
     * @return null DML statement doesn't return anything
     * @throws DMLException any problem with a DML statement
     */
    protected override List<Database.SaveResult> doBuild(
                                                  final List<SObject> records) {
        insert records;
  
        return null;                                            
    }
    
    /**
     * Customized hook implements DML statment update  
     *  
     * @param records List of SObjects to update
     * @return null DML statement doesn't return anything
     * @throws DMLException any problem with a DML statement
     */
    protected override List<Database.SaveResult> doWrite(
                                                  final List<SObject> records) {
        update records;

        return null;
    }
    /**
     * Customized hook implements DML statment delete  
     *  
     * @param records List of SObjectModels to create
     * @return null DML statement doesn't return anything
     * @throws DMLException any problem with a DML statement
     */
    protected override List<Database.DeleteResult> doDestroy(
                                            final List<SObject> records) {
        delete records;
        
        return null;
    }
    
}