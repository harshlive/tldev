public class OutcomeTriggerHelper {
    public static void updateDatesBasedOnStatus(List<Outcome__c> outcomeLst,Map<Id,Outcome__c> oldMap) {
        for(Outcome__c m:outcomeLst) {
            system.debug(m.Status__c );
            system.debug(oldMap.get(m.Id).Status__c );
            if(m.Status__c != oldMap.get(m.Id).Status__c) {
                if(m.Status__c == 'Complete') {
                    m.Completion_Date__c = system.today();
                }
            }
        }
    }
}