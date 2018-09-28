/*
 * 
 * AccountServices acts as an orchestrator and pulls together task or process  
 * logic typically utilising multiple object data.  
 * 
 * Class provides a strict encapsulation of code 
 * implementing business tasks, calculations & processes 
 * and is a key entry point to other layers.
 *
 * @author Shri K
 */
public class AccountServices {
 
 /** Singleton instance created upon class loading */
    final public static AccountDAO oAccountDAO;
    static 
    {
        oAccountDAO = new AccountDAO(DAOStrategyType.DMLDAOStrategy);    
    }
    
    /**
     * Updates the Account record GUID field with the GUID format.  
     * 
     * @param: lstAccount List of accounts for GUID generation.
     */
    public static void generateGUID(List<Account> lstAccount)
    {
        
        final List<Schema.SObjectField> fieldsToUpdate = 
                                    new List<Schema.SObjectField>{Account.GUID__c};
                                    
        List<AccountModel> lstAccountModel = new List<AccountModel>();
        AccountModel oAccountModel;
        for(Account oAccountNew: lstAccount) 
        {
            if(String.isBlank(oAccountNew.GUID__c))
            {
	            oAccountModel = new AccountModel(new Account(Id = oAccountNew.Id));
	                
	        	oAccountModel.record.put('GUID__c', 
	                    GUIDServices.newGUID((String)(oAccountModel.record.get('Id'))));
	        	lstAccountModel.add(oAccountModel);
            }
        }
        
        if(!lstAccountModel.isEmpty())
         try{
                oAccountDAO.modify(lstAccountModel, fieldsToUpdate);
            }
            catch(dmlException dex){
				for( Integer errorIndex = 0; errorIndex < dEx.getNumDml(); errorIndex++ )
                {
                    lstAccountModel[errorIndex].record.addError( dEx.getDmlMessage( errorIndex ) );
                } 
            }
    }   
}