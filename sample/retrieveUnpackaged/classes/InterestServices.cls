/*
 * 
 * InterestServices acts as an orchestrator and pulls together task or process  
 * logic typically utilising multiple object data.  
 * 
 * Class provides a strict encapsulation of code 
 * implementing business tasks, calculations & processes 
 * and is a key entry point to other layers.
 *
 * @author Shri K 
 */
public class InterestServices {

static List<String> lstSegmentAPINames = new List<String>{'S1', 'S2', 'S3', 'S4', 'S5', 'S6'};
    
    /**
     * update contacts segmentation fields depending on interestes selected.  
     * 
     * @param: lstNewInterest list of new interest. 
     * @param: mapOldInterest map of old interest.
     * @param: bIsInsert boolean variable tells whether it is Insert trigger.
     * @param: bIsUpdate boolean variable tells whether it is Update trigger.
     * @param: bIsDelete boolean variable tells whether it is Delete trigger.
     * @throws DMLException if there are any errors while saving records to database.
     */
    public static void calculateMarketingSegmentation(List<Interest__c> lstNewInterest, Map<Id, Interest__c> mapOldInterest, boolean bIsInsert, boolean bIsUpdate, boolean bIsDelete)
    {
        set<Id> setContact = new set<Id>();
        List<ContactModel> lstContactModel = new List<ContactModel>();
        
        if(bIsInsert || bIsUpdate)
        {
            for(Interest__c oInterest: lstNewInterest)
            {
                if(bIsInsert || bIsUpdate && oInterest.Interest__c != mapOldInterest.get(oInterest.Id).Interest__c)
                {
                    setContact.add(oInterest.Contact__c);
                }
            }
        }else if(bIsDelete)
        {
            for(Interest__c oInterest: mapOldInterest.values())
            {
                setContact.add(oInterest.Contact__c);
            }
        }
        
        if(setContact.isempty())
        {
            return;
        }
        
        Contact oContactNew;
        for(Contact oContact: [SELECT Id, (SELECT Id, Interest__c FROM Interests__r WHERE Interest__c != NULL) FROM Contact WHERE Id IN: setContact])
        {
            oContactNew = calculateAllSegmentationValues(oContact);
            if(!oContact.Interests__r.isEmpty())
            {
                for(String sSegmentation: lstSegmentAPINames)
                {
                    oContactNew = getContactSegmentationValues(oContactNew, sSegmentation, sSegmentation + '__c', 'Segment_Factor__c');
                }
            }
            lstContactModel.add(new ContactModel(oContactNew));
        }
        
        List<Schema.SObjectField> fieldsToUpdate = 
                                    new List<Schema.SObjectField>{Contact.S1__c, Contact.S2__c, Contact.S3__c, Contact.S4__c, Contact.S5__c, Contact.S6__c};
        if(!lstContactModel.isEmpty())
            ContactServices.contactDAO.modify(lstContactModel, fieldsToUpdate);
        
    }
    
    private static Contact calculateAllSegmentationValues(Contact oContact)
    {
        Contact oContactNew = new Contact(id = oContact.Id);
        for(Interest__c oInterest: oContact.Interests__r)
        {
            for(String sSegmentation: lstSegmentAPINames)
            {
                for(String sValue: oInterest.Interest__c.split(';'))
                {
                    String segmentationInterest = sSegmentation + '/' + sValue.replaceAll(' ', '');
                    String sizeRestrictedSegmentationInterest = (segmentationInterest.length() > 38) ? segmentationInterest.substring(0,37): segmentationInterest;
                    oContactNew = getContactSegmentationValues(oContactNew, sizeRestrictedSegmentationInterest, sSegmentation + '__c', 'Multiplication_Factor__c');
                }               
            }
        }   
        
        return oContactNew;
    }
    
    private static Contact getContactSegmentationValues(Contact oContact, String sCustomSettingKey, String sContactAPIName, String sCustomSetingAPIName)
    {
        Marketing_Segmentation__c oMarketingSegment = Marketing_Segmentation__c.getInstance(sCustomSettingKey);
        
        if(oMarketingSegment != null)
            oContact.put(sContactAPIName, ((decimal)oContact.get(sContactAPIName) == null ? 0:(decimal)oContact.get(sContactAPIName)) + (decimal)oMarketingSegment.get(sCustomSetingAPIName));    
        
        return oContact;
    }
}