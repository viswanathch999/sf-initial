/**
 * Data Access Object(DAO) class separates the code that accesses the database 
 * from the code that works with the data. Other components of the application 
 * delegate responsibility for database access to a DAO object, which  
 * communicates with the rest of the system by passing around model objects. 
 * 
 * DAOStrategy is an interface to represent all the common behaviors around data
 * access. It uses Strategy pattern to promote different algorithm 
 * implementations without causing tight coupling.    
 *
 * @author Naveen Hiremath
 */
public interface DAOStrategy {
    
    /**
     * Inserts all of the elements in the specified list to the database 
     *  
     * @param models list of SObjectModels to create
     * @param fieldsToSet list of fields to assign a value
     * @return result of the operation  
     */
    List<Database.SaveResult> create(
                                  final List<SObjectModel> models, 
                                  final List<Schema.SObjectField> fieldsToSet);
    /**
     * Queried data is casted into its relevant model 
     *  
     * @param records list of queried SObjecs
     * @return list of SObjects wrapped into it's respective model   
     */
    List<SobjectModel> read(final List<SObject> records);
    
    /**
     * Updates all of the elements in the specified list to the database 
     *  
     * @param records list of SObjectModels to create
     * @param fieldsToUpdate list of fields to update
     * @return result of the operation  
     */
    List<Database.SaveResult> modify(
                                final List<SObjectModel> models,
                                final List<Schema.SObjectField> fieldsToUpdate);
    /**
     * Deletes all of the elements in the specified list to the database 
     *  
     * @param records list of SObjectModels to create
     * @return result of the operation  
     */
    List<Database.DeleteResult> remove(final List<SObjectModel> models);
    
    /**
     * Adds all the fields to be queried  
     *  
     * @param selectFields list of Schema.SObjectField to read
     * @return pointer to this  
     */
    DAOStrategy addFields(final List<Schema.SObjectField> selectFields);
    
    /**
     * Return the list of Schema.SObjectField as a string for use in SOQL query
     *  
     * @return string representation of Schema.SObjectFields list  
     */
    String getFieldListString();
    
    /**
     * Return the name of the current SObject
     *  
     * @return name of the SObject  
     */
    String getFromSObjectName();
    
    /**
     * Set Database.DMLOptions to support Database operation
     *
     * @param dmlOptions database options to be set
     */
    void setDMLOptions(final Database.DMLOptions dmlOptions);
    
    /**
     * Get Database.DMLOptions
     *  
     * @return Database.DMLOptions that was previously set  
     */
    Database.DMLOptions getDMLOptions();

}