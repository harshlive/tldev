/*
Project: Translumina
Used for: Milestone Record Page LWC's
*/

public without sharing class MilestoneRecordPage {
 
    //get milestone details
    @AuraEnabled(cacheable=true)
    public static Milestone__c getMileStone(String milestoneId) {
        try{
             
            return [
                SELECT Id, Name, Start_Date__c, Account__c, LastModifiedDate 
                FROM Milestone__c WHERE Id=:milestoneId
                 
            ];
            
        }
        catch(Exception e){
            ErrorLogger.LogError('MiletoneRecordPage:getMileStone', 'Apex Class', e.getMessage(), e.getStackTraceString(), '', 'Milestone'+milestoneId,  '');
            throw new AuraException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=false)
    public static void setReminder(String taskId,DateTime taskTime) {
        try{
             Task tt=[SELECT Id, IsReminderSet, ReminderDateTime FROM Task where Id=:taskId LIMIT 1];
             tt.IsReminderSet=true;
             tt.ReminderDateTime=taskTime;
             System.debug(tt);
             update tt;
            
        }
        catch(Exception e){
            ErrorLogger.LogError('MiletoneRecordPage:setReminder', 'Apex Class', e.getMessage(), e.getStackTraceString(), '', 'Task'+taskId,  '');
            throw new AuraException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Outcome_Master__c> getOutcomeMaster(String guidanceId) {
        try{
        Milestone__c mile=[select Id,Name,Milestone_Master__c from Milestone__c where Id=:guidanceId];
        return [
            select Id,Name from Outcome_Master__c where Guidance_Question_Master__c=:mile.Milestone_Master__c                
            LIMIT 20
        ];
            }
        catch(Exception e){
            ErrorLogger.LogError('MiletoneRecordPage:getOutcomeMaster', 'Apex Class', e.getMessage(), e.getStackTraceString(), '', 'Milestone'+guidanceId,  '');
            throw new AuraException(e.getMessage());
        }
    }
    
	//Get profile information of User
    // @AuraEnabled(cacheable=true)
    // public static String getProfileInfo(String userId) {
    //     try{
    //         Id profileId=userinfo.getProfileId();
    //         User u=[Select Id,Name,profileId from User where Id=:userId];
    //         Profile profile=[Select Id,Name from Profile where Id=:u.ProfileId];
    //         system.debug('ProfileName'+profile.Name);
    //         return profile.Name; 
    //     }
    //     catch(Exception e){
    //         ErrorLogger.LogError('MiletoneRecordPage:getProfileInfo', 'Apex Class', e.getMessage(), e.getStackTraceString(), '', 'userid'+userId,  '');
    //         throw new AuraException(e.getMessage());
    //     }
    // }
    
    //get outcome List
    @AuraEnabled 
    public static List<Outcome__c> getOutcomeList(String milestoneId) {
        try{
            return [
                SELECT Id,Name, Account__c, Completion_Date__c, Due_Date__c,Outcome_Number_New__c ,
                Description__c, Milestone__c, Status__c
                FROM Outcome__c WHERE Milestone__c=:milestoneId
                
                LIMIT 20
            ];
        }
        catch(Exception e){
            ErrorLogger.LogError('MiletoneRecordPage:getOutcomeList', 'Apex Class', e.getMessage(), e.getStackTraceString(), '', 'Milestone'+milestoneId,  '');
            throw new AuraException(e.getMessage());
        }
    }
    
    //get Task List
    @AuraEnabled
    public static List<Task> showTaskList(String outcomeId) {
        try{
            return [
                SELECT Id, Subject, IsReminderSet,ReminderDateTime,ActivityDate,WhoId,Who.Name,
                WhatId,Contact__c, Milestone__c,Product__c,Product2__c,Support__r.Name,Support__c,
                Outcome__c,Owner.Name,StartDateTime__c,Category_Of_Task__c ,
                Comments__c,Category__c,Due_Date_Comments__c,
                Priority, Status FROM Task 
                where Outcome__c =:outcomeId            
                LIMIT 20
            ];
        }
        catch(Exception e){
            ErrorLogger.LogError('MiletoneRecordPage:showTaskList', 'Apex Class', e.getMessage(), e.getStackTraceString(), '', 'Outcome'+outcomeId,  '');
            throw new AuraException(e.getMessage());
        }
        
    }
    
    //Update Existing tasks  
    @AuraEnabled
    public static void saveTaskList(List<Task> taskList) {
        try {
            System.debug(taskList);
            update taskList; 
            
        }
        catch(Exception ex) {
            ErrorLogger.LogError('MiletoneRecordPage:saveTaskList', 'Apex Class', ex.getMessage(), ex.getStackTraceString(), '', 'Tasklist'+taskList,  '');
            throw new AuraException(ex.getMessage());
        }        
    }
    
    //Update Outcome List
    @AuraEnabled
    public static void saveOutcomeList(List<Outcome__c> saveOutcomes) {
        try {
            update saveOutcomes;
        }
        catch(Exception ex) {
            ErrorLogger.LogError('MiletoneRecordPage:saveOutcomeList', 'Apex Class', ex.getMessage(), ex.getStackTraceString(), '', 'Outcomes'+saveOutcomes,  '');
            
            throw new AuraException(ex.getMessage());
        }
        
    }
    
    //Insert New Task
    @AuraEnabled
    public static void insertTask(Task newTask) {
        try {
            Outcome__c ot=[select Id,Account__c,Milestone__c from Outcome__c 
                           where Id=:newTask.Outcome__c 
                           ];
            newTask.Reporting_For__c='Weekly';
            newTask.Account__c=ot.Account__c;
            newTask.Milestone__c=ot.Milestone__c;
            
            insert newTask  ;
            system.System.debug('after insert');
            
        }
        catch(Exception ex) {
            ErrorLogger.LogError('MiletoneRecordPage:insertTask', 'Apex Class', ex.getMessage(), ex.getStackTraceString(), '', 'Task'+newTask,  '');
            throw new AuraException(ex.getMessage());
        }
    }
    
    //Insert New Outcome
    @AuraEnabled
    public static void insertOutcome(Outcome__c newOutcome) {
        try {
            
            Milestone__c ms=[select Id,Account__c from Milestone__c 
                             where Id=:newOutcome.Milestone__c 
                              LIMIT 1];
            newOutcome.Account__c=ms.Account__c;
            System.debug('outcome'+newOutcome);
            insert newOutcome  ;
            system.System.debug('after insert');
            
        }
        catch(Exception ex) {
            ErrorLogger.LogError('MiletoneRecordPage:insertOutcome', 'Apex Class', ex.getMessage(), ex.getStackTraceString(), '', 'Outcome:'+newOutcome,  '');
            
            throw new AuraException(ex.getMessage());
        }
    }
    
    //Update Task List on Milestone Record Page
    @AuraEnabled
    public static void saveTaskLwc(List<Task> records,string account){
        try{
            System.debug('records::'+records);
            if(records.size()>0 && records != null){
                List<Task> taskList = new List<Task>();
                
                for(integer i = 0; i < records.size(); i++) {
                    System.debug('records: --'+records[i]);
                    Task tasks = new Task();
                    tasks.Id = records[i].Id;
                    tasks.Subject=records[i].Subject;
                    if(account != null) {
                        tasks.WhatId = account;
                        tasks.Account__c = account;
                    }
                    tasks.Due_Date_Comments__c=records[i].Due_Date_Comments__c;
                    tasks.ActivityDate=records[i].ActivityDate; 
                    tasks.Comments__c=records[i].Comments__c;  
                    tasks.Status=records[i].Status;
                    tasks.Product2__c=records[i].Product2__c;
                    tasks.Priority=records[i].Priority;
                    tasks.Category__c=records[i].Category__c;
                    tasks.OwnerId=records[i].OwnerId;
                    tasks.Category_Of_Task__c=records[i].Category_Of_Task__c;
                    tasks.Contact__c=records[i].Contact__c; 
                    tasks.Due_Date_Comments__c=records[i].Due_Date_Comments__c;
                    tasks.Type=records[i].Type;
                    tasks.StartDateTime__c=records[i].StartDateTime__c;
                    tasks.IsReminderSet=records[i].IsReminderSet;
                    tasks.ReminderDateTime=records[i].ReminderDateTime;
                    tasks.Support__c=records[i].Support__c;
                    tasks.Task_Type__c = 'In Field';
                    //tasks.StartDateTimeUpdated__c = records[i].StartDateTime__c;
                    
                    taskList.add(tasks);
                }   
                if(!taskList.isEmpty()){            
                    update taskList;
                }          
            }
        }
        catch (DmlException ex) {
            ErrorLogger.LogError('MiletoneRecordPage:saveTaskLwc', 'Apex Class', ex.getDmlMessage(0), ex.getStackTraceString(), '', 'Tasks:'+records,  '');
            throw new AurahandledException(ex.getDmlMessage(0));
        }
        catch(Exception ex) {
            ErrorLogger.LogError('MiletoneRecordPage:saveTaskLwc', 'Apex Class', ex.getMessage(), ex.getStackTraceString(), '', 'Tasks:'+records,  '');
            throw new AuraException(ex.getMessage());
        } 
    }
    
    //Delete Task
    @AuraEnabled
    public static String deleteTask(String toDeleteId){
        try{
            List<Task> acc = new List<Task>();
            Task a = new Task();
            a.Id = toDeleteId;
            acc.add(a);
            Database.DeleteResult[] drList = Database.delete(acc, false);
            List<String> deletedIds = new List<String>();
            List<String> errorMessages = new List<String>();
            // Iterate through each returned result
            for(Database.DeleteResult dr : drList) {
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully deleted account with ID: ' + dr.getId());
                    deletedIds.add(dr.getId());
                    
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : dr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                        errorMessages.add(err.getMessage());
                    }
                    
                }
            }
            if(deletedIds.size() > 0)
            {
                return 'success';
            }
            else
            {
                return errorMessages[0];
            } 
        }
        catch(Exception ex) {
            ErrorLogger.LogError('MiletoneRecordPage:deleteTask', 'Apex Class', ex.getMessage(), ex.getStackTraceString(), '', 'Task:'+toDeleteId,  '');
            throw new AuraException(ex.getMessage());
        }
    }
    
    //Delete Outcome
    @AuraEnabled
    public static String deleteOutcome(String toDeleteId){
        try{
            List<Outcome__c> out = new List<Outcome__c>();
            Outcome__c a = new Outcome__c();
            a.Id = toDeleteId;
            out.add(a);
            Database.DeleteResult[] drList = Database.delete(out, false);
            List<String> deletedIds = new List<String>();
            List<String> errorMessages = new List<String>();
            // Iterate through each returned result
            for(Database.DeleteResult dr : drList) {
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully deleted account with ID: ' + dr.getId());
                    deletedIds.add(dr.getId());
                    
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : dr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                        errorMessages.add(err.getMessage());
                    }
                    
                }
            }
            if(deletedIds.size() > 0)
            {
                return 'success';
            }
            else
            {
                return errorMessages[0];
            }
        }
        catch(Exception ex) {
            ErrorLogger.LogError('MiletoneRecordPage:deleteOutcome', 'Apex Class', ex.getMessage(), ex.getStackTraceString(), '', 'Outcome:'+toDeleteId,  '');
            throw new AuraException(ex.getMessage());
        }
    }
    
    //Update Outcome List on Milestone Record Page
    @AuraEnabled
    public static void saveOutcomeLwc(List<Outcome__c> records){
        try{
            if(records.size()>0 && records != null){
                List<Outcome__c> outcomeList = new List<Outcome__c>();            
                for(integer i = 0; i < records.size(); i++) {
                    System.debug('records: --'+records[i]);
                    Outcome__c otcme = new Outcome__c();
                    otcme.Id = records[i].Id;                 
                    otcme.Description__c=records[i].Description__c;  
                    otcme.Due_Date__c=records[i].Due_Date__c;                 
                    otcme.Completion_Date__c=records[i].Completion_Date__c;
                    otcme.Status__c=records[i].Status__c;
                    
                    
                    outcomeList.add(otcme);
                }   
                if(!outcomeList.isEmpty()){            
                    update outcomeList;
                }          
            } 
        }
        catch (DmlException ex) {
            ErrorLogger.LogError('MiletoneRecordPage:saveOutcomeLwc', 'Apex Class', ex.getDmlMessage(0), ex.getStackTraceString(), '', 'Outcomes:'+records,  '');
            throw new AurahandledException(ex.getDmlMessage(0));
        }
        catch(Exception ex) {
            ErrorLogger.LogError('MiletoneRecordPage:saveOutcomeLwc', 'Apex Class', ex.getMessage(), ex.getStackTraceString(), '', 'Outcomes:'+records,  '');
            throw new AuraException(ex.getMessage());
        }  
        
    }

    @AuraEnabled
    public static void insertTaskLwc(Task record){
        try{
            System.debug('records::'+record);
                List<Task> taskList = new List<Task>();
                
                    Task tasks = new Task();
                    tasks.Comments__c=record.Comments__c;  
                    tasks.Product2__c=record.Product2__c;
                    tasks.Priority=record.Priority;
                    tasks.Category__c=record.Category__c;
                    tasks.StartDateTime__c=record.StartDateTime__c;
                    tasks.Support__c=record.Support__c;
                    tasks.Contact__c=record.Contact__c;
                    tasks.WhoId=record.WhoId;
                    tasks.Task_Type__c = 'In Field';
                    tasks.Account__c = record.Account__c;
                    tasks.WhatId = record.WhatId;
                    taskList.add(tasks);
                System.debug('taskList::'+taskList);
                if(!taskList.isEmpty()){            
                    insert taskList;
                }          
        }
        catch (DmlException ex) {
            ErrorLogger.LogError('MiletoneRecordPage:insertTaskLwc', 'Apex Class', ex.getDmlMessage(0), ex.getStackTraceString(), '', 'Tasks:'+record,  '');
            throw new AurahandledException(ex.getDmlMessage(0));
        }
        catch(Exception ex) {
            ErrorLogger.LogError('MiletoneRecordPage:insertTaskLwc', 'Apex Class', ex.getMessage(), ex.getStackTraceString(), '', 'Tasks:'+record,  '');
            throw new AuraException(ex.getMessage());
        } 
    }
}