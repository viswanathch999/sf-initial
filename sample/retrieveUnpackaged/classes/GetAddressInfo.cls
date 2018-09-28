public class GetAddressInfo {

    //public AddressInfo customAddress = new AddressInfo();

    public void getAddressInfo(Id recordId, String sObjectName, AddressInfo customAddress) {
        sendUrlEndpoint(RecordId, getUrlEndpoint(customAddress), sObjectName);
    }

    private string getUrlEndpoint(AddressInfo customAddress) {
        String urlString = 'https://maps.googleapis.com/maps/api/geocode/json?address=' + EncodingUtil.urlEncode(customAddress.Street, 'UTF-8') + ',' + EncodingUtil.urlEncode(customAddress.City, 'UTF-8') + ',' + EncodingUtil.urlEncode(customAddress.State, 'UTF-8') + '&key=AIzaSyAxqmI-HJKfzQ6VHBqJq59bSQv9sm2Wipc';

        return urlString;

    }

    @future(callout = true)
    private static void sendUrlEndpoint(Id recordId, String urlString, String sObjectName) {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        req.setEndpoint(urlString);
        req.setMethod('GET');

        Http http = new http();
		
        if(!test.isRunningTest()){
        	res = http.send(req);            
        }

        Map<String, Schema.SObjectType> mapAllSobjects = Schema.getGlobalDescribe();

        Schema.SobjectType oType;

        oType = mapAllSobjects.get(sObjectName);

        SObject genericSObj = oType.newSObject();

        genericSObj.put('Id', recordId);

        JSONParser parser = JSON.createParser(res.getBody());

        Map<String, String> JSONMap = new Map<String, String> ();
        String Field_Name;
        String Value_String;
        String Street;

        while (parser.nextToken() != NULL) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != NULL) {
                    if (String.valueOf(parser.getCurrentToken()) == 'VALUE_STRING' && parser.getCurrentName() == 'short_name') {
                        Value_String = parser.getText();
                    } else if (String.valueOf(parser.getCurrentToken()) == 'VALUE_STRING' && parser.getCurrentName() == null && parser.getText() != 'political') {
                        Field_Name = parser.getText();
                    } else if (String.valueOf(parser.getCurrentToken()) == 'START_OBJECT' && parser.getCurrentName() == 'location') {
                        parser.nextValue();
                        JSONMap.put(parser.getCurrentName(), parser.getText());
                        parser.nextValue();
                        JSONMap.put(parser.getCurrentName(), parser.getText());
                    } else if (String.valueOf(parser.getCurrentToken()) == 'VALUE_STRING' && parser.getCurrentName() == null) {
                        Field_Name = 'type';
                        Value_String = parser.getText();
                    } else if (String.valueOf(parser.getCurrentToken()) == 'FIELD_NAME' && parser.getCurrentName() == 'status') {
                        parser.nextValue();
                        Field_Name = parser.getCurrentName();
                        Value_String = parser.getText();
                    }

                    if (Value_String != null && Field_Name != null) {
                        JSONMap.put(Field_Name, Value_String);
                        Value_String = null;
                        Field_Name = null;
                    }
                }
            }
        }
        for(String s : JSONMap.keySet()){
            System.debug(s + ' ' + JSONMap.get(s));
        }
        genericSObj.put('Street__c', JSONMap.get('street_number') + ' ' + JSONMap.get('route'));
        //genericSObj.put('County__c', JSONMap.get('administrative_area_level_2'));
        genericSObj.put('City__c', JSONMap.get('locality'));
        genericSObj.put('Postal_Code__c', JSONMap.get('postal_code'));
        genericSObj.put('Country_Code__c', JSONMap.get('country'));
        genericSObj.put('State_Code__c', JSONMap.get('administrative_area_level_1'));
        if(JSONMap.containsKey('lat') && JSONMap.containsKey('lng')){
            if(Decimal.valueOf(JSONMap.get('lat')) != NULL && Decimal.valueOf(JSONMap.get('lng')) != NULL){
                genericSObj.put('Coordinates__Latitude__s', Decimal.valueOf(JSONMap.get('lat')));
                genericSObj.put('Coordinates__Longitude__s', Decimal.valueOf(JSONMap.get('lng')));
            }            
        }
        genericSObj.put('Address_Status__c', JSONMap.get('status'));

        try {
            update genericSObj;
        } catch(DmlException e) {
            System.debug(e);
        }

    }

    public class AddressInfo {
        public String Street;
        public String County;
        public String City;
        public String PostalCode;
        public String Country;
        public String State;
        public Location Coordinates;
        public String Types;
        public String Status;

        public AddressInfo(String Street, String County, String City, String PostalCode, String Country, String State, Location Coordinates, String Types, String Status) {
            this.Street = Street;
            this.County = County;
            this.City = City;
            this.PostalCode = PostalCode;
            this.Country = Country;
            this.State = State;
            this.Coordinates = Coordinates;
            this.Types = Types;
            this.Status = Status;
        }
    }
}