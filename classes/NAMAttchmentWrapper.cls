public class NAMAttchmentWrapper {
    
    public String attachmentName { get; set; }
    public Boolean selected { get; set; }
    public Id attachmentId { get; set; }
    public Id parentId { get; set; }
    public String parent { get; set; }
    public String owner { get; set; }
    public Boolean supported { get; set; }
    public Decimal  totalBytesSize {get; set;}
    public Integer  totalMBSize {get; set;}
    public DateTime createDate { get; set; }
    public String showIcon { get; set; }
    public String hideIcon { get; set; }
    
    
    public NAMAttchmentWrapper(Id attachmentId, String attachmentName, Id parentId, String parent, String owner, Decimal totalBytesSize, DateTime createDate, Boolean supported){
        this.attachmentId = attachmentId;
        this.attachmentName = attachmentName;
        this.parent = parent;
        this.parentId = parentId;
        this.owner = owner;  
        this.supported = supported;  
        if(supported){
            this.hideIcon = 'slds-hide';
            this.showIcon =  'slds-icon_container slds-icon-standard-task2';
        } else{
            this.hideIcon = 'slds-icon_container slds-icon-standard-reward';
            this.showIcon = 'slds-hide';
        }
        this.totalBytesSize = totalBytesSize;
        Decimal totalMBSizeDecimal = (totalBytesSize/1024)/1024;
        this.totalMBSize = math.round(totalMBSizeDecimal)+1;
        this.createDate = createDate;
        selected = false;
    }
    
    
}