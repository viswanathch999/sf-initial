/**
* @author mfrizzell
* @description Controller for ThirdPartyCertificationPDF page
*/ 
public without sharing class ThirdPartyCertificationPDFCtrl  {
	
	final String STAGE_PMT_RECD = 'Payment Received';
	final String STAGE_CYCLE_OPEN = 'Cycle Open';
	final String OPP_TYPE_RENEW = 'Renewal';
    
	public Date fiscalStart { get; set; } 
	public Date fiscalEnd { get; set; }

    public String deadline { get; set; } 
	public String memberName { get; set; } 
	public String memberId { get; set; }
	public String chapterName { get; set; } 
	public String qualifyingCompany { get; set; }
	public String titleHeld { get; set; } 
	public String roleAtCompany { get; set; } 
	public String busAddress1 { get; set; } 
	public String busAddress2 { get; set; } 
	public String city { get; set; }
	public String stateProvince { get; set; } 
	public String country { get; set; }
	public String postalCode { get; set; } 
	public String businessSize { get; set; } 
	public String companyType { get; set; } 
	public String typeOfCorp { get; set; } 
	public String enterpriseType { get; set; } 
    
	public Decimal numOfEmployees { get; set; }
	public Decimal annualCompensation { get; set; } 
	public Decimal annualRevenue { get; set; } 
	public Decimal enterpriseValue { get; set; } 
    
	public Opportunity opp { get; set; } 
    
	public ThirdPartyCertificationPDFCtrl() {
        
		try {
			opp = [SELECT Id, Name, Qualifying_Company__c, Opp_Title_Formula__c, Fiscal_Date_Start__c, Next_Fiscal_Year_Date_Start__c, 
			            President_Type__c, QC_StreetAddress1__c, QC_StreetAddress2__c, QC_City__c, QC_State__c, QC_Country__c, 
			            QC_PostalCode__c, Business_Scope__c, Firm_Type__c, NumberOfEmployees__c, Total_Employee_Compensation__c, 
			            Organization_Type__c, AnnualRevenue__c, Enterprise_Type__c, Enterprise_Value__c, KGRenewal__Contact__c, 
						KGRenewal__Contact__r.Name, KGRenewal__Contact__r.Contact_Number__c, KGRenewal__Contact__r.Account.Name,
						KGRenewal__IsActiveCart__c, StageName, Opportunity_Type__c
					FROM Opportunity 
					WHERE KGRenewal__Contact__c = :ApexPages.currentPage().getParameters().get('Id')
					AND KGRenewal__IsActiveCart__c = true
					AND (StageName = :STAGE_CYCLE_OPEN OR StageName = :STAGE_PMT_RECD)
					AND Fiscal_Date_Start__c = :Date.newInstance(Date.today().year(), 07, 01)
					AND Opportunity_Type__c = :OPP_TYPE_RENEW
					LIMIT 1];
			
			fiscalStart = opp.Fiscal_Date_Start__c;
			fiscalEnd = opp.Next_Fiscal_Year_Date_Start__c.addDays(-1);

			Map<Integer, String> monthMap = new Map<Integer, String> {
				1 => 'January',
				2 => 'February',
				3 => 'March', 
				4 => 'April',
				5 => 'May',
				6 => 'June',
				7 => 'July',
				8 => 'August',
				9 => 'September',
				10 => 'October',
				11 => 'November',
				12 => 'December'
			};
			
			deadline = fiscalEnd.day() + ' ' + monthMap.get(fiscalEnd.month()) + ' ' + fiscalEnd.year();
			
			memberName = opp.KGRenewal__Contact__r.Name;
			memberId = opp.KGRenewal__Contact__r.Contact_Number__c;
			chapterName = opp.KGRenewal__Contact__r.Account.Name;
			qualifyingCompany = opp.Qualifying_Company__c;
			titleHeld = opp.Opp_Title_Formula__c;
			roleAtCompany = opp.President_Type__c;
			busAddress1 = opp.QC_StreetAddress1__c;
			busAddress2 = opp.QC_StreetAddress2__c;
			city = opp.QC_City__c;
			stateProvince = opp.QC_State__c;
			country = opp.QC_Country__c;
			postalCode = opp.QC_PostalCode__c;
			businessSize = opp.Business_Scope__c;
			companyType = opp.Firm_Type__c;
			numOfEmployees = opp.NumberOfEmployees__c;
			annualCompensation = opp.Total_Employee_Compensation__c;
			typeOfCorp = opp.Organization_Type__c;
			annualRevenue = opp.AnnualRevenue__c;
			enterpriseType = opp.Enterprise_Type__c;
			enterpriseValue = opp.Enterprise_Value__c;
		}
		catch (Exception ex) {
			System.debug('Error retrieving opportunity: ' + ex.getMessage() + ' @ line ' + ex.getLineNumber());
			ErrorLogUtil.createErrorLog('', 
										ApexPages.currentPage().getParameters().get('Id'), 
										'There was an error retrieving the opportunity values for the Third Party Certification PDF page: ' + ex.getMessage()
			);
		}

	}

}