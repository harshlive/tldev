public without sharing class DailyReportingController {
   
    @AuraEnabled
    public static List<Contact> fetchRecords(string accountId){
        List<Contact> conList = new List<Contact>();
        System.debug(accountId);
        if(accountId==null){
            return null;
        }
        List<AccountContactRelation> acrLst = new List<AccountContactRelation>();
        acrLst = [SELECT ContactId FROM AccountContactRelation WHERE AccountId = : accountId];
        Set<Id> conIds = new Set<Id>();
        for(AccountContactRelation acr : acrLst) {
            conIds.add(acr.ContactId);
        }
        conList = [Select Id, firstname,Title__C,Name,Contact_Name__c,AccountId, lastname FROM contact WHERE Id IN  : conIds];
        
        List<Task> taskList=[ SELECT Id, Subject, IsReminderSet,ReminderDateTime,ActivityDate,WhoId,Who.Name,
                             WhatId,Contact__c,Contact__r.Title__c, Milestone__c,Support__r.Name,Support__c,
                             Outcome__c,Owner.Name,StartDateTime__c,Category_Of_Task__c ,
                             Comments__c,Category__c,Due_Date_Comments__c,Account__r.Name,
                             Priority, Status FROM Task 
                             where Account__c =:accountId  AND Account__c!=Null];
        
        return conList;
    }
    
    @AuraEnabled
    public static void insertTaskList(List<Task> taskList) {
        try {
            System.debug(taskList);
            for(Task tsk : taskList) {
                tsk.subject = 'Daily Task';
                tsk.Reporting_For__c='Daily';
            }
            insert taskList; 
            
        }
        catch(Exception ex) {
            ErrorLogger.LogError('DailyReportingController:insertTaskList', 'Apex Class', ex.getMessage(), ex.getStackTraceString(), '', 'Tasklist'+taskList,  '');
            throw new AuraException(ex.getMessage());
        }        
    }
    @AuraEnabled
    public static void insertApprovalRequest(Date startDate,Date endDate) {
        try {
            User u=[select id,ManagerId from User where Id=:UserInfo.getUserId()];

            System.debug('start:'+startDate+':end:'+endDate);
            Task_Approval__c newReq=new Task_Approval__c();
            newReq.Start_Date__c=startDate;
            newReq.End_Date__c=endDate;
            newReq.User__c=UserInfo.getUserId();
            newReq.Approval_Status__c='Pending';
            newReq.Manager__c=u.ManagerId;
            //newReq.Type__c=approvalType;
            insert newReq;
            
        }
        catch(Exception ex) {
            ErrorLogger.LogError('DailyReportingController:insertApprovalRequest', 'Apex Class', ex.getMessage(), ex.getStackTraceString(), '', 'Dates:start-'+startDate+' end-'+endDate,  '');
            throw new AuraException(ex.getMessage());
        }        
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getPickList(String objectName,String fieldName) {
        system.debug(objectName);
        system.debug(fieldName);
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<string> pickListValues = new List<string>();
        for( Schema.PicklistEntry pickListVal : ple){
            //System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
            pickListValues.add(pickListVal.getValue());
        }    
        return pickListValues;
    }
    @AuraEnabled
    public static List<String> getPickListValues(string key){
        Map<String,List<String>> dependentPicklistValuesMap = DailyReportingController.getDependentPicklistValues(Task.Category__c);
        return dependentPicklistValuesMap.get(key);
    }
    
    public static Map<String, List<String>> getDependentPicklistValues(Schema.sObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<String>>();
        }
        
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                    String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                        (controlEntries == null
                         ?   (Object) (index == 1)
                         :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                        );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }
        return dependentPicklistValues;
    }
    @AuraEnabled
    public static boolean fetchApprovals(string userId,Date dateVal,Boolean checkDay){
        Date myDate = date.newinstance(dateVal.year(), dateVal.month(), dateVal.day());
        system.debug('myDate:'+myDate);

        if(checkDay==true){
            Date dd = System.today();
            Datetime ddt = (DateTime)dd;
            //This returns - Monday, Tuesday, Wednesday, etc..
            List<String> weekdays=new List<String>{'Friday','Saturday','Sunday'};
            String dayOfWeek = ddt.format('EEEE'); 
            System.debug('DAY::'+dayOfWeek);
            System.debug('IF::'+weekdays.contains(dayOfWeek));
            if(weekdays.contains(dayOfWeek)==false){
                  System.debug('In FALSE');
                List<Task_Approval__c> approvalLst = [SELECT Id from Task_Approval__c where Approval_Status__c  = 'Approved' and 
                User__c = : userId and start_date__c <= : dd and end_date__c >= : dd];                
                system.debug(approvalLst);
                if(approvalLst.size()>0) {
                    return true;
                }
            }else{
                return true;
            }
            
        }else{
            List<Task_Approval__c> approvalLst = [SELECT Id from Task_Approval__c where Approval_Status__c  = 'Approved' and User__c = : userId and start_date__c <= : myDate and end_date__c >= : myDate];
            system.debug(userId);
            system.debug(dateVal);
            system.debug(approvalLst);
            if(approvalLst.size()>0) {
                return true;
            }
        }
        System.debug('return false');
        return false;
    }

    //Added by Harsh G
    @AuraEnabled
    public static List<Account> getAccDetails(string accountId){
        List<Account> accList = new List<Account>();
        System.debug(accountId);
        accList = [Select Id, Status__c, Critical_Account__c, Aim_in_Account__c, Critical_Success_Factor_for_Aim__c, Action_Plan_for_account__c, Deadline_for_action__c FROM Account WHERE id = : accountId];
        
        return accList;
    }

    @AuraEnabled
    public static void insertWeeklyTaskList(List<Task> taskList) {
        try {
            System.debug(taskList);
            for(Task tsk : taskList) {
                tsk.subject = 'Weekly Task';
                tsk.Reporting_For__c='Weekly';
                tsk.Task_Type__c = 'In Field';
                tsk.StartDateTimeUpdated__c = tsk.StartDateTime__c;
                System.debug('tsk::'+tsk);
            }
            insert taskList; 
            
        }
        catch(Exception ex) {
            ErrorLogger.LogError('DailyReportingController:insertTaskList', 'Apex Class', ex.getMessage(), ex.getStackTraceString(), '', 'Tasklist'+taskList,  '');
            throw new AuraException(ex.getMessage());
        }        
    }

    @AuraEnabled
    public static List<wrapData> fetchRecordsForWeeklyPlan(string accountId){
        List<Contact> conList = new List<Contact>();
        List<wrapData> wrapList = new List<wrapData>();
        List<AccountContactRelation> acrLst = new List<AccountContactRelation>();
        acrLst = [SELECT ContactId FROM AccountContactRelation WHERE AccountId = : accountId];
        Set<Id> conIds = new Set<Id>();
        for(AccountContactRelation acr : acrLst) {
            conIds.add(acr.ContactId);
        }
        
        System.debug(accountId);
        conList = [Select Id, firstname,Title__C,Name,Contact_Name__c,AccountId, lastname FROM contact WHERE Id IN : conIds];
        wrapData wr ;
        for(Contact con : conList){
           wr = new wrapData();
           wr.Id = con.Id;
           wr.accountId = accountId;
           wr.uniKey = con.Id + ':' + 0;
           wr.name = con.Contact_Name__c;
           wrapList.add(wr);
           System.debug('wrapList::'+wrapList);
        }
        return wrapList;
    }

    public class wrapData{
        @AuraEnabled
        public String uniKey{get; set;}
        @AuraEnabled
        public String Id{get; set;}
        @AuraEnabled
        public String name{get; set;}
        @AuraEnabled
        public String AccountId{get; set;}
    }

    //get Task List
    @AuraEnabled
    public static List<Task> showTaskList() {
        try{
            Integer mnth = System.Today().Month();
            Integer yr = System.Today().Year();
            return [
                SELECT Id, Subject, IsReminderSet,ReminderDateTime,ActivityDate,WhoId,Who.Name,
                WhatId,What.Name,Contact__c, Milestone__c,Product__c,Product2__c,Support__r.Name,Support__c,
                Outcome__c,Owner.Name,StartDateTime__c,Category_Of_Task__c ,
                Comments__c,Category__c,Due_Date_Comments__c,
                Priority, Status FROM Task WHERE Reporting_For__c = 'Weekly' 
                AND OwnerId = : userinfo.getUserId() AND CALENDAR_MONTH(StartDateTime__c) = :mnth AND CALENDAR_YEAR(StartDateTime__c) = :yr ORDER BY StartDateTime__c DESC
            ];
        }
        catch(Exception e){
            ErrorLogger.LogError('WeeklyPlan:showTaskList', 'Apex Class', e.getMessage(), e.getStackTraceString(), '', '',  '');
            throw new AuraException(e.getMessage());
        }
        
    }
    
}