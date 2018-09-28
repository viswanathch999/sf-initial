// Set to Active=false on Jan 24 2017

trigger setCartToken on Opportunity (after insert) {
   /* if (!KGServiceClass.hasEncryptedOptyId){
        KGServiceClass.encryptOptyId(trigger.new);
    }*/
}