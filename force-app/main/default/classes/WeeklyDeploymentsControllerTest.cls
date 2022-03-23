@isTest
public class WeeklyDeploymentsControllerTest {
    @isTest 
    public static void fetchRecordsTest() {
        Daily_Deployment__c rec = new Daily_Deployment__c();
        Account acc = new Account(accountnumber='HO-18983',name='Aster MIMS');
        insert acc;
        rec.Account__c = acc.id;
        rec.user__c = userinfo.getUserId();
        //rec.name = 'Test';
        rec.Year__c = 2021;
        rec.Week_1__c = 10;
        rec.Week_2__c = 10;
        rec.Week_3__c = 10;
        rec.Week_4__c = 10;
        rec.Week_5__c = 10;
        rec.Month__c = 'January';
        insert rec;
        WeeklyDeploymentsController.fetchRecords(userinfo.getUserId(), 'January', 2021);
        
    }
}