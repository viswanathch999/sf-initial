@isTest
private class MarketingContContactExtTest {
    static Account testAccount;
    static Contact testContact;
    static SegmentContent__c customSetting;
    static final String DEFAULT_SEGEMENT_CODE = 'S6';
    static final String PAGE_ERR_MSG = MarketingContContactExt.CS_ERROR + DEFAULT_SEGEMENT_CODE; // Updated on 20 Feb 2016
    static final String JPG_IMG = '.jpg';
    
    static void setupCustomSetting()
    {
        customSetting = new SegmentContent__c();
        customSetting.Name = DEFAULT_SEGEMENT_CODE;
        customSetting.TopSpotImageName__c  = 'testTopImage';
        customSetting.TopSpotUrl__c   = 'testTopURL';
        customSetting.TopSpotUrlText__c = 'testTopURLText';
        customSetting.TopTitleText__c  = 'testTopTitleText';
        
        customSetting.BottomSpot1ImageName__c = 'testBottomImage1';
        customSetting.BottomSpot1UrlText__c = 'testBottomUrlText1';
        customSetting.BottomSpot1Url__c = 'testBottomUrl1';
        customSetting.BottomSpot1Text__c = 'testBottomText1';
        
        customSetting.BottomSpot2ImageName__c = 'testBottomImage2';
        customSetting.BottomSpot2UrlText__c = 'testBottomUrlText2';
        customSetting.BottomSpot2Url__c = 'testBottomUrl2';
        customSetting.BottomSpot2Text__c = 'testBottomText2';
        
        insert customSetting;
    }
    
    static void setupData()
    {
        testAccount = TestServices.createAccount('testAccount');
        insert testAccount;
        
        
        Map<String,Object> fieldToValues = 
            new Map<String,Object>{
                                    'LastName' =>'testLastName',
                                    'FirstName' => 'testFistName',
                                    'AccountId' => testAccount.Id,
                                    //'S6__c' => '10',
                                    'Marketing_Segment__c' => DEFAULT_SEGEMENT_CODE                 
                                  };
        testContact = (Contact) JSONUtils.createSObject(Contact.SObjectType,fieldToValues);
        insert testContact;
        
    }
    static testMethod void ControllerConstructor()
    {
        setupData();
        PageReference currentPage = Page.Marketing;
        Test.setCurrentPage(currentPage);
        Test.startTest();
            ApexPages.standardController stdCont = 
                new ApexPages.standardController(testContact);
            MarketingContContactExt contEx = 
                new MarketingContContactExt(stdCont);
        Test.stopTest();
        
        System.assertEquals(testContact,contEx.CONTACT_RECORD,'Contact Record should have been set by Standard Controller');
        System.assertEquals(DEFAULT_SEGEMENT_CODE,contEx.SEGMENT_CODE,'Contract Record should be setup to have the default segment code');      
        
        
    }
    static testMethod void testCustomSetup_Pass()
    {
        setupData();
        setupCustomSetting();
        PageReference currentPage = Page.Marketing;
        Test.setCurrentPage(currentPage);
        ApexPages.standardController stdCont = new ApexPages.standardController(testContact);
        MarketingContContactExt contEx = new MarketingContContactExt(stdCont);
        Boolean expected = true;
        Test.startTest();
            Boolean actual = contEx.isCustomSettingSetup;
        Test.stopTest();
        
        System.assertEquals(expected,actual,'These two values should be the same');
    }
    static testMethod void testCustomSetup_Fail()
    {
        setupData();
        PageReference currentPage = Page.Marketing;
        Test.setCurrentPage(currentPage);
        ApexPages.standardController stdCont = new ApexPages.standardController(testContact);
        MarketingContContactExt contEx = new MarketingContContactExt(stdCont);
        Boolean expected = false;
        
        Test.startTest();
            Boolean actual = contEx.isCustomSettingSetup;
        Test.stopTest();
        
        System.assertEquals(expected,actual,'These two values should be the same');
        System.assertEquals(PAGE_ERR_MSG,
                            (ApexPages.getMessages()[0]).getSummary(),
                            'These two values should be the same');
    }
    static testMethod void testPopulateSegmentContents()
    {
        setupData();
        setupCustomSetting();
        PageReference currentPage = Page.Marketing;
        Test.setCurrentPage(currentPage);
        ApexPages.standardController stdCont = new ApexPages.standardController(testContact);
        MarketingContContactExt contEx = new MarketingContContactExt(stdCont);
        
        Test.startTest();
            contEx.populateSegmentContents();
        Test.stopTest();
        
        System.assertEquals(customSetting.TopSpotImageName__c + JPG_IMG,
                            contEx.topSpotImage,'These two values should be the same');
        System.assertEquals(customSetting.TopSpotUrl__c,
                            contEx.topSpotUrl,'These two values should be the same');
        System.assertEquals(customSetting.TopSpotUrlText__c,
                            contEx.topSpotUrlText,'These two values should be the same');
        System.assertEquals(customSetting.TopTitleText__c,
                            contEx.topSpotTitleText,'These two values should be the same');
        
        System.assertEquals(customSetting.BottomSpot1ImageName__c + JPG_IMG,
                            contEx.bottomSpot1Image,'These two values should be the same');
        System.assertEquals(customSetting.BottomSpot1UrlText__c,
                            contEx.bottomSpot1UrlText,'These two values should be the same'); // Updated on 20 Feb 2016
        System.assertEquals(customSetting.BottomSpot1Url__c,
                            contEx.bottomSpot1Url,'These two values should be the same'); // Updated on 20 Feb 2016
        System.assertEquals(customSetting.BottomSpot1Text__c,
                            contEx.bottomSpot1TitleText,'These two values should be the same');
        
        System.assertEquals(customSetting.BottomSpot2ImageName__c + JPG_IMG,
                            contEx.bottomSpot2Image,'These two values should be the same');
        System.assertEquals(customSetting.BottomSpot2UrlText__c,
                            contEx.bottomSpot2UrlText,'These two values should be the same'); // Updated on 20 Feb 2016
        System.assertEquals(customSetting.BottomSpot2Url__c,
                            contEx.bottomSpot2Url,'These two values should be the same'); // Updated on 20 Feb 2016
        System.assertEquals(customSetting.BottomSpot2Text__c,
                            contEx.bottomSpot2TitleText,'These two values should be the same');
        
    }
    
    
    
}