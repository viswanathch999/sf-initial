public with sharing class AddProductsForQ4Prospects {
    @InvocableMethod(label='Set Products For Q4 Prospects' description='Creates OLIs For Q4 Prospects')
    public static void AddProductsForQ4(List<Opportunity> opps) {
    	System.debug('###opps: ' + opps);
    	
    	Set<String> chapterDues = new Set<String>{'New Member Only', 'All Members'};
    	List<OpportunityLineItem> olisToInsert = new List<OpportunityLineItem>();
    	
    	//List<Opportunity> opps= [SELECT Id, Fiscal_Date_Start__c FROM Opportunity WHERE Id IN: oppIds LIMIT 1];
    	Opportunity oOpp;
    	
    	if(!opps.isEmpty()) {
    		oOpp = opps[0];
    		System.debug('###oOpp: ' + oOpp);
    		Date fiscalStart = oOpp.Fiscal_Date_Start__c;
    		Date nextFiscalStart = fiscalStart.addYears(1);
    		System.debug('###fiscal: ' + fiscalStart);
    		System.debug('###nextfiscal: ' + nextFiscalStart);
    		Id targetChapterQ4Id = oOpp.Referred_by_Chapter__c;
    		
    		Contact oContact = new Contact();
    		
    		List<Contact> relatedContacts = [SELECT Id, Primary_Country__c, Member_Tier__c FROM Contact WHERE Id =: oOpp.KGRenewal__Contact__c LIMIT 1];
    		if(!relatedContacts.isEmpty()) {
    			oContact = relatedContacts[0];
    		}
    		System.debug('###relatedContacts: ' + relatedContacts);
    		System.debug('###oContact: ' + oContact);
    		
			List<Account_Affiliation__c> secondaryAffs = [SELECT Id, Account__c, Is_Primary__c, IsActive__c FROM Account_Affiliation__c WHERE Account__c =: targetChapterQ4Id AND IsActive__c = true AND Is_Primary__c = false AND Contact__c =: oContact.Id];
			
			System.debug('###secondaryAffs: ' + secondaryAffs);
			Boolean secondaryAffsExist;
			
			if(secondaryAffs.isEmpty()) {
				secondaryAffsExist = false;
			}
			
			else {
				secondaryAffsExist = true;
			}
			
			System.debug('###secondaryAffsExist: ' + secondaryAffsExist);
			
    		/*List<Product2> relatedProducts = [SELECT Id, Account__c, Chapter_Dues__c, IsActive, Product_Type__c 
    										  FROM Product2 
    										  WHERE Account__c =: targetChapterQ4Id 
    										  AND (Chapter_Dues__c = '' 
    										       OR Chapter_Dues__c IN :chapterDues)
    										  AND IsActive = true
    										  AND ((Product_Type__c = 'Primary' 
    										  	   OR Product_Type__c = 'Initiation' 
    										  	   OR (Product_Type__c = 'Primary Initiation' AND Fiscal_Date_Start__c =: fiscalStart)
    										  	   OR (Product_Type__c = 'Secordary Initiation' AND Fiscal_Date_Start__c =: fiscalStart))
										  	  OR (Country__c =: oOpp.KGRenewal__Contact__r.Primary_Country__c AND Country__c != '' AND Tier_Number__c =: oOpp.KGRenewal__Contact__r.Member_Tier__c AND Fiscal_Date_Start__c =: nextFiscalStart))];
    		
    		*/
    		
    		List<Product2> relatedProducts = [SELECT Id, Account__c, Chapter_Dues__c, IsActive, Product_Type__c, Tier_Number__c, Country__c
    										  FROM Product2 
    										  WHERE IsActive = true
    										  AND (
    										  		(
    										  		 Account__c =: targetChapterQ4Id
    										  		 AND (Chapter_Dues__c = '' OR Chapter_Dues__c IN :chapterDues)
    										  		 AND( 
	    										         Product_Type__c = 'Primary'
	    										         OR (Product_Type__c = 'Primary Initiation' AND Fiscal_Date_Start__c =: fiscalStart)
	    										         OR (Product_Type__c = 'Secondary Initiation' AND Fiscal_Date_Start__c =: fiscalStart)
    										         )
    										  		)
    										       OR 
    										        ((Country__c =: oContact.Primary_Country__c AND Country__c != '') 
    										         	AND Tier_Number__c =: oContact.Member_Tier__c 
    										         	AND Fiscal_Date_Start__c =: nextFiscalStart
										         	)
										           )
									           ];
    		System.debug('###relatedProducts: ' + relatedProducts);
    		
    		if(!relatedProducts.isEmpty()) {
    			System.debug('###inside relProds');
    			Pricebook2 stdPriceBook = [SELECT id, name FROM Pricebook2 WHERE isStandard = true LIMIT 1];
    			List<PriceBookEntry> pbes = [SELECT Id, UnitPrice, Product2Id FROM PriceBookEntry WHERE Product2Id IN :relatedProducts AND PriceBook2Id =: stdPriceBook.Id];
    			System.debug('###Pbes: ' + pbes);
    			Map<Id, List<PricebookEntry>> product2ToPBEs = GroupBy.Ids('Product2Id', pbes);
    			System.debug('###product2ToPBEs: ' + product2ToPBEs);
    			
    			for(Product2 prod : relatedProducts) {
    				if((prod.Product_Type__c == 'Secondary Initiation' && secondaryAffsExist) || prod.Product_Type__c != 'Secondary Initiation') {
	    				System.debug('###prod: ' + prod);
	    				OpportunityLineItem oli = new OpportunityLineItem();
	    				oli.OpportunityId = oOpp.Id;
	    				oli.Quantity = 1;
	    				oli.PricebookEntryId = product2ToPBEs.get(prod.Id)[0].Id;
	    				oli.UnitPrice = product2ToPBEs.get(prod.Id)[0].UnitPrice;
	    				olisToInsert.add(oli);
    				}
    				
    			}
    			
    			if(!olisToInsert.isEmpty()) {
    				insertOLIs(olisToInsert);
    			}
    		}
    	}
    }
    
    public static void insertOLIs(List<OpportunityLineItem> olisToInsert) {
    	try {
    		insert olisToInsert;
    	}catch(DMLException dEx) {
    		String sMessage= 'ERROR: An exception has occurred. Please contact your System Administrator quoting the following message -- '
                + dEx.getTypeName() + ':'+dEx.getMessage() + ':' + dEx.getLineNumber() + ':' + dEx.getStackTraceString();
            
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage() ;
            String[] toAddresses = Chapter_Health_Batch_Error_Email_Setting__c.getInstance().Error_Email_Recipients__c.split(';');
            //mail.setTreatTargetObjectAsRecipient(false);
            mail.setToAddresses(toAddresses) ;
            mail.setSubject('Exception occurred while deleting Lead Shares');
            
            String body = '<html lang="ja"><body>'+
                '<br><br>'+
                'This email alert is to bring to your notice that exception occured  while inserting OLIs while Adding Q4 Products for Prosepcts'+
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