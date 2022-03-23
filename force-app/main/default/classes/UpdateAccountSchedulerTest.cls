@isTest
public class UpdateAccountSchedulerTest {
    
    @isTest static void schedulerTest() {
        try{
            Test.startTest();          
            UpdateAccountScheduler.scheduleBatch();        
            Test.stopTest();
            
        }catch(Exception e){
            System.debug(e.getMessage());
        }        
    }
}