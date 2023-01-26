/**
* @author Dayana Daniel
* @description Batch process for synchronizing the data from old versions of the tool. 
* edited ateppo 5/7/2020
*/
global with sharing class NMTSyncBatch implements Database.Batchable<sObject>, Database.stateful{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //we have to filter at least for two values because for the old version, we are removing the NoteId, 
        //and in the new version, we are not copying the other values
        String query = 'SELECT Id, latestPublishedVersion.LegacyNoteConvertedId__c, latestPublishedVersion.LegacyNoteConvertedDate__c,';
               query += 'latestPublishedVersion.LegacyNoteConvertedLastModifiedDate__c, latestPublishedVersion.LegacyNoteConvertedOwnerId__c,';
               query += 'latestPublishedVersion.LegacyNoteConvertedParentId__c FROM ContentDocument WHERE latestPublishedVersion.LegacyNoteConvertedId__c != null';
               query += ' AND latestPublishedVersion.LegacyNoteConvertedDate__c != null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<ContentDocument> cds){
        
        List<NAMNoteConverted__c> notesConvertedToInsert = new List<NAMNoteConverted__c>();
        
        if(Schema.sObjectType.NAMNoteConverted__c.fields.LegacyNoteConvertedId__c.isCreateable()
               &&Schema.sObjectType.NAMNoteConverted__c.fields.LegacyNoteConvertedDate__c.isCreateable()
               &&Schema.sObjectType.NAMNoteConverted__c.fields.LegacyNoteConvertedLastModifiedDate__c.isCreateable()
               &&Schema.sObjectType.NAMNoteConverted__c.fields.LegacyNoteConvertedOwnerId__c.isCreateable()
               &&Schema.sObjectType.NAMNoteConverted__c.fields.LegacyNoteConvertedParentId__c.isCreateable()){
            for(ContentDocument cd: cds){
                   NAMNoteConverted__c noteConverted = new NAMNoteConverted__c();
                   noteConverted.LegacyNoteConvertedId__c = cd.latestPublishedVersion.LegacyNoteConvertedId__c;
                   noteConverted.LegacyNoteConvertedDate__c = cd.latestPublishedVersion.LegacyNoteConvertedDate__c;
                   noteConverted.LegacyNoteConvertedLastModifiedDate__c = cd.latestPublishedVersion.LegacyNoteConvertedLastModifiedDate__c;
                   noteConverted.LegacyNoteConvertedOwnerId__c = cd.latestPublishedVersion.LegacyNoteConvertedOwnerId__c;
                   noteConverted.LegacyNoteConvertedParentId__c = cd.latestPublishedVersion.LegacyNoteConvertedParentId__c;
                   notesConvertedToInsert.add(noteConverted);
            }

            Database.SaveResult[] srList = Database.insert(notesConvertedToInsert, true);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    mycustomfinish(true);
                    System.abortJob(bc.getJobId());
                }
            }

        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        mycustomfinish(false);
    }
    
    /**
    * @description finish method is not executed if we abort the batch. We use this method for both situations: normal and abort finishing
    */
    private void mycustomfinish(Boolean error){
        if(!error){
            NAMConfigs.setDataSynchronized(true);
        }
        NAMConfigs.setDataSynchronizing(false);
    }
}