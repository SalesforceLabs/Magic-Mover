@isTest
public class NAMLastAttachmentsControllerTest {
    
    /**
* @description
* @return als attachments that have been migrated
*/
    static List<Attachment> getMigratedAttachments(){
        return [SELECT Id, Name FROM Attachment WHERE Name LIKE :NAMUtils.MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN];
    }
    
    @isTest 
    static void construct() {
        NAMLastAttachmentsController controller = new NAMLastAttachmentsController();
        controller.getEmpty();
        controller.getorderByOptions ();
        controller.orderBy();
        controller.Next();
        controller.Previous();
        controller.getDisableNext();
        controller.getDisablePrevious();
        controller.loadInfo();
        String v = controller.version;
        System.assertEquals(0, controller.lastAttachments.size());
    }
    
    @isTest 
    static void construct2() {
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id;  
        ATFTestUtils.createAttachmentForObject(1, parentId, false, 'sample'+Math.random());//1 public attachment
        ATFTestUtils.createAttachmentForObject(1, parentId, true, 'sample'+Math.random());//1 private attachment
        NMTTestNoteUtils.sleep(6);
        NAMLastAttachmentsController controller = new NAMLastAttachmentsController();
        controller.migratedString = 'false';
        controller.loadInfo();
        System.assertEquals(2, controller.lastAttachments.size());
    }
    
    @isTest 
    static void runMigration() {
         Test.startTest();
        //setup
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id;  
        ATFTestUtils.createAttachmentForObject(1, parentId, false, 'sample3');//1 public attachment
        NMTTestNoteUtils.sleep(6);
        NAMLastAttachmentsController controller = new NAMLastAttachmentsController();
        controller.migratedString = 'false';
        controller.loadInfo();
        System.assertEquals(1, controller.lastAttachments.size());
        Attachment attach= [SELECT Id, OwnerId FROM Attachment LIMIT 1];
        //end setup
        
        List<String> resultAux = new List<String>();
        String sObjectsWrapperAsJson = '';
        //get the id
        resultAux.add(attach.Id);
        sObjectsWrapperAsJson+=attach.Id+',';
        NAMLastAttachmentsController.runConvertionRemote(sObjectsWrapperAsJson);
        
        //end setup
        Test.stopTest();
        controller.loadInfo();
        System.assertEquals(0, controller.lastAttachments.size());
    }
    
    @isTest 
    static void runMigrationOnlyOne() {
         Test.startTest();
        //setup
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id;  
        ATFTestUtils.createAttachmentForObject(2, parentId, false, 'sample3');//1 public attachment
        NMTTestNoteUtils.sleep(6);
        NAMLastAttachmentsController controller = new NAMLastAttachmentsController();
        controller.migratedString = 'false';
        controller.loadInfo();
        System.assertEquals(2, controller.lastAttachments.size());
        Attachment attach= [SELECT Id, OwnerId FROM Attachment LIMIT 1];
        //end setup
        
        List<String> resultAux = new List<String>();
        String sObjectsWrapperAsJson = '';
        //get the id
        resultAux.add(attach.Id);
        sObjectsWrapperAsJson+=attach.Id+',';
        NAMLastAttachmentsController.runConvertionRemote(sObjectsWrapperAsJson);
        
        //end setup
        Test.stopTest();
        controller.loadInfo();
        System.assertEquals(1, controller.lastAttachments.size());
    }
    
    @isTest 
    static void runMigration2() {
         Test.startTest();
        //setup
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id;  
        ATFTestUtils.createAttachmentForObject(1, parentId, true, 'ample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3sample3samplre3fff');//1 public attachment
        NMTTestNoteUtils.sleep(6);
        NAMLastAttachmentsController controller = new NAMLastAttachmentsController();
        controller.migratedString = 'false';
        controller.loadInfo();
        System.assertEquals(1, controller.lastAttachments.size());
        Attachment attach= [SELECT Id, OwnerId FROM Attachment LIMIT 1];
        //end setup
        
        List<String> resultAux = new List<String>();
        String sObjectsWrapperAsJson = '';
        //get the id
        resultAux.add(attach.Id);
        sObjectsWrapperAsJson+=attach.Id+',';
        NAMLastAttachmentsController.runConvertionRemote(sObjectsWrapperAsJson);
         Test.stopTest();
        
        controller.loadInfo();
        System.assertEquals(0, controller.lastAttachments.size());
        
       
        List <Attachment> attachments = getMigratedAttachments();
        System.assertEquals(1, attachments.size());
        
        List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE
                                          linkedEntityId = :c.Id];
        System.assertEquals(1, cdls.size());
        
        ContentVersion cv = [SELECT Id, OwnerId FROM ContentVersion LIMIT 1];
        System.assertEquals(attach.OwnerId, cv.OwnerId);
    }

}