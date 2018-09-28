global virtual with sharing class DetailPageHelper {
    
    public transient Map<String, OpportunityStage> probabilityStageNameMap;
    @TestVisible private RecordTypeHelper rtypeHelper;
    @TestVisible private Map<String, Schema.SObjectField> objectFieldMap;
    public String theSObjectApiName {get; set;}
    public Id recordTypeId {get; private set;}
    private ApexPages.StandardController stdController;
    public SObject theSobject {get; set;}
    public OpportunityContactRole theSobjectContactRole {get; set;}
    public String OPPORTUNITY_STANDARD_CONTACT_URL_PARAM = 'conid';
    
    public DetailPageHelper(){}
    
    public DetailPageHelper( ApexPages.StandardController stdController ){
        
        this.stdController = stdController;
        theSobjectContactRole = new OpportunityContactRole();
        
        this.theSObjectApiName = stdController.getRecord().getSObjectType().getDescribe().getName();
        this.rtypeHelper = new RecordTypeHelper( theSObjectApiName );
        
        if( rtypeHelper.useMasterRecordTypeId )
            this.recordTypeId = rtypeHelper.MASTER_RECORDTYPE_ID;
        else
            this.recordTypeId = (Id) stdController.getRecord().get('RecordTypeId');
            
        this.theSobject = this.rtypeHelper.newSobjectWithRecordTypeId( this.recordTypeId, true );
        objectFieldMap = this.theSobject.getSobjectType().getDescribe().fields.getMap();
        
        setObjectUrlParams();
    }
    
    private void setObjectUrlParams()
    {
        //Set the custom and standard lookup fields that are defined in the custom settings
        //conId required a contact role as well
        for(DynamicEditPageURLParameters__c objectUrlParams : DynamicEditPageURLParameters__c.getAll().values() )
        {
            if( objectUrlParams.ObjectApiName__c.equalsIgnoreCase( theSObjectApiName ) )
            {
                String paramValue = ApexPages.currentPage().getParameters().get( objectUrlParams.UrlParam__c );
                
                if( String.IsNotBlank( objectUrlParams.FieldOnObject__c ) 
                    && String.IsNotBlank( paramValue )
                    && objectFieldMap.get( objectUrlParams.FieldOnObject__c.toLowerCase() ) != null 
                    && objectFieldMap.get( objectUrlParams.FieldOnObject__c.toLowerCase() ).getDescribe().isCreateable())
                    {
                        this.theSobject.put( objectUrlParams.FieldOnObject__c, paramValue );    
                    }
                else if( String.IsBlank( objectUrlParams.FieldOnObject__c ) 
                         && String.IsNotBlank( paramValue )
                         && objectUrlParams.ObjectApiName__c.equalsIgnoreCase('Opportunity')
                         && objectUrlParams.UrlParam__c.equalsIgnoreCase( OPPORTUNITY_STANDARD_CONTACT_URL_PARAM ))
                {
                    //We handled the standard lookup to contact on opportunity by creating an oppty contact role
                    theSobjectContactRole.ContactId = paramValue;
                    theSobjectContactRole.IsPrimary = true;
                }
            }
        }
    }
    
    public virtual PageReference save()
    {
    	PageReference pageRef;
    	try{
	    	insert theSobject;
	    	
	    	if( theSobjectContactRole != null && String.IsNotBlank( theSobjectContactRole.ContactId ) )
	    	{
	    	    theSobjectContactRole.OpportunityId = theSobject.id;
    	        insert theSobjectContactRole;
	    	}
	    	    
	    	pageRef = new ApexPages.Standardcontroller( theSobject ).view();
    	}
    	catch( DMLException dex )
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dex.getMessage() ));
    	}
    	return pageRef;
    }
    
    public static Map<String, OpportunityStage> stageToProbabilityMap {
    	get
    	{
	    	if( stageToProbabilityMap == null )
	    	{
	    		stageToProbabilityMap = new Map<String, OpportunityStage>();
	    		
	    		for (OpportunityStage oppStage : [Select MasterLabel, DefaultProbability, ForecastCategoryName From OpportunityStage]) 
			    	stageToProbabilityMap.put(oppStage.MasterLabel, oppStage);
	    	}
	    	return stageToProbabilityMap;
    	}
    	set;
    }
    
    @RemoteAction
    global static Map<String, String> changeStageName(String stageName){
        Map<String, String> fieldNameToValue = new Map<String, String>();
        
	     if (stageToProbabilityMap.containsKey(stageName)) {
	     fieldNameToValue.put('Probability', stageToProbabilityMap.get(stageName).DefaultProbability.format());
	     fieldNameToValue.put('ForecastCategoryName', stageToProbabilityMap.get(stageName).ForecastCategoryName);
	   }
	   return fieldNameToValue;
    }
}