/**
* @author Jessica Bernal, Andres Canavesi
* @description Batch for deleting huge amounts of records. It also deletes the records from the recycle bin
* @date Created at 2017-01 / Updated at 2017-08
*/
global class ATFDeleteBatch implements Database.Batchable<sObject>, Database.stateful {
    
    /**
    * @description the query to get the records to delete
    */
    public String query;
    private final String objectName;
    public Integer totalDeleted = 0;
    public List<Id> listAttachmentsFail = new List<Id>();
    public List<NAMMigrationResults> migrationResultsList = new List<NAMMigrationResults>();
    
    global ATFDeleteBatch(String query, String objectName){
        if(objectName != null){
            //we are in a bulk migration context
            ATFAttachmentConversionStatus.changeToInProgressByObjectNameDeletion(objectName, null);
        } 
        this.query = query;
        this.objectName = objectName;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Attachment> scope){
        if(scope.size() > 0){
            if (scope.getSObjectType().getDescribe().isDeletable()) {  
                Integer idsFails = 0;
                Integer idsSuccess = 0;
                Integer counter = 0;
                List<sObject> attachmentsSuccess = new List<sObject>();
                Database.DeleteResult[] srList = Database.delete(scope, false);
                for (Database.DeleteResult sr : srList) {
                    if (sr.isSuccess()) {
                        idsSuccess++;
                        attachmentsSuccess.add(scope.get(counter));
                        migrationResultsList.add(new NAMMigrationResults(scope.get(counter).Id, scope.get(counter).Name, NAMUtils.isPrivateResult(scope.get(counter).isPrivate), NAMMigrationResults.StatusEnum.SUCCESS, ''));
                    }else{
                        idsFails++; 
                       // listAttachmentsFail.add(scope.get(counter).Id);
                        for(Database.Error err : sr.getErrors()) {
                           //  errors += scope.get(counter).Id + ' - ' + err.getStatusCode() + ': '+ err.getMessage() +'<br/>'; 
                          migrationResultsList.add(new NAMMigrationResults(scope.get(counter).Id, scope.get(counter).Name, NAMUtils.isPrivateResult(scope.get(counter).isPrivate), NAMMigrationResults.StatusEnum.ERROR, err.getStatusCode() + ': '+ err.getMessage()));
                        } 
                    }    
                    counter++;
                }
                totalDeleted += attachmentsSuccess.size();
                try{
                    if(attachmentsSuccess.size() > 0){
                        DataBase.emptyRecycleBin(attachmentsSuccess); 
                    }
                    
                }catch(Exception e){
                    migrationResultsList.add(new NAMMigrationResults('', '', '', NAMMigrationResults.StatusEnum.ERROR, 'Something went wrong trying to delete attachments from Recycle Bin' + ': '+ e.getMessage()));
                   
                    System.debug('Something went wrong trying to delete attachments from Recycle Bin');                
                }
            }else{
                system.debug('DeleteBatch class - access');
                throw new NAMForbiddenException('DeleteBatch class - access ERROR: isDeletable() for Object - objectType.getSObjectType().getDescribe().isDeletable()');
            }
        }        
    }
    
    global void finish(Database.BatchableContext BC){         
          try{
            String subjectEmail = 'Your '+ objectName +' attachments were deleted';        
            String signature = '<br/><br/><br/>Salesforce';
            String footer = 'You’re registered as '+UserInfo.getUserEmail()+' in the Salesforce org '+UserInfo.getOrganizationName()+'. Need help? Contact Salesforce Support. <br/>Package Version ' + NAMUtils.PACKAGE_VERSION_NAME + '.';
            String name = UserInfo.getFirstName();
            String emailReport = '';
            if(name != null){
                emailReport = '<p>Hello '+UserInfo.getFirstName()+',</p>';
            }else{
                emailReport = '<p>Hello '+UserInfo.getLastName()+',</p>';
            }    
            
            Integer deleteError = listAttachmentsFail.size();
            emailReport += '<div>' + totalDeleted + ' ' + objectName +' attachments were deleted from your org.</div><br>';
            if(deleteError > 0){
                emailReport += '<br>These attachments could not be deleted: <br>';
                subjectEmail = 'Some '+ objectName +' attachments have been deleted. Please open for errors.';            
            }
        
            //send an email to the user with the result of the deletion.
           NAMEmailHelper.sendMailWithCSV(UserInfo.getUserId(), subjectEmail, emailReport, signature, footer, migrationResultsList, true, true);
              
           //   NAMUtils.sendMailWithHTML(UserInfo.getUserId(), subjectEmail, emailReport, signature, footer);
        }catch(Exception e){
            System.debug('ERROR sending the email. '+e);
        }finally{
            if(objectName != null){
                ATFAttachmentConversionStatus.changeToCompletedByObjectNameDeletion(objectName);
            }
        }        
        
    }
}