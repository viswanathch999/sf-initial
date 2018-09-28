public class BusinessAddress {
    
    private getAddressInfo.AddressInfo customAddress;
    private getAddressInfo addressClass = new GetAddressInfo();
    
	public void getAddress(List<Account_Affiliation__c> newUpdates, Map<Id, Account_Affiliation__c> oldUpdates, Boolean isInsert) {

		List<Account_Affiliation__c> updateAA = new List<Account_Affiliation__c> ();
		

		for (Account_Affiliation__c aa : newUpdates) {
			if (aa.Street__c != NULL && aa.City__c != NULL && aa.State_Code__c != NULL) {
				if (isInsert) {
					//addressInfo.customAddress.Street = aa.Street__c;
					//addressInfo.customAddress.City = aa.City__c;
					//addressInfo.customAddress.State = aa.State_Code__c;
					//addressInfo.getAddressInfo(aa.Id, 'Account_Affiliation__c');
				} else if (aa.Street__c != oldUpdates.get(aa.id).Street__c || aa.City__c != oldUpdates.get(aa.id).City__c || aa.State_Code__c != oldUpdates.get(aa.id).State_Code__c) {
                    //String Street, String County, String City, String PostalCode, String Country, String State, Location Coordinates, String Types, String Status
                    customAddress = new getAddressInfo.AddressInfo(aa.Street__c, null, aa.City__c, null, null, aa.State_Code__c, null, null, null);
					addressClass.getAddressInfo(aa.Id, 'Account_Affiliation__c', customAddress);
				} 
			}
		}
	}
}