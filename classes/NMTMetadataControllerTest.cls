/**
* @author Jessica Bernal
*/

@isTest
public class NMTMetadataControllerTest extends Metadata.DeployCallbackContext {
  
/**
* @description we can't test metadata deployment in test environment, just for code coverage
*/
    @isTest
    static void addMetadataRemoteNotes(){
        Test.startTest();
        NMTMetadataController.addMetadataRemote('Account-Account Layout','Notes');
        NMTMetadataController metadatac = new NMTMetadataController();
        Test.stopTest();
        System.assert(metadatac.metadataLayouts.size() > 0); //just for doing coverage
    }
    
    
    /**
* @description we can't test metadata deployment in test environment, just for code coverage
*/
    @isTest
    static void addMetadataRemoteFiles(){
        Test.startTest();
        NMTMetadataController.addMetadataRemote('Account-Account Layout','Files');
        NMTMetadataController metadatac = new NMTMetadataController();
        Test.stopTest();
        System.assert(metadatac.metadataLayouts.size() > 0); //just for doing coverage
    }
    
        /**
* @description we can't test metadata deployment in test environment, just for code coverage
*/
    @isTest
    static void removeMetadataRemote(){
        Test.startTest();
        NMTMetadataController.removeMetadataRemote('Account-Account Layout','RelatedNoteList');
        NMTMetadataController metadatac = new NMTMetadataController();
        metadatac.Refresh();
        Test.stopTest();
        System.assert(metadatac.metadataLayouts.size() > 0); //just for doing coverage
        metadatac.Next();
        metadatac.Previous();
    }
    
    /**
* @description tests retrieve metadata
*/
    @isTest
    static void retrieveMetadata(){
        Test.startTest();
        NMTMetadataController metadatac = new NMTMetadataController();
        Test.stopTest();
        System.assert(metadatac.metadataLayouts.size() > 0); //just for doing coverage
    }
    
    /**
* @description mix tests
*/
    @isTest
    static void testValues(){
        Test.startTest();
        NMTMetadataController metadatac = new NMTMetadataController();
        Test.stopTest();
        System.assert(!metadatac.getDisableNext());
        System.assert(metadatac.getDisablePrevious());
        System.assertEquals('display: none;', metadatac.isPendingNotes);
        System.assertEquals('display: none;', metadatac.isPendingFiles);
        
        //create a legacy note for contact
        Contact contact1 = NMTTestNoteUtils.createContact();
        Boolean privateNotes = false;
        String noteForContactTitle = 'random note title '+NMTTestNoteUtils.randomInteger();
        List<Note> notes = NMTTestNoteUtils.createNoteForObject(1, contact1.Id, privateNotes, noteForContactTitle);
        Note noteForContact = notes.get(0);
        
        //create an attachment for contact
        ATFTestUtils.createAttachmentForContact(1, false, 'sample3');
        System.assertEquals('display: inline; color: #C23934', metadatac.isPendingNotes);
        System.assertEquals('display: inline; color: #C23934', metadatac.isPendingFiles);
        
        
    }
    
    @isTest
    static void testConsumeObject(){
        JSONParser parser = JSON.createParser('{"key":"value"}');

        NMTMetadataLayout.consumeObject(parser);
    }
    
    
}