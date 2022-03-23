public without sharing class MyTeamWeeklyTaskController {

    @AuraEnabled
    public static void insertWeeklyTask(Task newTask){      
        try { 
            newTask.Reporting_For__c='Weekly';
            insert newTask  ;
            system.System.debug('after insert'); 
        }
        catch(Exception ex) {
            ErrorLogger.LogError('MyTeamWeeklyTaskController:insertWeeklyTask', 'Apex Class', ex.getMessage(), ex.getStackTraceString(), '', 'Task'+newTask,  '');
            throw new AuraException(ex.getMessage());
        }

    
    }
    @AuraEnabled
    public static string fetchManagerId(string userId){      
        try { 
             User u=[select Id,Name,ManagerId,Manager.name from user where Id=:userId];
             return u.ManagerId;
        }
        catch(Exception ex) {
            ErrorLogger.LogError('MyTeamWeeklyTaskController:fetchManagerId', 'Apex Class', ex.getMessage(), ex.getStackTraceString(), '', 'User'+userId,  '');
            throw new AuraException(ex.getMessage());
        }

    
    }

    //Update Task List on Milestone Record Page
    @AuraEnabled
    public static void saveTaskWeeklyLwc(List<Task> records){
        try{
            if(records.size()>0 && records != null){
                List<Task> taskList = new List<Task>();
                
                for(integer i = 0; i < records.size(); i++) {
                    System.debug('records: --'+records[i]);
                    Task tasks = new Task();
                    tasks.Id = records[i].Id; 
                    tasks.Manager_Approval_Status__c=records[i].Manager_Approval_Status__c;
                    tasks.Manager_Comments__c=records[i].Manager_Comments__c;                    
                    taskList.add(tasks);
                }   
                if(!taskList.isEmpty()){            
                    update taskList;
                }          
            }
        }
        catch (DmlException ex) {
            ErrorLogger.LogError('MyTeamWeeklyTaskController:saveTaskWeeklyLwc', 'Apex Class', ex.getDmlMessage(0), ex.getStackTraceString(), '', 'Tasks:'+records,  '');
            throw new AurahandledException(ex.getDmlMessage(0));
        }
        catch(Exception ex) {
            ErrorLogger.LogError('MyTeamWeeklyTaskController:saveTaskWeeklyLwc', 'Apex Class', ex.getMessage(), ex.getStackTraceString(), '', 'Tasks:'+records,  '');
            throw new AuraException(ex.getMessage());
        } 
    }
    //Update Task List on Milestone Record Page
    @AuraEnabled
    public static void taskWeeklyApprove(List<Task> records){
        try{
            if(records.size()>0 && records != null){
                List<Task> taskList = new List<Task>();
                
                for(integer i = 0; i < records.size(); i++) {
                    System.debug('records: --'+records[i]);
                    Task tasks = new Task();
                    tasks.Id = records[i].Id; 
                    tasks.Manager_Approval_Status__c='Approved';    
                    tasks.Manager_Comments__c=records[i].Manager_Comments__c;                
                    taskList.add(tasks);
                }   
                if(!taskList.isEmpty()){            
                    update taskList;
                }          
            }
        }
        catch (DmlException ex) {
            ErrorLogger.LogError('MyTeamWeeklyTaskController:saveTaskWeeklyLwc', 'Apex Class', ex.getDmlMessage(0), ex.getStackTraceString(), '', 'Tasks:'+records,  '');
            throw new AurahandledException(ex.getDmlMessage(0));
        }
        catch(Exception ex) {
            ErrorLogger.LogError('MyTeamWeeklyTaskController:saveTaskWeeklyLwc', 'Apex Class', ex.getMessage(), ex.getStackTraceString(), '', 'Tasks:'+records,  '');
            throw new AuraException(ex.getMessage());
        } 
    }
    //Update Task List on Milestone Record Page
    @AuraEnabled
    public static void taskWeeklyReject(List<Task> records){
        try{
            if(records.size()>0 && records != null){
                List<Task> taskList = new List<Task>();
                
                for(integer i = 0; i < records.size(); i++) {
                    System.debug('records: --'+records[i]);
                    Task tasks = new Task();
                    tasks.Id = records[i].Id; 
                    tasks.Manager_Approval_Status__c='Rejected';    
                    tasks.Manager_Comments__c=records[i].Manager_Comments__c;                
                    taskList.add(tasks);
                }   
                if(!taskList.isEmpty()){            
                    update taskList;
                }          
            }
        }
        catch (DmlException ex) {
            ErrorLogger.LogError('MyTeamWeeklyTaskController:saveTaskWeeklyLwc', 'Apex Class', ex.getDmlMessage(0), ex.getStackTraceString(), '', 'Tasks:'+records,  '');
            throw new AurahandledException(ex.getDmlMessage(0));
        }
        catch(Exception ex) {
            ErrorLogger.LogError('MyTeamWeeklyTaskController:saveTaskWeeklyLwc', 'Apex Class', ex.getMessage(), ex.getStackTraceString(), '', 'Tasks:'+records,  '');
            throw new AuraException(ex.getMessage());
        } 
    }
    @AuraEnabled
    public static void setPriority(List<Task> records){
        system.debug(records);
        update records;
    } 
    
}