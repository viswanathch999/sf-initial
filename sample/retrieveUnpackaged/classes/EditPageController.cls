public class EditPageController {

	public DescribeLayout describeLayout { get; set; }

	public List<String> excludedFields {
		get{
			if ( excludedFields == null ){
				excludedFields = new List<String>();
			}

			return excludedFields;
		}
		set;
	}

	public List<String> readOnlyFields {
		get{
			if ( readOnlyFields == null ){
				readOnlyFields = new List<String>();
			}

			return readOnlyFields;
		}
		set;
	}

	public String jsonString {get; set;}
	public Boolean isValid {get; set;}

	public EditPageController (){

		isValid = false;
	}

	public void parseJsonString()
	{
		try
		{
			describeLayout = new DescribeLayout(jsonString);
		}
		catch( Exception ex )
		{
			ApexPages.addMessages( ex );
			return;
		}

		Set<String> excludedFieldSet = new Set<String>( excludedFields );
		Set<String> readOnlyFieldSet = new Set<String>( readOnlyFields );
		for( DescribeLayout.Section aSection : describeLayout.editLayoutSections )
		{
			for( DescribeLayout.Row aRow : aSection.layoutRows )
			{
				for( DescribeLayout.Item anItem : aRow.layoutItems )
				{
					for( DescribeLayout.Component aComponent : anItem.layoutComponents )
					{
						if( readOnlyFieldSet.contains( aComponent.fieldName ) )
						{
							anItem.isEditable = false;
						}
						if( excludedFieldSet.contains( aComponent.fieldName ) )
						{
							anItem.isVisible = false;
							break;
						}
					}
				}
			}
		}

		isValid = true;
	}
}