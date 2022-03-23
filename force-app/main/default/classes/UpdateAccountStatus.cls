global class UpdateAccountStatus implements Database.Batchable<sObject>, Database.Stateful {
    
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0; 
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        string query = 'select Id,Status__c, (select Id,Last_SAP_Updated__c from Metrics__r where Metric_Type__c=\'Actuals-Primary (Current FY)\' OR Metric_Type__c=\'Actuals-Secondary (Current FY)\' ) from Account where Status__c=\'Active\'';
        return Database.getQueryLocator(
            query	        
        );
    }
    global void execute(Database.BatchableContext bc, List<Account> scope){        
        // process each batch of records 
        System.debug('List'+scope);
        
        List<Account> accUpdateList = new List<Account>();
        for (Account accs : scope) 
        {      
            Boolean flag=false;
            
            if(accs.Metrics__r!=null && accs.Metrics__r.size()==0){
                
                accUpdateList.add(accs); 
            }else{
                for (Metric__c mtr : accs.Metrics__r) { 
                    if(mtr.Last_SAP_Updated__c!=null) {
                    Integer dt1 = -(system.today()).daysBetween(Date.valueOf(mtr.Last_SAP_Updated__c));
                      System.debug('days:: '+dt1);  
                    if(dt1<60)
                    {  
                        flag=true;
                        break;
                    } 
                    }
                }  
                if(flag==false){
                    accUpdateList.add(accs); 
                }
            }
            // increment the instance member counter
            recordsProcessed = recordsProcessed + 1;     
            
        } 
        System.debug(recordsProcessed + ' records processed!');
            System.debug('Acc List'+accUpdateList);
            if(!accUpdateList.isEmpty()){
                for(Account acc:accUpdateList){
                    acc.Status__c='Inactive';
                }
                update accUpdateList;
            }
    }    
    global void finish(Database.BatchableContext bc){
        
    }    
}