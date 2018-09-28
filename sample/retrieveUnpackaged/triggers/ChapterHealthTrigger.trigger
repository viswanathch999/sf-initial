trigger ChapterHealthTrigger on Chapter_Health__c (after insert, after update) {
    
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {

        // Update Chapter Below Minimum Standards (CBMS) flag on Account
        String CHAP_YPO = 'YPO Chapter';
        String CHAP_YPO_GOLD = 'YPO Gold Chapter';

        List<Account> acctsToUpdate = new List<Account>();
        List<Account> chapters = new List<Account>();

        try { 
            chapters = [SELECT Id, CBMS__c, YPOI_Type__c FROM Account WHERE Id IN :Pluck.ids('Account__c', Trigger.new)];
        }
        catch (Exception e) { 
            System.debug('Error retrieving Chapters: ' + e.getMessage());
        }

        for (Chapter_Health__c ch : Trigger.new) {
            for (Account chap : chapters) {
                if (ch.Account__c == chap.Id) {
                
                    // YPO Chapters
                    // Primary members >= 16
                    // Chapter Events >= 4
                    // Chapter Chair and Learning Officer = TRUE
                    if (chap.YPOI_Type__c == CHAP_YPO) {
                        if (ch.Number_Primary_Members_Current__c >= 16 && ch.Total_Number_Chapter_Events__c >= 4 && ch.Chapter_Ed_Chair_Identified__c == true) {
                            chap.CBMS__c = false;
                        }
                        else {
                            chap.CBMS__c = true;
                        }
                    }

                    // YPO Gold Chapters
                    // Primary & Secondary members >= 16
                    // Chapter Events >= 4
                    // Chapter Chair and Learning Officer = TRUE
                    else if (chap.YPOI_Type__c == CHAP_YPO_GOLD) {
                        if (ch.Number_Pri_Sec_Members__c >= 16 && ch.Total_Number_Chapter_Events__c >= 4 && ch.Chapter_Ed_Chair_Identified__c == true) {
                            chap.CBMS__c = false;
                        }
                        else {
                            chap.CBMS__c = true;
                        }
                    }
                    acctsToUpdate.add(chap);
                }
            }
        }

        if (!acctsToUpdate.isEmpty()) {
            try {
                update acctsToUpdate;
            } 
            catch (Exception e) {
                System.debug('Error updating accounts: ' + e);
            }
        } // End - update CBMS flag

    }
}