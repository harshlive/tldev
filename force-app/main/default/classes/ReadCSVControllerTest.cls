@isTest
public class ReadCSVControllerTest {
    @isTest 
    public static void readCSVFileTest() {
        Account acc = new Account(accountnumber='HO-18983',name='Aster MIMS');
        insert acc;
        Contact con = new Contact(accountid=acc.id,firstname='Rajesh',lastname='Gopinath',email='tesdt@mail.com',MobilePhone='8787656567');
        insert con;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.csv',
            VersionData =  Blob.valueOf('2021,November,,,,,Translumina,Abbott\nSno.,Name of the Hospital ( No Short Forms Please ),Hospital Id,Name Of Doctors,PTCA,DES,VIVO-CASH,Xience ExpeditionH\n1,Aster MIMS,HO-18983,Rajesh Gopinath,39,0,10,5 ')
        );
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.csv',
            VersionData =  Blob.valueOf('test')
        );
        insert contentVersion;
        ContentVersion cv = [SELECT id,ContentDocumentId FROM ContentVersion WHERE id=:contentVersion.id LIMIT 1];
        system.debug(cv.ContentDocumentId);
        ReadCSVController.readCSVFile(cv.ContentDocumentId,'SecondaryActuals');
        insert contentVersion2;
        ContentVersion cv2 = [SELECT id,ContentDocumentId FROM ContentVersion WHERE id=:contentVersion2.id LIMIT 1];
        ReadCSVController.readCSVFile(cv2.ContentDocumentId,'SecondaryActuals');
        
        
    }
    @isTest 
    public static void readCSVFilePrimaryTest() {
        Account acc = new Account(accountnumber='HO-18983',name='Aster MIMS');
        insert acc;
        Contact con = new Contact(accountid=acc.id,firstname='Rajesh',lastname='Gopinath',email='tesdt@mail.com',MobilePhone='8787656567');
        insert con;
        product2 p =new product2(name='Flex');
        insert p;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.csv',
            VersionData =  Blob.valueOf('2021,January,,,Flex,,,Racer CC,,,PC,,,PC Plus,,,Elite,,,VIVO ISAR,,,Non Premium Stents,,,,Premium Stents,,,,OPN NC,,,,Yukon Balloon,,,,VA,,,\nName of the state,Manager,TSM ID,Name of TSM,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales\nWest Bengal,Madhumita Das,TTLLP333,Madhumita Das,10,5,0,10,5,0,0,5,0,0,5,0,0,5,0,0,5,0,0,5,0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0')
        );
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.csv',
            VersionData =  Blob.valueOf('test')
        );
        
        ContentVersion cv3 = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.csv',
            VersionData =  Blob.valueOf('2021,February,,,Flex,,,Racer CC,,,PC,,,PC Plus,,,Elite,,,VIVO ISAR,,,Non Premium Stents,,,,Premium Stents,,,,OPN NC,,,,Yukon Balloon,,,,VA,,,\nName of the state,Manager,TSM ID,Name of TSM,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales\nWest Bengal,Madhumita Das,TTLLP333,Madhumita Das,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,0,20,15,0,30,20,0,30,15,20,30,15,0,20,30,15,10')
        );
        insert cv3;
        ContentVersion cv4 = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.csv',
            VersionData =  Blob.valueOf('2021,March,,,Flex,,,Racer CC,,,PC,,,PC Plus,,,Elite,,,VIVO ISAR,,,Non Premium Stents,,,,Premium Stents,,,,OPN NC,,,,Yukon Balloon,,,,VA,,,\nName of the state,Manager,TSM ID,Name of TSM,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales\nWest Bengal,Madhumita Das,TTLLP333,Madhumita Das,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,0,20,15,0,30,20,0,30,15,20,30,15,0,20,30,15,10')
        );
        insert cv4;
        ContentVersion cv5 = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.csv',
            VersionData =  Blob.valueOf('2021,April,,,Flex,,,Racer CC,,,PC,,,PC Plus,,,Elite,,,VIVO ISAR,,,Non Premium Stents,,,,Premium Stents,,,,OPN NC,,,,Yukon Balloon,,,,VA,,,\nName of the state,Manager,TSM ID,Name of TSM,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales\nWest Bengal,Madhumita Das,TTLLP333,Madhumita Das,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,0,20,15,0,30,20,0,30,15,20,30,15,0,20,30,15,10')
        );
        insert cv5;
        
        ContentVersion cv6 = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.csv',
            VersionData =  Blob.valueOf('2021,May,,,Flex,,,Racer CC,,,PC,,,PC Plus,,,Elite,,,VIVO ISAR,,,Non Premium Stents,,,,Premium Stents,,,,OPN NC,,,,Yukon Balloon,,,,VA,,,\nName of the state,Manager,TSM ID,Name of TSM,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales\nWest Bengal,Madhumita Das,TTLLP333,Madhumita Das,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,0,20,15,0,30,20,0,30,15,20,30,15,0,20,30,15,10')
        );
        insert cv6;
        
        ContentVersion cv7 = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.csv',
            VersionData =  Blob.valueOf('2021,June,,,Flex,,,Racer CC,,,PC,,,PC Plus,,,Elite,,,VIVO ISAR,,,Non Premium Stents,,,,Premium Stents,,,,OPN NC,,,,Yukon Balloon,,,,VA,,,\nName of the state,Manager,TSM ID,Name of TSM,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales\nWest Bengal,Madhumita Das,TTLLP333,Madhumita Das,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,0,20,15,0,30,20,0,30,15,20,30,15,0,20,30,15,10')
        );
        insert cv7;
        
        ContentVersion cv8 = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.csv',
            VersionData =  Blob.valueOf('2021,July,,,Flex,,,Racer CC,,,PC,,,PC Plus,,,Elite,,,VIVO ISAR,,,Non Premium Stents,,,,Premium Stents,,,,OPN NC,,,,Yukon Balloon,,,,VA,,,\nName of the state,Manager,TSM ID,Name of TSM,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales\nWest Bengal,Madhumita Das,TTLLP333,Madhumita Das,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,0,20,15,0,30,20,0,30,15,20,30,15,0,20,30,15,10')
        );
        insert cv8;
        
        ContentVersion cv9 = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.csv',
            VersionData =  Blob.valueOf('2021,August,,,Flex,,,Racer CC,,,PC,,,PC Plus,,,Elite,,,VIVO ISAR,,,Non Premium Stents,,,,Premium Stents,,,,OPN NC,,,,Yukon Balloon,,,,VA,,,\nName of the state,Manager,TSM ID,Name of TSM,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales\nWest Bengal,Madhumita Das,TTLLP333,Madhumita Das,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,0,20,15,0,30,20,0,30,15,20,30,15,0,20,30,15,10')
        );
        insert cv9;
        
        ContentVersion cv10 = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.csv',
            VersionData =  Blob.valueOf('2021,September,,,Flex,,,Racer CC,,,PC,,,PC Plus,,,Elite,,,VIVO ISAR,,,Non Premium Stents,,,,Premium Stents,,,,OPN NC,,,,Yukon Balloon,,,,VA,,,\nName of the state,Manager,TSM ID,Name of TSM,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales\nWest Bengal,Madhumita Das,TTLLP333,Madhumita Das,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,0,20,15,0,30,20,0,30,15,20,30,15,0,20,30,15,10')
        );
        insert cv10;
        ContentVersion cv11 = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.csv',
            VersionData =  Blob.valueOf('2021,October,,,Flex,,,Racer CC,,,PC,,,PC Plus,,,Elite,,,VIVO ISAR,,,Non Premium Stents,,,,Premium Stents,,,,OPN NC,,,,Yukon Balloon,,,,VA,,,\nName of the state,Manager,TSM ID,Name of TSM,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales\nWest Bengal,Madhumita Das,TTLLP333,Madhumita Das,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,0,20,15,0,30,20,0,30,15,20,30,15,0,20,30,15,10')
        );
        insert cv11;
        ContentVersion cv12 = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.csv',
            VersionData =  Blob.valueOf('2021,November,,,Flex,,,Racer CC,,,PC,,,PC Plus,,,Elite,,,VIVO ISAR,,,Non Premium Stents,,,,Premium Stents,,,,OPN NC,,,,Yukon Balloon,,,,VA,,,\nName of the state,Manager,TSM ID,Name of TSM,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales\nWest Bengal,Madhumita Das,TTLLP333,Madhumita Das,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,0,20,15,0,30,20,0,30,15,20,30,15,0,20,30,15,10')
        );
        insert cv12;
        
        ContentVersion cv13 = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.csv',
            VersionData =  Blob.valueOf('2021,December,,,Flex,,,Racer CC,,,PC,,,PC Plus,,,Elite,,,VIVO ISAR,,,Non Premium Stents,,,,Premium Stents,,,,OPN NC,,,,Yukon Balloon,,,,VA,,,\nName of the state,Manager,TSM ID,Name of TSM,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales,Target,Achievements,GRN,Net Sales\nWest Bengal,Madhumita Das,TTLLP333,Madhumita Das,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,10,5,0,0,20,15,0,30,20,0,30,15,20,30,15,0,20,30,15,10')
        );
        insert cv13;
        
        insert contentVersion;
        try{
            ContentVersion cv = [SELECT id,ContentDocumentId FROM ContentVersion WHERE id=:contentVersion.id LIMIT 1];
            ReadCSVController.readCSVFile(cv.ContentDocumentId,'PrimaryTargets');
            insert contentVersion2;
            ContentVersion cv2 = [SELECT id,ContentDocumentId FROM ContentVersion WHERE id=:contentVersion2.id LIMIT 1];
            ReadCSVController.readCSVFile(cv2.ContentDocumentId,'PrimaryTargets');
            ContentVersion c3 = [SELECT id,ContentDocumentId FROM ContentVersion WHERE id=:cv3.id LIMIT 1];
            ReadCSVController.readCSVFile(c3.ContentDocumentId,'PrimaryTargets');
            ContentVersion c4 = [SELECT id,ContentDocumentId FROM ContentVersion WHERE id=:cv4.id LIMIT 1];
            ReadCSVController.readCSVFile(c4.ContentDocumentId,'PrimaryTargets');
            ContentVersion c6 = [SELECT id,ContentDocumentId FROM ContentVersion WHERE id=:cv6.id LIMIT 1];
            ReadCSVController.readCSVFile(c6.ContentDocumentId,'PrimaryTargets');
            ContentVersion c7 = [SELECT id,ContentDocumentId FROM ContentVersion WHERE id=:cv7.id LIMIT 1];
            ReadCSVController.readCSVFile(c7.ContentDocumentId,'PrimaryTargets');
            ContentVersion c8 = [SELECT id,ContentDocumentId FROM ContentVersion WHERE id=:cv8.id LIMIT 1];
            ReadCSVController.readCSVFile(c8.ContentDocumentId,'PrimaryTargets');
            ContentVersion c9 = [SELECT id,ContentDocumentId FROM ContentVersion WHERE id=:cv9.id LIMIT 1];
            ReadCSVController.readCSVFile(c9.ContentDocumentId,'PrimaryTargets');
            ContentVersion c5 = [SELECT id,ContentDocumentId FROM ContentVersion WHERE id=:cv5.id LIMIT 1];
            ReadCSVController.readCSVFile(c5.ContentDocumentId,'PrimaryTargets');
            ContentVersion c10 = [SELECT id,ContentDocumentId FROM ContentVersion WHERE id=:cv10.id LIMIT 1];
            ReadCSVController.readCSVFile(c10.ContentDocumentId,'PrimaryTargets');
            /*ContentVersion c11 = [SELECT id,ContentDocumentId FROM ContentVersion WHERE id=:cv11.id LIMIT 1];
            ReadCSVController.readCSVFile(c11.ContentDocumentId,'PrimaryTargets');
            ContentVersion c12 = [SELECT id,ContentDocumentId FROM ContentVersion WHERE id=:cv12.id LIMIT 1];
            ReadCSVController.readCSVFile(c12.ContentDocumentId,'PrimaryTargets');
            ContentVersion c13 = [SELECT id,ContentDocumentId FROM ContentVersion WHERE id=:cv13.id LIMIT 1];
            ReadCSVController.readCSVFile(c13.ContentDocumentId,'PrimaryTargets');*/
        }catch(Exception e){
            System.debug('exception:'+e.getMessage());
        }
        
        
    }
    
    @isTest 
    public static void readCSVFileSecondaryTargetTest() {
        Account acc = new Account(accountnumber='HO-18983',name='Aster MIMS');
        insert acc;
        Contact con = new Contact(accountid=acc.id,firstname='Rajesh',lastname='Gopinath',email='tesdt@mail.com',MobilePhone='8787656567');
        insert con;
        product2 p =new product2(name='Flex');
        insert p;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.csv',
            VersionData =  Blob.valueOf('2021,May,,,,Target-Secondary (Current FY),,,,,\nTSM ID,TSM,Hospital Id,Hospital Name,Product Name,January,February,March,April,May,June\nTTLLP333,Madhumita Das,HO12345,Batch L1 Hospital,Premium,5,10,15,20,25,30\nTTLLP333,Madhumita Das,HO12345,Batch L1 Hospital,Non Premium,5,10,15,20,25,30\nTTLLP333,Madhumita Das,HO12345,Batch L1 Hospital,Vivo Isar,5,10,15,20,25,30'
                                       )
        );
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.csv',
            VersionData =  Blob.valueOf('test')
        );
        insert contentVersion;
        ContentVersion cv = [SELECT id,ContentDocumentId FROM ContentVersion WHERE id=:contentVersion.id LIMIT 1];
        system.debug(cv.ContentDocumentId);
        ReadCSVController.readCSVFile(cv.ContentDocumentId,'SecondaryTargets');
        insert contentVersion2;
        ContentVersion cv2 = [SELECT id,ContentDocumentId FROM ContentVersion WHERE id=:contentVersion2.id LIMIT 1];
        ReadCSVController.readCSVFile(cv2.ContentDocumentId,'SecondaryTargets');
        
        
    }
}