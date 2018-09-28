public class v_InvoiceExt  {
	
	public Boolean isLifetime {get; private set;}

	public v_InvoiceExt(ApexPages.StandardController StndContr) {
		id InvId = StndContr.getId();

		Id oppId = [SELECT KGRenewal__Opportunity__c FROM KGRenewal__Invoice__c WHERE Id =: InvId LIMIT 1].KGRenewal__Opportunity__c;
		isLifetime = OpportunityServices.IsLifetimeProductIncluded(oppId);
	}

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

}