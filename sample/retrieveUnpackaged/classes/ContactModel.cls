/**
 * ContactModel is model class for contact object that encapsulates its state & 
 * behavior along with its closely related associations
 * 
 * @author Shri K
 */
public class ContactModel extends SObjectModel{
	/*public List<Contact> children;
	public List<Contact> spouse;
	
	
	public static final String CONST_CONTACT = 'Contact';
    public static final String CONST_SPOUSE = 'Spouse_Partner';
    public static final String CONST_CHILD = 'Child';
    public static final String CONST_YPO = 'YPO';
	public static final Id CONST_SPOUSE_RECORD_TYPE_ID = RecordTypeServices.getRecordTypeByDeveloperName(CONST_SPOUSE, CONST_CONTACT).Id;
    public static final Id CONST_CHILD_RECORD_TYPE_ID = RecordTypeServices.getRecordTypeByDeveloperName(CONST_CHILD, CONST_CONTACT).Id;
    public static final String CONST_YPO = 'YPO';*/
	public ContactModel(final Contact sobj) {
            super(sobj);
    }
     
     
     
    
   /* public void addChild(Contact child){
    	Contact con = (Contact)this.record;
    	if(children == null){
    		children = new List<Contact>();
    	}
    	children.add(child);
    } 
    
    public void addSpouse(Contact sp){
    	Contact con = (Contact)this.record;
    	if(spouse == null || spouse.IsEmpty()){
            spouse = new List<Contact>();
        }else if(spouse.size() >= 1){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Only one spouse/partner can be added'));
            return; 
        }
        spouse.add(sp);
    }
    
    public Boolean isYPO(){
    	Contact con = (Contact)this.record;
    	Boolean returnVal = true;
    	if(con.YPO_WPO__c != null){
    		returnVal = (con.YPO_WPO__c==CONST_YPO?true:false);
    	}     	
    	return returnVal;
    }
    
    public Boolean isGraceAvailable(){
    	Contact con = (Contact)this.record;
    	Boolean returnVal = false;
    	if(con.Grace_Years_Available__c != null && con.Is_Grace_Used__c != null ){
    		if((con.Grace_Years_Available__c > 0 && !con.Is_Grace_Used__c) || (con.Grace_Years_Available__c > 0 && !con.Is_Grace_Used__c)){
    			returnVal = true;
    		}
    	} 
    	return returnVal;
    }*/
    
}