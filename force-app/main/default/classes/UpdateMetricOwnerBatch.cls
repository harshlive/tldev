public class UpdateMetricOwnerBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'SELECT id,user__c,ownerid FROM Metric__c';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Metric__c> MetricsLst){
        for(Metric__c m:MetricsLst) {
            if(string.isNotBlank(m.User__c))
            m.OwnerId = m.User__c;
        }
        update MetricsLst;
    }
    
    public void finish(Database.BatchableContext BC){
    }
}