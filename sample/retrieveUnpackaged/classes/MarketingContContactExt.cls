public with sharing class MarketingContContactExt {
    
    @TestVisible private final Contact CONTACT_RECORD;
    @TestVisible private final String SEGMENT_CODE;
    @TestVisible private static final String CS_ERROR = 'Custom Setting is not setup for this segment code: ';
    private static final String JPG_IMG = '.jpg';
    public String topSpotImage{get; private set;}
    public String topSpotUrl{get; private set;}
    public String topSpotUrlText{get; private set;}
    public String topSpotTitleText{get; private set;}
    
    public String bottomSpot1Image{get; private set;}
    public String bottomSpot1Url{get; private set;}
    public String bottomSpot1UrlText{get; private set;}
    public String bottomSpot1TitleText{get; private set;}
    
    public String bottomSpot2Image{get; private set;}
    public String bottomSpot2Url{get; private set;}
    public String bottomSpot2UrlText{get; private set;}
    public String bottomSpot2TitleText{get; private set;}
    
    @TestVisible private Boolean isCustomSettingSetup
    {
        get
        {
            boolean exist = SegmentContent__c.getInstance(SEGMENT_CODE)!= null? true:false;
            if(!exist){
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR ,CS_ERROR + SEGMENT_CODE));
            }
            return exist; 
        }
    }
    
    public MarketingContContactExt(ApexPages.standardController stdCont){
        if(!Test.isRunningTest()) // Added on 20 Feb 2016
            stdCont.addFields(new List<String>{'Marketing_Segment__c'});
            
        this.CONTACT_RECORD = (Contact) stdCont.getRecord();
        this.SEGMENT_CODE = CONTACT_RECORD.Marketing_Segment__c;
    }
    
    public void populateSegmentContents(){
        if(isCustomSettingSetup){
            SegmentContent__c content = SegmentContent__c.getInstance(SEGMENT_CODE);
            topSpotImage = content.TopSpotImageName__c + JPG_IMG;
            topSpotUrl = content.TopSpotUrl__c ;
            topSpotUrlText = content.TopSpotUrlText__c;
            topSpotTitleText = content.TopTitleText__c ;
            
            bottomSpot1Image = content.BottomSpot1ImageName__c + JPG_IMG;
            bottomSpot1UrlText = content.BottomSpot1UrlText__c ;
            bottomSpot1Url = content.BottomSpot1Url__c ;
            bottomSpot1TitleText = content.BottomSpot1Text__c ;
            
            bottomSpot2Image = content.BottomSpot2ImageName__c + JPG_IMG;
            bottomSpot2UrlText = content.BottomSpot2UrlText__c ;
            bottomSpot2Url = content.BottomSpot2Url__c ;
            bottomSpot2TitleText = content.BottomSpot2Text__c ;
        }
    }
    
    
}