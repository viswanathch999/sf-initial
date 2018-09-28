/**
 * TaskDAO is a concrete implementation of SObjectDAO 
 * that encapsulates data access of a contact sObject.
 * 
 * @author Malay Desai
 */
public class TaskDAO {
	
	private DAOStrategy dmlDAO;
         
     /** Sole constructor */
    public TaskDAO(final DAOStrategyType daoType) {
        dmlDAO = DAOStrategyFactory.getInstance(daoType, Task.sObjectType);
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

}