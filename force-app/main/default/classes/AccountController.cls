public with sharing class AccountController {

    
    @AuraEnabled(cacheable=true)
    public static List<Account> fetchAccounts(string userId) {
        Map<Id,Account> accMap= new Map<Id,Account>([
            SELECT  Id, Name, Critical_Account__c,Account_Dynamics__c,Aim_in_Account__c,Critical_Success_Factor_for_Aim__c,
            Action_Plan_for_account__c,Deadline_for_action__c,Is_Account_at_Risk__c,Product_Category__c,Account_ID__c,
            Reason_for_account_being_at_risk__c  FROM Account Where ownerId=:userId
        ]);
        List<AccountTeamMember> actAccounts=[select id ,UserId,AccountId from AccountTeamMember Where UserId =:userId];
        Set<Id> accIds=new Set<ID>();
        for(AccountTeamMember acc: actAccounts){
            accIds.add(acc.AccountId);
        }
        for(Account acc :[ SELECT  Id, Name, Critical_Account__c,Account_Dynamics__c,Aim_in_Account__c,Critical_Success_Factor_for_Aim__c,
            Action_Plan_for_account__c,Deadline_for_action__c,Is_Account_at_Risk__c,Product_Category__c,Account_ID__c,
            Reason_for_account_being_at_risk__c  FROM Account Where ID IN: accIds]){
                if(!accMap.containsKey(acc.Id)){
                   accMap.put(acc.Id,acc);
                }
            }
        return accMap.values();
    }

    
   
    @AuraEnabled
    public static void saveAccountLWC(List<Account> records){

        try{
            System.debug('records::'+records);
            if(records.size()>0 && records != null){
                List<Account> accList = new List<Account>();
                
                for(integer i = 0; i < records.size(); i++) {
                    System.debug('records: --'+records[i]);
                    Account acc = new Account();
                    acc.Id = records[i].Id;
                    acc.Critical_Success_Factor_for_Aim__c=records[i].Critical_Success_Factor_for_Aim__c;
                    acc.Action_Plan_for_account__c=records[i].Action_Plan_for_account__c; 
                    acc.Critical_Account__c=records[i].Critical_Account__c;  
                    acc.Aim_in_Account__c=records[i].Aim_in_Account__c;
                    acc.Account_Dynamics__c=records[i].Account_Dynamics__c;
                    acc.Deadline_for_action__c=records[i].Deadline_for_action__c;
                    acc.Is_Account_at_Risk__c=records[i].Is_Account_at_Risk__c;
                    acc.Reason_for_account_being_at_risk__c=records[i].Reason_for_account_being_at_risk__c;
                    acc.Product_Category__c=records[i].Product_Category__c;
                    accList.add(acc);
                }   
                if(!accList.isEmpty()){            
                    update accList;
                }          
            }
        }
        catch(Exception ex) {
            ErrorLogger.LogError('AccountController:saveAccountLWC', 'Apex Class', ex.getMessage(), ex.getStackTraceString(), '', 'Tasks:'+records,  '');
            throw new AuraException(ex.getMessage());
        } 

    }
     

}