@isTest
public class DeploymentFormControllerTest {

    @isTest static void saveDeploymentsTest(){
        Account acc=new Account();
        acc.Name='ABC';
        
        insert acc;
        Daily_Deployment__c ddy=new Daily_Deployment__c();
        ddy.Month__c='May';
        ddy.Product_Family__c='VA';
        ddy.Product_Name__c='Agile';
        ddy.Year__c=2021;
        ddy.Week_1_Amount__c=10;
        ddy.Week_2_Amount__c=110;
        ddy.Week_3_Amount__c=10;
        ddy.Week_4_Amount__c=10;
        ddy.Week_5_Amount__c=10; 
        ddy.Account__c=acc.Id; 
        List<Daily_Deployment__c> depList=new List<Daily_Deployment__c>();
        depList.add(ddy);
        DeploymentFormController.saveDeployments(depList);
    }
    
    @isTest static void getVaDeploymentsTest(){
        Account acc=new Account();
        acc.Name='ABC';
        
        insert acc;
        DeploymentFormController.getVaDeployments(acc.Id,2021,'May');
    }
    
    @isTest static void getContactTest(){
        Account acc=new Account();
        acc.Name='ABC';
        
        insert acc;
        Contact con=new Contact();
        con.LastName='Test';
        con.AccountId=acc.Id;
        con.Email='abpw@gmail.com';
        con.MobilePhone='9099999090';
        insert con;
        DeploymentFormController.getContact(acc.Id);
        DeploymentFormController.getContactDetails(acc.Id, 2021, 'May');
        
    }
}