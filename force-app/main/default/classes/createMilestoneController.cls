public class createMilestoneController {
    static final string ACTIVE_STATUS = 'Active';
    static final string INACTIVE_STATUS = 'Inactive';
    @AuraEnabled
    public static string createRecords(string accountId) {
        List<Milestone_Master__c> GA_MasterLst = new List< Milestone_Master__c>();
        List<Milestone__c> GA_Lst = new List<Milestone__c>();
        Set<Id> GA_Master_IDSet = new Set<Id>();
        List<Outcome_master__c> outcomeMasterLst = new List<Outcome_master__c>();
        List<Outcome__c> outcomeLst = new List<Outcome__c>();
        Map<Id,Milestone__c> GA_MasterIdMap = new Map<Id,Milestone__c>();
        Set<string> milestoneNameSet = new Set<string>();
        List<Milestone__c> existingMilestonesList = new List<Milestone__c>();
        List<Outcome__c> existingOutcomesList = new List<Outcome__c>();
        
        Account acc = [SELECT id,Status__c	FROM Account WHERE id = : accountId ];
        if(acc != null) {
            existingMilestonesList = [SELECT Id,Name FROM Milestone__c WHERE Account__c = :acc.id];
            if(existingMilestonesList.size()>0) {
                for(Milestone__c rec: existingMilestonesList) {
                    milestoneNameSet.add(rec.Name);
                }
            }
            GA_Lst = getMilestoneRecords(acc,milestoneNameSet);
        }
        existingOutcomesList = [SELECT Id,Outcome_Name__c FROM Outcome__c WHERE Account__c = :acc.id];
        Map<String,Outcome__c> outcomeMap = new Map<String,Outcome__c>();
        for(Outcome__c oc : existingOutcomesList) {
            outcomeMap.put(oc.Outcome_Name__c,oc);
        }
        List<Milestone__c> allMilestones = [SELECT Id,Name FROM Milestone__c WHERE Account__c = :acc.id];
        Map<string,Milestone__c> milestoneMap = new Map<string,Milestone__c>();
        for(Milestone__c ms : allMilestones) {
            milestoneMap.put(ms.name,ms);
        }
        outcomeMasterLst = [SELECT Id, Name,Guidance_Question_Master__r.Name  FROM Outcome_master__c];
        for(Outcome_master__c outcomeMaster : outcomeMasterLst) {
            if(!outcomeMap.containsKey(outcomeMaster.Name)) {
                Outcome__c outRec = new Outcome__c();
                outRec.Outcome_Name__c = outcomeMaster.name;
                outRec.Description__c = outcomeMaster.name;
                outRec.Outcome_Master__c = outcomeMaster.Id;
                outRec.Status__c = 'Not Started';
                outRec.Milestone__c = milestoneMap.get(outcomeMaster.Guidance_Question_Master__r.Name).Id;
                outRec.Account__c = acc.id;
                outcomeLst.add(outRec);
            }
        }
        if(outcomeLst.size()>0) {
            system.debug(outcomeLst);
            insert outcomeLst; 
        }
        /*if(GA_Lst.size()>0) {
for(Milestone__c gaRec : GA_Lst ) {
GA_Master_IDSet.add(gaRec.Milestone_Master__c);
GA_MasterIdMap.put(gaRec.Milestone_Master__c,gaRec);
}
}
        if(GA_Master_IDSet.size()>0) {
        outcomeMasterLst = [SELECT Id, Name, Guidance_Question_Master__c  FROM Outcome_master__c WHERE Guidance_Question_Master__c  in : GA_Master_IDSet];
        }
        if(outcomeMasterLst.size()>0) {
        
        for(Outcome_master__c outcomeMaster : outcomeMasterLst) {
        Outcome__c outRec = new Outcome__c();
        outRec.Outcome_Name__c = outcomeMaster.name;
        outRec.Description__c = outcomeMaster.name;
        outRec.Outcome_Master__c = outcomeMaster.Id;
        outRec.Status__c = 'Not Started';
        //outRec.Start_Date__c = system.today();
        //outRec.Due_Date__c = system.today();
        outRec.Milestone__c = GA_MasterIdMap.get(outcomeMaster.Guidance_Question_Master__c).Id;
        outRec.Account__c = GA_MasterIdMap.get(outcomeMaster.Guidance_Question_Master__c).Account__c;
        outcomeLst.add(outRec);
        }
        }
        if(outcomeLst.size()>0) {
system.debug(outcomeLst);
insert outcomeLst; 
}*/
        if(GA_Lst.size()>0) {
            return 'Guided Questions and Outcomes updated successfully.';
        }
        else {
            return 'All Guided Questions already Present.';
        }
    }
    public static List<Milestone__c> getMilestoneRecords(Account acc, Set<string> milestoneNameSet) {
        List<Milestone__c> GA_Lst = new List<Milestone__c>();
        List<Milestone_Master__c> GA_MasterLst = new List< Milestone_Master__c>();
        
        GA_MasterLst = [SELECT Id,Name FROM Milestone_Master__c WHERE Index__c<> NULL];
        for(Milestone_Master__c GA_Rec : GA_MasterLst) {
            if(! milestoneNameSet.contains(GA_Rec.Name)) {
                Milestone__c rec = new Milestone__c();
                rec.Name = GA_Rec.Name;
                rec.Milestone_Master__c = GA_Rec.Id;
                rec.Status__c = 'Not Started';
                rec.Account__c = acc.Id;
                GA_Lst.add(rec);
            }
        }
        insert GA_Lst;
        system.debug(GA_Lst);
        return GA_Lst;
    }
}