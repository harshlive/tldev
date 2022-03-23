@isTest 
public class AccountTriggerHandlerTest {

    @isTest static void onAfterInsertTest() {
        Account a1=new Account();
        a1.Name='test1';
        a1.AccountNumber='ho1010';
        Account a2=new Account();
        a2.Name='test12';
        a2.AccountNumber='ho10102';
        Account a3=new Account();
        a3.Name='test13';
        a3.AccountNumber='ho10103';
        List<Account> accList=new List<Account>();
        accList.add(a1);
        accList.add(a2);
        accList.add(a3);
        insert accList;
        AccountTriggerHandler.onAfterInsert(accList);
        
    }
     @isTest static void onAfterUpdateTest() {
        Account a1=new Account();
        a1.Name='test1';
        a1.AccountNumber='ho1010';
        Account a2=new Account();
        a2.Name='test12';
        a2.AccountNumber='ho10102';
        Account a3=new Account();
        a3.Name='test13';
        a3.AccountNumber='ho10103';
        insert a1;
         insert a2;
         insert a3;
         
         map<Id,Account> oldMap=new map<Id,Account>();
         oldMap.put(a1.Id,a1);
         oldMap.put(a2.Id,a2);
         oldMap.put(a3.Id,a3);
         
         List<Account> accList=new List<Account>();
         a1.AccountNumber='';
         a1.AccountNumber='tt4';
         a3.AccountNumber='123456789';
         
        accList.add(a1);
        accList.add(a2);
        accList.add(a3);
        update accList;
         
         AccountTriggerHandler.onAfterUpdate(accList, oldMap);
        
        
    }
}