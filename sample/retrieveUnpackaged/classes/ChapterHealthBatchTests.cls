@isTest 
public class ChapterHealthBatchTests {
    
	public static String chCurrentRT = RecordTypeServices.getRecordTypeByDeveloperName('Current', 'Chapter_Health__c').Id;
	public static String chHistoryRT = RecordTypeServices.getRecordTypeByDeveloperName('History', 'Chapter_Health__c').Id;
	public static String rhCurrentRT = RecordTypeServices.getRecordTypeByDeveloperName('Current', 'Region_Health__c').Id;
	public static String rhHistoryRT = RecordTypeServices.getRecordTypeByDeveloperName('History', 'Region_Health__c').Id;
    public static String chapterRT = RecordTypeServices.getRecordTypeByDeveloperName('Chapter', 'Account').Id;
    public static String aaChapterRT = RecordTypeServices.getRecordTypeByDeveloperName('Chapter', 'Account_Affiliation__c').Id;
    
	public static List<Account> regions = new List<Account>();
	public static List<Account> chapters = new List<Account>();
	public static List<Contact> contacts = new List<Contact>();
	public static List<Account_Affiliation__c> acctAffs = new List<Account_Affiliation__c>();
	
	public static List<String> batchTypes = new List<String> { 'Count', 'Min', 'Max', 'Sum', 'Bool' };
	public static List<Chapter_Health__c> chRecords = new List<Chapter_Health__c>();
	public static List<Region_Health__c> rhRecords = new List<Region_Health__c>();

	public static Chapter_Health_Batch__c chDailyBatch = new Chapter_Health_Batch__c();
	public static Chapter_Health_Batch__c chQuarterBatch = new Chapter_Health_Batch__c();
	public static Chapter_Health_Batch__c chYearlyBatch = new Chapter_Health_Batch__c();
	public static Chapter_Health_Batch__c rhDailyBatch = new Chapter_Health_Batch__c();


    // Setup regions and chapters
	public static void setupBase() { 
		
		for (Integer i=1; i<=3; i++) {
			Account reg = TestServices.createAccount('RH_TestRegion' + i);
			reg.Type = 'Region';
			reg.Status__c = 'Active';
			reg.RecordTypeId = chapterRT;
			reg.Start_Date__c = System.today().addYears(-60);
			regions.add(reg);
		}
		insert regions;

		for (Account r : regions) {
			for (Integer i=1; i<=2; i++) { // 2 chapters per region
				Account chap = TestServices.createAccount('CH_TestChapter' + r.Name.right(1) + '-' + i);
				chap.Type = 'Chapter';
				chap.Status__c = 'Active';
				chap.RecordTypeId = chapterRT;
				chap.ParentId = r.Id;
				chap.Start_Date__c = system.today().addYears(-30);
				chapters.add(chap);
			}
		}
		insert chapters;

		System.assertEquals(3, regions.size());
		System.assertEquals(6, chapters.size());
	}
	

	// Setup contacts and account affiliations
	public static void setupContacts() {
		
		for (Account chap : chapters) {
			for (Integer i=1; i<=3; i++) { // 3 contacts per chapter
				Contact cont = TestServices.createContact('TestUser ' + chap.Name, chap.Id);
				cont.Birthdate = System.today().addYears(-35);
				cont.RecordTypeId = RecordTypeServices.getRecordTypeByDeveloperName('Member', 'Contact').Id;
				contacts.add(cont);
			}
		}
		insert contacts;

		for (Account chap : chapters) { 
			for (Contact cont : contacts) {
				if (cont.AccountId == chap.Id) {
					Account_Affiliation__c aa = TestServices.createAccountAffiliation(chap.Id, cont.Id);
					aa.IsActive__c = true;
					aa.Is_Primary__c = true;
					Integer years = (Integer.valueOf(chap.Name.right(1)) * 3) * -1; // -3, -6, -9, etc.
					aa.Start_Date__c = system.today().addYears(years);
					aa.RecordTypeId = aaChapterRT;
					acctAffs.add(aa);
				}
			}
		}
		insert acctAffs;
		
		System.assertEquals(18, contacts.size());
		System.assertEquals(18, acctAffs.size());
	}


