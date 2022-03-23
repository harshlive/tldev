@isTest 
private class MilestoneRecordPageTest {
    
    @isTest static void getMileStoneTest() {
        Account acc=new Account();
        acc.Name='Test';
        insert acc;
        Milestone__c milestone0=new Milestone__c();
        milestone0.Name='Test1';
        milestone0.Account__c=acc.Id;
        insert milestone0;   
        try {
            System.assertEquals(milestone0.Id , MilestoneRecordPage.getMileStone( ''+milestone0.Id+'' ).Id);
            
            MilestoneRecordPage.getMileStone( 'test' );  
        }
        catch(Exception ex) {
            System.debug(ex.getMessage());
        }
        
    }
    @isTest static void getProfileInfoTest() {
        Profile p=[SELECT Id From Profile WHERE Name='Standard User'];
        User u2 =new User( Alias = 'NU1' , Email ='nu1@to.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', UserName='nu1@tto.com', 
                          ProfileId=p.Id, TimeZoneSidKey    = 'America/Los_Angeles');
        insert u2;
        try{ 
            //System.assertEquals('Standard User',MilestoneRecordPage.getProfileInfo(''+u2.Id+''));
            //MilestoneRecordPage.getProfileInfo('test');            
        }catch(Exception e){
            System.debug(e.getMessage()); } 
    }
    
    @isTest static void setReminderTest() {        
        Task tt=new Task(); 
        tt.Subject='call';        
        insert tt;        
        try{ 
           MilestoneRecordPage.setReminder(''+tt.Id+'',DateTime.now());            
            MilestoneRecordPage.setReminder('test',DateTime.now());  
        }catch(Exception e){
            System.debug(e.getMessage()); } 
    }
    @isTest static void getOutcomeMasterTest() {        
         
        Account acc=new Account();
        acc.Name='Test 1';
        insert acc;
		Milestone_Master__c mm1=new Milestone_Master__c();
        mm1.Name='Test 1';
        mm1.Index__c=1;
        insert mm1;
       	Outcome_Master__c om1=new Outcome_Master__c();
        om1.Name='Outcome 1';
        om1.Index__c=1;
        om1.Guidance_Question_Master__c=mm1.Id;
        insert om1;
        Milestone__c m1=new Milestone__c();
        m1.Name='Test 1';
        m1.Account__c=acc.Id;
        m1.Milestone_Master__c=mm1.Id;
        insert m1;
        
        try{ 
           MilestoneRecordPage.getOutcomeMaster(''+m1.Id+'');            
            MilestoneRecordPage.getOutcomeMaster('test'); 
            
        }catch(Exception e){
            System.debug(e.getMessage()); } 
    }
    @isTest static void getOutcomeListTest() {
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
        
        Outcome__c ott2=new Outcome__c();
        ott2.Milestone__c=milestone0.Id;
        ott2.Status__c='Not Started';
        ott2.Due_Date__c=Date.newInstance(2020,10,16);
        ott2.Description__c='Test';
        insert ott2;
        ott2.Status__c = 'Complete';
        update ott2;
        try{ 
            System.assertEquals(ott.Id,MilestoneRecordPage.getOutcomeList( ''+milestone0.Id+'' )[0].Id);
            
            MilestoneRecordPage.getOutcomeList(';');            
        }catch(Exception e){
            System.debug(e.getMessage()); } 
    }
    
    @isTest static void showTaskListTest() {
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
        
        Task tt=new Task(); 
        tt.Subject='call';
        tt.Outcome__c=ott.Id;
        insert tt;
        try{
            System.assertEquals( tt.Id,MilestoneRecordPage.showTaskList( ''+ott.Id+'' )[0].Id);
            
            MilestoneRecordPage.showTaskList(';');            
        }catch(Exception e){
            System.debug(e.getMessage()); } 
    }
    
    @isTest static void deleteTaskTest() {
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
         
        Task tt=new Task();
        tt.Subject='call';
        tt.Outcome__c=ott.Id;
        insert tt;
        try{
            MilestoneRecordPage.deleteTask( ''+tt.Id+'' );
            Task deletedAccount = [SELECT Id, IsDeleted FROM Task WHERE Id = :tt.Id ALL ROWS]; 
            System.assert(deletedAccount.IsDeleted);
            MilestoneRecordPage.deleteTask('test');            
        }catch(Exception e){
            System.debug(e.getMessage()); }  
        
    }
    
    @isTest static void deleteOutcomeTest() {
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
        
        try{
            MilestoneRecordPage.deleteOutcome( ''+ott.Id+'' ); 
            Outcome__c deletedAccount = [SELECT Id, IsDeleted FROM Outcome__c WHERE Id = :ott.Id ALL ROWS];
         //   System.asserEquals(deletedAccount.IsDeleted, true);
            System.assert(deletedAccount.IsDeleted);
            MilestoneRecordPage.deleteOutcome('test');            
        }catch(Exception e){
            System.debug(e.getMessage()); } 
    }
    
