@isTest 
private class DailyReportingControllerTest {

    @isTest static void fetchRecordsTest() {
        Account acc=new Account();
        acc.Name='Test';
        insert acc;
        Contact con=new Contact();
        con.LastName='Test con';
        con.MobilePhone='9856545874';
        con.Email='test@gmail.com';
        con.AccountId=acc.Id;
        insert con;
        DailyReportingController.fetchRecords(acc.Id);
        DailyReportingController.getAccDetails(acc.Id);
        DailyReportingController.fetchRecordsForWeeklyPlan(acc.Id);
    }
    @isTest static void insertApprovalRequestTest(){
        try{
            
    
        DailyReportingController.insertApprovalRequest(System.today(),System.today());
        DailyReportingController.insertApprovalRequest(null,null);
        }catch(Exception e){
            System.debug('error');
        }
         
    }
    @isTest static void fetchApprovalsTest(){
         Task_Approval__c ta=new Task_Approval__c();
        ta.Start_Date__c=system.today();
        ta.End_Date__c=system.today();
        ta.User__c=UserInfo.getUserId();
        ta.Approval_Status__c='Approved';
        ta.Manager__c=UserInfo.getUserId();
        insert ta;
        
        DailyReportingController.fetchApprovals(UserInfo.getUserId(),System.today(),true);
        DailyReportingController.fetchApprovals(UserInfo.getUserId(),System.today(),false);
    }
    @isTest static void insertTaskListTest(){
        Task tt=new Task();
        tt.Priority='Normal';
        List<Task> ttList=new List<Task>();
        ttList.add(tt);
        List<Task> ttList1=new List<Task>();
        try{
        	DailyReportingController.insertTaskList(ttList);
            DailyReportingController.insertTaskList(null);     
        }catch(Exception e){
            
        }
    }
    @isTest static void getPickListTest(){
        DailyReportingController.getPickList('Task', 'Status');
        DailyReportingController.showTaskList();
    } 
    
    @isTest static void getPickListValuesTest(){
        DailyReportingController.getPickListValues('In Field');
        DailyReportingController.getPickListValues(null);
    } 
    
    @isTest static void insertWeeklyTaskListTest(){
        Task tt=new Task();
        tt.Priority='Normal';
        List<Task> ttList=new List<Task>();
        ttList.add(tt);
        try{
			DailyReportingController.insertWeeklyTaskList(ttList);            
			DailyReportingController.insertWeeklyTaskList(null);            
        }catch(Exception e){
            
        }
    }
}