	// Setup chapter and region health records
	public static void setupHealthRecords() {
		
		for (Account reg : regions) { 
			Region_Health__c rh = new Region_Health__c();
			rh.Account__c = reg.Id;
			rh.RecordTypeId = rhCurrentRT;
			rh.Report_Year__c = FiscalDateUtility.getFiscalYear(Date.today()).EndDate.year();
			rh.Report_Quarter__c = 'Q-' + String.valueOf(FiscalDateUtility.getFiscalQuarter(Date.today()).Number);
			rhRecords.add(rh);
		}
		insert rhRecords;

		for (Region_Health__c rh : rhRecords) { 
			for (Account chap : chapters) { 
				if (rh.Account__c == chap.ParentId) {
					Chapter_Health__c ch = new Chapter_Health__c();
					ch.Region_Health__c = rh.Id;
					ch.Account__c = chap.Id;
					ch.RecordTypeId = chCurrentRT;
					ch.Report_Year__c = FiscalDateUtility.getFiscalYear(Date.today()).EndDate.year();
					ch.Report_Quarter__c = 'Q-' + String.valueOf(FiscalDateUtility.getFiscalQuarter(Date.today()).Number);
					ch.Number_Member_Forums__c = 10;
					chRecords.add(ch);
				}
			}
		}
		insert chRecords;

		System.assertEquals(3, rhRecords.size(), 'There should be 3 regional health records to start (1 per region)');
		System.assertEquals(6, chRecords.size(), 'There should be 6 chapter health records to start (1 per chapter)');
	}


