@isTest
private class TestDetailPageHelper {

	private static OpportunityStage createOpportunityStage ( String masterLabel, Decimal defaultProbability, String forecastCategoryName )
   	{
        String jsondata1 = '{ "attributes" :'
        				+		'{"type" : "OpportunityStage"},'
        				+		'"MasterLabel" : "';
        	   jsondata1 += masterLabel+'",'
        				+		'"DefaultProbability" : "';
        	   jsondata1 += defaultProbability.format()+'",'
        				+		'"ForecastCategoryName" : "';
        	   jsondata1 += forecastCategoryName+'"}';
		
		OpportunityStage oppStage1 = (OpportunityStage) JSON.deserialize(jsondata1, OpportunityStage.class);
		
		return oppStage1;
   	}
	
	private static testMethod void testDefaultConstructor() {
        
		Test.StartTest();
		    DetailPageHelper sampleHelperController = new DetailPageHelper();
		Test.StopTest();
        
        System.assertEquals( null, sampleHelperController.theSObjectApiName, 'The correct sobject api name should not be set');
        System.assertEquals( null, sampleHelperController.rtypeHelper, 'The recordtypehelper should not be set');
        System.assertEquals( null, sampleHelperController.theSobject, 'The sobject should not be set');
        
	}
	
	private static testMethod void testConstructor() {
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Opportunity());
		
		Test.StartTest();
		    DetailPageHelper sampleHelperController = new DetailPageHelper(sc);
		Test.StopTest();
        
