@isTest
public class UpdateMetricOwnerBatchTest {
    static testmethod void testSuccess() {
        Metric__c m = new Metric__c();
        m.User__c= userinfo.getUserId();
        insert m;
        Test.startTest();
        UpdateMetricOwnerBatch c = new UpdateMetricOwnerBatch();
        Database.executeBatch(c);
        Test.stopTest();
    }
}