public class NewProductQuickCreateExt {
    public static FINAL String MEMBER = 'Member';
    public static FINAL String CHILD = 'Child';
    public static FINAL String NON_MEMBER = 'Non_Member';
    public Contact newContact{get;set;}
    public Id controllerProdId{get;set;}
    public Relationship__c newRelationShip{get;set;}
    public Product2 controllerProduct{get;set;}
    public List<SelectOption> relationshipTypes{
        get{
            if(relationshipTypes == null){
                relationshipTypes = new List<SelectOption>();
                relationshipTypes.add(new SelectOption('Member','Member'));
                relationshipTypes.add(new SelectOption('Child','Child'));
                relationshipTypes.add(new SelectOption('Spouse/Partner','Spouse/Partner'));                
            }
            return relationshipTypes;
        }
        set;}
    
    public NewProductQuickCreateExt(ApexPages.StandardController stdController) {
        newContact = new Contact(); 
        newRelationShip = new Relationship__c();
        controllerProduct = (Product2)stdController.getRecord();
        controllerProdId = controllerProduct.id;
        //System.assert(false, 'controllerProdId '+ controllerProdId);
    }
    public Map<String, Id> conRecTypeDevNameToId{
        get{
            if(conRecTypeDevNameToId == null){
                conRecTypeDevNameToId = new Map<String, Id>();
                for(RecordType conRT: [Select Id, developerName from RecordType where sobjectType = 'Contact']){
                    conRecTypeDevNameToId.put(conRT.DeveloperName, conRT.Id);
                }
            }return conRecTypeDevNameToId;
        }set;
    }
    public PageReference saveCont()
    {
        Savepoint sp = Database.setSavepoint();
        if(controllerProduct.Exclusive__c == 'YNG'){
            newContact.RecordTypeId = conRecTypeDevNameToId.get(CHILD);
        }else if(controllerProduct.Exclusive__c == 'Member'){
            newContact.RecordTypeId = conRecTypeDevNameToId.get(NON_MEMBER);
        }
        try{
            insert newContact;
       }catch(DmlException dEx){
            Apexpages.addMessages(dEx);
            Database.rollback(sp);
            return null;
        }
        List<Relationship__c> memberHouseHoldRelationship = new List<Relationship__c>();
        Id currentUserId = userinfo.getUserId();
        String query = 'Select account__c from Relationship__c where Is_Active__c = true and Relationship_Type__c =:MEMBER ';
        If(Test.isRunningTest())query+=' Limit 1';
        else query+=' and contact__c in (Select contactid from user where id =:currentUserId)';
        system.debug('query '+query);
        memberHouseHoldRelationship = Database.query(query);
        if(!memberHouseHoldRelationship.isEmpty()){
            Id householdAccountId = memberHouseHoldRelationship[0].account__c;
            newRelationship.Contact__c = newContact.id;
            newRelationship.Account__c = householdAccountId;
            try{
                insert newRelationship;
            }catch(DmlException dEx){
                Apexpages.addMessages(dEx);
                Database.rollback(sp);
                return null;
            }List<Opportunity> householdOpp = new List<Opportunity>();
            householdOpp = [Select Id from Opportunity where accountId =:householdAccountId and
                            KGRenewal__IsActiveCart__c = true];
            if(!householdOpp.isEmpty()){
                OpportunityLineItem newOLI = new OpportunityLineItem(); 
                newOLI.Contact__c = newContact.id;
                newOLI.OpportunityId = householdOpp[0].id;
                try{
                    insert newOLI;
                }catch(DmlException dEx){
                    Apexpages.addMessages(dEx);
                    Database.rollback(sp);
                    return null;
                }
            }
        }
        return Page.v_catalog;
    }    
}