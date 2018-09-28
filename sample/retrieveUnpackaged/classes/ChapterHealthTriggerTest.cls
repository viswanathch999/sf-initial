@isTest (seeAllData=false)
private class ChapterHealthTriggerTest  {
	
	private static String CHAPTER_YPO = 'YPO Chapter';
	private static String CHAPTER_GOLD = 'YPO Gold Chapter';
	private static Id CHAPTER_RT = RecordTypeServices.getRecordTypeByDeveloperName('Chapter', 'Account').Id;
	private static Id CHAPHEALTH_RT = RecordTypeServices.getRecordTypeByDeveloperName('Current', 'Chapter_Health__c').Id;

	private static Integer MEMBERS_PASS = 16;
	private static Integer MEMBERS_FAIL = 15;
	private static Integer EVENTS_PASS = 4;
	private static Integer EVENTS_FAIL = 3;
	private static Integer CC_PASS = 2;
	private static Integer CC_FAIL = 1;

	private static Account region = new Account();
	private static List<Account> chapters = new List<Account>();
	private static List<Chapter_Health__c> healthRecs = new List<Chapter_Health__c>();


	private static void init() { 
		
		region = TestServices.createAccount('RH_TestRegion');
		region.Type = 'Region';
		region.Status__c = 'Active';
		region.RecordTypeId = CHAPTER_RT;
		region.Start_Date__c = System.today().addYears(-60);
		System.debug(region);
		insert region;
		
		for (Integer i=1; i<=8; i++) { // 8 chapters: 6 = fail, 2 = pass
			Account chap = TestServices.createAccount('CH_TestChapter ' + i);
			chap.Type = 'Chapter';
			chap.Status__c = 'Active';
			chap.RecordTypeId = CHAPTER_RT;
			chap.YPOI_Type__c = Math.mod(i, 2) == 0 ? CHAPTER_YPO : CHAPTER_GOLD; // create YPO and Gold chapters
			chap.ParentId = region.Id;
			chap.Start_Date__c = system.today().addYears(-30);
			System.debug(chap);
			chapters.add(chap);
		}
		insert chapters;

		for (Account chap : chapters) {
			Chapter_Health__c ch = new Chapter_Health__c();
			Integer counter = Integer.valueOf(chap.Name.right(1)); // get chapter #
			ch.Account__c = chap.Id;
			ch.RecordTypeId = CHAPHEALTH_RT;
			ch.Report_Year__c = 2018;
			ch.Report_Quarter__c = 'Q-1';
			ch.Number_Primary_Members_Current__c = counter <= 2 ? MEMBERS_FAIL : MEMBERS_PASS ; // 2 failures for member count
			ch.Total_Number_Chapter_Events__c = counter >= 3 && counter <= 4 ? EVENTS_FAIL : EVENTS_PASS; // 2 failures for event count
			ch.Chapter_Ed_Chair_backend__c = counter >= 5 && counter <= 6 ? CC_FAIL : CC_PASS; // 2 failures for officer count
			System.debug(ch);
			healthRecs.add(ch);
		}

	}


	private static testMethod void testTrigger() {
		init();

		Test.startTest();
		insert healthRecs;
		Test.stopTest();
		
		List<AggregateResult> pass = [SELECT COUNT(Id) FROM Account WHERE Id IN :chapters AND CBMS__c = false];
		List<AggregateResult> fail = [SELECT COUNT(Id) FROM Account WHERE Id IN :chapters AND CBMS__c = true];
		System.assertEquals(2, pass[0].get('expr0'));
		System.assertEquals(6, fail[0].get('expr0'));

	}

}