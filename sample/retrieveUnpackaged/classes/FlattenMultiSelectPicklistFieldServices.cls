/**
* FlattenMultiSelectPicklistFieldServices used by FlattenMultiSelectPicklistFieldBatch
* for translating and copying the data from multiple multiselect picklists defined 
* in custom setting M2MXSkillsetSearchObject
* into a text field containing the concatenation from all the multiselect fields
*
* @author Nikunj Doshi
*/
public class FlattenMultiSelectPicklistFieldServices {
    static final string DELIMETER = ',';
    /**
* Map of Object Name to it`s corresponding M2MX_Skillset_Search_Objects__c custom seting record..
*/
    public static Map<String, M2MX_Skillset_Search_Objects__c> mappingMap{
        get{
            if(mappingMap == null){
                mappingMap = new Map<String,M2MX_Skillset_Search_Objects__c>();
                for(M2MX_Skillset_Search_Objects__c mapping: M2MX_Skillset_Search_Objects__c.getAll().values())
                    mappingMap.put(mapping.API_Name__c , mapping);
            }
            return mappingMap;
        }private set;
    } 
    
    /**
* Returns list of multiselect picklists field api names
* specific to an object 
*  
* @param objectName API Name of the object
* @return List of String 
*/
    
    public Static List<String> getMultiSelectFieldNames(String objectName){
        system.debug(' mappingMap '+mappingMap);
        system.debug(' objectName '+objectName);
        List<String> retList = new List<String>();
        if(mappingMap.get(objectName).MultiselectPicklist_Field_API_Name__c != null)
            retList = mappingMap.get(objectName).MultiselectPicklist_Field_API_Name__c.split(DELIMETER);
        return retList;
    }
    
    /**
* Updates text field on records with concatenation of value from all the multiselect fields
* specific to an object 
*  
* @param scope List of sObjects to be updated
* @return null
*/
    public static void convertMultiSelectToText(List<sObject> scope){
        List<sObject> sObjectsToUpdate = new List<sObject>();
        for(sObject sObj: scope){
            String objectName = String.valueOf(sObj.getSObjectType());
            M2MX_Skillset_Search_Objects__c mapping = mappingMap.get(objectName);
            Integer i = 0;
            for(String fromField :getMultiSelectFieldNames(objectName)){
                String concatString = (String)sObj.get(fromField);
                if(i!=0 && sObj.get(mapping.Text_Field_API_Name__c) != null) 
                    concatString =concatString +';'+ sObj.get(mapping.Text_Field_API_Name__c);                    
                sObj.put(mapping.Text_Field_API_Name__c, concatString);         
                i++;
            }
            sObjectsToUpdate.add(sObj);
        }
        update sObjectsToUpdate;
    }
}