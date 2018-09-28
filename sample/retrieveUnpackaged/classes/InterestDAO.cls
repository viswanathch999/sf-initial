/**
 * AccountDAO is a concrete implementation of SObjectDAO 
 * that encapsulates data access of a Interest__c sObject.
 * 
 * @author Shri K
 */
public class InterestDAO {

	private DAOStrategy dmlDAO;
         
     /** Sole constructor */
    public InterestDAO(final DAOStrategyType daoType) {
        dmlDAO = DAOStrategyFactory.getInstance(daoType, Interest__c.sObjectType);
    }
     
    /**
     * Fires atomic DML update
     *  
     * @param models List of SObjectModels to insert
     * @param fieldsToUpdate list of fields to insert
     * @return null
     * @throws CRUDException when the running user lacks object modify rights
     * @throws FLSException if the running user lacks field modify rights
     * @throws DMLException any problem with a DML statement
     * @throws InvalidArgumentException if the arguments are invalid
     */
    public List<Database.SaveResult> create(
                                final List<SObjectModel> models,
                                final List<Schema.SObjectField> fieldsToUpdate) {
        return dmlDAO.create(models, fieldsToUpdate);                                
    }
    
    /**
     * This method is used to query chapter health records from the database.
     *  
     * @param selectFields list of Schema.SObjectFields to query
     * @param name name of the chapter health record type to lookup
     * @return list of ChapterHealthModel
     */
    /*public List<SObjectModel> getInterestForContact(
						            final List<Schema.SObjectField> selectFields, 
						            final String contactId
						            ) {   
        // Apex variable binding is secure against SOQL injection 
        final String accQuery = String.format('SELECT {0} FROM {1} WHERE Contact__c =: contactId ORDER BY Category__c', 
            new List<String>{
            	dmlDAO.addFields(selectFields).getFieldListString(),
            	dmlDAO.getFromSObjectName()});
        
        // Database.query() can only resolve bind variables if they are in the 
        // current scope    
        return dmlDAO.read(Database.query(accQuery));
	}*/    

}