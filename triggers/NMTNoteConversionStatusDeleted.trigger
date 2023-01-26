trigger NMTNoteConversionStatusDeleted on NAMNoteConversionStatus__c (before delete) {
    String className = NMTMigratorBatch.class.getName();
    String nameSpace = '';
    if(className.contains('.')){
        nameSpace = className.substringBefore('.');
        className = className.substringAfter('.');
        
    }
    List<ApexClass> classesId = new List<ApexClass>();
    /* SR note: user CRUD/FLS checks not appropriate here */
    if(String.isEmpty(nameSpace)){
        classesId = [SELECT Id FROM ApexClass WHERE Name = :className LIMIT 1];
    }else{
        classesId = [SELECT Id FROM ApexClass WHERE Name = :className AND NamespacePrefix = :nameSpace LIMIT 1];
    }
    if(classesId!=null && !classesId.isEmpty()){
        //Select the Job that is processing for that class
        /* SR note: user CRUD/FLS checks not appropriate here */
        List<AsyncApexJob> jobs = [SELECT Id, JobItemsProcessed, Status FROM AsyncApexJob WHERE ApexClassId = :classesId[0].id AND Status != 'Completed' AND Status != 'Aborted' ORDER BY CreatedDate DESC];
        if(jobs!=null&&!jobs.isEmpty()){
            for(AsyncApexJob job:jobs){
                //Abort that Job
                String jobId = job.id;
                System.abortJob(jobId.substring(0, 15));
            }
        }
    }
}