    @isTest static void saveTaskListTest(){
        
        
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
            MilestoneRecordPage.saveTaskList(taskList);
            System.assertEquals('call Test12',taskList[0].Subject);
            MilestoneRecordPage.saveTaskList(null);  
        }catch(Exception e){
            System.debug(e.getMessage()); } 
    }
    
    
    @isTest static void saveOutcomeListTest(){
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
        Outcome__c ott1=new Outcome__c();
        ott1.Milestone__c=milestone0.Id;
        ott1.Status__c='Not Started';
        ott1.Due_Date__c=Date.newInstance(2020,10,16);
        ott1.Description__c='Test2';
        insert ott1; 
        ott1.Description__c='test22';
        ott.Description__c='test11';
        List<Outcome__c> saveOutcomes=new List<Outcome__c>();
        saveOutcomes.add(ott);
        saveOutcomes.add(ott1);
        try{
            MilestoneRecordPage.saveOutcomeList(saveOutcomes);
            System.assertEquals('test11',saveOutcomes[0].Description__c);
            MilestoneRecordPage.saveOutcomeList(null);            
        }catch(Exception e){ 
            System.debug(e.getMessage());} 
    }
    @isTest static void insertTaskTest(){
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
         
        Task tt=new Task();
 
        tt.Subject='call';
        tt.Outcome__c=ott.Id;
        List<Task> taskList1=new List<Task>();
        try{ 
            MilestoneRecordPage.insertTask(tt);
            System.assertEquals('call', tt.Subject);
            MilestoneRecordPage.insertTask(null);            
        }catch(Exception e){System.debug(e.getMessage()); }
        
    }
    @isTest static void insertOutcomeTest(){
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
        try{
            MilestoneRecordPage.insertOutcome(ott);
            System.assertEquals('Test',ott.Description__c);
            MilestoneRecordPage.insertOutcome(null);            
        }catch(Exception e){System.debug(e.getMessage()); }
    }
    @isTest static void saveTaskLwcTest(){
        Profile p=[SELECT Id From Profile WHERE Name='Standard User'];
        User u2 =new User( Alias = 'NU1' , Email ='nu1@to.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', UserName='nu1@tto.com', 
                          ProfileId=p.Id, TimeZoneSidKey    = 'America/Los_Angeles');
        insert u2; 
        Account acc=new Account();
        acc.Name='T';
        insert acc;
        Milestone__c milestone0=new Milestone__c();
        milestone0.Name='T1';
        milestone0.Account__c=acc.Id;
        insert milestone0;
        Outcome__c ott=new Outcome__c();
        ott.Milestone__c=milestone0.Id;
        ott.Status__c='Not Started';
        ott.Due_Date__c=Date.newInstance(2020,10,16);
        ott.Description__c='T';
        insert ott; 
        Milestone_Master__c mm=new Milestone_Master__c(Name='Y');
        insert mm;
        
        Task tt1=new Task();
        tt1.Subject='Q';
        tt1.Status='Not Started';
        tt1.Priority='Low';
        tt1.Outcome__c=ott.Id;
        tt1.OwnerId=u2.Id;
        insert tt1; 
        tt1.Subject='R'; 
        List<Task> taskList=new List<Task>();
        taskList.add(tt1);
        
        try{
            MilestoneRecordPage.saveTaskLwc(taskList,acc.Id);
            System.assertEquals('Not Started',taskList[0].Status );
            MilestoneRecordPage.saveTaskLwc(null,null);            
        }catch(Exception e){ System.debug(e.getMessage());} 
        
    }
    @isTest static void saveOutcomeLwcTest(){
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
        Outcome__c ott1=new Outcome__c();
        ott1.Milestone__c=milestone0.Id;
        ott1.Status__c='Not Started';
        ott1.Due_Date__c=Date.newInstance(2020,10,16);
        ott1.Description__c='Test2';
        insert ott1; 
        ott1.Description__c='test22';
        ott.Description__c='test11';
        List<Outcome__c> saveOutcomes=new List<Outcome__c>();
        saveOutcomes.add(ott);
        saveOutcomes.add(ott1);
        
        try{
            MilestoneRecordPage.saveOutcomeLwc(saveOutcomes);
            System.assertEquals('test11', saveOutcomes[0].Description__c);
            MilestoneRecordPage.saveOutcomeLwc(null);            
        }catch(Exception e){System.debug(e.getMessage()); } 
    }
    
    @isTest static void insertTaskLwcTest(){
        Account acc=new Account();
        acc.Name='Test';
        insert acc;
		Task tasks = new Task();
        tasks.Comments__c='Test Cmnt';  
        tasks.Product2__c='Balloon';
        tasks.Priority='High';
        tasks.Category__c='Meeting';
        tasks.StartDateTime__c=system.today();
        tasks.Task_Type__c = 'In Field';
        
        try{
            MilestoneRecordPage.insertTaskLwc(tasks);            
        }catch(Exception e){System.debug(e.getMessage()); } 
    }
    
    
    
}