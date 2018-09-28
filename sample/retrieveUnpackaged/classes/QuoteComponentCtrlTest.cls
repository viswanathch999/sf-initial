@isTest
public with sharing class QuoteComponentCtrlTest {

  @isTest
  public static void testQuotes(){
    Opportunity o = new Opportunity(
      Name = 'test opty',
      CloseDate = System.today(),
      StageName = 'test stage'
    );
    insert o;

    QuoteComponentCtrl ctrl = new QuoteComponentCtrl();

    ApexPages.StandardController stdCtrl = new ApexPages.StandardController(o);
    ctrl = new QuoteComponentCtrl(stdCtrl);

    ctrl = new QuoteComponentCtrl(o.Id, 'test-quote');

    System.debug(ctrl.currentDate);
    System.debug(ctrl.expirationDate );
    System.debug(ctrl.formatCurrency(666.6) );
    ctrl.isMultiCurrencyOrganization = false;
    //System.debug(ctrl.taxedAmount );
    System.debug(ctrl.CurrencyISOCode  );
    System.debug(ctrl.totalListPrice );
    System.debug(ctrl.pageTitle  );
    System.debug(ctrl.quoteNumber  );
    ctrl.quoteNumber = null;
    System.debug(ctrl.quoteNumber   );
    System.debug(ctrl.opportunityRecord);

  }


}