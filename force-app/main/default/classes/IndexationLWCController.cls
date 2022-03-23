public without sharing class IndexationLWCController {
    @AuraEnabled
    public static Index_Factor__c getIndices(String state, string fiscalYear) {
        try{
            List <Index_Factor__c> indexRecLst = [SELECT id,Q1_Index__c,Q2_Index__c,Q3_Index__c,Q4_Index__c
                                        FROM Index_Factor__c WHERE Fiscal_Year__c=: fiscalYear AND 
                                        state__c = :state];
            if(indexRecLst.size() >0 ) {
                return indexRecLst[0];
            }
            else {
                Index_Factor__c newRec = createIndex( state, fiscalYear,0,0,0,0);
                return newRec;
            }
        }
        catch(Exception ex) {
            throw new AuraException(ex.getMessage());
        }
    }
    @AuraEnabled
    public static Index_Factor__c saveIndex(Index_Factor__c index) {
        update index;
        return [SELECT id,Q1_Index__c,Q2_Index__c,Q3_Index__c,Q4_Index__c
                                        FROM Index_Factor__c WHERE id =: index.id];
    }
    public static Index_Factor__c createIndex(String state, string fiscalYear,Double q1Index,Double q2Index,Double q3Index,Double q4Index) {
        Index_Factor__c newRec = new Index_Factor__c();
        newRec.state__c = state;
        newRec.Fiscal_Year__c = fiscalYear;
        newRec.Q1_Index__c = q1Index;
        newRec.Q2_Index__c	 = q2Index;
        newRec.Q3_Index__c = q3Index;
        newRec.Q4_Index__c = q4Index;
        insert newRec;
        return newRec;
    }

}