@isTest
private class EditPageControllerTest {

    static testMethod void testInitialization() {

        Test.startTest();
        	EditPageController customCont = new EditPageController();
        Test.stopTest();

        System.assert ( !customCont.isValid,'The valid should be initialized to false' );
        System.assertEquals ( 0, customCont.excludedFields.size(), 'Excluded field list should be initialized to a new list' );
    }

    static testMethod void testParseJsonString(){

    	EditPageController customCont = new EditPageController();
    	customCont.jsonString = '{"editLayoutSections":[{"columns":"2","heading":"Fields","layoutRows":[{"layoutItems":[{"editable":"true","label":"Policy/Plan","layoutComponents":{"displayLines":"1","tabOrder":"6","type":"Field","value":"Policy_Plan__c"},"placeholder":"false","required":"true"}]}],"rows":"3","useCollapsibleSection":"false","useHeading":"false"}]}';

    	Test.startTest();
    		customCont.parseJsonString();
    	Test.stopTest();

    	System.assert( customCont.isValid, 'Because the parsing is sucessful isValid should be set to true' );
		System.assertEquals( 1, customCont.DescribeLayout.editLayoutSections.size(), 'There should have been 1 section parsed' );
		System.assertEquals( 1, customCont.DescribeLayout.editLayoutSections[0].layoutRows.size(), 'There should have been 1 layout row parsed' );
		System.assertEquals( 1, customCont.DescribeLayout.editLayoutSections[0].layoutRows[0].layoutItems.size(), 'There should have been 1 item' );
		System.assertEquals( true, customCont.DescribeLayout.editLayoutSections[0].layoutRows[0].layoutItems[0].isEditable, 'The item should not be editable' );
    }

    static testMethod void testParseJsonStringWithMalFormedJSON(){

    	EditPageController customCont = new EditPageController();
    	customCont.jsonString = ': [{ "firstName":"Joh';

    	Test.startTest();
    		customCont.parseJsonString();
    	Test.stopTest();

    	System.assert ( !customCont.isValid, 'For error the isValid should be set to false' );
    }

	static testMethod void testCreateSectionWithFieldsWithExcludedFields(){
		String jsonString = '{"editLayoutSections":[{"columns":"2","heading":"Fields","layoutRows":[{"layoutItems":[{"editable":"true","label":"Policy/Plan","layoutComponents":{"displayLines":"1","tabOrder":"6","type":"Field","value":"Policy_Plan__c"},"placeholder":"false","required":"true"}]}],"rows":"3","useCollapsibleSection":"false","useHeading":"false"}]}';

		EditPageController customCont = new EditPageController();
		customCont.excludedFields = new List<String>{'Policy_Plan__c'};

		Test.startTest();

			customCont.jsonString = jsonString;
			customCont.parseJSONString();

		Test.stopTest();

    	System.assert( customCont.isValid, 'Because the parsing is sucessful isValid should be set to true' );
		System.assertEquals( 1, customCont.DescribeLayout.editLayoutSections.size(), 'There should have been 1 section parsed' );
		System.assertEquals( 1, customCont.DescribeLayout.editLayoutSections[0].layoutRows.size(), 'There should have been 1 layout row parsed' );
		System.assertEquals( 1, customCont.DescribeLayout.editLayoutSections[0].layoutRows[0].layoutItems.size(), 'There should have been 1 item' );
		System.assertEquals( false, customCont.DescribeLayout.editLayoutSections[0].layoutRows[0].layoutItems[0].isVisible, 'The item should not be visible' );
	}

	static testMethod void testCreateSectionWithFieldsWithReadOnlyFields(){
		String jsonString = '{"editLayoutSections":[{"columns":"2","heading":"Fields","layoutRows":[{"layoutItems":[{"editable":"true","label":"Policy/Plan","layoutComponents":{"displayLines":"1","tabOrder":"6","type":"Field","value":"Policy_Plan__c"},"placeholder":"false","required":"true"}]}],"rows":"3","useCollapsibleSection":"false","useHeading":"false"}]}';

		EditPageController customCont = new EditPageController();
		customCont.readOnlyFields = new List<String>{'Policy_Plan__c'};

		Test.startTest();

			customCont.jsonString = jsonString;
			customCont.parseJSONString();

		Test.stopTest();

    	System.assert( customCont.isValid, 'Because the parsing is sucessful isValid should be set to true' );
		System.assertEquals( 1, customCont.DescribeLayout.editLayoutSections.size(), 'There should have been 1 section parsed' );
		System.assertEquals( 1, customCont.DescribeLayout.editLayoutSections[0].layoutRows.size(), 'There should have been 1 layout row parsed' );
		System.assertEquals( 1, customCont.DescribeLayout.editLayoutSections[0].layoutRows[0].layoutItems.size(), 'There should have been 1 item' );
		System.assertEquals( true, customCont.DescribeLayout.editLayoutSections[0].layoutRows[0].layoutItems[0].isVisible, 'The item should be visible' );
		System.assertEquals( false, customCont.DescribeLayout.editLayoutSections[0].layoutRows[0].layoutItems[0].isEditable, 'The item should not be editable' );
	}
}