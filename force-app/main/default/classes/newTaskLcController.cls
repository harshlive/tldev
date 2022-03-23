public class newTaskLcController {
@AuraEnabled 
    public static Account getAccount(String recordId) {
        Outcome__c oc = [SELECT id,account__c FROM outcome__c where id = :recordId LIMIT 1];
        Account acc = [SELECT Id,Name from Account where id = :oc.account__c LIMIT 1];
        return acc;
    } 
}