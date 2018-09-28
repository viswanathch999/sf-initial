@isTest
private class DescribeLayoutTest
{
	static final Integer NUM_CHILDREN = 7;
	static final Integer COLUMNS = 3;
	static final String HEADING = 'An Awesome Section';
	static final Boolean USE_HEADING = false;
	static final Boolean IS_COLLAPSIBLE = true;

	static final String LABEL = 'Some Cool Label';
	static final Boolean IS_EDITABLE = true;
	static final Boolean IS_PLACEHOLDER = false;
	static final Boolean IS_REQUIRED = true;

	static final String FIELD_NAME = 'Some_Custom_Field__c';

	private static testMethod void testDescribeLayout_JSONConstructor()
	{
		String jsonString =
			'{'
				+ '"editLayoutSections": ['
					+ '{'
						+ '"rows": "1",'
						+ '"heading": "' + HEADING + '",'
						+ '"useHeading": "' + USE_HEADING + '",'
						+ '"columns": "' + COLUMNS + '",'
						+ '"useCollapsibleSection": "' + IS_COLLAPSIBLE + '",'
						+ '"layoutRows": {'
							+ '"numItems": "1",'
							+ '"layoutItems": {'
								+ '"editable": "' + IS_EDITABLE + '",'
								+ '"required": "' + IS_REQUIRED + '",'
								+ '"label": "' + LABEL + '",'
								+ '"placeholder": "' + IS_PLACEHOLDER + '",'
								+ '"layoutComponents": {'
									+ '"type": "Field",'
									+ '"value": "' + FIELD_NAME + '",'
									+ '"displayLines": "1",'
									+ '"tabOrder": "63"'
								+ '}'
							+ '}'
						+ '}'
					+ '}'
				+ ']'
			+ '}';

		Test.startTest();

			DescribeLayout actualResult = new DescribeLayout( jsonString );

		Test.stopTest();

		System.assertEquals( 1, actualResult.editLayoutSections.size(), 'Each of the child sections should be represented' );

		DescribeLayout.Section actualSection = actualResult.editLayoutSections[0];

		System.assertEquals( COLUMNS, actualSection.columns, 'The section\'s number of columns should be set' );
		System.assertEquals( HEADING, actualSection.heading, 'The section\'s heading should be set' );
		System.assertEquals( IS_COLLAPSIBLE, actualSection.isCollapsible, 'The section\'s collapsibility should be set' );
		System.assertEquals( 1, actualSection.layoutRows.size(), 'Each of the child rows should be represented' );

		DescribeLayout.Row actualRow = actualSection.layoutRows[0];

		System.assertEquals( 1, actualRow.layoutItems.size(), 'Each of the child items should be represented' );

		DescribeLayout.Item actualItem = actualRow.layoutItems[0];

		System.assertEquals( LABEL, actualItem.label, 'The item\'s label should be set' );
		System.assertEquals( IS_EDITABLE, actualItem.isEditable, 'The item\'s editability should be set' );
		System.assertEquals( IS_PLACEHOLDER, actualItem.isPlaceholder, 'The item\'s placeholder status should be set' );
		System.assertEquals( IS_REQUIRED, actualItem.isRequired, 'The item\'s requiredness should be set' );
		System.assertEquals( 1, actualItem.layoutComponents.size(), 'Each of the child components should be represented' );

		DescribeLayout.Component actualComponent = actualItem.layoutComponents[0];

		System.assertEquals( FIELD_NAME, actualComponent.fieldName, 'The component\'s field name should be set' );
	}
	