	// Setup batches - daily, quarterly, yearly, and regional
	public static void setupBatches() {
		
		insert new Chapter_Health_Batch_Error_Email_Setting__c(Error_Email_Recipients__c = 'test@test.com');
		
		for (String bType : batchTypes) {
			chDailyBatch = new Chapter_Health_Batch__c();
			chDailyBatch.Name = 'CH Daily Batch - ' + bType;
			chDailyBatch.Processed__c = Date.today().addDays(-1);
			chDailyBatch.Is_Active__c = true;
			chDailyBatch.Auto_Calculate__c = true;
			chDailyBatch.Object__c = 'Account Affiliation';
			chDailyBatch.Chapter_Lookup_Field_API_Name__c = 'Account__c'; 
			if (bType == 'Count') {
				chDailyBatch.Function__c = UpdChapterHealthDailyBatchServices.COUNT;
				chDailyBatch.Target_Field_API_Name__c = 'Number_Primary_Members_Current__c';
				chDailyBatch.Field_to_Aggregate__c = 'Id';
				chDailyBatch.SOQL_Query__c = 'SELECT Id, Account__c ' +
											 'FROM Account_Affiliation__c ' +
											 'WHERE Account__c IN {{chapterIds}} ' + 
											 'AND IsActive__c = True ' +
											 'AND Contact_Record_Type_Name__c = \'Member\' ' + 
											 'AND is_Primary__c = true';
			}
			if (bType == 'Sum') {
				chDailyBatch.Function__c = UpdChapterHealthDailyBatchServices.SUM;
				chDailyBatch.Target_Field_API_Name__c = 'Age_Sum__c';
				chDailyBatch.Field_to_Aggregate__c = 'Contact__r.Age_Current__c';
				chDailyBatch.SOQL_Query__c = 'SELECT Account__c, Contact__r.Age_Current__c ' +
											 'FROM Account_Affiliation__c ' +
											 'WHERE Account__c IN {{chapterIds}} ' +
											 'AND IsActive__c = true ' + 
											 'AND Contact_Record_Type_Name__c = \'Member\' ';
			}
			if (bType == 'Min') {
				chDailyBatch.Function__c = UpdChapterHealthDailyBatchServices.MIN;
				chDailyBatch.Target_Field_API_Name__c = 'Tenure_Sum__c';
				chDailyBatch.Field_to_Aggregate__c = 'Tenure__c';
				chDailyBatch.SOQL_Query__c = 'SELECT Id, Account__c, Tenure__c ' +
											 'FROM Account_Affiliation__c ' +
											 'WHERE Account__c IN {{chapterIds}} ' +
											 'AND IsActive__c = True ' +
											 'AND Contact_Record_Type_Name__c = \'Member\' ';
			}
			if (bType == 'Max') {
				chDailyBatch.Function__c = UpdChapterHealthDailyBatchServices.MAX;
				chDailyBatch.Target_Field_API_Name__c = 'Tenure_Sum__c';
				chDailyBatch.Field_to_Aggregate__c = 'Tenure__c';
				chDailyBatch.SOQL_Query__c = 'SELECT Id, Account__c, Tenure__c ' +
											 'FROM Account_Affiliation__c ' +
											 'WHERE Account__c IN {{chapterIds}} ' +
											 'AND IsActive__c = True ' +
											 'AND Contact_Record_Type_Name__c = \'Member\' ';
			}
			if (bType == 'Bool') { 
				chDailyBatch.Function__c = UpdChapterHealthDailyBatchServices.BOOL;
				chDailyBatch.Target_Field_API_Name__c = 'Is_CA_Workshop_Attendance__c';
				chDailyBatch.Object__c = 'Contact Position';
				chDailyBatch.Field_to_Aggregate__c = '';
				chDailyBatch.SOQL_Query__c = 'SELECT Contact__c, Account__c ' + 
											 'FROM Contact_Position__c ' +
											 'WHERE Account__c IN {{chapterIds}} ' +
											 'AND Status__c = \'Current\' ' +
											 'AND Contact__c IN ' +
											     '(SELECT Contact__c ' +
												 'FROM Contact_Event__c ' +
												 'WHERE Program_Format__c = \'Chapter Administrator Workshop\' ' +
												 'AND Event__r.End_Date__c >= LAST_N_QUARTERS:8)';
			}
			insert chDailyBatch;
		}

		chQuarterBatch = new Chapter_Health_Batch__c();
		chQuarterBatch.Name = 'CH Quarterly Batch';
		chQuarterBatch.Is_Active__c = true;
		chQuarterBatch.Keep_Quarterly__c = true;
		chQuarterBatch.Target_Field_API_Name__c = 'Number_Member_Forums__c';
		insert chQuarterBatch;

		chYearlyBatch = new Chapter_Health_Batch__c();
		chYearlyBatch.Name = 'CH Quarterly Batch';
		chYearlyBatch.Is_Active__c = true;
		chYearlyBatch.Keep_Yearly__c = true;
		chYearlyBatch.Target_Field_API_Name__c = 'Number_Member_Forums__c';
		insert chYearlyBatch;

		for (String bType : batchTypes) {
			rhDailyBatch = new Chapter_Health_Batch__c();
			rhDailyBatch.Name = 'RH Daily Batch';
			rhDailyBatch.Processed__c = Date.today().addDays(-1);
			rhDailyBatch.Is_Active__c = true;
			rhDailyBatch.Region_Health_Calculation__c = true;
			rhDailyBatch.Target_Field_API_Name__c = 'No_of_Chapters__c';
			if (bType == 'Sum') rhDailyBatch.Function__c = UpdChapterHealthDailyBatchServices.SUM;
			if (bType == 'Min') rhDailyBatch.Function__c = UpdChapterHealthDailyBatchServices.MIN;
			if (bType == 'Max') rhDailyBatch.Function__c = UpdChapterHealthDailyBatchServices.MAX;
			if (bType == 'Count') rhDailyBatch.Function__c = UpdChapterHealthDailyBatchServices.COUNT;
			rhDailyBatch.Field_to_Aggregate__c = 'Account_Status__c';
			rhDailyBatch.SOQL_Query__c = 'Active';
			insert rhDailyBatch;
		}
	}


