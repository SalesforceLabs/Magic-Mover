trigger NMTContentDocumentDeletionTrigger on ContentDocument (before delete) {
    System.debug('Inside Trigger');
    NMTContentNotesDeletionTriggerHandler handler = new NMTContentNotesDeletionTriggerHandler(Trigger.isExecuting, Trigger.size);
    handler.onAfterDelete(Trigger.old);
}