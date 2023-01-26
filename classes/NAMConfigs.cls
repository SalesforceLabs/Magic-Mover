/**
* @description
* @author Andres Canavesi
* @date 2017-11-03
* edited ateppo 4/15/2020
*/
public class NAMConfigs {
    
    /**
* @description 
* @param configName
* @return the config by Its configName or null if it doesn't exist
*/
    private static NAMConfig__c getConfig(String configName){
        List<NAMConfig__c> configs = new List<NAMConfig__c>();
        if (Schema.sObjectType.NAMConfig__c.fields.Value__c.isAccessible()) {
            configs = [SELECT Value__c FROM NAMConfig__c WHERE Name = :configName LIMIT 1];
        }
        if(configs.size() == 0){
            return null;
        }else{
            return configs.get(0);            
        }
        
    }
    
    /**
* @description
* @return the number of attachments or notes to migrate by day. If the config does not exist, returns a default value
*/
    public static Integer getSchedulerSize(){
        NAMConfig__c config =  NAMConfigs.getConfig('SchedulerSize');
        if(config == null){
            return 10;
        }
        return Integer.valueOf(config.Value__c);
    }
    
    /**
* @description
* @return timeout attachment value
*/
    public static Integer getTimeoutAttachmentSize(){
        NAMConfig__c config =  NAMConfigs.getConfig('TimeoutAttachmentSize');
        if(config == null){
            return 12000;
        }
        return Integer.valueOf(config.Value__c);
    }
    
     /**
* @description
* @return timeout note value
*/
    public static Integer getTimeoutNoteSize(){
        NAMConfig__c config =  NAMConfigs.getConfig('TimeoutNoteSize');
        if(config == null){
            return 30000;
        }
        return Integer.valueOf(config.Value__c);
    }
    
    
    /**
* @description
* @return the batch size for Attachments migrator tool. If the config does not exist, returns a default value
*/
    public static Integer getBatchSizeForAttachments(){
        NAMConfig__c config =  NAMConfigs.getConfig('BatchSizeAttachments');
        if(config == null){
            return 100;
        }
        return Integer.valueOf(config.Value__c);
    }
    
    /**
* @description
* @return the BodyLength for Attachments migrator tool to query. If the config does not exist, returns a default value
*/
    public static Integer getBodyLength(){
        NAMConfig__c config =  NAMConfigs.getConfig('BodyLength');
        if(config == null){
            return 1;
        }
        return Integer.valueOf(config.Value__c);
    }
    
    /**
* @description
* @return the Id for Attachments owner on the new file/new note create when users are converting.
*/
    public static String getOwner(){
        NAMConfig__c config =  NAMConfigs.getConfig('Owner');
        if(config == null){
            return UserInfo.getUserId();
        }
        return String.valueOf(config.Value__c);
    }
    
    /**
* @description
* @return the Id or start of Id for Attachments owner on the new file/new note that will change for OwnerTo config.
*/
    public static String getOwnerFrom(){
        NAMConfig__c config =  NAMConfigs.getConfig('OwnerFrom');
        if(config == null){
            return '035';
        }
        return String.valueOf(config.Value__c);
    }
    
    /**
* @description
* @return the Id that will set for new file/new note owners on Attachments that start or is from OwnerFrom config.
*/
    public static String getOwnerTo(){
        NAMConfig__c config =  NAMConfigs.getConfig('OwnerTo');
        if(config == null){
            return UserInfo.getUserId();
        }
        return String.valueOf(config.Value__c);
    }
    
    
    /**
* @description
* @return the dinamic batch size for Attachments migrator tool (to rerun the batch if cpu limit). If the config does not exist, returns a default value
*/
    public static Integer getDinamicBatchSizeForAttachments(){
        NAMConfig__c config =  NAMConfigs.getConfig('DinamicBatchSizeAttachments');
        if(config == null){
            return 100;
        }
        return Integer.valueOf(config.Value__c);
    }
    
    /**
* @description
* @return the batch size for Notes migrator tool. If the config does not exist, returns a default value
*/
    public static Integer getBatchSizeForNotes(){
        NAMConfig__c config =  NAMConfigs.getConfig('BatchSizeNotes');
        if(config == null){
            return 200;
        }
        return Integer.valueOf(config.Value__c);
    }
    
