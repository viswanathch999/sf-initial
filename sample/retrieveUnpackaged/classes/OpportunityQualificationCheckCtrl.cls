public class OpportunityQualificationCheckCtrl  {
	
	public FINAL String PASS_MSG = ' meets qualifcation criteria for the specified contact.';
	public FINAL String FAIL_MSG = ' does not meet qualifcation criteria for the specified contact.';
	public FINAL String ORGTYPE_SALES = 'Sales';
	public FINAL String ORGTYPE_SVC = 'Service';
	public FINAL String ORGTYPE_MFG = 'Manufacturing';
	public FINAL String ORGTYPE_AGENCY = 'Agency-type';
	public FINAL String ORGTYPE_FINANCE = 'Financial Institution';

	public Opportunity opp { get; set; } 
	public List<Qualification> results { get; set; } 
	public Boolean processComplete { get; set; } 


	// Treat null decimals as zero
	public Decimal ifNull(Decimal num) {
		if (num == null) num = 0;
		return num;
	}


	// Contstructor
	public OpportunityQualificationCheckCtrl() {
		opp = new Opportunity();
		results = new List<Qualification>();
		processComplete = false;

		try { 
			opp = [SELECT Id, Name, NumberOfEmployees__c, Total_Employee_Compensation__c, AnnualRevenue__c, Enterprise_Value__c, Organization_Type__c, 
						KGRenewal__Contact__c, KGRenewal__Contact__r.Annual_Revenue__c, KGRenewal__Contact__r.Annual_Fees__c, KGRenewal__Contact__r.Annual_Assets__c, 
						KGRenewal__Contact__r.Total_Employee_Compensation__c, KGRenewal__Contact__r.Enterprise_Value__c, KGRenewal__Contact__r.Number_of_Employees__c, 
						KGRenewal__Contact__r.Number_of_Employees_opt_2__c, Enterprise_Type__c
				   FROM Opportunity 
				   WHERE Id = :ApexPages.currentPage().getParameters().get('id')
				   LIMIT 1];
		}
		catch (Exception ex) {
			System.debug('OpportunityQualificationCheckCtrl could not get the opportunity.');
		}
	}


	// Logic
	public void checkQualifications() { 
		System.debug(opp.NumberOfEmployees__c + ' ' + opp.KGRenewal__Contact__r.Number_of_Employees__c);

		// Requirement A
		if (opp.NumberOfEmployees__c >= ifNull(opp.KGRenewal__Contact__r.Number_of_Employees__c)) { 
			results.add(new Qualification('Requirement A', true, PASS_MSG));
		} 
		else if (opp.NumberOfEmployees__c >= ifNull(opp.KGRenewal__Contact__r.Number_of_Employees_opt_2__c) 
				&& opp.Total_Employee_Compensation__c >= ifNull(opp.KGRenewal__Contact__r.Total_Employee_Compensation__c))
		{
			results.add(new Qualification('Requirement A', true, PASS_MSG));
		}
		else {
			results.add(new Qualification('Requirement A', false, FAIL_MSG));
		}
		System.debug('Req A: ' + results[0]);

		// Requirement B
		Double comparisonValue = 0;
		if (opp.Organization_Type__c == ORGTYPE_SALES || opp.Organization_Type__c == ORGTYPE_SVC || opp.Organization_Type__c == ORGTYPE_MFG) {
			comparisonValue = ifNull(opp.KGRenewal__Contact__r.Annual_Revenue__c);
		} 
		if (opp.Organization_Type__c == ORGTYPE_AGENCY) {
			comparisonValue = ifNull(opp.KGRenewal__Contact__r.Annual_Fees__c);
		}
		if (opp.Organization_Type__c == ORGTYPE_FINANCE) {
			comparisonValue = ifNull(opp.KGRenewal__Contact__r.Annual_Assets__c);
		} 

		// logic
		if (opp.AnnualRevenue__c >= comparisonValue) {
			results.add(new Qualification('Requirement B', true, PASS_MSG));
		}
		else if (opp.Enterprise_Value__c >= ifNull(opp.KGRenewal__Contact__r.Enterprise_Value__c)
				&& opp.Enterprise_Type__c != '' && opp.Enterprise_Type__c != null)
		{
			results.add(new Qualification('Requirement B', true, PASS_MSG));
		}
		else {
			results.add(new Qualification('Requirement B', false, FAIL_MSG));
		}
		System.debug('Req B: ' + results[1]);

		// Update Opportunity if both pass
		if (results[0].isQualified == true && results[1].isQualified == true) {
			try {
				opp.Certification_Status__c = 'Complete';
				update opp;
			}
			catch (DmlException dex) {
				results.add(new Qualification('', false, 'There was an error updating the Opportunity Certification field.  ' + 
														 'Please check Certification Type and update this field manually if necessary.'));
			}
		}

		processComplete = true;
	}


	// Wrapper
	public class Qualification {
		public String name { get; set; } 
		public Boolean isQualified { get; set; } 
		public String userMessage { get; set; } 

		public Qualification(String req, Boolean pass, String msg) {
			name = req;
			isQualified = pass;
			userMessage = msg;
		}
	}


}