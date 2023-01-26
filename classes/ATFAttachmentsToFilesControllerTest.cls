/**
* @description 
* @author Dayana Daniel, Jessica Bernal, Andres Canavesi
*/
@isTest
public class ATFAttachmentsToFilesControllerTest {
    
    
    /**
* @description
* @return all attachments that have not been migrated
*/
    static List<Attachment> getUnmigratedAttachments(){
        return [SELECT Id, Name FROM Attachment WHERE NOT (Name LIKE :NAMUtils.MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)];
    }
    
    /**
* @description
* @return als attachments that have been migrated
*/
    static List<Attachment> getMigratedAttachments(){
        return [SELECT Id, Name FROM Attachment WHERE Name LIKE :NAMUtils.MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN];
    }
    
    /**
* @description tests migration by contact
* Test Case Name: Migrate user's public and private attachments for a record, 
* Test Case Name: Application WILL create a CDL connecting new Content Document with Record
* Test Case Name: When migrating new document owner field WILL be attachment owner
*/
    @isTest 
    static void migrationBatchRuns() {
        Test.startTest();
        //setup
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id;  
        ATFTestUtils.createAttachmentForObject(1, parentId, false, 'sample'+Math.random());//1 public attachment
        ATFTestUtils.createAttachmentForObject(1, parentId, true, 'sample'+Math.random());//1 private attachment
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.byCreateDate = false;
        controller.deleteAfterMigration = false;
        String v = controller.version;
        controller.loadInfo();
        List <Attachment> attachmentsCreated = getUnmigratedAttachments();
        System.assertEquals(2, attachmentsCreated.size(), 'Attachments have not been created');
        Attachment attach= [SELECT Id, OwnerId FROM Attachment LIMIT 1];
        //end setup
        
        string json = 'Contact' + ',' + '2' + '|';
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        ATFAttachmentsToFilesController.runMigrationRemote(json, 'byObject', dateSt, dateEn, false);
        
        Test.stopTest();
        
        //get all migrated attachments
        List <Attachment> attachments = getMigratedAttachments();
        System.assertEquals(2, attachments.size(), 'Attachment have not been converted properly');
        
        //validate the new file is visible from its parent record
        List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE
                                          linkedEntityId = :c.Id];
        System.assertEquals(2, cdls.size());
        
