/**
* Creates new Region Health and Chapter Health quarterly records and 
* creates relationships between them.
*
* Prevents creation of duplicate quarterly records for CH or RH.
*
* Updates related records when there are missing quarterly records.
*
* Copies specified field values from historical to current CH records.
*/ 
public class ChapterHealthCreationServices {
    
	public static String chapterHealthCurrentRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Current', 'Chapter_Health__c').Id;
    public static String educationMetricsCurrentRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Education_Metrics', 'Chapter_Health__c').Id;
    public static String chapterHealthHistoryRecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('History', 'Chapter_Health__c').Id;

	public static Id rhCurrentRT = RecordTypeServices.getRecordTypeByDeveloperName('Current', 'Region_Health__c').Id;
	public static Id rhHistoryRT = RecordTypeServices.getRecordTypeByDeveloperName('History', 'Region_Health__c').Id;
	public static Id chCurrentRT = RecordTypeServices.getRecordTypeByDeveloperName('Current', 'Chapter_Health__c').Id;
	public static Id chHistoryRT = RecordTypeServices.getRecordTypeByDeveloperName('History', 'Chapter_Health__c').Id;
	

	// Get list of fields marked as quarter or yearly roll-over
    public static List<String> getCarryForwardFields(String yearlyOrQuarterly) {
        Set<String> fieldsToQuery;
        List<Chapter_Health_Batch__c> chapterHlthBatch;
        
		try {
			if (yearlyOrQuarterly == 'Quarterly') {
				chapterHlthBatch = [SELECT Id, Target_Field_API_Name__c 
									FROM Chapter_Health_Batch__c 
									WHERE Keep_Quarterly__c = true];
			}
			else {
				chapterHlthBatch = [SELECT Id, Target_Field_API_Name__c 
									FROM Chapter_Health_Batch__c 
									WHERE Keep_Yearly__c = true];
			}
		}
		catch (Exception e) {
			System.debug('Error retrieving carry forward fields: ' + e.getMessage() + ' @ line ' + e.getLineNumber());
		}

        fieldsToQuery = new Set<String>{ 'Account__c', 
										 'Region_Health__c', 
										 'Region_Health__r.Account__c',
										 'Account__r.Name',  
										 'Report_Quarter__c',
										 'Report_Year__c',
										 'Type__c' };
        fieldsToQuery.addAll(Pluck.strings('Target_Field_API_Name__c', chapterHlthBatch));
        return new List<String>(fieldsToQuery);
    }
    

	// Create new Region Health (RH) quarterly records
	public static void createRegionHealth(Account region, String batchType, String currentFY, String currentFQ) {
		Region_Health__c oldRH = new Region_Health__c();
		Region_Health__c newRH = new Region_Health__c();
		Region_Health__c emptyRH = new Region_Health__c();

		System.debug(region.Name);
		
		// Get current RH record for this region
		try { 
			oldRH = [SELECT Id, Name, Report_Year__c, Report_Quarter__c, Account__c 
					FROM Region_Health__c 
					WHERE Account__c = :region.Id 
					AND RecordType.DeveloperName = 'Current'
					LIMIT 1];
			System.debug('  Current RH: ' + oldRH.Name + ' ' + oldRH.Report_Year__c + ' ' + oldRH.Report_Quarter__c);
		}
		catch (Exception e) { 
			System.debug('Error retrieving current RH record: ' + e.getMessage() + ' @' + e.getLineNumber());
		}

		if (oldRH != emptyRH) {
			
			// Make sure "Current" record isn't for the new fiscal quarter,
			// then create new record and update "Current" record to "History"
			if (String.valueOf(Integer.valueOf(oldRH.Report_Year__c) + oldRH.Report_Quarter__c) != currentFY + currentFQ) {
				newRH.RecordTypeId = rhCurrentRT;
				newRH.Report_Quarter__c = currentFQ;
				newRH.Report_Year__c = Integer.valueOf(currentFY);
				newRH.Account__c = region.Id;
				
				oldRH.RecordTypeId = rhHistoryRT;

				// Commit change to old RH record
				try { 
					update oldRH; 
				}
				catch (Exception e) { 
					System.debug('Could not update existing RH record: ' + e.getMessage() + ' @' + e.getLineNumber()); 
				}
			}
		}

		// Could not find a "Current" record, so create one
		else {
			newRH.RecordTypeId = rhCurrentRT;
			newRH.Report_Quarter__c = currentFQ;
			newRH.Report_Year__c = Integer.valueOf(currentFY);
			newRH.Account__c = region.Id;
		}
		
		// Insert new RH record and start 
		// Chapter Health creation process
		if (newRH != emptyRH) {
			try { 
				insert newRH; 
				System.debug('    New RH: ' + newRH);
				createChapterHealth(newRH, batchType, currentFY, currentFQ);
			}
			catch (Exception e) { 
				System.debug('Error inserting new RH record: ' + e.getMessage() + ' @' + e.getLineNumber()); 
			}
		}
		
		// Existing RH record is for this quarter, 
		// so start CH process with existing record
		else { 
			createChapterHealth(oldRH, batchType, currentFY, currentFQ);
		}
	}


