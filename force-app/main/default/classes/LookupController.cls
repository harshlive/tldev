public without sharing class LookupController {
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String searchTerm, string myObject, String filter) {
        String myQuery = null;
        system.debug(filter);
        string fields = 'Id, Name';
        if(myObject == 'Product2') {
            fields = 'Id, Name';
        }
        if(filter != null && filter != ''){
            myQuery = 'Select '+fields+' from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND '+filter+' LIMIT  5';
        }
        else {
            if(searchTerm == null || searchTerm == ''){
                myQuery = 'Select '+fields+' from '+myObject+' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5';
            }
            else {
                myQuery = 'Select '+fields+' from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' LIMIT  5';
            }
        }
        List<sObject> lookUpList = database.query(myQuery);
        return lookUpList;
    }
    @AuraEnabled(cacheable=true)
    public static List<Account> searchTeamAccounts(String searchTerm) {
        Set<String> uniqueAccIdSet = new Set<String>();
        String teamQuery = 'SELECT Id,Name FROM account WHERE Name Like  \'%'+searchTerm+ '%\' AND Id IN (SELECT accountId FROM accountteammember WHERE UserId = '+'\''+UserInfo.getUserId()+'\''+')';
        String ownerQuery = 'SELECT Id,Name FROM account WHERE Name Like  \'%'+searchTerm+ '%\' AND ownerid = '+'\'' + UserInfo.getUserId()+'\'';
        List<User> userLst = [SELECT id from user where managerid =:userinfo.getUserId()];
        Set<string> userIdSet = new Set<String>();
        for(user u:userLst) {
            userIdSet.add(u.id);
        }
        string keyword = '%'+searchTerm+'%';
        String reporteeOwnedQuery = 'SELECT Id,Name FROM account WHERE Name Like  \'%'+searchTerm+ '%\' AND ownerid in '+'\'' + UserInfo.getUserId()+'\'';
        List<Account> teamAccountList = database.query(teamQuery);
        List<Account> ownedAccountList = database.query(ownerQuery);
        List<Account> reporteeOwnedAccountList = [SELECT id,Name from account where name like :keyword and ownerid in :userIdSet];
        List<Account> finalList = new List<Account>();
        finalList.addAll(teamAccountList);
        finalList.addAll(ownedAccountList);
        finalList.addAll(reporteeOwnedAccountList);
        for(Account acc : finalList) {
            uniqueAccIdSet.add(acc.id);
        }
        
        return [SELECT Id,Name FROM account WHERE id in :uniqueAccIdSet];
    }
}