        //validate the new file preserves the ownership
        ContentVersion cv = [SELECT Id, OwnerId FROM ContentVersion LIMIT 1];
        System.assertEquals(attach.OwnerId, cv.OwnerId);
    }
    
    @isTest 
    static void migrationBatchRunsEnableBodyLength() {
        Test.startTest();
        //setup
        NAMConfig__c config = new NAMConfig__c();
        config.Name = 'EnableBodyLength';
        config.Value__c = String.valueOf(true);
        upsert config;
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id;  
        ATFTestUtils.createAttachmentForObject(1, parentId, false, 'sample'+Math.random());//1 public attachment
        ATFTestUtils.createAttachmentForObject(1, parentId, true, 'sample'+Math.random());//1 private attachment
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.byCreateDate = false;
        controller.deleteAfterMigration = false;
        String v = controller.version;
        controller.loadInfo();
        List <Attachment> attachmentsCreated = getUnmigratedAttachments();
        System.assertEquals(2, attachmentsCreated.size(), 'Attachments have not been created');
        Attachment attach= [SELECT Id, OwnerId FROM Attachment LIMIT 1];
        //end setup
        
        string json = 'Contact' + ',' + '2' + '|';
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        ATFAttachmentsToFilesController.runMigrationRemote(json, 'byObject', dateSt, dateEn, false);
        
        Test.stopTest();
        
        //get all migrated attachments
        List <Attachment> attachments = getMigratedAttachments();
        System.assertEquals(2, attachments.size(), 'Attachment have not been converted properly');
        
        //validate the new file is visible from its parent record
        List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE
                                          linkedEntityId = :c.Id];
        System.assertEquals(2, cdls.size());
        
        //validate the new file preserves the ownership
        ContentVersion cv = [SELECT Id, OwnerId FROM ContentVersion LIMIT 1];
        System.assertEquals(attach.OwnerId, cv.OwnerId);
    }
    
    
    @isTest 
    static void migrationBatchRunsEnableBodyLength2() {
        Test.startTest();
        //setup
        NAMConfig__c config = new NAMConfig__c();
        config.Name = 'EnableBodyLength';
        config.Value__c = String.valueOf(true);
        upsert config;
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id;  
        ATFTestUtils.createAttachmentForObject(1, parentId, false, 'sample'+Math.random());//1 public attachment
        ATFTestUtils.createAttachmentForObject(1, parentId, true, 'sample'+Math.random());//1 private attachment
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.byCreateDate = true;
        controller.deleteAfterMigration = false;
        String v = controller.version;
        controller.loadInfo();
        List <Attachment> attachmentsCreated = getUnmigratedAttachments();
        System.assertEquals(2, attachmentsCreated.size(), 'Attachments have not been created');
        Attachment attach= [SELECT Id, OwnerId FROM Attachment LIMIT 1];
        //end setup
        
        string json = 'Contact' + ',' + '2' + '|';
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        ATFAttachmentsToFilesController.runMigrationRemote(json, 'byObject', dateSt, dateEn, false);
        
        Test.stopTest();
        
        //get all migrated attachments
        List <Attachment> attachments = getMigratedAttachments();
        System.assertEquals(2, attachments.size(), 'Attachment have not been converted properly');
        
        //validate the new file is visible from its parent record
        List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE
                                          linkedEntityId = :c.Id];
        System.assertEquals(2, cdls.size());
        
        //validate the new file preserves the ownership
        ContentVersion cv = [SELECT Id, OwnerId FROM ContentVersion LIMIT 1];
        System.assertEquals(attach.OwnerId, cv.OwnerId);
    }
    
    
    @isTest 
    static void migrationBatchRunsEnableBodyLengthByLastModify() {
        Test.startTest();
        //setup
        NAMConfig__c config = new NAMConfig__c();
        config.Name = 'EnableBodyLength';
        config.Value__c = String.valueOf(true);
        upsert config;
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id;  
        ATFTestUtils.createAttachmentForObject(1, parentId, false, 'sample'+Math.random());//1 public attachment
        ATFTestUtils.createAttachmentForObject(1, parentId, true, 'sample'+Math.random());//1 private attachment
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.byCreateDate = false;
        controller.deleteAfterMigration = false;
        String v = controller.version;
        controller.loadInfo();
        List <Attachment> attachmentsCreated = getUnmigratedAttachments();
        System.assertEquals(2, attachmentsCreated.size(), 'Attachments have not been created');
        Attachment attach= [SELECT Id, OwnerId FROM Attachment LIMIT 1];
        //end setup
        
        string json = 'Contact' + ',' + '2' + '|';
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        ATFAttachmentsToFilesController.runMigrationRemote(json, 'byObject', dateSt, dateEn, true);
        
        Test.stopTest();
        
        //get all migrated attachments
        List <Attachment> attachments = getMigratedAttachments();
        System.assertEquals(2, attachments.size(), 'Attachment have not been converted properly');
        
        //validate the new file is visible from its parent record
        List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE
                                          linkedEntityId = :c.Id];
        System.assertEquals(2, cdls.size());
        
        //validate the new file preserves the ownership
        ContentVersion cv = [SELECT Id, OwnerId FROM ContentVersion LIMIT 1];
        System.assertEquals(attach.OwnerId, cv.OwnerId);
    }
    
    /**
* @description tests migration by id
*/
    @isTest 
    static void migrationBatchByIdRuns() {
        Test.startTest();
        //setup
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id;  
        ATFTestUtils.createAttachmentForObject(1, parentId, false, 'sample3');//1 public attachment
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.deleteAfterMigration = false;
        controller.refresh();
        controller.getorderByOptions ();
        Attachment attach= [SELECT Id, OwnerId FROM Attachment LIMIT 1];
        //end setup
        
        List<String> resultAux = new List<String>();
        String sObjectsWrapperAsJson = '';
        //get the id
        resultAux.add(attach.Id);
        sObjectsWrapperAsJson+=attach.Id+',';
        
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        ATFAttachmentsToFilesController.runMigrationRemote(sObjectsWrapperAsJson, 'byId', dateSt, dateEn, false);
        
        //end setup
        Test.stopTest();
        
        List <Attachment> attachments = getMigratedAttachments();
        System.assertEquals(1, attachments.size());
        
        List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE
                                          linkedEntityId = :c.Id];
        System.assertEquals(1, cdls.size());
        
        ContentVersion cv = [SELECT Id, OwnerId FROM ContentVersion LIMIT 1];
        System.assertEquals(attach.OwnerId, cv.OwnerId);
    }
    
    static void testRefrsh() {
        Test.startTest();
        NAMConfig__c config = new NAMConfig__c();
        config.Name = 'EnableBodyLength';
        config.Value__c = String.valueOf(true);
        upsert config;
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        Contact c = ATFTestUtils.createContact();
        
        Id parentId = c.Id;  
        ATFTestUtils.createAttachmentForObject(1, parentId, false, 'sample'+Math.random());//1 public attachment
        ATFTestUtils.createAttachmentForObject(1, parentId, true, 'sample'+Math.random());//1 private attachment
        controller.byCreateDate = true;
        controller.refresh();
        Test.stopTest();
        
        System.assertEquals('0', controller.totalConvertedAttachments);
    }
    
    /**
* @description tests migration by invalids ids
*/
    @isTest 
    static void migrationBatchByInvalidsIdsRuns() {
        Test.startTest();
        
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.deleteAfterMigration = false;
        
        String sObjectsWrapperAsJson = '';
        
        sObjectsWrapperAsJson+='attach.Id1,attach.Id2,attach.Id3';
        
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        try{
            ATFAttachmentsToFilesController.runMigrationRemote(sObjectsWrapperAsJson, 'byId', dateSt, dateEn, true);
            System.assert(false);
        }catch(NAMForbiddenException ex){
            //we expect an exception here
            System.assert(ex != null);
        }
        
        //end setup
        Test.stopTest();
        
    }
    
    /**
* @description tests migration by empty parents ids
*/
    @isTest 
    static void migrationBatchByEmptyParentsIdsRuns() {
        Test.startTest();
        
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.deleteAfterMigration = false;
        
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id; 
        
        String sObjectsWrapperAsJson = '';
        
        sObjectsWrapperAsJson+=parentId;
        
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        try{
            ATFAttachmentsToFilesController.runMigrationRemote(sObjectsWrapperAsJson, 'byObjectId', dateSt, dateEn, true);
            System.assert(false);
        }catch(Exception ex){
            System.assertEquals('No attachments are associated with the ID '+parentId+'.', ex.getMessage());
        }
        
        //end setup
        Test.stopTest();
        
    }
    
    /**
* @description tests migration by invalid parents ids
*/
    @isTest 
    static void migrationBatchByInvalidParentsIdsRuns() {
        Test.startTest();
        
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.deleteAfterMigration = false;
        
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id; 
        delete c;
        
        String sObjectsWrapperAsJson = '';
        
        sObjectsWrapperAsJson+=parentId;
        
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        try{
            ATFAttachmentsToFilesController.runMigrationRemote(sObjectsWrapperAsJson, 'byObjectId', dateSt, dateEn, true);
            System.assert(false);
        }catch(Exception ex){
            System.assertEquals('We can\'t get data for the ID ' + parentId + '. The ID doesn\'t exist or has been deleted, or you don\'t have access to that record.', ex.getMessage());
        }
        
        //end setup
        Test.stopTest();
        
    }
    
    /**
* @description tests migration by parent id
*/
    @isTest 
    static void migrationBatchByParentIdRuns() {
        Test.startTest();
        //setup
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id;  
        ATFTestUtils.createAttachmentForObject(1, parentId, false, 'sample3');
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.deleteAfterMigration = false;
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
        
        //end setup
        Test.stopTest();
        
        List <Attachment> attachments = new List <Attachment>();
        //TODO use NAMUtils.MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
        attachments = getMigratedAttachments();
        System.assertEquals(1, attachments.size());
        
        List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE
                                          linkedEntityId = :c.Id];
        System.assertEquals(1, cdls.size());
        
        ContentVersion cv = [SELECT Id, OwnerId FROM ContentVersion LIMIT 1];
        System.assertEquals(attach.OwnerId, cv.OwnerId);
    }
    
    /**
* @description tests migration by contact if attachment were created by standard user
* Test Case Name: Migrate users public attachments for a record, only public attachments uploaded (from standard user).
* Test Case Name: Application WILL create a CDL connecting new Content Document with Record, only public attachments uploaded (from standard user).
* Test Case Name: When migrating new document owner field WILL be attachment owner, only public attachments uploaded (from standard user).
*/
    @isTest 
    static void migrationBatchRunStandardUser() {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'attach', Email='testattach@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testattach@testorg.com');
        Test.startTest();
        //setup
        System.runAs(u) {
            Contact c = ATFTestUtils.createContact();
            Id parentId = c.Id;  
            ATFTestUtils.createAttachmentForObject(1, parentId, false, 'sample3');
        }
        Attachment attach= [SELECT Id, OwnerId FROM Attachment LIMIT 1];
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.deleteAfterMigration = false;
        //end setup
        
        string json = 'Contact' + ',' + '1' + '|';
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        ATFAttachmentsToFilesController.runMigrationRemote(json, 'byObject', dateSt, dateEn, true);
        
        //end setup
        Test.stopTest();
        
        List <Attachment> attachments = getMigratedAttachments();
        System.assertEquals(1, attachments.size());
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE
                                          linkedEntityId = :contact.Id];
        System.assertEquals(1, cdls.size());
        
        System.runAs(u) {
            ContentVersion cv = [SELECT Id, OwnerId FROM ContentVersion LIMIT 1];
            System.assertEquals(attach.OwnerId, cv.OwnerId);
        }
    }
    
    /**
* @description tests migration by contact if attachment were created by standard user and Admin
* Test Case Name: Migrate users public attachments for a record, only public attachments uploaded (from standard/ admin user).
* Test Case Name: Application WILL create a CDL connecting new Content Document with Record, only public attachments uploaded (from standard/admin user).
* Test Case Name: When migrating new document owner field WILL be attachment owner, only public attachments uploaded (from standard/admin user).
*/
    @isTest 
    static void migrationBatchRunStandardUserAndAdmin() {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'attach', Email='testattach@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testattach@testorg.com');
        Test.startTest();
        //setup
        System.runAs(u) {
            Contact c = ATFTestUtils.createContact();
            Id parentId = c.Id;  
            ATFTestUtils.createAttachmentForObject(1, parentId, false, 'sample3');
        }
        Attachment attach= [SELECT Id, OwnerId FROM Attachment LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id;  
        ATFTestUtils.createAttachmentForObject(1, parentId, false, 'sample3');
        Attachment attach2= [SELECT Id, OwnerId FROM Attachment WHERE ParentId  = :parentId LIMIT 1];
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.deleteAfterMigration = false;
        //end setup
        
        string json = 'Contact' + ',' + '2' + '|';
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        ATFAttachmentsToFilesController.runMigrationRemote(json, 'byObject', dateSt, dateEn, true);
        
        //end setup
        Test.stopTest();
        
        List <Attachment> attachments = getMigratedAttachments();
        System.assertEquals(2, attachments.size());
        
        List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE
                                          linkedEntityId = :contact.Id];
        System.assertEquals(1, cdls.size());
        
        List<ContentDocumentLink> cdls2 = [SELECT Id FROM ContentDocumentLink WHERE
                                           linkedEntityId = :c.Id];
        System.assertEquals(1, cdls2.size());
        
        System.runAs(u) {
            ContentVersion cv = [SELECT Id, OwnerId FROM ContentVersion LIMIT 1];
            System.assertEquals(attach.OwnerId, cv.OwnerId);
        }
        
        ContentVersion cv2 = [SELECT Id, OwnerId FROM ContentVersion WHERE OwnerId = :attach2.OwnerId LIMIT 1];
        System.assertEquals(attach2.OwnerId, cv2.OwnerId);
    }
    
    /**
* @description tests migration by contact if attachment were created by standard user inactive. 
* Test Case Name: Migrate users public attachments for a record, only public attachments uploaded (from inactive user).
* Test Case Name: Application WILL create a CDL connecting new Content Document with Record, only public attachments uploaded (from inactive user).
* Test Case Name: When migrating new document owner field WILL be user doing migration, only public attachments uploaded (from inactive user).
*/
    @isTest 
    static void migrationBatchRunStandardUserInactive() {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'attach', Email='testattach@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testattach@testorg.com');
        
        
        Test.startTest();
        //setup
        System.runAs(u) {
            Contact c = ATFTestUtils.createContact();
            Id parentId = c.Id;  
            ATFTestUtils.createAttachmentForObject(1, parentId, false, 'sample3');
        }
        Attachment attach= [SELECT Id, OwnerId FROM Attachment LIMIT 1];
        u.IsActive = false;
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.deleteAfterMigration = false;
        //end setup
        
        string json = 'Contact' + ',' + '1' + '|';
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        ATFAttachmentsToFilesController.runMigrationRemote(json, 'byObject', dateSt, dateEn, true);
        
        //end setup
        Test.stopTest();
        
        List <Attachment> attachments = getMigratedAttachments();
        System.assertEquals(1, attachments.size());
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE
                                          linkedEntityId = :contact.Id];
        System.assertEquals(1, cdls.size());
        
        System.runAs(u) {
            ContentVersion cv = [SELECT Id, OwnerId FROM ContentVersion LIMIT 1];
            System.assertEquals(attach.OwnerId, cv.OwnerId);
        }
    }
    
    /**
* @description tests migration by contact if attachment were created by standard user inactive & inactive and Admin. 
* Test Case Name: Migrate users public attachments for a record, only public attachments uploaded (from inactive/standard/admin users).
* Test Case Name: Application WILL create a CDL connecting new Content Document with Record, only public attachments uploaded (from inactive/standard/admin users).
* Test Case Name: When migrating new document owner field is correct, only public attachments uploaded (from inactive/standard/admin users).
*/
    @isTest 
    static void migrationBatchRunStandardUserInactiveActiveAdmin() {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'attach', Email='testattach@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testattach@testorg.com');
        User uu = new User(Alias = 'attach2', Email='testattach2@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='testattach2@testorg.com');
        Test.startTest();
        //setup
        System.runAs(u) {
            Contact c = ATFTestUtils.createContact();
            Id parentId = c.Id;  
            ATFTestUtils.createAttachmentForObject(1, parentId, false, 'sample3');
        }
        Attachment attach= [SELECT Id, OwnerId FROM Attachment LIMIT 1];
        System.runAs(uu) {
            Contact c = ATFTestUtils.createContact();
            Id parentId = c.Id;  
            ATFTestUtils.createAttachmentForObject(1, parentId, false, 'sample');
        }
        Attachment attach2= [SELECT Id, OwnerId FROM Attachment WHERE Name = 'sample' LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 2];
        Contact contact = contacts.get(0);
        Contact contact2 = contacts.get(1);
        u.IsActive = false;
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id;  
        ATFTestUtils.createAttachmentForObject(1, parentId, false, 'sample33');
        Attachment attach3= [SELECT Id, OwnerId FROM Attachment WHERE Name = 'sample33' LIMIT 1];
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.deleteAfterMigration = false;
        //end setup
        
        string json = 'Contact' + ',' + '3' + '|';
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        ATFAttachmentsToFilesController.runMigrationRemote(json, 'byObject', dateSt, dateEn, true);
        
        //end setup
        Test.stopTest();
        
        List <Attachment> attachments = getMigratedAttachments();
        System.assertEquals(3, attachments.size());
        
        List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE
                                          linkedEntityId = :contact.Id];
        System.assertEquals(1, cdls.size());
        
        List<ContentDocumentLink> cdls2 = [SELECT Id FROM ContentDocumentLink WHERE
                                           linkedEntityId = :contact2.Id];
        System.assertEquals(1, cdls2.size());
        
        List<ContentDocumentLink> cdls3 = [SELECT Id FROM ContentDocumentLink WHERE
                                           linkedEntityId = :c.Id];
        System.assertEquals(1, cdls3.size());
        
        System.runAs(u) {
            ContentVersion cv = [SELECT Id, OwnerId FROM ContentVersion LIMIT 1];
            System.assertEquals(attach.OwnerId, cv.OwnerId);
        }
        
        System.runAs(uu) {
            ContentVersion cv = [SELECT Id, OwnerId FROM ContentVersion LIMIT 1];
            System.assertEquals(attach2.OwnerId, cv.OwnerId);
        }
        
        //ContentVersion cv = [SELECT Id, OwnerId FROM ContentVersion LIMIT 1];
        //System.assertEquals(attach3.OwnerId, cv.OwnerId);
        
    }
    
    /**
* @description tests migration by contact if attachment were created by other Admin
* Test Case Name: Migrate users public attachments for a record, only public attachments uploaded (Admin doing migration).
* Test Case Name: Application WILL create a CDL connecting new Content Document with Record, only public attachments uploaded (from other admin user).
* Test Case Name: When migrating new document owner field WILL be attachment owner, only public attachments uploaded (from other admin user).
*/
    @isTest 
    static void migrationBatchRunOtherAdmin() {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'attach', Email='testattach@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testattach@testorg.com');
        Test.startTest();
        //setup
        System.runAs(u) {
            Contact c = ATFTestUtils.createContact();
            Id parentId = c.Id;  
            ATFTestUtils.createAttachmentForObject(1, parentId, false, 'sample3');
        }
        Attachment attach= [SELECT Id, OwnerId FROM Attachment LIMIT 1];
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.deleteAfterMigration = false;
        //end setup
        
        string json = 'Contact' + ',' + '1' + '|';
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        ATFAttachmentsToFilesController.runMigrationRemote(json, 'byObject', dateSt, dateEn, true);
        
        //end setup
        Test.stopTest();
        
        List <Attachment> attachments = getMigratedAttachments();
        System.assertEquals(1, attachments.size());
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE
                                          linkedEntityId = :contact.Id];
        System.assertEquals(1, cdls.size());
        
        System.runAs(u) {
            ContentVersion cv = [SELECT Id, OwnerId FROM ContentVersion LIMIT 1];
            System.assertEquals(attach.OwnerId, cv.OwnerId);
        }
    }
    /**
* @description tests two migrations at same time 
* Test Case Name: When migration starts, block the object so can’t be migrated while migrating.
*/
    @isTest 
    static void migrationAtSameTime() {
        Test.startTest();
        //setup
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id;  
        ATFTestUtils.createAttachmentForObject(100, parentId, false, 'sample3');
        Account a = ATFTestUtils.createAccount();
        Id parentId2 = a.Id;  
        ATFTestUtils.createAttachmentForObject(100, parentId2, false, 'sample3');
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.deleteAfterMigration = false;
        ATFAttachmentsToFilesController controller2 = new ATFAttachmentsToFilesController();
        controller2.deleteAfterMigration = false;
        //end setup
        
        string json = 'Contact' + ',' + '50' + '|';
        string json2 = 'Account' + ',' + '50' + '|';
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        ATFAttachmentsToFilesController.runMigrationRemote(json, 'byObject', dateSt, dateEn, true);
        ATFAttachmentsToFilesController.runMigrationRemote(json2, 'byObject', dateSt, dateEn, true);
        
        
        Boolean aux4 = controller.getDisableNextMigratedObjects();
        Boolean aux3 = controller.getDisablePreviousMigratedObjects();
        
        
        //end setup
        Test.stopTest();
        
        List <Attachment> attachments = getMigratedAttachments();
        System.assertEquals(100, attachments.size());
    }
    
    /**
* @description tests migration if user put a negative number of Attachments 
* Test Case Name: When an object is selected, an input show up, try to set negative numbers.
*/
    @isTest 
    static void migrationWithNegativeInput() {
        Test.startTest();
        //setup
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id;  
        ATFTestUtils.createAttachmentForObject(1, parentId, false, 'sample3');
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.deleteAfterMigration = false;
        //end setup
        
        string json = 'Contact' + ',' + '-1' + '|';
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        ATFAttachmentsToFilesController.runMigrationRemote(json, 'byObject', dateSt, dateEn, true);
        
        //end setup
        Test.stopTest();
        
        List <Attachment> attachments = getMigratedAttachments();
        System.assertEquals(0, attachments.size());
    }
    
    /**
* @description tests two migrations at same time with same object 
* Test Case Name: When migration starts, block the object so can’t be migrated while migrating.
*/
    @isTest 
    static void migrationAtSameTimeSameObject() {
        Test.startTest();
        //setup
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id;  
        ATFTestUtils.createAttachmentForObject(100, parentId, false, 'sample3');
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        
        controller.deleteAfterMigration = false;
        //end setup
        
        string json = 'Contact' + ',' + '100' + '|';
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        ATFAttachmentsToFilesController.runMigrationRemote(json, 'byObject', dateSt, dateEn, true);
        List<NAMAttachmentConversionStatus__c> attachmentStatus = ATFAttachmentConversionStatus.findInProgressObjects();
        Boolean isInProgress = ATFAttachmentConversionStatus.containsObjectByName(attachmentStatus, 'Contact');
        
        //end setup
        Test.stopTest();
        System.assertEquals(true, isInProgress );
    }
    
    
    /**
* @description tests not able to migrate when notes is already migrating 
*/
    @isTest 
    static void migrationIfNotesProcessMigrateFirst() {
        Contact c = NMTTestNoteUtils.createContact();
        //create two legacy note
        List<Note> notes = NMTTestNoteUtils.createNoteForObject(100, c.Id, false);
        List<String> resultAux = new List<String>();
        String sObjectsWrapperAsJson = '';
        //get the ids
        for(Note note:notes)
        {
            resultAux.add(note.Id);
            sObjectsWrapperAsJson+=note.Id+',';
        }
        Test.startTest();
        ATFAttachmentsToFilesController ac = new ATFAttachmentsToFilesController();
        String otherToolInProgress = ac.otherToolInProgress;
        System.assertEquals('display:none', otherToolInProgress );
        String dateS = Date.Today() + '';
        String dateE = Date.Today() + '';
        //run the migration by Ids  
        NMTNotesMigrationController.runMigrationRemote(sObjectsWrapperAsJson,'byId', dateS,dateE, true);
        ac.checkOtherTool();
        otherToolInProgress = ac.otherToolInProgress;
        Test.stopTest();
        System.assertEquals('display:inline', otherToolInProgress );
    }
    
    //tests Next and Previous of tables
    @isTest 
    static void testPaginationButtons() {
        Test.startTest();
        //setup
        ATFTestUtils.createAttachmentForContact(NAMUtils.DEFAULT_PAGE_SIZE*2, false, 'sample');
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.loadInfo();
        //end setup
        
        controller.getDisablePreviousUnmigratedObjects();
        
        controller.OffsetSizeUnmigratedObjects = 1;
        controller.getDisablePreviousUnmigratedObjects();
        
        controller.getDisableNextUnmigratedObjects();
        controller.NextUnmigratedObjects();
        controller.PreviousUnmigratedObjects();
        
        Test.stopTest();
        system.assert(controller.unmigratedAttachmentsPerObject.size() == 0);
        
    }
    
    //tests refresh of attachments
    @isTest 
    static void testRefresh() {
        Test.startTest();
        //setup
        Integer attachmentsToCreate = 10;
        ATFTestUtils.createAttachmentForContact(attachmentsToCreate, false, 'sample');
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.loadInfo();
        string objectName = 'Contact';
        
        controller.OffsetSizeUnmigratedObjects = 0;
        controller.OffsetSizeMigratedObjects = 0;
        controller.TotalToMigrate = 1;
        Date dateSt = Date.today();
        Date dateEn = Date.today() + 1;
        List<NAMObjectCount> migratedAttachmentsPerObject = NAMUtils.countMigratedAttachmentsPerObject(NAMUtils.DEFAULT_PAGE_SIZE, 0,dateSt,dateEn, true,'All');       
        System.assertEquals(0, migratedAttachmentsPerObject.size());
        
        string json = 'Contact' + ',' + '1' + '|';
        String dateStString = Datetime.now().format('yyyy-MM-dd');
        String dateEnString = Datetime.now().format('yyyy-MM-dd');
        ATFAttachmentsToFilesController.runMigrationRemote(json,'byObject', dateStString,dateEnString, true);
        Boolean aux1 = controller.getEmptyUnmigratedObjects();
        Boolean aux2 = controller.getEmptyMigratedObjects(); 
        
        Test.stopTest();
        
        System.assert(controller.getDisableNextMigratedObjects() == true);
    }
    
    @isTest 
    static void testRefresh2() {
        Test.startTest();
        //setup
        Integer attachmentsToCreate = 10;
        ATFTestUtils.createAttachmentForContact(attachmentsToCreate, false, 'sample');
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.objectSelected = 'Contact';
        controller.refresh();
        NAMConfigs.setEnableBodyLength(true);
        controller.refresh();
        
        Test.stopTest();
        
        System.assert(controller.getDisableNextMigratedObjects() == true);
    }
    
    @isTest 
    static void testRefresh3() {
        Test.startTest();
        //setup
        Integer attachmentsToCreate = 10;
        ATFTestUtils.createAttachmentForContact(attachmentsToCreate, false, 'sample');
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.objectSelected = 'Contact';
        controller.byCreateDate = false;
        controller.refresh();
        NAMConfigs.setEnableBodyLength(true);
        controller.refresh();
        
        Test.stopTest();
        
        System.assert(controller.getDisableNextMigratedObjects() == true);
    }
    
    @isTest
    static void testIsPending(){
        NAMConfigs.setEnableBodyLength(true);
        Boolean result = NAMUtils.isPendingAttachmentsToBeConverted();
        System.assert(result == false);
        
    }
    
    /**
* @description tests what happen when lenght of attachment names is more than 255 characters
*/
    @isTest 
    static void migrationWhenAttachmentNameMoreThan() {
        Test.startTest();
        //setup
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id;  
        ATFTestUtils.createAttachmentForObject(1, parentId, false, 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.deleteAfterMigration = false;
        Attachment attach= [SELECT Id, OwnerId FROM Attachment LIMIT 1];
        //end setup
        
        string json = 'Contact' + ',' + '1' + '|';
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        ATFAttachmentsToFilesController.runMigrationRemote(json, 'byObject', dateSt, dateEn, true);
        
        //end setup
        Test.stopTest();
        controller.refresh();
        List <Attachment> attachments = getMigratedAttachments();
        
        System.assertEquals(1, attachments.size());
    }
    
    /**
* @description check if dont migrate older attchaments
*/
    @isTest 
    static void migrationOlderAttachments() {
        Test.startTest();
        //setup
        Contact c = ATFTestUtils.createContact();
        Id parentId = c.Id;
        Integer day = 100;
        ATFTestUtils.createAttachmentForObjectCreatedDate(1, parentId, false, day);
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.deleteAfterMigration = false;
        Attachment attach= [SELECT Id, OwnerId FROM Attachment LIMIT 1];
        //end setup
        
        string json = 'Contact' + ',' + '1' + '|';
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        ATFAttachmentsToFilesController.runMigrationRemote(json, 'byObject', dateSt, dateEn, true);
        
        //end setup
        Test.stopTest();
        
        List <Attachment> attachments = getMigratedAttachments();
        System.assertEquals(0, attachments.size());
    }
    
    @isTest 
    static void migrationEventTest() {
        Test.startTest();
        
        Event event = new Event();
        event.DurationInMinutes = 10;
        event.ActivityDate = System.today();
        event.ActivityDateTime = System.today();
        insert event;
        
        Id parentId = event.Id;
        Integer day = 100;
        ATFTestUtils.createAttachmentForObjectCreatedDate(1, parentId, false, day);
        
        ATFAttachmentsToFilesController controller = new ATFAttachmentsToFilesController();
        controller.deleteAfterMigration = false;
        controller.objectSelected = 'Event';
        Attachment attach= [SELECT Id, OwnerId FROM Attachment LIMIT 1];
        //end setup
        
        String json = 'Event' + ',' + '1' + '|';
        String dateSt = Datetime.now().format('yyyy-MM-dd');
        String dateEn = Datetime.now().format('yyyy-MM-dd');
        ATFAttachmentsToFilesController.runMigrationRemote(json, 'byObject', dateSt, dateEn, true);
        
        NAMConfigs.setEnableBodyLength(true);
        NAMUtils.countTotalMigratedAttachmentsPerObject(event.ActivityDate, event.ActivityDate, true, 'Event');
        NAMUtils.countTotalMigratedAttachments(event.ActivityDate, event.ActivityDate, true, 'Event');
        
        NAMConfigs.setEnableBodyLength(false);
        NAMUtils.countTotalMigratedAttachmentsPerObject(event.ActivityDate, event.ActivityDate, true, 'Event');
        NAMUtils.countTotalMigratedAttachments(event.ActivityDate, event.ActivityDate, true, 'Event');
        
        Test.stopTest();
    }
}