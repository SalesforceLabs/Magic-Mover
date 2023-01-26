/**
* @description 
* @author Andres Canavesi
*/

@isTest
public class NMTDeleteBatchTest {
    
    /**
* @description tests that after legacy notes deletion. This method doe snot tests migration
* Test Case Name: Delete converted legacy notes
*/
    @isTest
    static void testNotestDeletionTrigger(){
        if(NAMUtils.isEnhancedNotesEnabled()||NAMUtils.ENABLE_NOTES_TESTS){
        /*
* Steps: 
* - create a legacy note
* - migrate the legacy note using the MigrationBatchHelper to do it syncronously
* - (in this method we do not test migration success)
* - assert the legacy note created was deleted
*/
        
        //create a legacy note
        Contact contact1 = NMTTestNoteUtils.createContact();
        Boolean privateNotes = false;
        String noteTitle = 'random note title '+NMTTestNoteUtils.randomInteger();
        List<Note> notes = NMTTestNoteUtils.createNoteForObject(1, contact1.Id, privateNotes, noteTitle);
        Id noteId = notes.get(0).Id;
        NMTMigratorBatchHelper.migrateToContentNoteUsingContentVersion(notes,'Contact');
        NMTNoteConversionStatus.changeStatus('Completed', null,'Convertion');
        
        //assert over NAMNoteConversionStatus__c object 
        NAMNoteConversionStatus__c status = NMTNoteConversionStatus.findStatus();
        
        Test.startTest();
        NMTDeleteBatch deleteBatch = new NMTDeleteBatch('Contact', System.today(), System.today(), true); 
        String deleteBatchJobId = Database.executeBatch(deleteBatch);
        System.assert(deleteBatchJobId != null);
        Test.stopTest();
        
        //assert the legacy note created was deleted
        List<Note> notesDeleted = [select id from note where id = :noteId];
        System.assertEquals(0, notesDeleted.size(),'The note converted was not deleted');
        }
    }
    
    
    /**
* @description tests that after legacy notes deletion. This method doe snot tests migration (the note belongs to a standard user)
* Test Case Name: Delete converted legacy notes from standard user
*/
    @isTest
    static void testNotestDeletionStandardUser(){
        if(NAMUtils.isEnhancedNotesEnabled()||NAMUtils.ENABLE_NOTES_TESTS){
        /*
* Steps: 
* - create a legacy note from a standard user
* - migrate the legacy note using the MigrationBatchHelper to do it syncronously
* - (in this method we do not test migration success)
* - assert the legacy note created was deleted
*/
        
        //create a legacy note from a standard user
        
        // Setup test data
        // This code runs as the system user
      Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
      User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
      LocaleSidKey='en_US', ProfileId = p.Id,
      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@notes.attachments.testorg.com');
 
      System.runAs(u) {
         // The following code runs as user 'u'
        Contact contact1 = NMTTestNoteUtils.createContact();
        Boolean privateNotes = false;
        String noteTitle = 'random note title '+NMTTestNoteUtils.randomInteger();
        NMTTestNoteUtils.createNoteForObject(1, contact1.Id, privateNotes, noteTitle);
      }
        
        // This code runs as the system user
        List<Note> notes = [SELECT Id, Title, Body, Parent.Type, OwnerId, LastModifiedDate, CreatedDate, CreatedById, LastModifiedById, IsPrivate FROM Note];
        //Assert that a note was created
        System.assertEquals(1, notes.size());
        
        Id noteId = notes.get(0).Id;
        //Run the migration
        NMTMigratorBatchHelper.migrateToContentNoteUsingContentVersion(notes,'Contact');
        NMTNoteConversionStatus.changeStatus('Completed', null,'Convertion');
        
        //assert over NAMNoteConversionStatus__c object 
        NAMNoteConversionStatus__c status = NMTNoteConversionStatus.findStatus();
        
        Test.startTest();
        //run deletion
        NMTDeleteBatch deleteBatch = new NMTDeleteBatch('Contact', System.today(), System.today(), true); 
        String deleteBatchJobId = Database.executeBatch(deleteBatch);
        System.assert(deleteBatchJobId != null);
        Test.stopTest();
        
        //assert the legacy note created was deleted
        List<Note> notesDeleted = [select id from note where id = :noteId];
        System.assertEquals(0, notesDeleted.size(),'The note converted was not deleted');
        }
    }
    
    /**
* @description tests that after legacy notes deletion. This method doe snot tests migration (the note belongs to an inactive user)
* Test Case Name: Delete converted legacy notes from inactive user
*/
    @isTest
    static void testNotestDeletionInactiveUser(){
        if(NAMUtils.isEnhancedNotesEnabled()||NAMUtils.ENABLE_NOTES_TESTS){
        /*
* Steps: 
* - create a legacy note from a standard user
* - put the user inactive
* - migrate the legacy note using the MigrationBatchHelper to do it syncronously
* - (in this method we do not test migration success)
* - assert the legacy note created was deleted
*/
        
        //create a legacy note from a standard user
        
        // Setup test data
        // This code runs as the system user
      Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
      User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
      LocaleSidKey='en_US', ProfileId = p.Id,
      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@notes.attachments.testorg.com');
 
      System.runAs(u) {
         // The following code runs as user 'u'
        Contact contact1 = NMTTestNoteUtils.createContact();
        Boolean privateNotes = false;
        String noteTitle = 'random note title '+NMTTestNoteUtils.randomInteger();
        NMTTestNoteUtils.createNoteForObject(1, contact1.Id, privateNotes, noteTitle);
      }
        
        u.IsActive = false; 
        
        // This code runs as the system user
        List<Note> notes = [SELECT Id, Title, Body, Parent.Type, OwnerId, LastModifiedDate, CreatedDate, CreatedById, LastModifiedById, IsPrivate FROM Note];
        //Assert that a note was created
        System.assertEquals(1, notes.size());
        
        Id noteId = notes.get(0).Id;
        //Run the migration
        NMTMigratorBatchHelper.migrateToContentNoteUsingContentVersion(notes,'Contact');
        NMTNoteConversionStatus.changeStatus('Completed', null,'Convertion');
        
        //assert over NAMNoteConversionStatus__c object 
        NAMNoteConversionStatus__c status = NMTNoteConversionStatus.findStatus();
        
        Test.startTest();
        //run deletion
        NMTDeleteBatch deleteBatch = new NMTDeleteBatch('Contact', System.today(), System.today(), true); 
        String deleteBatchJobId = Database.executeBatch(deleteBatch);
        System.assert(deleteBatchJobId != null);
        Test.stopTest();
        
        //assert the legacy note created was deleted
        List<Note> notesDeleted = [select id from note where id = :noteId];
        System.assertEquals(0, notesDeleted.size(),'The note converted was not deleted');
        }
    }
    
}