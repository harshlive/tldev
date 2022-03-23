public class GuidanceQuestionTriggerHandler {
    
    public static void onAfterUpdate(List<Milestone__c> newList,Map<Id,Milestone__c> oldMap){
        set<Id> accIds=new set<Id>();
        set<Id> milestoneIds=new set<Id>(); 
        map<Id,Account> accUpdateMap=new map<Id,Account>();
        
        for(Milestone__c mile:newList){
            if(mile.Status__c!=oldMap.get(mile.Id).Status__c&&mile.Status__c=='Complete'){
                accIds.add(mile.Account__c);
                milestoneIds.add(mile.Id);
            }
        }
        List<Account> accList=[select Id,Milestone__c from Account where Id in :accIds];
        List<Milestone__c> mileList=[select Id,Account__c,Index__c from Milestone__c where Id in :milestoneIds];
        map<Id,Account> accMap=new map<Id,Account>();
        List<Account_Milestone__mdt> acc_mdt=[SELECT Id, Label, Index__c FROM Account_Milestone__mdt];
        map<Decimal,String> accmdtMap=new map<Decimal,String>();
        for(Account_Milestone__mdt accmdt:acc_mdt){
            Decimal index=accmdt.Index__c;
            index=math.floor(index);                
            accmdtMap.put(  index,accmdt.Label);
        }
        
        for(Account acc:accList){
            accMap.put(acc.Id,acc);
        }
        
        for(Milestone__c mil:mileList){
            Account accUpdate=accMap.get(mil.Account__c);
            if(mil.Index__c=='1'){
                accUpdate.Milestone__c=accmdtMap.get(2);
            }else if(mil.Index__c=='2'){
                accUpdate.Milestone__c=accmdtMap.get(3);
            }else if(mil.Index__c=='3'){
                accUpdate.Milestone__c=accmdtMap.get(4);
            }else if(mil.Index__c=='4'){
                accUpdate.Milestone__c=accmdtMap.get(5);
            }   
            accUpdateMap.put(accUpdate.Id,accUpdate);
        }
        if(!accUpdateMap.isEmpty()){
            update accUpdateMap.Values();
        } 
        
    }
    public static void updateDatesBasedOnStatus(Map<Id,Milestone__c> newMap,Map<Id,Milestone__c> oldMap) {
        system.debug('inside handler method');
        set<Id> milestoneIdSet = oldMap.keySet();
        Map<Id,Integer> mileStoneVSWIPOutcomeCount = new Map<Id,Integer>();
        List<Outcome__c> outcomeLst = [SELECT Id,Milestone__c,Completion_Date__c,Due_Date__c,Status__c FROM outcome__c WHERE Milestone__c IN : milestoneIdSet];
        for(Outcome__c rec : outcomeLst) {
            if(rec.Status__c != 'Complete' && rec.Status__c != 'Not Applicable' && newMap.get(rec.Milestone__c).status__c == 'Complete') {
                    newMap.get(rec.Milestone__c).addError('Please complete all the outcomes before marking the Guided Question as Complete');
            }
            
        }
            
        
        for(Milestone__c m:newMap.values()) {
            system.debug(m.Status__c );
            system.debug(oldMap.get(m.Id).Status__c );
            if(m.Status__c != oldMap.get(m.Id).Status__c) {
                if(m.Status__c == 'In Progress') {
                    m.Start_Date__c = system.today();
                }
                else if(m.Status__c == 'Complete') {
                    m.Completion_Date__c = system.today();
                }
            }
        }
    }
    public static void updatesDatesOnOutcome(Map<Id,Milestone__c> newMap,Map<Id,Milestone__c> oldMap) {
        set<Id> milestoneIdSet = newMap.keySet();
        List<Outcome__c> outcomeLst = [SELECT Id,Milestone__c,Completion_Date__c,Due_Date__c,Status__c FROM outcome__c WHERE Milestone__c IN : milestoneIdSet];
        if(outcomeLst.size()>0) {
            for(Outcome__c rec : outcomeLst) {
                if(newMap.containsKey(rec.Milestone__c) ) {
                    if(newMap.get(rec.Milestone__c).Deadline__c != oldMap.get(rec.Milestone__c).Deadline__c)
                        rec.Due_Date__c = newMap.get(rec.Milestone__c).Deadline__c;
                }
            }
            update outcomeLst;
        }
        
    }
}