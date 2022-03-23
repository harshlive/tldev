@isTest 
private class TaskTriggerHandlerTest {
	
    @isTest static void onBeforeInsertTest() {
        
        Profile p=[SELECT Id From Profile WHERE Name='Standard User'];
        User u2 =new User( Alias = 'NU1' , Email ='nu1@to.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_IN', UserName='nu1@tto.com', 
                          ProfileId=p.Id, TimeZoneSidKey    = 'America/Los_Angeles');
        insert u2;
        
        Account acc=new Account();
        acc.Name='Test';
        insert acc;
        Contact con=new Contact();
        con.LastName='con';
        con.AccountId=acc.Id;
        con.MobilePhone='9856545874';
        con.Email='con@gmail.com';
        insert con;
        Milestone__c milestone0=new Milestone__c();
        milestone0.Name='Test1';
        milestone0.Account__c=acc.Id;
        insert milestone0;
        Outcome__c ott=new Outcome__c();
        ott.Milestone__c=milestone0.Id;
        ott.Status__c='Not Started';
         ott.Account__c=acc.Id;
        ott.Due_Date__c=Date.newInstance(2020,10,16);
        ott.Description__c='Test';
        insert ott; 
        Milestone_Master__c mm=new Milestone_Master__c(Name='TestM');
        insert mm;
         
        Task tt=new Task();
        tt.Account__c=acc.Id;
        tt.Contact__c=con.Id; 
        tt.Subject='Phone Call';
        tt.Support__c=u2.Id;
        tt.Outcome__c=ott.Id; 
        
        Task tt1=new Task();  
        tt1.Subject='call';
        tt1.Outcome__c=ott.Id; 
        
        Task tt2=new Task();  
        tt2.Account__c=acc.Id;
        tt2.Subject='call';
        tt2.Outcome__c=ott.Id; 
        
        Task tt3=new Task();  
        tt3.WhatId=acc.Id;
        tt3.Subject='call';
        tt3.Outcome__c=ott.Id; 
         Task tt4=new Task();  
        tt4.WhatId=acc.Id;
        tt4.WhoId=con.Id;        
        tt4.Subject='call';
        tt4.Outcome__c=ott.Id; 
        
        List<Task> taskList=new List<Task>();
        taskList.add(tt);
        taskList.add(tt1);
        taskList.add(tt2);        
        taskList.add(tt3);
        taskList.add(tt4);
        TaskTriggerHandler.onBeforeInsert(taskList);
        System.assertEquals(acc.Id, tt.Account__c);
        
        
             
    }
    @isTest static void onAfterUpdateTest() {
        
        Profile p=[SELECT Id From Profile WHERE Name='Standard User'];
        User u2 =new User( Alias = 'NU1' , Email ='nu1@to.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_IN', UserName='nu1@tto.com', 
                          ProfileId=p.Id, TimeZoneSidKey    = 'America/Los_Angeles');
        insert u2;
        
        Account acc=new Account();
        acc.Name='Test';
        insert acc;
        Contact con=new Contact();
        con.LastName='con';
        con.AccountId=acc.Id;
        con.Email='con@gmail.com';
        con.MobilePhone='9856545874';
        insert con;
        Milestone__c milestone0=new Milestone__c();
        milestone0.Name='Test1';
        milestone0.Account__c=acc.Id;
        insert milestone0;
        Outcome__c ott=new Outcome__c();
        ott.Milestone__c=milestone0.Id;
        ott.Account__c=acc.Id;
        ott.Status__c='Not Started';
        ott.Due_Date__c=Date.newInstance(2020,10,16);
        ott.Description__c='Test';
        insert ott; 
        Milestone_Master__c mm=new Milestone_Master__c(Name='TestM');
        insert mm;
          
        Task tt=new Task();
        tt.Account__c=acc.Id;
        tt.Contact__c=con.Id; 
        tt.Subject='call';
        tt.Task_Type__c = 'In Field';
        
        tt.Category__c='Phone Call';
        tt.Outcome__c=ott.Id;
        insert tt;
        
        map<Id,Task> oldMap=new map<Id,Task>();
        oldMap.put(tt.Id,tt);
        
        tt.Task_Type__c = 'In Field';
        tt.Category__c='Email';
        update tt;
        map<Id,Task> newMap=new map<Id,Task>();
        newMap.put(tt.Id,tt);
        
        List<Task> taskList=new List<Task>();
        taskList.add(tt);
        TaskTriggerHandler.onAfterUpdate(taskList, oldMap, newMap);
        System.assertEquals('Email', taskList[0].Category__c );
        
        Account acc1=new account();
        acc1.Name='t1';
        insert acc1;
        tt.Contact__c=null;
        tt.Account__c=acc1.Id;
        tt.Support__c=u2.Id;
        
        update tt;
        map<Id,Task> newMap1=new map<Id,Task>();
        newMap1.put(tt.Id,tt);
        TaskTriggerHandler.onAfterUpdate(taskList, oldMap, newMap1);
        
         
        tt.Contact__c=null;
        tt.Account__c=null;        
        update tt;
        map<Id,Task> newMap2=new map<Id,Task>();
        newMap1.put(tt.Id,tt);
        TaskTriggerHandler.onAfterUpdate(taskList, oldMap, newMap2);
        
 
    }
    @isTest static void onBeforeDeleteTest(){
         Profile p=[SELECT Id From Profile WHERE Name='Standard User'];
        User u2 =new User( Alias = 'NU1' , Email ='nu1@to.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_IN', UserName='nu1@tto.com', 
                          ProfileId=p.Id, TimeZoneSidKey    = 'America/Los_Angeles');
        insert u2;
        
        Task tt=new Task();
        tt.Subject='meeting';
        tt.OwnerId=u2.Id;
        insert tt;
        List<Task> ttList=new List<Task>();
        ttList.add(tt);
        TaskTriggerHandler.onBeforeDelete(ttList);
        
    }
}