    /**
* @description
* @return true if the tool should enable dynamic batch sizing, false in other cases.
*/
    public static Boolean getEnableDynamicBatchSize(){
        NAMConfig__c config =  NAMConfigs.getConfig('EnableDynamicBatchSize');
        if(config == null){
            return false;
        }
        return Boolean.valueOf(config.Value__c);
    }
    
    /**
* @description
* @return true if you wanna set an especific Scheduler Size, 
* false if you dont only will happen if you reach limit creation error.
*/
    public static Boolean getEnableScheduler(){
        NAMConfig__c config =  NAMConfigs.getConfig('EnableScheduler');
        if(config == null){
            return false;
        }
        return Boolean.valueOf(config.Value__c);
    }
    
    /**
* @description
* @return true if you wanna set an especific timeout attachment Size
*/
    public static Boolean getEnableTimeoutAttachment(){
        NAMConfig__c config =  NAMConfigs.getConfig('EnableTimeoutAttachment');
        if(config == null){
            return false;
        }
        return Boolean.valueOf(config.Value__c);
    }
    
    /**
* @description
* @return true if you wanna set an especific timeout note Size
*/
    public static Boolean getEnableTimeoutNote(){
        NAMConfig__c config =  NAMConfigs.getConfig('EnableTimeoutNote');
        if(config == null){
            return false;
        }
        return Boolean.valueOf(config.Value__c);
    }
    
    
    /**
* @description
* @return true if the tool should enable Owner when converting Attachments/Notes.
*/
    public static Boolean getEnableOwner(){
        NAMConfig__c config =  NAMConfigs.getConfig('EnableOwner');
        if(config == null){
            return false;
        }
        
        return Boolean.valueOf(config.Value__c);
    }
    
    /**
* @description
* @return true if the tool should enable OwnerFrom & OwnerTo setting when converting Attachments/Notes.
*/
    public static Boolean getEnableOwnerFromTo(){
        NAMConfig__c config =  NAMConfigs.getConfig('EnableOwnerFromTo');
        if(config == null){
            return false;
        }
        
        return Boolean.valueOf(config.Value__c);
    }
    
    
    
    
    /**
* @description
* @return true if the tool should enable BodyLength when query Attachments false in other cases.
*/
    public static Boolean getEnableBodyLength(){
        NAMConfig__c config =  NAMConfigs.getConfig('EnableBodyLength');
        if(config == null){
            return false;
        }
        
        return Boolean.valueOf(config.Value__c);
    }
    
    /**
* @description
* @return true if the tool has synchronized the old data.
*/
    public static Boolean getDataSynchronized(){
        NAMConfig__c config =  NAMConfigs.getConfig('DataSynchronized');
        if(config == null){
            return false;
        }
        
        return Boolean.valueOf(config.Value__c);
    }
    
    /**
* @description
* @return true if the tool is synchronizing the old data.
*/
    public static Boolean getDataSynchronizing(){
        NAMConfig__c config =  NAMConfigs.getConfig('DataSynchronizing');
        if(config == null){
            return false;
        }
        
        return Boolean.valueOf(config.Value__c);
    }
    
    
    /**
* @description
* @return min batch size that the tool will reach in dynamic batch size mode.
*/
    public static Integer getMinBatchSize(){
        NAMConfig__c config =  NAMConfigs.getConfig('MinBatchSize');
        if(config == null){
            return 1;
        }
        return Integer.valueOf(config.Value__c);
    }
    
    /**
* @description
* @return metadata pagination size.
*/
    public static Integer getMetadataPageSize(){
        NAMConfig__c config =  NAMConfigs.getConfig('MetadataPageSize');
        if(config == null){
            return 20;
        }
        return Integer.valueOf(config.Value__c);
    }
    
