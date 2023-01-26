@isTest
public class NAMlastConvertedControllerTest {
    
    @isTest 
    static void construct() {
        Test.startTest();
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id;  
        ATFTestUtils.createAttachmentForObject(1, parentId, false, 'sample3');
        ATFAttachmentsToFilesController controllerAttachment = new ATFAttachmentsToFilesController();
        controllerAttachment.deleteAfterMigration = false;
        Attachment attach= [SELECT Id, OwnerId FROM Attachment LIMIT 1];
        //end setup
        
        List<String> resultAux = new List<String>();
        String sObjectsWrapperAsJson = '';
        //get the id
        resultAux.add(attach.Id);
        sObjectsWrapperAsJson+=parentId+',';
        
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        ATFAttachmentsToFilesController.runMigrationRemote(sObjectsWrapperAsJson, 'byObjectId', dateSt, dateEn, true);
        
        NMTTestNoteUtils.sleep(6);
        Test.stopTest();
        
        NAMlastConvertedController controller = new NAMlastConvertedController();
        controller.Next();
        controller.Previous();
        controller.getDisableNext();
        controller.getDisablePrevious();
        String v = controller.version;
        System.assertEquals(1, controller.lastConverted.size());
    }
    
    @isTest 
    static void construct2() {
        
        Test.startTest();
        Contact cNote = NMTTestNoteUtils.createContact();
        //create two legacy note
        List<Note> notes = NMTTestNoteUtils.createNoteForObject(2, cNote.Id, false);
        List<String> resultAuxNote = new List<String>();
        String sObjectsWrapperAsJsonNote = '';
        //get the ids
        for(Note note:notes)
        {
            resultAuxNote.add(note.Id);
            sObjectsWrapperAsJsonNote+=note.Id+',';
        }
        //run the migration by Ids  
        NMTNotesMigrationController.runMigrationRemote(sObjectsWrapperAsJsonNote,'byId', '2017-08-08', '2017-08-08', true);
        
        NMTTestNoteUtils.sleep(6);
        Test.stopTest();
        
        NAMlastConvertedController controller = new NAMlastConvertedController();
        System.assertEquals(2, controller.lastConverted.size());
    }
    
}