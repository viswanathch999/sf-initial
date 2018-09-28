public with sharing class DocusignServices {

    public String docusignEndpointUrl {get; private set;} 
    private static DocusignServices instance;
    // Determines if this is a test or live transaction.
    public Boolean isTestTransaction                                       
        {
            get; set {
                isTestTransaction = value;
            // Grab the appropriate CyberSource URL from Custom Settings
            //CustomSettingsModel csm = new CustomSettingsModel();
            if (isTestTransaction) {
                // Test transaction
              docusignEndpointUrl  = csm.Test_URL__c;
            }
            //else {
                // Live transaction
             // docusignEndpointUrl  = csm.docusignRecord.Docusign_Production_URL__c;
           // }
            // Make sure we got a value from Custom Settings.
            if (String.isBlank(docusignEndpointUrl)) {
          //    throw new CustomExceptions.ConfigurationException('Docusign Endpoint URL not found in custom settings');
            }
            }
        }
    
    // Custom settings holds call out urls.
    public DocusignCustomSetting__c csm
    {
        get
        {
            if (csm == null)
                csm = DocusignCustomSetting__c.getInstance('Docusign');

            return csm;
        }
        private set;
    }// end of coSettings method
    
   
    public static DocusignServices getInstance()
    {
        if (instance == null)
            instance = new DocusignServices();

        return instance;
    }//end method getInstance
    
    //Get Authenticaion Header, Used for all request
    public String AuthenticationHeader(){
        
        //Get Paramter from Custom Setting (sfdc cache) and construct auth header
      
        return '<DocuSignCredentials>'+
                    '<Username>'+csm.Username__c+'</Username>'+
                    '<Password>'+csm.Password__c+'</Password>'+
                    '<IntegratorKey>'+csm.IntegratorKey__c+'</IntegratorKey>'+
                '</DocuSignCredentials>';
    }
    
    
    ///////////////////// New Methods /////////////////////
    
    public SendResults sendEnvelope(envelopeDefinition ed) {
       
        SendResults sr = new SendResults();
    //    DocuSignCredentials li = new DocuSignCredentials();
        String authString = AuthenticationHeader();
        system.debug('ed values'+ed);
        string body = ed.generateJSONString();
        system.debug('**** Envelope Body: ' + ed.generateJSONString());
        HttpRequest req = new HttpRequest();
        //string baseUrl = WebServiceURLs__c.getInstance('DocuSign Base URL').Endpoint_Url__c + Configuration__c.getInstance('DocuSign Account Id').Value__c
        string baseUrl = 'https://demo.docusign.net/restapi/v2/accounts/' + csm.DocusignAccountID__c;
        req.setEndpoint(baseUrl + '/envelopes');
        
        //system.debug('**** BASE URL: ' + lr.baseUrl);
        req.setMethod('POST');
        req.setHeader('X-DocuSign-Authentication', authString);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Length', string.valueOf(body.length()));
        req.setBody(body);
        req.setTimeout(60000);
        system.debug('****X-DocuSign-Authentication: ' + req.getHeader('X-DocuSign-Authentication'));
        system.debug('****Content-Length: ' + req.getHeader('Content-Length'));
        //Http http = new Http();       
        try {
            HttpResponse res = sendRequest(req, ed);
            string envelopeId = GetTokenValueFromResponse(res, 'envelopeId');
            system.debug('envelope Id'+ envelopeId);
            if (string.isBlank(envelopeId)) {
                string errorCode = GetTokenValueFromResponse(res, 'errorCode');
                string errorMessage = GetTokenValueFromResponse(res, 'message');
                sr.isSuccess = false;
                sr.message = errorCode + ': ' + errorMessage;
            } else {
                sr.envelopeId = envelopeId;
                sr.isSuccess = true;
            }
            system.debug('****** response: ' + res);
        } catch (Exception ex) {
            sr.IsSuccess = false;
            sr.message = 'Unable to create and send: ' + ex.getMessage();
        }
         
        return sr;
    
    }
    
   //builds JSON Class
    public class envelopeDefinition extends DocuSignRequestObject {
        public string accountId;
        public string status;
        public string emailSubject;
        public string emailBlurb;
        public string autoNavigation = 'false';
        public customField customFields = new customField();
        public string templateId;
        public List<templateRole> templateRoles = new List<templateRole>();        
    }
    
    public class customField {
        public List<textCustomField> textCustomFields = new List<textCustomField>();
    }
    
       public class textCustomField {
        public string name;
        public string show = 'true';
        public string required = 'false';
        public string value;
    }
    
    //templateRole Class for JSON
    public class templateRole {
        public string email;
        public string name;
        public string roleName;
        public tab tabs = new tab();
    }
    
    public class tab {
        public List<texttab> texttabs = new List<texttab>();
    }
    
    public class textTab {
        public string tabLabel;
        public string Name;
        public string value;
    }
    
    
    
    
    //Sends request
    private static HttpResponse sendRequest(HttpRequest req, envelopeDefinition ed) {
        HttpResponse res;
        
        if (!Test.isRunningTest()) {
            Http http = new Http();
            res = http.send(req);
        } else {
            //TODo
            system.debug('entered test req '+ req);
            system.debug('ed values '+ ed);
         //   res = TestDocuSignServices.createResponse(req, ed);
            res = null;
        }
        
        return res;
    }
    
    //gets envelopeId
    public static string GetTokenValueFromResponse(HTTPResponse res, string tokenName) {
        tokenName = tokenName.toLowerCase();
        system.debug('response body'+res.getBody());
        JSONParser parser = JSON.CreateParser(res.getBody());
        system.debug('parser values'+ parser);
        System.JSONToken currentToken = parser.nextToken();
        system.debug('current token'+ currentToken);
        while (currentToken != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText().toLowerCase() == tokenName)) {
                parser.nextToken();
                system.debug('parser get text'+ parser.getText());
                return parser.getText();
                
            }
            currentToken = parser.nextToken();
            system.debug('currentToken parser'+ currentToken);
        }
        return null;
    }
    
    //this extends abstract class Result.
    public class SendResults extends Result{
        public string envelopeId;
    }
    
    //Abstract class holds two properties
    abstract class Result {
        public boolean isSuccess;
        public string message;
    }
    
    //declared as abstract class , so that class can call this JSON Request.
    abstract class DocuSignRequestObject {
        public virtual string generateJSONstring() {
            system.debug('*** JSON: ' + JSON.serializePretty(this));
            return JSON.serialize(this);
        } 
    }     
    
    //Creates Json,  Business Owner emails are passed .
    public  envelopeDefinition createEnvelope(List<Opportunity> oppRecords){
        envelopeDefinition ed = new envelopeDefinition();
        ed.accountId = csm.DocusignAccountID__c;
        ed.status = 'Sent';
        ed.emailSubject = 'Please review the included document';
        ed.emailBlurb = 'Please Sign ASAP!';
        ed.templateId = csm.TemplateId__c;
        TemplateRole role = new TemplateRole();
        
        customField customFields = new customField();
        textCustomField tc = new textCustomField();
        
        for(Opportunity o: oppRecords){
            role.email = o.Third_Party_Email__c;
            role.Name = o.Third_Party_Name__c;
            role.roleName = 'Signer';
            
            texttab tb = new texttab();
            tb.tabLabel = 'Title';
            tb.Name	=	'Title';
            tb.Value = o.Qualifying_Company__c;
            
            texttab tb1 = new texttab();
            tb1.tabLabel = 'Company';
            tb1.Name	=	'Company';
            tb1.Value = o.Qualifying_Company__c;
            
            tc.name = '##SFOpportunity';
         	tc.value = o.Id;
            
            ed.templateRoles.add(role);
            ed.templateRoles[0].tabs.textTabs.add(tb);
            ed.templateRoles[0].tabs.textTabs.add(tb1);
            ed.customFields.textCustomFields.add(tc);
        }
        
        return ed;
    }
    
}