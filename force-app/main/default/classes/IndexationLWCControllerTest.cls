@isTest
public class IndexationLWCControllerTest {
    @isTest static void getIndicesTest() {
        Account acc = new Account(name = 'test Account',billingstate='Jharkhand',Stents_Per_Month_Potential__c=200);
        insert acc;
        product2 p = new product2(name='test');
        insert p;
        Metric__c metricToInsert = new Metric__c();
        metricToInsert.Name = 'test';
        metricToInsert.Account__c = acc.id;
        metricToInsert.Fiscal_Year__c = '2021';
        metricToInsert.Product__c = p.Id;
        metricToInsert.Metric_Type__c =  'Target (Current FY)';
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
        Index_Factor__c ifrec = new Index_Factor__c(state__c='Jharkhand',Fiscal_Year__c='2021',Q1_Index__c=10,
                                                 Q2_Index__c=10,Q3_Index__c=10,Q4_Index__c=10);
        insert ifrec;
        IndexationLWCController.getIndices('Jharkhand','2021');
        IndexationLWCController.getIndices('Jharkhand','2022');
    }
    @isTest static void saveIndexTest() {
        Account acc = new Account(name = 'test Account',billingstate='Jharkhand',Stents_Per_Month_Potential__c=200);
        insert acc;
        product2 p = new product2(name='test');
        insert p;
        Metric__c metricToInsert = new Metric__c();
        metricToInsert.Name = 'test';
        metricToInsert.Account__c = acc.id;
        metricToInsert.Fiscal_Year__c = '2021';
        metricToInsert.Product__c = p.Id;
        metricToInsert.Metric_Type__c =  'Target (Current FY)';
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
        index_factor__c index = new Index_Factor__c(state__c='Jharkhand',Fiscal_Year__c='2021',Q1_Index__c=10,
                                                 Q2_Index__c=10,Q3_Index__c=10,Q4_Index__c=10);
        insert index;
        index.Q1_Index__c = 20;
        index.Q2_Index__c = 20;
        index.Q3_Index__c = 20;
        index.Q4_Index__c = 20;
        IndexationLWCController.saveIndex(index);
    }
}