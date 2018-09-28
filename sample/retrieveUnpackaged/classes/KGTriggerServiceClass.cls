/*
    This service class contains the methods invoked in KG triggers
    1) setRenewalOppsSubscription
    2) addWorldawareBenefit
    3) applySpouseDuesDiscounts
    4) applyBenefitDiscounts (ie YNG+)
    This class also contains the helper methods of these methods.
  */
public without sharing class KGTriggerServiceClass 
{
//*****************************************************************************
// 1) setRenewalOppsSubscription
//*****************************************************************************
    // Used in before insert Opportunity trigger
    // Set renewal Opp's Subscription to initial Opp's Subscription

    public static void setRenewalOppsSubscription( List<Opportunity> newList )
    {
        List<Opportunity> renewalOppList = new List<Opportunity>();
        Set<Id> previousOppIdSet = new Set<Id>();
        for( Opportunity opp : newList )
        {
            if( opp.KGRenewal__PreviousSale__c != null
                && ! opp.IsClosed )
            {
                renewalOppList.add( opp );
                previousOppIdSet.add( opp.KGRenewal__PreviousSale__c );
            }
        }

        // Exit if no renewal Opps
        if( renewalOppList.isEmpty() ) { return; }

        // get previous opps from cache or query if opps not in cache
        Map<Id, Opportunity> previousOppMap = getOppMap( previousOppIdSet );

        for( Opportunity opp : renewalOppList )
        {
            Opportunity previousOpp = previousOppMap.get( opp.KGRenewal__PreviousSale__c );
            if( previousOpp.KGRenewal__Subscription__c != null ) 
            {
                opp.KGRenewal__Subscription__c = previousOpp.KGRenewal__Subscription__c;
            }
        }
    }
//*****************************************************************************
    // cache of opps
    private static Map<Id, Opportunity> oppMapCache;
//*****************************************************************************
    // no query if opps already in cache, otherwise query and add opps to cache
    private static Map<Id, Opportunity> getOppMap( Set<Id> oppIdSet )
    {
        if( oppMapCache == null )
        { 
            oppMapCache = new Map<Id, Opportunity>(); 
        }
        for( Id oppId : oppIdSet )
        {
            if( ! oppMapCache.containsKey( oppId ) )
            {
                // map doesn't have one of the opps - put all opps into the map
                oppMapCache.putAll( [SELECT KGRenewal__Subscription__c
                                        FROM Opportunity
                                        WHERE Id IN :oppIdSet] );
                // break from loop after query - only need to query once
                break;
            }
        }
        return oppMapCache;
    }
//*****************************************************************************
// 2) addWorldawareBenefit
//*****************************************************************************
  // Add complementary Worldaware benefit to Opportunity for YPO Gold members
  // if the contact (opportunity contact role) doesn't already have it for the current
  // fiscal year
/*
  // Complimentary Worldaware YPO Gold Feature disabled (Backlog Item-06369)
  public static void addWorldawareBenefit( List<Opportunity> newList ) 
  {
    List<Opportunity> oppList = new List<Opportunity>();
    for( Opportunity opp : newList )
    {
      if( opp.Worldaware_YPO_Gold_Count__c < 1
          && ! opp.IsClosed )
      {
        oppList.add( opp );
      }
    }
    if( oppList.isEmpty() ) { return; }
  
    // Is the Contact YPO Gold?
    List<OpportunityContactRole> ocrList = [SELECT ContactId, 
                                                    OpportunityId,
                                                    Opportunity.Pricebook2Id, 
                                                    Opportunity.KGRenewal__ContractEndDate__c 
                                              FROM OpportunityContactRole
                                              WHERE OpportunityId IN :oppList
                                                AND Contact.YPO_WPO_Formula__c = 'YPO Gold'
                                                AND IsPrimary = true
                                              ORDER BY Opportunity.CreatedDate];
    // No YPO Gold Contacts so exit
    if( ocrList.isEmpty() ) { return; }

    // These are the contacts and Opps we might have to create the new line items for
    Map<String, OpportunityContactRole> contactToOcrMap = new Map<String, OpportunityContactRole>();
    Set<Id> contactIdSet = new Set<Id>();

    for( OpportunityContactRole ocr : ocrList )
    {
      if( ocr.Opportunity.Pricebook2Id != null
          && ocr.Opportunity.KGRenewal__ContractEndDate__c != null )
      {
        final String contactDateKey = '' + ocr.ContactId + ocr.Opportunity.KGRenewal__ContractEndDate__c;
        contactToOcrMap.put( contactDateKey, ocr );
        contactIdSet.add( ocr.ContactId );
      }
    }

    if( contactToOcrMap.isEmpty() ) { return; }

    List<OpportunityContactRole> ocrWithBenefit = [ SELECT ContactId,
                                                           Opportunity.KGRenewal__ContractEndDate__c
                                                      FROM OpportunityContactRole
                                                      WHERE ContactId IN :contactIdSet 
                                                        AND IsPrimary = true
                                                        AND Opportunity.Worldaware_YPO_Gold_Count__c > 0
                                                      ORDER BY Opportunity.CreatedDate ];

    for( OpportunityContactRole ocr : ocrWithBenefit )
    {
      final String contactDateKey = '' + ocr.ContactId + ocr.Opportunity.KGRenewal__ContractEndDate__c;
      contactToOcrMap.remove( contactDateKey );
    }

    if( contactToOcrMap.isEmpty() ) { return; }

    // get pricebook entries for Worldaware YPO Gold
    List<PricebookEntry> pbeList = [ SELECT Pricebook2Id
                                      FROM PricebookEntry
                                      WHERE Product2.Worldaware_benefit__c = true
                                        AND Product2.Complimentary_WPO_Product__c = true
                                        AND IsActive = true ];
    Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>();
    for( PricebookEntry pbe : pbeList )
    {
      pbeMap.put( pbe.Pricebook2Id, pbe );
    }

    List<OpportunityLineItem> oliListToInsert = new List<OpportunityLineItem>();

    for( OpportunityContactRole ocr : contactToOcrMap.values() )
    {
      PricebookEntry pbe = pbeMap.get( ocr.Opportunity.Pricebook2Id );
      if( pbe == null )
      {
        throw new dataSetupException('No active Worldaware YPO Gold product and/or pricebook entry (Opp: '
                                      + ocr.OpportunityId + ' Pricebook: ' + pbe.Id + ')');
      }
      oliListToInsert.add( new OpportunityLineItem( PricebookEntryId = pbe.Id,
                                                    OpportunityId = ocr.OpportunityId,
                                                    UnitPrice = 0,
                                                    Quantity = 1,
                                                    Contact__c = ocr.contactId ) );
    }
    insert oliListToInsert;
  }
*/
//*****************************************************************************
// 3) applySpouseDuesDiscounts
//*****************************************************************************
  // Applies a 50% discount to 'Annual Dues' product.family if either
  // (a) OCR's Contact's Spouse/Partner checkbox is checked or
  // (b) OCR's Contact's Membership Status indicates they are a Surviving Spouse/Partner

  public static void applySpouseDuesDiscounts( List<OpportunityLineItem> oliList )
  {
    
    Map<Id, Product2> productMap = getProductMap( oliList );

    List<OpportunityLineItem> annualDuesOliList = new List<OpportunityLineItem>();
    Set<Id> annualDuesOppIdSet =  new Set<Id>();
    for( OpportunityLineItem oli : oliList )
    {
      Product2 prod = productMap.get( oli.Product2Id );
      if( 'Annual Dues'.equalsIgnoreCase(prod.Family) 
          // If any of the below is missing, we won't be able to process the oli
          && oli.OpportunityId != null )
      {
        annualDuesOliList.add( oli );
        annualDuesOppIdSet.add( oli.OpportunityId );
      }
    }

    // No Annual Dues Line Items so exit
    if( annualDuesOliList.isEmpty() ) { return; }
    RecordType spousePartnerRecordType = RecordTypeServices.getRecordTypeByName('Spouse/Partner', 'Contact');
    
    List<OpportunityContactRole> ocrList = [SELECT OpportunityId
                                              FROM OpportunityContactRole
                                              WHERE IsPrimary = true
                                                AND (Contact.Is_Spouse_Member__c = true
                                                OR Contact.Membership_status__c = 'Surviving Spouse/Partner')
                                                AND OpportunityId IN :annualDuesOppIdSet];
    // No spouse OCRs so exit
    if( ocrList.isEmpty() ) { return; }
    

    Map<Id, OpportunityContactRole> spouseOcrMap = new Map<Id, OpportunityContactRole>();
    for( OpportunityContactRole ocr : ocrList ) 
    {
      spouseOcrMap.put( ocr.OpportunityId, ocr );
    }

    for( OpportunityLineItem oli : annualDuesOliList )
    {
      if( spouseOcrMap.containsKey(oli.OpportunityId))
      {
        // This item is for a spouse
        // Apply a 50% discount to 'Annual Dues' item
        oli.discount = 50;
      }
    }
  }
//*****************************************************************************
// 4) applyBenefitDiscounts (ie YNG+)
//*****************************************************************************
// Max for all YNG+ products for the Contact should be $895 for the fiscal year
  public static void applyBenefitDiscounts( List<OpportunityLineItem> oliList )
  {
    final Decimal YNG_MAX = 895.00;
    final String PRODUCT_FAMILY = 'Member Benefit';
    final String PRODUCT_EXCLUSIVE = 'YNG';

    // Do we have any matching Benefit Line Items?
    final Map<Id, Product2> productMap = getProductMap( oliList );

    List<OpportunityLineItem> benefitOliList = new List<OpportunityLineItem>();
    Set<Id> benefitOppIdSet =  new Set<Id>();
    System.debug( '***** oliList.size(): ' + oliList.size() );
    for( OpportunityLineItem oli : oliList )
    {
      final Product2 prod = productMap.get( oli.Product2Id );
      System.debug( '***** Product2.Name: ' + prod.Name );
      System.debug( '***** oli.Quantity: ' + oli.Quantity );
      if( PRODUCT_FAMILY.equalsIgnoreCase(prod.Family) 
          && PRODUCT_EXCLUSIVE.equalsIgnoreCase(prod.Exclusive__c)
          // If any of the below is missing, we won't be able to process the oli
          && oli.OpportunityId != null
          && oli.Quantity != null 
          && oli.UnitPrice != null ) 
      {
        System.debug( '***** Benefit Oli found' );
        System.debug( '***** oli.Id: ' + oli.Id );
        System.debug( '***** oli.OpportunityId: ' + oli.OpportunityId );
        benefitOliList.add( oli );
        benefitOppIdSet.add( oli.OpportunityId );
      }
    }

    // No matching Benefit Line Items so exit
    if( benefitOliList.isEmpty() ) { return; }
    
    System.debug( '***** benefitOppIdSet: ' + benefitOppIdSet );

    // Get Opp totals for the OLIs we are inserting/deleting
    List<OpportunityContactRole> currentOcrList = [ SELECT ContactId, 
                                                    OpportunityId,
                                                    Opportunity.YNG_Plus_Total__c, 
                                                    Opportunity.KGRenewal__ContractEndDate__c
                                              FROM OpportunityContactRole
                                              WHERE OpportunityId IN :benefitOppIdSet
                                                AND IsPrimary = true ];

    System.debug( '***** currentOcrList.size(): ' + currentOcrList.size() );
    
    // Determine the contacts for the OLIs we are inserting/deleting
    Map<Id, String> oppToContactMap = new Map<Id, String>();
    Set<Id> contactIdSet = new Set<Id>();

    for( OpportunityContactRole ocr : currentOcrList )
    {
      if( ocr.Opportunity.KGRenewal__ContractEndDate__c != null )
        {
          final String contactDateKey = '' + ocr.ContactId + ocr.Opportunity.KGRenewal__ContractEndDate__c;
          System.debug( '***** contactDateKey: ' + contactDateKey );
          oppToContactMap.put( ocr.OpportunityId, contactDateKey );
          contactIdSet.add( ocr.ContactId );
        }
    }

    // Get other Opps for these contacts from these fiscal years
    List<OpportunityContactRole> allOcrList = [ SELECT ContactId, 
                                                        OpportunityId, 
                                                        Opportunity.YNG_Plus_Total__c, 
                                                        Opportunity.KGRenewal__ContractEndDate__c 
                                                  FROM OpportunityContactRole
                                                  WHERE ContactId IN :contactIdSet
                                                    AND IsPrimary = true 
                                                    AND ( Opportunity.IsWon = true
                                                          OR Opportunity.IsClosed = false) ];
    System.debug( '***** allOcrList.size(): ' + allOcrList.size() );
    
    // ocrMap has combined list for current benefit oli and all related Opps
    // (map used to prevent duplicate ocrs)
    Map<Id, OpportunityContactRole> ocrMap = new Map<Id, OpportunityContactRole>( allOCRList );
    ocrMap.putAll( currentOcrList );

    // Sum up Benefit totals for each contact
    Map<String, Decimal> contactTotalMap = new Map<String, Decimal>();
    for( OpportunityContactRole ocr : ocrMap.values() ) 
    {
      final String contactDateKey = '' + ocr.ContactId + ocr.Opportunity.KGRenewal__ContractEndDate__c;
      Decimal total = ocr.Opportunity.YNG_Plus_Total__c.setScale(2);
      if( contactTotalMap.containsKey( contactDateKey ) )
      {
        total += contactTotalMap.get( contactDateKey );
      }
      contactTotalMap.put( contactDateKey, total );
    }

    if( Trigger.isInsert )
    {
      for( OpportunityLineItem oli : benefitOliList )
      {
        System.debug( '***** benefit oli: ' + oli );
        // calculating subtotal since oli.Subtotal can be null when inserting an oli
        final Decimal subtotal = ( oli.Quantity * oli.UnitPrice ).setScale(2);
        System.debug( '***** benefit oli subtotal: ' + subtotal );

        final String contactDateKey = oppToContactMap.get( oli.OpportunityId );
        // Note: the Opp could be a Renewal Opp that is being inserted
        System.assert( contactDateKey != null, 'No Primary Opportunity Contact Role for Opp ' + oli.OpportunityId );

        final Decimal contactTotal = contactTotalMap.get( contactDateKey );

        // Throws exception if Opp does not have Opportunity Contact Role
        if( contactTotal >= YNG_MAX )
        {
          oli.Discount = 100.00;
        }
        else if( contactTotal + subtotal > YNG_MAX )
        {
          Decimal oliPrice = YNG_MAX - contactTotal;
          oli.Discount = 100.00 * (1 - oliPrice/subtotal);
          contactTotalMap.put( contactDateKey, YNG_MAX );
        }
        else
        {
          oli.Discount = 0.00;
          contactTotalMap.put( contactDateKey, contactTotal + subtotal );
        }
      }
    }
    else if( Trigger.isDelete )
    {
      // Determine if deleting any line items means we have to adjust discounts
      // on remaining YNG+ benefit line items
      benefitOppIdSet.clear();
      for( OpportunityLineItem oli : benefitOliList )
      {
        String contactDateKey = oppToContactMap.get( oli.OpportunityId );
        Decimal contactTotal = contactTotalMap.get( contactDateKey );

        if( contactTotal + oli.TotalPrice > YNG_MAX )
        {
          // deleting this benefit oli
          benefitOppIdSet.add( oli.OpportunityId );
        }
        contactTotalMap.put( contactDateKey, contactTotal + oli.TotalPrice );
      }

      // deleting benefit line items does not require changes to other line items so exit
      if( benefitOppIdSet.isEmpty() ) { return; }

      // otherOcrMap has list of other Opps (Opps for current benefit olis are removed)
      for( OpportunityContactRole currentOcr : currentOcrList )
      {
        ocrMap.remove( currentOcr.Id );
      }
      // Sum up Benefit totals for each contact
      contactTotalMap.clear();
      for( OpportunityContactRole ocr : ocrMap.values() ) 
      {
        final String contactDateKey = '' + ocr.ContactId + ocr.Opportunity.KGRenewal__ContractEndDate__c;
        Decimal total = ocr.Opportunity.YNG_Plus_Total__c.setScale(2);
        if( contactTotalMap.containsKey( contactDateKey ) )
        {
          total += contactTotalMap.get( contactDateKey );
        }
        contactTotalMap.put( contactDateKey, total );
      }

      benefitOliList = [SELECT OpportunityId,
                                Subtotal,
                                Discount
                          FROM OpportunityLineItem
                          WHERE OpportunityId IN :benefitOppIdSet
                            AND Product2.Family = :PRODUCT_FAMILY
                            AND Product2.Exclusive__c = :PRODUCT_EXCLUSIVE
                          ORDER BY TotalPrice DESC];

      List<OpportunityLineItem> oliListToUpdate = new List<OpportunityLineItem>();
      // Increase price (reduce discount)
      for( OpportunityLineItem oli : benefitOliList )
      {
        System.assertNotEquals( oli.Subtotal, null, 'oli.Subtotal is null' );
        final Decimal subtotal = oli.Subtotal.setScale(2);
        // value of discount before we re-calculate new discount
        final Decimal originalDiscount = oli.Discount;
        final String contactDateKey = oppToContactMap.get( oli.OpportunityId );
        final Decimal contactTotal;
        // *** contactTotal could be null if there are no other Opps for this contact
        if( contactTotalMap.containsKey(contactDateKey) )
        {
            contactTotal = contactTotalMap.get( contactDateKey );
        }
        else
        {
            contactTotal = 0.00;
        }
        
        // Throws exception if Opp does not have Opportunity Contact Role
        if( contactTotal >= YNG_MAX )
        {
          oli.Discount = 100.00;
        }
        else if( contactTotal + subtotal > YNG_MAX )
        {
          Decimal oliPrice = YNG_MAX - contactTotal;
          oli.Discount = 100.00 * (1 - oliPrice/subtotal);
          contactTotalMap.put( contactDateKey, YNG_MAX );
        }
        else
        {
          oli.Discount = 0.00;
          contactTotalMap.put( contactDateKey, contactTotal + subtotal );
        }
        if( originalDiscount != oli.Discount )
        {
          oliListToUpdate.add( oli );
        }
      }      
      update oliListToUpdate;
    }
  }
//*****************************************************************************
// HELPER METHODS
//*****************************************************************************
    private static Map<Id, Product2> prodMap;
    /*
    * Initializes and returns a Map of Products created from a list of
    * OpportunityLineItems.
    */
    private static Map<Id, Product2> getProductMap( List<OpportunityLineItem> oliList )
    {
        if( prodMap == null )
        {
            prodMap = new Map<Id, Product2>();
        }

        if( oliList == null || oliList.isEmpty() ) 
        {
            return prodMap;
        }

        Set<Id> productIdSet = new Set<Id>();
        for( OpportunityLineItem oli : oliList ) 
        {
            if( ! prodMap.containsKey(oli.product2Id) )
            {
                // Map doesn't have the product
                productIdSet.add( oli.product2Id );
            }
        }
        //system.debug('productIdSet: ' + productIdSet);
        if( productIdSet.size() > 0 ) 
        {
            // Need to add products to the map
            List<Product2> productList = [SELECT Name,
                                                 Family, 
                                                 Exclusive__c 
                                            FROM Product2 
                                            WHERE Id IN :productIdSet];
            prodMap.putAll( productList );
        }
        return prodMap;
    }
//*****************************************************************************
// Exceptions
//*****************************************************************************
    public class dataSetupException extends Exception {}
//*****************************************************************************
}