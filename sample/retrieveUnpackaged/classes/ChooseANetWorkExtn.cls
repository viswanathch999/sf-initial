public without sharing class ChooseANetWorkExtn {

    public Contact oContact {get;set;}
    
    public String selectedAccountId {set;get;}
    Map<Id,Account> MapAccounts;
    public List<selectBusinessNetWork> AccountBusinessNetwork {set;get;}

    public ChooseANetWorkExtn(ApexPages.StandardController oStandardController) {
        AccountBusinessNetwork  = new List<selectBusinessNetWork>();
        //if(!Test.isRunningTest()) {
            //oStandardController.addFields(new List<String>{'Business_Network__c'});
        //}
        try {
			Id conId = null;
            if((Contact)oStandardController.getRecord()!= new Contact()){
                conId = (id)oStandardController.getid();
            } else {
                User oUser = [Select Id,ContactId from User where Id =: UserInfo.getUserId()];
                if (oUser.ContactId != null) {
					conId =  oUser.ContactId;
                } else {
					conId = null;
                    throw new CustomException('No member Contact record found!');
                }
            }
			oContact = [Select Id, Business_Network__c From Contact Where Id = :conId];
	        getAccountBusiNetwork();

        } catch (CustomException CExcp) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, CExcp.getMessage()));
        } 
    }

    public void getAccountBusiNetwork(){
		
		//US8552 - Restrict the map list to only Active business networks
        MapAccounts = new Map<Id,Account>([SELECT Id,Name,Description From Account where Parent.Name = 'Business' AND Type = 'Business' AND Category__c = 'Public' AND Status__c = 'Active' ORDER BY Name]);
        
        if(!MapAccounts.isEmpty()){
            for(Account oBusinessNetwork : MapAccounts.values()){
                selectBusinessNetWork selectBusnet;
                
                if(oContact.Business_Network__c == oBusinessNetwork.Name){
                    selectBusnet = new selectBusinessNetWork(true, oBusinessNetwork);
					selectedAccountId = oBusinessNetwork.Id;
                } else {
                    selectBusnet = new selectBusinessNetWork(false, oBusinessNetwork);
                }
                AccountBusinessNetwork.add(selectBusnet);
            }
        }  
    }
    
    public PageReference goBack(){
        return new PageReference('/apex/updateprofileinfo_ypo?id='+ocontact.id);
    }    
    
    public PageReference updateContact(){
        system.debug('**********selectedAccountId ***************'+selectedAccountId );
		PageReference pageRef = null;
        try{        
            oContact.Business_Network__c = MapAccounts.get(selectedAccountId).Name;    
            update oContact;
			pageRef = new PageReference('/apex/catalog_ypo?id='+ocontact.Id);
        }catch(Exception e){
            System.debug('Exception in update Contact');
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, 'Be sure to select a network before continuing.  Contact Member Services with any questions you might have.'));
        }

        //pageRef.setRedirect(true);
        return pageRef;
    }
    
    public class selectBusinessNetWork{
    
        public Boolean isSelectedBuniness {set;get;}
        public Account AccBusinessNetwork {set;get;}
        
        public selectBusinessNetWork(Boolean  isselected , Account accountBN){
            isSelectedBuniness = isselected;
            AccBusinessNetwork = accountBN;
        
        }
    }
}