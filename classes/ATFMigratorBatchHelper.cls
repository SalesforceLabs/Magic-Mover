public class ATFMigratorBatchHelper {
    
    /**
* @description Creates a ContentVersion
@param attachments to be converted
@param objectName: The type of the parent of the attachments that we are migrating
@return List<NAMMigrationResults>: 
first add the errors (if any) when insert the content versions
second add the error (if any) from the call to the method to create content document links
finally add success if any content version was insert successfully and no errors were return in
the creation of content document links
*/
    
    public static List<NAMMigrationResults> migrateUsingContentVersion(List<Attachment> attachments, String objectName) {
        
        
        //this is used to be able to call a rollback in case something goes wrong along the process 
        //when a rollback is executed, It is only for the current job, not for the whole migration
        Savepoint mySavePoint = Database.setSavepoint(); 
        List<NAMMigrationResults> migrationResultsList = new List<NAMMigrationResults>();
        if(attachments.size() > 0){
            List<ContentVersion> cvsToCreate = new List<ContentVersion>();
            Boolean ownerIsActive = NAMConfigs.getEnableOwner();
            Boolean ownerFromToIsActive = NAMConfigs.getEnableOwnerFromTo();
            String owner;
            String ownerFrom;
            String ownerTo;
            if(ownerIsActive){
                owner = NAMConfigs.getOwner();
            }
            if(ownerFromToIsActive){
                ownerFrom = NAMConfigs.getOwnerFrom();
                ownerTo = NAMConfigs.getOwnerTo();   
            }
            
            for(Attachment oldAttachment :attachments){
                cvsToCreate.add(createContentVersion(oldAttachment, ownerIsActive, owner, ownerFromToIsActive, ownerFrom, ownerTo));
            }
            Integer idsSuccess = 0;
            Integer counter = 0;
            List<Attachment> attachmentsSuccess = new List<Attachment>(); 
            List<Attachment> attachmentsUpdateSuccess = new List<Attachment>(); 
            List<ContentVersion> cvSuccess = new List<ContentVersion>(); 
            //map Id of the attachment with the created ContentVersion (File)
            Map<Id, ContentVersion> mapAttachmentWithCV = new Map<Id, ContentVersion>();
            //map Id of the contentversion (File) with the attachment 
            Map<Id, Attachment> mapCVIdWithAttachment = new Map<Id, Attachment>();
            if(Schema.sObjectType.ContentVersion.isCreateable()
               &&Schema.sObjectType.ContentVersion.fields.Title.isCreateable()
               &&Schema.sObjectType.ContentVersion.fields.VersionData.isCreateable()
               &&Schema.sObjectType.ContentVersion.fields.FirstPublishLocationId .isCreateable()
               &&Schema.sObjectType.ContentVersion.fields.PathonClient.isCreateable()
               &&Schema.sObjectType.ContentVersion.fields.OwnerId.isCreateable()
               &&Schema.sObjectType.ContentVersion.fields.CreatedById.isCreateable()
               &&Schema.sObjectType.ContentVersion.fields.CreatedDate.isCreateable()
               &&Schema.sObjectType.ContentVersion.fields.LastModifiedById.isCreateable()
               &&Schema.sObjectType.ContentVersion.fields.SharingPrivacy.isCreateable()
               &&Schema.sObjectType.ContentVersion.fields.LastModifiedDate.isCreateable()
               &&Schema.sObjectType.ContentVersion.fields.Description.isCreateable()
               &&Schema.sObjectType.ContentVersion.fields.Origin.isCreateable()
               &&Schema.sObjectType.Attachment.isUpdateable()){
                   Database.SaveResult[] srList = Database.insert(cvsToCreate, false);
                   for (Database.SaveResult sr : srList) {
                       if (sr.isSuccess()) {
                           attachmentsSuccess.add(attachments.get(counter));
                           mapAttachmentWithCV.put(attachments.get(counter).Id, cvsToCreate.get(counter));
                       }else{
                           for(Database.Error err : sr.getErrors()) {
                               migrationResultsList.add(new NAMMigrationResults(String.valueOf(attachments.get(counter).Id), '',NAMUtils.isPrivateResult(attachments.get(counter).isPrivate), NAMMigrationResults.StatusEnum.ERROR, err.getStatusCode() + ': '+ err.getMessage()));
                               if(err.getStatusCode().equals(System.StatusCode.STORAGE_LIMIT_EXCEEDED)){
                                   throw new NAMStorageException(migrationResultsList);
                               }
                           }                        
                       }    
                       counter++;
                   }
                   
                   counter = 0;
                   
                   changeNames(mapAttachmentWithCV, attachmentsSuccess); 
                   Boolean errorUpdatingNames = false;
                   Database.SaveResult[] srListUpdate = Database.update(attachmentsSuccess, false);
                   for (Database.SaveResult sr : srListUpdate) {
                       if (sr.isSuccess()) {
                           idsSuccess++;
                           attachmentsUpdateSuccess.add(attachments.get(counter));
                           cvSuccess.add(cvsToCreate.get(counter));
                           mapCVIdWithAttachment.put(cvsToCreate.get(counter).Id, attachments.get(counter));
                       }else{
                           errorUpdatingNames = true;
                           for(Database.Error err : sr.getErrors()) {
                               migrationResultsList.add(new NAMMigrationResults(String.valueOf(attachments.get(counter).Id), '', NAMUtils.isPrivateResult(attachments.get(counter).isPrivate),NAMMigrationResults.StatusEnum.ERROR, err.getStatusCode() + ': '+ err.getMessage()));
                               if(err.getStatusCode().equals(System.StatusCode.STORAGE_LIMIT_EXCEEDED)){
                                   throw new NAMStorageException(migrationResultsList);
                               }
                           }                        
                       }    
                       counter++;
                   }
                   
                   if(errorUpdatingNames){
                       Database.rollback(mySavePoint); 
                       for(Attachment attachment : attachmentsUpdateSuccess){
                           Id attachmentId = String.valueOf(attachment.Id);
                           NAMMigrationResults result =  new NAMMigrationResults(attachmentId, '', NAMUtils.isPrivateResult(attachment.isPrivate), NAMMigrationResults.StatusEnum.ERROR, 'Error trying to update attachments names.');
                           migrationResultsList.add(result);
                       } 
                       
                       
                       
                   } else {
                       List<ID> cvIds = new List<ID>();
                       for(ContentVersion cv :cvSuccess){
                           cvIds.add(cv.id);
                       }
                       
                       
                       Map<ID, ContentVersion> contentVersionMap = new Map<ID, ContentVersion>([
                           SELECT
                           id,
                           contentDocumentId
                           FROM
                           ContentVersion
                           WHERE
                           id IN :cvIds
                       ]);
                       //lists the migrated notes in the email
                       for(Attachment attachment : attachmentsSuccess){
                           Id attachmentId = String.valueOf(attachment.Id);
                           
                           //mapAttachmenteWithCV does not contain contentDocumentId
                           ContentVersion cv = mapAttachmentWithCV.get(attachment.Id);
                           
                           ContentVersion cvConverted =contentVersionMap.get(cv.Id);
                           Id convertedAttachmentId = null;
                           if(cvConverted!=null){
                               convertedAttachmentId = cvConverted.contentDocumentId;
                           }
                           NAMMigrationResults result = new NAMMigrationResults(attachmentId, convertedAttachmentId, NAMUtils.isPrivateResult(attachment.isPrivate),NAMMigrationResults.StatusEnum.SUCCESS, '');
                           migrationResultsList.add(result);
                       }                           
                       
                   }
                   
               }
            
        }
        return migrationResultsList;
    }
    
    
    
    /**
* @description This method takes the list of attachments and the map with the attachment Id and file create for it (contentversion)
* and calls the transformNames method to retrive the new name (put the file id (ContentVersion Id) on the begining of the name) 
* @param mapToLink 
* @param attachments 
*/
    public static void changeNames(Map<Id, ContentVersion> mapToLink, List<Attachment> attachments){
        String newName = '';
        for (Attachment attachment : attachments){
            if(mapToLink.get(attachment.Id).Id != null){                
                newName = transformNames(mapToLink.get(attachment.Id).Id, attachment.Name);
                system.debug(newName);
                system.debug(newName.length());
                if(newName.length() > 255){
                    String couttedName = newName.substring(0, 254);
                    attachment.Name = couttedName;
                } else {
                    
                    attachment.Name = newName; 
                    
                }
            }
        }
    }
    
    /**
* @description used to create the new name (put the file id (ContentVersion Id) on the begining of the name) 
* @param contentVersionId 
* @param nameAttachment 
* @return
*/
    public static String transformNames(Id contentVersionId, String nameAttachment){
        String contentVersionIdString = '';
        contentVersionIdString = contentVersionId;
        return '[' + contentVersionIdString.substring(0,15) +']' + ' ' + nameAttachment;
        
    }
    
    /*
* @description Create a ContentVersion from a Attachment
*/
    private static ContentVersion createContentVersion(Attachment oldAttachment, Boolean ownerIsActive, String owner, Boolean ownerFromToIsActive, String ownerFrom, String ownerTo) {
        ContentVersion cv = new ContentVersion();
        
        // data fields
        cv.pathOnClient = '/' + oldAttachment.name;
        cv.Title = oldAttachment.Name.substringBeforeLast('.');
        cv.Description = NAMUtils.cleanUpNoteBody(oldAttachment.Description).replaceAll('&amp;','&');
        cv.Origin = 'H'; 
        if(oldAttachment.Body == null || Blob.valueOf('') == oldAttachment.Body){
            //VersionData is a required field, so we set a default value
            cv.VersionData = Blob.valueOf('null');
        }else{
            cv.VersionData = oldAttachment.Body;
        }
        cv.CreatedDate = oldAttachment.CreatedDate;   
        if(ownerFromToIsActive && String.valueOf(oldAttachment.OwnerId).startsWith(ownerFrom)){
            cv.OwnerId = ownerTo;
            cv.CreatedById = ownerTo;
        } else if (ownerIsActive) {
            cv.OwnerId = owner;
            cv.CreatedById = owner;
        } else{
            cv.OwnerId = oldAttachment.OwnerId;
            cv.CreatedById = oldAttachment.OwnerId;
        }
        
        cv.LastModifiedById = oldAttachment.LastModifiedById;
        cv.LastModifiedDate = oldAttachment.LastModifiedDate;
        /*
* "Setting FirstPublishLocationId allows you to create a file and share it with an initial 
* record/group in a single transaction"
* ContentDocumentLink will create automatically by Salesforce
*/
        cv.FirstPublishLocationId = oldAttachment.parentId;
        if(oldAttachment.IsPrivate){
            cv.SharingPrivacy = 'P';
        } 
        
        
        return cv;
    }
}