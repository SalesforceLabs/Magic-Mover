/**
* @author Jessica Bernal, Andres Canavesi
* @description Batch process for running the migration in a huge collection of data. 
*/ 

global with sharing class NMTMigratorBatch implements Database.Batchable<sObject>, Database.stateful{    
    
    private final String objectName;
    /**
* @description could be byId, byObjectId or byObject
*/
    private final String migrationType;
    /**
* @description the amount of notes that the user wants to migrate. If null will migrate all notes (not converted)
* this attribute will be decremented for each succes migrated note.
*/
    private Integer totalToMigrate; 
    
    private Integer totalToMigrateBeginning; 
    /**
* @description 
*/
    private final List<String> listIds; 
    
    private final Date startDate;
    private final Date endDate;
    /**
* @description not all processed notes will be migrated, some of them maybe have been migrated
*/
    public Integer notesToBeMigrated = 0;
    public Integer totalFiles = 0;
    public Integer totalFilesFailed = 0;
    public Integer recordsBatch = 0;
    public Boolean invalidChar = false;
    
    /**
* @description a flag to know if and error related to org limits has occurred
* we have to do this way since LimitException can't be caught
*/
    public Boolean limitError = false;
    public Boolean notesAreCero = false;
    public Boolean byCreateDate;
    public List<Id> listNotesFail = new List<Id>();
    
    /**
* List of results to send by CSV
*/
    public List<NAMMigrationResults> migrationResultsGlobal;
    
    /**
* @param objectName the parent type of the notes to migrate (Account, Contact, etc.). 
* must not be null if migraitonType is byObject
* @param listIds notes ids to migrate.
* @param migrationType must be not null
* @param totalToMigrate if It is null will migrate all notes that were not converted yet
*/
    public NMTMigratorBatch(String objectName, List<String> listIds, String migrationType, Integer totalToMigrate, Date startDate, Date endDate, Boolean byCreateDate){
        this.totalToMigrateBeginning = totalToMigrate;
        if(NAMConfigs.getEnableScheduler() && NAMConfigs.getSchedulerSize() > 0){
            this.totalToMigrate = NAMConfigs.getSchedulerSize();
        } else {
            this.totalToMigrate = totalToMigrate; 
        }
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
        
        //this query cannot contain a LIMIT since we don't know which of this notes are already converted
        //because of that we go through all notes in database (converted and not converted)
        DateTime startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), 00, 00, 00);
        DateTime endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 00, 00, 00);
        String sstart = startDateTime.format(NAMUtils.DATE_TIME_FORMAT);
        String send = endDateTime.format(NAMUtils.DATE_TIME_FORMAT);
        String query = 'SELECT Id, Title, Body, Parent.Type, OwnerId, LastModifiedDate, CreatedDate, CreatedById, LastModifiedById, IsPrivate ' 
            +' FROM Note WHERE';
        
        if(listIds !=null && migrationType == 'byId'){
            System.debug(listIds);
            query += ' Id in :listIds ';            
        } 
        if(listIds !=null && migrationType == 'byObjectId'){
            query += ' ParentId in :listIds ';            
        } 
        if(migrationType == 'byObject'){
            if(byCreateDate){    
                query+=' createdDate >= ' + sstart + ' and createdDate <= ' + send;
            } else {
                query+=' lastModifiedDate >= ' + sstart + ' and lastModifiedDate <= ' + send;  
            }
            query += ' AND Parent.Type = \''+ String.escapeSingleQuotes(objectName) + '\'';
        }
        
        query += ' ORDER BY Id ASC ';
        
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Note> notes){
        
        AsyncApexJob currentBatch = [Select Id, Status, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];  
        String currentBatchValue = currentBatch.ExtendedStatus;
        if(currentBatchValue !=null && currentBatchValue.containsIgnoreCase('error')){
            this.limitError = true;
            List<NAMMigrationResults> errorObject = new List<NAMMigrationResults>();
            errorObject.add(new NAMMigrationResults(null,null,null,NAMMigrationResults.StatusEnum.ERROR, currentBatchValue));
            migrationResultsGlobal.addAll(errorObject);
            mycustomfinish(true,bc);
            System.abortJob(bc.getJobId());
            
        }else{
            try{
                this.limitError = true;
                //to know how many notes we are going to migrate in this batch
                integer totalToMigrateBatch;
                if(NAMConfigs.getEnableScheduler() && totalToMigrateBeginning >= NAMConfigs.getSchedulerSize() && NAMConfigs.getSchedulerSize() > 0){
                    NMTNoteConversionStatus.changeStatus('Progress', BC.getJobId(),'Convertion');
                } 
                
                if(totalToMigrate == null || totalToMigrate > notes.size()){
                    
                    totalToMigrateBatch = notes.size();
                }else{
                    totalToMigrateBatch = totalToMigrate;
                }
                
                if(totalToMigrateBatch > 0){
                    
                    List<Note> notesToMigrate = new List<Note>();
                    if(NAMConfigs.getEnableScheduler() && totalToMigrateBeginning >= NAMConfigs.getSchedulerSize() && NAMConfigs.getSchedulerSize() > 0){
                        notesToMigrate = NAMUtils.filterNotesToMigrate(notes, NAMConfigs.getSchedulerSize());
                        system.debug('getEnableScheduler');
                        NMTNoteConversionStatus.changeStatus('Progress', BC.getJobId(),'Convertion');
                    } else {
                        notesToMigrate = NAMUtils.filterNotesToMigrate(notes, totalToMigrateBatch);
                    }
                    system.debug('notesToMigrate: ' + notesToMigrate.size());
                    recordsBatch = notesToMigrate.size();
                    if(recordsBatch > 0){
                        notesAreCero = false;
                    } else{
                        notesAreCero = true;
                    }
                    notesToBeMigrated += notesToMigrate.size();
                    
                    List<NAMMigrationResults> migrationresultsConversion = NMTMigratorBatchHelper.migrateToContentNoteUsingContentVersion(notesToMigrate, objectName);
                    System.debug(migrationresultsConversion);
                    Integer countSuccess = 0;
                    Integer countErrors = 0;
                    for(NAMMigrationResults migrationresult: migrationresultsConversion)
                    {
                        if(migrationresult.Status!=null && migrationresult.Status.equals(NAMMigrationResults.StatusEnum.SUCCESS)){
                            countSuccess++;
                        }if(migrationresult.Status!=null && migrationresult.Status.equals(NAMMigrationResults.StatusEnum.ERROR)){
                            countErrors++;
                            if(migrationresult.ErrorMessage.containsIgnoreCase(NAMUtils.CHARACTER_ERROR)){
                                invalidChar = true;
                            }
                        }
                    }
                    migrationResultsGlobal.addAll(migrationresultsConversion);
                    totalFiles += countSuccess;
                    totalFilesFailed += countErrors;
                    if(totalToMigrate != null){
                        totalToMigrate = totalToMigrate - countSuccess;
                    }
                    
                } 
                /*
* Since we cannot catch LimitException we did this workaround
* When an error related to org limits ocurrs this line is not executed
* after all jobs are completed the finish() method is executed and we can
* warn the user through this flag.
*/
                this.limitError = false;
            }catch(NAMStorageException ex){
                this.limitError = false;
                if(ex.migrationResultsException!=null){
                    migrationResultsGlobal.addAll(ex.migrationResultsException);
                }
                mycustomfinish(true,bc);
                System.abortJob(bc.getJobId());
            } catch(Exception ex){
                System.debug('NMTMigratorBatch - Error: ' + ex.getMessage());
                List<NAMMigrationResults> errorObject = new List<NAMMigrationResults>();
                errorObject.add(new NAMMigrationResults(null,null,null,NAMMigrationResults.StatusEnum.ERROR, 'NMTMigratorBatch - Error: ' + ex.getMessage()));
                migrationResultsGlobal.addAll(errorObject);
                
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
        mycustomfinish(false, bc);
    }
    
    /**
* @description finish method is not executed if we abort the batch. We use this method for both situations: normal and abort finishing
*/
    
    private void mycustomfinish(Boolean storage,Database.BatchableContext bc){
        try{
            String limitMessage = '';
            if(limitError){
                List<AsyncApexJob> jobs = [SELECT ExtendedStatus FROM AsyncApexJob WHERE id = :bc.getJobId()];
                if(jobs!=null&&!jobs.isEmpty()){
                    limitMessage = jobs[0].ExtendedStatus;
                }
            }
            system.debug('totalToMigrateBeginning: ' + totalToMigrateBeginning);
            system.debug('notesToBeMigrated: ' + notesToBeMigrated);
            Integer quantityLeft = 0;
            if(totalToMigrateBeginning == null){
                quantityLeft = 0;
            }else{
                quantityLeft = totalToMigrateBeginning -  notesToBeMigrated;    
            }
            
            system.debug('quantityLeft: ' + quantityLeft);
            if(NAMConfigs.getEnableScheduler() && !notesAreCero && NAMConfigs.getSchedulerSize() > 0 && quantityLeft > 0){
                NMTMigratorBatch batchScheduler = new NMTMigratorBatch(this.objectName, null, this.migrationType,quantityLeft, this.startDate, this.endDate, this.byCreateDate);
                String cronID = System.scheduleBatch(batchScheduler, 'NMTMigratorBatch'+this.objectName+quantityLeft, NAMUtils.SCHEDULER_TIME);
                
            }
            NAMEmailHelper.emailSetupAndSend(false, objectName,migrationResultsGlobal,totalFiles,limitError,storage, invalidChar, notesToBeMigrated,totalFilesFailed,listIds,limitMessage);
        }catch(Exception e){
            String errorMessage = e.getMessage()+' '+e.getCause()+' '+e.getLineNumber()+' '+e.getTypeName()+' '+e.getStackTraceString();
            System.debug('Error sending the email when the migration has finished. '+errorMessage);

        }finally{
            String name = NMTMigratorBatch.class.getName();
            String nameSpace = '';
            List<ApexClass> className = new List<ApexClass>();
            if(name.contains('.')){
                nameSpace = name.substringBefore('.');
                name = name.substringAfter('.');
                className = [SELECT id FROM ApexClass WHERE name = :name AND namespaceprefix=:namespace LIMIT 1];
            }else{
                className = [SELECT id FROM ApexClass WHERE name = :name LIMIT 1];
            }
            //If an error is thrown during change of status, job (AsyncApexJob) status will be 'Completed'
            //In progress label will be hidden anyway
            
            List<AsyncApexJob> jobs = [SELECT Status FROM AsyncApexJob WHERE (Status = 'Processing' 
                                                                              OR Status = 'Holding' 
                                                                              OR Status = 'Queued'
                                                                              OR Status = 'Preparing')
                                       AND ApexClassID  = :className.get(0).Id LIMIT 1];
            
            if(jobs.isEmpty()){
                NMTNoteConversionStatus.changeStatus('Completed', null,'Convertion');
            }
            
        }
    }
}