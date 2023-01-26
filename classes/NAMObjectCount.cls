/**
 * @description
 * @author Andres Canavesi
 * @date 2017-01
 */
public class NAMObjectCount {
    
    /**
    * @description true if there is a batch queued or in progress migrating attachments or notes for this objectName
    */
    public Boolean migrationInProgress { get; set; }
    public String objectName {get; set;}
    public Integer quantity {get; set;}
    /**
    * @description SUM(BodyLength) of Attachment
    */
    public Decimal  totalBytesSize {get; set;}
    public Integer  totalMBSize {get; set;}
    
    
    public NAMObjectCount(AggregateResult ar) {
        quantity = (Integer) ar.get('Quantity');
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
        migrationInProgress = false;       
    }
    
    public NAMObjectCount(AggregateResult ar, String parentType) {
        quantity = (Integer) ar.get('Quantity');
        objectName = parentType;
        totalBytesSize = (Decimal) ar.get('totalBytesSize');
        Decimal totalMBSizeDecimal = (totalBytesSize/1024)/1024;
        totalMBSize = math.round(totalMBSizeDecimal)+1;
        migrationInProgress = false;       
    }
}