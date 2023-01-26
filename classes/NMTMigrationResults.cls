/**
* @author Dayana Daniel
*/

public class NMTMigrationResults {
    
    public enum StatusEnum {SUCCESS, ERROR}
    
    public String LegacyNoteId {get; set;}
    public String ContentNoteId {get; set;}
    //possible values: SUCCESS or ERROR
    public StatusEnum Status {get; set;}
    public String ErrorMessage {get; set;}
    
    public NMTMigrationResults(String legacyNoteId, String contentNoteId, StatusEnum status, String errorMessage)
    {
        this.LegacyNoteId = legacyNoteId;
        this.ContentNoteId = contentNoteId;
        this.Status = status;
        this.ErrorMessage = errorMessage;
    }
    
    
}