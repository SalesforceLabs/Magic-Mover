/**
* @description
* @author Jessica Bernal
* @date 2017-11-07
*/
public with sharing class NAMConfigController {
    public List<AsyncApexJob> apexJobs {get; set;}
    public List<ApexTrigger> triggers {get; set;}
    public List<CronTrigger> scheduledJobs {get; set;}
    public Integer ScheduledJobsOffsetSize = 0;
    public Integer ScheduledJobsQueryLimit = NAMUtils.DEFAULT_CONFIG_PAGE_SIZE;
    public Integer TriggersOffsetSize = 0;
    public Integer TriggersQueryLimit = NAMUtils.DEFAULT_CONFIG_PAGE_SIZE;
    public Integer OffsetSize = 0;
    public Integer QueryLimit = NAMUtils.DEFAULT_CONFIG_PAGE_SIZE;
    public Integer attachmentsBatchSize {get; set;}
    public Integer schedulerSize {get; set;}
    public Integer timeoutAttachmentSize {get; set;}
    public Integer timeoutNoteSize {get; set;}
    public Integer notesBatchSize {get; set;}
    public Integer metadataPageSize {get; set;}
    public Integer minBatchSize {get; set;}
    public Integer bodyLength {get; set;}
    public Boolean enableBodyLength {get; set;}
    public String owner {get; set;}
    public Boolean enableOwner {get; set;}
    public String ownerFrom {get; set;}
    public String ownerTo {get; set;}
    public Boolean enableOwnerFromTo {get; set;}
    public String showHide { get; set; }
    public String highMessage { get; set; }
    public String message { get; set; }
    public String messageOwnerFromTo { get; set; }
    public String messageOwner { get; set; }
    public String showHideOwnerFromTo { get; set; }
    public String showHideOwner { get; set; }
    public String showHideError { get; set; }
    public String errorMessage { get; set; }
    public Boolean enableDynamicBatchSize {get; set;}
    public Boolean enableScheduler {get; set;}
    public Boolean enableTimeoutAttachment {get; set;}
    public Boolean enableTimeoutNote {get; set;}
    public String sucessComumunityGroupURL {get; set;}
    public String appExchangeURL {get; set;}
    public String apexjobsURL {get; set;}
    public String triggersURL {get; set;}
    public String scheduledJobsURL {get; set;}
    public String version {get{
        return NAMUtils.PACKAGE_VERSION_NAME;
    } set;}
    
    public NAMConfigController(){
        showHide = 'slds-hide';
        showHideError = 'slds-hide';
        showHideOwner = 'slds-hide';
        showHideOwnerFromTo = 'slds-hide';
        sucessComumunityGroupURL = NAMUtils.SUCCESS_COMMUNITY_GROUP_URL;
        appExchangeURL = NAMUtils.APP_EXCHANGE_URL;
        attachmentsBatchSize = NAMConfigs.getBatchSizeForAttachments();
        notesBatchSize = NAMConfigs.getBatchSizeForNotes();
        enableDynamicBatchSize = NAMConfigs.getEnableDynamicBatchSize();
        minBatchSize = NamConfigs.getMinBatchSize();
        metadataPageSize = NAMConfigs.getMetadataPageSize();
        schedulerSize = NAMConfigs.getSchedulerSize();
        enableScheduler = NAMConfigs.getEnableScheduler();
        timeoutAttachmentSize = NAMConfigs.getTimeoutAttachmentSize();
        enableTimeoutAttachment = NAMConfigs.getEnableTimeoutAttachment();
        timeoutNoteSize = NAMConfigs.getTimeoutNoteSize();
        enableTimeoutNote = NAMConfigs.getEnableTimeoutNote();
        enableBodyLength = NAMConfigs.getEnableBodyLength();
        bodyLength = NAMConfigs.getBodyLength();
        enableOwner = NAMConfigs.getEnableOwner();
        owner = NAMConfigs.getOwner();
        enableOwnerFromTo = NAMConfigs.getEnableOwnerFromTo();
        ownerFrom = NAMConfigs.getOwnerFrom();
        ownerTo = NAMConfigs.getOwnerTo();
        apexjobsURL = URL.getSalesforceBaseUrl().toExternalForm() + '/apexpages/setup/listAsyncApexJobs.apexp'; 
        triggersURL = URL.getSalesforceBaseUrl().toExternalForm() + '/setup/build/allTriggers.apexp';
        scheduledJobsURL = URL.getSalesforceBaseUrl().toExternalForm() + '/08e?retURL=/ui/setup/Setup?setupid=Jobs&setupid=ScheduledJobs';
        loadApexJobs();
        loadTriggers();
        loadScheduledJobs();
    }
    
    public void changeConfigs(){
        errorMessage = '';
        highMessage = 'height: 4rem;';
        showHide = 'slds-hide';
        showHideError = 'slds-hide';
        showHideOwner = 'slds-hide';
        showHideOwnerFromTo = 'slds-hide';
        Boolean save = true;
        List<User> user = new List<User>();
        List<User> userFromTo = new List<User>();
        
        if(enableOwner){
            user = NAMUtils.checkUserId(owner);
            if(user.size() > 0){
                NAMConfigs.setOwner(user.get(0).Id);
            } else {
                save = false;
                errorMessage += 'User Id: ' + owner + ' is Invalid, please try enter Id again. ';
                showHideError = '';
            } 
        }
        
        if(enableOwnerFromTo){
            userFromTo = NAMUtils.checkUserId(ownerTo);
            if(userFromTo.size() > 0){
                NAMConfigs.setOwnerTo(userFromTo.get(0).Id);
            } else {
                save = false;
                errorMessage += 'User Id to set: ' + ownerTo + ' is Invalid, please try enter Id again.';
                showHideError = '';
            } 
        }
        
        if(save){
            NAMConfigs.setBatchSizeForAttachments(attachmentsBatchSize);
            NAMConfigs.setBatchSizeForNotes(notesBatchSize);
            NAMConfigs.setEnableDynamicBatchSize(enableDynamicBatchSize);
            NAMConfigs.setMetadataPageSize(metadataPageSize);
            NAMConfigs.setMinBatchSize(minBatchSize);
            NAMConfigs.setEnableBodyLength(enableBodyLength);
            NAMConfigs.setBodyLength(bodyLength);
            NAMConfigs.setEnableOwner(enableOwner);
            NAMConfigs.setEnableOwnerFromTo(enableOwnerFromTo);
            if(enableScheduler){
                NAMConfigs.setSchedulerSize(schedulerSize);
            }
            if(enableTimeoutAttachment){
                NAMConfigs.setTimeoutAttachmentSize(timeoutAttachmentSize);
            }
            if(enableTimeoutNote){
                NAMConfigs.setTimeoutNoteSize(timeoutNoteSize);
            }
            if(enableOwnerFromTo){
                NAMConfigs.setOwnerFrom(ownerFrom);
            }
            NAMConfigs.setEnableScheduler(enableScheduler); 
            NAMConfigs.setEnableTimeoutAttachment(enableTimeoutAttachment); 
            NAMConfigs.setEnableTimeoutNote(enableTimeoutNote); 
            showHideError = 'slds-hide';
            message = 'Configs saved.';
            if(enableOwner && user.size() > 0 && !user.get(0).IsActive){
                messageOwner = 'Keep in mind that User ' + user.get(0).Id;
                if(user.get(0).FirstName != null){
                    messageOwner += ' - ' + user.get(0).FirstName;
                } else {
                    messageOwner += ' - ' + user.get(0).LastName;
                }
                messageOwner += ' is Inactive';
                highMessage = 'height: 7rem;';
                showHideOwner = '';
            } 
            if(enableOwnerFromTo && userFromTo.size() > 0 && !userFromTo.get(0).IsActive){
                messageOwnerFromTo = 'Keep in mind that User ' + userFromTo.get(0).Id;
                if(userFromTo.get(0).FirstName != null){
                    messageOwnerFromTo += ' - ' + userFromTo.get(0).FirstName;
                } else {
                    messageOwnerFromTo += ' - ' + userFromTo.get(0).LastName;
                }
                messageOwnerFromTo += ' is Inactive';
                highMessage = 'height: 7rem;';
                showHideOwnerFromTo = ''; 
            }
            showHide = ''; 
            
        }
        
    }
    
    public void resetAttachmentsConversion(){
        highMessage = 'height: 4rem;';
        showHide = 'slds-hide';
        showHideError = 'slds-hide';
        showHideOwner = 'slds-hide';
        showHideOwnerFromTo = 'slds-hide';
        String className = ATFMigratorBatch.class.getName();
        String nameSpace = '';
        if(className.contains('.')){
            nameSpace = className.substringBefore('.');
            className = className.substringAfter('.');
            
            System.debug('className '+className);
            System.debug('nameSpace '+nameSpace);
        }
        NAMUtils.abortOperation(className, nameSpace, true, true);
        message = 'Attachments reset done. ';
        showHide = '';
    }
    
    public void resetNotesConversion(){
        highMessage = 'height: 4rem;';
        showHide = 'slds-hide';
        showHideError = 'slds-hide';
        showHideOwner = 'slds-hide';
        showHideOwnerFromTo = 'slds-hide';
        String className = NMTMigratorBatch.class.getName();
        String nameSpace = '';
        if(className.contains('.')){
            nameSpace = className.substringBefore('.');
            className = className.substringAfter('.');
            
            System.debug('className '+className);
            System.debug('nameSpace '+nameSpace);
        }
        NAMUtils.abortOperation(className, nameSpace, true, false);
        message = 'Notes reset done. ';
        showHide = '';
    }
    
    public Boolean getDisablePrevious(){
        if(OffsetSize > 0){
            return false;
        }
        else return true;
    }
    
    public Boolean getDisableNext() {
        if(NAMUtils.loadApexJobs(QueryLimit,NAMUtils.DEFAULT_CONFIG_PAGE_SIZE + OffsetSize).size() > 0){
            return false;
            
        } else{
            return true;
            
        }
    }
    
    public PageReference Next() {
        OffsetSize += NAMUtils.DEFAULT_CONFIG_PAGE_SIZE;
        apexJobs = NAMUtils.loadApexJobs(QueryLimit, OffsetSize);
        system.debug('OffsetSize: ' + OffsetSize);
        return null;
    }
    
    public PageReference Previous() {
        OffsetSize -= NAMUtils.DEFAULT_CONFIG_PAGE_SIZE;
        apexJobs = NAMUtils.loadApexJobs(QueryLimit, OffsetSize);
        system.debug('OffsetSize: ' + OffsetSize);
        return null;
    }
    
    public Boolean getTriggersDisablePrevious(){
        if(TriggersOffsetSize > 0){
            return false;
        }
        else return true;
    }
    
    public Boolean getTriggersDisableNext() {
        if(NAMUtils.loadTriggers(TriggersQueryLimit,NAMUtils.DEFAULT_CONFIG_PAGE_SIZE + TriggersOffsetSize).size() > 0){
            return false;
            
        } else{
            return true;
            
        }
    }
    
    public Boolean getScheduledJobsDisablePrevious(){
        if(ScheduledJobsOffsetSize > 0){
            return false;
        }
        else return true;
    }
    
    public Boolean getScheduledJobsDisableNext() {
        if(NAMUtils.loadScheduledJobs(ScheduledJobsQueryLimit,NAMUtils.DEFAULT_CONFIG_PAGE_SIZE + ScheduledJobsOffsetSize).size() > 0){
            return false;
            
        } else{
            return true;
            
        }
    }
    
    public PageReference TriggersNext() {
        TriggersOffsetSize += NAMUtils.DEFAULT_CONFIG_PAGE_SIZE;
        triggers = NAMUtils.loadTriggers(TriggersQueryLimit, TriggersOffsetSize);
        return null;
    }
    
    public PageReference TriggersPrevious() {
        TriggersOffsetSize -= NAMUtils.DEFAULT_CONFIG_PAGE_SIZE;
        triggers = NAMUtils.loadTriggers(TriggersQueryLimit, TriggersOffsetSize);
        return null;
    }
    
    public PageReference ScheduledJobsNext() {
        ScheduledJobsOffsetSize += NAMUtils.DEFAULT_CONFIG_PAGE_SIZE;
        scheduledJobs = NAMUtils.loadScheduledJobs(ScheduledJobsQueryLimit, ScheduledJobsOffsetSize);
        return null;
    }
    
    public PageReference ScheduledJobsPrevious() {
        ScheduledJobsOffsetSize -= NAMUtils.DEFAULT_CONFIG_PAGE_SIZE;
        scheduledJobs = NAMUtils.loadScheduledJobs(ScheduledJobsQueryLimit, ScheduledJobsOffsetSize);
        return null;
    }
    
    public PageReference loadApexJobs(){
        apexJobs = NAMUtils.loadApexJobs(QueryLimit, OffsetSize);
        return null;
    }
    
    public PageReference loadTriggers(){
        triggers = NAMUtils.loadTriggers(TriggersQueryLimit, TriggersOffsetSize);
        return null;
    }
    
    public PageReference loadScheduledJobs(){
        scheduledJobs = NAMUtils.loadScheduledJobs(ScheduledJobsQueryLimit, ScheduledJobsOffsetSize);
        return null;
    }
    
    public Boolean getEmptyScheduledJobs() { 
        return scheduledJobs.size() == 0;
    } 
    
    public Boolean getEmptyTriggers() { 
        return triggers.size() == 0;
    } 
    
    public Boolean getEmptyApexJobs() { 
        return apexJobs.size() == 0;
    } 
    
}