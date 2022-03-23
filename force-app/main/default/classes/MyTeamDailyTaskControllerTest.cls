@isTest 
private class MyTeamDailyTaskControllerTest {
    
    @isTest static void fetchRecordsTest() {
        
        Profile p=[SELECT Id From Profile WHERE Name='Standard User'];
        User u2 =new User( Alias = 'NU1' , Email ='nu1@to.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', UserName='nu1@tto.com', 
                          ProfileId=p.Id, TimeZoneSidKey    = 'America/Los_Angeles');
        insert u2;
         Account acc=new Account();
        acc.Name='Test';
        insert acc;
        Task tt=new Task();
        tt.Account__c=acc.Id;
        tt.Subject='Meeting';
        tt.IsReminderSet=false;
        tt.ActivityDate=Date.today();
        tt.OwnerId=u2.Id;
        tt.StartDateTime__c=DateTime.now();
        tt.Category__c='Meeting';
        tt.Task_Type__c='In Field';
        tt.Priority='Normal';
        tt.Status='Not Started';
        insert tt;
       
        List<Task> ttList=new List<Task>();
        ttList.add(tt);
        try{
            
            MyTeamDailyTaskController.fetchRecords( u2.Id ,Date.today() );  
            MyTeamDailyTaskController.fetchDailyRecords( u2.Id ,Date.today(),Date.today().addDays(1) );  
            MyTeamDailyTaskController.fetchWeeklyPlanRecords(u2.Id,Date.today(),Date.today().addDays(1));
 	MyTeamDailyTaskController.fetchRecordsfromAccount(u2.Id, acc.Id );
        }catch(Exception e){
            
        }
        //System.assertEquals(ttList,MyTeamDailyTaskController.fetchRecords( u2.Id ,Date.today()) );        
    }
    
    @isTest static void insertWeeklyTaskTest() {
    	Task t=new Task();
        t.Status='Not Started';
        Task t1=new Task();
        
        try{
       		 MyTeamDailyTaskController.insertWeeklyTask(t);
             MyTeamDailyTaskController.insertWeeklyTask(null);
        }catch(Exception e){
            System.debug('excep');
        }
    }
    
    @isTest static void getUserListTest() {
        Set<ID> roleIds=new Set<ID>();
        UserRole userRole=new UserRole();
        userRole.Name='Test';
        userRole.ParentRoleId=UserInfo.getUserRoleId();
        insert userRole;  
        roleIds.add(userRole.Id);
        UserRole ur=new UserRole();
        ur.Name='Test 2';
        ur.ParentRoleId=UserInfo.getUserRoleId();
        insert ur; 
        User uu=[Select Id, Name,username From User where id=:userinfo.getUserId()]; 
        Map<Id,User> usrMap=new Map<Id,User>();
        usrMap.put(uu.Id, uu);
        MyTeamDailyTaskController.getUserList(); 
         MyTeamDailyTaskController.getAllSubRoleIds(roleIds); 
        //System.assertEquals(usrMap.values(),MyTeamDailyTaskController.getUserList());
        
    }
    
    @isTest static void fetchDailytask() {
         Account acc=new Account();
        acc.Name='Test';
        insert acc;
        Task tt=new Task();
        tt.Account__c=acc.Id;
        tt.Subject='Meeting';
        tt.IsReminderSet=false;
        tt.ActivityDate=Date.today();
        tt.StartDateTime__c=DateTime.now();
        tt.Category__c='Meeting';
        tt.Task_Type__c='In Field';
        tt.Priority='Normal';
        tt.Status='Not Started';
        tt.StartDateTime__c=Date.Today();
        tt.OwnerId=UserInfo.getUserId();
        insert tt;
        MyTeamDailyTaskController.fetchAllDailyTask(UserInfo.getUserId(),Date.Today()); 
        //System.assertEquals(usrMap.values(),MyTeamDailyTaskController.getUserList());
        
    }
    
}