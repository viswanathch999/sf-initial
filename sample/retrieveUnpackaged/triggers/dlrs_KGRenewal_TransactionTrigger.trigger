/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_KGRenewal_TransactionTrigger on KGRenewal__Transaction__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(KGRenewal__Transaction__c.SObjectType);
}