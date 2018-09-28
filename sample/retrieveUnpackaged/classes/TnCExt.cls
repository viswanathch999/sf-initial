public without sharing class TnCExt {
    
	private id contactId;
    public Contact con{get;set;}
    public Opportunity opp; 
   
    public TnCExt(ApexPages.StandardController oStandardController){
        try {
            if((Contact)oStandardController.getRecord()!= new Contact()){
                contactId = (id)oStandardController.getid();
            } else {
                User oUser = [Select Id,ContactId from User where Id =: UserInfo.getUserId()];
                if (oUser.ContactId != null) {
					contactId =  oUser.ContactId;
                } else {
					contactid = null;
                    throw new CustomException('No member Contact record found!');
                }
            }
            con = [SELECT Id, Name, Accept_Code_Conduct__c FROM Contact WHERE Id =: contactId];
        
			Opp = ContactServices.getOpportunities(con);

        } catch (Exception excpt) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Excpt.getMessage()));
        } 
    }
    public PageReference goBack(){
    	PageReference pr= new PageReference('/apex/Catalog_YPO');
    	return pr;
    }
    public PageReference save(){
        PageReference finalPg = new PageReference('/apex/Checkout_Check_Wire_YPO');
        finalPg.setRedirect(true);
        if(!con.Accept_Code_Conduct__c){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Kindly_Agree_Code_Conduct));
            return null;
        }
        try{
            opp.Code_of_Conduct_Accepted__c = con.Accept_Code_Conduct__c;
            update opp;
        }
        catch(Dmlexception dEx){
            Apexpages.addMessages(dEx);
            return null;
        }
        return finalPg;
    }

}