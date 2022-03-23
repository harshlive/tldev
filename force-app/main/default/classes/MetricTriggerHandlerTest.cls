@isTest 
private class MetricTriggerHandlerTest {
    
    @isTest static void onAfterInsertTest() {
        
        Product2 pd1=new Product2();
        pd1.Name='Pd1';
        pd1.Family='STENT';
        //pd1.Category__c='Premium Stent';
        insert pd1;
        Product2 pd2=new Product2();
        pd2.Name='Pd2';
        pd2.Family='STENT';
        //pd2.Category__c='Non-Premium Stent';
        insert pd2;
        Product2 pd3=new Product2();
        pd3.Name='Pd3';
        pd3.Family='OTHERS';
        pd3.Category__c='IVL';
        insert pd3;
        Product2 pd4=new Product2();
        pd4.Name='Pd4';
        pd4.Family='OTHERS';
        pd4.Category__c='VA';
        insert pd4;
        Product2 pd5=new Product2();
        pd5.Name='Pd5';
        pd5.Family='OTHERS';
        //pd5.Category__c='BALLOONS';
        insert pd5;
        Product2 pd6=new Product2();
        pd6.Name='Pd6';
        pd6.Family='OTHERS';
        //pd6.Category__c='OPN';
        insert pd6;
        Product2 pd7=new Product2();
        pd7.Name='Pd7';
        pd7.Family='OTHERS';
        //pd7.Category__c='Nic Nano';
        insert pd7;
        
        Account acc=new Account();
        acc.Name='Test';
        acc.Status__c='Active';
        insert acc;
        
        Metric__c metricListobj0 = new Metric__c (  );
        metricListobj0.Name='Test 1';
        metricListobj0.Metric_Type__c='Target (Current FY)';
        metricListobj0.Account__c=acc.Id;
        metricListobj0.Product__c=pd1.Id;
        metricListobj0.JAN__c=20;
        metricListobj0.Last_SAP_Updated__c=Date.newInstance(2020, 05,30);
        Insert metricListobj0;
        
        Metric__c metricListobj1 = new Metric__c (  );
        metricListobj1.Name='Test 2';
        metricListobj1.APR__c=10;  
        metricListobj1.Product__c=pd2.Id;
        metricListobj1.Metric_Type__c='Actuals-Primary (Current FY)';
        metricListobj1.Account__c=acc.Id;
        metricListobj1.Last_SAP_Updated__c=Date.newInstance(2020, 03,30);
        Insert metricListobj1;
        
        Metric__c metricListobj2 = new Metric__c (  );
        metricListobj2.Name='Test 3';
        metricListobj2.JUL__c=10;
        metricListobj2.Product__c=pd3.Id;
        metricListobj2.Metric_Type__c='Actuals-Primary (Current FY)';
        metricListobj2.Account__c=acc.Id;
        metricListobj2.Last_SAP_Updated__c=Date.newInstance(2020, 04,01);
        Insert metricListobj2;
        
        Metric__c metricListobj4 = new Metric__c (  );
        metricListobj4.Name='Test 4';
        metricListobj4.JUL__c=10;
        metricListobj4.Product__c=pd4.Id; 
        metricListobj4.Account__c=acc.Id; 
        Insert metricListobj4;
        
        Metric__c metricListobj5 = new Metric__c (  );
        metricListobj5.Name='Test 5';
        metricListobj5.JUL__c=10;
        metricListobj5.Product__c=pd5.Id; 
        metricListobj5.Account__c=acc.Id; 
        Insert metricListobj5;
        
        Metric__c metricListobj6 = new Metric__c (  );
        metricListobj6.Name='Test 6';
        metricListobj6.JUL__c=10;
        metricListobj6.Product__c=pd6.Id; 
        metricListobj6.Account__c=acc.Id; 
        Insert metricListobj6;
        
        Metric__c metricListobj7 = new Metric__c (  );
        metricListobj7.Name='Test 7';
        metricListobj7.JUL__c=10;
        metricListobj7.Product__c=pd7.Id; 
        metricListobj7.Account__c=acc.Id; 
        Insert metricListobj7;
        
          
        List<Metric__c> metricList = new List<Metric__c> ();
        metricList.add(metricListobj0);
        metricList.add(metricListobj1);
        metricList.add(metricListobj2);
        metricList.add(metricListobj4);
        metricList.add(metricListobj5);
        metricList.add(metricListobj6);
        metricList.add(metricListobj7);
        
        MetricTriggerHandler.onAfterInsert(metricList);
        System.assertEquals('Test 1', metricListobj0.Name);
    }
    
    @isTest static void onAfterUpdateTest() {	
        
        
        Account acc=new Account();
        acc.Name='Test';
        acc.Status__c='Inactive';
        insert acc;
        
        Metric__c metricListobj0 = new Metric__c (  );
        metricListobj0.Name='Test 1';
        metricListobj0.Metric_Type__c='Target (Current FY)';
        metricListobj0.Account__c=acc.Id;
        metricListobj0.JAN__c=10;
        metricListobj0.Last_SAP_Updated__c=Date.newInstance(2020, 05,30);
        Insert metricListobj0;
        
        Metric__c metricListobj1 = new Metric__c (  );
        metricListobj1.Name='Test 2';
        metricListobj1.Metric_Type__c='Actuals-Primary (Current FY)';
        metricListobj1.Account__c=acc.Id;
        metricListobj0.Last_SAP_Updated__c=Date.newInstance(2020, 03,30);
        Insert metricListobj1;
        
        Metric__c metricListobj2 = new Metric__c (  );
        metricListobj2.Name='Test 3';
        metricListobj2.Metric_Type__c='Actuals-Primary (Current FY)';
        metricListobj2.Account__c=acc.Id;
        metricListobj0.Last_SAP_Updated__c=Date.newInstance(2020, 04,01);
        Insert metricListobj2;
        
        map<Id,Metric__c> oldMap = new map<Id,Metric__c> (  );
        oldMap.put(metricListobj0.Id,metricListobj0);
        oldMap.put(metricListobj1.Id,metricListobj1);
        oldMap.put(metricListobj2.Id,metricListobj2);
        
        metricListobj2.Last_SAP_Updated__c=Date.newInstance(2020, 06,01);
        metricListobj2.FEB__c=20;
        metricListobj0.DEC__c=10;
        update metricListobj2;
        List<Metric__c> metricList = new List<Metric__c> ();
        metricList.add(metricListobj0);
        metricList.add(metricListobj1);
        metricList.add(metricListobj2);
        
        
        MetricTriggerHandler.onAfterUpdate(  metricList, oldMap);
        System.assertEquals(Date.newInstance(2020, 06,01) , metricListobj2.Last_SAP_Updated__c);
    }
    
    
}