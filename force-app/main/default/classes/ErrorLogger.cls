public without sharing class ErrorLogger {
    
    public static String LogError(String ComponentName, String ComponentType,
                                          String ErrorMessage, String ErrorDescription, String ErrorCode,
                                          String RecordReference, String AdditionalInfo)
    {
        Error_Log__c er = new Error_Log__c();
        
        er.Component_Name__c=ComponentName;
        er.Component_Type__c=ComponentType;
        
        er.ErrorMessage__c=ErrorMessage;
        er.Error_Description__c=ErrorDescription;
        er.Error_Code__c=ErrorCode;
        
        er.Record_Reference__c = RecordReference.left(255);
        er.Additional_Info__c=AdditionalInfo;
        
        er.Logged_In_User__c=UserInfo.getName();
        insert er;
        return er.Name; 
    }
    
     public static String LogErrorCSV(String ComponentName, String ComponentType,String DocumentType,
                                          String ErrorMessage, String ErrorDescription, String ErrorCode,
                                          String RecordReference, String AdditionalInfo)
    {
        System.debug('In error log csv');
        Error_Log__c er = new Error_Log__c();
        
        er.Component_Name__c=ComponentName;
        er.Component_Type__c=ComponentType;
        er.Document_Type__c=DocumentType;
        er.ErrorMessage__c=ErrorMessage;
        er.Error_Description__c=ErrorDescription;
        er.Error_Code__c=ErrorCode;
        
        er.Record_Reference__c = RecordReference.left(255);
        er.Additional_Info__c=AdditionalInfo;
        
        er.Logged_In_User__c=UserInfo.getName();
        System.debug('Before insert log');
        insert er;
        System.debug('After insert log:'+er.Id+er.Document_Type__c);
        return er.Name; 
    }

}