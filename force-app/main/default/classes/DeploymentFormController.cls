/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-25-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class DeploymentFormController {

    @AuraEnabled
    public static String  saveDeployments(List<Daily_Deployment__c> depList){
        system.debug(depList);
        for(Daily_Deployment__c ddy:depList){
            ddy.User__c=UserInfo.getUserId();
            ddy.Deployment_Type__c = 'Actual';
        }
        upsert depList;
        return 'Success';
        
    }
    
    @AuraEnabled
    public static Map<String,Daily_Deployment__c>  getVaDeployments(String accId,Integer year,String month){
        Id userId=UserInfo.getUserId();
        Map<String,List<String>> dependentPicklistValuesMap = DailyReportingController.getDependentPicklistValues(Daily_Deployment__c.Product_Name__c);
        
        List<Daily_Deployment__c> dplyList=[SELECT Id, OwnerId, Name, CreatedDate, Week_1__c, Week_2__c, Week_3__c, Week_4__c, 
                                            Week_5__c, Year__c, Month__c, Doctor__c, Product_Family__c, Product_Name__c, Product_Category__c, 
                                            Account__c, Month_Total__c 
                                            FROM Daily_Deployment__c where User__c=:userId AND Product_Family__c='VA'AND Product_Name__c!=null AND Account__c=:accId 
                                            AND Month__c=:month AND Year__c=:year AND Deployment_Type__c = 'Actual'];
        
        Map<String,Daily_Deployment__c> dplyMap=new Map<String,Daily_Deployment__c>();
        for(Daily_Deployment__c dply: dplyList){
            dplyMap.put(dply.Product_Name__c,dply);
        }
        
        Map<String,Daily_Deployment__c> vaMap=new Map<String,Daily_Deployment__c>();
        
        for(String prdFam:dependentPicklistValuesMap.keyset()){
            if(prdFam!='VA'){
                continue;
            }
            List<String> prdList=dependentPicklistValuesMap.get(prdFam); 
            for(String prdName:prdList){ 
                
                if(dplyMap.get(prdName)==null){ 
                    Daily_Deployment__c ddy=new Daily_Deployment__c();
                    ddy.Month__c=month;
                    ddy.Product_Family__c=prdFam;
                    ddy.Product_Name__c=prdName;
                    ddy.Year__c=year;
                    ddy.Week_1__c=0;
                    ddy.Week_2__c=0;
                    ddy.Week_3__c=0;
                    ddy.Week_4__c=0;
                    ddy.Week_5__c=0; 
                    ddy.Account__c=accId; 
                    vaMap.put(prdName,ddy);
                }else{
                    vaMap.put(prdName,dplyMap.get(prdName));
                }
            }     
        } 
        return vaMap; 
    }
    
    
    
    
     @AuraEnabled
    public static List<Contact>  getContact(String accId){
        List<AccountContactRelation> acrLst = new List<AccountContactRelation>();
        acrLst = [SELECT ContactId FROM AccountContactRelation WHERE AccountId = : accId];
        Set<Id> conIds = new Set<Id>();
        for(AccountContactRelation acr : acrLst) {
            conIds.add(acr.ContactId);
        }
        List<Contact> conList=[SELECT Id,Name,AccountId from Contact where Id IN :conIds];
        return conList;
    }
    @AuraEnabled
    public static Map<String,Map<string,List<Daily_Deployment__c>>> getContactDetails(String accId,Integer year,String month){
        
        Id userId=UserInfo.getUserId();
        List<AccountContactRelation> acrLst = new List<AccountContactRelation>();
        acrLst = [SELECT ContactId FROM AccountContactRelation WHERE AccountId = : accId];
        Set<Id> conIds = new Set<Id>();
        for(AccountContactRelation acr : acrLst) {
            conIds.add(acr.ContactId);
        }
        List<Contact> conList=[SELECT Id,Name,AccountId from Contact where Id IN :conIds];
        Set<Id> docSet=new Set<Id>();
        for(Contact con:conList){
            docSet.add(con.Id);
        }
        
        Map<String,List<String>> dependentPicklistValuesMap = DailyReportingController.getDependentPicklistValues(Daily_Deployment__c.Product_Name__c);
        
        List<Daily_Deployment__c> dplyList=[SELECT Id,OwnerId, Name, CreatedDate, Week_1__c, Week_2__c, Week_3__c, Week_4__c, Week_5__c, Year__c, 
                                            Month__c, Doctor__c, Product_Family__c, Product_Name__c, Product_Category__c, Account__c, Month_Total__c 
                                            FROM Daily_Deployment__c where User__c=:userId AND Doctor__c in :docSet and Month__c=:month and Year__c=:year ];
        Map<String,Daily_Deployment__c> dplyMap=new Map<String,Daily_Deployment__c>();
        for(Daily_Deployment__c ddy:dplyList){
            dplyMap.put(ddy.Account__c +''+ddy.Doctor__c+ddy.Product_Name__c,ddy);
        }
        
        //DATA MAP
        Map<String,Map<String,List<Daily_Deployment__c>>> dataMap=new Map<String,Map<String,List<Daily_Deployment__c>>>();
        for(Id docId:docSet){
            Map<String,List<Daily_Deployment__c>> prdFamDplyMap=new Map<String,List<Daily_Deployment__c>>();
            
            List<Daily_Deployment__c> dpyMapLst=new List<Daily_Deployment__c>();
            
            for(String prdFam:dependentPicklistValuesMap.keyset()){
                if(prdFam=='VA'){
                    continue;
                }
                List<String> prdList=dependentPicklistValuesMap.get(prdFam); 
                for(String prdName:prdList){ 
                    
                    if(dplyMap.get(accId+docId+prdName)!=null){
                        dpyMapLst.add(dplyMap.get(accId+docId+prdName)); 
                    }else{
                        Daily_Deployment__c ddy=new Daily_Deployment__c();
                        ddy.Month__c=month;
                        ddy.Product_Family__c=prdFam;
                        ddy.Product_Name__c=prdName;
                        ddy.Year__c=year;
                        ddy.Week_1__c=0;
                        ddy.Week_2__c=0;
                        ddy.Week_3__c=0;
                        ddy.Week_4__c=0;
                        ddy.Week_5__c=0;
                        ddy.Doctor__c=docId;
                        ddy.Account__c=accId; 
                        dpyMapLst.add(ddy);
                    }
                }   
                
                prdFamDplyMap.put(prdFam,dpyMapLst);
                dpyMapLst=new List<Daily_Deployment__c>();
            }
            dataMap.put(docId,prdFamDplyMap);
            prdFamDplyMap=new Map<String,List<Daily_Deployment__c>>();
        }  
        
        //Contact Id-->product Name, list deployment
        Map<id,Map<string,List<Daily_Deployment__c>>> deploymentList=new Map<id,Map<string,List<Daily_Deployment__c>>>();
        return dataMap;
    }
    @AuraEnabled
    public static Response getDeployments(String accId,Integer year,String month){
        Id userId=UserInfo.getUserId();
        List<AccountContactRelation> acrLst = new List<AccountContactRelation>();
        acrLst = [SELECT ContactId FROM AccountContactRelation WHERE AccountId = : accId];
        Set<Id> conIds = new Set<Id>();
        for(AccountContactRelation acr : acrLst) {
            conIds.add(acr.ContactId);
        }
        List<Contact> conList=[SELECT Id,Name,AccountId from Contact where Id IN : conIds];
        Set<Id> docSet=new Set<Id>();
        for(Contact con:conList){
            docSet.add(con.Id);
        }
        
        Map<String,List<String>> dependentPicklistValuesMap = DailyReportingController.getDependentPicklistValues(Daily_Deployment__c.Product_Name__c);
        
        List<Daily_Deployment__c> dplyList=[SELECT Id, OwnerId, Name, CreatedDate, Week_1__c, Week_2__c, Week_3__c, Week_4__c, Year__c, 
                                            Month__c, Doctor__c, Product_Family__c, Product_Name__c, Product_Category__c, Account__c 
                                            FROM Daily_Deployment__c where User__c=:userId AND Doctor__c in :docSet and Month__c=:month 
                                            and Year__c=:year and account__c = : accId AND Deployment_Type__c = 'Actual'];
        
        return null;
        
    }
    public class Response{
        @AuraEnabled
        public String accountName{get; set;}
        @AuraEnabled
        public List<ProductFamily> ProductFamily{get; set;}
    }
    public class ProductFamily{
        @AuraEnabled
        public String Name{get; set;}
        @AuraEnabled
        public List<ProductsArray> ProductsArray{get; set;}
    }
    public class ProductsArray{
        @AuraEnabled
        public String Name{get; set;}
        @AuraEnabled
        public String Num{get; set;}
        @AuraEnabled
        public String RecId{get; set;}
    }
}