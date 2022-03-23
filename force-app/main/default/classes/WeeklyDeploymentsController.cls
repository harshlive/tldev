public class WeeklyDeploymentsController {
@AuraEnabled
    public static List<Daily_Deployment__c> fetchRecords(string user, string month,integer year) {
        List<Daily_Deployment__c> deploymentLst = new List<Daily_Deployment__c>();
        deploymentLst = [SELECT Year__c, Month__c, Week_1__c, Week_2__c, Week_3__c,Doctor__c, Doctor__r.Name,Product_Family__c,Product_Name__c,
                Week_4__c, Week_5__c, User__c, Account__c,Account__r.Name, Month_Total__c, Id,User__r.Name FROM Daily_Deployment__c
               WHERE Month__c =:month AND User__c =:user AND Year__c=:year AND deployment_Type__c = 'Actual' order by product_family__c];
        if(deploymentLst!= null && deploymentLst.size()>0) {
            return deploymentLst;
        }
        return null;
    }
}