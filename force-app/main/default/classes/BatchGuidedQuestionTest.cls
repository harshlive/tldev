@isTest
public class BatchGuidedQuestionTest {

    @isTest static void guidedTest(){
        
        Account acc=new Account();
        acc.Name='Test';
        insert acc;
                try{
            Test.startTest();          
       		Database.executeBatch(new BatchGuidedQuestion(),50);
            Test.stopTest();
            
        }catch(Exception e){
            System.debug(e.getMessage());
        }        
    }
}