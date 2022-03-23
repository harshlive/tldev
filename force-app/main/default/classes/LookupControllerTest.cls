@isTest
public class LookupControllerTest {
    @isTest static void searchTest() {
        Account acc = new Account(name = 'test Account',billingstate='Jharkhand',Stents_Per_Month_Potential__c=200);
        insert acc;
        LookupController.search('test', 'account', null);
        LookupController.search(null, 'account', null);
        LookupController.search('test', 'account','Stents_Per_Month_Potential__c=200');
    }
    @isTest static void searchTeamAccountsTest() {
        Account acc = new Account(name = 'test Account',billingstate='Jharkhand',Stents_Per_Month_Potential__c=200);
        insert acc;
        LookupController.searchTeamAccounts('test');
        LookupController.searchTeamAccounts(null);
        LookupController.searchTeamAccounts('test');
    }
}