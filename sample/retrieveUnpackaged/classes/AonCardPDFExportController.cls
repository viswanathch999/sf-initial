public with sharing class AonCardPDFExportController {
    
    private final Contact myContact ;
    public final Opportunity myOpp {
        get; set; 
    } 
    public List<String> familyMembers{get;set;}
    // The extension constructor initializes the private member
    // variable myContact by using the getRecord method from the standard
    // controller.
    public AonCardPDFExportController(ApexPages.StandardController stdController) {
        Set<Id> oppIdSet = new Set<Id>() ;        
        familyMembers = new List<String>();
        //if(!Test.isRunningTest())stdController.addfields(new List<String>{'name'});
        this.myContact = (Contact)stdController.getRecord();
        //familyMembers.add(myContact.name);
        if(myContact == null || myContact.id == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Error_Invalid_Id));
            return;
        }
        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
        for(OpportunityContactRole ocr: [SELECT ContactId, OpportunityId FROM OpportunityContactRole WHERE ContactId = :myContact.Id])
        {
            if(ocr.OpportunityId != null) 
                oppIdSet.add(ocr.OpportunityId) ;
        }
        if(!oppIdSet.isEmpty()){
            List<Opportunity> oppList = new List<Opportunity>();
            System.debug('*** QUERY:  SELECT CloseDate, StageName, IsClosed, IsWon, Probability, KGRenewal__ContractEffectiveDate__c,'+
                       'KGRenewal__ContractEndDate__c, (Select Contact__c, Contact__r.name, product2id from opportunitylineitems '+
                        'where product2.Worldaware_benefit__c = true and contact__c != null)'+
                       'FROM Opportunity WHERE IsClosed = true AND IsWon = true AND ' + 
                       'KGRenewal__contractEffectiveDate__c ='+ FiscalDateUtility.startOfCurrentFiscal	+ 
                       'AND Id IN :oppIdSet ORDER BY KGRenewal__ContractEffectiveDate__c DESC LIMIT 1');
            oppList = [SELECT CloseDate, StageName, IsClosed, IsWon, Probability, KGRenewal__ContractEffectiveDate__c,
                       KGRenewal__ContractEndDate__c, (Select Contact__c, Contact__r.name, product2id from opportunitylineitems 
                                                       where product2.Worldaware_benefit__c = true and contact__c != null)
                       FROM Opportunity WHERE IsClosed = true AND IsWon = true AND 
                       /*KGRenewal__IsActiveCart__c = true*/ KGRenewal__contractEffectiveDate__c =: FiscalDateUtility.startOfCurrentFiscal	
                       AND Id IN :oppIdSet ORDER BY KGRenewal__ContractEffectiveDate__c DESC LIMIT 1];      
            if(!oppList.isEmpty()){
                this.myOpp = oppList.get(0) ;
                system.debug('oppList[0].opportunitylineitems'+oppList[0].opportunitylineitems);
                for(opportunitylineitem oli :oppList[0].opportunitylineitems){
                    familyMembers.add(oli.Contact__r.name);
                }
            }
        }
        if(oppIdSet.isEmpty() || familyMembers.isEmpty()){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.No_AON_Subscription_found));
        }
    }
}