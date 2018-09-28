trigger KG_OppLineItem_Trigger on OpportunityLineItem (before insert, after delete)
{
    if( Trigger.isBefore && Trigger.isInsert )
    {
      // YNG+ benefit discounts
      KGTriggerServiceClass.applyBenefitDiscounts( Trigger.new );
      // Spouse Annual Dues discounts
      KGTriggerServiceClass.applySpouseDuesDiscounts( Trigger.new );
    }

    if( Trigger.isAfter && Trigger.isDelete )
    {
      // YNG+ benefit discounts
      KGTriggerServiceClass.applyBenefitDiscounts( Trigger.old );
    }
}