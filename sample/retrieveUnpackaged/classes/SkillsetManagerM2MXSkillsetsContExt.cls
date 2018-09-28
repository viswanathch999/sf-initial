/*
 * 
 * SkillsetManagerM2MXSkillsetsContExt is a extension class for Skillset Manager page. 
 * This class will cater addition/removal of Skillset for contact.
 *
 * @author Malay Desai
 */
public with sharing class SkillsetManagerM2MXSkillsetsContExt {
    
     Id contactId;
    @TestVisible static Id testContactId;    
    public M2MX_Skillsets__c oSkillset{get; set;}
    public List<ExpertiseWrapper> oSkillsetExpertise {get; private set;}
    
    public List<M2MX_Skillsets__c> lstSkillsets{ 
        get{
            if(String.isNotEmpty(contactId)){
                return [SELECT Id, Category__c, Sub_Category__c, Expertise__c, Contact__c FROM M2MX_Skillsets__c WHERE Contact__c =: contactId ORDER BY Category__c];        
            }else{
                return null;
            }
        } 
        private set;
    }
    
    public SkillsetManagerM2MXSkillsetsContExt(ApexPages.StandardController oSkillsetController){
        if(!Test.isRunningTest()){
            oSkillsetController.addFields(new List<String>{'Contact__c'});
            contactId = ((M2MX_Skillsets__c)oSkillsetController.getRecord()).Contact__c;
        }else{
            contactId = testContactId;
        }
        oSkillsetExpertise = new List<ExpertiseWrapper>();
        oSkillset = new M2MX_Skillsets__c(Contact__c = contactId);    
        //resetSkillset();
    }
    
    public void filterExpertise() {
        this.oSkillsetExpertise.clear();
        for(Skillsets_Expertise__c eachExpertise : [Select Expertise__c, Category__c, Sub_Category__c 
                                                    From Skillsets_Expertise__c 
                                                    Where Category__c = :oSkillset.Category__c 
                                                    And Sub_Category__c = :oSkillset.Sub_Category__c]){
            oSkillsetExpertise.add(new ExpertiseWrapper(eachExpertise));                
        }
    }
    
    public void saveSkillset(){
        List<M2MX_Skillsets__c> skillsetsToInsert = new List<M2MX_Skillsets__c>();
        for(ExpertiseWrapper eachRecord :oSkillsetExpertise) {
            if(eachRecord.isChecked) {
                skillsetsToInsert.add(new M2MX_Skillsets__c(Contact__c = contactId, Category__c=eachRecord.record.Category__c, Sub_Category__c=eachRecord.record.Sub_Category__c, Expertise__c=eachRecord.record.Expertise__c));
            }
        }
        insert skillsetsToInsert;
        //resetSkillset();
    }
    public void saveOtherSkillset(){
        M2MX_Skillsets__c otherSkillSet = new M2MX_Skillsets__c(Contact__c = contactId, Category__c=oSkillset.Category__c, Sub_Category__c=oSkillset.Sub_Category__c,
                                         Expertise__c=oSkillset.Expertise__c);
        try{
            insert otherSkillSet;
        }
        catch(DmlException dEx){
                ApexPages.addmessages(dEx);
            return;
        }    
    }
    
    /*private void resetSkillset(){
        oSkillset = new M2MX_Skillsets__c(Contact__c = contactId);    
    }*/
    
    private class ExpertiseWrapper {
        public Boolean isChecked { get; set; }
        public Skillsets_Expertise__c record { get; private set; }
        
        public ExpertiseWrapper(Skillsets_Expertise__c rec) {
            this.record = rec;
            this.isChecked = false;
        }
    }
}