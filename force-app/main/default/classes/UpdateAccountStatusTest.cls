@isTest
public class UpdateAccountStatusTest {

    @isTest static void accountTest() {
        Account acc=new Account();
        acc.Name='Test 1';
        acc.Status__c='Active';
        insert acc;
        
        Account acc1=new Account();
        acc1.Name='Test 2';
        acc1.Status__c='Active';
        insert acc1;
        
        Metric__c m1=new Metric__c();
        m1.Account__c=acc1.Id;
        m1.Name='Test 1';
        m1.Metric_Type__c='Actuals-Primary (Current FY)';
        m1.Last_SAP_Updated__c=Date.newInstance(2020, 08, 01);
        insert m1;
        System.debug('Days: ' +(system.today()).daysBetween(Date.valueOf(m1.Last_SAP_Updated__c)));
        
        
        Account acc2=new Account();
        acc2.Name='Test 3';
        acc2.Status__c='Active';
        insert acc2;
        
        Metric__c m2=new Metric__c();
        m2.Account__c=acc2.Id;
        m2.Name='Test 4';
        m2.Metric_Type__c='Actuals-Primary (Current FY)';
        m2.Last_SAP_Updated__c=Date.newInstance(2020, 01, 01);
        insert m2;
        
        System.debug('Days: ' +(system.today()).daysBetween(Date.valueOf(m2.Last_SAP_Updated__c)));
 
        Test.startTest();        
        
        UpdateAccountStatus u1=new UpdateAccountStatus();
        DataBase.executeBatch(u1); 
        System.assertEquals('Active',acc.Status__c);
        
        Test.stopTest();
        
    }
}