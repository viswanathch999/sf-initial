public class FiscalDateUtility {

    public static Date todaysDate{get{
        if(todaysDate == null)
            todaysDate = System.today();
        return todaysDate;
    } set; }                            

    public static Period currentFicalPeriod{
        get{
            if(currentFicalPeriod == null)
                currentFicalPeriod = [Select Type, StartDate, EndDate, Number, FiscalYearSettings.PeriodId From Period Where Type='Year' and startDate <= :todaysDate /*TODAY*/ and endDate >= :todaysDate/*TODAY*/];
            return currentFicalPeriod;
        }set;}
    
  public static Date startOfCurrentFiscal {
        get{
            if(startOfCurrentFiscal== null)
                startOfCurrentFiscal = currentFicalPeriod.StartDate;
            //System.today().month()>FiscalYearEndMonth?Date.newInstance(system.today().year(), 7 , 1):Date.newInstance(system.today().year()-1, 7 , 1);
            return startOfCurrentFiscal;
        }set;}
    
    public static Date startOfNextFiscal {
        get{
            if(startOfNextFiscal== null)
                startOfNextFiscal = currentFicalPeriod.StartDate.addyears(1);
            //System.today().month()>FiscalYearEndMonth?Date.newInstance(system.today().year(), 7 , 1):Date.newInstance(system.today().year()-1, 7 , 1);
            return startOfNextFiscal;
        }set;}
    
    public static Date startOfPrevFiscal {
        get{
            if(startOfPrevFiscal== null)
                startOfPrevFiscal = currentFicalPeriod.StartDate.addyears(-1); 
            //System.today().month()>FiscalYearEndMonth?Date.newInstance(system.today().year()-1, 7 , 1):Date.newInstance(system.today().year()-2, 7 , 1);
            return startOfPrevFiscal;
        }set;}    
    
    public static Date endOfCurrentFiscal {
        get{
            if(endOfCurrentFiscal== null)
                endOfCurrentFiscal = currentFicalPeriod.EndDate;
            //System.today().month()>FiscalYearEndMonth?Date.newInstance(system.today().year(), 7 , 1):Date.newInstance(system.today().year()-1, 7 , 1);
            return endOfCurrentFiscal;
        }set;}
    
    public static Date endOfPrevFiscal {
        get{
            if(endOfPrevFiscal== null)
                endOfPrevFiscal = currentFicalPeriod.EndDate.addyears(-1); 
            //System.today().month()>FiscalYearEndMonth?Date.newInstance(system.today().year()-1, 7 , 1):Date.newInstance(system.today().year()-2, 7 , 1);
            return endOfPrevFiscal;
        }set;} 
   
    public static Period currentFiscalQuarterPeriod{
        get{
            if(currentFiscalQuarterPeriod == null)
                currentFiscalQuarterPeriod = [Select Type, StartDate, EndDate, Number, FiscalYearSettings.PeriodId From Period Where Type='Quarter'
                                             and startDate <= :todaysDate /*TODAY*/ and endDate >= :todaysDate /*TODAY*/];
            return currentFiscalQuarterPeriod;
        }set;}
    
  public static Date startOfCurrentFiscalQtr {
    get {
      if (startOfCurrentFiscalQtr == null)
        startOfCurrentFiscalQtr = currentFiscalQuarterPeriod.StartDate;
      return startOfCurrentFiscalQtr;
    } set;
  }

  public static Date endOfCurrentFiscalQuarter {
        get{
            if(endOfCurrentFiscalQuarter== null)
                endOfCurrentFiscalQuarter = currentFiscalQuarterPeriod.EndDate;
            return endOfCurrentFiscalQuarter;
        }set;}

    public static Integer currentFiscalQuarterNum {
        get{
            if(currentFiscalQuarterNum== null)
                currentFiscalQuarterNum = currentFiscalQuarterPeriod.Number;
            return currentFiscalQuarterNum;
        }set;}

    public static String currentFiscalQuarter {
        get{
            if(currentFiscalQuarter== null)
                currentFiscalQuarter = 'Q-'+currentFiscalQuarterPeriod.Number;
            return currentFiscalQuarter;
        }set;}

  public static String currentFiscalYear {
    get {
      // YPO FY naming convention is one year ahead of SF, so we add 1 to the value
      // Example: 2017/7/1 to 2018/6/30 shoud be FY2018, not 2017
      Integer fYear;
      try { fYear = Integer.valueOf([SELECT Id, Name FROM FiscalYearSettings WHERE StartDate <= TODAY and EndDate >= TODAY LIMIT 1].Name) + 1; }
      catch (Exception e) { }
      return String.valueOf(fYear);
    }
    set;
  }

  public static String previousFiscalYear {
    get {
      // YPO FY naming convention is one year ahead of SF, so no need to add to the value to get previous FY
      Integer fYear;
      try { fYear = Integer.valueOf([SELECT Id, Name FROM FiscalYearSettings WHERE StartDate <= TODAY and EndDate >= TODAY LIMIT 1].Name); }
      catch (Exception e) { }
      return String.valueOf(fYear);
    }
    set;
  }

  public static Period getFiscalYear(Date thisDate) {
    Period thisFY;
    if (thisDate != null)
      thisFY = [SELECT Id, Number, PeriodLabel, QuarterLabel, StartDate, EndDate, Type FROM Period WHERE Type = 'Year' AND StartDate <= :thisDate AND EndDate >= :thisDate];
    return thisFY;
  }

  public static Period getFiscalQuarter(Date thisDate) {
    Period thisFQ;
    if (thisDate != null)
      thisFQ = [SELECT Id, Number, PeriodLabel, QuarterLabel, StartDate, EndDate, Type FROM Period WHERE Type = 'Quarter' AND StartDate <= :thisDate AND EndDate >= :thisDate];
    return thisFQ;
  }

}