	private static testMethod void testDescribeLayout_JSONSingleSectionConstructor()
	{
		
	 String jsonString = '{"editLayoutSections":{'
	   
      + '"columns":"2",'
      +'"heading":"Information",'
      +'"layoutRows":['  
      +'{'  
            +'"layoutItems":['  
            +'{'  
                  +'"editable":"false",'
                  +'"label":"Order Error Name",'
                  +'"layoutComponents":{'  
                     +'"displayLines":"1",'
                     +'"tabOrder":"20",'
                     +'"type":"Field",'
                     +'"value":"Name"'
                  +'},'
                  +'"placeholder":"false",'
                  +'"required":"false"'
               +'},'
               +'{'  
                  +'"editable":"false",'
                  +'"label":"Owner",'
                  +'"layoutComponents":{'  
                     +'"displayLines":"1",'
                     +'"tabOrder":"33",'
                     +'"type":"Field",'
                     +'"value":"OwnerId"'
                  +'},'
                  +'"placeholder":"false",'
                  +'"required":"false"'
               +'}'
            +'],'
            +'"numItems":"2"'
         +'},'
         +'{'  
            +'"layoutItems":['  
               +'{'  
                  +'"editable":"true",'
                  +'"label":"Amount Approved",'
                  +'"layoutComponents":{'  
                     +'"displayLines":"1",'
                     +'"tabOrder":"21",'
                     +'"type":"Field",'
                     +'"value":"Amount_Approved__c"'
                  +'},'
                  +'"placeholder":"false",'
                  +'"required":"false"'
               +'},'
               +'{'  
                  +'"editable":"false",'
                  +'"label":"Record Type",'
                  +'"layoutComponents":{'  
                     +'"displayLines":"1",'
                     +'"tabOrder":"34",'
                     +'"type":"Field",'
                     +'"value":"RecordTypeId"'
                  +'},'
                  +'"placeholder":"false",'
                  +'"required":"false"'
               +'}'
            +'],'
            +'"numItems":"2"'
         +'}'          
      +'],'
      +'"rows":"13",'
      +'"useCollapsibleSection":"false",'
      +'"useHeading":"true"'
   +'}'
  +'}';

		Test.startTest();

			DescribeLayout actualResult = new DescribeLayout( jsonString );

		Test.stopTest();

		System.assertEquals( 1, actualResult.editLayoutSections.size(), 'Each of the child sections should be represented' );

		DescribeLayout.Section actualSection = actualResult.editLayoutSections[0];

		System.assertEquals( 2, actualSection.columns, 'The section\'s number of columns should be set' );
		System.assertEquals( 'Information', actualSection.heading, 'The section\'s heading should be set' );
		System.assertEquals( false, actualSection.isCollapsible, 'The section\'s collapsibility should be set' );
		System.assertEquals( 2, actualSection.layoutRows.size(), 'Each of the child rows should be represented' );
	}
	
	private static testMethod void testDescribeLayout()
	{
		Map<String, Object> describeLayoutResultMap = new Map<String, Object>();

		List<Object> editLayoutSections = new List<Object>();

		for( Integer i = 0; i < NUM_CHILDREN; i++ )
		{
			editLayoutSections.add( new Map<String, Object>() );
		}

		describeLayoutResultMap.put( DescribeLayout.EDIT_LAYOUT_SECTIONS_KEY, editLayoutSections );

		Test.startTest();

			DescribeLayout actualResult = new DescribeLayout( describeLayoutResultMap );

		Test.stopTest();

		System.assertEquals( NUM_CHILDREN, actualResult.editLayoutSections.size(), 'Each of the child sections should be represented' );
	}

	private static testMethod void testSection()
	{
		Map<String, Object> describeLayoutSectionMap = new Map<String, Object>();

		List<Object> layoutRows = new List<Object>();

		for( Integer i = 0; i < NUM_CHILDREN; i++ )
		{
			layoutRows.add( new Map<String, Object>() );
		}

		describeLayoutSectionMap.put( DescribeLayout.COLUMNS_KEY, String.valueOf( COLUMNS ) );
		describeLayoutSectionMap.put( DescribeLayout.HEADING_KEY, HEADING );
		describeLayoutSectionMap.put( DescribeLayout.USE_HEADING_KEY, String.valueOf( USE_HEADING ) );
		describeLayoutSectionMap.put( DescribeLayout.USE_COLLAPSIBLE_KEY, String.valueOf( IS_COLLAPSIBLE ) );
		describeLayoutSectionMap.put( DescribeLayout.LAYOUT_ROWS_KEY, layoutRows );

		Test.startTest();

			DescribeLayout.Section actualResult = new DescribeLayout.Section( describeLayoutSectionMap );

		Test.stopTest();

		System.assertEquals( COLUMNS, actualResult.columns, 'The section\'s number of columns should be set' );
		System.assertEquals( HEADING, actualResult.heading, 'The section\'s heading should be set' );
		System.assertEquals( USE_HEADING, actualResult.useHeading, 'The section\'s use heading property should be set' );
		System.assertEquals( IS_COLLAPSIBLE, actualResult.isCollapsible, 'The section\'s collapsibility should be set' );
		System.assertEquals( NUM_CHILDREN, actualResult.layoutRows.size(), 'Each of the child rows should be represented' );
	}

	private static testMethod void testSection_OneRow()
	{
		Map<String, Object> describeLayoutSectionMap = new Map<String, Object>();

		describeLayoutSectionMap.put( DescribeLayout.LAYOUT_ROWS_KEY, new Map<String, Object>() );

		Test.startTest();

			DescribeLayout.Section actualResult = new DescribeLayout.Section( describeLayoutSectionMap );

		Test.stopTest();

		System.assertEquals( 1, actualResult.layoutRows.size(), 'Each of the child rows should be represented' );
	}

