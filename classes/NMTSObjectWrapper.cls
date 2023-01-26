/**
 * @description Wrapper to give extra functionality to the UI, in particular for massive selection
 * @author Andres Canavesi
 * @date 2017-01
 */

public class NMTSObjectWrapper {
    public String objectName { get; set; }
    public Boolean selected { get; set; }
    /**
    * @description true if there is a batch queued or in progress migrating attachments or notes for this objectName
    */
    public Boolean migrationInProgress { get; set; }
    public Integer quantityAttachments {get; set;}
    /**
    * @description the user  will be able to specify the quantity of attahcments to migrate
    */
    public Integer attachmentsToMigrate {get; set;}
    /**
    * @description SUM(BodyLength) of Attachment
    */
    public Decimal  totalBytesSize {get; set;}
    public Integer  totalMBSize {get; set;}
    public Integer inputToMigrate {get; set;}
    public Integer quantityAttachmentsLength {get; set;}
    
    public NMTSObjectWrapper(){
        selected = false;
        migrationInProgress = false;
        quantityAttachments = 0;  
        inputToMigrate = 0;        
    }
    
    public NMTSObjectWrapper(AggregateResult ar) {
        this();   
        quantityAttachments = (Integer) ar.get('Quantity');
        if(quantityAttachments > NAMUtils.ORG_LIMIT_MIGRATE){
            attachmentsToMigrate = NAMUtils.ORG_LIMIT_MIGRATE;
        }else{
            attachmentsToMigrate = quantityAttachments;
        }
        objectName = (String) ar.get('ObjectName');
        if(objectName == null || objectName.equals('')){
            
            objectName = NAMUtils.BLANK_PARENT_TYPES;
        }
        if(objectName == '00X'){
            objectName = 'Email Template';
        }
        totalBytesSize = (Decimal) ar.get('totalBytesSize');
        Decimal totalMBSizeDecimal = (totalBytesSize/1024)/1024;
        totalMBSize = math.round(totalMBSizeDecimal)+1;
        quantityAttachmentsLength = String.valueOf(quantityAttachments).length();
    }
    
    public NMTSObjectWrapper(AggregateResult ar, String objectType) {
        this();   
        quantityAttachments = (Integer) ar.get('Quantity');
        if(quantityAttachments > NAMUtils.ORG_LIMIT_MIGRATE){
            attachmentsToMigrate = NAMUtils.ORG_LIMIT_MIGRATE;
        }else{
            attachmentsToMigrate = quantityAttachments;
        }
        objectName = objectType;
        
        totalBytesSize = (Decimal) ar.get('totalBytesSize');
        Decimal totalMBSizeDecimal = (totalBytesSize/1024)/1024;
        totalMBSize = math.round(totalMBSizeDecimal)+1;
        quantityAttachmentsLength = String.valueOf(quantityAttachments).length();
    }
    
    
}