        System.assertEquals( 'Opportunity', sampleHelperController.theSObjectApiName, 'The correct sobject api name should be set');
        System.assertEquals( Opportunity.getSobjectType(), sampleHelperController.theSObject.getSobjectType(), 'The correct sobject should be set');
        System.assertNotEquals( null, sampleHelperController.rtypeHelper, 'The recordtypehelper should be set');
        System.assertNotEquals( null, sampleHelperController.theSobject, 'The sobject should be set');
        
	}
	
	private static testMethod void testConstructorWithStandardAccountLookupParameter() {
        
        final Id TEST_ACCOUNT_ID = '001j000000OvUvd';
        
        DynamicEditPageURLParameters__c params = new DynamicEditPageURLParameters__c (Name = 'Opportunity', ObjectApiName__c = 'Opportunity', UrlParam__c = 'accid', FieldOnObject__c = 'accountId');
        insert params;
        
        Pagereference testPage = new Pagereference ( Page.DynamicEditPageOpptySample.getUrl() );
        testPage.getParameters().put('accid', TEST_ACCOUNT_ID );
        Test.setCurrentPageReference ( testPage );
		
		Test.StartTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(new Opportunity());
		    DetailPageHelper sampleHelperController = new DetailPageHelper(sc);
		Test.StopTest();
        
        System.assertEquals( TEST_ACCOUNT_ID, sampleHelperController.theSobject.get('AccountId'), 'The sobject accountId should be set');
        System.assertEquals( null, sampleHelperController.theSobjectContactRole.ContactId, 'The sobject contactrole contactId should not be set');
        
	}
	
	private static testMethod void testConstructorWithStandardContactLookupParameter() {
        
        final Id TEST_CONTACT_ID = '003j000000LiosN';
        DynamicEditPageURLParameters__c params = new DynamicEditPageURLParameters__c (Name = 'Opportunity', ObjectApiName__c = 'Opportunity', UrlParam__c = 'conid');
        insert params;
        
        Pagereference testPage = new Pagereference ( Page.DynamicEditPageOpptySample.getUrl() );
        testPage.getParameters().put('conid', TEST_CONTACT_ID);
        Test.setCurrentPageReference ( testPage );
		
		Test.StartTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(new Opportunity());
		    DetailPageHelper sampleHelperController = new DetailPageHelper(sc);
		    DynamicEditPageOpptySampleController sampleConcreteHelperController = new DynamicEditPageOpptySampleController(sc);
		Test.StopTest();
        
        System.assertNotEquals( null, sampleHelperController.theSobjectContactRole, 'The sobject contactrole should be set');
        System.assertEquals( TEST_CONTACT_ID, sampleHelperController.theSobjectContactRole.ContactId, 'The sobject contactrole contactId should be set');
        System.assertEquals( true, sampleHelperController.theSobjectContactRole.isPrimary, 'The sobject contactrole isprimary should be set correctly');
        
        System.assertNotEquals( null, sampleConcreteHelperController.theSobjectContactRole, 'The sobject contactrole should be set');
        System.assertEquals( TEST_CONTACT_ID, sampleConcreteHelperController.theSobjectContactRole.ContactId, 'The sobject contactrole contactId should be set');
        System.assertEquals( true, sampleConcreteHelperController.theSobjectContactRole.isPrimary, 'The sobject contactrole isprimary should be set correctly');
        
	}
	
	private static testMethod void testDetailPageHelperSaveWithError() {
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Opportunity());
	    DetailPageHelper sampleHelperController = new DetailPageHelper(sc);
		
		Test.StartTest();
	        sampleHelperController.save();
		Test.StopTest();
        
        System.assert( ApexPages.hasMessages(), 'An error should have been detected and displayed on the page');
	}
	
	public static testMethod void testStageNameChange()
	{
		final String PROBABILITY = 'Probability';
		final String FORECAST = 'ForecastCategoryName';
		
		final String TEST_OPP_STAGE_1 = 'Closed / Won';
		final String TEST_OPP_STAGE1_FORECAST = 'Won';

		final String TEST_OPP_STAGE_2 = 'New';		
		final String TEST_OPP_STAGE2_FORECAST = 'Pipeline';
		
		final String TEST_OPP_FALSE_STAGE = 'Old';
		
		final Decimal DEFAULT_PROB_STAGE1 = 100.0;
		final Decimal DEFAULT_PROB_STAGE2 = 10.0;
		
		OpportunityStage opStage1 = createOpportunityStage(TEST_OPP_STAGE_1, DEFAULT_PROB_STAGE1, TEST_OPP_STAGE1_FORECAST);
		OpportunityStage opStage2 = createOpportunityStage(TEST_OPP_STAGE_2, DEFAULT_PROB_STAGE2, TEST_OPP_STAGE2_FORECAST);

		Map<String, OpportunityStage> testStageToProbabilityMap = new Map<String, OpportunityStage>{ TEST_OPP_STAGE_1 => opStage1, TEST_OPP_STAGE_2 => opStage2};
		DetailPageHelper.stageToProbabilityMap = testStageToProbabilityMap;
		
		Test.StartTest();
			Map<String, String> result1 = DetailPageHelper.changeStageName(TEST_OPP_STAGE_1);
			Map<String, String> result2 = DetailPageHelper.changeStageName(TEST_OPP_STAGE_2);
			Map<String, String> emptyResult = DetailPageHelper.changeStageName(TEST_OPP_FALSE_STAGE);
		Test.StopTest();
		
		System.assertEquals( 2, result1.size(), 'A matching oppty probability and forecast should be found');
		System.assertEquals( TEST_OPP_STAGE1_FORECAST, result1.get( FORECAST ), 'We should receive the correct forecast');
		System.assertEquals( DEFAULT_PROB_STAGE1.format(), result1.get( PROBABILITY ), 'We should receive the correct probability');

		System.assertEquals( 2, result2.size(), 'A matching oppty probability and forecast should be found');
		System.assertEquals( TEST_OPP_STAGE2_FORECAST, result2.get( FORECAST ), 'We should receive the correct forecast');
		System.assertEquals( DEFAULT_PROB_STAGE2.format(), result2.get( PROBABILITY ), 'We should receive the correct probability');
	
		System.assertEquals( 0, emptyResult.size(), 'The invalid stage should not return any results');
	}

}