	private static testMethod void testRow()
	{
		Map<String, Object> describeLayoutRowMap = new Map<String, Object>();

		List<Object> layoutItems = new List<Object>();

		for( Integer i = 0; i < NUM_CHILDREN; i++ )
		{
			layoutItems.add( new Map<String, Object>() );
		}

		describeLayoutRowMap.put( DescribeLayout.LAYOUT_ITEMS_KEY, layoutItems );

		Test.startTest();

			DescribeLayout.Row actualResult = new DescribeLayout.Row( describeLayoutRowMap );

		Test.stopTest();

		System.assertEquals( NUM_CHILDREN, actualResult.layoutItems.size(), 'Each of the child items should be represented' );
	}

	private static testMethod void testRow_OneItem()
	{
		Map<String, Object> describeLayoutRowMap = new Map<String, Object>();

		describeLayoutRowMap.put( DescribeLayout.LAYOUT_ITEMS_KEY, new Map<String, Object>() );

		Test.startTest();

			DescribeLayout.Row actualResult = new DescribeLayout.Row( describeLayoutRowMap );

		Test.stopTest();

		System.assertEquals( 1, actualResult.layoutItems.size(), 'Each of the child items should be represented' );
	}

	private static testMethod void testItem()
	{
		Map<String, Object> describeLayoutItemMap = new Map<String, Object>();

		List<Object> layoutComponents = new List<Object>();

		for( Integer i = 0; i < NUM_CHILDREN; i++ )
		{
			layoutComponents.add( new Map<String, Object>() );
		}

		describeLayoutItemMap.put( DescribeLayout.LABEL_KEY, LABEL );
		describeLayoutItemMap.put( DescribeLayout.EDITABLE_KEY, String.valueOf( IS_EDITABLE ) );
		describeLayoutItemMap.put( DescribeLayout.PLACEHOLDER_KEY, String.valueOf( IS_PLACEHOLDER ) );
		describeLayoutItemMap.put( DescribeLayout.REQUIRED_KEY, String.valueOf( IS_REQUIRED ) );
		describeLayoutItemMap.put( DescribeLayout.LAYOUT_COMPONENTS_KEY, layoutComponents );

		Test.startTest();

			DescribeLayout.Item actualResult = new DescribeLayout.Item( describeLayoutItemMap );

		Test.stopTest();

		System.assertEquals( LABEL, actualResult.label, 'The item\'s label should be set' );
		System.assertEquals( IS_EDITABLE, actualResult.isEditable, 'The item\'s editability should be set' );
		System.assertEquals( IS_PLACEHOLDER, actualResult.isPlaceholder, 'The item\'s placeholder status should be set' );
		System.assertEquals( IS_REQUIRED, actualResult.isRequired, 'The item\'s requiredness should be set' );
		System.assertEquals( true, actualResult.isVisible, 'The item\'s visibility should be defaulted to true' );
		System.assertEquals( NUM_CHILDREN, actualResult.layoutComponents.size(), 'Each of the child components should be represented' );
	}

	private static testMethod void testItem_OneComponent()
	{
		Map<String, Object> describeLayoutItemMap = new Map<String, Object>();

		describeLayoutItemMap.put( DescribeLayout.LAYOUT_COMPONENTS_KEY, new Map<String, Object>() );

		Test.startTest();

			DescribeLayout.Item actualResult = new DescribeLayout.Item( describeLayoutItemMap );

		Test.stopTest();

		System.assertEquals( 1, actualResult.layoutComponents.size(), 'Each of the child components should be represented' );
	}

	private static testMethod void testFieldComponent()
	{
		Map<String, Object> describeLayoutComponentMap = new Map<String, Object>();

		describeLayoutComponentMap.put( DescribeLayout.VALUE_KEY, FIELD_NAME );

		Test.startTest();

			DescribeLayout.Component actualResult = new DescribeLayout.Component( describeLayoutComponentMap );

		Test.stopTest();

		System.assertEquals( FIELD_NAME, actualResult.fieldName, 'The component\'s field name should be set' );
	}
	
	private static testMethod void testEmptyTypeComponent()
	{
		Map<String, Object> describeLayoutComponentMap = new Map<String, Object>();

		describeLayoutComponentMap.put( DescribeLayout.TYPE_KEY, DescribeLayout.EMPTY_SPACE_TYPE );

		Test.startTest();

			DescribeLayout.Component actualResult = new DescribeLayout.Component( describeLayoutComponentMap );

		Test.stopTest();

		System.assert( actualResult.isEmptySpace, 'The component of type "EmptySpace" should be loaded from the desribe layout' );
	}
}