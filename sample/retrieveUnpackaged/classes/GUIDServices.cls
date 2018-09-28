/*
 * 
 * GUIDServices is a service class for all the operations related to GUID generation. 
 * Class contains service methods GUID generation.
 *
 * @author Shri K
 */
 
public class GUIDServices {

    /*
     * Method to generate GUID from salesforce Id of the record. 
     * @param recordId is the id of the record whose GUID need to be generated.
     * @return GUID in string String format
     */
    public static String newGUID(String recordId)
    {
        if(String.isNotEmpty(recordId))
        {
        	Blob bRecordBinary = Blob.valueOf(recordId.subString(0, 15) );
        	String sHexValue = EncodingUtil.convertToHex(bRecordBinary);
        	//sHexValue = sHexValue.toUpperCase();
        	return sHexValue.subString(0, 8) + '-' + sHexValue.subString(8, 12) + '-' + sHexValue.subString(12, 16) + '-' + sHexValue.subString(16, 20) + '-'+ sHexValue.subString(20, 30) + '00';
        }else{
        	return null;
        }
    }
    public static void generateGUID(List<sObject> records)
    {
        List<sObject> recordsToUpdate = new List<sObject>();
        for(sObject aRecord: records) 
        {
            if(String.isBlank((String)aRecord.get('GUID__c')))
            {
                aRecord.put('GUID__c',
                            GUIDServices.newGUID((String)(aRecord.get('Id'))));
                recordsToUpdate.add(aRecord);
            }
        }
        if(!recordsToUpdate.isEmpty()){
            try{      
                update recordsToUpdate;
            }catch(DmlException dEx){
                for( Integer errorIndex = 0; errorIndex < dEx.getNumDml(); errorIndex++ )
                {
                    recordsToUpdate[errorIndex].addError(dEx.getDmlMessage(errorIndex));
                }
            }
        }
    }
    
}