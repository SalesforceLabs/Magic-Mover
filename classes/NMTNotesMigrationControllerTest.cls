/**
* @description 
* @author Dayana Daniel, Jessica Bernal, Andres Canavesi
*/

@isTest
public class NMTNotesMigrationControllerTest {
    
    /**
* @description tests by note id
* Test Case Name: Migrate by id separated by comma
*/
    @isTest
    static void testRunMigrationById(){
        if(NAMUtils.isEnhancedNotesEnabled()||NAMUtils.ENABLE_NOTES_TESTS){
            /*
* Steps:
* - create a contact 
* - create two legacy note
* - get the ids
* - run the migration by Ids
* - assert 2 ContentVersions were created
* - assert 2 CDLs were created
*/
            
            Contact c = NMTTestNoteUtils.createContact();
            //create two legacy note
            List<Note> notes = NMTTestNoteUtils.createNoteForObject(2, c.Id, false);
            List<String> resultAux = new List<String>();
            String sObjectsWrapperAsJson = '';
            //get the ids
            for(Note note:notes)
            {
                resultAux.add(note.Id);
                sObjectsWrapperAsJson+=note.Id+',';
            }
            
            //assert that 2 Legacy Notes were created
            System.assertEquals(2, resultAux.size(), '2 Legacy Notes created to migrate');
            
            Test.startTest();
            //run the migration by Ids  
            NMTNotesMigrationController.runMigrationRemote(sObjectsWrapperAsJson,'byId', '2017-08-08', '2017-08-08', true);
            Test.stopTest();
            
            List<NAMNoteConverted__c> contentVersions = [SELECT Id FROM NAMNoteConverted__c WHERE LegacyNoteConvertedId__c in :resultAux];
            //assert 2 contentVersions were created
            System.assertEquals(2, contentVersions.size(), '2 Content Notes created');
            
            List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE
                                              linkedEntityId = :c.Id
                                              AND
                                              contentDocument.latestPublishedVersion.LegacyNoteConvertedId__c in :resultAux];
            //assert 2 CDLs were created
            System.assertEquals(2, cdls.size(), '2 Content Notes linked to the parent Contact');
        }
    }
    
    @isTest
    static void testRunMigrationByIdFalseParameter(){
        if(NAMUtils.isEnhancedNotesEnabled()||NAMUtils.ENABLE_NOTES_TESTS){
            /*
* Steps:
* - create a contact 
* - create two legacy note
* - get the ids
* - run the migration by Ids
* - assert 2 ContentVersions were created
* - assert 2 CDLs were created
*/
            
            Contact c = NMTTestNoteUtils.createContact();
            //create two legacy note
            List<Note> notes = NMTTestNoteUtils.createNoteForObject(2, c.Id, false);
            List<String> resultAux = new List<String>();
            String sObjectsWrapperAsJson = '';
            //get the ids
            for(Note note:notes)
            {
                resultAux.add(note.Id);
                sObjectsWrapperAsJson+=note.Id+',';
            }
            
            //assert that 2 Legacy Notes were created
            System.assertEquals(2, resultAux.size(), '2 Legacy Notes created to migrate');
            
            Test.startTest();
            //run the migration by Ids  
            NMTNotesMigrationController.runMigrationRemote(sObjectsWrapperAsJson,'byId', '2017-08-08', '2017-08-08', false);
            Test.stopTest();
            
            List<NAMNoteConverted__c> contentVersions = [SELECT Id FROM NAMNoteConverted__c WHERE LegacyNoteConvertedId__c in :resultAux];
            //assert 2 contentVersions were created
            System.assertEquals(2, contentVersions.size(), '2 Content Notes created');
            
            List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE
                                              linkedEntityId = :c.Id
                                              AND
                                              contentDocument.latestPublishedVersion.LegacyNoteConvertedId__c in :resultAux];
            //assert 2 CDLs were created
            System.assertEquals(2, cdls.size(), '2 Content Notes linked to the parent Contact');
        }
    }
    
    /**
* @description tests by note id by new line
* Test Case Name: Migrate by id separated by new line
*/
    @isTest
    static void testRunMigrationByIdNewLine(){
        if(NAMUtils.isEnhancedNotesEnabled()||NAMUtils.ENABLE_NOTES_TESTS){
            /*
* Steps:
* - create a contact 
* - create two legacy note
* - get the ids
* - run the migration by Ids
* - assert 2 ContentVersions were created
* - assert 2 CDLs were created
*/
            
            Contact c = NMTTestNoteUtils.createContact();
            //create two legacy note
            List<Note> notes = NMTTestNoteUtils.createNoteForObject(2, c.Id, false);
            List<String> resultAux = new List<String>();
            String sObjectsWrapperAsJson = '';
            //get the ids
            for(Note note:notes)
            {
                resultAux.add(note.Id);
                sObjectsWrapperAsJson+=note.Id+'\n';
            }
            
            //assert that 2 Legacy Notes were created
            System.assertEquals(2, resultAux.size(), '2 Legacy Notes created to migrate');
            
            Test.startTest();
            //run the migration by Ids  
            NMTNotesMigrationController.runMigrationRemote(sObjectsWrapperAsJson,'byId', '2017-08-08', '2017-08-08', true);
            Test.stopTest();
            
            List<NAMNoteConverted__c> contentVersions = [SELECT Id FROM NAMNoteConverted__c WHERE LegacyNoteConvertedId__c in :resultAux];
            //assert 2 contentVersions were created
            System.assertEquals(2, contentVersions.size(), '2 Content Notes created');
            
            List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE
                                              linkedEntityId = :c.Id
                                              AND
                                              contentDocument.latestPublishedVersion.LegacyNoteConvertedId__c in :resultAux];
            //assert 2 CDLs were created
            System.assertEquals(2, cdls.size(), '2 Content Notes linked to the parent Contact');
        }
    }
    
    /**
* @description tests by note id by new line and comma
* Test Case Name: Migrate by id separated by comma and new line
*/
    @isTest
    static void testRunMigrationByIdCommaAndNewLine(){
        if(NAMUtils.isEnhancedNotesEnabled()||NAMUtils.ENABLE_NOTES_TESTS){
            /*
* Steps:
* - create a contact 
* - create 10 legacy note
* - get the ids
* - run the migration by Ids
* - assert 10 ContentVersions were created
* - assert 10 CDLs were created
*/
            
            Contact c = NMTTestNoteUtils.createContact();
            //create two legacy note
            List<Note> notes = NMTTestNoteUtils.createNoteForObject(10, c.Id, false);
            List<String> resultAux = new List<String>();
            String sObjectsWrapperAsJson = '';
            //get the ids
            for(integer i=0; i<notes.size(); i++)
            {
                resultAux.add(notes.get(i).Id);
                if(math.mod(i, 2)==0){
                    sObjectsWrapperAsJson+=notes.get(i).Id+'\n';
                }else
                {
                    sObjectsWrapperAsJson+=notes.get(i).Id+',';
                }
            }
            
            //assert that 2 Legacy Notes were created
            System.assertEquals(10, resultAux.size(), '2 Legacy Notes created to migrate');
            
            Test.startTest();
            //run the migration by Ids  
            NMTNotesMigrationController.runMigrationRemote(sObjectsWrapperAsJson,'byId', '2017-08-08', '2017-08-08', true);
            Test.stopTest();
            
            List<NAMNoteConverted__c> contentVersions = [SELECT Id FROM NAMNoteConverted__c WHERE LegacyNoteConvertedId__c in :resultAux];
            //assert 10 contentVersions were created
            System.assertEquals(10, contentVersions.size(), '10 Content Notes created');
            
            List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE
                                              linkedEntityId = :c.Id
                                              AND
                                              contentDocument.latestPublishedVersion.LegacyNoteConvertedId__c in :resultAux];
            //assert 10 CDLs were created
            System.assertEquals(10, cdls.size(), '10 Content Notes linked to the parent Contact');
        }
    }
    
    /**
* @description test migration by object (Account, Contact, etc)
*Test Cases: New note last modified date is the same that the legacy note
*            New note owner is the same that legacy note owner
*/
    @isTest
    static void testRunMigrationByObject(){
        if(NAMUtils.isEnhancedNotesEnabled()||NAMUtils.ENABLE_NOTES_TESTS){
            /*
* Steps:
* - create a contact and a note for It
* - create an account and a note for it
* - run migration
* - get all content versions and assert there are only two with the same titltes than legacy notes
*/
            
            //create a legacy note for contact
            Contact contact1 = NMTTestNoteUtils.createContact();
            Boolean privateNotes = false;
            String noteForContactTitle = 'random note title '+NMTTestNoteUtils.randomInteger();
            List<Note> notes = NMTTestNoteUtils.createNoteForObject(1, contact1.Id, privateNotes, noteForContactTitle);
            Note noteForContact = notes.get(0);
            
            //create a legacy note for account
            Account account1 = NMTTestNoteUtils.createAccount();
            String noteForAccountTitle = 'random note title '+NMTTestNoteUtils.randomInteger();
            notes = NMTTestNoteUtils.createNoteForObject(1, account1.Id, privateNotes, noteForAccountTitle);
            Note noteForAccount = notes.get(0);
            
            //run the migration
            Test.startTest();
            String migrationType = 'byObject';
            Integer totalToMigrate = 1;
            Date startDate = system.today();
            startDate = startDate.addDays(-30);
            Date endDate = system.today();
            
            String dataString = 'Contact' + ',' + totalToMigrate + '|'+'Account' + ',' + totalToMigrate + '|';
            NMTNotesMigrationController.runMigrationRemote(dataString, migrationType, String.valueOf(startDate), String.valueOf(endDate), true);
            System.assertEquals(true,NMTNoteConversionStatus.isInProgress());
            Test.stopTest();
            
            NMTTestNoteUtils.sleep(6);
            
            System.assertEquals(false,NMTNoteConversionStatus.isInProgress(), 'Migration was not stoped');
            
            //get all content versions and assert there are only two with the same titltes than legacy notes
            List<NAMNoteConverted__c> allCV = NMTTestNoteUtils.getAllConvertedNotes();
            System.assert(allCV != null);
            
            System.assertEquals(2, allCV.size(), 'There are not two notes migrated');
            
        }
    }
    
    
    /**
* @description test migration by object (Account, Contact, etc)
*/
    @isTest
    static void testRunMigrationByObjectNotNotes(){
        if(NAMUtils.isEnhancedNotesEnabled()||NAMUtils.ENABLE_NOTES_TESTS){
            /*
* Steps:
* - create a contact and a note for It
* - create an account and a note for it
* - run migration with a date before
* - get all content versions and assert there are only two with the same titltes than legacy notes
*/
            
            //create a legacy note for contact
            Contact contact1 = NMTTestNoteUtils.createContact();
            Boolean privateNotes = false;
            String noteForContactTitle = 'random note title '+NMTTestNoteUtils.randomInteger();
            List<Note> notes = NMTTestNoteUtils.createNoteForObject(1, contact1.Id, privateNotes, noteForContactTitle);
            Note noteForContact = notes.get(0);
            
            //create a legacy note for account
            Account account1 = NMTTestNoteUtils.createAccount();
            String noteForAccountTitle = 'random note title '+NMTTestNoteUtils.randomInteger();
            notes = NMTTestNoteUtils.createNoteForObject(1, account1.Id, privateNotes, noteForAccountTitle);
            Note noteForAccount = notes.get(0);
            
            //run the migration
            Test.startTest();
            String migrationType = 'byObject';
            Integer totalToMigrate = 1;
            Date startDate = system.today();
            startDate = startDate.addDays(-60);
            Date endDate = system.today();
            endDate = endDate.addDays(-30);
            String dataString = 'Contact' + ',' + totalToMigrate + '|'+'Account' + ',' + totalToMigrate + '|';
            NMTNotesMigrationController.runMigrationRemote(dataString, migrationType, String.valueOf(startDate), String.valueOf(endDate), false);
            System.assertEquals(true,NMTNoteConversionStatus.isInProgress());
            Test.stopTest();
            
            NMTTestNoteUtils.sleep(6);
            
            System.assertEquals(false,NMTNoteConversionStatus.isInProgress(), 'Migration was not stoped');
            
            //get all content versions and assert there are only two with the same titltes than legacy notes
            List<ContentVersion> allCV = NMTTestNoteUtils.getAllContentVersions();
            System.assertEquals(0, allCV.size());
            
            Boolean noteForContactMigrated = false;
            Boolean noteForAccountMigrated = false;
            for(ContentVersion cv :allCV){
                if(cv.Title == noteForContact.Title){
                    noteForContactMigrated = true;
                }
                if(cv.Title == noteForAccount.Title){
                    noteForAccountMigrated = true;
                }
            }
            System.assertEquals(false, noteForContactMigrated, 'Note for contact was migrated');
            System.assertEquals(false, noteForAccountMigrated, 'Note for account was migrated');
        }
    }
    
    /**
* @description test notes deletion
*/
    @isTest
    static void testNotesDeletion(){
        if(NAMUtils.isEnhancedNotesEnabled()||NAMUtils.ENABLE_NOTES_TESTS){
            /*
* Steps: 
* - create a legacy note
* - migrate the legacy note using the MigrationBatchHelper to do it syncronously
* - (in this method we do not test migration success)
* - delete all legacy notes with NotesMigrationController
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
            Date startDate = system.today();
            startDate = startDate.addDays(-30);
            Date endDate = system.today();
            NMTNotesMigrationController.deleteRemote('Contact', String.valueOf(startDate), String.valueOf(endDate), true);
            Test.stopTest();
            
            //assert the legacy note created was deleted
            List<Note> notesDeleted = [select id from note where id = :noteId];
            System.assertEquals(0, notesDeleted.size(),'The note converted was not deleted');
        }
    }
    
    /**
* @description test notes counters
*/
    @isTest
    static void testCounters(){
        if(NAMUtils.isEnhancedNotesEnabled()||NAMUtils.ENABLE_NOTES_TESTS){
            /*
* Steps:
* - create a contact 
* - create two legacy notes
* - assert numberOfConvertedNotes = 0
* - assert numberOfConvertedNotesHistory = 0
* - assert notesHasNotBeenConverted = 2
* - assert notesPerObject.size() = 1 (in the UI show the Contact in the list of Objects)
* - run the migration to one note (in this method the migration is not tested)
* - assert inProgressValue != null 
* - assert numberOfConvertedNotes = 1
* - assert numberOfConvertedNotesHistory = 1
* - assert notesHasNotBeenConverted = 1
*/
            Contact c = NMTTestNoteUtils.createContact();
            //create two legacy note
            List<Note> notes = NMTTestNoteUtils.createNoteForObject(2, c.Id, false);
            List<String> resultAux = new List<String>{notes.get(0).Id};
                String sObjectsWrapperAsJson = notes.get(0).Id;
            
            NMTNotesMigrationController nMigrationController = new NMTNotesMigrationController();
            nMigrationController.doCounts();
            //- assert numberOfConvertedNotes = 0
            //- assert numberOfConvertedNotesHistory = 0
            //- assert notesHasNotBeenConverted = 2
            //- assert notesPerObject.size() = 1 (in the UI show the Contact in the list of Objects)
            //- assert there is not empty objects
            //
            List<NMTSObjectWrapperNotes> notesPerObject = nMigrationController.notesPerObject;
            System.assertEquals('0', nMigrationController.numberOfConvertedNotes);
            System.assertEquals(1, notesPerObject.size());
            System.assert(!nMigrationController.getEmptyObjects());
            
            Test.startTest();
            //run the migration by Ids
            Date startDate = system.today();
            startDate = startDate.addDays(-30);
            Date endDate = system.today();
            NMTNotesMigrationController.runMigrationRemote(sObjectsWrapperAsJson,'byId', String.valueOf(startDate), String.valueOf(endDate), true);
            NMTNotesMigrationController nMigrationController3 = new NMTNotesMigrationController();
            System.assert(nMigrationController3.inProgressValue!=null);
            Test.stopTest();
            
            NMTNotesMigrationController nMigrationController2 = new NMTNotesMigrationController();
            nMigrationController2.doCounts();
            
            NMTNotesMigrationController.detectInternalSalesforceError();
            NMTNotesMigrationController.abortOperation();
            nMigrationController2.orderBy();
            nMigrationController2.getorderByOptions ();
            System.assertEquals('1', nMigrationController2.numberOfConvertedNotes);
        }
    }
    
    /**
* @description test date filter
*/
    @isTest
    static void testDateFilter(){
        if(NAMUtils.isEnhancedNotesEnabled()||NAMUtils.ENABLE_NOTES_TESTS){
            /*
* Steps:
* - create a contact and a note for It
* - create an account and a note for it
* - change date range to yerterday
* - assert 0 notes on that range
*/
            
            //create a legacy note for contact
            Contact contact1 = NMTTestNoteUtils.createContact();
            Boolean privateNotes = false;
            String noteForContactTitle = 'random note title '+NMTTestNoteUtils.randomInteger();
            List<Note> notes = NMTTestNoteUtils.createNoteForObject(1, contact1.Id, privateNotes, noteForContactTitle);
            Note noteForContact = notes.get(0);
            
            //create a legacy note for account
            Account account1 = NMTTestNoteUtils.createAccount();
            String noteForAccountTitle = 'random note title '+NMTTestNoteUtils.randomInteger();
            notes = NMTTestNoteUtils.createNoteForObject(1, account1.Id, privateNotes, noteForAccountTitle);
            Note noteForAccount = notes.get(0);
            
            NMTNotesMigrationController controller = new NMTNotesMigrationController();
            
            //Assert first counts
            controller.doCounts();
            System.assertEquals('2', controller.TotalLegacyNotes);
            System.assertEquals('0', controller.numberOfConvertedNotes);
            System.assertEquals('2', controller.numberOfUnconvertedNotes);
            
            //Assert filter counts
            Date mydate = System.today();
            
            controller.startDateCV.LegacyNoteConvertedDate__c = mydate.addDays(-2);
            controller.endDateCV.LegacyNoteConvertedDate__c = mydate.addDays(-2);
            controller.Filter();
            
            System.assertEquals('0', controller.TotalLegacyNotes);
            System.assertEquals('0', controller.numberOfConvertedNotes);
            System.assertEquals('0', controller.numberOfUnconvertedNotes);
            
            //Assert refresh counts
            
            controller.startDateFilter = mydate;
            controller.endDateFilter = mydate;
            controller.Refresh();
            System.assertEquals('0', controller.TotalLegacyNotes);
            System.assertEquals('0', controller.numberOfConvertedNotes);
            System.assertEquals('0', controller.numberOfUnconvertedNotes);
        }
    }
    
    
    
    @isTest 
    static void testRefresh() {
        Test.startTest();
        //setup
        Integer noteToCreate = 10;
        Contact c = NMTTestNoteUtils.createContact();
        NMTTestNoteUtils.createNoteForObject(noteToCreate, c.Id, false);
        NMTNotesMigrationController controller = new NMTNotesMigrationController();
        controller.objectSelected = 'Contact';
        controller.refresh();
        NAMConfigs.setEnableBodyLength(true);
        controller.refresh();
        
        
        Test.stopTest();
        
        System.assert(controller.getDisableNextMigratedObjects() == true);
    }
    
    @isTest 
    static void testRefresh2() {
        Test.startTest();
        //setup
        Integer noteToCreate = 10;
        Contact c = NMTTestNoteUtils.createContact();
        NMTTestNoteUtils.createNoteForObject(noteToCreate, c.Id, false);
        NMTNotesMigrationController controller = new NMTNotesMigrationController();
        controller.objectSelected = 'Contact';
        controller.byCreateDate = false;
        controller.refresh();
        NAMConfigs.setEnableBodyLength(true);
        controller.refresh();
        
        Test.stopTest();
        
        System.assert(controller.getDisableNextMigratedObjects() == true);
    }
    
    /**
* @description test time zone
*/
    @isTest
    static void testTimeZone(){
        if(NAMUtils.isEnhancedNotesEnabled()||NAMUtils.ENABLE_NOTES_TESTS){
            System.debug(System.UserInfo.getTimeZone());
            
            // Setup test data
            // This code runs as the system user
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@notes.attachments.testorg.com');
            
            Integer daysAgo = -1;
            Integer hoursToAdd = 23;
            System.runAs(u) {
                //use script
                Boolean privateRecords = false;
                Id ownerId = UserInfo.getUserId();
                Integer quantityRecords = 5;
                //DateTime createdDate = DateTime.newInstance(2017, 9, 20).addHours(23);
                
                DateTime createdDate = DateTime.now().addDays(daysAgo).addHours(hoursToAdd);
                
                Contact contact = new Contact(LastName='contact'+createdDate);
                insert contact;
                Id parentId = contact.Id;
                
                List<Note> notes = new List<Note>();
                for(Integer i = 0; i<quantityRecords ; i++){
                    Note note=new Note();
                    note.Title='note';
                    note.body='a'; //you can test special characters here
                    note.parentId=parentId; //you can test special characters here
                    note.IsPrivate = privateRecords;
                    note.OwnerId = ownerId;
                    note.createdDate = createdDate;
                    notes.add(note);
                }
                insert notes;
                System.debug(notes.get(0).createdDate);
            }  
            
            
            NMTNotesMigrationController controller = new NMTNotesMigrationController();
            
            //Assert first counts
            controller.doCounts();
            System.assertEquals('5', controller.TotalLegacyNotes);
            System.assertEquals('0', controller.numberOfConvertedNotes);
            System.assertEquals('5', controller.numberOfUnconvertedNotes);
            
            //Assert filter counts
            //Date mydate = Date.newInstance(2017, 9, 20);
            Date mydate = Date.today().addDays(daysAgo);
            
            
            controller.startDateCV.LegacyNoteConvertedDate__c = mydate;
            controller.endDateCV.LegacyNoteConvertedDate__c = mydate;
            controller.Filter();
            
            //Assert filter counts
            //mydate = Date.newInstance(2017, 9, 21);
            mydate = Date.today().addDays(daysAgo+1);
            
            controller.startDateCV.LegacyNoteConvertedDate__c = mydate;
            controller.endDateCV.LegacyNoteConvertedDate__c = mydate;
            controller.Filter();
            
            //Assert filter counts
            //mydate = Date.newInstance(2017, 9, 21);
            mydate = Date.today().addDays(daysAgo+1);
            
            controller.startDateCV.LegacyNoteConvertedDate__c = mydate;
            controller.endDateCV.LegacyNoteConvertedDate__c = mydate;
            controller.Filter();
        }
        
    }
    
    /**
* @description test another tool in progress
*Test Case Name: When migrating/deleting process is in progress block the other process
*/
    @isTest
    static void testAnotherTool(){
        if(NAMUtils.isEnhancedNotesEnabled()||NAMUtils.ENABLE_NOTES_TESTS){
            //setup
            Contact c = ATFTestUtils.createContact();
            Id parentId = c.Id;  
            ATFTestUtils.createAttachmentForObject(100, parentId, false, 'sample3');
            ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
            controller.deleteAfterMigration = false;
            Attachment attach= [SELECT Id, OwnerId FROM Attachment LIMIT 1];
            //end setup
            
            string json = 'Contact' + ',' + '1' + '|';
            String dateSt = Datetime.now().format('yyyy-MM-dd');
            String dateEn = Datetime.now().format('yyyy-MM-dd');
            
            Test.startTest();
            
            ATFAttachmentsToFilesController.runMigrationRemote(json,'byObject',dateSt, dateEn, true);
            NMTNotesMigrationController notesController = new NMTNotesMigrationController();
            //end setup
            Test.stopTest();
            
            System.assertEquals('display:inline', notesController.otherToolInProgress);
            
            notesController.checkInProgress();
            
            System.assertEquals('display:none', notesController.otherToolInProgress);
        }
    }
    
    /**
* @description test is data synchronized
*/
    @isTest
    static void testDataSynchronized(){
        //we need to make sure for an empty state the tool recognizes we don't need to synchronize the data.
        System.assert(NAMUtils.isDataSynchronized());
    }
}