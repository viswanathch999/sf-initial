global class BenefitAccountAffiliationYearEndBatch implements Database.Batchable<sObject>{
    
    private String Query;
    private String endOfFiscal = String.valueOf(FiscalDateUtility.getFiscalYear(Date.today()).EndDate);
    private String startOfFiscal = String.valueOf(FiscalDateUtility.getFiscalYear(Date.today().addYears(1)).StartDate);
    private List<Account_Affiliation__c> acctAffBenifit = new List<Account_Affiliation__c>();
    
    global BenefitAccountAffiliationYearEndBatch(){
        
        Query = 'Select Id, Start_Date__c, End_Date__c, isActive__c From Account_Affiliation__c ' + 
            'where RecordType.Name = \'Benefit\' and ((End_Date__c = ' + endOfFiscal + ' and isActive__c = true) or (Start_Date__c = ' + startOfFiscal + ' and isActive__c = false))';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug(Query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        For(Account_Affiliation__c acctAff : (List<Account_Affiliation__c>) scope){
            if(acctAff.End_Date__c == Date.valueOf(endOfFiscal) && acctAff.IsActive__c == true){
                System.debug('Old Event: ' + acctAff.End_Date__c + ' - ' + acctAff.isActive__c);
                acctAff.IsActive__c = false;
                acctAffBenifit.add(acctAff);
            }else if(acctAff.Start_Date__c == Date.valueOf(startOfFiscal) && acctAff.IsActive__c == false){
                System.debug('New Event: ' + acctAff.Start_Date__c + ' - ' + acctAff.isActive__c);
                acctAff.IsActive__c = true;
                acctAffBenifit.add(acctAff);	
            }
        }
        
        if(acctAffBenifit.size() > 0){
            try{
                update acctAffBenifit;
            }catch(DmlException e){
                System.debug(e);
            }
        }       
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}