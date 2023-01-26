/**
* @author Jessica Bernal, Andres Canavesi
* @description Batch process for running the migration in a huge collection of data. 
*/ 
global with sharing class ATFMigratorBatch implements Database.Batchable<sObject>, Database.stateful{    
    
    private final String objectName;
    /**
* @description could be byId, byObjectId or byObject
*/
    private final String migrationType;
    /**
* @description the amount of attachments that the user wants to migrate. If null will migrate all attachments (not converted)
*/
    private final Integer totalToMigrate;    
    private final List<String> listIds;
    
    private final Date startDate;
    private final Date endDate;
    
    private Integer totalToMigrateBeginning; 
    
    public Integer attachmentsToBeMigrated = 0;
    public Integer totalFiles = 0;
    public Integer totalFilesFailed = 0;
    public Integer recordsBatch = 0;
    
    /**
* @description a flag to know if and error related to org limits has occurred.
* We have to use this way since LimitException can't be caught
*/
    public Boolean limitError = false;
    public Boolean attachmentsAreCero = true;
    public Boolean byCreateDate;
    public List<Id> listAttachmentsFail = new List<Id>();
    
    /**
* List of results to send by CSV
*/
    public List<NAMMigrationResults> migrationResultsGlobal;
    
    
    
    /**
* @param objectName the parent type of the attachments to migrate (Account, Contact, etc.)
* @param deleteAfterMigration true to delete attachments after success migration.
* @param totalToMigrate
* @param startDate
* @param endDate
*/
    public ATFMigratorBatch(String objectName, List<String> listIds, String migrationType, Integer totalToMigrate, Date startDate, Date endDate, Boolean byCreateDate){
        this.totalToMigrate = totalToMigrate; 
        this.totalToMigrateBeginning = totalToMigrate;
        this.objectName = objectName;        
        this.migrationType = migrationType;       
        this.listIds = listIds;           
        this.migrationResultsGlobal = new List<NAMMigrationResults>();
        this.startDate = startDate;
        this.byCreateDate = byCreateDate;
        this.endDate = endDate.addDays(1);
        System.debug('Starting MigratorBatch for objectName: '+objectName+ ' listIds: '+listIds+' migrationType: '+migrationType+' totalToMigrate: '+totalToMigrate);
        
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        DateTime startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), 00, 00, 00);
        DateTime endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 00, 00, 00);
        String sstart = startDateTime.format(NAMUtils.DATE_TIME_FORMAT);
        String send = endDateTime.format(NAMUtils.DATE_TIME_FORMAT);
        Integer limitQuery = totalToMigrate-totalFiles;
        System.debug('Total to Migrate '+totalToMigrate);
        System.debug('Total Migrated '+totalFiles);
        System.debug('Total to Migrate in this Batch '+limitQuery);
        
        String query = 'SELECT Id, Name, Body, Description, ParentId, OwnerId, LastModifiedDate, CreatedDate, LastModifiedById, IsPrivate FROM Attachment WHERE ';
        if(migrationType == 'byObject'){
            query += 'Parent.Type = \''+String.escapeSingleQuotes(this.objectName)+'\' AND bodyLength != 0'; 
            
            if(NAMConfigs.getEnableBodyLength()){
                Integer bodyLengthValue = NAMConfigs.getBodyLength() * 1024 * 1024;  
                query += ' AND bodyLength <= :bodyLengthValue ';
            }
            if(byCreateDate){
                query +=  ' AND createdDate >= ' + sstart + ' AND createdDate <= ' + send;
            } else {
                query +=  ' AND lastModifiedDate >= ' + sstart + ' AND lastModifiedDate <= ' + send;
            } 
        } 
        if(listIds !=null && migrationType == 'byId'){
            System.debug(listIds);
            query += 'Id in :listIds ';            
        } 
        if(listIds !=null && migrationType == 'byObjectId'){
            query += 'ParentId in :listIds ';            
        }
        
        //condition for not migrated attachments        
        query += ' AND (NOT  Name LIKE \''+ NAMUtils.MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN+'\') ';
        query += ' ORDER BY ParentId ASC, Id ASC '; 
        if(migrationType == 'byObject'){
            system.debug('NAMConfigs.getSchedulerSize(): ' + NAMConfigs.getSchedulerSize());
            if(NAMConfigs.getEnableScheduler() && totalToMigrate >= NAMConfigs.getSchedulerSize() && NAMConfigs.getSchedulerSize() > 0){
                query += ' LIMIT '+ NAMConfigs.getSchedulerSize(); 
                ATFAttachmentConversionStatus.changeToInProgressByObjectName(objectName, NAMConfigs.getSchedulerSize(), BC.getJobId());
                
            } else{
                query += ' LIMIT '+ limitQuery; 
            }  
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Attachment> attachments){
        system.debug('start batch: ' + attachments.size());
        limitError = true;
        /* SR note: user CRUD/FLS checks not appropriate here */
        AsyncApexJob currentBatch = [Select Id, Status, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()]; 
        String currentBatchValue = currentBatch.ExtendedStatus;
        
        if(currentBatchValue !=null 
           && currentBatchValue.containsIgnoreCase('error')
           &&!currentBatchValue.toLowerCase().contains(NAMUtils.APEX_CPU_LIMIT_TEXT.toLowerCase())
           &&!currentBatchValue.toLowerCase().contains(NAMUtils.APEX_HEAP_LIMIT_TEXT.toLowerCase())){
               attachmentsAreCero = false;
               this.limitError = true;
               List<NAMMigrationResults> errorObject = new List<NAMMigrationResults>();
               errorObject.add(new NAMMigrationResults(null,null,null,NAMMigrationResults.StatusEnum.ERROR, currentBatchValue));
               migrationResultsGlobal.addAll(errorObject);
               mycustomfinish(true,bc);
               System.abortJob(bc.getJobId());
           }else{
               system.debug('batch else');
               try{
                   if(attachments.size() > 0){
                       System.debug('attachments.size is greater than 0');
                       attachmentsAreCero = false;
                       recordsBatch = attachments.size();
                       attachmentsToBeMigrated += attachments.size();
                       
                       List<NAMMigrationResults> migrationresultsConversion = ATFMigratorBatchHelper.migrateUsingContentVersion(attachments, objectName);
                       System.debug(migrationresultsConversion);
                       Integer countSuccess = 0;
                       Integer countErrors = 0;
                       for(NAMMigrationResults migrationresult: migrationresultsConversion)
                       {
                           if(migrationresult.Status!=null && migrationresult.Status.equals(NAMMigrationResults.StatusEnum.SUCCESS)){
                               countSuccess++;
                           }if(migrationresult.Status!=null && migrationresult.Status.equals(NAMMigrationResults.StatusEnum.ERROR)){
                               countErrors++;
                           }
                       }
                       migrationResultsGlobal.addAll(migrationresultsConversion);
                       totalFiles += countSuccess;
                       totalFilesFailed += countErrors;
                   } 
                   
                   /*
* Since we cannot catch LimitException we did this workaround
* When an error related to org limits ocurrs this line is not executed
* after all jobs are completed the finish() method is executed and we can
* warn the user through this flag.
*/
                   limitError = false;
               }catch(NAMStorageException ex){
                   this.limitError = false;
                   if(ex.migrationResultsException!=null){
                       migrationResultsGlobal.addAll(ex.migrationResultsException);
                   }
                   mycustomfinish(true,bc);
                   System.abortJob(bc.getJobId());
               } catch(Exception ex){
                   System.debug('MigratorBatch - Error: ' + ex.getMessage());
                   List<NAMMigrationResults> errorObject = new List<NAMMigrationResults>();
                   errorObject.add(new NAMMigrationResults(null,null,null,NAMMigrationResults.StatusEnum.ERROR, 'MigratorBatch - Error: ' + ex.getMessage()));
                   migrationResultsGlobal.addAll(errorObject);
               } 
           }
        
    }
    
    global void finish(Database.BatchableContext bc){
        mycustomfinish(false,bc);
    }
    
    /**
* @description finish method is not executed if we abort the batch. We use this method for both situations: normal and abort finishing
*/
    private void mycustomfinish(Boolean storage,Database.BatchableContext bc){
        String limitMessage = '';
        Boolean setStatus = true;
        
        try{
            //verify the status of the job looking for possible errors
            /* SR note: user CRUD/FLS checks not appropriate here */
            List<AsyncApexJob> jobs = [SELECT ExtendedStatus FROM AsyncApexJob WHERE id = :bc.getJobId()];
            if(jobs!=null&&!jobs.isEmpty()){
                if(jobs[0].ExtendedStatus!=null){
                    limitMessage = jobs[0].ExtendedStatus;
                }
            }
            
            //If there is a CPU time limit exceeded try to migrate with a smaller batch size only if is migrating by 
            //object and the dynamic batch size is enabled
            
            if((limitMessage.toLowerCase().contains(NAMUtils.APEX_CPU_LIMIT_TEXT.toLowerCase()) 
                || limitMessage.toLowerCase().contains(NAMUtils.APEX_HEAP_LIMIT_TEXT.toLowerCase()))
               && NAMConfigs.getEnableDynamicBatchSize() && migrationType.equals('byObject')){
                   //don't set the status at the end of this batch
                   setStatus = false;
                   //create the new batch with the same parameters (just subtract the files already migrated to the total to migrate)
                   ATFMigratorBatch batch = new ATFMigratorBatch(objectName, null, migrationType, totalToMigrate, startDate, endDate, byCreateDate);
                   
                   //add the current migration success to the batch to send it in the final mail.
                   List<NAMMigrationResults> newmigrationResults = new List<NAMMigrationResults>();
                   for(NAMMigrationResults result:migrationResultsGlobal){
                       if(result.Status!=null && result.Status.equals(NAMMigrationResults.StatusEnum.SUCCESS)){
                           newmigrationResults.add(result);
                       }
                   }
                   batch.migrationResultsGlobal = newmigrationResults;
                   
                   //specify the total files already migrated
                   batch.totalFiles = totalFiles;
                   
                   //specify the total files to be migrated
                   batch.attachmentsToBeMigrated = totalFiles;
                   
                   //figure out the better batch size
                   Integer batchSize = NAMConfigs.getDinamicBatchSizeForAttachments()/2;
                   
                   //update the dynamic batch size
                   NAMConfigs.setDinamicBatchSizeForAttachments(batchSize);
                   
                   //we do this until the batch size reach 5 value (we can do a config with this value too)
                   if(batchSize>NAMConfigs.getMinBatchSize()){
                       Id batchId = Database.executeBatch(batch, batchSize);   
                       ATFAttachmentConversionStatus.changeToInProgressByObjectName(objectName, totalToMigrate, batchId);
                   }else{
                       NAMConfigs.setDinamicBatchSizeForAttachments(NAMConfigs.getBatchSizeForAttachments());
                       NAMEmailHelper.emailSetupAndSend(true,objectName,migrationResultsGlobal,totalFiles,limitError,storage, false, attachmentsToBeMigrated,totalFilesFailed,listIds,limitMessage);
                   }
                   
               }
            else{
                //update the dynamic batch size to the default value
                NAMConfigs.setDinamicBatchSizeForAttachments(NAMConfigs.getBatchSizeForAttachments());
                
                NAMEmailHelper.emailSetupAndSend(true,objectName,migrationResultsGlobal,totalFiles,limitError,storage, false, attachmentsToBeMigrated,totalFilesFailed,listIds,limitMessage);
            }
        }catch(Exception e){
            System.debug('Error sending the email when the migration has finished. '+e.getMessage());
        }finally{ 
            if(setStatus){
                if(migrationType == 'byObject'){
                    ATFAttachmentConversionStatus.changeToCompletedByObjectName(objectName);
                    
                    Integer quantityLeft = totalToMigrateBeginning-totalFiles;
                    if(NAMConfigs.getEnableScheduler() && !attachmentsAreCero && NAMConfigs.getSchedulerSize() > 0 && quantityLeft > 0){
                        ATFMigratorBatch batchScheduler = new ATFMigratorBatch(this.objectName, null, this.migrationType, quantityLeft, this.startDate, this.endDate, this.byCreateDate);
                        String cronID = System.scheduleBatch(batchScheduler, 'MigratorBatch'+this.objectName+quantityLeft, NAMUtils.SCHEDULER_TIME);
                        
                    } 
                } else {
                    ATFAttachmentConversionStatus.changeToCompletedByObjectName(migrationType);
                }
            }
        }
    }
    
}