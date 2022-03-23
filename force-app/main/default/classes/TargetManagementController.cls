public without sharing class TargetManagementController {
    static final string ACTUAL_PRIMARY_CURRENT = 'Actuals-Primary (Current FY)';
    static final string ACTUAL_SECONDARY_CURRENT = 'Actuals-Secondary (Current FY)';
    static final string ACTUAL_SECONDARY_PREVIOUS = 'Actuals (Previous FY)';
    static final string TARGET_CURRENT = 'Target (Current FY)';
    static final string COMPETITOR_CURRENT = 'Competitor Actuals (Current FY)';
    
    @AuraEnabled
    public static Map<string,Map<string,metric__c>> fetchMetrics(String accountId, string fy, string productIdSet) {
        try{
            Map<string,Map<string,metric__c>> responseMap = new Map<string,Map<string,metric__c>>();
            List<Metric__c> newMetricsList = new List<Metric__c>();
            List<Metric__c> currentMetricLst = getCurrentMetrics(accountId,fy);
            List<Metric__c> previousMetricLst = getPreviousMetrics(accountId,String.valueOf(integer.valueof(fy)-1));
            List<Product2> prodLst = getProductsList(productIdSet);
            prepResponseMap(accountId,fy,responseMap,newMetricsList,currentMetricLst,previousMetricLst,prodLst);
            if(newMetricsList.size()>0) {
                insert newMetricsList;
                responseMap = getResponseMap(accountId,fy,productIdSet);
            }
            return responseMap;
        }
        catch(Exception ex) {
            system.debug(ex.getMessage());
            return null;
        }
    }
    public static void prepResponseMap(String accountId, string fy,Map<string,Map<string,metric__c>> responseMap,
                                       List<Metric__c> newMetricsList,List<Metric__c> currentMetricLst,
                                       List<Metric__c> previousMetricLst,List<Product2> prodLst) {
                                           for(Product2 prod : prodLst) {
                                               if(! responseMap.containsKey(prod.Name)) {
                                                   Map<String,Metric__c> metricsMap = new Map<String,Metric__c>();
                                                   //Commenting to hide data in projetcion LWC
                                                //    for(Metric__c met : previousMetricLst) {
                                                //        if(met.product__c == prod.Id) {
                                                //            metricsMap.put(ACTUAL_SECONDARY_PREVIOUS, met);
                                                //        }
                                                //    }
                                                   for(Metric__c met : currentMetricLst) {
                                                       if(met.product__c == prod.Id) {
                                                           metricsMap.put(met.Metric_Type__c, met);
                                                       }
                                                   }
                                                   if(newMetricsList != null) {
                                                       newMetricsList = addNewMetricsToList(metricsMap,accountId, prod, fy,newMetricsList);
                                                   }
                                                   if(prod.Scheme__c != null) {
                                                        responseMap.put(prod.Name+' - '+prod.Scheme__c, metricsMap);
                                                   }
                                                   else {
                                                        responseMap.put(prod.Name, metricsMap);
                                                   }
                                               }
                                           }
                                       }
    public static Map<string,Map<string,metric__c>> getResponseMap(String accountId, string fy, string productIdSet) {
        try{
            Map<string,Map<string,metric__c>> responseMap = new Map<string,Map<string,metric__c>>();
            List<Metric__c> currentMetricLst = getCurrentMetrics(accountId,fy);
            List<Metric__c> previousMetricLst = getPreviousMetrics(accountId,String.valueOf(integer.valueof(fy)-1));
            List<Product2> prodLst = getProductsList(productIdSet);
            prepResponseMap(accountId,fy,responseMap,null,currentMetricLst,previousMetricLst,prodLst);
            return responseMap;
        }
        catch(Exception ex) {
            system.debug(ex.getMessage());
            return null;
        }
    }  
    public static List<Product2> getProductsList(string productIdSet) {
        string productQuery;
        if(productIdSet != null && productIdSet !='*') {
            productQuery = 'SELECT id,Name,Scheme__c FROM product2 where id IN '+productIdSet;
        }
        else {
            productQuery = 'SELECT id,Name,Scheme__c FROM product2 WHERE Competitor_Product__c = false';
        } 
        system.debug(productQuery);
        List<Product2> prodLst = Database.query(productQuery);
        system.debug(prodLst);
        return prodLst;
    }
    public static List<Metric__c> getCurrentMetrics(string accountId, string fy) {
        //Adding Metric_Type__c=:ACTUAL_SECONDARY_CURRENT  to hide data in projetcion LWC
        return [SELECT id,account__c,Fiscal_Year__c,product__c,product__r.Name,Metric_Type__c,JAN__c,FEB__c,MAR__c,APR__c,MAY__c,
                JUN__c,JUL__c,AUG__c,SEP__c,OCT__c,NOV__c,DEC__c,Q1__c,Q2__c,Q3__c,Q4__c FROM Metric__c
                WHERE account__c = :accountId AND Fiscal_Year__c = : fy AND Metric_Type__c != :COMPETITOR_CURRENT AND Metric_Type__c=:ACTUAL_SECONDARY_CURRENT ORDER BY Metric_Type__c ASC ];
    }
    public static List<Metric__c> getPreviousMetrics(string accountId, string PreviousFY) {
        return [SELECT id,account__c,Fiscal_Year__c,product__c,product__r.Name,Metric_Type__c,JAN__c,FEB__c,MAR__c,APR__c,MAY__c,
                JUN__c,JUL__c,AUG__c,SEP__c,OCT__c,NOV__c,DEC__c,Q1__c,Q2__c,Q3__c,Q4__c FROM Metric__c
                WHERE account__c = :accountId AND Fiscal_Year__c = : PreviousFY 
                AND Metric_Type__c =: ACTUAL_SECONDARY_CURRENT];
    }
    public static List<Metric__c> addNewMetricsToList(Map<String,Metric__c> metricsMap, String accountId,Product2 prod,String fy,List<Metric__c> newMetricsList) {
        if(! metricsMap.containsKey(ACTUAL_SECONDARY_PREVIOUS)) {
            Metric__c mRecord = createMetricRecord(accountId, prod, String.valueOf(integer.valueof(fy)-1), ACTUAL_SECONDARY_CURRENT);
            newMetricsList.add(mRecord);
        } 
        if(! metricsMap.containsKey(TARGET_CURRENT)) {
            Metric__c mRecord = createMetricRecord(accountId, prod, fy, TARGET_CURRENT);
            newMetricsList.add(mRecord);
        }
        if(! metricsMap.containsKey(ACTUAL_PRIMARY_CURRENT)) {
            Metric__c mRecord = createMetricRecord(accountId, prod, fy, ACTUAL_PRIMARY_CURRENT);
            newMetricsList.add(mRecord);
        }
        if(! metricsMap.containsKey(ACTUAL_SECONDARY_CURRENT)) {
            Metric__c mRecord = createMetricRecord(accountId, prod, fy, ACTUAL_SECONDARY_CURRENT);
            newMetricsList.add(mRecord);
        } 
        return newMetricsList;
    }
    public static Metric__c createMetricRecord(string account,Product2 prod, string fy, string type) {
        try {
            Metric__c metricToInsert = new Metric__c();
            metricToInsert.Name = prod.Name;
            metricToInsert.Account__c = account;
            metricToInsert.Fiscal_Year__c = fy;
            metricToInsert.Product__c = prod.Id;
            metricToInsert.Metric_Type__c = type;
            metricToInsert.JAN__c = 0;
            metricToInsert.FEB__c = 0;
            metricToInsert.MAR__c = 0;
            metricToInsert.APR__c = 0;
            metricToInsert.MAY__c = 0;
            metricToInsert.JUN__c = 0;
            metricToInsert.JUL__c = 0;
            metricToInsert.AUG__c = 0;
            metricToInsert.SEP__c = 0;
            metricToInsert.OCT__c = 0;
            metricToInsert.NOV__c = 0;
            metricToInsert.DEC__c = 0;
            return metricToInsert;
        }
        catch(Exception ex) {
            system.debug(ex.getMessage());
            return null;
        }
    }
    @AuraEnabled
    public static void saveMetricRecord(List<Metric__c> metricRecordList) {
        system.debug(metricRecordList);
        try {
            Database.upsert(metricRecordList);
            system.debug(metricRecordList);
        }
        catch(Exception ex) {
            system.debug(ex.getMessage());
        }
    } 
}