	// Run yearly batch
	public static testmethod void testYearlyBatch() {
		System.debug('<<<<<<<<<< testYearlyBatch() >>>>>>>>>>');
		
		setupBase();
		setupContacts();
		setupHealthRecords();

		Test.startTest();
		ChapterHealthBatchScheduler scheduler = new ChapterHealthBatchScheduler();
		scheduler.today = FiscalDateUtility.startOfNextFiscal;
		System.debug('+++++ Today: ' + scheduler.today + ' CurrentFY: ' + scheduler.currentFY + ' CurrentFQ: ' + scheduler.currentFQ);
		scheduler.execute(null);
		Test.stopTest();
	}


	// Run quarterly batch
	public static testmethod void testQuarterlyBatch() {
		System.debug('<<<<<<<<<< testQuarterlyBatch() >>>>>>>>>>');
		
		setupBase();
		setupContacts();
		setupHealthRecords();

		Test.startTest();
		ChapterHealthBatchScheduler scheduler = new ChapterHealthBatchScheduler();
		scheduler.today = FiscalDateUtility.getFiscalQuarter(Date.today()).StartDate.addMonths(3);
		System.debug('+++++ Today: ' + scheduler.today + ' CurrentFY: ' + scheduler.currentFY + ' CurrentFQ: ' + scheduler.currentFQ);
		scheduler.execute(null);
		Test.stopTest();
	}
	

	// Run quarterly batch with no existing Chapter or Regional Health records
	public static testmethod void testQuarterlyNoRecords() {
		System.debug('<<<<<<<<<< testQuarterlyNoRecords() >>>>>>>>>>');

		setupBase();
		setupContacts();

		Test.startTest();
		ChapterHealthBatchScheduler scheduler = new ChapterHealthBatchScheduler();
		scheduler.today = FiscalDateUtility.getFiscalQuarter(Date.today()).StartDate.addMonths(3);
		System.debug('+++++ Today: ' + scheduler.today + ' CurrentFY: ' + scheduler.currentFY + ' CurrentFQ: ' + scheduler.currentFQ);
		scheduler.execute(null);
		Test.stopTest();
	}


	// Run daily batches
	public static testmethod void testDailyBatches() {
		System.debug('<<<<<<<<<< testDailyBatches() >>>>>>>>>>');

		setupBase();
		setupContacts();
		setupHealthRecords();
		setupBatches();

		Test.startTest();
		ChapterHealthBatchScheduler scheduler = new ChapterHealthBatchScheduler();
		scheduler.today = FiscalDateUtility.startOfCurrentFiscalQtr.addDays(3);
		scheduler.currentFY = FiscalDateUtility.currentFiscalYear;
		scheduler.currentFQ = FiscalDateUtility.currentFiscalQuarter;
		scheduler.execute(null);
		Test.stopTest();
	}

	
	// Run daily batch with no data to aggregate
	public static testmethod void testDailyNoData() {
		System.debug('<<<<<<<<<< testDailyNoData() >>>>>>>>>>');

		setupBase();
		setupHealthRecords();
		setupBatches();

		Date fdu1 = FiscalDateUtility.startOfCurrentFiscal;
		Date fdu2 = FiscalDateUtility.startOfPrevFiscal;
		Date fdu3 = FiscalDateUtility.endOfPrevFiscal;
		Date fdu4 = FiscalDateUtility.endOfCurrentFiscalQuarter;
		String fdu5 = FiscalDateUtility.previousFiscalYear;

		Test.startTest();
		ChapterHealthBatchScheduler scheduler = new ChapterHealthBatchScheduler();
		scheduler.today = FiscalDateUtility.startOfCurrentFiscalQtr.addDays(3);
		scheduler.currentFY = FiscalDateUtility.currentFiscalYear;
		scheduler.currentFQ = FiscalDateUtility.currentFiscalQuarter;
		scheduler.execute(null);
		Test.stopTest();
	}


}