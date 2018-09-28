public class UpdChapterHealthDailyBatchServices {    
    
	@TestVisible Static Final String COUNT = 'Count';
    @TestVisible Static Final String MAX = 'Max';
    @TestVisible Static Final String MIN = 'Min';
    @TestVisible Static Final String SUM = 'Sum';
    @TestVisible Static Final String BOOL = 'Boolean';

	public static List<String> calculateAndUpdateChapterHealth(List<Account> scope, Chapter_Health_Batch__c chbToBeCalculated) {  
        List<String> errorMessages = new List<String>();
        List<Chapter_Health__c> chapterHealthRecordsToBeUpdated = new List<Chapter_Health__c>();
		List<sObject> queryRecords =  new List<sObject>();
		String query = chbToBeCalculated.SOQL_Query__c;

		Set<Id> chapterIds = Pluck.ids(scope);
        query = query.replace('{{chapterIds}}', ' :chapterIds '/*'\''+*/ /*+'\''*/);
		query = query.replace('{{startFY}}', FiscalDateUtility.currentFiscalYear);

		try {
            queryRecords = Database.query(query);
            if (!queryRecords.isEmpty()) {
                Map<Id, List<sObject>> groupedByChapter = GroupBy.ids(chbToBeCalculated.Chapter_Lookup_Field_API_Name__c, queryRecords);
                System.debug('total records: ' + queryRecords.size());
				System.debug('grouped by chapter: ' + groupedByChapter);

				for (Account chapter : scope) {
					
                    if (groupedByChapter != null && groupedByChapter.containsKey(chapter.Id)) {
                        if (!chapter.Chapter_Health__r.isEmpty()) {
							System.debug(chapter.Name + ' (' + chapter.Chapter_Health__r[0].Id + ')');
                            Chapter_Health__c relatedChapterHealthRecord = chapter.Chapter_Health__r[0];
                            if (chbToBeCalculated.Function__c == COUNT) {
                                relatedChapterHealthRecord.put(chbToBeCalculated.Target_Field_API_Name__c, groupedByChapter.get(chapter.id).size());
								System.debug('COUNT of ' + chbToBeCalculated.Target_Field_API_Name__c + ' = ' + groupedByChapter.get(chapter.id).size());
                            }
                            else if (chbToBeCalculated.Function__c == MAX) {
								List<Decimal> stats = new List<Decimal>(Pluck.decimals(chbToBeCalculated.Field_to_Aggregate__c, groupedByChapter.get(chapter.id)));
                                stats.sort();
                                relatedChapterHealthRecord.put(chbToBeCalculated.Target_Field_API_Name__c, stats[stats.size()-1]);
								System.debug('MAX of ' + chbToBeCalculated.Target_Field_API_Name__c + ' = ' + stats[stats.size()-1]);
                            }
                            else if (chbToBeCalculated.Function__c == MIN) {
                                List<Decimal> stats = new List<Decimal>(Pluck.decimals(chbToBeCalculated.Field_to_Aggregate__c, groupedByChapter.get(chapter.id)));
                                stats.sort();
                                relatedChapterHealthRecord.put(chbToBeCalculated.Target_Field_API_Name__c, stats[0]);
								System.debug('MIN of ' + chbToBeCalculated.Target_Field_API_Name__c + ' = ' + stats[0]);
                            }
                            else if (chbToBeCalculated.Function__c == SUM) {
                                //List<Decimal> stats = new List<Decimal>(Pluck.decimals(chbToBeCalculated.Field_to_Aggregate__c, groupedByChapter.get(chapter.id)));
                                Decimal total = 0;
                                
                                for (SObject obj : groupedByChapter.get(chapter.id)) {
                                  total += (Decimal) BluewolfDevUtils.getFieldValue(obj,chbToBeCalculated.Field_to_Aggregate__c ) != null ? 
										   (Decimal) BluewolfDevUtils.getFieldValue(obj,chbToBeCalculated.Field_to_Aggregate__c ) 
										   : 0.0;
                                }
                                relatedChapterHealthRecord.put(chbToBeCalculated.Target_Field_API_Name__c, total);
                                System.debug('SUM of ' + chbToBeCalculated.Target_Field_API_Name__c + ' = ' + total);
                            }
                            else if (chbToBeCalculated.Function__c == BOOL) {
                                Boolean isNotEmpty = false;
                                if (groupedByChapter.containsKey(chapter.id))
                                    isNotEmpty = !groupedByChapter.get(chapter.id).isEmpty(); 
                                relatedChapterHealthRecord.put(chbToBeCalculated.Target_Field_API_Name__c, isNotEmpty);
								System.debug('BOOL value of ' + chbToBeCalculated.Target_Field_API_Name__c + ' = ' + isNotEmpty);
                            }

                            chapterHealthRecordsToBeUpdated.add(relatedChapterHealthRecord);
                        }
                    }

					// no records returned for this chapter, so insert zero or false
					else { 
						if (!chapter.Chapter_Health__r.isEmpty()) {
							Chapter_Health__c relatedChapterHealthRecord = chapter.Chapter_Health__r[0];
							System.debug(chapter.Name + ' (' + chapter.Chapter_Health__r[0].Id + ')');
							System.debug('no results, setting to zero or false');
							if (chbToBeCalculated.Function__c == COUNT ||
								chbToBeCalculated.Function__c == MAX ||
								chbToBeCalculated.Field_to_Aggregate__c == MIN ||
								chbToBeCalculated.Function__c == SUM) relatedChapterHealthRecord.put(chbToBeCalculated.Target_Field_API_Name__c, 0);
							if (chbToBeCalculated.Function__c == BOOL) relatedChapterHealthRecord.put(chbToBeCalculated.Target_Field_API_Name__c, FALSE);
							chapterHealthRecordsToBeUpdated.add(relatedChapterHealthRecord);
						}
					}
                }
            }

			// no records returned by query, so set values to zero or false
			else { 
				for (Account chapter : scope) {
					if (!chapter.Chapter_Health__r.isEmpty()) {
						Chapter_Health__c relatedChapterHealthRecord = chapter.Chapter_Health__r[0];
						System.debug(chapter.Name + ' (' + chapter.Chapter_Health__r[0].Id + ')');
						System.debug('No results, setting to zero or false');
						if (chbToBeCalculated.Function__c == COUNT ||
							chbToBeCalculated.Function__c == MAX ||
							chbToBeCalculated.Field_to_Aggregate__c == MIN ||
							chbToBeCalculated.Function__c == SUM) relatedChapterHealthRecord.put(chbToBeCalculated.Target_Field_API_Name__c, 0);
						if (chbToBeCalculated.Function__c == BOOL) relatedChapterHealthRecord.put(chbToBeCalculated.Target_Field_API_Name__c, FALSE);
						chapterHealthRecordsToBeUpdated.add(relatedChapterHealthRecord);
					}
				}
			}
			if (!chapterHealthRecordsToBeUpdated.isEmpty()) {
				System.debug('Updates: ' + chapterHealthRecordsToBeUpdated);
				update chapterHealthRecordsToBeUpdated;
			}
        }
        catch(Exception dEx) {
            errorMessages.add(dEx.getMessage() + ' @ line #' + dEx.getLineNumber() + '\n');
        }
        return errorMessages;
    }

    public static List<String> calculateAndUpdateRegionalHealth(List<Account> scope, Chapter_Health_Batch__c chbToBeCalculated)
    {  
        System.debug('regional accounts: ' + scope.size());
        List<String> errorMessages = new List<String>();
        List<Region_Health__c> allRegionalHealths = new List<Region_Health__c>();
        for (Account region : scope) {
            allRegionalHealths.addAll(region.Region_Health__r);
        }
        
        Set<Id> regionalHealthIds = Pluck.ids(allRegionalHealths);
        System.debug('regionalHealthIds'+ regionalHealthIds);
        String query = 'SELECT Region_Health__c, ' + chbToBeCalculated.Field_to_Aggregate__c + ' ' +
					   'FROM Chapter_Health__c ' +
					   'WHERE Region_Health__c IN :regionalHealthIds '+
					   'AND RecordType.DeveloperName =\'Current\' ';
        List<sObject> queryRecords =  new List<sObject>();
        List<Region_Health__c> regionHealthRecordsToBeUpdated = new List<Region_Health__c>();      
        
		try {
            queryRecords = Database.query(query);   
            if (!queryRecords.isEmpty()) {
                Map<Id, List<sObject>> groupedByRegionHealth = GroupBy.ids('Region_Health__c', queryRecords);
                for (Account region : scope) {
                    for (Region_Health__c regionalHealthRecordToBeUpdated : region.Region_Health__r) {                        
                            System.debug('region: ' + region.Name);
                            if (groupedByRegionHealth != null && groupedByRegionHealth.containsKey(regionalHealthRecordToBeUpdated.Id)) {
                                List<Chapter_Health__c> relatedChapterHealthRecords = groupedByRegionHealth.get(regionalHealthRecordToBeUpdated.id);
                                
								//count - counts records where field to aggregate = soql query **do not use for bool values**
								if (chbToBeCalculated.Function__c == COUNT) {
									Integer total = 0;
                                    for (Chapter_Health__c ch: relatedChapterHealthRecords) {
                                       if (ch.get(chbToBeCalculated.Field_to_Aggregate__c)!=null && ch.get(chbToBeCalculated.Field_to_Aggregate__c) == chbToBeCalculated.SOQL_Query__c) {
                                           total += 1;
                                       }
                                    }
									System.debug('COUNT of ' + chbToBeCalculated.Field_to_Aggregate__c + ' = ' + total);
                                    regionalHealthRecordToBeUpdated.put(chbToBeCalculated.Target_Field_API_Name__c, total);
                                }

								//max
                                else if (chbToBeCalculated.Function__c == MAX) {
                                    List<Decimal> stats = new List<Decimal>(Pluck.decimals(chbToBeCalculated.Field_to_Aggregate__c, relatedChapterHealthRecords));
                                    stats.sort();
                                    regionalHealthRecordToBeUpdated.put(chbToBeCalculated.Target_Field_API_Name__c,
                                                                        stats[stats.size()-1]);
                                }

								//min
                                else if (chbToBeCalculated.Function__c == MIN) {
                                    List<Decimal> stats = new List<Decimal>(Pluck.decimals(chbToBeCalculated.Field_to_Aggregate__c, relatedChapterHealthRecords));
                                    stats.sort();
                                    regionalHealthRecordToBeUpdated.put(chbToBeCalculated.Target_Field_API_Name__c,
                                                                        stats[0]);
                                }

								//sum
                                else if (chbToBeCalculated.Function__c == SUM) {
                                    Decimal total = 0;
                                    for (Chapter_Health__c ch: relatedChapterHealthRecords) {
                                        System.debug(ch + ' --- '+ch.get(chbToBeCalculated.Field_to_Aggregate__c));
                                        if (ch.get(chbToBeCalculated.Field_to_Aggregate__c)!=null)
                                            total = total + (Decimal)ch.get(chbToBeCalculated.Field_to_Aggregate__c);
                                    }
                                    /*List<Decimal> stats = new List<Decimal>(Pluck.decimals(chbToBeCalculated.Field_to_Aggregate__c, relatedChapterHealthRecords));
                                    System.debug('stats '+stats);
                                    
                                    for (Decimal d: stats)
                                        total +=d;*/
                                    regionalHealthRecordToBeUpdated.put(chbToBeCalculated.Target_Field_API_Name__c, total);
                                }

								//boolean - counts records where field to aggregate = true
                                else if (chbToBeCalculated.Function__c == BOOL) {
                                  integer total = 0;
                                  for (Chapter_Health__c ch: relatedChapterHealthRecords) {
                                    if (ch.get(chbToBeCalculated.Field_to_Aggregate__c) == true)
                                      total += 1;
                                  }
                                  regionalHealthRecordToBeUpdated.put(chbToBeCalculated.Target_Field_API_Name__c, total);
                                }
                                regionHealthRecordsToBeUpdated.add(regionalHealthRecordToBeUpdated);
                            
                        }
                        update regionHealthRecordsToBeUpdated;
                    }
                }}}
        catch(Exception dEx) {
            errorMessages.add(dEx.getMessage() + ' @ line #' + dEx.getLineNumber() + '\n');
        }
        return errorMessages;
    }
    
	public static void sendBatchEmailNotification(Id jobId, String BATCH_JOB_Name, String errorMessage){
        
        if(Chapter_Health_Batch_Error_Email_Setting__c.getInstance().Error_Email_Recipients__c != null){
            String[] toAddress = Chapter_Health_Batch_Error_Email_Setting__c.getInstance().Error_Email_Recipients__c.split(';');
			//String[] toAddress = new String[] { 'mfrizzell@ypo.org' };
            AsyncApexJob job = [ SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
                                TotalJobItems, CreatedBy.Email, LastProcessedOffset
                                FROM AsyncApexJob 
                                WHERE Id =:jobId];
            //get accumulative statistics for the last subJob
            List<AsyncApexJob> subJobs = [ SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
                                          TotalJobItems, CreatedBy.Email, LastProcessedOffset
                                          FROM AsyncApexJob 
                                          WHERE ParentJobId =:job.Id 
                                          ORDER BY CompletedDate desc, LastProcessedOffset desc LIMIT 1];
            
            String emailBody = BATCH_JOB_Name + ' - ' + job.JobItemsProcessed + ' out of a total ' + job.TotalJobItems + ' were processed. \n\n';
            
            String emailSubject = 'Success: ';
            
            if(job.JobItemsProcessed != job.TotalJobItems) {
                emailBody += Label.UpdateChapterHealthDailyBatchProcessedJobsFailMessage;
                emailSubject = 'Failure: ';
            }
            if(errorMessage != null && errorMessage != ''){
                emailBody += errorMessage;
                emailSubject = 'Failure: ';
            }
            emailSubject += BATCH_JOB_Name + ' ' + System.Today().year() + '/' + System.Today().month() + '/' + System.Today().day();
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddress);        
            mail.setSaveAsActivity(false);
            mail.setSubject(emailSubject);     
            mail.setPlainTextBody(emailBody);
            If(!Test.isRunningTest())Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        }                
    }

}