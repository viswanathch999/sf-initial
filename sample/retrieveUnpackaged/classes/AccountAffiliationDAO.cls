/**
 * AccountAffiliationDAO is a concrete implementation of SObjectDAO 
 * that encapsulates data access of a contact sObject.
 * 
 * @author Malay Desai
 */
public class AccountAffiliationDAO {
	
	private DAOStrategy dmlDAO;
	
	 /** Sole constructor */
    public AccountAffiliationDAO(final DAOStrategyType daoType) {
        dmlDAO = DAOStrategyFactory.getInstance(daoType, Account_Affiliation__c.sObjectType);
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
     * Fires atomic DML Create
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
     * This method is used to query Account Affiliation records associated with the 
     * parent contact record with specified account type from the database.
     * @param : fieldSet  to query all fields part of it 
     * @param : otherFields on Account_Affiliation__c to query
     * @param : Id of the Parent Contact records
     * @param : Id account RecordType to be excluded
     * @param : Type of the corresponding parent Account records
     * @return list of Account_Affiliation__c records
     */
	public List<SObjectModel> getFilteredRecords(final Schema.FieldSet accAffFieldSet, final List<Schema.SObjectField> otherAccAffFields, 
												 final String contactId, Id selectedAccRecTypeId){
	
		String sAPINames = '';
        List<SObjectModel> lstSobjectModel;
        for(Schema.SObjectField aField : otherAccAffFields){
        	sAPINames += aField.getDescribe().getName() + ','; 
        }
        for(Schema.FieldSetMember aField: accAffFieldSet.getFields())
        {
        	sAPINames += aField.getFieldPath() + ',';  
        }
        
        sAPINames = sAPINames.removeEnd(',');		
        final String accAffQuery ;
        
        // Apex variable binding is secure against SOQL injection 
        /*if(accountType == null){
        	accAffQuery = String.format('SELECT {0} FROM {1} WHERE Contact__c = :contactId AND Account__r.recordTypeId != :accountRecordTypeId ORDER BY Account__r.Name,IsActive__c', 
	            new List<String>{
	            	sAPINames,
	            	dmlDAO.getFromSObjectName()});		
        } else{
        	accAffQuery = String.format('SELECT {0} FROM {1} WHERE Contact__c = :contactId AND Account__r.recordTypeId != :accountRecordTypeId AND Account__r.Type = :accountType  ORDER BY Account__r.Name,IsActive__c', 
            new List<String>{
            	sAPINames,
            	dmlDAO.getFromSObjectName()});
        }*/
                                                     
        if(selectedAccRecTypeId == null){
        	accAffQuery = String.format('SELECT {0} FROM {1} WHERE Contact__c = :contactId ORDER BY Account__r.Name,IsActive__c', 
	            new List<String>{
	            	sAPINames,
	            	dmlDAO.getFromSObjectName()});		
        } else{
        	accAffQuery = String.format('SELECT {0} FROM {1} WHERE Contact__c = :contactId AND Account__r.recordTypeId = :selectedAccRecTypeId ORDER BY Account__r.Name,IsActive__c', 
            new List<String>{
            	sAPINames,
            	dmlDAO.getFromSObjectName()});
        }
        
        // Database.query() can only resolve bind variables if they are in the 
        // current scope          
        try{
        	lstSobjectModel = read(Database.query(accAffQuery));
        } catch(Exception e){
        	lstSobjectModel = new List<SObjectModel>();
        }
        return lstSobjectModel;
	}

}