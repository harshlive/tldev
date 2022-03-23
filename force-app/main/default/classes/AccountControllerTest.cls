@isTest 
public class AccountControllerTest {
    
    @isTest
    public static void method1(){
        List<Account> accList=new List<Account>();
        Account a1=new Account();
        a1.Name='test1';
        // a1.AccountNumber='ho1010';
        a1.ownerId=UserInfo.getUserId();
        accList.add(a1);
        Account a2=new Account();
        a2.Name='test12';
        // a2.AccountNumber='ho10102';
        accList.add(a2);
        Account a3=new Account();
        a3.Name='test13';
        // a3.AccountNumber='ho10103';
        accList.add(a3);
        insert accList;
        AccountTeamMember atm=new AccountTeamMember();
        atm.AccountId=a3.Id;
        atm.UserId=UserInfo.getUserId();
        insert atm;
        AccountTeamMember atm1=new AccountTeamMember();
        atm1.AccountId=a2.Id;
        atm1.UserId=UserInfo.getUserId();
        insert atm1;
        AccountController.fetchAccounts(UserInfo.getUserId());
    }
    
  
    
    @isTest
    static void method2() {
        List<account> accList=new List<Account>();
        List<account> updateAccList=new List<Account>();
        Account a1=new Account();
        a1.Name='test1';
        a1.AccountNumber='ho1010';
        accList.add(a1);
        insert accList;
        for(account acc: accList){
            acc.Id = accList[0].Id;
            acc.Critical_Success_Factor_for_Aim__c='Price Revision';
            acc.Action_Plan_for_account__c='abcd';
            acc.Critical_Account__c=true;
            acc.Aim_in_Account__c='Retain';
            acc.Account_Dynamics__c='sdgh';
            acc.Deadline_for_action__c=system.today();
            acc.Is_Account_at_Risk__c=true;
            acc.Reason_for_account_being_at_risk__c='Price Correction';
            acc.Product_Category__c='DES';
            updateAccList.add(acc);
        }
        AccountController.saveAccountLWC(updateAccList);
    }
}