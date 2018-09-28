public with sharing class RecordTypeHelper {

	public string objectName{ get; set;}
	public Id MASTER_RECORDTYPE_ID
    {
        get{ return '012000000000000AAA'; }
       
        private set;
    }
   
    public boolean useMasterRecordTypeId{
        get{
            return defaultRecordTypeId == MASTER_RECORDTYPE_ID;
        }
        private set;
    }
    
    public Id defaultRecordTypeId
    {
        get{
            if (defaultRecordTypeId == null )
            {
                defaultRecordTypeId = getDefaultRecordtypeId();
            }
            return defaultRecordTypeId;
        }
       
        private set;
    }   
    
    private Schema.SObjectType sobjectType{
    	
    	get{
    		if( sobjectType == null )
    			sobjectType = Schema.getGlobalDescribe().get( objectName );
			return sobjectType;    		
    	}
    	set;
    } 
    
    public RecordTypeHelper(String objName) {
    	this.objectName = objName;
    }
     
    public SObject newSobjectWithRecordTypeId( String objectName, Id recordTypeId, boolean loadDefaults )
    {
    	Sobject recordToReturn = sobjectType.newSObject(); 
    	
    	Id defaultRtype = recordTypeId == MASTER_RECORDTYPE_ID ? null : recordTypeId;
    	
    	SObject defaultObjectByRecordType = sobjectType.newSObject(defaultRtype, loadDefaults);
		Map<String, Schema.SObjectField> fieldMap = sobjectType.getDescribe().fields.getMap();
		
		for( String field : fieldMap.keySet())
		{
			Schema.DescribeFieldResult fieldDesc = fieldMap.get( field ).getDescribe();
			
			if( useMasterRecordTypeId && fieldDesc.getName() == 'recordtypeid')
				continue;
			
			if( fieldDesc.isCreateable())
				recordToReturn.put( fieldDesc.getName(), defaultObjectByRecordType.get( fieldDesc.getName()));
			
		}
		return recordToReturn;
    }
    
    public SObject newSobjectWithRecordTypeId( Id recordTypeId, boolean loadDefaults )
    {
		return newSobjectWithRecordTypeId( this.objectName, recordTypeId, loadDefaults );
    }
    
    private Id getDefaultRecordtypeId()
    {
        List<Schema.RecordTypeInfo> rtypeInfos = sobjectType.getDescribe().getRecordTypeInfos();
       
        Id defaultRecordTypeId = MASTER_RECORDTYPE_ID; 
       
        for (Schema.RecordTypeInfo info : rtypeInfos)
        {                   
          if( info.isDefaultRecordTypeMapping() && info.getRecordTypeId() != MASTER_RECORDTYPE_ID )
          {
              defaultRecordTypeId = info.getRecordTypeId();
              break;
          }
        }
       
        return defaultRecordTypeId;
    }
}