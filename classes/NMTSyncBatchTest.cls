@isTest
public class NMTSyncBatchTest {
    
    @isTest
    static void test(){
        
         Contact contact = NMTTestNoteUtils.createContact();
        //create one legacy note
        List<Note> notes = NMTTestNoteUtils.createNoteForObject(1, contact.Id, false);
        
        Note oldNote = notes.get(0);
        
        ContentVersion cv = new ContentVersion();
         // data fields
        cv.title = oldNote.title;
        cv.versionData = Blob.valueOf(oldNote.body);
        cv.pathOnClient = oldNote.title + '.snote';
        
        //we need this field in order to know which note match with this CV in case the user deletes it.
        cv.LegacyNoteConvertedId__c = oldNote.id;
        cv.LegacyNoteConvertedDate__c = System.today();
        
        cv.FirstPublishLocationId = oldNote.parentId;
        cv.Origin = 'H'; 
        
        insert cv;
        
        Test.startTest();
        
        NMTSyncBatch batch = new NMTSyncBatch();
        String batchId = Database.executeBatch(batch, 100);
        
        Test.stopTest();
    }
}