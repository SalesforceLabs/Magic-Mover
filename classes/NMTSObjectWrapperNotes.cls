/**
 * @author Andres Canavesi
 * @description Wrapper to give extra functionality to the UI, in particular for massive selection
 */

public class NMTSObjectWrapperNotes {
    public String objectName { get; set; }
    public Boolean selected { get; set; }
    public Integer quantity { get; set; }
    
    
    public NMTSObjectWrapperNotes(AggregateResult ar, Integer unmigrated) {
        selected = false;
        quantity = unmigrated;
        objectName = (String) ar.get('ObjectName');
    }
    
    
}