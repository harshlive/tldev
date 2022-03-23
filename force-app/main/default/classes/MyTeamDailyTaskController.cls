public with sharing class MyTeamDailyTaskController {
    
    @AuraEnabled
    public static List<Task> fetchRecords(string userId,Date taskDate){         
        
        List<Task> taskList=[ SELECT Id, Subject, IsReminderSet,ReminderDateTime,ActivityDate,WhoId,Who.Name,
                             WhatId,What.Name,Contact__c,Contact__r.Title__c,Product__c,Product2__c, Milestone__c,Support__r.Name,Support__c,
                             Outcome__c,Owner.Name,StartDateTime__c,Category_Of_Task__c ,
                             Comments__c,Category__c,Due_Date_Comments__c,Task_Type__c,Account__r.Name,
                             Priority, Status FROM Task 
                             where  OwnerId=:userId and DAY_ONLY (convertTimezone (StartDateTime__c))=:taskDate];
        
        return taskList; 
        
    }
    //new version
    @AuraEnabled
    public static List<Task> fetchDailyRecords(string userId,Date fromDate,Date toDate){         
        
        List<Task> taskList=[ SELECT Id, Subject, IsReminderSet,ReminderDateTime,ActivityDate,WhoId,Who.Name,
                             WhatId,What.Name,Contact__c,Contact__r.Title__c,Product__c,Product2__c, Milestone__c,Support__r.Name,Support__c,
                             Outcome__c,Owner.Name,StartDateTime__c,Category_Of_Task__c ,
                             Comments__c,Category__c,Due_Date_Comments__c,Task_Type__c,Account__r.Name,
                             Priority, Status FROM Task 
                             where  OwnerId=:userId and DAY_ONLY (convertTimezone (StartDateTime__c))>=:fromDate 
                             and DAY_ONLY (convertTimezone (StartDateTime__c))<=:toDate 
                             order by StartDateTime__c ];
        
        return taskList; 
        
    }
    @AuraEnabled
    public static void insertWeeklyTask(Task newTask){      
        try {
            
            
            insert newTask  ;
            system.System.debug('after insert');
            
        }
        catch(Exception ex) {
            ErrorLogger.LogError('MyTeamDailyTaskController:insertWeeklyTask', 'Apex Class', ex.getMessage(), ex.getStackTraceString(), '', 'Task'+newTask,  '');
            throw new AuraException(ex.getMessage());
        }
        
        
    }
    @AuraEnabled
    public static List<Task> fetchWeeklyPlanRecords(string userId,Date fromDate,Date toDate){      
        
        
        
        List<String> catTypes=System.Label.WeeklyTabCategoryTypes.split(',');
        
        
        List<Task> tasks=[SELECT Id, Category__c,Subject, ActivityDate,WhoId FROM Task 
                          where   Status!='Completed'  AND Category__c in :catTypes  ];
        List<Task> taskList=[ SELECT Id, Subject, IsReminderSet,ReminderDateTime,ActivityDate,WhoId,Who.Name,
                             WhatId,What.Name,Contact__c,Contact__r.Title__c,Product__c,Product2__c, Milestone__c,Milestone__r.Name,Support__r.Name,
                             Support__c, Outcome__c,Outcome__r.Outcome_Name__c ,Owner.Name,StartDateTime__c,Category_Of_Task__c ,
                             Comments__c,Category__c,Due_Date_Comments__c,Task_Type__c,Account__r.Name,
                             Priority, Status,Manager_Approval_Status__c,Manager_Comments__c FROM Task 
                             where  OwnerId=:userId and DAY_ONLY (convertTimezone (StartDateTime__c))>=:fromDate 
                             and DAY_ONLY (convertTimezone (StartDateTime__c))<=:toDate
                             AND (((outcome__c != null or  Category__c in :catTypes )  AND  (Status!='Complete' OR Category__c='Marketing Activity')) OR reporting_for__c = 'Weekly')
                             order by StartDateTime__c];
        
        return taskList; 
        
    }
    /* @AuraEnabled
public static List<Date> fetchWeekDates(Date taskDate){      


Date weekstart = taskDate.toStartofWeek();
Date weekend = weekstart.adddays(6);
System.debug('Today:'+taskDate+' Start Week:'+weekstart+' End:'+weekend);
List<Date> datelist=new List<Date>();
datelist.add(weekstart);
datelist.add(weekend);

Map<String,Date> dateMap=new Map<String,Date>();  
dateMap.put('start',weekstart);     
dateMap.put('end',weekend);
return datelist; 

}*/
    
    @AuraEnabled
    public static List<Task> fetchRecordsfromAccount(string userId,string accountId){   
        
        System.debug('accID: '+accountId); 
        System.debug('accID: '+accountId); 
        List<Task> taskList=[ SELECT Id, Subject, IsReminderSet,ReminderDateTime,ActivityDate,WhoId,Who.Name,
                             WhatId,What.Name,Contact__c,Contact__r.Title__c,Product__c,Product2__c,Milestone__c,
                             Milestone__r.Name,Support__r.Name,Support__c,
                             Outcome__c,Outcome__r.Outcome_Name__c,Owner.Name,StartDateTime__c,Category_Of_Task__c ,
                             Comments__c,Category__c,Due_Date_Comments__c,Task_Type__c,Account__r.Name,
                             Priority, Status FROM Task 
                             where  OwnerId=:userId and Account__c=:accountId ];
        
        return taskList; 
        
    }
    
    @AuraEnabled
    public static List<User> getUserList(){
        Id userId=UserInfo.getUserId();
        System.debug('userId:'+userId);
        List<string> roleList = system.label.AllUsersAccess.split(',');
        User currentUser=[select Id,name,UserRoleId,userrole.name,username,profile.name from User where Id=:userId ];
        Map<Id,Profile> profileIds = new Map<id,profile>([SELECT Id,UserLicenseId FROM Profile 
                                                          where UserLicenseId  in (SELECT Id FROM UserLicense where name ='Salesforce')]);
        
        List<user> allUsers = [select id,Name from user where profileId in:profileIds.Keyset() and IsActive=true 
                               and profile.name!='System Administrator' and Id!=:currentUser.Id];
        allUsers.add(currentUser);
        if(roleList.contains(currentUser.profile.name)) {
            return allUsers;
        }
        Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{currentUser.userroleid});
        Map<Id,User> users = new Map<Id, User>([Select Id, Name,username From User where
                                                UserRoleId IN :allSubRoleIds or id=:userinfo.getUserId()]);
        return users.values();
    }
    
    /*@AuraEnabled
public static List<User> getAccountUserList(string accountId){
Id userId=UserInfo.getUserId();
System.debug('userId:'+userId);
User currentUser=[select Id,name,userroleid,username from User where Id=:userId ];
Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{currentUser.userroleid});
List<AccountTeamMember> acc=[SELECT Id, AccountId,Account.Name, UserId,User.Name, TeamMemberRole, Title 
FROM AccountTeamMember
WHERE AccountId=:accountId];
set<Id> accIds=new set<Id>();
for(AccountTeamMember accM:acc)
{
accIds.add(accM.UserId);
}
Map<Id,User> users = new Map<Id, User>([Select Id, Name,username From User where
Id in acc.UserId]);
return users.values();
}*/
    
    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        
        Set<ID> currentRoleIds = new Set<ID>();
        
        for(UserRole userRole :[select Id from UserRole where ParentRoleId
                                IN :roleIds AND ParentRoleID != null])
            currentRoleIds.add(userRole.Id);
        if(currentRoleIds.size() > 0)
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        return currentRoleIds;
    }


 @AuraEnabled
    public static List<Task> fetchAllDailyTask(string userId,Date selectedDate){      
        List<Task> taskList=new List<Task>();

        taskList=[ SELECT Id, Subject, IsReminderSet,ReminderDateTime,ActivityDate,WhoId,Who.Name,
                             WhatId,What.Name,Contact__c,Contact__r.Name,Product__c,Product2__c, Milestone__c,Milestone__r.Name,Support__r.Name,
                             Support__c, Outcome__c,Outcome__r.Outcome_Name__c ,Owner.Name,StartDateTime__c,Category_Of_Task__c ,
                             Comments__c,Category__c,Due_Date_Comments__c,Task_Type__c,Account__r.Name,Type,CreatedDate,
                             Priority, Status,Manager_Approval_Status__c,Manager_Comments__c FROM Task  
                             where  OwnerId=:userId /* AND Reporting_For__c='Daily'*/
                             and DAY_ONLY (convertTimezone (StartDateTime__c)) = :selectedDate
                             order by StartDateTime__c];
        return taskList;
       
        
    }

}