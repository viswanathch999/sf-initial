public without sharing class SplashScreenController_YPO {
	static final String CONST_MEMBER = 'Member';
	static final String CONST_FORMER_MEMBER = 'Former_Member';
	static final String CONST_CONTACT = 'Contact';
	public Boolean isMember { get; set; }
	public Contact oContact { get; set; }
	public Opportunity oOpp;

	public Boolean isCheckWire {
		get {
			if (isCheckWire == null)
			{
				isCheckWire = false;
			}
			return isCheckWire;
		} set;
	}

	public Boolean isCreditCard {
		get {
			if (isCreditCard == null)
			{
				isCreditCard = false;
			}
			return isCreditCard;
		} set;
	}

	public static Boolean isThirdPartyCertify {
		get {
			if (isThirdPartyCertify == null) {
				isThirdPartyCertify = false;
			}

			return isThirdPartyCertify;
		}
		set; }

	public static Boolean isLifetime {
		get {
			if (isLifetime == null) {
				isLifetime = false;
			}

			return isLifetime;
		}
		set; }

	public boolean displayTransitionModal {
		get {
			if (displayTransitionModal == null) {

				if (ApexPages.currentPage().getParameters().get('Modal') == 'Transition') {
					displayTransitionModal = true;
				} else {
					displayTransitionModal = false;
				}
			}
			return displayTransitionModal;
		} set;
	}

	public boolean displayGraceModal {
		get {
			if (displayGraceModal == null) {

				if (ApexPages.currentPage().getParameters().get('Modal') == 'Grace') {
					displayGraceModal = true;
				} else {
					displayGraceModal = false;
				}
			}
			return displayGraceModal;
		} set;
	}

	Id memberRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_MEMBER, CONST_CONTACT).Id;
	Id formerMemberRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName(CONST_FORMER_MEMBER, CONST_CONTACT).Id;

	public SplashScreenController_YPO(Apexpages.StandardController oStandardController) {
		System.debug('On the Thankyou Page');
		try {
			if ((Contact) oStandardController.getRecord() != new Contact()) {
				oContact = (Contact) oStandardController.getRecord();
				getContact(oContact.id);
			} else {
				User oUser = [Select Id, ContactId from User where Id = :UserInfo.getUserId()];
				if (oUser.ContactId != null) {
					getContact(oUser.ContactId);
				} else {
					throw new CustomException('No member Contact record found!');
				}
			}

			isLifetime = oContact.Interested_in_Lifetime_member_option__c;
			//isMember = (oContact.RecordTypeId==memberRecordTypeId?true:false); 
			isMember = ((oContact.RecordTypeId == memberRecordTypeId || oContact.RecordTypeId == formerMemberRecordTypeId) ? true : false);

			oOpp = getOpportunity(oContact.id);

			if (oOpp != null) {
				System.debug('Current status - StageName: ' + oOpp.StageName + ' Cert Status: ' + oOpp.Certification_Type__c + ' Cert Page Exch status:' + oOpp.Certification_Page_Status_Exchange__c);
				if (oOpp.Certification_Page_Status_Exchange__c != 'Complete') {
					isThirdPartyCertify = true;
				}

				if (oOpp.StageName == 'Payment Pending') {
					isCheckWire = true;
				}

				if (oOpp.StageName == 'Payment Received' || oOpp.StageName == 'Closed Won') {
					isCreditCard = true;
				}
			}
			System.debug('*** credit: ' + isCreditCard + ' check: ' + isCheckWire + ' thirdparty: ' + isThirdPartyCertify);
		} catch(CustomException CExcp) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, CExcp.getMessage()));
		}
	}

	private void getcontact(id contactid) {
		oContact = [SELECT Name, Interested_in_Lifetime_Member_Option__c, LastName, Account.ParentId, HouseHoldID__c, AccountId, YPO_WPO__c, Grace_Years_Available__c,
		            Is_Grace_Used__c, Title, Number_of_Employees1__c, Total_Employee_Compensation__c, Last_Renewals_Page__c,
		            Annual_Revenue__c, Enterprise_Value__c, Transition_Status__c, Number_of_Employees__c, Last_Renewals_Form__c,
		            Age_Current__c, Number_Years_a_Member__c, RecordTypeId FROM Contact WHERE Id = :ContactId];
	}

	private Opportunity getOpportunity(id contactid) {
		Date NextFiscalStartDate = FiscalDateUtility.startOfNextFiscal;
		Date CurrentFiscalStartDate = FiscalDateUtility.startOfCurrentFiscal;

		try {
			for (Opportunity Oppts :[Select id, StageName, Certification_Page_Status_Exchange__c, Certification_Type__c, Opportunity_Type__c, Fiscal_Date_Start__c FROM Opportunity WHERE KGRenewal__Contact__c = :ContactId and StageName in('Payment Pending', 'Payment Received', 'Closed Won') order by CloseDate DESC]) {
				System.debug('Staging: ' + Oppts.StageName + ' Starting: ' + Oppts.Fiscal_Date_Start__c);
				If (Oppts.Opportunity_Type__c == 'Renewal') {
					if (Oppts.Fiscal_Date_Start__c == NextFiscalStartDate || Oppts.Fiscal_Date_Start__c == CurrentFiscalStartDate) {
						System.debug('Renewal Opportunity selected: ' + Oppts.id);
						return Oppts;
					}
				} else { //Not a Renewal
					if (Oppts.Fiscal_Date_Start__c == CurrentFiscalStartDate) {
						System.debug('Non-Renewal Opportunity selected: ' + Oppts.id);
						return Oppts;
					}
				}
			}
		} catch(Exception Excpt) {
			System.debug('SplashScreenController_YPO/getOpportunity: ' + Excpt.getMessage());
		}
		return null;
	}
}