/**
 * ContactDAO is a concrete implementation of SObjectDAO 
 * that encapsulates data access of a contact sObject.
 * 
 * @author Malay Desai
 */
public class ContactDAO {
     
    private DAOStrategy dmlDAO;
         
     /** Sole constructor */
    public ContactDAO(final DAOStrategyType daoType) {
        dmlDAO = DAOStrategyFactory.getInstance(daoType, Contact.sObjectType);
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
     * Converts native SObject records into relevant Models
     *  
     * @param records queried SObject records
     * @return list of SObjectModel records from native SObjects
     */
	public List<SObjectModel> read(List<SObject> records){
		
		return dmlDAO.read(records);
	}
	
	/**
     * Queries the selected fields for list of Ids passed in on Contact object
     *  
     * @param selectFields list of Schema.SObjectFields to query
     * @param Set of Contact Ids
     * @return list of SObjectModels
     */
	public List<SObjectModel> getM2MXContacts(final List<Schema.SObjectField> selectFields, final Set<Id> lstId) {
		// Apex variable binding is secure against SOQL injection 
        final String conQuery = String.format('SELECT {0} FROM {1} WHERE Id in :lstId', 
            new List<String>{
            	dmlDAO.addFields(selectFields).getFieldListString(),
            	dmlDAO.getFromSObjectName()});
        // Database.query() can only resolve bind variables if they are in the 
        // current scope    
        return dmlDAO.read(Database.query(conQuery));
	
	}
	
	/**
     * Queries the selected fields for Id passed in on Contact object
     *  
     * @param selectFields list of Schema.SObjectFields to query
     * @param Id of Contact
     * @return list of SObjectModels
     */
	/*public List<SObjectModel> getInterestContact(final List<Schema.SObjectField> selectFields, final Id contactId) {
		// Apex variable binding is secure against SOQL injection 
        final String conQuery = String.format('SELECT {0} FROM {1} WHERE Id =:contactId', 
            new List<String>{
            	dmlDAO.addFields(selectFields).getFieldListString(),
            	dmlDAO.getFromSObjectName()});
        // Database.query() can only resolve bind variables if they are in the 
        // current scope    
        return dmlDAO.read(Database.query(conQuery));
	
	}  
	
	public List<SObjectModel> getChildrenAndSpouse(final List<Schema.SObjectField> selectFields, final Id accountId, final Id householdId, final List<Id> recordTypeIds){
		// Apex variable binding is secure against SOQL injection 
		System.debug('Account Id : ' +accountId );
		System.debug('household Id : ' +householdId );
		System.debug('Record Id : ' +recordTypeIds  );
        final String conQuery = String.format('SELECT {0} FROM {1} WHERE RecordTypeId in :recordTypeIds AND accountId =:accountId AND HouseholdId__c =:householdId', 
            new List<String>{
            	dmlDAO.addFields(selectFields).getFieldListString(),
            	dmlDAO.getFromSObjectName()});
        // Database.query() can only resolve bind variables if they are in the 
        // current scope    
        return dmlDAO.read(Database.query(conQuery));
	}*/ 
}