	// Create new Chapter Health (CH) quarterly 
	// records and set carry over field values
	public static void createChapterHealth(Region_Health__c rh, String batchType, String currentFY, String currentFQ) {
		List<Chapter_Health__c> chUpdate = new List<Chapter_Health__c>();
		List<Chapter_Health__c> chCreate = new List<Chapter_Health__c>();
		List<Chapter_Health__c> chList = new List<Chapter_Health__c>();
		List<String> carryForwardFields = ChapterHealthCreationServices.getCarryForwardFields(batchType);
		Boolean currRecExists = false;

		// Get all "Current" CH records and carry forward fields
		String targetFields = String.join(carryForwardFields, ', ');
		String qry = 'SELECT Id, Name, ' + targetFields + ' ' +
					 'FROM Chapter_Health__c ' +
					 'WHERE RecordType.DeveloperName = \'Current\' ' + 
					 'AND Account__r.ParentId = \'' + rh.Account__c + '\'' ;
		try { chList = Database.query(qry); }
		catch (Exception e) { System.debug('Error retrieving CH records: ' + e.getMessage() + ' @ line ' + e.getLineNumber()); }
		
		// Create chapter health record for each chapter in region
		for (Account chap : [SELECT Id, Name, ParentId 
							FROM Account 
							WHERE ParentId = :rh.Account__c 
							AND Type = 'Chapter' 
							AND RecordType.DeveloperName = 'Chapter']) {
			System.debug(chap.Name);
			currRecExists = false;
			
			// Find "Current" record for this chapter
			for (Chapter_Health__c ch : chList) {
				if (ch.Account__c == chap.Id) {
					currRecExists = true;
					System.debug('  Current CH: ' +  ch.Name + ' ' + ch.Report_Year__c + ' ' + ch.Report_Quarter__c);

					// Make sure "Current" record isn't for the new fiscal quarter,
					// then create new record and set carry forward field values, 
					// then update "Current" record to "History"
					if (String.valueOf(Integer.valueOf(ch.Report_Year__c) + ch.Report_Quarter__c) != (currentFY + currentFQ)) {
						Chapter_Health__c newCH = new Chapter_Health__c();
						for (String cff : carryForwardFields) {
							if (cff.indexOf('__c') > -1 && !cff.contains('__r')) {  // field is a custom field
								try { newCH.put(cff, ch.get(cff)); }
								catch (Exception e) { System.debug('Could not set value of field ' + cff + ' on CH record ' + ch.Name + ' - ' + e.getMessage()); }
							}
						}
						newCH.RecordTypeId = chCurrentRT;
						newCH.Report_Quarter__c = currentFQ;
						newCH.Report_Year__c = Integer.valueOf(currentFY);
						newCH.Type__c = 'Current';
						newCH.Account__c = chap.Id;
						newCH.Region_Health__c = rh.Id;
						chCreate.add(newCH);
						System.debug('    New CH: ' + newCH);
								
						ch.RecordTypeId = chHistoryRT;
						chUpdate.add(ch);
					}

					// Quarterly CH record already exists, so just
					// make sure it is related to correct RH record.
					else {
						ch.Region_Health__c = rh.Id;
						chUpdate.add(ch);
					}
				}
			}
						
			// Could not find a "Current" record, so create one
			// NOTE: Carry forward fields will be NULL
			if (currRecExists == false) { 
				Chapter_Health__c newCH = new Chapter_Health__c();
				newCH.RecordTypeId = chCurrentRT;
				newCH.Report_Quarter__c = currentFQ;
				newCH.Report_Year__c = Integer.valueOf(currentFY);
				newCH.Type__c = 'Current';
				newCH.Account__c = chap.Id;
				newCH.Region_Health__c = rh.Id;
				chCreate.add(newCH);
				System.debug('    New CH: ' + newCH);
			}
		}

		// Commit CH updates/insertions
		try {
			System.debug('Chapter Health: ' + chUpdate.size() + ' updates, ' + chCreate.size() + ' new records');
			update chUpdate;
			insert chCreate;
		}
		catch (Exception e) {
			System.debug('Error creating/updating Chapter Health records: ' + e.getMessage() + ' @ line ' + e.getLineNumber());
		}
	}

}