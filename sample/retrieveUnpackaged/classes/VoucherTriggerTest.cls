@isTest
public with sharing class VoucherTriggerTest {
    
    public static testmethod void testVoucherGuidGeneration(){
    	
    	Account tAcct = TestServices.createAccount('tstAccount');
    	insert tAcct;
    	
    	Contact tCont = TestServices.createContact(tAcct.Id);
    	insert tCont;
    	
	    Test.startTest();
	    	insert new Voucher__c(Contact__c = tCont.Id);
	    Test.stopTest();
	    
	    Voucher__c expectedV = [Select Id, Guid__c From Voucher__c LIMIT 1];
	    
	    System.assertNotEquals(null, expectedV.Guid__c, ' We expect the guid to be populated in the trigger ');
    	
    }

    public static testmethod void testVoucherGuidGeneration_Update(){
    	
    	Account tAcct = TestServices.createAccount('tstAccount');
    	insert tAcct;
    	
    	Contact tCont = TestServices.createContact(tAcct.Id);
    	insert tCont;
    	
    	Voucher__c tVouch= new Voucher__c(Contact__c = tCont.Id);
	    insert tVouch;
	    	 
	    Test.startTest();
	    	tVouch.Guid__c = '';
	    	update tVouch;
	    Test.stopTest();
	    
	    Voucher__c expectedV = [Select Id, Guid__c From Voucher__c Where Id = :tVouch.Id];
	    
	    System.assertNotEquals(null, expectedV.Guid__c, ' We expect the guid to be populated in the trigger ');
    	
    }
}