public class ExceptionTriggerServices {
    public final static String CONST_CHAP_CHAIR = 'Chapter Chair';
    public final static String CONST_CHAP_MEM_OFF = 'Chapter Membership Officer';
    public final static String CONST_CHAP_ADMIN = 'Chapter Administrator';
    public static void updateUserLokups(List<Exception__c> newExceptions, Map<Id, Exception__c> oldExceptions){
        Set<Id> accountIds = new Set<Id>();
        for(Exception__c anEx: newExceptions){
            if(oldExceptions.isEmpty() || anEx.account__c != oldExceptions.get(anEx.Id).account__c)
                accountIds.add(anEx.account__c);
        }
        if(!accountIds.isEmpty()){
            Map<Id, List<CA_Setting__c>> chapterIdToCASettings = new Map<Id, List<CA_Setting__c>>();
            for(CA_Setting__c cas: [Select Id, Role__c, User__c, Chapter__c from CA_Setting__c where Chapter__c in :accountIds and Primary__c = true and isActive__c = true]){
                if(!chapterIdToCASettings.containsKey(cas.Chapter__c))
                    chapterIdToCASettings.put(cas.Chapter__c, new List<CA_Setting__c>());
                chapterIdToCASettings.get(cas.Chapter__c).add(cas);
            }
            for(Exception__c anEx: newExceptions){
                if(anEx.account__c != null && chapterIdToCASettings !=null && chapterIdToCASettings.containsKey(anEx.account__c)){
                    for(CA_Setting__c relatedCas: chapterIdToCASettings.get(anEx.account__c)){
                        Id adminId = relatedCas.user__c;
                        String aRole = relatedCas.role__c;
                        if(aRole.equalsIgnoreCase(CONST_CHAP_MEM_OFF))
                            anEx.Chapter_Membership_Officer__c = adminId;
                        else if(aRole.equalsIgnoreCase(CONST_CHAP_CHAIR))
                            anEx.Chpter_Chair__c = adminId;
                        else if(aRole.equalsIgnoreCase(CONST_CHAP_ADMIN))
                            anEx.Chapter_Administrator__c  = adminId;
                    }
                }
            }
        }
    }
}