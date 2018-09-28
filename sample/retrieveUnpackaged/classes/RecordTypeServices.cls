public with sharing class RecordTypeServices {
   
    private static List<RecordType> allRecordTypes {
        get{
            if (allRecordTypes == null)
                allRecordTypes = [select Id, Name, DeveloperName, SObjectType from RecordType];
               
            return allRecordTypes;
        }
        set;
    }
   
    public static List<RecordType> getRecordTypesForSObjectType(string sObjectType) {
        List<RecordType>rts = new List<RecordType>();
        for (RecordType rt : allRecordTypes) {
            if (rt.SobjectType == sObjectType) rts.add(rt);
        }
        return rts;
    }
     public static RecordType getRecordTypeByName(String name, String sObjectType){
        for (RecordType rt : allRecordTypes) {
            if (rt.SobjectType == sObjectType&&rt.Name == name) return rt;
        }       
        return null;
     }
     
     public static RecordType getRecordTypeByDeveloperName(String developer_name, String sObjectType){
        for (RecordType rt : allRecordTypes) {
            if (rt.SobjectType == sObjectType&&rt.DeveloperName == developer_name) return rt;
        }       
        return null;
     }
     
     public static RecordType getRecordTypeById(Id recordTypeId){
        for (RecordType rt : allRecordTypes) {
            if (rt.Id == recordTypeId) return rt;
        }       
        return null;
     }

	 public static Map<String, Schema.RecordTypeInfo> getRecordType(String sObjectName){
		Map<String, Schema.RecordTypeInfo> recordTypeName = new Map<String, Schema.RecordTypeInfo>();
		DescribeSObjectResult result = Schema.getGlobalDescribe().get(sObjectName).getDescribe();

		for(String rt : result.getRecordTypeInfosByName().keySet()){
			recordTypeName.put(rt, result.getRecordTypeInfosByName().get(rt));
		}

		return recordTypeName;
	 }

}