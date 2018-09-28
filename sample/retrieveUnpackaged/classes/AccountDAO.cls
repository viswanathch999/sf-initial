/**
 * AccountDAO is a concrete implementation of SObjectDAO 
 * that encapsulates data access of a Account sObject.
 * 
 * @author Shri K
 */
public class AccountDAO {
    
    private DAOStrategy dmlDAO;
	     
	 /** Sole constructor */
     public AccountDAO(final DAOStrategyType daoType) {
     	dmlDAO = DAOStrategyFactory.getInstance(daoType, Account.sObjectType);
     }
     
    /**
     * This method is used to query chapter Account records from the database.
     *  
     * @param selectFields list of Schema.SObjectFields to query
     * @param name name of the region health record type to lookup
     * @return list of SObjectModel
     */
    public List<SObjectModel> getChapterAccount(
						            final List<Schema.SObjectField> selectFields, 
						            final String name,
						            final String type) {   
        // Apex variable binding is secure against SOQL injection 
        final String accQuery = String.format('SELECT {0} FROM {1} WHERE RecordType.DeveloperName = :name AND Type =: type', 
            new List<String>{
            	dmlDAO.addFields(selectFields).getFieldListString(),
            	dmlDAO.getFromSObjectName()});
        
        // Database.query() can only resolve bind variables if they are in the 
        // current scope    
        return dmlDAO.read(Database.query(accQuery));
	}
	
	/**
     * Fires atomic DML update
     *  
     * @param models List of SObjectModels to update
     * @param fieldsToUpdate list of fields to update
     * @return null
     * @throws CRUDException when the running user lacks object modify rights
     * @throws FLSException if the running user lacks field modify rights
     * @throws DMLException any problem with a DML statement
     * @throws InvalidArgumentException if the arguments are invalid
     */
    public List<Database.SaveResult> modify(
                                final List<SObjectModel> models,
                                final List<Schema.SObjectField> fieldsToUpdate) {
        return dmlDAO.modify(models, fieldsToUpdate);                                
    }
}