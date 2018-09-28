public with sharing class RenewalsBatchServices {
    
    public static final String THIRD_PARTY_CERTIFY = 'Third Party Certify';
    public static final String SELF_CERTIFY = 'Self Certify';
    
    public static void setActiveCart( List<Opportunity> theOpps ){
        
        Set<Opportunity> oppsToUpdate = new Set<Opportunity>();
        
        List<Opportunity> inactiveCartOpps = new List<Opportunity>();
        for(Opportunity opp : theOpps){
            if(!opp.KGRenewal__IsActiveCart__c){
                inactiveCartOpps.add(opp);
            }
        }
        Set<Id> relatedContactIds = Pluck.Ids('KGRenewal__Contact__c', inactiveCartOpps);
        Map<Id, List<Opportunity>> otherOpps = GroupBy.ids('KGRenewal__Contact__c', [Select Id, KGRenewal__IsActiveCart__c, KGRenewal__Contact__c,
                                                                                     KGRenewal__Contact__r.Number_Years_a_Member__c,
                                                                                     KGRenewal__Contact__r.Tenure_FY17_c__c,
                                                                                     KGRenewal__Contact__r.Date_Last_Grace_Year_Used__c,
                                                                                     KGRenewal__Contact__r.YPO_WPO_Formula__c
                                                                                     FROM Opportunity WHERE KGRenewal__Contact__c 
                                                                                     IN: relatedContactIds
                                                                                     AND KGRenewal__IsActiveCart__c = true
                                                                                     AND Fiscal_Date_Start__c != :FiscalDateUtility.startOfNextFiscal]);
        Set<Id> thirdPartyContacts = Pluck.ids('contact__c', [Select contact__c FROM Contact_Position__c WHERE contact__c =: relatedContactIds
                                                              AND Start_Date__c >=: FiscalDateUtility.startOfCurrentFiscal.addYears(1)
                                                              AND Is_Officer_Position__c = true]);
        
        for(Opportunity opp : theOpps){
            //2213 ND 13/12/16 //
            if(opp.KGRenewal__Contact__c != null){
                if(opp.KGRenewal__Contact__r.Tenure_FY17_c__c!=null){
                    Integer yearsMember = (Integer)opp.KGRenewal__Contact__r.Tenure_FY17_c__c;
                    Decimal mod = Math.mod(yearsMember, 3);
                    if(mod == 0)opp.Certification_Type__c = THIRD_PARTY_CERTIFY;
                    else if(mod != 0 || yearsMember == 12)opp.Certification_Type__c = SELF_CERTIFY;
                }
                
                if(thirdPartyContacts.contains(opp.KGRenewal__Contact__c) ||( opp.KGRenewal__Contact__r.Date_Last_Grace_Year_Used__c != null &&
                   opp.KGRenewal__Contact__r.Date_Last_Grace_Year_Used__c.year() == system.today().year())){
                    opp.Certification_Type__c = THIRD_PARTY_CERTIFY;
                }
            }
            
            if(opp.KGRenewal__Contact__r.YPO_WPO_Formula__c == 'YPO'){
                opp.Certification_Status__c = 'Incomplete';
            }else if(opp.KGRenewal__Contact__r.YPO_WPO_Formula__c == 'YPO Gold'){
                opp.Certification_Status__c = 'Complete';
            }
            opp.StageName = 'Cycle Open';
            opp.KGRenewal__IsActiveCart__c = true;
            oppsToUpdate.add(opp);
            
            if(otherOpps.containsKey(opp.KGRenewal__Contact__c)){
                
                for(Opportunity activeOpp : otherOpps.get(opp.KGRenewal__Contact__c) ){
                    
                    activeOpp.KGRenewal__IsActiveCart__c = false; 
                    oppsToUpdate.add(activeOpp);
                    
                    if(activeOpp.Grace_status__c == 'Approved' && activeOpp.Next_Fiscal_Year_Date_Start__c.year() == (Date.Today().year() - 1)) {
                        opp.Certification_Type__c = THIRD_PARTY_CERTIFY;
                    }
                }
            }            
        }
        
        try{
            update new List<Opportunity> (oppsToUpdate);
        }catch(DMLException dmlex){
            //TODO: UPDATE ERROR HANDLING
            System.debug( 'DML Exception : '+ dmlex);
        }
    }
    
    public static void opportunitySetProductFlow( List<Opportunity> theOpp ){
        
        for(Opportunity opp : theOpp ){
            try{
                Map<String, Object> mapFlowInput = new Map<String, Object>{'varOpptyID' => opp.Id, 'varRefChapID' => opp.Referred_by_Chapter__c, 'varOppRecordType' => opp.Record_Type_Name__c};
                Flow.Interview.Set_Products setProductsFlow = new Flow.Interview.Set_Products(mapFlowInput); 
                setProductsFlow.start();
            }catch(Exception ex){
                System.debug( 'Error calling set products flow for record : '+ opp.Id + ': '+ ex.getMessage());
            	
            	String sMessage= 'ERROR: An exception has occurred. Please contact your System Administrator quoting the following message -- '
                + ex.getTypeName() + ':'+ex.getMessage() + ':' + ex.getLineNumber() + ':' + ex.getStackTraceString();
            
	            List<String> emailAddrs = new List<String>();
	            emailAddrs.add('ross.freeman@bluewolgroup.com');
	            emailAddrs.add('taylor.poppell@bluewolgroup.com');
	            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	            String[] toAddresses = emailAddrs;
	            mail.setToAddresses(toAddresses) ;
	            mail.setSubject('Exception occurred while running Set Products');
	            
	            String body = '<html lang="ja"><body>'+
	                '<br><br>'+
	                'An exception occurred during the Set Products Batch on the following record: ' + opp.Id + '.'+
	                '<br><br>'+
	                '<b>'+
	                'Here is detail of Exception '+
	                '</b>'+
	                '<br><br>'+ sMessage+
	                '</body></html>';
	            mail.setHtmlBody(body);
	            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
        
        
    }
}