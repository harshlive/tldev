@isTest 
private class GuidanceQuestionTriggerHandlerTest {
    
    @isTest static void onAfterUpdateTest() {	
        
        Account acc=new Account();
        acc.Name='Test';
        insert acc;
        
        Milestone_Master__c m1=new Milestone_Master__c();
        m1.Name='Test 1';
        m1.Index__c=1;
        insert m1;
        Milestone_Master__c m2=new Milestone_Master__c();
        m2.Name='Test 2';
        m2.Index__c=2;
        insert m2;
        Milestone_Master__c m3=new Milestone_Master__c();
        m3.Name='Test 3';
        m3.Index__c=3;
        insert m3;
        Milestone_Master__c m4=new Milestone_Master__c();
        m4.Name='Test 4';
        m4.Index__c=4;
        insert m4;
        
        Milestone__c newListobj0 = new Milestone__c (  );
        newListobj0.Account__c=acc.Id;  
        newListobj0.Milestone_Master__c=m1.Id;
        newListobj0.Status__c='In Progress';
        Insert newListobj0;
        Milestone__c newListobj1 = new Milestone__c (  );
        newListobj1.Milestone_Master__c=m2.Id;
        newListobj1.Account__c=acc.Id; 
        newListobj1.Status__c='In Progress';
        Insert newListobj1;
        Milestone__c newListobj2 = new Milestone__c (  );
        newListobj2.Milestone_Master__c=m3.Id;
        newListobj2.Account__c=acc.Id; 
        newListobj2.Status__c='In Progress';
        Insert newListobj2;
        Milestone__c newListobj3 = new Milestone__c (  );
        newListobj3.Milestone_Master__c=m4.Id;
        newListobj3.Account__c=acc.Id; 
        newListobj3.Status__c='In Progress';
        Insert newListobj3;
        
        Map<Id,Milestone__c> oldMap = new Map<Id,Milestone__c> ();
        oldMap.put(newListobj0.Id,newListobj0);
        oldMap.put(newListobj1.Id,newListobj1);
        oldMap.put(newListobj2.Id,newListobj2);
        oldMap.put(newListobj3.Id,newListobj3);
        
        newListobj0.Status__c='Complete';
        newListobj0.Deadline__c=Date.newInstance(2020,10, 28);
        newListobj1.Status__c='Complete';
        newListobj1.Deadline__c=Date.newInstance(2020,10, 28);
        newListobj2.Status__c='Complete';
        newListobj2.Deadline__c=Date.newInstance(2020,10, 28);
        newListobj3.Status__c='Complete';
        newListobj3.Deadline__c=Date.newInstance(2020,10, 28);
        
        List<Milestone__c> newUpdateList = new List<Milestone__c> ();
        newUpdateList.add(newListobj0);
        newUpdateList.add(newListobj1);
        newUpdateList.add(newListobj2);
        newUpdateList.add(newListobj3);
        update newUpdateList;
        
        List<Milestone__c> newList = new List<Milestone__c> ();
        newList.add(newListobj0);
        newList.add(newListobj1);
        newList.add(newListobj2);
        newList.add(newListobj3);
         
        
        GuidanceQuestionTriggerHandler.onAfterUpdate( newList, oldMap);
        System.assertEquals('Complete', newListobj3.Status__c);
    }
    
}