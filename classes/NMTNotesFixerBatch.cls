/**
* Batch to fix last modified dates of Magic Mover's converted and deleted legacy notes.
* It creates a new version of the converted note with the right last modified date
*
* IMPORTANT: it recovers the last modified date but without time since is data we do not have available.
* 
* Execute like:
* 
* NMTNotesFixerBatch batch = new NMTNotesFixerBatch();
* Integer batchSize = 500;
* Database.executeBatch(batch, batchSize);
* 
* @author Andres Canavesi
* edited ateppo 5/7/2020
*/
global with sharing class NMTNotesFixerBatch implements Database.Batchable<sObject>, Database.stateful{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String namespace = '';//example: MYNAMESPACE__
        
        //selects all migrated notes that has been deleted
        String query = 'SELECT Id, LatestPublishedVersion.'+namespace+'LegacyNoteConvertedLastModifiedDate__c, '; 
        query += ' LatestPublishedVersion.PathOnClient, LatestPublishedVersion.VersionData '; 
        query += ' FROM ContentDocument ';
        query += ' WHERE LatestPublishedVersion.LegacyNoteConvertedLastModifiedDate__c != null ';
        query += ' AND LatestPublishedVersion.LegacyNoteConvertedId__c = null ';
        System.debug(query);
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<ContentDocument> cds){
        List<ContentVersion> filesToSave = new List<ContentVersion>();
        //for each converted note, create a new version with the right last modified date 
        if(Schema.sObjectType.ContentVersion.fields.ContentDocumentId.isCreateable()
               &&Schema.sObjectType.ContentVersion.fields.ReasonForChange.isCreateable()
               &&Schema.sObjectType.ContentVersion.fields.PathOnClient.isCreateable()
               &&Schema.sObjectType.ContentVersion.fields.VersionData.isCreateable()
               &&Schema.sObjectType.ContentVersion.fields.LastModifiedDate.isCreateable()
               &&Schema.sObjectType.ContentVersion.fields.CreatedDate.isCreateable()){        
                for(ContentDocument cd :cds){
                   ContentVersion newCv = new ContentVersion();
                   newCv.ContentDocumentId = cd.id;
                   newCv.ReasonForChange = 'Magic Mover fix';
                   newCv.PathOnClient = cd.LatestPublishedVersion.PathOnClient;
                   newCv.VersionData =cd.LatestPublishedVersion.VersionData;
                   newCv.LastModifiedDate = cd.LatestPublishedVersion.LegacyNoteConvertedLastModifiedDate__c;
                   newCv.CreatedDate = cd.LatestPublishedVersion.LegacyNoteConvertedLastModifiedDate__c;
                   filesToSave.add(newCv);
               }

            insert filesToSave;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug('Magic mover notes fixer done');
    }
}