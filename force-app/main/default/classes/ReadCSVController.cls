public inherited sharing class ReadCSVController {
    public static string SAR_TYPE = 'SecondaryActuals';
    public static string SECONDARY_TARGET_TYPE = 'SecondaryTargets';
    public static string PRIMARY_TARGET_TYPE = 'PrimaryTargets';
    public static string CASH = 'CASH';
    public static string SCHEME = 'SCHEME';
    public static string TRANSLUMINA = 'translumina';
    public static string ACTUAL_PRIMARY_METRIC_TYPE ='Actuals-Primary (Current FY)';
    public static string COMPETITOR_METRIC_TYPE = 'Competitor Actuals (Current FY)';
    public static string ACTUAL_SECONDARY_METRIC_TYPE = 'Actuals-Secondary (Current FY)';
    public static string JANUARY = 'January';
    public static string FEBRUARY = 'February';
    public static string MARCH = 'March';
    public static string APRIL = 'April';
    public static string MAY = 'May';
    public static string JUNE = 'June';
    public static string JULY = 'July';
    public static string AUGUST = 'August';
    public static string SEPTEMBER = 'September';
    public static string OCTOBER = 'October';
    public static string NOVEMBER = 'November';
    public static string DECEMBER = 'December';
    public static string PRIMARY_TARGET_METRIC_TYPE = 'Target (Current FY)';
    
    @AuraEnabled
    public static list<Metric__c> readCSVFile(Id idContentDocument,String type) {
        if(type == SAR_TYPE) {
            return ReadCSVController.readCSVFileSAR(idContentDocument);
        }
        else if(type == SECONDARY_TARGET_TYPE) {
            return ReadCSVController.readCSVFileSecondaryTarget(idContentDocument);
        }
        else if(type == PRIMARY_TARGET_TYPE) {
            return ReadCSVController.readCSVFilePrimary(idContentDocument);
        }
        return null;
    }
    @AuraEnabled
    public static list<Metric__c> readCSVFileSAR(Id idContentDocument){
        list<Metric__c> compLst = new list<Metric__c>();
        list<Metric__c> lstMetricsToInsert = new list<Metric__c>();
        string cash=CASH.toLowerCase();
        string scheme=SCHEME.toLowerCase();
        try {
            if(idContentDocument != null){
                ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];            
                List<Account> accList=[SELECT Id, Name, AccountNumber FROM Account];
                List<Contact> conList=[SELECT Id, Name,Contact_ID__c FROM Contact];
                List<Product2> prodList=[SELECT Id,Name ,Family,Competitor__c,Brand__c FROM Product2];
                
                
                map<String,String> accMap=new map<String,String>();
                map<String,String> conMap=new map<String,String>();
                map<String,String> prodMap=new map<String,String>();
                map<String,String> prodRevMap=new map<String,String>();
                for(Account acc:accList){
                    accMap.put(acc.AccountNumber,acc.Id);
                }
                for(Contact con:conList){
                    conMap.put(con.Contact_ID__c,con.Id);
                }
                for(Product2 pd:prodList){                    
                    prodMap.put(pd.Name.toLowerCase().trim(),pd.Id);     
                    prodRevMap.put(pd.Id,pd.Name.toLowerCase().trim());
                } 
                system.debug(prodMap);
                list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');
                list<string> topRow = lstCSVLines[0].split(',');
                string fiscalYear = topRow[0].trim();
                string month = topRow[1];
                set<string> monthSet = new Set<string>{JANUARY,FEBRUARY,MARCH,APRIL,MAY,JUNE,JULY,AUGUST,SEPTEMBER,OCTOBER,NOVEMBER,DECEMBER };
                
                    
                    if(!monthSet.contains(month)) {
                     ErrorLogger.LogErrorCSV('ReadCSVController:readCSVFileSAR', 'Apex Class','MONTHLY SAR REPORT','Invalid Month: '+month,  '', '',
                                                         'CSV File:'+idContentDocument,  'Line: month');
                       return null;
                }
                Map<Integer,String> competitorIndexMap = new Map<Integer,String>();
                for(Integer p = 2;p<topRow.size();p++) {
                    if(!String.isBlank(topRow[p])) {
                        competitorIndexMap.put(p,topRow[p]);
                    }
                }
                
                set<Id> doctorIds=new set<Id>();
                List<Metric__c> metricsToUpsert = new List<Metric__c>();
                for(Integer i = 2; i < lstCSVLines.size(); i++){
                    for(Integer k : competitorIndexMap.keySet()) {
                        Metric__c record = new Metric__c();
                        list<String> csvRowData = lstCSVLines[i].split(',');
                        System.debug('csvRowData====> '+csvRowData);
                        record.Fiscal_Year__c = fiscalYear;
                        record.Account__c = accMap.get(csvRowData[1]);
                        record.Doctor__c = conMap.get(csvRowData[3]);
                        //doctor name set
                        doctorIds.add(conMap.get(csvRowData[3]));
                        record.PTCA_Doctor__c = integer.valueof(csvRowData[5]);
                        record.DES_Doctor__c = integer.valueof(csvRowData[6]);
                        if(competitorIndexMap.get(k).toLowerCase() != TRANSLUMINA) {
                            system.debug(csvRowData[k]);
                            system.debug(competitorIndexMap.get(k).toLowerCase());
                            record.Competitor__c = competitorIndexMap.get(k);
                            record.Metric_Type__c = COMPETITOR_METRIC_TYPE;
                        }
                        else {
                            record.Metric_Type__c = ACTUAL_SECONDARY_METRIC_TYPE;
                        }
                        system.debug(lstCSVLines[1].split(',')[k].deleteWhitespace().trim().toLowerCase());
                        
                        //Product Mapping
                        system.debug(prodMap.get(lstCSVLines[1].split(',')[k].trim().toLowerCase()));                        
                        if(prodMap.get(lstCSVLines[1].split(',')[k].trim().toLowerCase())!=null){
                            record.Product__c = prodMap.get(lstCSVLines[1].split(',')[k].trim().toLowerCase());
                        }else if(prodMap.get(lstCSVLines[1].split(',')[k].trim().toLowerCase().split('-')[0])!=null){
                            record.Product__c = prodMap.get(lstCSVLines[1].split(',')[k].trim().toLowerCase().split('-')[0]);
                        }
                         
                        system.debug(lstCSVLines[1].split(',')[k].deleteWhitespace().trim().toLowerCase().split('-'));
                        if(lstCSVLines[1].split(',')[k].deleteWhitespace().trim().toLowerCase().split('-').size()>1) {
                            if(lstCSVLines[1].split(',')[k].deleteWhitespace().trim().toLowerCase().split('-')[1]!=null){
                                if(lstCSVLines[1].split(',')[k].deleteWhitespace().trim().toLowerCase().split('-')[1]==cash){
                                    record.Scheme__c=CASH;
                                }else if(lstCSVLines[1].split(',')[k].deleteWhitespace().trim().toLowerCase().split('-')[1]==scheme){
                                    record.Scheme__c=SCHEME;
                                }
                            }
                        }
                        record.Name = lstCSVLines[1].split(',')[k];
                        Decimal recordVal;
                        if(!String.isBlank(csvRowData[k].trim())) {
                            recordVal=decimal.valueof(csvRowData[k].trim());
                        }
                        else {
                            recordVal=0;
                        }
                        if(month==JANUARY){record.JAN__c =  recordVal;}
                        else if(month==FEBRUARY){
                            record.FEB__c =  recordVal;
                        }
                        else if(month==MARCH){ 
                            record.MAR__c =  recordVal;
                        }
                        else if(month==APRIL){ 
                            record.APR__c =  recordVal;
                        }
                        else if(month==MAY){ 
                            record.MAY__c =  recordVal;
                        }
                        else if(month==JUNE){ 
                            record.JUN__c =  recordVal;
                        }
                        else if(month==JULY){ 
                            record.JUL__c =  recordVal;
                        }
                        else if(month==AUGUST){ 
                            record.AUG__c =  recordVal;
                        }
                        else if(month==SEPTEMBER){ 
                            record.SEP__c =  recordVal;
                        }
                        else if(month==OCTOBER){ 
                            record.OCT__c =  recordVal;
                        }
                        else if(month==NOVEMBER){ 
                            record.NOV__c =  recordVal;
                        }
                        else if(month==DECEMBER)  { 
                            record.DEC__c =  recordVal;
                        }
                        if(record.Metric_Type__c == COMPETITOR_METRIC_TYPE) {
                            compLst.add(record);
                        }
                        else {
                            lstMetricsToInsert.add(record);
                        }
                        
                    }
                } 
                List<Metric__c> checkMetricList=[SELECT Id, Scheme__c,Account__c, Fiscal_Year__c,Product__c, Product__r.Name,Doctor__c, Doctor__r.Name FROM Metric__c
                                                 WHERE Doctor__c in :doctorIds and Fiscal_Year__c =:fiscalYear
                                                AND (Metric_Type__c=:ACTUAL_SECONDARY_METRIC_TYPE OR Metric_Type__c=:COMPETITOR_METRIC_TYPE )];
                map<String,String> checkMetricMap=new map<String,String>();
                system.debug('The List'+checkMetricList);
                for(Metric__c mt:checkMetricList){
                    if(mt.Doctor__c!=null){
                        if(mt.Scheme__c!=null){
                            SYSTEM.debug('Scheme true: '+mt.Scheme__c.tolowerCase());
                            checkMetricMap.put(mt.Account__c+'-'+mt.Doctor__c+'-'+mt.Fiscal_Year__c+'-'+mt.Product__c+'-'+mt.Scheme__c.toLowerCase(),mt.Id);
                        }else{
                            SYSTEM.debug('Scheme False:');
                            checkMetricMap.put(mt.Account__c+'-'+mt.Doctor__c+'-'+mt.Fiscal_Year__c+'-'+mt.Product__c,mt.Id);
                        }
                    }
                }
                
                for(Metric__c mmt:lstMetricsToInsert){
                    String keycheck; 
                    if(mmt.Scheme__c!=null){ 
                        keycheck=mmt.Account__c+'-'+mmt.Doctor__c+'-'+mmt.Fiscal_Year__c+'-'+mmt.Product__c+'-'+mmt.Scheme__c.toLowerCase(); 
                    }else{ 
                        keycheck =mmt.Account__c+'-'+mmt.Doctor__c+'-'+mmt.Fiscal_Year__c+'-'+mmt.Product__c;
                    }
                    //system.debug(keycheck);
                    system.debug(checkMetricMap.containsKey(keycheck));
                    if(checkMetricMap.containsKey(keycheck)){
                         
                        mmt.Id=checkMetricMap.get(keycheck);
                    }
                }
                try{    
                    if(!lstMetricsToInsert.isEmpty()) {
                        //upsert lstMetricsToInsert;
                        Database.UpsertResult[] srList = Database.upsert(lstMetricsToInsert, true);
                        // Iterate through each returned result
                        for (Database.UpsertResult sr : srList) {
                            if (!sr.isSuccess()) {
                                
                                // Operation failed, so get all errors                
                                for(Database.Error err : sr.getErrors()) {
                                    System.debug('The following error has occurred.');                    
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Fields that affected this error: ' + err.getFields());
                                    ErrorLogger.LogErrorCSV('ReadCSVController:readCSVFileSAR', 'Apex Class','MONTHLY SAR REPORT', err.getMessage(), ''+err.getFields(), '',
                                                         'CSV File:'+idContentDocument,  'Line: '+err.getFields());
                                    
                                }
                                System.debug('Block-For');
                                return null;
                            }
                        }
                    }
                    if(compLst.size()>0) {
                        processCompData(compLst,prodRevMap,month,fiscalYear,doctorIds);
                    }
                }
                catch (Exception ex) {
                    System.debug('Block-1');
                    ErrorLogger.LogErrorCSV('ReadCSVController:readCSVFileSAR', 'Apex Class','MONTHLY SAR REPORT', ex.getMessage(), '',
                                 'CSV File:'+idContentDocument,  '','Line: '+ex.getLineNumber()); 
                    return null;
                } 
            }
            system.debug(lstMetricsToInsert);
            return lstMetricsToInsert;    
        }
        catch(Exception ex) {
            System.debug('Exception Block-2');
            ErrorLogger.LogErrorCSV('ReadCSVController:readCSVFileSAR', 'Apex Class','MONTHLY SAR REPORT', ex.getMessage(), '',
                                 'CSV File:'+idContentDocument,  '',''); 
            return null;
        }
    }
    public static void processCompData(List<Metric__c> compLst,map<String,String> prodRevMap,string month,string fiscalYear,Set<Id> doctorIds) {
        List<Daily_Deployment__c> compDepLst = new List<Daily_Deployment__c>();
        Map<String,String> monthMap = new Map<String,String>{'January' => 'JAN__c', 'February' => 'FEB__c', 'March' => 'MAR__c',
            'April' => 'APR__c', 'May' => 'MAY__c', 'June' => 'JUN__c',
            'July' => 'JUL__c', 'August' => 'AUG__c', 'September' => 'SEP__c',
            'October' => 'OCT__c', 'November' => 'NOV__c', 'December' => 'DEC__c'};
                for(Metric__c mt : compLst) {
                    Daily_Deployment__c dep = new Daily_Deployment__c();
                    dep.Account__c = mt.Account__c;
                    dep.Doctor__c = mt.Doctor__c;
                    dep.Competitor_Name__c = mt.Competitor__c;
                    if(! prodRevMap.containsKey(mt.Product__c) )
                    {system.debug(mt.Product__c);}
                    dep.Competitor_Product__c = prodRevMap.get(mt.Product__c);
                    dep.Week_4__c = Integer.valueOf( mt.get(monthMap.get(month)));
                    dep.Month__c = month;
                    dep.Year__c = Integer.valueOf(fiscalYear);
                    compDepLst.add(dep);
                }
        List<Daily_Deployment__c> checkMetricList=[SELECT Id,Account__c,Year__c,month__c, Doctor__c,Competitor_Product__c,Competitor_Name__c FROM Daily_Deployment__c
                                         WHERE Doctor__c in :doctorIds and Year__c =:Integer.valueOf(fiscalYear)
                                         AND Competitor_Name__c != NULL];
        map<String,String> checkMetricMap=new map<String,String>();
        system.debug('The List'+checkMetricList);
        for(Daily_Deployment__c mt:checkMetricList){
            if(mt.Doctor__c!=null){
                checkMetricMap.put(mt.Account__c+'-'+mt.Doctor__c+'-'+mt.Year__c+'-'+mt.Competitor_Product__c + mt.month__c,mt.Id);
            }
        }
        
        for(Daily_Deployment__c mt:compDepLst){
            String keycheck; 
            keycheck =mt.Account__c+'-'+mt.Doctor__c+'-'+mt.Year__c+'-'+mt.Competitor_Product__c + mt.month__c;
            //system.debug(keycheck);
            system.debug(checkMetricMap.containsKey(keycheck));
            if(checkMetricMap.containsKey(keycheck)){
                
                mt.Id=checkMetricMap.get(keycheck);
            }
        } 
        if(!compDepLst.isEmpty()) {
            //upsert lstMetricsToInsert;
            system.debug(compDepLst.size());
            Database.UpsertResult[] srList = Database.upsert(compDepLst, true);
            // Iterate through each returned result
            for (Database.UpsertResult sr : srList) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                    System.debug('Block-For');
                    //return null;
                }
            }
        }
    }
    @AuraEnabled
    public static list<Metric__c> readCSVFilePrimary(Id idContentDocument){
        string nonpremium='Non Premium Stents';
        string premium='Premium Stents';
        Set<Id> userIds = new Set<Id>();
        list<Metric__c> lstMetricsToInsert = new list<Metric__c>();
        set<string> monthSet = new Set<string>{JANUARY,FEBRUARY,MARCH,APRIL,MAY,JUNE,JULY,AUGUST,SEPTEMBER,OCTOBER,NOVEMBER,DECEMBER };
            try {
                if(idContentDocument != null){
                    ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];            
                    List<User> usrList=[SELECT Id,Employee_Id__c, Name FROM User]; 
                    List<Product2> prodList=[SELECT Id,Name ,Family,Category__c,Competitor__c,Brand__c FROM Product2];
                    
                    map<String,String> userMap=new map<String,String>();
                    map<String,String> conMap=new map<String,String>();
                    map<String,Product2> prodMap=new map<String,Product2>();
                    for(User usr:usrList){
                        if(usr.Employee_Id__c!=null){
                            userMap.put(usr.Employee_Id__c.toLowerCase().deleteWhitespace(),usr.Id);
                            
                        }
                    }
                    for(Product2 pd:prodList){ 
                        prodMap.put(pd.Name.toLowerCase().deleteWhitespace(),pd);
                        
                    }  
                    list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');
                    list<string> topRow = lstCSVLines[0].split(',');
                    string fiscalYear = topRow[0].trim();
                    string month = topRow[1];
                    if(!monthSet.contains(month)) {
                        ErrorLogger.LogErrorCSV('ReadCSVController:readCSVFilePrimary', 'Apex Class','Primary-Targets and Actuals','Invalid Month: '+month,  '', '',
                                                'CSV File:'+idContentDocument,  'Line: month');
                        return null;
                    }
                    
                    Map<Integer,String> productIndexMap = new Map<Integer,String>();
                    for(Integer p = 2;p<topRow.size();p++) {
                        if(!String.isBlank(topRow[p])) {
                            productIndexMap.put(p,topRow[p]);
                        }
                    }
                    System.debug(productIndexMap);
                    
                    
                    Schema.SObjectType s = Schema.getGlobalDescribe().get('Metric__c') ;
                    Schema.DescribeSObjectResult r = s.getDescribe() ;
                    Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
                    Schema.DescribeFieldResult fieldResult = fields.get('Target_Product_Category__c').getDescribe();
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    List<string> pickListValues = new List<string>();
                    for( Schema.PicklistEntry pickListVal : ple){ 
                        pickListValues.add(pickListVal.getValue());
                    }   
                    map<String,String> prodCatMap=new map<String,String>();
                    for(String ss:pickListValues){
                        prodCatMap.put(ss.toLowerCase(),ss);
                    } 
                    
                    for(Integer i = 2; i < lstCSVLines.size(); i++){
                        for(Integer k : productIndexMap.keySet()) {
                            list<String> csvRowData = lstCSVLines[i].split(',');
                            System.debug('csvRowData====> '+csvRowData);
                            if(prodCatMap.get(productIndexMap.get(k).toLowerCase())!=null){
                                if(productIndexMap.get(k).toLowerCase()==nonpremium||productIndexMap.get(k).toLowerCase()==premium){  
                                    System.debug('Preim/NonPreim'+productIndexMap.get(k));
                                    Decimal recordVal;
                                    if(!String.isBlank(csvRowData[k].trim())) {
                                        recordVal=decimal.valueof(csvRowData[k].trim());
                                    }
                                    else {
                                        recordVal=0;
                                    }
                                    Metric__c record = createMetric(month,recordVal,fiscalYear,0);
                                    record.Name=productIndexMap.get(k); 
                                    record.State__c=csvRowData[0];
                                    if(!(productIndexMap.get(k) == nonpremium || productIndexMap.get(k) == premium )) {
                                        if(prodMap.get(productIndexMap.get(k).toLowerCase().deleteWhitespace()) !=null && prodMap.get(productIndexMap.get(k).toLowerCase().deleteWhitespace()).Id!=null){                                
                                            record.Product__c=prodMap.get(productIndexMap.get(k).toLowerCase().deleteWhitespace()).Id;
                                        }
                                    }
                                    record.Target_Product_Category__c=prodCatMap.get(productIndexMap.get(k).toLowerCase());
                                    System.debug('User1:'+csvRowData[2].toLowerCase().deleteWhitespace()+',map:'+userMap.get(csvRowData[2].toLowerCase().deleteWhitespace()));    
                                    record.User__c=userMap.get(csvRowData[2].toLowerCase().deleteWhitespace());
                                    userIds.add(userMap.get(csvRowData[2].toLowerCase().deleteWhitespace()));
                                    record.Metric_Type__c=PRIMARY_TARGET_METRIC_TYPE; 
                                    
                                    lstMetricsToInsert.add(record);
                                    
                                    
                                    
                                }else{ 
                                    Decimal target;
                                    if(!String.isBlank(csvRowData[k].trim())) {
                                        target=decimal.valueof(csvRowData[k].trim());
                                    }
                                    else {
                                        target = 0;
                                    }
                                    System.debug('VA/OPN/'+productIndexMap.get(k));
                                    Metric__c targetMetric = createMetric(month,target,fiscalYear,0);
                                    targetMetric.Name=productIndexMap.get(k);
                                    targetMetric.State__c=csvRowData[0]; 
                                    if(prodMap.get(productIndexMap.get(k).toLowerCase().deleteWhitespace()) !=null && prodMap.get(productIndexMap.get(k).toLowerCase().deleteWhitespace()).Id!=null){                                
                                        targetMetric.Product__c=prodMap.get(productIndexMap.get(k).toLowerCase().deleteWhitespace()).Id;
                                    }
                                    targetMetric.Target_Product_Category__c=prodCatMap.get(productIndexMap.get(k).toLowerCase());
                                    targetMetric.User__c=userMap.get(csvRowData[2].toLowerCase().deleteWhitespace());
                                    userIds.add(userMap.get(csvRowData[2].toLowerCase().deleteWhitespace()));
                                    targetMetric.Metric_Type__c=PRIMARY_TARGET_METRIC_TYPE; 
                                    lstMetricsToInsert.add(targetMetric);
                                    
                                    Decimal actual;
                                    if(!String.isBlank(csvRowData[k+1].trim())) {
                                        actual=decimal.valueof(csvRowData[k+1].trim());
                                    }
                                    else {
                                        actual = 0;
                                    }
                                    Decimal actualGrn;
                                    if(!String.isBlank(csvRowData[k+2].trim())) {
                                        
                                        actualGrn=decimal.valueof(csvRowData[k+2].trim());
                                    }
                                    else {
                                        actualGrn = 0;
                                    }
                                    if(!String.isBlank(csvRowData[k].trim())) {
                                        target=decimal.valueof(csvRowData[k].trim());
                                    }
                                    else {
                                        target = 0;
                                    }
                                    Metric__c actualMetric = createMetric(month,actual,fiscalYear,actualGrn);
                                    actualMetric.Name=productIndexMap.get(k);
                                    actualMetric.State__c=csvRowData[0]; 
                                    if(prodMap.get(productIndexMap.get(k).toLowerCase().deleteWhitespace()) !=null && prodMap.get(productIndexMap.get(k).toLowerCase().deleteWhitespace()).Id!=null){                                
                                        actualMetric.Product__c=prodMap.get(productIndexMap.get(k).toLowerCase().deleteWhitespace()).Id;
                                    }
                                    actualMetric.Target_Product_Category__c=prodCatMap.get(productIndexMap.get(k).toLowerCase());
                                    System.debug('User2:'+csvRowData[2].toLowerCase().deleteWhitespace()+',map:'+userMap.get(csvRowData[2].toLowerCase().deleteWhitespace()));
                                    actualMetric.User__c=userMap.get(csvRowData[2].toLowerCase().deleteWhitespace());
                                    userIds.add(userMap.get(csvRowData[2].toLowerCase().deleteWhitespace()));
                                    actualMetric.Metric_Type__c=ACTUAL_PRIMARY_METRIC_TYPE; 
                                    
                                    lstMetricsToInsert.add(actualMetric);
                                }
                            }else{
                                System.debug('error value:'+csvRowData[k].trim());
                                Decimal recordVal;
                                if(!String.isBlank(csvRowData[k].trim())) {
                                    recordVal=decimal.valueof(csvRowData[k].trim());
                                }
                                else {
                                    recordVal = 0;
                                }
                                Decimal recordGrn;
                                if(!String.isBlank(csvRowData[k+1].trim())) {
                                    recordGrn=decimal.valueof(csvRowData[k+1].trim());
                                }
                                else {
                                    recordGrn = 0;
                                }
                                System.debug('Products'+productIndexMap.get(k));
                                
                                Metric__c record = createMetric(month,recordVal,fiscalYear,recordGrn);
                                record.Name=productIndexMap.get(k);
                                record.State__c=csvRowData[0]; 
                                system.debug(productIndexMap.get(k));
                                system.debug(prodMap.get(productIndexMap.get(k).toLowerCase().deleteWhitespace()));
                                if(prodMap.get(productIndexMap.get(k).toLowerCase().deleteWhitespace()) !=null && prodMap.get(productIndexMap.get(k).toLowerCase().deleteWhitespace()).Id!=null){                                
                                    record.Product__c=prodMap.get(productIndexMap.get(k).toLowerCase().deleteWhitespace()).Id;
                                }
                                system.debug(productIndexMap.get(k).toLowerCase().deleteWhitespace());
                                system.debug(prodMap.get(productIndexMap.get(k).toLowerCase().deleteWhitespace()));
                                if(prodMap.get(productIndexMap.get(k).toLowerCase().deleteWhitespace()) != null) {
                                    record.Target_Product_Category__c=prodMap.get(productIndexMap.get(k).toLowerCase().deleteWhitespace()).Category__c;
                                }
                                System.debug('User3:'+csvRowData[2].toLowerCase().deleteWhitespace()+',map:'+userMap.get(csvRowData[2].toLowerCase().deleteWhitespace()));
                                record.User__c=userMap.get(csvRowData[2].toLowerCase().deleteWhitespace());
                                record.Metric_Type__c=ACTUAL_PRIMARY_METRIC_TYPE;
                                lstMetricsToInsert.add(record);
                                
                            }   
                        }
                    }
                    List<Metric__c> checkMetricList=[SELECT Id,User__c,Target_Product_Category__c,Metric_Type__c, Fiscal_Year__c,scheme__c,Product__c, Product__r.Name,Doctor__c, Doctor__r.Name FROM Metric__c
                                                     WHERE user__c in :userIds and Fiscal_Year__c =:fiscalYear AND Metric_Type__c in ('Target (Current FY)','Actuals-Primary (Current FY)')];
                    map<String,String> checkMetricMapTarget=new map<String,String>();
                    map<String,String> checkMetricMapActual=new map<String,String>();
                    system.debug(checkMetricList);
                    for(Metric__c mt:checkMetricList){
                        if(mt.Metric_Type__c == PRIMARY_TARGET_METRIC_TYPE) {
                            checkMetricMapTarget.put(mt.User__c+'-'+mt.Fiscal_Year__c+'-'+mt.Target_Product_Category__c+'-'+mt.Metric_Type__c,mt.Id);
                        }
                        else if(mt.Metric_Type__c == ACTUAL_PRIMARY_METRIC_TYPE) {
                            checkMetricMapActual.put(mt.User__c+'-'+mt.Fiscal_Year__c+'-'+mt.Product__c+'-'+mt.Metric_Type__c,mt.Id);
                        }
                        
                    }
                    
                    for(Metric__c mt:lstMetricsToInsert){
                        if(mt.Metric_Type__c == PRIMARY_TARGET_METRIC_TYPE) {
                            String keycheck= mt.User__c+'-'+mt.Fiscal_Year__c+'-'+mt.Target_Product_Category__c+'-'+mt.Metric_Type__c;
                            system.debug(keycheck);
                            system.debug(checkMetricMapTarget.containsKey(keycheck));
                            if(checkMetricMapTarget.containsKey(keycheck)){
                                mt.Id=checkMetricMapTarget.get(keycheck);
                            }
                        }
                        else if(mt.Metric_Type__c == ACTUAL_PRIMARY_METRIC_TYPE) {
                            String keycheck= mt.User__c+'-'+mt.Fiscal_Year__c+'-'+mt.Product__c+'-'+mt.Metric_Type__c;
                            system.debug(keycheck);
                            system.debug(checkMetricMapActual.containsKey(keycheck));
                            if(checkMetricMapActual.containsKey(keycheck)){
                                mt.Id=checkMetricMapActual.get(keycheck);
                            }
                        }
                    }
                }    
                System.debug('empty metric list:'+lstMetricsToInsert);
                if(!lstMetricsToInsert.isEmpty()) {
                    System.debug('metric list:'+lstMetricsToInsert);
                    Database.UpsertResult[] srList = Database.Upsert(lstMetricsToInsert, true);
                    // Iterate through each returned result
                    for (Database.UpsertResult sr : srList) {
                        if (!sr.isSuccess()) {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Fields that affected this error: ' + err.getFields());
                                ErrorLogger.LogErrorCSV('ReadCSVController:readCSVFilePrimary', 'Apex Class','Primary-Targets and Actuals', err.getMessage(), ''+err.getFields(), '',
                                                        'CSV File:'+idContentDocument, 'Line: '+err.getFields());
                            }
                            System.debug('readCSVFilePrimary For-Block');
                            return null;
                        }
                    }
                }
                return lstMetricsToInsert;
            }catch(Exception ex) {
                ErrorLogger.LogErrorCSV('ReadCSVController:readCSVFilePrimary', 'Apex Class','Primary-Targets and Actuals', ex.getMessage(), '',
                                        'CSV File:'+idContentDocument,  '','');
                System.debug('Exception Block-2: '+ex.getMessage()+ex.getLineNumber());
                return null;     
            }
    }
    
    public static Metric__c createMetric(string month,Decimal recordVal,string fiscalYear,Decimal grn){
        
        System.debug('grn:'+grn);
        Metric__c record=new Metric__c();
        record.Fiscal_Year__c = fiscalYear;
        
        if(month==JANUARY){
            record.JAN__c =  recordVal;
            record.JAN_GRN__c=grn;
        }
        else if(month==FEBRUARY){
            record.FEB__c =  recordVal;
            record.FEB_GRN__c=grn;
        }
        else if(month==MARCH){
            record.MAR__c =  recordVal;
            record.MAR_GRN__c=grn;
        }
        else if(month==APRIL){
            record.APR__c =  recordVal;
            record.APR_GRN__c=grn;
        }
        else if(month==MAY){
            record.MAY__c =  recordVal;
            record.MAY_GRN__c=grn;
        }
        else if(month==JUNE){
            record.JUN__c =  recordVal;
            record.JUN_GRN__c=grn;
        }
        else if(month==JULY){
            record.JUL__c =  recordVal;
            record.JUL_GRN__c=grn;
        }
        else if(month==AUGUST){
            record.AUG__c =  recordVal;
            record.AUG_GRN__c=grn;
        }
        else if(month==SEPTEMBER){
            record.SEP__c =  recordVal;
            record.SEP_GRN__c=grn;
        }
        else if(month==OCTOBER){
            record.OCT__c =  recordVal;
            record.OCT_GRN__c=grn;
        }
        else if(month==NOVEMBER){
            record.NOV__c =  recordVal;
            record.NOV_GRN__c=grn;
        }
        else if(month==DECEMBER){
            record.DEC__c =  recordVal;
            record.DEC_GRN__c=grn;
        }
        
        return record;
        
    }
    
    @AuraEnabled
    public static list<Metric__c> readCSVFileSecondaryTarget(Id idContentDocument){
        string nonpremium='Non Premium';
        string premium='Premium';
        string categorypremium='PREMIUM STENTS';
        string categorynonpremium='NON PREMIUM STENTS';
        Set<Id> userIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        list<Metric__c> lstMetricsToInsert = new list<Metric__c>();
        set<string> monthSet = new Set<string>{JANUARY,FEBRUARY,MARCH,APRIL,MAY,JUNE,JULY,AUGUST,SEPTEMBER,OCTOBER,NOVEMBER,DECEMBER };
            
            try {
                if(idContentDocument != null){
                    ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];            
                    List<User> usrList=[SELECT Id,Employee_Id__c, Name FROM User]; 
                    List<Product2> prodList=[SELECT Id,Name ,Category__c,Family,Competitor__c,Brand__c FROM Product2];
                    List<Account> accList=[SELECT Id, Name, AccountNumber FROM Account];
                    map<String,String> accMap=new map<String,String>();
                    for(Account acc:accList){
                        accMap.put(acc.AccountNumber,acc.Id);
                    }
                    map<String,String> userMap=new map<String,String>();
                    map<String,String> conMap=new map<String,String>();
                    map<String,Product2> prodMap=new map<String,Product2>();
                    for(User usr:usrList){
                        if(usr.Employee_Id__c!=null){
                            userMap.put(usr.Employee_Id__c.toLowerCase().deleteWhitespace(),usr.Id); 
                        }                    
                    }
                    for(Product2 pd:prodList){ 
                        prodMap.put(pd.Name.toLowerCase().deleteWhitespace(),pd);                    
                    }  
                    list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');
                    list<string> topRow = lstCSVLines[0].split(',');
                    string fiscalYear = topRow[0].trim();
                    string month = topRow[1];//no month
                    
                    Map<Integer,String> productIndexMap = new Map<Integer,String>();
                    for(Integer p = 2;p<topRow.size();p++) {
                        if(!String.isBlank(topRow[p])) {
                            productIndexMap.put(p,topRow[p]);
                        }
                    }
                    System.debug(productIndexMap);
                    list<string> topRow1 = lstCSVLines[1].split(',');
                    Map<Integer,String> monthIndexMap = new Map<Integer,String>();
                    for(Integer p = 5;p<topRow1.size();p++) {
                        if(!String.isBlank(topRow1[p].trim())) {
                            System.debug(':'+topRow1[p].trim()+':');
                            if(!monthSet.contains( topRow1[p].trim())) {
                                ErrorLogger.LogErrorCSV('ReadCSVController:readCSVFileSecondaryTarget', 'Apex Class','Secondary-Targets','Invalid Month: '+topRow1[p].trim(),  '', '',
                                                        'CSV File:'+idContentDocument, 'Line: month');
                                return null;
                            }else{
                                monthIndexMap.put(p,topRow1[p].trim()); 
                            }
                            
                        }
                    }
                    System.debug(monthIndexMap);
                    
                    
                    
                    Schema.SObjectType s = Schema.getGlobalDescribe().get('Metric__c') ;
                    Schema.DescribeSObjectResult r = s.getDescribe() ;
                    Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
                    Schema.DescribeFieldResult fieldResult = fields.get('Target_Product_Category__c').getDescribe();
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    List<string> pickListValues = new List<string>();
                    for( Schema.PicklistEntry pickListVal : ple){ 
                        pickListValues.add(pickListVal.getValue());
                    }   
                    map<String,String> prodCatMap=new map<String,String>();
                    for(String ss:pickListValues){
                        prodCatMap.put(ss.toLowerCase(),ss);
                    } 
                    
                    for(Integer i = 2; i < lstCSVLines.size(); i++){
                        
                        list<String> csvRowData = lstCSVLines[i].split(',');
                        System.debug('csvRowData====> '+csvRowData);
                        
                        Metric__c record =new Metric__c();
                        record.User__c=userMap.get(csvRowData[0].toLowerCase().deleteWhitespace());
                        userIds.add(record.User__c);
                        record.Account__c = accMap.get(csvRowData[2]);
                        accIds.add(record.Account__c);
                        record.Metric_Type__c='Target-Secondary (Current FY)';
                        System.debug('602:'+csvRowData[4].toLowerCase().deleteWhitespace());
                        
                        if(csvRowData[4].toLowerCase().deleteWhitespace()==premium && prodMap.get(csvRowData[4].toLowerCase().deleteWhitespace()) == null){
                            record.Name=csvRowData[4];
                            record.Target_Product_Category__c=categorypremium;
                        }else if(csvRowData[4].toLowerCase().deleteWhitespace()==nonpremium.toLowerCase().deleteWhitespace() && prodMap.get(csvRowData[4].toLowerCase().deleteWhitespace()) == null){
                            record.Name=csvRowData[4];
                            record.Target_Product_Category__c=categorynonpremium;
                            
                        }else if(prodMap.get(csvRowData[4].toLowerCase().deleteWhitespace()) != null) {
                            record.Name=prodMap.get(csvRowData[4].toLowerCase().deleteWhitespace()).Name;
                            record.Product__c=prodMap.get(csvRowData[4].toLowerCase().deleteWhitespace()).Id;
                            productIds.add(record.Product__c);
                            record.Target_Product_Category__c=prodMap.get(csvRowData[4].toLowerCase().deleteWhitespace()).Category__c;
                        }
                        record.Fiscal_Year__c = fiscalYear;
                        
                        for(Integer k : monthIndexMap.keySet()) {
                            
                            Decimal recordVal;
                            if(!String.isBlank(csvRowData[k].trim())) {
                                System.debug('val:'+csvRowData[k].trim());
                                recordVal=decimal.valueof(csvRowData[k].trim());
                            }
                            else {
                                recordVal=0;
                            }
                            System.debug('K:'+k+'--MOnth:'+monthIndexMap.get(k)+' val: '+recordVal);
                            System.debug('condition'+(monthIndexMap.get(k)=='july'||monthIndexMap.get(k)=='jul'));
                            
                            if(monthIndexMap.get(k)==JANUARY){
                                record.JAN__c =  recordVal ;
                            }
                            else if(monthIndexMap.get(k)==FEBRUARY){
                                record.FEB__c =  recordVal ;
                            }
                            else if(monthIndexMap.get(k)==MARCH){
                                record.MAR__c =  recordVal; 
                            }
                            else if(monthIndexMap.get(k)==APRIL ){
                                record.APR__c =  recordVal; 
                            } 
                            else if(monthIndexMap.get(k)==MAY){
                                system.debug('in may');
                                record.MAY__c =  recordVal;
                            }
                            else if(monthIndexMap.get(k)==JUNE ){
                                system.debug('in june');
                                record.JUN__c =  recordVal; 
                            }
                            else if(monthIndexMap.get(k)==JULY ){
                                system.debug('in july');
                                record.JUL__c =  recordVal; 
                            }
                            else if(monthIndexMap.get(k)==AUGUST ){
                                record.AUG__c =  recordVal; 
                            }
                            else if(monthIndexMap.get(k)==SEPTEMBER ){
                                record.SEP__c =  recordVal; 
                            }
                            else if(monthIndexMap.get(k)==OCTOBER ){
                                record.OCT__c =  recordVal;
                            }
                            else if(monthIndexMap.get(k)==NOVEMBER ){
                                record.NOV__c =  recordVal; 
                            }
                            else if(monthIndexMap.get(k)==DECEMBER ){
                                record.DEC__c =  recordVal; 
                            } 
                        }
                        lstMetricsToInsert.add(record);
                    }
                    List<Metric__c> checkMetricList=[SELECT Id,User__c,Account__c,Target_Product_Category__c,Metric_Type__c, Fiscal_Year__c,scheme__c,Product__c, Product__r.Name,Doctor__c, Doctor__r.Name FROM Metric__c
                                                     WHERE user__c in :userIds and (product__c in :productIds OR Target_Product_Category__c=:categorynonpremium OR Target_Product_Category__c=:categorypremium ) 
                                                     and account__c in:accIds and Fiscal_Year__c =:fiscalYear AND Metric_Type__c ='Target-Secondary (Current FY)'];
                    map<String,String> checkMetricMap=new map<String,String>();
                    map<String,String> checkMetricStentsMap=new map<String,String>();
                    system.debug('Metric List:'+checkMetricList);
                    for(Metric__c mt:checkMetricList){
                        checkMetricMap.put(mt.User__c+'-'+mt.Fiscal_Year__c+'-'+mt.Product__c+'-'+mt.account__c,mt.Id); 
                        if(mt.Product__c==null){
                            system.debug('in category:'+(mt.User__c+'-'+mt.Fiscal_Year__c+'-'+mt.Target_Product_Category__c+'-'+mt.account__c));
                            checkMetricStentsMap.put(mt.User__c+'-'+mt.Fiscal_Year__c+'-'+mt.Target_Product_Category__c+'-'+mt.account__c,mt.Id);
                        }
                        
                    }
                    
                    for(Metric__c mt:lstMetricsToInsert){
                        if(mt.Product__c==null && (mt.Target_Product_Category__c==categorypremium || mt.Target_Product_Category__c==categorynonpremium) ){
                            system.debug('in category');
                            String keycheck= mt.User__c+'-'+mt.Fiscal_Year__c+'-'+mt.Target_Product_Category__c+'-'+mt.account__c;
                            system.debug(keycheck);
                            
                            system.debug(checkMetricStentsMap.containsKey(keycheck));
                            if(checkMetricStentsMap.containsKey(keycheck)){
                                System.debug('Got Id:'+checkMetricStentsMap.get(keycheck));
                                mt.Id=checkMetricStentsMap.get(keycheck);
                            }
                        }else{
                            system.debug('in product');
                            String keycheck= mt.User__c+'-'+mt.Fiscal_Year__c+'-'+mt.Product__c+'-'+mt.account__c;
                            system.debug(keycheck);
                            system.debug(checkMetricMap.containsKey(keycheck));
                            if(checkMetricMap.containsKey(keycheck)){
                                mt.Id=checkMetricMap.get(keycheck);
                            }
                        }
                        
                    }   
                } 
                try{    
                    System.debug('empty metric list:'+lstMetricsToInsert);
                    if(!lstMetricsToInsert.isEmpty()) {
                        System.debug('metric list:'+lstMetricsToInsert);
                        Database.UpsertResult[] srList = Database.upsert(lstMetricsToInsert, true);
                        // Iterate through each returned result
                        for (Database.UpsertResult sr : srList) {
                            if (!sr.isSuccess()) {
                                // Operation failed, so get all errors                
                                for(Database.Error err : sr.getErrors()) {
                                    System.debug('The following error has occurred.');                    
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Fields that affected this error: ' + err.getFields());
                                    ErrorLogger.LogErrorCSV('ReadCSVController:readCSVFileSecTarget', 'Apex Class','Secondary-Targets', err.getMessage(), ''+err.getFields(), '',
                                                            'CSV File:'+idContentDocument,  'Line:'+err.getFields());
                                }
                                System.debug('readcsvSecTarget:For Block');
                                return null;
                            }
                        }
                        
                    }
                }
                catch (Exception ex) {
                    System.debug('Exception Block-1: '+ex.getMessage()+ex.getLineNumber());
                    ErrorLogger.LogErrorCSV('ReadCSVController:readCSVFileSecTarget', 'Apex Class','Secondary-Targets', ex.getMessage(), ''+ex.getCause(),
                                            'CSV File:'+idContentDocument,  '','Line: '+ex.getLineNumber());
                    return null;
                } 
                return lstMetricsToInsert;
            }catch(Exception ex) {
                ErrorLogger.LogErrorCSV('ReadCSVController:readCSVFileSecTarget', 'Apex Class','Secondary-Targets', ex.getMessage()+' '+ex.getLineNumber(), '',
                                        'CSV File:'+idContentDocument,  '','Line: '+ex.getLineNumber());
                System.debug('Exception Block-2:'+ex.getMessage()+ex.getLineNumber());
                return null;   
            }
    }
    
}