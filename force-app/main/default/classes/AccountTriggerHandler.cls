public class AccountTriggerHandler {
    
    public static void onAfterInsert(List<Account> newList){
        
        List<Account> updateList=new List<Account>();
        set<Id> accIds=new set<Id>();
        for(Account acc:newList){
            if(acc.AccountNumber!=null){
				accIds.add(acc.Id);
            }
        }
        if(!accIds.isEmpty()){
            List<Account> accList=[select Id,Account_ID__c,AccountNumber from Account where Id in :accIds];
            
            for(Account acc:accList){
                if(acc.AccountNumber!=null){
                    acc.Account_ID__c=acc.AccountNumber;
                    updateList.add(acc);
                }
            }
        }
        if(!updateList.isEmpty()){
            update updateList;
        }
        
    }
    public static void onAfterUpdate(List<Account> newList,map<Id,Account> oldMap){
        List<Account> updateList=new List<Account>();
        set<Id> accIds=new set<Id>();
        for(Account acc:newList){
            
            if(acc.AccountNumber!=oldMap.get(acc.Id).AccountNumber && acc.AccountNumber!=null ){
                accIds.add(acc.Id);
            }
        }
        if(!accIds.isEmpty()){
            List<Account> accList=[select Id,Account_ID__c,AccountNumber from Account where Id in :accIds];
            
            for(Account acc:accList){
                if(acc.AccountNumber!=oldMap.get(acc.Id).AccountNumber && acc.AccountNumber!=null){
                    acc.Account_ID__c=acc.AccountNumber;
                    updateList.add(acc);
                }
            }
        }
        
        if(!updateList.isEmpty()){
            update updateList;
        }
    }
}