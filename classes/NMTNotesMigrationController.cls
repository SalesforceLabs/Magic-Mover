/**
* @author Jessica Bernal, Andres Canavesi
* edited ateppo 5/5/2020
*/

public with sharing class NMTNotesMigrationController {
    
    public String objectName {get; set;}
    public String storageURL {get; set;}
    public String apexjobsURL {get; set;}
    public String numberOfConvertedNotes {get; set;}
    public String numberOfUnconvertedNotes {get; set;}
    public String appExchangeURL {get; set;}
    public String sucessComumunityGroupURL {get; set;}
    public String version {get{
        return NAMUtils.PACKAGE_VERSION_NAME;
    } set;}
    /**
* @description total of notes minus total of CV with LegacyNoteConvertedId__c not equals to null
*/
    public String numberOfPendingNotes {get; set;}
    public Integer OffsetSizeUnmigratedObjects = 0;
    public Integer QueryLimitUnmigratedObjects = NAMUtils.DEFAULT_NOTE_PAGE_SIZE;
    public Integer OffsetSizeMigratedObjects = 0;
    public Integer QueryLimitMigratedObjects = NAMUtils.DEFAULT_NOTE_PAGE_SIZE;
    public Boolean allUnmigratedObjectsChecked { get; set; }
    public Boolean allMigratedObjectsChecked { get; set; }
    public List<NMTSObjectWrapperNotes> notesPerObject {get; set;}
    public List<NMTSObjectWrapperNotes> notesMigratedPerObject {get; set;}
    public Boolean EmptyMigratedObjects {get; set;}
    public Organization org { get; set; }
    public String orgEdition { get; set; }
    public Integer countNotesPerObject = 0;
    public Integer countNotesMigratedPerObject = 0;
    public Integer countObjectsWithNotesMigrated = 0;
    public Integer countObjectsWithNotesUnMigrated = 0;
    public Integer timeout {get{
        return NAMUtils.LIMIT_TIME_OUT_NOTE;
    } set;}
    public Boolean noRecords {get; set;}
    public String otherToolInProgress {get; set;}
    public String inProgressValue {get{
        if(inProgressValue==null || inProgressValue.equals(''))
        {
            return 'In Progress';
        }
        return inProgressValue;
    } set;}
    public String inProgressLabel {get; set;}
    public String inProgressLabelTable {get; set;}
    public String inProgressDeleteValue {get{
        if(inProgressDeleteValue==null || inProgressDeleteValue.equals(''))
        {
            return 'In Progress';
        }
        return inProgressDeleteValue;
    } set;}
    public String inProgressDeleteLabel {get; set;}
    public Boolean inProgress {get{
        return NMTNoteConversionStatus.isInProgress();
    }
                               
                               set;}
    //Access control
    public String TotalLegacyNotes {get; set;}
    public Date auxStartDate;
    public Date auxEndDate;
    public Boolean byCreateDate = true;
    public String byCreateDateString {get; set;}
    
    public Boolean schedulerIsActive {get; set;}
    public Integer schedulerSize {get; set;}
    
    public String objectSelected {get;set;}
    
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
            // startDateFilter = startDateFilter.addDays(-30);
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
    
    //only to use the Date in the VF Page
    public NAMNoteConverted__c startDateCV {get;set;}
    public NAMNoteConverted__c endDateCV {get;set;}
    public String validationDateMessage{get;set;}
    
    public String notesNotEnabled{get; set;}
    public String notesEnabled{get; set;}
    
    //To catch permission issue
    public String permissionIssue{get; set;}
    public String notPermissionIssue{get; set;}
    
    /**
* @description the error message we get when we try to do a request to Tooling API
*/
    public String RemoteSettingConnectionWarningMessage {get;set;}
    
    public NMTNotesMigrationController(){
        objectSelected = 'All';
        byCreateDateString = 'true';
        showHideRemote = '';
        showHideRemotePE = '';
        showHideDataSync = '';
        showHide = 'slds-hide';
        schedulerIsActive = NAMConfigs.getEnableScheduler();
        schedulerSize = NAMConfigs.getSchedulerSize();
        /* SR note: user CRUD/FLS checks not appropriate here */
        org = [SELECT OrganizationType FROM Organization LIMIT 1];
        orgEdition = org.OrganizationType+'';
        if(NAMUtils.isEditionSupported(orgEdition)){
            showHideRemotePE = 'slds-hide';
            checkRemoteSetting();
            if(!RemoteSettingConnectionWarning){
                showHideRemote = 'slds-hide';
                showHide = '';
            }
            
        } else {
            showHideRemote = 'slds-hide';
            checkRemoteSetting();
            if(!RemoteSettingConnectionWarning){
                showHideRemotePE = 'slds-hide';
                showHide = '';
            }
            
        }
        if(NAMUtils.isDataSynchronized()){
            showHideDataSync = 'slds-hide';
            if(!RemoteSettingConnectionWarning){
                showHide = '';
            }
        }else{
            showHide = 'slds-hide';
            showHideDataSync = '';
            if(NAMConfigs.getDataSynchronizing()){
                showHideLabelSync = '';
                showHideButtonSync = 'slds-hide';
            }else{
                showHideLabelSync = 'slds-hide';
                showHideButtonSync = '';
            }
        }
        notesNotEnabled = 'slds-hide';
        notesEnabled = '';
        permissionIssue = 'slds-hide';
        notPermissionIssue = '';
        startDateCV = new NAMNoteConverted__c();
        startDateCV.LegacyNoteConvertedDate__c = StartDateFilter;
        endDateCV = new NAMNoteConverted__c();
        endDateCV.LegacyNoteConvertedDate__c = EndDateFilter;
        validationDateMessage = '';
        if(!NAMUtils.isEnhancedNotesEnabled()){
            notesEnabled = 'slds-hide';
            notesNotEnabled = '';
        }
        finishCount = 'false';
        try{
            NAMUtils.validatePermissions();
        }catch(Exception ex){
            permissionIssue = '';
            notPermissionIssue = 'slds-hide';
        }
        
        sucessComumunityGroupURL = NAMUtils.SUCCESS_COMMUNITY_GROUP_URL;
        appExchangeURL = NAMUtils.APP_EXCHANGE_URL;
        storageURL = URL.getSalesforceBaseUrl().toExternalForm() + '/setup/org/orgstorageusage.jsp?id=' + UserInfo.getOrganizationId();
        apexjobsURL = URL.getSalesforceBaseUrl().toExternalForm() + '/apexpages/setup/listAsyncApexJobs.apexp';           
        
        
        countNotesPerObject = 0; 
        countObjectsWithNotesUnMigrated = 0;
        
        countNotesMigratedPerObject = 0;
        countObjectsWithNotesMigrated = 0;
        noRecords = true;
        EmptyMigratedObjects = true;
        
        TotalLegacyNotes = '0';
        numberOfConvertedNotes = '0';
        numberOfUnconvertedNotes = '0';
        auxStartDate = startDateCV.LegacyNoteConvertedDate__c;
        auxEndDate = endDateCV.LegacyNoteConvertedDate__c;
        
        checkInProgress();
    }
    
    @TestVisible
    private void checkInProgress(){
        List<NAMNoteConversionStatus__c> migrated = NMTNoteConversionStatus.find();
        
        inProgress = NMTNoteConversionStatus.isInProgress();
        List<NAMAttachmentConversionStatus__c> attachmentStatus = ATFAttachmentConversionStatus.findInProgress();
        if(attachmentStatus != null && attachmentStatus.size() > 0){
            otherToolInProgress = 'display:inline';
            inProgressLabel = 'display:none';
            inProgressLabelTable = 'display:inline';
            inProgressDeleteLabel = 'display:none';
        } else {
            otherToolInProgress = 'display:none';
            if(migrated.size() > 0 && inProgress){
                disabledCount = true;
                numberOfPendingNotes = ' - ';
                String jobId = migrated.get(0).JobId__c;
                /* SR note: user CRUD/FLS checks not appropriate here */
                AsyncApexJob job = [SELECT Id, TotalJobItems, JobItemsProcessed 
                                    FROM AsyncApexJob 
                                    WHERE Id = :jobId];
                if(job != null){
                    if(migrated.get(0).Type__c.contains('Deletion')){
                        inProgressDeleteValue = 'In Progress' ;
                    }else{
                        inProgressValue = 'In Progress' ;
                    }
                    
                }
                inProgressLabelTable = 'display:none';
                if(migrated.get(0).Type__c.contains('Deletion')){
                    inProgressLabel = 'display:none';
                    inProgressDeleteLabel = 'display:inline';
                    
                }else{
                    inProgressLabel = 'display:inline';
                    inProgressDeleteLabel = 'display:none';
                }
            } else{
                disabledCount = false;
                inProgressLabel = 'display:none';
                inProgressDeleteLabel = 'display:none';
                inProgressLabelTable = 'display:inline';
            }
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
    
    
    @TestVisible
    private void doCounts(){
        auxStartDate = startDateCV.LegacyNoteConvertedDate__c;
        auxEndDate = endDateCV.LegacyNoteConvertedDate__c;
        loadSObjects();
        countNotesPerObject = 0; 
        countObjectsWithNotesUnMigrated = notesPerObject.size();
        for(NMTSObjectWrapperNotes notePerObject: notesPerObject){
            countNotesPerObject+=noteperObject.quantity;
        }
        
        countNotesMigratedPerObject = 0;
        countObjectsWithNotesMigrated = notesMigratedPerObject.size();
        for(NMTSObjectWrapperNotes noteMigratedPerObject: notesMigratedPerObject){
            countNotesMigratedPerObject+=noteMigratedPerObject.quantity;
        }
        
        
        if(countNotesPerObject > 0){
            noRecords = false;
        } else{
            noRecords = true;
        }
        
        TotalLegacyNotes = countNotesMigratedPerObject+countNotesPerObject+'';
        numberOfConvertedNotes = countNotesMigratedPerObject +'';
        numberOfUnconvertedNotes = countNotesPerObject + '';
        finishCount = 'true';
        startDate = auxStartDate;
        endDate = auxEndDate;
        
    }
    
    
    /**
* @description
* @return null
*/
    public PageReference loadSObjects(){
        List<List<NMTSObjectWrapperNotes>> results = NAMUtils.countPublicNotesPerObject(QueryLimitMigratedObjects, OffsetSizeMigratedObjects, auxStartDate, auxEndDate, byCreateDate, objectSelected);
        notesPerObject = results.get(0);
        notesMigratedPerObject = results.get(1);
        for(NMTSObjectWrapperNotes theObject : notesPerObject) {  
            theObject.selected = false;
        }
        if(notesMigratedPerObject.size()>0){
            EmptyMigratedObjects = false;
        }else{
            EmptyMigratedObjects = true;
        }
        return null;
    }
    
    public PageReference Filter(){
        if(startDateCV.LegacyNoteConvertedDate__c>System.today()||endDateCV.LegacyNoteConvertedDate__c>System.today()){
            validationDateMessage = 'Invalid date range. Please choose dates that include today or earlier.';
            finishCount = 'true';
        }else if(startDateCV.LegacyNoteConvertedDate__c>endDateCV.LegacyNoteConvertedDate__c){
            validationDateMessage = 'Invalid date range. Please choose an end date that\'s on or after the start date.';
            finishCount = 'true';
        }
        else{
            validationDateMessage='';
            finishCount = 'false';
            auxStartDate = startDateCV.LegacyNoteConvertedDate__c;
            auxEndDate = endDateCV.LegacyNoteConvertedDate__c;
            
            system.debug('auxStartDate: ' + auxStartDate);
            system.debug('auxEndDate: ' + auxEndDate);
            loadSObjects();
            countNotesPerObject = 0; 
            countObjectsWithNotesUnMigrated = notesPerObject.size();
            for(NMTSObjectWrapperNotes notePerObject: notesPerObject){
                countNotesPerObject+=noteperObject.quantity;
            }
            
            countNotesMigratedPerObject = 0;
            countObjectsWithNotesMigrated = notesMigratedPerObject.size();
            for(NMTSObjectWrapperNotes noteMigratedPerObject: notesMigratedPerObject){
                countNotesMigratedPerObject+=noteMigratedPerObject.quantity;
            }
            
            if(countNotesPerObject > 0){
                noRecords = false;
            } else{
                noRecords = true;
            }
            
            TotalLegacyNotes = countNotesMigratedPerObject+countNotesPerObject+'';
            numberOfConvertedNotes = countNotesMigratedPerObject +'';
            numberOfUnconvertedNotes = countNotesPerObject + '';
            finishCount = 'true';
            startDate = auxStartDate;
            endDate = auxEndDate;
            
        }
        return null;
    }
    
    @RemoteAction
    public static String detectInternalSalesforceError() {
        String className = NMTMigratorBatch.class.getName();
        String nameSpace = '';
        if(className.contains('.')){
            nameSpace = className.substringBefore('.');
            className = className.substringAfter('.');
            
            System.debug('className '+className);
            System.debug('nameSpace '+nameSpace);
        }
        String classId = NAMUtils.detectInternalSalesforceError(className, nameSpace);
        if(!classId.equals('-1')){
            System.debug('Internal Salesforce Error detected');
        }
        return classId;
    }
    
    @RemoteAction
    public static void abortOperation() {
        String className = NMTMigratorBatch.class.getName();
        String nameSpace = '';
        if(className.contains('.')){
            nameSpace = className.substringBefore('.');
            className = className.substringAfter('.');
            
            System.debug('className '+className);
            System.debug('nameSpace '+nameSpace);
        }
        NAMUtils.abortOperation(className, nameSpace, false, false);
    }
    
    /**
* @description
* @return null
*/
    public PageReference Refresh(){
        
        finishCount = 'false';
        auxStartDate = startDate;
        auxEndDate = endDate;
        loadSObjects();
        countNotesPerObject = 0; 
        countObjectsWithNotesUnMigrated = notesPerObject.size();
        for(NMTSObjectWrapperNotes notePerObject: notesPerObject){
            countNotesPerObject+=noteperObject.quantity;
        }
        
        countNotesMigratedPerObject = 0;
        countObjectsWithNotesMigrated = notesMigratedPerObject.size();
        for(NMTSObjectWrapperNotes noteMigratedPerObject: notesMigratedPerObject){
            countNotesMigratedPerObject+=noteMigratedPerObject.quantity;
        }
        
        if(countNotesPerObject > 0){
            noRecords = false;
        } else{
            noRecords = true;
        }
        
        TotalLegacyNotes = countNotesMigratedPerObject+countNotesPerObject+'';
        numberOfConvertedNotes = countNotesMigratedPerObject +'';
        numberOfUnconvertedNotes = countNotesPerObject + '';
        
        finishCount = 'true';
        checkInProgress();
        getobjectsItems();
        schedulerIsActive = NAMConfigs.getEnableScheduler();
        schedulerSize = NAMConfigs.getSchedulerSize();
        return null;
    }
    
    /**
* @description Selects / unselects all rows in the UI
* @return null
*/
    public PageReference checkUncheckObjects(){
        for(NMTSObjectWrapperNotes theObject : notesPerObject){
            theObject.selected = allUnmigratedObjectsChecked;
        }
        return null;
    }
    
    @RemoteAction
    public static void deleteRemote(String objectNameDelete, String startDate, String endDate, Boolean byCreateDate) {
        
        NAMUtils.validatePermissions();
        
        System.debug(objectNameDelete);
        Date sdate = Date.valueOf(startDate);
        Date edate = Date.valueOf(endDate);
        
        List<NAMAttachmentConversionStatus__c> attachmentStatus = ATFAttachmentConversionStatus.findInProgress();
        if(attachmentStatus.size() == 0 && !NMTNoteConversionStatus.isInProgress()){
            NMTDeleteBatch batch = new NMTDeleteBatch(objectNameDelete, sdate, edate, byCreateDate);
            Id batchId = Database.executeBatch(batch, NAMConfigs.getBatchSizeForNotes());
            NMTNoteConversionStatus.changeStatus('Progress', batchId,'Deletion');
        }else{
            System.debug(attachmentStatus.size());
            if(attachmentStatus.size()>0){
                throw new NAMOtherToolInProgressException('You\'re currently converting attachments to files. When that process completes, you can convert notes.');
            }
        }
    }
    
    @RemoteAction
    public static void syncRemote() {
        Boolean inSync = NAMConfigs.getDataSynchronizing();
        if(!inSync){
            NAMConfigs.setDataSynchronizing(true);
            NMTSyncBatch batch = new NMTSyncBatch();
            Database.executeBatch(batch, NAMConfigs.getBatchSizeForNotes());
        }
    }
    
    /**
* @description
*/
    @RemoteAction
    public static void runMigrationRemote(String sObjectsWrapperAsJson, String migrationType, String startDate, String endDate, Boolean byCreateDate) {
        
        NAMUtils.validatePermissions();
        
        Date sdate = Date.valueOf(startDate);
        Date edate = Date.valueOf(endDate);
        List<NAMAttachmentConversionStatus__c> attachmentStatus = ATFAttachmentConversionStatus.findInProgress();
        System.debug(attachmentStatus.size());
        if(attachmentStatus.size() == 0 && sObjectsWrapperAsJson != '' && !NMTNoteConversionStatus.isInProgress() ){
            sObjectsWrapperAsJson = sObjectsWrapperAsJson.removeEnd(',');
            if(migrationType.equals('byObject')){  
                sObjectsWrapperAsJson = sObjectsWrapperAsJson.removeEnd('|');
                String[] objectsArray = sObjectsWrapperAsJson.split('\\|');
                //bulk migration does not delete note after the migration
                Boolean deleteAfterMigration = false;
                for(Integer i=0; i<objectsArray.size(); i++){
                    String[] row = objectsArray[i].split(',');
                    String objectName = row[0];
                    Integer quantity = null;
                    if(row.size()>1){
                        quantity = Integer.valueOf(row[1]);
                    }
                    if(quantity > 0 || quantity == null){                    
                        NMTMigratorBatch batch = new NMTMigratorBatch(objectName, null, migrationType,quantity,sDate, eDate, byCreateDate);
                        Id batchId = Database.executeBatch(batch, NAMConfigs.getBatchSizeForNotes());
                        NMTNoteConversionStatus.changeStatus('Progress', batchId,'Convertion');
                    }                           
                }
                
            }   else{
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
                
                for(String idNote : resultAux){
                    mapAux.put(idNote, idNote);
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
                    if(invalidsIds.contains(' - ')){
                        Throw new NAMForbiddenException('We don\'t recognize the IDs ' + invalidsIds + '. Reenter the IDs and try again.');
                    } else {
                        Throw new NAMForbiddenException('We don\'t recognize the ID ' + invalidsIds + '. Reenter the ID and try again.');
                    }
                    
                } else{
                    if(migrationType.equals('byId')){
                        mapAux = NAMUtils.validateEnteredIDs(validIds, mapAux, false);
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
                        if(invalidsIds.contains(' - ')){
                            Throw new NAMForbiddenException('We can\'t get data for the IDs ' + invalidsIds + '. The IDs don\'t exist or have been deleted, or you don\'t have access to those records.');
                        } else {
                            Throw new NAMForbiddenException('We can\'t get data for the ID ' + invalidsIds + '. The ID doesn\'t exist or has been deleted, or you don\'t have access to that record.');
                        }
                    } else {
                        system.debug('mapAux: ' + mapAux);
                        system.debug('mapAuxToCheckRecords: ' + mapAuxToCheckRecords);
                        if(migrationType.equals('byObjectId')){
                            mapAux = NAMUtils.validateNoRecordsObjectIDs(validIds, mapAuxToCheckRecords, false);
                        } 
                        if(migrationType.equals('byObjectId') && !mapAux.isEmpty()){
                            invalidsIds = '';
                            for(String invalidsId : mapAux.values()){
                                invalidsIds += invalidsId + ' - ';
                            }
                            invalidsIds = invalidsIds.removeEnd(' - ');
                            if(invalidsIds.contains(' - ')){
                                Throw new NAMForbiddenException('No notes are associated with these IDs ' + invalidsIds + '.');
                            } else {
                                Throw new NAMForbiddenException('No notes are associated with the ID ' + invalidsIds + '.');
                            }
                        } else {
                            NMTMigratorBatch batch = new NMTMigratorBatch(null, validIds, migrationType, null,sDate, eDate, byCreateDate);
                            Id batchId = Database.executeBatch(batch, NAMConfigs.getBatchSizeForNotes());
                            /* SR note: user CRUD/FLS checks not appropriate here */
                            AsyncApexJob job = [SELECT Id, TotalJobItems, JobItemsProcessed 
                                                FROM AsyncApexJob 
                                                WHERE Id = :batchId];
                            NMTNoteConversionStatus.changeStatus('Progress', batchId,'Convertion');
                        }
                        
                    }
                } 
            }
            
        } else{
            if(attachmentStatus.size()>0){
                throw new NAMOtherToolInProgressException('You\'re currently converting attachments to files. When that process completes, you can convert notes.');
            } else {
                if(sObjectsWrapperAsJson != ''){
                    String message = 'We are busy converting notes. When we\'re done, start another conversion.';
                    Throw new NAMForbiddenException(message);
                }
            }
        }
    }
    
    public Boolean getEmptyObjects() {  
        return countNotesPerObject == 0;
    } 
    
    public Boolean getDisablePreviousMigratedObjects(){
        if(OffsetSizeMigratedObjects>0){
            return false;
        }
        else return true;
    }
    
    public Boolean getDisablePreviousUnmigratedObjects(){
        if(OffsetSizeUnmigratedObjects>0){
            return false;
        }
        else return true;
    }
    
    public Boolean getDisableNextMigratedObjects() {
        List<List<NMTSObjectWrapperNotes>> results = NAMUtils.countPublicNotesPerObject(QueryLimitMigratedObjects, OffsetSizeMigratedObjects+QueryLimitMigratedObjects+1,startDate,endDate, byCreateDate, objectSelected);
        return results.get(1).size()<=0; 
    }
    
    public Boolean getDisableNextUnmigratedObjects() {        
        List<List<NMTSObjectWrapperNotes>> results = NAMUtils.countPublicNotesPerObject(QueryLimitUnMigratedObjects, OffsetSizeUnMigratedObjects+QueryLimitUnMigratedObjects+1,startDate,endDate, byCreateDate, objectSelected);
        return results.get(0).size()<=0;
    }
    
    public PageReference NextMigratedObjects() {
        OffsetSizeMigratedObjects += QueryLimitMigratedObjects;
        notesMigratedPerObject = NAMUtils.countPublicNotesPerObject(QueryLimitMigratedObjects, OffsetSizeMigratedObjects,startDate,endDate, byCreateDate, objectSelected).get(1);
        allMigratedObjectsChecked = false;
        checkUncheckMigratedObjects();
        return null;
    }
    
    public PageReference NextUnmigratedObjects() {
        OffsetSizeUnmigratedObjects += QueryLimitUnmigratedObjects;
        notesPerObject = NAMUtils.countPublicNotesPerObject(QueryLimitUnMigratedObjects, OffsetSizeUnMigratedObjects,startDate,endDate, byCreateDate, objectSelected).get(0);
        allUnmigratedObjectsChecked = false;
        checkUncheckObjects();
        return null;
    }
    
    public PageReference PreviousMigratedObjects() {
        OffsetSizeMigratedObjects -= QueryLimitMigratedObjects;
        notesMigratedPerObject = NAMUtils.countPublicNotesPerObject(QueryLimitMigratedObjects, OffsetSizeMigratedObjects,startDate,endDate, byCreateDate, objectSelected).get(1);
        allMigratedObjectsChecked = false;
        checkUncheckMigratedObjects();
        return null;
    }
    
    public PageReference PreviousUnmigratedObjects() {
        OffsetSizeUnmigratedObjects -= QueryLimitUnmigratedObjects;
        notesPerObject = NAMUtils.countPublicNotesPerObject(QueryLimitUnMigratedObjects, OffsetSizeUnMigratedObjects,startDate,endDate, byCreateDate, objectSelected).get(0);
        allUnmigratedObjectsChecked = false;
        checkUncheckObjects();
        return null;
    }
    
    /**
* @description Selects / unselects all rows in the UI
* @return null
*/
    public PageReference checkUncheckMigratedObjects(){
        for(NMTSObjectWrapperNotes theObject : notesMigratedPerObject){
            theObject.selected = allMigratedObjectsChecked;
        }
        return null;
    }
    
    public void ResetFinishCount() {
        finishCount = 'false';
        
    }
    
    //Code to set the remote setting
    public String Host {get;set;}
    
    public String RemoteSettingResponse {get;set;}
    
    public Boolean RemoteSettingConnectionWarning {get;set;}
    
    public String showHideRemote { get; set; }
    public String showHideRemotePE { get; set; }
    public String showHide { get; set; }
    public String showHideDataSync { get; set; }
    public String showHideButtonSync { get; set; }
    public String showHideLabelSync { get; set; }
    
    public void checkRemoteSetting()
    {
        // Get Host Domain
        Host = URL.getSalesforceBaseUrl().toExternalForm();
        
        // Attempt to connect to the Tooling API
        RemoteSettingConnectionWarning = false;
        if(!NAMRollupService.checkRemoteSetting())
        {
            RemoteSettingConnectionWarning = true;
            try {
                NAMRollupService.checkRemoteSettingForCallouts();
            } catch (System.CalloutException e) {
                RemoteSettingConnectionWarningMessage = e.getMessage();
            }
        }
    }
    
    
    public List<SelectOption> getobjectsItems() {
        List<SelectOption> greens = new List<SelectOption>();
        List<SelectOption> options = new List<SelectOption>();
        Boolean addAll = true;
        String[] customobjects = NAMUtils.getCustomObject();
        options.add(new SelectOption('All', 'All'));
        for(String green : NAMUtils.PARENT_TYPE_GREENS){
            options.add(new SelectOption(green, green));
            greens.add(new SelectOption(green, green));
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