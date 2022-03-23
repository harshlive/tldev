public class AccountPlanController {
    public class Plan{
        @AuraEnabled
        public String account{get; set;}
        @AuraEnabled
        public String user{get; set;}
        @AuraEnabled
        public String month{get; set;}
        @AuraEnabled
        public Integer year{get; set;}
        @AuraEnabled
        public String pName{get; set;}
        @AuraEnabled
        public Integer pVal{get; set;}
    }
    @AuraEnabled
    public static void createRecords(List<Plan> planLst) {
        Set<String> accIDs = new Set<String>();
        Set<String> userIDs = new Set<String>();
        Set<String> months = new Set<String>();
        Set<Integer> years = new Set<Integer>();
        Set<String> products = new Set<String>();
        Map<String,Daily_Deployment__c> depsMap = new Map<String,Daily_Deployment__c>();
        Map<String,String> accIdMap = new Map<String,String>();
        Map<String,String> userIdMap = new Map<String,String>();
        List<Daily_Deployment__c> deps = new List<Daily_Deployment__c>();
        Map<String,List<String>> dependentPicklistValuesMap = DailyReportingController.getDependentPicklistValues(Daily_Deployment__c.Product_Name__c);
        
        Map<String,String> pickValMap = new Map<String,String>();
        for(String key : dependentPicklistValuesMap.keySet()) {
            for(String elem : dependentPicklistValuesMap.get(key)) {
                pickValMap.put(elem,key);
            }
        }
        for(Plan pln : planLst) {
            accIDs.add(pln.account);
            userIDs.add(pln.user);
            months.add(pln.month);
            years.add(pln.year);
            products.add(pln.pName);
        }
        system.debug(accIDs);
        for(Account acc : [SELECT Id,Account_ID__c FROM Account WHERE Account_ID__c IN : accIDs]) {
            accIdMap.put(acc.Account_ID__c,acc.Id);
        }
        for(User usr : [SELECT Id,Employee_Id__c FROM User WHERE Employee_Id__c IN : userIDs]) {
            userIdMap.put(usr.Employee_Id__c,usr.Id);
        }
        List<Daily_Deployment__c> depLst = [SELECT Id,Account__r.Account_ID__c,User__r.Employee_Id__c,Month__c,Year__c,Product_Name__c ,Product_Family__c
                                            FROM Daily_Deployment__c WHERE Account__r.Account_ID__c IN : accIDs AND 
                                            User__r.Employee_Id__c IN : userIDs AND Month__c IN : months AND Year__c IN : years 
                                            AND (Product_Name__c IN : products OR Product_Family__c IN : products) AND Deployment_Type__c = 'Target'];
        for(Daily_Deployment__c dep : depLst) {
            String key = '';
            if(dep.Product_Family__c != 'VA') {
                key = dep.Account__r.Account_ID__c + dep.User__r.Employee_Id__c + dep.Month__c + String.valueOf(dep.Year__c) + dep.Product_Name__c;
            }
            else if(dep.Product_Family__c == 'VA') {
                key = dep.Account__r.Account_ID__c + dep.User__r.Employee_Id__c + dep.Month__c + String.valueOf(dep.Year__c) + dep.Product_Family__c;
            }
            depsMap.put(key,dep);
        }
        for(Plan pln : planLst) {
            String key = pln.account + pln.user + pln.month + String.valueOf(pln.year) + pln.pName;
            Daily_Deployment__c dep = new Daily_Deployment__c();
            dep.Account__c = accIdMap.get(pln.account);
            dep.User__c = userIdMap.get(pln.user);
            dep.Month__c = pln.month;
            dep.Year__c = pln.year;
            dep.Deployment_Type__c = 'Target';
            dep.Week_4__c = pln.pVal != null ?pln.pVal : 0;
            if(pln.pName == 'VA') {
                dep.Product_Family__c = pln.pName;
            }
            else {
                dep.Product_Name__c = pln.pName;
                dep.Product_Family__c = pickValMap.get(pln.pName);
            }
            
            if(depsMap.containsKey(key)) {
                dep.Id = depsMap.get(key).Id;
            }
            deps.add(dep);
        }
        Database.upsert(deps);
    }
}