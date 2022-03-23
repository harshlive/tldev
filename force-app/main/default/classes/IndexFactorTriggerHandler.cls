public class IndexFactorTriggerHandler {
    public static void afterTrigger(List<Index_Factor__c> indexList,Map<Id,Index_Factor__c> oldIndexMap) {
        IndexFactorTriggerHelper.updateTargets(indexList,oldIndexMap);
    }
}