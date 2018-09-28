public class v_InvoicesControllerExt {
	
	public List<cInvoice> recs { get; set; } 
	private final KGRenewal.VenueInvoicesController venueCtrl { get; set; } 

	// constructor
  	public v_InvoicesControllerExt(KGRenewal.VenueInvoicesController ctrl) {
		recs = new List<cInvoice>();
		
		venueCtrl = ctrl;
		venueCtrl.sortField = 'Name';
		venueCtrl.sortDirection = 'DESC';
		venueCtrl.initializeInvoices();
		
		for (KGRenewal__Invoice__c inv : venueCtrl.invoices) {
			try { 
				Id oppId = [SELECT KGRenewal__Opportunity__r.Id FROM KGRenewal__Invoice__c WHERE Id = :inv.Id LIMIT 1].KGRenewal__Opportunity__r.Id;
				recs.add(new cInvoice(inv, oppId));
			}
			catch (Exception ex) { 
				ErrorLogUtil.insertErrorLogs(new List<Error_Log__c> {
					ErrorLogUtil.createErrorLog('', inv.Id, 'Error in v_InvoicesControllerExt: ' + ex.getMessage())
				});
			}
		}
	}


	// wrapper to add isLifetime boolean 
	public class cInvoice {
		public KGRenewal__Invoice__c invoice { get; set; } 
		public Boolean isLifetime { get; set; } 

		public cInvoice(KGRenewal__Invoice__c inv, Id oppId) {
			if (inv != null) invoice = inv;
			isLifetime = OpportunityServices.IsLifetimeProductIncluded(new Opportunity(Id = oppId));
		}
	}

}