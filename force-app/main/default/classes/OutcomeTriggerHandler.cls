public class OutcomeTriggerHandler {
    public static void beforeUpdate(List<Outcome__c> outcomeLst,Map<Id,Outcome__c> oldMap) {
        OutcomeTriggerHelper.updateDatesBasedOnStatus(outcomeLst,oldMap);
    }
}