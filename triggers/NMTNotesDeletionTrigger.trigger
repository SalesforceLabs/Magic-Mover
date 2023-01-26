/**
* @author Andres Canavesi, Dayana Daniel
* @description A trigger that set to null the field LegacyNoteConvertedId__c when a Note was deleted.
* This is to be able to know the pending notes to be migrated.
*/
trigger NMTNotesDeletionTrigger on Note (after delete) {
    
    NMTNotesDeletionTriggerHandler handler = new NMTNotesDeletionTriggerHandler(Trigger.isExecuting, Trigger.size);
    handler.onAfterDelete(Trigger.old);
    
}