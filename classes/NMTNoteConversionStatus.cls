/**
* @author Jessica Bernal, Andres Canavesi
* @description a service to provice methods for NoteConversionStatus custom object. 
* This custom object is used to know which objects still have notes records in progress migration.
* It's kind of a flag to avoid two users (or the same user) migrate notes from objects at the same time
* @date 2017-01
* edited ateppo 5/5/2020
*/

public with sharing class NMTNoteConversionStatus {
   
    /**
* @param state
* @param jobId
* @param action
* 
*/
    public static void changeStatus(String state, String jobId, String action){
        
        if (Schema.sObjectType.NAMNoteConversionStatus__c.fields.Status__c.isCreateable()
            && Schema.sObjectType.NAMNoteConversionStatus__c.fields.JobId__c .isCreateable()
            && Schema.sObjectType.NAMNoteConversionStatus__c.fields.Type__c .isCreateable()
            && Schema.sObjectType.NAMNoteConversionStatus__c.fields.Status__c.isUpdateable()
            && Schema.sObjectType.NAMNoteConversionStatus__c.fields.JobId__c .isUpdateable()
            && Schema.sObjectType.NAMNoteConversionStatus__c.fields.Type__c .isUpdateable()) {
                List<NAMNoteConversionStatus__c> statusList = find();
                NAMNoteConversionStatus__c status;
                
                if(statusList.size() > 0){
                    status= statusList.get(0);
                } else{
                    status = new NAMNoteConversionStatus__c();
                }    
                if(jobId != null){
                    status.JobId__c = jobId;
                }
                status.Type__c = action;
                status.Status__c = state; 
                upsert status;
                
            }else{
                system.debug('NAMNoteConversionStatus__c - changeStatusByObjectName access');
                throw new NAMForbiddenException('NAMNoteConversionStatus__c - changeStatusByObjectName access ERROR: isCreateable() or isUpdateable() for status.ObjectName__c or status.Status__c');
                
            }
        
    }
    
    public static List<NAMNoteConversionStatus__c> find(){
        /* SR note: user CRUD/FLS checks not appropriate here */
        return [SELECT Id, Status__c, JobId__c, Type__c, LastModifiedDate
                FROM NAMNoteConversionStatus__c 
                LIMIT 1];
    } 
    
    public static NAMNoteConversionStatus__c findStatus(){
        /* SR note: user CRUD/FLS checks not appropriate here */
        List<NAMNoteConversionStatus__c> statuses = [SELECT Id, Status__c, JobId__c, Type__c
                FROM NAMNoteConversionStatus__c 
                LIMIT 1];
        if(statuses.isEmpty()){
            return null;
        }
        return statuses.get(0);
    }
     
    /**
* @description
*/
    public static Boolean isInProgress(){

        List<ApexClass> classNameId;
        List<ApexClass> classNameDeleteId;
        
        /* SR note: user CRUD/FLS checks not appropriate here */
        if(NMTMigratorBatch.class.getName().contains('.')){
            classNameId = [SELECT id FROM ApexClass WHERE 
                           name = :NMTMigratorBatch.class.getName().substringAfter('.')
                           AND NamespacePrefix = :NMTMigratorBatch.class.getName().substringBefore('.')
                           LIMIT 1];
        } else {
            classNameId = [SELECT id FROM ApexClass WHERE name = :NMTMigratorBatch.class.getName() LIMIT 1];
        }
        
        if(NMTDeleteBatch.class.getName().contains('.')){
             classNameDeleteId = [SELECT id FROM ApexClass WHERE 
                                  name = :NMTDeleteBatch.class.getName().substringAfter('.')
                                  AND NamespacePrefix = :NMTDeleteBatch.class.getName().substringBefore('.')
                                  LIMIT 1];
        } else {
            classNameDeleteId = [SELECT id FROM ApexClass WHERE name = :NMTDeleteBatch.class.getName() LIMIT 1];
        }
        
        List<AsyncApexJob> jobs = [SELECT Status FROM AsyncApexJob WHERE (Status = 'Processing' 
                                       OR Status = 'Holding' 
                                       OR Status = 'Queued'
                                       OR Status = 'Preparing')
                                       AND (ApexClassID  = :classNameId.get(0).Id 
                                        OR ApexClassID  = :classNameDeleteId.get(0).Id) 
                                   LIMIT 1];
        
        return jobs.size()>0;
    }
       public static void deleteAllNoteConversionStatus(){
        List<NAMNoteConversionStatus__c> allStatus = [SELECT Id 
                                                       FROM NAMNoteConversionStatus__c 
                                                       LIMIT :NAMUtils.LIMIT_QUERIES_OBJECTS];
        if (NAMNoteConversionStatus__c.sObjectType.getDescribe().isDeletable()) {            
            if(allStatus != null){
                delete allStatus;
            }
        }else{
            throw new NAMForbiddenException('NAMNoteConversionStatus__c - deleteAllNoteConversionStatus access ERROR: isDeletable() for NAMAttachmentConversionStatus__c');
        }
    }
    
}