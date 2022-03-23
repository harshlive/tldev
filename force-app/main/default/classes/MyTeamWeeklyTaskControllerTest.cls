@isTest
public class MyTeamWeeklyTaskControllerTest {
    @isTest static void setPriorityTest(){
        Task tt1=new Task(); 
        tt1.Subject='call'; 
        insert tt1;
        List<Task> tskList=new List<Task>();
        tskList.add(tt1);
        MyTeamWeeklyTaskController.setPriority(tskList);
    }
    @isTest static void taskWeeklyRejectTest(){
        String uu=System.UserInfo.getUserId();
         Profile p=[SELECT Id From Profile WHERE Name='Standard User'];
        User u2 =new User( Alias = 'NU1' , Email ='nu1@to.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', UserName='nu1@tto.com', ManagerId=uu,
                          ProfileId=p.Id, TimeZoneSidKey    = 'America/Los_Angeles');
        insert u2; 
        Account acc=new Account();
        acc.Name='Test';
        insert acc;
        Milestone__c milestone0=new Milestone__c();
        milestone0.Name='Test1';
        milestone0.Account__c=acc.Id;
        insert milestone0;
        Outcome__c ott=new Outcome__c();
        ott.Milestone__c=milestone0.Id;
        ott.Status__c='Not Started';
        ott.Due_Date__c=Date.newInstance(2020,10,16);
        ott.Description__c='Test';
        insert ott; 
        Milestone_Master__c mm=new Milestone_Master__c(Name='Test Master');
        insert mm;
        
        Task tt1=new Task();
 
        tt1.Subject='call';
        tt1.Outcome__c=ott.Id;
        tt1.OwnerId=u2.Id;
        insert tt1;
        Task tt2=new Task(); 
        tt2.Subject='call2';
        tt2.Outcome__c=ott.Id;
        tt2.OwnerId=u2.Id;
        insert tt2;
        tt1.Subject='call Test12';  
        tt2.Subject='call Test2';
        List<Task> taskList=new List<Task>();
        taskList.add(tt1);
        taskList.add(tt2);
        try{
            
            MyTeamWeeklyTaskController.taskWeeklyReject(taskList);
            MyTeamWeeklyTaskController.taskWeeklyReject(null);
        }catch(Exception e){
            System.debug('error');
        }
    }
    @isTest static void taskWeeklyApproveTest(){
        Account acc=new Account();
        acc.Name='Test';
        insert acc;
        Milestone__c milestone0=new Milestone__c();
        milestone0.Name='Test1';
        milestone0.Account__c=acc.Id;
        insert milestone0;
        Outcome__c ott=new Outcome__c();
        ott.Milestone__c=milestone0.Id;
        ott.Status__c='Not Started';
        ott.Due_Date__c=Date.newInstance(2020,10,16);
        ott.Description__c='Test';
        insert ott; 
        Milestone_Master__c mm=new Milestone_Master__c(Name='Test Master');
        insert mm;
        
        Task tt1=new Task();
 
        tt1.Subject='call';
        tt1.Outcome__c=ott.Id;
        insert tt1;
        Task tt2=new Task(); 
        tt2.Subject='call2';
        tt2.Outcome__c=ott.Id;
        insert tt2;
        tt1.Subject='call Test12';  
        tt2.Subject='call Test2';
        List<Task> taskList=new List<Task>();
        taskList.add(tt1);
        taskList.add(tt2);
        try{
            
            MyTeamWeeklyTaskController.taskWeeklyApprove(taskList);
            MyTeamWeeklyTaskController.taskWeeklyApprove(null);
        }catch(Exception e){
            System.debug('error');
        }
    }
    @isTest static void saveTaskWeeklyLwcTest(){
         
		Account acc=new Account();
        acc.Name='Test';
        insert acc;
        Milestone__c milestone0=new Milestone__c();
        milestone0.Name='Test1';
        milestone0.Account__c=acc.Id;
        insert milestone0;
        Outcome__c ott=new Outcome__c();
        ott.Milestone__c=milestone0.Id;
        ott.Status__c='Not Started';
        ott.Due_Date__c=Date.newInstance(2020,10,16);
        ott.Description__c='Test';
        insert ott; 
        Milestone_Master__c mm=new Milestone_Master__c(Name='Test Master');
        insert mm;
        
        Task tt1=new Task();
 
        tt1.Subject='call';
        tt1.Outcome__c=ott.Id;
        insert tt1;
        Task tt2=new Task(); 
        tt2.Subject='call2';
        tt2.Outcome__c=ott.Id;
        insert tt2;
        tt1.Subject='call Test12';  
        tt2.Subject='call Test2';
        List<Task> taskList=new List<Task>();
        taskList.add(tt1);
        taskList.add(tt2);
        try{
            
        MyTeamWeeklyTaskController.saveTaskWeeklyLwc(taskList);
        MyTeamWeeklyTaskController.saveTaskWeeklyLwc(null);
        }catch(Exception e){
            System.debug('error');
        }
    }
    @isTest static void fetchManagerIdTest(){
         Profile p=[SELECT Id From Profile WHERE Name='Standard User'];
        User u2 =new User( Alias = 'NU1' , Email ='nu1@to.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', UserName='nu1@tto.com', 
                          ProfileId=p.Id, TimeZoneSidKey    = 'America/Los_Angeles');
        insert u2; 
        User u3 =new User( Alias = 'NU12' , Email ='nu12@to.com',
                          EmailEncodingKey = 'UTF-8', LastName = '2Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', UserName='nu12@tto.com', ManagerId=u2.Id,
                          ProfileId=p.Id, TimeZoneSidKey    = 'America/Los_Angeles');
        insert u3;
        try{
            MyTeamWeeklyTaskController.fetchManagerId(u3.Id);
            MyTeamWeeklyTaskController.fetchManagerId(null);
        }catch(Exception e){
            System.debug('error');
        }
        
    }
   
    @isTest static void insertWeeklyTaskTest() {
        
        Task t=new Task(); 
        t.Status='In Progress';
        Task t2=new Task(); 
        t2.Status='In Progress';
        t2.Category__c='Meet';
        try{
            
            MyTeamWeeklyTaskController.insertWeeklyTask(t);
            MyTeamWeeklyTaskController.insertWeeklyTask(t2);
            
        }catch(Exception e){
            system.debug('e');
        }
    }
}