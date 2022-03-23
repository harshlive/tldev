public class competitorLWCController {
    static final string ACTUAL_COMPETITOR_CURRENT = 'Competitor Actuals (Current FY)';
    @AuraEnabled
    public static Map<string,List<Metric__c>> getCompInfo(string accountId, string fiscal_year) {
        List<Metric__c> metricLst = [SELECT id,account__c,Fiscal_Year__c,product__c,product__r.Name,Metric_Type__c,JAN__c,FEB__c,MAR__c,APR__c,MAY__c,
                                     JUN__c,JUL__c,AUG__c,SEP__c,OCT__c,NOV__c,DEC__c,Q1__c,Q2__c,Q3__c,Q4__c, Competitor__c  FROM Metric__c
                                     WHERE account__c = :accountId AND Fiscal_Year__c = : fiscal_year AND Metric_Type__c = :ACTUAL_COMPETITOR_CURRENT];
        
        Map<string,List<Metric__c>> competitorInfoMap = new Map<string,List<Metric__c>>();
        if(metricLst.size()>0) {
            for(Metric__c metricRecord : metricLst) {
                if(competitorInfoMap.containsKey(metricRecord.Competitor__c)) {
                    competitorInfoMap.get(metricRecord.Competitor__c).add(metricRecord);
                }
                else {
                    List<Metric__c> tempList = new List<Metric__c>();
                    tempList.add(metricRecord);
                    competitorInfoMap.put(metricRecord.Competitor__c,tempList);
                }
            }
        }
        return competitorInfoMap;
    }
    @AuraEnabled
    public static Metric__c getMonthlyCompInfo(string accountId, string competitor, string fiscal_year , string prodId) {
        List<Metric__c> metricLst = [SELECT id,account__c,Fiscal_Year__c,product__c,product__r.Name,Metric_Type__c,JAN__c,FEB__c,MAR__c,APR__c,MAY__c,
                                     JUN__c,JUL__c,AUG__c,SEP__c,OCT__c,NOV__c,DEC__c,Q1__c,Q2__c,Q3__c,Q4__c,Competitor__c FROM Metric__c
                                     WHERE account__c = :accountId AND Fiscal_Year__c = : fiscal_year 
                                     AND Metric_Type__c = :ACTUAL_COMPETITOR_CURRENT AND product__c = :prodId AND Competitor__c=: competitor];
        if(metricLst != null && metricLst.size()>0) {
            return metricLst[0];
        }
        else {
            return null;
        }
    }
    @AuraEnabled
    public static void updateMonthlyCompInfo(Metric__c metRecord) {
        Product2 prd = [SELECT Id, Name FROM product2 where id = :metRecord.Product__c];
        metRecord.Name = prd.Name;
        upsert metRecord;
        system.debug(metRecord);
    }
}