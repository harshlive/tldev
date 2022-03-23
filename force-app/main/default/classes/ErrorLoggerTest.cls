@isTest
private class ErrorLoggerTest {
    @isTest static void myTest() {
        
ErrorLogger.LogError('Anon Window', 'Test Apex Code','Limit Exception',
                     'Hey this is a description Dump Exverything here', 'API Error code 500',
                     'RecordID', 
                     'Put the JSON Here');
    
    ErrorLogger.LogErrorCSV('Anon Window', 'Test Apex Code','Test Document Type','Limit Exception',
                     'Hey this is a description Dump Exverything here', 'API Error code 500',
                     'RecordID', 
                     'Put the JSON Here');
    }
}