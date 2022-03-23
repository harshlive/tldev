public class MetricTriggerHelper {

    public static void metricOwnerPopulate(List<Metric__c> newList){
        set<Id> idList=new set<Id>();
        for(Metric__c mm:newList){
            if(mm.User__c!=null){
                idList.add(mm.Id);
            }
        } 
        List<Metric__c> newUpdateList=[select Id,Name,User__c,OwnerId,User__r.Name from Metric__c where Id in :idList]; 
        for(Metric__c mm:newUpdateList){ 
            System.debug('set owner:'+mm.user__r.Name);
                mm.OwnerId=mm.User__c; 
        }
        if(!newUpdateList.isEmpty()){
            update newUpdateList;
        } 
    } 
}