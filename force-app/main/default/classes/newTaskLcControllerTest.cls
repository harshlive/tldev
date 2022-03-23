@isTest 
public class newTaskLcControllerTest {
    @isTest
    static void createRecordsTest() {
        Account acc = new Account(name = 'test Account');
        insert acc;
        Milestone__c m1 = new Milestone__c(name='test1',account__c= acc.id);
        insert m1;
        Outcome__c o1 = new Outcome__c(Milestone__c =m1.id,account__c = acc.id,status__c = 'Not Started');
        insert o1;
        newTaskLcController.getAccount(o1.id);
    }
}