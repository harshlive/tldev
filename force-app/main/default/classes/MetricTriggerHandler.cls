public class MetricTriggerHandler {
    
    public static void onBeforeInsert(List<Metric__c> newList){
        set<Id> accIds=new set<Id>();
        for(Metric__c mm:newList){
            if(mm.Account__c!=null){
                accIds.add(mm.Account__c);
            }
        }
        
        List<Account> accList=[select Id,Name,OwnerId,BillingState from Account where Id in :accIds];
        map<String,Account> accMap=new map<String,Account>();
        for(Account acc:accList){
            accMap.put(acc.Id,acc);
        }
        for(Metric__c mm:newList){
            if(mm.Account__c!=null){
                mm.User__c=accMap.get(mm.Account__c).OwnerId;
                mm.OwnerId=accMap.get(mm.Account__c).OwnerId;
                mm.State__c=accMap.get(mm.Account__c).BillingState;
            }
            
        } 
    }
    
    public static void onAfterInsert(List<Metric__c> metricList){  
        System.debug('After Insert');
        map<Id,Account> accUpdateMap=new map<Id,Account>();
        
        set<Id> accIds=new set<Id>();
        set<Id> productIds=new set<Id>();
        for(Metric__c mm:metricList){
            if(mm.Q1__c!=0 || mm.Q2__c!=0 || mm.Q3__c!=0 || mm.Q4__c!=0 ){
                if(mm.Product__c!=null){               
                    accIds.add(mm.Account__c);
                    productIds.add(mm.Product__c);     
                }
            }            
        }
        List<Account> accList=[SELECT Id,Non_Premium_Stent__c, Premium_Stent__c, IVL__c, OPN__c, VA__c, Nic_Nano__c, Balloon__c,  Name 
                               FROM Account where Id in :accIds];
        map<Id,Account> accMap=new map<Id,Account>();
        for(Account acc:accList){
            accMap.put(acc.Id, acc);
        }
        map<Id,Product2> prdMap=new map<Id,Product2>();
        List<Product2> productList=[select Id,Name,Category__c,Family 
                                    from Product2 where Id in :productIds];
        for(Product2 pd:productList){
            prdMap.put(pd.Id,pd);
        }
        
        for(Metric__c met:metricList){
            System.debug('IN new Metriclist');
            if(met.Product__c!=null){
                Account acc=accMap.get(met.Account__c);
                if(acc != null) {
                    System.debug('After acc not null');
                    system.debug(met.Product__c);
                    system.debug(prdMap.get(met.Product__c));
                    if(prdMap.get(met.Product__c) != null) {
                        if(prdMap.get(met.Product__c).Category__c==System.Label.Premium_Stent ){
                            System.debug('in active premium');
                            acc.Premium_Stent__c=true;
                            acc.Stent_Status__c='Active';
                        }else if(prdMap.get(met.Product__c).Category__c==System.Label.Non_Premium_Stent ){
                            System.debug('in active non premium');
                            acc.Non_Premium_Stent__c=true;
                            acc.Stent_Status__c='Active';
                        }else if(prdMap.get(met.Product__c).Category__c==System.Label.IVL ){
                            acc.IVL__c=true;
                        }else if(prdMap.get(met.Product__c).Category__c==System.Label.VA ){
                            acc.VA__c=true;
                        }else if(prdMap.get(met.Product__c).Category__c==System.Label.OPN ){
                            acc.OPN__c=true;
                        }else if(prdMap.get(met.Product__c).Category__c==System.Label.Balloon ){
                            acc.Balloon__c=true;
                        }else if(prdMap.get(met.Product__c).Category__c==System.Label.Nic_Nano ){
                            acc.Nic_Nano__c=true;
                        }
                    }
                    accUpdateMap.put(acc.Id,acc); 
                }
            }            
        }
        
        if(!accUpdateMap.isEmpty()){
            update accUpdateMap.Values();
        } 
        
    }
    public static void onAfterUpdate(List<Metric__c> metricList,map<Id,Metric__c> oldMap){
        set<Id> metricIds=new set<Id>();
        List<Metric__c> metricChkList=new List<Metric__c>(); 
        List<Metric__c> updateUserList=new List<Metric__c>();
        for(Metric__c me:metricList){
            if(me.User__c!=oldMap.get(me.Id).User__c){
                updateUserList.add(me);
            }
            if(me.Last_SAP_Updated__c!=oldMap.get(me.Id).Last_SAP_Updated__c && 
               me.Metric_Type__c=='Actuals-Primary (Current FY)'){
                   metricIds.add(me.Account__c);
               }
            if(me.Q1__c!=oldMap.get(me.Id).Q1__c || me.Q2__c!=oldMap.get(me.Id).Q2__c || 
               me.Q3__c!=oldMap.get(me.Id).Q3__c || me.Q4__c!=oldMap.get(me.Id).Q4__c){
                   metricChkList.add(me);
               }
        }
        //change checkbox list on Account
        if(!metricChkList.isEmpty()){
            MetricTriggerHandler.onAfterInsert(metricChkList);
        }
        if(!metricIds.isEmpty()){
            List<Account> accList=[select Id,Status__c from Account where Id in :metricIds];
            for(Account acc:accList){
                if(acc.Status__c=='Inactive'){
                    acc.Status__c='Active';
                }
            }  
            update accList;          
        }
        if(!updateUserList.isEmpty()){
            MetricTriggerHelper.metricOwnerPopulate(updateUserList);
        }
    }
}