/*
* Credit: http://mysalesforceescapade.blogspot.com/2015/03/getting-dependent-picklist-values-from.html
			https://www.dropbox.com/s/4gi7m38sr4blqqo/GetDependentOptions.txt //Code improvement
* Objective: fetch dependent picklist values based on the controlling field value.
*/

@isTest
public class PicklistFieldControllerTest {    
    static testMethod void getDependentOptionsImplTest(){
        PicklistFieldController controller = new PicklistFieldController();
        Map<String,Map<String,String>> valueMap = controller.GetDependentOptions('Account','BillingCountryCode','BillingStateCode');
        for(String contr : valueMap.keySet()){
            System.debug('CONTROLLING FIELD : ' + contr);
            System.debug('DEPENDENT VALUES ...  : ' + valueMap.get(contr).keySet());
        }
    }

}