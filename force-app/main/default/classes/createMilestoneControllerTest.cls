@isTest 
public class createMilestoneControllerTest {
    @isTest static void createRecordsTest() {
        Account acc = new Account(name = 'test Account');
        insert acc;
        List<Milestone_Master__c> mlist = new List<Milestone_Master__c>();
        Milestone_Master__c m1 = new Milestone_Master__c(name='test1',index__c=1);
        mlist.add(m1);
        Milestone_Master__c m2 = new Milestone_Master__c(name='test2',index__c=2);
        mlist.add(m2);
        insert mlist;
        List<Outcome_Master__c> olist = new List<Outcome_Master__c>();
        Outcome_Master__c o1 = new Outcome_Master__c(name='test1',index__c=1,Guidance_Question_Master__c=m1.id);
        olist.add(o1);
        Outcome_Master__c o2 = new Outcome_Master__c(name='test2',index__c=2,Guidance_Question_Master__c=m2.id);
        olist.add(o2);
        insert olist;
        createMilestoneController.createRecords( acc.Id); 
    }
}