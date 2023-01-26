/**
* @author 
*/
public class NAMMigrationResults {
    
    public enum StatusEnum {SUCCESS, ERROR}
    
    public String OldId {get; set;}
    public String NewId {get; set;}
    public String IsPrivate {get; set;}
    //possible values: SUCCESS or ERROR
    public StatusEnum Status {get; set;}
    public String ErrorMessage {get; set;}
    
    public NAMMigrationResults(String oldId, String newId, String isPrivate, StatusEnum status, String errorMessage)
    {
        this.OldId = oldId;
        this.NewId = newId;
        this.IsPrivate = isPrivate;
        this.Status = status;
        this.ErrorMessage = errorMessage;
    }
    
    
}