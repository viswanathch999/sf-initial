trigger StagingCventTransactionBatching on Staging_Cvent_Transaction_Detail__c (before insert) {
ffirule.IntegrationRuleEngine.triggerHandler();
}