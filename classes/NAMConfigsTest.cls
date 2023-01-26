/**
* @description 
* @author  Andres Canavesi
*/
@isTest
public class NAMConfigsTest {
    
    @isTest 
    static void testAttachmentsConfigs() {
        Integer attachmentsBatchSize = NAMConfigs.getBatchSizeForAttachments();
        System.assert(attachmentsBatchSize >0);
        
        NAMConfigs.setBatchSizeForAttachments(430);
        attachmentsBatchSize = NAMConfigs.getBatchSizeForAttachments();
        System.assertEquals(430, attachmentsBatchSize);
        
        Integer dinamicBatchSizeForAttachments = NAMConfigs.getDinamicBatchSizeForAttachments();
        System.assert(dinamicBatchSizeForAttachments >0);
        
        NAMConfigs.setDinamicBatchSizeForAttachments(210);
        dinamicBatchSizeForAttachments = NAMConfigs.getDinamicBatchSizeForAttachments();
        System.assertEquals(210, dinamicBatchSizeForAttachments);
        
        Boolean enableDynamicBatchSize = NAMConfigs.getEnableDynamicBatchSize();
        System.assertEquals(false, enableDynamicBatchSize, 'enableDynamicBatchSize must be false by default');
        
        NAMConfigs.setEnableDynamicBatchSize(true);
        enableDynamicBatchSize = NAMConfigs.getEnableDynamicBatchSize();
        System.assertEquals(true, enableDynamicBatchSize);
        
        Integer minBatchSize = NAMConfigs.getMinBatchSize();
        System.assert(minBatchSize >0);
        
        NAMConfigs.setMinBatchSize(5);
        minBatchSize = NAMConfigs.getMinBatchSize();
        System.assertEquals(5, minBatchSize);
    }
    
    @isTest 
    static void testNotesConfigs() {
        Integer notesBatchSize = NAMConfigs.getBatchSizeForNotes();
        System.assert(notesBatchSize >0);
        
        NAMConfigs.setBatchSizeForNotes(120);
        notesBatchSize = NAMConfigs.getBatchSizeForNotes();
        System.assertEquals(120, notesBatchSize);
    }
    
    @isTest 
    static void testMetadataPageSize() {
        Integer metadataPageSize = NAMConfigs.getMetadataPageSize();
        System.assert(metadataPageSize >0);
        
        NAMConfigs.setMetadataPageSize(10);
        metadataPageSize = NAMConfigs.getMetadataPageSize();
        System.assertEquals(10, metadataPageSize);
    }
    
    @isTest 
    static void testResetAttachmentsConversion() {
        NAMAttachmentConversionStatus__c status = new NAMAttachmentConversionStatus__c();
        status.Name = 'status';
        upsert status;
        NAMConfigController controller = new NAMConfigController();
        controller.resetAttachmentsConversion();
        List<NAMAttachmentConversionStatus__c> results = [SELECT Id, JobId__c 
                                                       FROM NAMAttachmentConversionStatus__c 
                                                          LIMIT 1];
        System.assertEquals(0, results.size());
    }
    
     @isTest 
    static void testResetNotesConversion() {
        NAMNoteConversionStatus__c status = new NAMNoteConversionStatus__c();
        status.Name = 'status';
        upsert status;
        NAMConfigController controller = new NAMConfigController();
        controller.resetNotesConversion();
        List<NAMNoteConversionStatus__c> results = [SELECT Id, JobId__c 
                                                       FROM NAMNoteConversionStatus__c 
                                                          LIMIT 1];
        System.assertEquals(0, results.size());
    }
    
      @isTest 
    static void testOtherConfigs() {
        Integer schedulerSize = NAMConfigs.getSchedulerSize();
        System.assert(schedulerSize >0);
        NAMConfigs.setSchedulerSize(120);
        schedulerSize = NAMConfigs.getSchedulerSize();
        System.assertEquals(120, schedulerSize);
        
        String owner = NAMConfigs.getOwner();
        System.assert(owner.length() >0);
        NAMConfigs.setOwner('123456789');
        owner = NAMConfigs.getOwner();
        System.assertEquals('123456789', owner);
        
        String ownerFrom = NAMConfigs.getOwnerFrom();
        System.assert(ownerFrom.length() >0);
        NAMConfigs.setOwnerFrom('035');
        ownerFrom = NAMConfigs.getOwnerFrom();
        System.assertEquals('035', ownerFrom);
        
        String ownerTo = NAMConfigs.getOwnerTo();
        System.assert(ownerTo.length() >0);
        NAMConfigs.setOwnerTo('03512333');
        ownerTo = NAMConfigs.getOwnerTo();
        System.assertEquals('03512333', ownerTo);
        
        Integer bodyLength = NAMConfigs.getBodyLength();
        System.assert(bodyLength >0);
        NAMConfigs.setBodyLength(1000);
        bodyLength = NAMConfigs.getBodyLength();
        System.assertEquals(1000, bodyLength);
        
    }
    
     @isTest 
    static void testOtherEnableConfigs() {
        
        NAMConfigs.setEnableOwner(true);
        Boolean enableOwner = NAMConfigs.getEnableOwner();
        System.assertEquals(true, enableOwner);
        
        NAMConfigs.setEnableOwnerFromTo(true);
        Boolean enableOwnerFromTo = NAMConfigs.getEnableOwnerFromTo();
        System.assertEquals(true, enableOwnerFromTo);
        
        NAMConfigs.setEnableScheduler(true);
        Boolean enableScheduler = NAMConfigs.getEnableScheduler();
        System.assertEquals(true, enableScheduler);
        
        NAMConfigs.setEnableTimeoutAttachment(true);
        Boolean enableTimeoutAttachment = NAMConfigs.getEnableTimeoutAttachment();
        System.assertEquals(true, enableTimeoutAttachment);
        
        NAMConfigs.setEnableTimeoutNote(true);
        Boolean enableTimeoutNote = NAMConfigs.getEnableTimeoutNote();
        System.assertEquals(true, enableTimeoutNote);
        
        NAMConfigs.setEnableBodyLength(true);
        Boolean enableBodyLength = NAMConfigs.getEnableBodyLength();
        System.assertEquals(true, enableBodyLength);
        
    }
    
    @isTest 
    static void testOtherEnableConfigs2() {
        Integer timeoutNoteSize = NAMConfigs.getTimeoutNoteSize();
        System.assert(timeoutNoteSize >0);
        NAMConfigs.setTimeoutNoteSize(120);
        timeoutNoteSize = NAMConfigs.getTimeoutNoteSize();
        System.assertEquals(120, timeoutNoteSize);
        
        Integer timeoutAttachmentSize = NAMConfigs.getTimeoutAttachmentSize();
        System.assert(timeoutAttachmentSize >0);
        NAMConfigs.setTimeoutAttachmentSize(120);
        timeoutAttachmentSize = NAMConfigs.getTimeoutAttachmentSize();
        System.assertEquals(120, timeoutAttachmentSize);
        
        NAMConfigs.setEnableTimeoutAttachment(true);
        Boolean enableTimeoutAttachment = NAMConfigs.getEnableTimeoutAttachment();
        System.assertEquals(true, enableTimeoutAttachment);
        
        NAMConfigs.setEnableTimeoutNote(true);
        Boolean enableTimeoutNote = NAMConfigs.getEnableTimeoutNote();
        System.assertEquals(true, enableTimeoutNote);
        
    }
    
    
}