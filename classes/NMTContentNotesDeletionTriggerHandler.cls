/* edited ateppo 5/5/2020 */

public class NMTContentNotesDeletionTriggerHandler {
    
    public static boolean firstRun = true; 
    
    private Boolean m_isExecuting = false;
    private Integer batchSize = 0;
    
    public NMTContentNotesDeletionTriggerHandler(boolean isExecuting, integer size) {
        this.m_isExecuting = isExecuting;
        this.batchSize = size;
    }
    
    public void onAfterDelete(List<ContentDocument> oldDocuments){
        List<Id> notesIds = new List<Id>();
        List<Id> cdIds = new List<Id>();
        for (ContentDocument cd : oldDocuments){
            System.debug('cv Id'+cd.Id);
            cdIds.add(cd.Id);
        }
        
        //we can't query over ContentVersion
        List<ContentDocument> cds = new List<ContentDocument>();

        if (Schema.sObjectType.ContentDocument.isAccessible()) {
            cds = [SELECT Id, latestPublishedVersion.LegacyNoteConvertedId__c FROM ContentDocument WHERE id in:cdIds];
            System.debug('cvs size'+cds.size());
            for(ContentDocument cd: cds ){
                System.debug('note Id'+cd.latestPublishedVersion.LegacyNoteConvertedId__c);
                if(cd.latestPublishedVersion.LegacyNoteConvertedId__c != null){
                    notesIds.add(cd.latestPublishedVersion.LegacyNoteConvertedId__c);
                }
            }
        }  

        System.debug('notes deleted: '+notesIds.size());
        
        List<NAMNoteConversionStatus__c> statuses = new List<NAMNoteConversionStatus__c>();
        List<NAMNoteConverted__c> notesConvertedUtil = new List<NAMNoteConverted__c>();

        if (Schema.sObjectType.NAMNoteConversionStatus__c.fields.Id.isAccessible() 
            && Schema.sObjectType.NAMNoteConversionStatus__c.fields.Status__c.isAccessible()
            && Schema.sObjectType.NAMNoteConversionStatus__c.fields.JobId__c.isAccessible()
            && Schema.sObjectType.NAMNoteConversionStatus__c.fields.Type__c.isAccessible()
            && Schema.sObjectType.NAMNoteConverted__c.fields.Id.isAccessible()) {
            //TODO: I don't know why we update the status???
            statuses = [SELECT Id, Status__c, JobId__c, Type__c
                        FROM NAMNoteConversionStatus__c 
                        LIMIT 1];
            if(!statuses.isEmpty()){
                NAMNoteConversionStatus__c noteConversionStatus = statuses.get(0);
                
                //notes has been converted
                notesConvertedUtil = [SELECT Id
                                      FROM
                                      NAMNoteConverted__c
                                      WHERE
                                      LegacyNoteConvertedId__c in :notesIds];
                System.debug('count trigger' +notesConvertedUtil.size());
                
                if(notesConvertedUtil.getSObjectType().getDescribe().isDeletable() && Schema.sObjectType.NAMNoteConverted__c.isDeletable()){
                    delete notesConvertedUtil;
                }
                
            }
        }
    }

}