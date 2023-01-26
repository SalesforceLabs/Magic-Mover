/**
* @author Jessica Bernal, Andres Canavesi
* @description Batch for deleting huge amounts of records. It also deletes the records from the recycle bin. 
* Deletes only PUBLIC migrated notes. Sends an email to the  the user with the result of deletion
* @date 2017-06
*/

global class NMTDeleteBatch implements Database.Batchable<sObject>, Database.stateful {
    
    /**
* @description the query to get the records to delete
*/
    public Integer totalDeleted = 0;
    public List<Id> listNotesFail = new List<Id>();
    public String errors = '';
    public String objectName;
    public Boolean byCreateDate;
    
    private final Date startDate;
    private final Date endDate;
    public List<NAMMigrationResults> migrationResultsList = new List<NAMMigrationResults>();
    
    global NMTDeleteBatch(String objectName, Date startDate, Date endDate, Boolean byCreateDate){
        this.objectName = objectName;
        this.startDate = startDate;
        this.endDate = endDate.addDays(1);
        this.byCreateDate = byCreateDate;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        /*
        * Since we don't know which notes have been migrated we have to go through all of them and
        * ask for each batch if the notes were migrated. 
        * Because of that the only WHERE is IParent.Type = objectName
        */
        DateTime startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), 00, 00, 00);
        DateTime endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 00, 00, 00);
        String sstart = startDateTime.format('yyyy-MM-dd\'T00:00:00z\'');
        String send = endDateTime.format('yyyy-MM-dd\'T00:00:00z\'');
        
        String query = 'SELECT Id, Title, Body, IsPrivate, ParentId, OwnerId, LastModifiedDate, CreatedDate, CreatedById, LastModifiedById ' 
            +' FROM Note WHERE Parent.Type = \''+objectName+'\' ';
        if(byCreateDate){    
            query+=' AND createdDate >= ' + sstart + ' AND createdDate <= ' + send;
        } else {
            query+=' AND lastModifiedDate >= ' + sstart + ' AND lastModifiedDate <= ' + send; 
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Note> notesLegacy){
        if (notesLegacy.getSObjectType().getDescribe().isDeletable()) {  
            List<String> notesParentsIds = new List<String>();
            List<String> notesIds = new List<String>();
            for(Note note :notesLegacy){
                notesIds.add(String.valueOf(note.Id));
                notesParentsIds.add(String.valueOf(note.ParentId));
            }
            
            //to know which notes have been migrated we just use the temporary object
            List<NAMNoteConverted__c> convertedNotes = [SELECT LegacyNoteConvertedId__c
                                                                   FROM
                                                                   NAMNoteConverted__c
                                                                   WHERE
                                                                   LegacyNoteConvertedId__c in :notesIds]; 
            
            if(convertedNotes.size() > 0){
                List<Note> notes = new List<Note>();
                for(Note note :notesLegacy){
                    boolean add = false;
                    //look if the note was already migrated
                    for(NAMNoteConverted__c cl: convertedNotes){
                        if(String.valueOf(note.Id) == cl.LegacyNoteConvertedId__c){
                            add = true;
                            break;
                        } 
                    } 
                    if(add){
                        notes.add(note);
                    }
                }
                System.debug('Notes to delete: '+notes);
                if(notes.size() > 0 && notes.getSObjectType().getDescribe().isDeletable()) {
                    Integer idsFails = 0;
                    Integer idsSuccess = 0;
                    Integer counter = 0;
                    List<sObject> notesSuccess = new List<sObject>();
                    Database.DeleteResult[] srList = Database.delete(notes, false);
                    for (Database.DeleteResult sr : srList) {
                        if (sr.isSuccess()) {
                            idsSuccess++;
                            notesSuccess.add(notes.get(counter));
                            migrationResultsList.add(new NAMMigrationResults(notes.get(counter).Id, notes.get(counter).Title, NAMUtils.isPrivateResult(notes.get(counter).isPrivate), NAMMigrationResults.StatusEnum.SUCCESS, ''));
                        }else{
                            idsFails++; 
                            for(Database.Error err : sr.getErrors()) {
                               migrationResultsList.add(new NAMMigrationResults(notes.get(counter).Id, notes.get(counter).Title, NAMUtils.isPrivateResult(notes.get(counter).isPrivate), NAMMigrationResults.StatusEnum.ERROR, err.getStatusCode() + ': '+ err.getMessage()));
                            } 
                        }    
                        counter++;
                    }
                    totalDeleted += notesSuccess.size();
                    try{
                        if(notesSuccess.size() > 0){
                            DataBase.emptyRecycleBin(notesSuccess); 
                        }
                    }catch(Exception e){
                         migrationResultsList.add(new NAMMigrationResults('', '', '', NAMMigrationResults.StatusEnum.ERROR, 'Something went wrong trying to delete attachments from Recycle Bin' + ': '+ e.getMessage()));
                   
                        System.debug('Something went wrong trying to delete notes from Recycle Bin');                
                    }
                } else {
                    System.debug('notes.size() > 0 false');
                }
                
            } else {
                System.debug('notesContentDocumentLinks.size() > 0 false');
            }
        } else{
            system.debug('DeleteBatch class - access');
            throw new NAMForbiddenException('DeleteBatch class - access ERROR: isDeletable() for Object - objectType.getSObjectType().getDescribe().isDeletable()');
        }                  
    }
    
    global void finish(Database.BatchableContext BC){ 
        try{
            String subjectEmail = 'Your Classic notes were deleted';        
            String signature = '<br/><br/><br/>Salesforce';
            String footer = 'You’re registered as '+UserInfo.getUserEmail()+' in the Salesforce org '+UserInfo.getOrganizationName()+'. Need help? Contact Salesforce Support. <br/>Package Version ' + NAMUtils.PACKAGE_VERSION_NAME + '.';
            String name = UserInfo.getFirstName();
            String emailReport = '';
            if(name != null){
                emailReport = '<p>Hello '+UserInfo.getFirstName()+',</p>';
            }else{
                emailReport = '<p>Hello '+UserInfo.getLastName()+',</p>';
            }    
            
            Integer deleteError = listNotesFail.size();
            emailReport += '<div>' + totalDeleted + ' notes were deleted from your org.</div><br>';
            if(deleteError > 0){
                emailReport += '<br>These notes could not be deleted: <br>';
                subjectEmail = 'Some Classic notes have been deleted. Please open for errors.';            
            }
        
            //send an email to the user with the result of the deletion.
           NAMEmailHelper.sendMailWithCSV(UserInfo.getUserId(), subjectEmail, emailReport, signature, footer, migrationResultsList, false, true);
         
        }catch(Exception e){
            System.debug('ERROR sending the email. '+e);
        }finally{
            //If an error is thrown during change of status, job (AsyncApexJob) status will be 'Completed'
            //In progress label will be hidden anyway
            NMTNoteConversionStatus.changeStatus('Completed', null,'Deletion');
        }        
    }
}