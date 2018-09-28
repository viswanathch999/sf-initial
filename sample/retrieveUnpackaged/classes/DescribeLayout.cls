public class DescribeLayout
{
	// DescribeLayout
	public static final String EDIT_LAYOUT_SECTIONS_KEY = 'editLayoutSections';

	// DescribeLayoutSection
	public static final String COLUMNS_KEY = 'columns';
	public static final String HEADING_KEY = 'heading';
	public static final String LAYOUT_ROWS_KEY = 'layoutRows';
	public static final String USE_COLLAPSIBLE_KEY = 'useCollapsibleSection';
	public static final String USE_HEADING_KEY = 'useHeading';

	// DescribeLayoutRow
	public static final String LAYOUT_ITEMS_KEY = 'layoutItems';

	// DescribeLayoutItem
	public static final String EDITABLE_KEY = 'editable';
	public static final String LABEL_KEY = 'label';
	public static final String LAYOUT_COMPONENTS_KEY = 'layoutComponents';
	public static final String PLACEHOLDER_KEY = 'placeholder';
	public static final String REQUIRED_KEY = 'required';

	// DescribeLayoutComponent
	public static final String TYPE_KEY = 'type';
	public static final String VALUE_KEY = 'value';
	public static final String EMPTY_SPACE_TYPE = 'EmptySpace';
	
	///////////////////////////////////////////////////////////////////////////

	public List<Section> editLayoutSections { get; private set; }

	/*
	 * @throws System.JSONException
	 * @throws System.TypeException
	 */
	public DescribeLayout( String jsonString )
	{
		this( (Map<String, Object>)JSON.deserializeUntyped( jsonString ) );
	}

	/*
	 * @throws System.TypeException on invalid property hierarchy
	 * See http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_describelayout_describelayoutresult.htm
	 */
	public DescribeLayout( Map<String, Object> properties )
    {
        editLayoutSections = new List<Section>();

        if( properties.get( EDIT_LAYOUT_SECTIONS_KEY ) instanceof Map<String, Object> )
        {
            editLayoutSections.add( new Section( (Map<String, Object>) properties.get( EDIT_LAYOUT_SECTIONS_KEY ) ) );
        }
        else if( properties.get( EDIT_LAYOUT_SECTIONS_KEY ) instanceof List<Object> )
        {
            for( Object section : ( List<Object> )properties.get( EDIT_LAYOUT_SECTIONS_KEY ) )
            {
                editLayoutSections.add( new Section( (Map<String, Object>)section ) );
            }
        }
    }

	public class Section
	{
		public Integer columns { get; private set; }
		public String heading { get; private set; }
		public Boolean useHeading { get; private set; }
		public Boolean isCollapsible { get; private set; }

		public List<Row> layoutRows { get; private set; }

		public Section( Map<String, Object> properties )
		{
			columns = Integer.valueOf( properties.get( COLUMNS_KEY ) );
			heading = (String)properties.get( HEADING_KEY );
			useHeading = 'true' == (String)properties.get( USE_HEADING_KEY );
			isCollapsible = 'true' == (String)properties.get( USE_COLLAPSIBLE_KEY );

			layoutRows = new List<Row>();

			Object layoutRowsGeneric = properties.get( LAYOUT_ROWS_KEY );

			if( null != layoutRowsGeneric )
			{
				if( layoutRowsGeneric instanceof List<Object> )
				{
					for( Object layoutRow : (List<Object>)layoutRowsGeneric )
					{
						layoutRows.add( new Row( (Map<String, Object>)layoutRow ) );
					}
				}
				else if( layoutRowsGeneric instanceof Map<String, Object> )
				{
					layoutRows.add( new Row( (Map<String, Object>)layoutRowsGeneric ) );
				}
			}
		}
	}

	public class Row
	{
		public List<Item> layoutItems { get; private set; }

		public Row( Map<String, Object> properties )
		{
			layoutItems = new List<Item>();

			Object layoutItemsGeneric = properties.get( LAYOUT_ITEMS_KEY );

			if( null != layoutItemsGeneric )
			{
				if( layoutItemsGeneric instanceof List<Object> )
				{
					for( Object layoutItem : (List<Object>)layoutItemsGeneric )
					{
						layoutItems.add( new Item( (Map<String, Object>)layoutItem ) );
					}
				}
				else if( layoutItemsGeneric instanceof Map<String, Object> )
				{
					layoutItems.add( new Item( (Map<String, Object>)layoutItemsGeneric ) );
				}
			}
		}
	}

	public class Item
	{
		public String label { get; private set; }
		public Boolean isEditable { get; set; }
		public Boolean isPlaceholder { get; set; }
		public Boolean isRequired { get; set; }
		public Boolean isVisible { get; set; }

		public List<Component> layoutComponents { get; private set; }

		public Item( Map<String, Object> properties )
		{
			label = (String)properties.get( LABEL_KEY );
			isEditable = 'true' == (String)properties.get( EDITABLE_KEY );
			isPlaceholder = 'true' == (String)properties.get( PLACEHOLDER_KEY );
			isRequired = 'true' == (String)properties.get( REQUIRED_KEY );
			isVisible = true;

			layoutComponents = new List<Component>();

			Object layoutComponentsGeneric = properties.get( LAYOUT_COMPONENTS_KEY );

			if( null != layoutComponentsGeneric )
			{
				if( layoutComponentsGeneric instanceof List<Object> )
				{
					for( Object layoutComponent : (List<Object>)layoutComponentsGeneric )
					{
						layoutComponents.add( new Component( (Map<String, Object>)layoutComponent ) );
					}
				}
				else if( layoutComponentsGeneric instanceof Map<String, Object> )
				{
					layoutComponents.add( new Component( (Map<String, Object>)layoutComponentsGeneric ) );
				}
			}
		}
	}

	public class Component
	{
		public String fieldName { get; private set; }
		public Boolean isEmptySpace { get; private set; }
			
		public Component( Map<String, Object> properties )
		{
			isEmptySpace = (String)properties.get ( TYPE_KEY ) == EMPTY_SPACE_TYPE;
			fieldName = (String)properties.get( VALUE_KEY );
		}
	}
}