    /**
* @description
* @return 
*/
    public static void setMetadataPageSize(Integer size){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('MetadataPageSize');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'MetadataPageSize';
               }
               config.Value__c = String.valueOf(size);
               upsert config;
           }
    }
    
    /**
* @description
* @param
*/
    public static void setBatchSizeForAttachments(Integer size){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('BatchSizeAttachments');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'BatchSizeAttachments';
               }
               config.Value__c = String.valueOf(size);
               upsert config;
           }
    }
    
    /**
* @description
* @param
*/
    public static void setDinamicBatchSizeForAttachments(Integer size){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('DinamicBatchSizeAttachments');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'DinamicBatchSizeAttachments';
               }
               config.Value__c = String.valueOf(size);
               upsert config;
           }
    }
    
    /**
* @description
* @param
*/
    public static void setSchedulerSize(Integer size){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('SchedulerSize');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'SchedulerSize';
               }
               config.Value__c = String.valueOf(size);
               upsert config;
           }
    }
    
    /**
* @description
* @param
*/
    public static void setTimeoutAttachmentSize(Integer size){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('TimeoutAttachmentSize');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'TimeoutAttachmentSize';
               }
               config.Value__c = String.valueOf(size);
               upsert config;
           }
    }
    
    /**
* @description
* @param
*/
    public static void setTimeoutNoteSize(Integer size){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('TimeoutNoteSize');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'TimeoutNoteSize';
               }
               config.Value__c = String.valueOf(size);
               upsert config;
           }
    }
    
    
    /**
* @description
* @param
*/
    public static void setOwner(String ownerId){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('Owner');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'Owner';
               }
               config.Value__c = String.valueOf(ownerId);
               upsert config;
           }
    }
    
    /**
* @description
* @param
*/
    public static void setOwnerFrom(String ownerId){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('OwnerFrom');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'OwnerFrom';
               }
               config.Value__c = String.valueOf(ownerId);
               upsert config;
           }
    }
    
    /**
* @description
* @param
*/
    public static void setOwnerTo(String ownerId){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('OwnerTo');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'OwnerTo';
               }
               config.Value__c = String.valueOf(ownerId);
               upsert config;
           }
    }
    
    
    
    /**
* @description
* @param
*/
    public static void setBodyLength(Integer size){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('BodyLength');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'BodyLength';
               }
               config.Value__c = String.valueOf(size);
               upsert config;
           }
    }
    
    /**
* @description
* @param
*/
    public static void setBatchSizeForNotes(Integer size){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('BatchSizeNotes');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'BatchSizeNotes';
               }
               config.Value__c = String.valueOf(size);
               upsert config;
           }
    }
    
    /**
* @description
* @param
*/
    public static void setEnableScheduler(Boolean value){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('EnableScheduler');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'EnableScheduler';
               }
               config.Value__c = String.valueOf(value);
               upsert config;
           }
    }
    
    /**
* @description
*/
    public static void setDataSynchronized(Boolean value){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('DataSynchronized');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'DataSynchronized';
               }
               config.Value__c = String.valueOf(value);
               upsert config;
           }
    }
    
    /**
* @description
*/
    public static void setDataSynchronizing(Boolean value){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('DataSynchronizing');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'DataSynchronizing';
               }
               config.Value__c = String.valueOf(value);
               upsert config;
           }
    }
    
    /**
* @description
* @param
*/
    public static void setEnableTimeoutAttachment(Boolean value){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('EnableTimeoutAttachment');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'EnableTimeoutAttachment';
               }
               config.Value__c = String.valueOf(value);
               upsert config;
           }
    }
    
    /**
* @description
* @param
*/
    public static void setEnableTimeoutNote(Boolean value){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('EnableTimeoutNote');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'EnableTimeoutNote';
               }
               config.Value__c = String.valueOf(value);
               upsert config;
           }
    }
    
    
    /**
* @description
* @param
*/
    public static void setEnableDynamicBatchSize(Boolean value){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('EnableDynamicBatchSize');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'EnableDynamicBatchSize';
               }
               config.Value__c = String.valueOf(value);
               upsert config;
           }
    }
    
    /**
* @description
* @param
*/
    public static void setEnableBodyLength(Boolean value){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('EnableBodyLength');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'EnableBodyLength';
               }
               config.Value__c = String.valueOf(value);
               upsert config;
           }
    }
    
    /**
* @description
* @param
*/
    public static void setEnableOwner(Boolean value){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('EnableOwner');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'EnableOwner';
               }
               config.Value__c = String.valueOf(value);
               upsert config;
           }
    }
    
     
    /**
* @description
* @param
*/
    public static void setEnableOwnerFromTo(Boolean value){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('EnableOwnerFromTo');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'EnableOwnerFromTo';
               }
               config.Value__c = String.valueOf(value);
               upsert config;
           }
    }
    
    /**
* @description
* @param
*/
    public static void setMinBatchSize(Integer size){
        if(Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isCreateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable()
           &&Schema.sObjectType.NAMConfig__c.fields.Value__c.isUpdateable()){
               NAMConfig__c config =  NAMConfigs.getConfig('MinBatchSize');
               if(config == null){
                   config = new NAMConfig__c();
                   config.Name = 'MinBatchSize';
               }
               config.Value__c = String.valueOf(size);
               upsert config;
           }
    }
}