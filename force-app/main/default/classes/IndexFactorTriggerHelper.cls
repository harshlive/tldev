public class IndexFactorTriggerHelper {
    static final string TARGET_CURRENT = 'Target (Current FY)';
    
    public static void updateTargets(List<Index_Factor__c> indexList,Map<Id,Index_Factor__c> oldIndexMap) {
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> metricIdSet = new Set<Id>();
        set<string> stateSet = new Set<string>();
        set<string> fySet = new Set<string>();
        
        List<Account> accList = new List<Account>();
        List<metric__c> metricsList = new List<metric__c>();
        List<metric__c> metricsToUpdateList = new List<metric__c>();
        
        for (Index_Factor__c index: indexList) {
            if(index.Q1_Index__c != 0 || index.Q2_Index__c != 0 || index.Q3_Index__c != 0 ||index.Q4_Index__c != 0 ) {
                stateSet.add(index.State__c);
                fySet.add(index.Fiscal_Year__c);
            }
        }
        system.debug(stateSet);
        system.debug(fySet);
        if(stateSet.size()>0) {
            accList = [SELECT Id, Name, Stents_Per_Month_Potential__c  FROM Account WHERE billingstate in :stateSet];
            system.debug([SELECT Id, Name, billingstate  FROM Account]);
        }
        system.debug(accList);
        
        if(accList.size()>0) {
            for(Account acc : accList) {
                accountIdSet.add(acc.Id);
            }
            
        }
        if(accountIdSet.size()>0) {
            metricsList = [SELECT id,account__c,account__r.billingstate,Fiscal_Year__c,product__c,product__r.Name,Metric_Type__c,JAN__c,FEB__c,MAR__c,APR__c,MAY__c,
                           JUN__c,JUL__c,AUG__c,SEP__c,OCT__c,NOV__c,DEC__c FROM Metric__c
                           WHERE account__c in :accountIdSet AND Fiscal_Year__c in : fySet 
                           AND Metric_Type__c =: TARGET_CURRENT];
        }
        
        if(metricsList.size()>0) {
            for(Index_Factor__c index: indexList) {
                for(metric__c targetRecord :  metricsList) {
                    system.debug(index.State__c);
                    system.debug(targetRecord.account__r.billingstate);
                    system.debug(index.Fiscal_Year__c);
                    system.debug(targetRecord.Fiscal_Year__c);
                    if(index.State__c == targetRecord.account__r.billingstate && index.Fiscal_Year__c == targetRecord.Fiscal_Year__c) {
                        if(oldIndexMap.get(index.Id).Q1_Index__c != index.Q1_Index__c) {
                            targetRecord.APR__c = Math.round(targetRecord.APR__c - targetRecord.APR__c*index.Q1_Index__c/100);
                            targetRecord.MAY__c = Math.round(targetRecord.MAY__c - targetRecord.MAY__c*index.Q1_Index__c/100);
                            targetRecord.JUN__c = Math.round(targetRecord.JUN__c - targetRecord.JUN__c*index.Q1_Index__c/100);
                        }
                        if(oldIndexMap.get(index.Id).Q2_Index__c != index.Q2_Index__c) {
                            targetRecord.JUL__c = Math.round(targetRecord.JUL__c - targetRecord.JUL__c*index.Q2_Index__c/100);
                            targetRecord.AUG__c = Math.round(targetRecord.AUG__c - targetRecord.AUG__c*index.Q2_Index__c/100);
                            targetRecord.SEP__c = Math.round(targetRecord.SEP__c - targetRecord.SEP__c*index.Q2_Index__c/100);
                        }
                        if(oldIndexMap.get(index.Id).Q3_Index__c != index.Q3_Index__c) {
                            targetRecord.OCT__c = Math.round(targetRecord.OCT__c - targetRecord.OCT__c*index.Q3_Index__c/100);
                            targetRecord.NOV__c = Math.round(targetRecord.NOV__c - targetRecord.NOV__c*index.Q3_Index__c/100);
                            targetRecord.DEC__c = Math.round(targetRecord.DEC__c - targetRecord.DEC__c*index.Q3_Index__c/100);
                        }
                        if(oldIndexMap.get(index.Id).Q4_Index__c != index.Q4_Index__c) {
                            targetRecord.JAN__c = Math.round(targetRecord.JAN__c - targetRecord.JAN__c*index.Q4_Index__c/100);
                            targetRecord.FEB__c = Math.round(targetRecord.FEB__c - targetRecord.FEB__c*index.Q4_Index__c/100);
                            targetRecord.MAR__c = Math.round(targetRecord.MAR__c - targetRecord.MAR__c*index.Q4_Index__c/100);
                        }
                        metricsToUpdateList.add(targetRecord);
                    }
                }
            }
            system.debug(metricsToUpdateList);
            update metricsToUpdateList;
        }
    }
}