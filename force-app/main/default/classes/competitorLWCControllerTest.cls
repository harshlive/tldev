@isTest 
public class competitorLWCControllerTest {
    @isTest static void createRecordsTest() {
        Account acc = new Account(name = 'test Account');
        insert acc;
        product2 p =new product2(name='test');
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
        insert metricToInsert;
        competitorLWCController.getCompInfo(acc.Id,'2021');
    }
    @isTest static void updateMonthlyCompInfoTest() {
        Account acc = new Account(name = 'test Account');
        insert acc;
        product2 p =new product2(name='test');
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
        insert metricToInsert;
        competitorLWCController.updateMonthlyCompInfo(metricToInsert);
    }
    @isTest static void getMonthlyCompInfoTest() {
        Account acc = new Account(name = 'test Account');
        insert acc;
        product2 p =new product2(name='test');
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
        metricToInsert.Competitor__c = 'Abbott';
        insert metricToInsert;
        competitorLWCController.getMonthlyCompInfo(acc.id,'Abbott','2021',p.id);
        competitorLWCController.getMonthlyCompInfo(acc.id,'Abbott','2022',p.id);
    }
}