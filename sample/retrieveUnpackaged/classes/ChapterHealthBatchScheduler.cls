/**
* This is the schedulable interface for the Chapter and Regional Health batches.
* Depending on the date (end of qtr, end of year) it runs either the daily, 
* quarterly, or yearly batch process.
*/ 
global class ChapterHealthBatchScheduler implements Schedulable {
    
	// Allow manipulation of these for testing purposes
	public Date today { get { return today == null ? Date.today() : today; } set; }
	public Date startOfQuarter { get { return startOfQuarter == null ? FiscalDateUtility.getFiscalQuarter(today).StartDate : startOfQuarter; } set; }
	public Date startOfYear { get { return startOfYear == null ? FiscalDateUtility.getFiscalYear(today).StartDate : startOfYear; } set; } 
	public String currentFQ { get { return currentFQ == null ? 'Q-' + String.valueOf(FiscalDateUtility.getFiscalQuarter(today).Number) : currentFQ; } set; }
	public String currentFY { get { return currentFY == null ? String.valueOf(FiscalDateUtility.getFiscalYear(today).EndDate.year()) : currentFY; } set; }

	global void execute(SchedulableContext ctx) {
		
		// Year
		if (today == startOfYear) {
			System.debug('Starting yearly batch');
			Database.executeBatch(new ChapterHealthQuarterlyBatch('Yearly', currentFY, currentFQ));
        }

		// Quarter
		else if (today == startOfQuarter) {
			System.debug('Starting quarterly batch');
			Database.executeBatch(new ChapterHealthQuarterlyBatch('Quarterly', currentFY, currentFQ));
        }

		// Daily
		else {
			System.debug('Starting daily batch');
			ChapterHealthBatchHelper helperCH = new ChapterHealthBatchHelper();
			helperCH.execute(null);
        }
    }

}