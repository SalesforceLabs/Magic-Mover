@isTest
public class NMTNoteConversionStatusDeletedTest {
    
    @isTest 
    static void testDeleteNMTNoteConversionStatus() {
        //create 100 legacy notes for contact
        Contact contact1 = NMTTestNoteUtils.createContact();
        Boolean privateNotes = false;
        String noteForContactTitle = 'random note title '+NMTTestNoteUtils.randomInteger();
        List<Note> notes = NMTTestNoteUtils.createNoteForObject(100, contact1.Id, privateNotes, noteForContactTitle);
        Note noteForContact = notes.get(0);
        
        //run the migration
        Test.startTest();
        String migrationType = 'byObject';
        Integer totalToMigrate = 100;
        Date startDate = system.today();
        startDate = startDate.addDays(-30);
        Date endDate = system.today();
        
        String dataString = 'Contact' + ',' + totalToMigrate + '|';
        NMTNotesMigrationController.runMigrationRemote(dataString, migrationType, String.valueOf(startDate), String.valueOf(endDate), true);
        System.assertEquals(true,NMTNoteConversionStatus.isInProgress());
        List<NAMNoteConversionStatus__c> statuses = NMTNoteConversionStatus.find();
        delete statuses;
        
        System.assert(!NMTNoteConversionStatus.isInProgress());
        Test.stopTest();
            
    }
    
    
}