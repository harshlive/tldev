@isTest 
private class TargetManagementControllerTest {	
    @isTest static void fetchMetricsTest() {
        Account acc = new Account(name = 'test Account');
        insert acc;
        product2 p1 =new product2(name='test1');
        insert p1;
        product2 p2 =new product2(name='test2');
        insert p2;
        TargetManagementController.fetchMetrics( acc.id ,'2021' ,'(\''+p1.id+'\',' + '\''+p2.id+'\')' ); 
    }
    @isTest static void saveMetricRecordTest() {
        Account acc = new Account(name = 'test Account');
        insert acc;
        product2 p =new product2(name='test1');
        insert p;
        Metric__c metricToInsert = new Metric__c();
        metricToInsert.Name = 'test';
        metricToInsert.Account__c = acc.id;
        metricToInsert.Fiscal_Year__c = '2021';
        metricToInsert.Product__c = p.Id;
        metricToInsert.Metric_Type__c = 'Competitor Actuals (Current FY)';
        metricToInsert.JAN__c = 0;
        metricToInsert.FEB__c = 0;
        metricToInsert.MAR__c = 0;
        metricToInsert.APR__c = 0;
        metricToInsert.MAY__c = 0;
        metricToInsert.JUN__c = 0;
        metricToInsert.JUL__c = 0;
        metricToInsert.AUG__c = 0;
        metricToInsert.SEP__c = 0;
        metricToInsert.OCT__c = 0;
        metricToInsert.NOV__c = 0;
        metricToInsert.DEC__c = 0;
        List<Metric__c> mLst = new List<Metric__c>();
        mLst.add(metricToInsert);
        TargetManagementController.saveMetricRecord(mLst);
    }

}