/**
 * 
 * TaskServices acts as an orchestrator and pulls together task or process  
 * logic typically utilising multiple object data.  
 * 
 * Class provides a strict encapsulation of code 
 * implementing business tasks, calculations & processes 
 * and is a key entry point to other layers.
 *
 * @author Malay Desai
 */
public class TaskServices {

    static final String CONST_TASK = 'Task';
    static final String CONST_M2MX = 'M2MX';
    static final String CONST_CONTACT = 'Contact';
    static final String M2MX_TASK_RECORDTYPEID = RecordTypeServices.getRecordTypeByName(CONST_M2MX,CONST_TASK).Id;
    static final String CONST_CONTACT_KEY_PREFIX = Schema.getGlobalDescribe().get(CONST_CONTACT).getDescribe().getKeyPrefix();
    static final private ContactDAO oContactDAO = new ContactDAO(DAOStrategyType.DMLDAOStrategy);
    
    
    /**
     * When a Task with record type M2MX is created on Contact record, this method updates the Date_Last_M2MX_Request_Email__c with task created date
     *  
     * @param List of Task
     * @return null
     */
    public static void updateLastContactedOnContact(List<Task> newTasks){
        List<Contact> lstContact = new List<Contact>(); 
        Map<Id,DateTime> contactIdVsCreatedDate = new Map<Id,DateTime>();
        Map<Id,Contact> contactMap; 
        for(Task task : newTasks){
            if(task.whoId != null && String.valueOf(task.whoId).subString(0,3).equalsIgnoreCase(CONST_CONTACT_KEY_PREFIX) && task.recordTypeId == M2MX_TASK_RECORDTYPEID){
                contactIdVsCreatedDate.put(task.whoId,task.CreatedDate);
            }
        }
        
        if(!contactIdVsCreatedDate.isEmpty()){ 
        	List<Contact> lst2Contact = new List<Contact>();
        	final List<Schema.SObjectField> contactFields = new List<Schema.SObjectField> {Contact.Id, Contact.Date_Last_M2MX_Request_Email__c}; 
        	List<SObjectModel> lstContactModels = oContactDAO.getM2MXContacts(contactFields,contactIdVsCreatedDate.keySet()) ;
        	for(SObjectModel oContactModel : lstContactModels){
        		lst2Contact.add((Contact)oContactModel.record);
        	}
            contactMap = new Map<Id,Contact>(lst2Contact);
        }
        
        if(contactMap != null && !contactMap.isEmpty()){
            for(Id contactId: contactIdVsCreatedDate.keySet()){        
                DateTime dt =  contactIdVsCreatedDate.get(contactId);
                Contact oContact = contactMap.get(contactId);
                oContact.Date_Last_M2MX_Request_Email__c = Date.newinstance(dt.year(), dt.month(), dt.day());
                lstContact.add(oContact);
            }
        }
        if(!lstContact.isEmpty()){
        	List<SObjectModel> lstContactModel = oContactDAO.read(lstContact);
        	final List<Schema.SObjectField> contactFields = new List<Schema.SObjectField> {Contact.Date_Last_M2MX_Request_Email__c};
        	oContactDAO.modify(lstContactModel,contactFields);
        }
    }
    public static void validateDeleteAllowed(List<Task> oldTasks){
        for (Task oldTask : oldTasks)      
       {            
          if (!oldTask.Able_to_Delete_Activities__c)
          {
             oldTask.addError(Label.Cant_Delete_Task);
          }
       }
    }
}