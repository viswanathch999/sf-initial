public class YPO_OpportunityPdfController {
    Public Opportunity opportunityRecordPDF
        {
        public get;
        public set
            {
                if(value == null || value.Id == null)
                {
                    opportunityRecordPDF = new Opportunity();
                    return;
                   }
                   opportunityRecordPDF = [SELECT Id, Amount,
                       (SELECT KGRenewal__Name__c,
                           TotalPrice
                           FROM OpportunityLineItems
                           ORDER BY KGRenewal__Name__c)
                        FROM Opportunity
                        WHERE Id = :value.Id];
            }
    }
}