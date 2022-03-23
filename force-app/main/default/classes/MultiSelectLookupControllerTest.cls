@isTest
public class MultiSelectLookupControllerTest {
    @isTest static void retrieveRecordsTest() {
        Product2 prd = new Product2(name = 'test prod');
        insert prd;
        MultiSelectLookupController.retrieveRecords('Product2', 'name', 'name', 'test');
    }
}