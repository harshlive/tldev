global class BatchGuidedQuestion implements    Database.Batchable<Sobject> 
{
    global integer count = 0;
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator([select Id,Name,(Select Id,Name from Milestones__r) from Account 
                                         where Id NOT IN (Select Account__c from Milestone__c)]);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope)
    {
            
        for(Account acc:scope){
            count++;
            System.debug('count:' + count);
            createMilestoneController.createRecords(acc.Id);
        }
    }    

    global void finish(Database.BatchableContext bc){
        System.debug('count:' + count);
         
    
    }    
}