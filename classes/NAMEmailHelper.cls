public class NAMEmailHelper { 
    
    /**
* @description map to store known conversion errors, to send them in the email to the 
* administrator to suggest a common solution to fix It
*/
    public static Map<String, NAMTroubleshooting> knownMigrationErrors = new Map<String, NAMTroubleshooting>{
        String.valueOf(System.StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY) => new NAMTroubleshooting(String.valueOf(System.StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY),
                                                                                                         'There is a trigger in the Content Version that is failing.',
                                                                                                         'Disable the trigger during migration.'),
            String.valueOf(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) => new NAMTroubleshooting(String.valueOf(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION),
                                                                                                          'There is a validation rule in the Content Version.',
                                                                                                          'Disable that validation rule during migration.'),
            String.valueOf(System.StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION) => new NAMTroubleshooting(String.valueOf(System.StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION),
                                                                                                          'There is a filter validation in the Content Version.',
                                                                                                          'Disable that filter validation during migration.'),
            String.valueOf(System.StatusCode.REQUIRED_FIELD_MISSING) => new NAMTroubleshooting(String.valueOf(System.StatusCode.REQUIRED_FIELD_MISSING),
                                                                                               'There is a field required in the Content Version.',
                                                                                               'Make that field not required during migration.'),
            String.valueOf(System.StatusCode.STORAGE_LIMIT_EXCEEDED) => new NAMTroubleshooting(String.valueOf(System.StatusCode.STORAGE_LIMIT_EXCEEDED),
                                                                                               'The org has reached the storage limit.',
                                                                                               'Delete migrated attachments to  free up space.')};
                                                                                                   
                                                                                                   
                                                                                                   /*
* @description send an email after the migration completes to the user that request it
*/                                                                                            
                                                                                                   public static void emailSetupAndSend(Boolean isAttachments, String objectName, List<NAMMigrationResults> migrationResults, Integer totalFiles, Boolean limitError, Boolean storage, Boolean InvalidCharacter, Integer objectsToBeMigrated, Integer totalFilesFailed, List<String> listIds, String limitMessage){  
                                                                                                       String objectOfMigration;
                                                                                                       if(isAttachments){
                                                                                                           objectOfMigration = 'attachment';
                                                                                                       } else {
                                                                                                           objectOfMigration = 'note';
                                                                                                       }
                                                                                                       String subjectEmail = 'Your '; 
                                                                                                       if(objectName != null){
                                                                                                           subjectEmail += objectName + ' ';
                                                                                                       }
                                                                                                       subjectEmail += objectOfMigration + ' conversion job has completed';
                                                                                                       String signature = '<br/><br/><br/>Salesforce';
                                                                                                       String footer = 'You’re registered as '+UserInfo.getUserEmail()+' in the Salesforce org '+UserInfo.getOrganizationName()+'. Need help? Contact Salesforce Support. <br/>Package Version ' + NAMUtils.PACKAGE_VERSION_NAME + '.';
                                                                                                       String name = UserInfo.getFirstName();
                                                                                                       String emailReport = '';
                                                                                                       if(name != null){
                                                                                                           emailReport = '<p>Hello '+UserInfo.getFirstName()+',</p>';
                                                                                                       }else{
                                                                                                           emailReport = '<p>Hello '+UserInfo.getLastName()+',</p>';
                                                                                                       }        
                                                                                                       
                                                                                                       if(totalFilesFailed > 0 || limitError || storage){
                                                                                                           if(limitError){ 
                                                                                                               subjectEmail = 'Your ';
                                                                                                               if(objectName != null){
                                                                                                                   subjectEmail += objectName + ' ';  
                                                                                                               }
                                                                                                               subjectEmail += objectOfMigration + ' conversion job has completed, but you exceeded your daily limit. Please open for errors.';
                                                                                                           } else{
                                                                                                               if(storage){
                                                                                                                   subjectEmail = 'Your '+ objectName + ' ' + objectOfMigration + ' conversion job has completed, but you exceeded your storage limit. Please open for errors.';
                                                                                                               } else{
                                                                                                                   subjectEmail = 'Your '+ objectName + ' ' + objectOfMigration + ' conversion job has completed. Please open for errors.';             
                                                                                                               }
                                                                                                           }    
                                                                                                       }
                                                                                                       
                                                                                                       if(objectsToBeMigrated > 0){
                                                                                                           emailReport += '<div>The conversion of ';
                                                                                                           if(objectName != null){
                                                                                                               emailReport +=objectName + ' ';
                                                                                                           }
                                                                                                           if(isAttachments){
                                                                                                               emailReport += 'attachments to Salesforce Files is complete.<br/>';
                                                                                                           } else {
                                                                                                               emailReport += 'Classic notes to Enhanced notes is complete.<br/>';
                                                                                                           }
                                                                                                           
                                                                                                           if(totalFiles == objectsToBeMigrated){
                                                                                                               emailReport += 'Number of ' + objectOfMigration + 's to convert: ' + objectsToBeMigrated + '<br/>'+
                                                                                                                   + 'Number of ' + objectOfMigration + 's converted: ' + totalFiles + '<br/>'+
                                                                                                                   + 'Number of errors: ' + totalFilesFailed + '<div>';
                                                                                                               if(isAttachments){
                                                                                                                   emailReport += '<p>Since they are converted to files, these attachments can now be deleted.</p>';
                                                                                                               } else {
                                                                                                                   emailReport += '<p>Since they are converted to Enhanced notes, these Classic notes can now be deleted.</p>'; 
                                                                                                               }
                                                                                                               
                                                                                                           }else{
                                                                                                               if(limitError){
                                                                                                                   emailReport += 'Number of '+ objectOfMigration + 's converted: ' + totalFiles + '<br/>';
                                                                                                                   emailReport += '<p>Your org has exceeded at least one daily limit, such as content publication limits or Apex limits.' 
                                                                                                                       +'Please contact Salesforce support to resolve this issue. The limit will reset after 24 hours.<p>';
                                                                                                                   if(limitMessage!=null&&String.isNotBlank(limitMessage)&&String.isNotEmpty(limitMessage)){
                                                                                                                       emailReport +='<br/><br/>'
                                                                                                                           +'<b>Apex Job Status Message:</b> '+limitMessage;
                                                                                                                       if(limitMessage.toLowerCase().contains(NAMUtils.APEX_CPU_LIMIT_TEXT.toLowerCase())){
                                                                                                                           if(!NAMConfigs.getEnableDynamicBatchSize()&&NAMConfigs.getBatchSizeForAttachments()>NAMConfigs.getMinBatchSize()){
                                                                                                                               emailReport +='<br/><br/>'
                                                                                                                                   +'Migration used '+NAMConfigs.getBatchSizeForAttachments()+' batch size. Set a smaller batch size or enable the dynamic batch size in the configuration page.';
                                                                                                                           }else{
                                                                                                                               emailReport +='<br/><br/>'
                                                                                                                                   +'Migration used the minimum batch size. You may have a large record that the tool cannot migrate, please review and migrate it manually.';
                                                                                                                           }
                                                                                                                       }
                                                                                                                   }
                                                                                                               }else{
                                                                                                                   if(storage){
                                                                                                                       emailReport += 'Number of '+ objectOfMigration + 's converted: ' + totalFiles + '<br/>';
                                                                                                                       emailReport += '<p>Some '+ objectOfMigration + 's could not be converted because your org has exceeded the storage limit. '
                                                                                                                           +'Delete converted '+ objectOfMigration + 's or other files to free up storage space. '
                                                                                                                           +'<a href="https://developer.salesforce.com/docs/atlas.en-us.salesforce_app_limits_cheatsheet.meta/salesforce_app_limits_cheatsheet/salesforce_app_limits_overview.htm"  target = "_blank">See Salesforce Files Limits </a></p>';
                                                                                                                   }else{
                                                                                                                       emailReport += 'Number of ' + objectOfMigration + 's to convert: ' + objectsToBeMigrated + '<br/>'+
                                                                                                                           + 'Number of ' + objectOfMigration + 's converted: ' + totalFiles + '<br/>'+
                                                                                                                           + 'Number of errors: ' + totalFilesFailed + '<div>';
                                                                                                                       
                                                                                                                       //to log errors
                                                                                                                       Set<NAMTroubleshooting> errors = new Set<NAMTroubleshooting>();
                                                                                                                       for(NAMMigrationResults result: migrationResults){
                                                                                                                           String[] statusCode = result.ErrorMessage.split(':');
                                                                                                                           if(!statusCode.isEmpty()&&knownMigrationErrors.containsKey(statusCode[0]))
                                                                                                                           {
                                                                                                                               NAMTroubleshooting newtroubleshooting = knownMigrationErrors.get(statusCode[0]);
                                                                                                                               errors.add(newtroubleshooting);
                                                                                                                           }
                                                                                                                       }
                                                                                                                       
                                                                                                                       if(!errors.isEmpty()){
                                                                                                                           emailReport += '<div><br/><br/>We found these errors:<br/><br/>';
                                                                                                                           for(NAMTroubleshooting error: errors){
                                                                                                                               emailReport +='<b>'+error.errorCode+'</b>: '+error.cause+' '+error.solution+'<br/><br/>';
                                                                                                                           }
                                                                                                                           emailReport += 'Open the csv file to see more details.<br/>'
                                                                                                                               +'<a href="https://appexchange.salesforce.com/servlet/servlet.FileDownload?file=00P3A00000aB532UAC"  target = "_blank">Learn More</a></div>';
                                                                                                                           
                                                                                                                       }
                                                                                                                   } 
                                                                                                               }
                                                                                                               
                                                                                                               if(InvalidCharacter){
                                                                                                                   emailReport += '<div><br/><br/>Review csv file for "UNSAFE_HTML_CONTENT" errors, remove/replace the invalid characters and try again.<br/><br/>';
                                                                                                               }
                                                                                                           }  
                                                                                                       } else{
                                                                                                           if(objectsToBeMigrated == 0 ){
                                                                                                               if(listIds != null){
                                                                                                                   emailReport += '<br/>We can\'t find the ' + objectOfMigration + 's or Objects with the following ids, ' + objectOfMigration + 's were deleted OR already migrated:<br/>';
                                                                                                                   emailReport += '<p>'+ listIds +'<p><br/>';
                                                                                                               }else if(objectName!=null){
                                                                                                                   if(isAttachments){
                                                                                                                       emailReport += '<br/>We can\'t find Attachments in '+ objectName +' object, ' + objectOfMigration + 's were deleted OR already migrated:<br/>';
                                                                                                                       
                                                                                                                   } else {
                                                                                                                       emailReport += '<br/>We can\'t find Notes in '+ objectName +' object, ' + objectOfMigration + 's were deleted OR already migrated:<br/>';
                                                                                                                       
                                                                                                                   }
                                                                                                               }
                                                                                                           }
                                                                                                       }
                                                                                                       //send an email to the user with the result of the migration.
                                                                                                       NAMEmailHelper.sendMailWithCSV(UserInfo.getUserId(), subjectEmail, emailReport, signature, footer, migrationResults, isAttachments, false);
                                                                                                   }
    
    /**
* @description 
* @param address 
* @param subject 
* @param body 
* @param signature 
* @param footer 
* @param migrationResults
*/
    public static void sendMailWithCSV(Id address, String subject, String body, String signature, String footer, List<NAMMigrationResults> migrationResults, Boolean isAttachments, Boolean isDeleteProcess) {
        system.debug('migrationResults ' + migrationResults.size());
        // Create an email message object
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setTargetObjectId(address);
        system.debug(address);
        mail.saveAsActivity = false;
        mail.setSubject(subject);
        String bodyemail = '<html><head></head><body>' + body +'<div><br/>' + signature +'<div><br/>' + '<footer>' + footer + '</footer></body></html>';
        system.debug('bodyemail');
        system.debug(bodyemail);
        
        mail.setHtmlBody(bodyemail);
        
        if(migrationResults!=null && migrationResults.size()>0){
            string header;
            if(isDeleteProcess){
                if(isAttachments){
                    header = 'Attachment Id, Name, Is Private, Status, Error Description \n';   
                } else {
                    header = 'Classic Note Id, Title, Is Private, Status, Error Description \n';
                }
                
            } else {
                
                if(isAttachments){
                    header = 'Attachment Id, File Id , Is Private, Status, Error Description \n';   
                } else {
                    header = 'Classic Note Id, Enhanced Note Id , Is Private, Status, Error Description \n';
                }
                
            }
            string finalstr = header ;
            if(migrationResults.size() > 20000){
                for(Integer i = 0; i< 20000; i++)
                {
                    string recordString = migrationResults.get(i).OldId+','+migrationResults.get(i).NewId+','+migrationResults.get(i).IsPrivate+','+migrationResults.get(i).Status+','+migrationResults.get(i).ErrorMessage +'\n';
                    finalstr = finalstr +recordString; 
                }  
            } else{
                for(NAMMigrationResults migrationResult : migrationResults){
                    string recordString = migrationResult.OldId+','+migrationResult.NewId+','+migrationResult.IsPrivate+','+migrationResult.Status+','+migrationResult.ErrorMessage +'\n';
                    finalstr = finalstr +recordString; 
                }
                
            }
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            blob csvBlob = Blob.valueOf(finalstr);
            string csvname;
            if(isAttachments){
                csvname= 'AttachmentMigration.csv';
            } else {
                csvname= 'NotesMigration.csv';
            }
            
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
            
            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            
        }
        
        // Pass this email message to the built-in sendEmail method 
        // of the Messaging class
        Messaging.SendEmailResult[] results = Messaging.sendEmail(
            new Messaging.SingleEmailMessage[] { mail });
        
        // Call a helper method to inspect the returned results
        inspectResults(results);
    }
    
    /**
* @description 
* @param results 
* @return
*/
    private static Boolean inspectResults(Messaging.SendEmailResult[] results) {
        Boolean sendResult = true;
        
        // sendEmail returns an array of result objects.
        // Iterate through the list to inspect results. 
        // In this class, the methods send only one email, 
        // so we should have only one result.
        for (Messaging.SendEmailResult res : results) {
            if (res.isSuccess()) {
                System.debug('Email sent successfully.');
            }
            else {
                sendResult = false;
                System.debug('[Email] The following errors occurred: ' + res.getErrors());                 
            }
        }
        return sendResult;
    }
    
    
}