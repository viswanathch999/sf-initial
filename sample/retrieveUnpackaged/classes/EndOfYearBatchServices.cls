public with sharing class EndOfYearBatchServices {


	public static void setActiveCart( List<Opportunity> theOpps ){
		
		List<Opportunity> oppsToUpdate = new List<Opportunity>();
		
		List<Opportunity> inactiveCartOpps = new List<Opportunity>();
		for(Opportunity opp : theOpps){
			if(!opp.KGRenewal__IsActiveCart__c){
				inactiveCartOpps.add(opp);
			}
		}
		
		Map<Id, List<Opportunity>> otherOpps = GroupBy.ids('KGRenewal__Contact__c', [Select Id, KGRenewal__IsActiveCart__c, KGRenewal__Contact__c 
																					FROM Opportunity WHERE KGRenewal__Contact__c 
																					IN: Pluck.Ids('KGRenewal__Contact__c', inactiveCartOpps) 
																					AND KGRenewal__IsActiveCart__c = true]);
	
		for(Opportunity opp : theOpps){
			
			opp.KGRenewal__IsActiveCart__c = true;
			oppsToUpdate.add(opp);
			
			if(otherOpps.containsKey(opp.KGRenewal__Contact__c)){
				
				for(Opportunity activeOpp : otherOpps.get(opp.KGRenewal__Contact__c) ){
					
					activeOpp.KGRenewal__IsActiveCart__c = false; 
					oppsToUpdate.add(activeOpp);
				}
			}
		}
		
		try{
			update oppsToUpdate;
		}catch(DMLException dmlex){
			//TODO: UPDATE ERROR HANDLING
			System.assert(false, 'DML Exception : '+ dmlex);
		}
	}
	
	public static void opportunitySetProductFlow( List<Opportunity> theOpp ){
		
		for(Opportunity opp : theOpp ){
			Map<String, Object> mapFlowInput = new Map<String, Object>{'varOpptyID' => opp.Id};
	            
	        Flow.Interview.Set_Products setProductsFlow = new Flow.Interview.Set_Products(mapFlowInput); 
	        setProductsFlow.start();
		}
		
		
	}
}