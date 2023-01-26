/**
* @author Jessica Bernal, Andres Canavesi
* @description a service to provice methods for AttachmentConversionStatus custom object. 
* This custom object is used to know which objects still have attachments records in progress migration.
* It's a flag to avoid two users (or the same user) to migrate attachments from objects at the same time
* @date 2017-01
* edited ateppo 4/15/2020
*/
public with sharing class  ATFAttachmentConversionStatus {
    
    /**
* @param objectName
*/
    public static Boolean isInProgressByObjectName(String objectName){

        List<NAMAttachmentConversionStatus__c> results = new List<NAMAttachmentConversionStatus__c>();

        if (Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Id.isAccessible() 
	        && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.JobId__c.isAccessible()) {
                results = [SELECT Id, JobId__c 
                            FROM NAMAttachmentConversionStatus__c 
                            WHERE ObjectName__c = :objectName 
                            AND RecordId__c = null
                            AND Type__c = 'MigrationAttachment'
                            LIMIT 1];
        } 
        List<NAMAttachmentConversionStatus__c> migrationResults = filterAbortedAndCompletedJobs(results);
       
        return migrationResults.size()>0;
    }
    
    /**
* @param objectName
*/
    public static NAMAttachmentConversionStatus__c findByObjectNameDeletion(String objectName){

        List<NAMAttachmentConversionStatus__c> result = new List<NAMAttachmentConversionStatus__c>();
        //We ask for RecordId__c = null because we are in a bulk context

        if (Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Id.isAccessible()) {
                result = [SELECT Id 
                            FROM NAMAttachmentConversionStatus__c 
                            WHERE ObjectName__c = :objectName
                            AND RecordId__c = null
                            AND Type__c = 'Deletion'
                            LIMIT 1];
        }
        if(result.size()>0){
            return result.get(0);
        }else{
            return null;
        }
    }
    
    /**
* @param objectName
*/
    public static Boolean isInProgressByObjectNameDeletion(String objectName){

        List<NAMAttachmentConversionStatus__c> results = new List<NAMAttachmentConversionStatus__c>();

        if (Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Id.isAccessible() 
	        && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.JobId__c.isAccessible()) {
                results = [SELECT Id, JobId__c
                            FROM NAMAttachmentConversionStatus__c 
                            WHERE ObjectName__c = :objectName 
                            AND RecordId__c = null
                            AND Type__c = 'Deletion'
                            LIMIT 1];
        }
        List<NAMAttachmentConversionStatus__c> resultDeletion = filterAbortedAndCompletedJobs(results);
        return resultDeletion.size()>0;
    }
    
    /**
* @param objectName
*/
    private static void changeStatusByObjectNameDeletion(String objectName, String batchId){        
        if (Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.ObjectName__c.isCreateable()
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Type__c.isCreateable()
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Type__c.isUpdateable()
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.JobId__c.isCreateable()
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.JobId__c.isUpdateable()
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.ObjectName__c.isUpdateable()) {
                NAMAttachmentConversionStatus__c status = findByObjectNameDeletion(objectName);
                if(status == null){
                    status = new NAMAttachmentConversionStatus__c();
                    status.ObjectName__c = objectName;
                    status.Type__c = 'Deletion';
                }
                if(batchId != null){
                    status.JobId__c = batchId;
                }
                upsert status;
            }  else{
                throw new NAMForbiddenException('NAMAttachmentConversionStatus__c - changeStatusByObjectNameDeletion access ERROR: isCreateable() or isUpdateable() for status.ObjectName__c or status.Type__c');
                
            }
    }
    
    /**
* @param objectName
*/
    public static void changeToInProgressByObjectNameDeletion(String objectName, String batchId){
        changeStatusByObjectNameDeletion(objectName, batchId);
    }
    
    /**
* @param objectName
*/
    public static void changeToCompletedByObjectNameDeletion(String objectName){
        NAMAttachmentConversionStatus__c status = findByObjectNameDeletion(objectName);
        if (NAMAttachmentConversionStatus__c.sObjectType.getDescribe().isDeletable()) {            
            if(status != null){
                List<Id> statusId= new List<Id>();
                statusId.add(status.Id);
                delete status;
                if(statusId != null){
                    Database.emptyRecycleBin(statusId);
                }
                
            }
        }else{
            throw new NAMForbiddenException('NAMAttachmentConversionStatus__c - changeToCompletedByObjectNameDeletion access ERROR: isDeletable() for NAMAttachmentConversionStatus__c');
            
        }
        
        
    }   
    
    /**
* @param objectName
*/
    public static NAMAttachmentConversionStatus__c findByObjectName(String objectName){
        //We ask for RecordId__c = null because we are in a bulk context
        List<NAMAttachmentConversionStatus__c> result = new List<NAMAttachmentConversionStatus__c>();

        if (Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Id.isAccessible()) {
            result = [SELECT Id 
                        FROM NAMAttachmentConversionStatus__c 
                        WHERE ObjectName__c = :objectName
                        AND RecordId__c = null
                        AND Type__c = 'MigrationAttachment'
                        LIMIT 1];
        }
        if(result.size()>0){
            return result.get(0);
        }else{
            return null;
        }
    }
 
    /**
* @param objectName
* @param quantity
*/
    private static void changeStatusByObjectName(String objectName, Integer quantity, String batchId){
        if (Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Quantity__c.isCreateable()
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Type__c.isCreateable()
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.jobId__c.isCreateable()
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.ObjectName__c.isCreateable()
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Type__c.isUpdateable()
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Quantity__c.isUpdateable()
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.jobId__c.isUpdateable()
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.ObjectName__c.isUpdateable()) {
                NAMAttachmentConversionStatus__c status = findByObjectName(objectName);
                if(status == null){
                    status = new NAMAttachmentConversionStatus__c();
                    status.ObjectName__c = objectName;
                    status.Type__c = 'MigrationAttachment';
                    if(quantity != null){
                        status.Quantity__c = quantity;
                    }
                }
                status.Quantity__c = quantity;
                if(batchId != null){
                    status.jobId__c = batchId;
                }
                upsert status;
                
            }else{
                throw new NAMForbiddenException('NAMAttachmentConversionStatus__c - changeStatusByObjectName access ERROR: isCreateable() or isUpdateable() for status.ObjectName__c, status.Quantity__c or status.Type__c');
            }
    }
    
    /**
* @param objectName
* @param quantity
*/
    public static void changeToInProgressByObjectName(String objectName, Integer quantity, String batchId){
        changeStatusByObjectName(objectName, quantity, batchId);
    }
    
    /**
* @param objectName
*/
    public static void changeToCompletedByObjectName(String objectName){
        NAMAttachmentConversionStatus__c status = findByObjectName(objectName);
        if (NAMAttachmentConversionStatus__c.sObjectType.getDescribe().isDeletable()) {            
            if(status != null){
                List<Id> statusId= new List<Id>();
                statusId.add(status.Id);
                delete status;
                if(statusId != null){
                    Database.emptyRecycleBin(statusId);
                }
            }
        }else{
            throw new NAMForbiddenException('NAMAttachmentConversionStatus__c - changeToCompletedByObjectNameDeletion access ERROR: isDeletable() for NAMAttachmentConversionStatus__c');
        }
    }
    
   public static void deleteAllAttachmentConversionStatus(){
        List<NAMAttachmentConversionStatus__c> allStatus = new List<NAMAttachmentConversionStatus__c>();
        if (Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Id.isAccessible()) {
            allStatus = [SELECT Id FROM NAMAttachmentConversionStatus__c LIMIT :NAMUtils.LIMIT_QUERIES_OBJECTS];
        }
        if (NAMAttachmentConversionStatus__c.sObjectType.getDescribe().isDeletable()) {            
            if(allStatus != null){
                delete allStatus;
            }
        }else{
            throw new NAMForbiddenException('NAMAttachmentConversionStatus__c - deleteAllAttachmentConversionStatus access ERROR: isDeletable() for NAMAttachmentConversionStatus__c');
        }
    }
    
    /**
* @return returns a lists containing the objects that have a migration in progress this is used for bulk migration
*/
    public static List<NAMAttachmentConversionStatus__c> findInProgressObjects(){
        List<NAMAttachmentConversionStatus__c> objects = new List<NAMAttachmentConversionStatus__c>();
        if (Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.ObjectName__c.isAccessible() 
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Quantity__c.isAccessible() 
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.JobId__c.isAccessible()) {
            objects = [SELECT ObjectName__c, Quantity__c, JobId__c 
                        FROM NAMAttachmentConversionStatus__c
                        WHERE Type__c = 'MigrationAttachment' 
                        AND (NOT ObjectName__c = 'byObjectId')
                        AND (NOT ObjectName__c = 'byId')];
        }
        return filterAbortedAndCompletedJobs(objects);
    }
    
    public static List<NAMAttachmentConversionStatus__c> findInProgressId(){
        List<NAMAttachmentConversionStatus__c> objects = new List<NAMAttachmentConversionStatus__c>();
        if (Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.ObjectName__c.isAccessible() 
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Quantity__c.isAccessible() 
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.JobId__c.isAccessible()) {
            objects = [SELECT ObjectName__c, Quantity__c, JobId__c 
                        FROM NAMAttachmentConversionStatus__c
                        WHERE Type__c = 'MigrationAttachment' 
                        AND (ObjectName__c = 'byObjectId' OR ObjectName__c = 'byId')];
        }
        system.debug('objects');
        system.debug(objects);
        return objects;
    }
    
    public static List<NAMAttachmentConversionStatus__c> filterAbortedAndCompletedJobs(List<NAMAttachmentConversionStatus__c> objects){
        List<NAMAttachmentConversionStatus__c> results = new List<NAMAttachmentConversionStatus__c>();
        //If the batch does not finish properly because the job is aborted the status keeps in progress but for the UI it isn't.
        //When a new batch is created the jobId changes and the other one is discarded.
        //We can't send an email with the results of the migration in the case that the job is aborted.
        if (Schema.sObjectType.AsyncApexJob.fields.Status.isAccessible()) {
            for(NAMAttachmentConversionStatus__c result:objects){
                List<AsyncApexJob> jobs = [SELECT Status FROM AsyncApexJob WHERE id = :result.JobId__c LIMIT 1];
                if(jobs!=null&&jobs.size()>0){
                    AsyncApexJob job = jobs.get(0);
                    if(!job.status.equals('Aborted') && !job.status.equals('Completed') && !job.status.equals('Failed') ){
                        results.add(result);
                    }
                }
            }
        }
        return results;
        
    }
    
    /**
* @return returns a lists containing the objects that have a migration or deletion in progress this is used for bulk migration
*/
    public static List<NAMAttachmentConversionStatus__c> findInProgress(){
        List<NAMAttachmentConversionStatus__c> objects = new List<NAMAttachmentConversionStatus__c>();
        if (Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.ObjectName__c.isAccessible() 
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Quantity__c.isAccessible() 
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.JobId__c.isAccessible()) {
            objects = [SELECT ObjectName__c, Quantity__c, JobId__c 
                        FROM NAMAttachmentConversionStatus__c LIMIT 1000];
        }
        return filterAbortedAndCompletedJobs(objects);
    }
    
    /**
* @param statuses
* @param objectName
*/
    public static Boolean containsObjectByName(List<NAMAttachmentConversionStatus__c> statuses, String objectName){
        for(NAMAttachmentConversionStatus__c status :statuses){
            if(status.ObjectName__c != null && status.ObjectName__c == objectName){
                return true;
            }
        }
        return false;
    }
    
    /**
* @param statuses
* @param objectName
*/
    public static Integer containsObjectByNameGetQuantity(List<NAMAttachmentConversionStatus__c> statuses, String objectName){
        Integer quantity = 0;
        for(NAMAttachmentConversionStatus__c status :statuses){
            if(status.ObjectName__c != null && status.ObjectName__c == objectName){
                quantity =(Integer) status.Quantity__c;
            }
        }
        return quantity;
    }
    
    /**
* @return returns a lists containing the objects that have a migration in progress but are tye deletion this is used for bulk migration
*/
    public static List<NAMAttachmentConversionStatus__c> findInProgressObjectsDeletion(){
        List<NAMAttachmentConversionStatus__c> deletions = new List<NAMAttachmentConversionStatus__c>();
        if (Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.ObjectName__c.isAccessible()  
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.JobId__c.isAccessible()) {
                deletions = [SELECT ObjectName__c, JobId__c 
                    FROM NAMAttachmentConversionStatus__c       
                    WHERE Type__c = 'Deletion'];
            }
        return filterAbortedAndCompletedJobs(deletions);
    }    
    
}