public class YNG_OlisContactInfoUpdatePageExt{
    public List<opportunitylineitem> yngOLIs{get;set;}
    public Id stdContId{get;private set;}    
    public YNG_OlisContactInfoUpdatePageExt(ApexPages.StandardController stdCont){
        stdContId = stdCont.getId();               
    }   
    
    public PageReference onLoad(){
        String queryString = 'Select id, (Select id, product2.name, contact__c, contact__r.FirstName, contact__r.LastName,';
        List<String> fields = new List<String>();     
        for(Schema.FieldSetMember fld :SObjectType.opportunitylineitem.FieldSets.OliProductContactsAdditionalInfo.getFields()) {
            fields.add(fld.getFieldPath());
        }
        queryString += String.join(fields, ',');
        queryString += ' from opportunitylineitems where Product2.Exclusive__c=\'YNG\') '+
            'from opportunity where KGRenewal__IsActiveCart__c = true and KGRenewal__Contact__c =\''+stdContId+'\' Limit 1';
        try{
            Opportunity yngOpp = Database.query(queryString);
            yngOLIs = yngOpp.opportunitylineitems;
            if(yngOLIs == null || yngOLIs.isEmpty()){            
                Pagereference tnc = Page.CodeOfConduct_YPO;
                tnc.getParameters().put('id', stdContId);
                return tnc; 
            }
        }catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_ActiveCart_Opportunity_Found));
            return null;
        } 
        return null;
    }
    
    public PageReference saveProductsContact(){
        List<Contact> ContactsToBeUpdated = new List<Contact>();
        for(opportunitylineitem aOLI : yngOLIs){
            Contact prodCon = new Contact();
            prodCon.id = aOLI.contact__c;
            prodCon.FirstName = aOLI.contact__r.FirstName;
            prodCon.LastName = aOLI.contact__r.LastName;
            for(Schema.FieldSetMember field : SObjectType.opportunitylineitem.FieldSets.OliProductContactsAdditionalInfo.getFields()){
                String fieldname = field.getFieldPath().replace('Contact__r.', '');
                prodCon.put(fieldname, aOLI.getsobject('Contact__r').get(fieldname));                
            }
            ContactsToBeUpdated.add(prodCon);
        }
        try{
            update ContactsToBeUpdated;
        }
        catch(DmlException dEx){
            ApexPages.addMessages(dEx);
            return null;
        }
        Pagereference tnc = Page.CodeOfConduct_YPO;
        tnc.getParameters().put('id', stdContId);
        return tnc; 
    }
}