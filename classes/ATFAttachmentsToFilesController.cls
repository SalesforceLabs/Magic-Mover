/**
* @author Jessica Bernal, Andres Canavesi
* @date 2016-12
* @description controller for the page that migrates PUBLIC attachments in bulk.
* edited ateppo 4/15/2020
*/
global with sharing class ATFAttachmentsToFilesController {
    
    public List<NAMObjectCount> migratedAttachmentsPerObject {get; set;}
    public String version {get{return NAMUtils.PACKAGE_VERSION_NAME;} set;}
    public String objectName {get; set;}
    public String storageURL {get; set;}
    public String apexjobsURL {get; set;}
    public String sucessComumunityGroupURL {get; set;}
    public String appExchangeURL {get; set;}
    public Integer OffsetSizeUnmigratedObjects = 0;
    public Integer OffsetSizeMigratedObjects = 0;
    public Boolean allUnmigratedObjectsChecked { get; set; }
    public Boolean deleteAfterMigration { get; set; }
    public List<NMTSObjectWrapper> unmigratedAttachmentsPerObject {get; set;}
    public Integer TotalToMigrate { get; set; }
    public Organization org { get; set; }
    public Integer countMigratedAttachmentsPerObject = 0;
    public Integer countUnmigratedAttachmentsPerObject = 0;
    public Integer timeout {get{return NAMUtils.LIMIT_TIME_OUT;} set;}
    public Boolean noRecords {get; set;}
    public String otherToolInProgress {get; set;}
    public Date auxStartDate;
    public Date auxEndDate;
    public Boolean byCreateDate = true;
    public String byCreateDateString {get; set;}
    
    public Boolean schedulerIsActive {get; set;}
    public Integer schedulerSize {get; set;}
    
    public String objectSelected {get;set;}
    /**
* @description by default we display a date range of one month
*/
    public Date startDate{ get{
        if(startDate==null){
            startDate = Date.today();
            //startDate = startDate.addDays(-30);
            //We changed to avoid the error when the are too many records
            startDate = startDate.addDays(-1);
        }
        return startDate;
    } set;}
    
    public Date endDate{ get{
        if(endDate==null){
            endDate = System.today();
        }
        return endDate;
    } set;}
    
    public Date startDateFilter{ get{
        if(startDateFilter==null){
            startDateFilter = Date.today();
            //startDateFilter = startDateFilter.addDays(-30);
            //We changed to avoid the error when the are too many records
            startDateFilter = startDateFilter.addDays(-1);
        }
        return startDateFilter;
    } set;}
    
    public Date endDateFilter{ get{
        if(endDateFilter==null){
            endDateFilter = System.today();
        }
        return endDateFilter;
    } set;}
    
    public String finishCount {get{
        if(finishCount !=null && finishCount.equals('true')){
            finishCount = 'false';
            return 'true';
        }
        return finishCount;
    } set;}
    public boolean disabledCount {get; set;}
    
    public Boolean inProgress {get{
        List<NAMAttachmentConversionStatus__c> attachmentStatus = ATFAttachmentConversionStatus.findInProgressObjects();
        return attachmentStatus.size() > 0;
    }
                               
                               set;}
    public Boolean inProgressId {get{
        List<NAMAttachmentConversionStatus__c> attachmentByIdStatus = ATFAttachmentConversionStatus.findInProgressId();
        system.debug('attachmentByIdStatus.size() > 0: ' + attachmentByIdStatus.size());
        return attachmentByIdStatus.size() > 0;
    }
                                 
                                 set;}
    
    //only to use the Date in the VF Page
    public NAMNoteConverted__c startDateCV {get;set;}
    public NAMNoteConverted__c endDateCV {get;set;}
    public String validationDateMessage{get;set;}
    
    //totals table
    public String totalAttachments {get;set;}
    public String totalConvertedAttachments {get;set;}
    public String totalUnconvertedAttachments {get;set;}
    
    //To catch permission issue
    public String permissionIssue{get; set;}
    public String notPermissionIssue{get; set;}
    
    public ATFAttachmentsToFilesController(){
        objectSelected = 'All';
        byCreateDateString = 'true';
        permissionIssue = 'slds-hide';
        notPermissionIssue = '';
        schedulerIsActive = NAMConfigs.getEnableScheduler();
        schedulerSize = NAMConfigs.getSchedulerSize();
        startDateCV = new NAMNoteConverted__c();
        startDateCV.LegacyNoteConvertedDate__c = StartDateFilter;
        endDateCV = new NAMNoteConverted__c();
        endDateCV.LegacyNoteConvertedDate__c = EndDateFilter;
        validationDateMessage = '';
        finishCount = 'false';
        try{
            NAMUtils.validatePermissions();
        }catch(Exception ex){
            permissionIssue = '';
            notPermissionIssue = 'slds-hide';
        }
        noRecords = true;
        countMigratedAttachmentsPerObject = 0;
        countUnmigratedAttachmentsPerObject = 0;        
        TotalToMigrate = 0; 
        
        sucessComumunityGroupURL = NAMUtils.SUCCESS_COMMUNITY_GROUP_URL;
        appExchangeURL = NAMUtils.APP_EXCHANGE_URL;
        storageURL = URL.getSalesforceBaseUrl().toExternalForm() + '/setup/org/orgstorageusage.jsp?id=' + UserInfo.getOrganizationId();
        apexjobsURL = URL.getSalesforceBaseUrl().toExternalForm() + '/apexpages/setup/listAsyncApexJobs.apexp';           
        //loadInfo();
        checkOtherTool();
        if (Schema.sObjectType.Organization.fields.OrganizationType.isAccessible()) {
            org = [SELECT OrganizationType FROM Organization LIMIT 1];
        }
        totalAttachments = '0';
        totalConvertedAttachments ='0';
        totalUnconvertedAttachments = '0';
    }
    
    
    
    /**
* @description
*/
    public void checkOtherTool(){
        if(NMTNoteConversionStatus.isInProgress()){
            otherToolInProgress = 'display:inline';
            disabledCount = true;
        } else {
            otherToolInProgress = 'display:none';
            disabledCount = false;
        }
    }
    
    public List<SelectOption> getorderByOptions (){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('true', 'by Created Date'));
        options.add(new SelectOption('false', 'by Last Modified Date'));
        return options;
    }
    
    public void orderBy(){
        if(byCreateDateString == 'true'){
            byCreateDate = true;            
        } else {
            byCreateDate = false;  
        }
    }
    
    /**
* @description
* @return null
*/
    public PageReference loadInfo(){
        if(startDateCV.LegacyNoteConvertedDate__c>System.today()||endDateCV.LegacyNoteConvertedDate__c>System.today()){
            validationDateMessage = 'Invalid date range. Please choose dates that include today or earlier.';
            finishCount = 'true';
        }else if(startDateCV.LegacyNoteConvertedDate__c>endDateCV.LegacyNoteConvertedDate__c){
            validationDateMessage = 'Invalid date range. Please choose an end date that\'s on or after the start date.';
            finishCount = 'true';
        }
        else{
            validationDateMessage = '';
            finishCount = 'false';
            auxStartDate = startDateCV.LegacyNoteConvertedDate__c;
            auxEndDate = endDateCV.LegacyNoteConvertedDate__c;
            loadSObjects();
            loadSObjectsDelete();
            countUnmigratedAttachmentsPerObject = NAMUtils.countTotalPublicUnmigratedAttachmentsPerObject(auxStartDate, auxEndDate, byCreateDate, objectSelected);
            countMigratedAttachmentsPerObject = NAMUtils.countTotalMigratedAttachmentsPerObject(auxStartDate, auxEndDate, byCreateDate, objectSelected);
            doCounts();
            startDate = auxStartDate;
            endDate = auxEndDate;
            finishCount = 'true';
        }
        return null;
    }
    
    /**
* @description loads objects that have at least one attachment to be converted
* @return null
*/
    public PageReference loadSObjects(){
        List<NAMAttachmentConversionStatus__c> attachmentStatus = ATFAttachmentConversionStatus.findInProgressObjects();
        unmigratedAttachmentsPerObject = NAMUtils.countPublicUnmigratedAttachmentsPerObject(NAMUtils.DEFAULT_PAGE_SIZE, OffsetSizeUnmigratedObjects, auxStartDate, auxEndDate, byCreateDate, objectSelected);
        if(unmigratedAttachmentsPerObject.size() > 0){
            noRecords = false;
        }
        for(NMTSObjectWrapper theObject : unmigratedAttachmentsPerObject) {  
            theObject.selected = false;
            theObject.migrationInProgress = ATFAttachmentConversionStatus.containsObjectByName(attachmentStatus, theObject.objectName);
            theObject.inputToMigrate = ATFAttachmentConversionStatus.containsObjectByNameGetQuantity(attachmentStatus, theObject.objectName);
        }
        
        checkOtherTool();
        if(attachmentStatus.size() > 0){
            disabledCount = true;
        } else{
            system.debug('disabledCount');
            disabledCount = false; 
        }
        return null;
    }
    
    /**
* @description loads objects that have at least one migrated attachment
* @return null
*/
    public PageReference loadSObjectsDelete(){
        List<NAMAttachmentConversionStatus__c> attachmentStatus = ATFAttachmentConversionStatus.findInProgressObjectsDeletion();
        migratedAttachmentsPerObject = NAMUtils.countMigratedAttachmentsPerObject(NAMUtils.DEFAULT_PAGE_SIZE, OffsetSizeMigratedObjects, auxStartDate, auxEndDate, byCreateDate, objectSelected);
        system.debug('migratedAttachmentsPerObject');
        system.debug(migratedAttachmentsPerObject);
        for(NAMObjectCount theObject : migratedAttachmentsPerObject) {
            theObject.migrationInProgress = ATFAttachmentConversionStatus.containsObjectByName(attachmentStatus, theObject.objectName);
        } 
        checkOtherTool();
        if(attachmentStatus.size() > 0){
            disabledCount = true;
        } else{
            disabledCount = false; 
        }
        return null;
    }
    
    /**
* @description
*/
    private void doCounts(){
        Integer totalUnmigratedObjects = 0;
        Integer totalMigratedObjects = 0;
        List<NMTSObjectWrapper> unmigratedObjects = NAMUtils.countTotalUnmigratedAttachments(auxStartDate, auxEndDate, byCreateDate, objectSelected);
        
        for(NMTSObjectWrapper theObject : unmigratedObjects) {  
            totalUnmigratedObjects += theObject.quantityAttachments;
        }
        List<NAMObjectCount> migratedObjects = NAMUtils.countTotalMigratedAttachments(auxStartDate, auxEndDate, byCreateDate, objectSelected);
        
        for(NAMObjectCount theObject : migratedObjects) {  
            totalMigratedObjects += theObject.quantity;
        }
        
        system.debug('totalAttachments: ' +totalUnmigratedObjects + ' ' + totalMigratedObjects );
        
        totalAttachments = totalUnmigratedObjects + totalMigratedObjects + '';
        totalConvertedAttachments = totalMigratedObjects + '';
        totalUnconvertedAttachments = totalUnmigratedObjects + '';
        
    }
    
    public PageReference refresh(){
        refreshMigrated();
        refreshUnmigrated();
        getobjectsItems();
        schedulerIsActive = NAMConfigs.getEnableScheduler();
        schedulerSize = NAMConfigs.getSchedulerSize();
        return null;
    }
    
    
    /**
* @description
* @return null
*/
    public void refreshMigrated(){
        finishCount = 'false';
        auxStartDate = startDate;
        auxEndDate = endDate;
        loadSObjectsDelete();
        countMigratedAttachmentsPerObject = NAMUtils.countTotalMigratedAttachmentsPerObject(auxStartDate, auxEndDate, byCreateDate, objectSelected);
        if(migratedAttachmentsPerObject.size() == 0 && countMigratedAttachmentsPerObject >= NAMUtils.DEFAULT_PAGE_SIZE){            
            PreviousMigratedObjects();
        }
        getDisableNextMigratedObjects();
        doCounts();
        finishCount = 'true';
    }
    
    /**
* @description
* @return null
*/
    public void refreshUnmigrated(){
        finishCount = 'false';
        auxStartDate = startDate;
        auxEndDate = endDate;
        loadSObjects();
        countUnmigratedAttachmentsPerObject = NAMUtils.countTotalPublicUnmigratedAttachmentsPerObject(auxStartDate, auxEndDate, byCreateDate, objectSelected);
        if(unmigratedAttachmentsPerObject.size() == 0 && countUnmigratedAttachmentsPerObject >= NAMUtils.DEFAULT_PAGE_SIZE){            
            PreviousUnmigratedObjects();
        }
        getDisableNextUnmigratedObjects();
        List<NAMAttachmentConversionStatus__c> attachmentStatus = ATFAttachmentConversionStatus.findInProgressObjects();
        if(attachmentStatus.size() > 0){
            inProgress = true;
        } else {
            inProgress = false;
        }
        List<NAMAttachmentConversionStatus__c> attachmentByIdStatus = ATFAttachmentConversionStatus.findInProgressId();
        if(attachmentByIdStatus.size() > 0){
            inProgressId = true;
        } else {
            inProgressId = false;
        }
        doCounts();
        finishCount = 'true';
    }
    
    /**
* @description
*/
    @RemoteAction
    global static void deleteMigratedByObjectNameRemote(String objectNameDelete, String startDateDelete, String endDateDelete, Boolean byCreateDate) {
        
        NAMUtils.validatePermissions();
        
        Date sdate = Date.valueOf(startDateDelete);
        Date edate = Date.valueOf(endDateDelete);
        edate = edate.addDays(1);
        DateTime startDateTime = DateTime.newInstance(sdate.year(), sdate.month(), sdate.day(), 00, 00, 00);
        DateTime endDateTime = DateTime.newInstance(edate.year(), edate.month(), edate.day(), 00, 00, 00);
        String sstart = startDateTime.format(NAMUtils.DATE_TIME_FORMAT);
        String send = endDateTime.format(NAMUtils.DATE_TIME_FORMAT);
        
        if(NMTNoteConversionStatus.isInProgress()){
            throw new NAMOtherToolInProgressException('You\'re currently already converting Notes. When that process completes, you can convert notes.');
        }
        
        if( !ATFAttachmentConversionStatus.isInProgressByObjectNameDeletion(objectNameDelete)){
            String parentType = '';
            parentType = 'Parent.Type=\''+String.escapeSingleQuotes(objectNameDelete)+'\'';
            
            String query = 'SELECT Id, IsPrivate, Name FROM Attachment WHERE Name LIKE \''+NAMUtils.MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN+'\' AND '+parentType+' ';
            if(byCreateDate){
                query += ' AND createdDate >= ' + sstart + ' AND createdDate <= ' + send;
            } else {
                query += ' AND lastModifiedDate >= ' + sstart + ' AND lastModifiedDate <= ' + send; 
            }
            if(NAMConfigs.getEnableBodyLength()){
                Integer bodyLengthValue = NAMConfigs.getBodyLength() * 1024 * 1024; 
                query += ' AND bodyLength <=' + bodyLengthValue;
            }
            
            ATFDeleteBatch batch = new ATFDeleteBatch(query, objectNameDelete);
            Id batchId = Database.executeBatch(batch, NAMConfigs.getBatchSizeForAttachments());
            ATFAttachmentConversionStatus.changeToInProgressByObjectNameDeletion(objectNameDelete, batchId);
        }
    }
    
    /**
* @description migrates attachments created att berween startDate and endDate
* @param sObjectsWrapperAsJson
* @param migrationType
* @param startDate does reference to attachment's created date. With the format yyyy-MM-dd
* @param endDate does reference to attachment's created date. With the format yyyy-MM-dd
*/
    @RemoteAction
    global static void runMigrationRemote(String sObjectsWrapperAsJson, String migrationType, String startDate, String endDate, Boolean byCreateDate) {  
        
        NAMUtils.validatePermissions();
        
        Date sdate = Date.valueOf(startDate);
        Date edate = Date.valueOf(endDate);
        String objectsProcessAlreadyStarted = '';
        Boolean processAlreadyStarted = false;
        if(NMTNoteConversionStatus.isInProgress()){
            throw new NAMOtherToolInProgressException('You\'re currently already converting Notes. When that process completes, you can convert notes.');
        }
        
        if(!NMTNoteConversionStatus.isInProgress() && sObjectsWrapperAsJson != ''){  
            sObjectsWrapperAsJson = sObjectsWrapperAsJson.removeEnd('|');
            if(migrationType.equals('byObject')){ 
                String[] objectsArray = sObjectsWrapperAsJson.split('\\|');
                //bulk migration does not delete attachment after the migration
                Boolean deleteAfterMigration = false;
                for(Integer i=0; i<objectsArray.size(); i++){
                    String[] row = objectsArray[i].split(',');
                    String objectName = row[0];
                    Integer quantity = Integer.valueOf(row[1]);
                    if(quantity > 0 &&!ATFAttachmentConversionStatus.isInProgressByObjectName(objectName)){
                        ATFMigratorBatch batch = new ATFMigratorBatch(objectName, null, migrationType, quantity, sDate, eDate, byCreateDate);
                        Id batchId = Database.executeBatch(batch, NAMConfigs.getBatchSizeForAttachments());   
                        ATFAttachmentConversionStatus.changeToInProgressByObjectName(objectName, quantity, batchId); 
                    } else {
                        if(quantity > 0){
                            objectsProcessAlreadyStarted += objectName + ' ';
                            processAlreadyStarted = true;
                        }
                    }                          
                }
                if(processAlreadyStarted){
                    objectsProcessAlreadyStarted = objectsProcessAlreadyStarted.removeEnd(' ');
                    String message = 'We are busy converting ' + objectsProcessAlreadyStarted + '. When we\'re done, start another conversion.';
                    throw new NAMForbiddenException(message);
                }
                
            } else {
                List<NAMAttachmentConversionStatus__c> attachmentStatus = ATFAttachmentConversionStatus.findInProgress();
                if(attachmentStatus != null && attachmentStatus.size() == 0){
                    List<String> objectsArrayTemp = sObjectsWrapperAsJson.split('\n');
                    List<String> objectsArray = new List<String>();
                    for(String objectArray : objectsArrayTemp){
                        objectsArray.addAll(objectArray.split(','));
                    }
                    Set<String> listAux = new Set<String>();
                    List<String> resultAux = new List<String>();
                    listAux.addAll(objectsArray);
                    resultAux.addAll(listAux);
                    Map<String,String> mapAux = new Map<String,String>();
                    Map<String,String> mapAuxToCheckRecords = new Map<String,String>();
                    for(String idAttachment : resultAux){
                        mapAux.put(idAttachment, idAttachment);
                    }
                    List<Id> validIds = new List<Id>();
                    Boolean invalidIds = false;
                    String invalidsIds = '';
                    for(String validId : resultAux){
                        try{
                            Id checkValidId = validId;
                            validIds.add(checkValidId);
                        } catch(Exception e){
                            invalidIds = true;
                            invalidsIds += validId + ' - ';
                        }
                    }
                    if(invalidIds){
                        invalidsIds = invalidsIds.removeEnd(' - ');
                        throw new NAMForbiddenException('We don\'t recognize the ID ' + invalidsIds + '. Reenter the ID and try again.');
                    } else{
                        if(migrationType.equals('byId')){
                            mapAux = NAMUtils.validateEnteredIDs(validIds, mapAux, true);
                        } else {
                            mapAuxToCheckRecords.putAll(mapAux);
                            mapAux = NAMUtils.validateEnteredObjectIDs(validIds, mapAux);
                        }
                        if(!mapAux.isEmpty()){
                            invalidsIds = '';
                            for(String invalidsId : mapAux.values()){
                                invalidsIds += invalidsId + ' - ';
                            }
                            invalidsIds = invalidsIds.removeEnd(' - ');
                            throw new NAMForbiddenException('We can\'t get data for the ID ' + invalidsIds + '. The ID doesn\'t exist or has been deleted, or you don\'t have access to that record.');
                        } else {
                            if(migrationType.equals('byObjectId')){
                                mapAux = NAMUtils.validateNoRecordsObjectIDs(validIds, mapAuxToCheckRecords, true);
                            } 
                            if(migrationType.equals('byObjectId') && !mapAux.isEmpty()){
                                invalidsIds = '';
                                for(String invalidsId : mapAux.values()){
                                    invalidsIds += invalidsId + ' - ';
                                }
                                invalidsIds = invalidsIds.removeEnd(' - ');
                                if(invalidsIds.contains(' - ')){
                                    throw new NAMForbiddenException('No attachments are associated with these IDs ' + invalidsIds + '.');
                                } else {
                                    throw new NAMForbiddenException('No attachments are associated with the ID ' + invalidsIds + '.');
                                }
                            } else {
                                ATFMigratorBatch batch = new ATFMigratorBatch(null, validIds, migrationType, validIds.size(), sDate, eDate, byCreateDate);
                                Id batchId = Database.executeBatch(batch, NAMConfigs.getBatchSizeForAttachments());   
                                ATFAttachmentConversionStatus.changeToInProgressByObjectName(migrationType, validIds.size(), batchId); 
                            }
                        }
                    }
                    
                } else {
                    objectsProcessAlreadyStarted = objectsProcessAlreadyStarted.removeEnd(' ');
                    String message = 'We are busy converting ' + objectsProcessAlreadyStarted + '. When we\'re done, start another conversion.';
                    throw new NAMForbiddenException(message);
                }
                
            }
        }     
    }
    
    /**
* @description
* @return
*/
    public Boolean getEmptyMigratedObjects() {    
        return countMigratedAttachmentsPerObject == 0;
    }
    
    /**
* @description
* @return
*/
    public Boolean getEmptyUnmigratedObjects() { 
        return countUnmigratedAttachmentsPerObject == 0;
    } 
    
    /**
* @description
* @return
*/
    public Boolean getDisablePreviousMigratedObjects(){
        if(OffsetSizeMigratedObjects>0){
            return false;
        }
        else return true;
    }
    
    /**
* @description
* @return
*/
    public Boolean getDisablePreviousUnmigratedObjects(){
        if(OffsetSizeUnmigratedObjects>0){
            return false;
        }
        else return true;
    }
    
    /**
* @description
* @return
*/
    public Boolean getDisableNextMigratedObjects() {
        if(countMigratedAttachmentsPerObject > NAMUtils.DEFAULT_PAGE_SIZE){            
            if(countMigratedAttachmentsPerObject > NAMUtils.DEFAULT_PAGE_SIZE + OffsetSizeMigratedObjects){
                return false;
            }else{
                return true;
            }
        }else{            
            return true;
        } 
    }
    
    /**
* @description
* @return
*/
    public Boolean getDisableNextUnmigratedObjects() {        
        if(countUnmigratedAttachmentsPerObject > NAMUtils.DEFAULT_PAGE_SIZE){            
            if(countUnmigratedAttachmentsPerObject > NAMUtils.DEFAULT_PAGE_SIZE + OffsetSizeUnmigratedObjects){
                return false;
            }else{
                return true;
            }
        }else{            
            return true;
        }   
    }
    
    /**
* @description
* @return
*/
    public PageReference NextMigratedObjects() {
        OffsetSizeMigratedObjects += NAMUtils.DEFAULT_PAGE_SIZE;
        loadSObjectsDelete();
        TotalToMigrate = 0;
        return null;
    }
    
    /**
* @description
* @return
*/
    public PageReference NextUnmigratedObjects() {
        OffsetSizeUnmigratedObjects += NAMUtils.DEFAULT_PAGE_SIZE;
        loadSObjects();
        TotalToMigrate = 0;
        allUnmigratedObjectsChecked = false;
        return null;
    }
    
    /**
* @description
* @return
*/
    public PageReference PreviousMigratedObjects() {
        OffsetSizeMigratedObjects -= NAMUtils.DEFAULT_PAGE_SIZE;
        loadSObjectsDelete();
        TotalToMigrate = 0;
        return null;
    }
    
    /**
* @description
* @return
*/
    public PageReference PreviousUnmigratedObjects() {
        OffsetSizeUnmigratedObjects -= NAMUtils.DEFAULT_PAGE_SIZE;
        loadSObjects();
        TotalToMigrate = 0;
        allUnmigratedObjectsChecked = false;
        return null;
    }
    
    /**
* @description
*/
    public void ResetFinishCount() {
        finishCount = 'false';
    }
    
    public List<SelectOption> getobjectsItems() {
        List<SelectOption> options = new List<SelectOption>();
        List<SelectOption> greens = new List<SelectOption>();
        Boolean addAll = true;
        options.add(new SelectOption('All', 'All'));
        String[] customobjects = NAMUtils.getCustomObject();
        for(String green : NAMUtils.PARENT_TYPE_GREENS){
            options.add(new SelectOption(green, green));
            greens.add(new SelectOption(green, green));
        }
        
        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){   
            options.add(new SelectOption(differentType, differentType)); 
            greens.add(new SelectOption(differentType, differentType)); 
        }
        for(String customObject : customobjects){
            if(options.size() < 1000){
                options.add(new SelectOption(customObject, customObject));
            } else {
                addAll = false;
                break;
            }
        }
        
        if(addAll){
            return options;
        } else {
            return greens;
        }
    }
}