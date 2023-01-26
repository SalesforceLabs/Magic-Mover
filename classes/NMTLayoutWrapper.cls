/**
* @author Jessica Bernal
*/

public class NMTLayoutWrapper implements Comparable{
    public String name { get; set; }
    public String objectName { get; set; }
    public Boolean selected { get; set; }
    public Boolean notesRelatedList { get; set; }
    public Boolean filesRelatedList { get; set; }
    public String fullName { get; set; }
    
    public NMTLayoutWrapper(String nameLayout, String fullNameLayout, Boolean contentHasRelatedList, Boolean notesRelatedListLayout, Boolean filesRelatedListLayout){
        name = nameLayout;
        selected = contentHasRelatedList;
        fullName = fullNameLayout;
        Integer indexOfForObjectName = fullName.indexOf('-');
        objectName = fullName.substring(0, indexOfForObjectName);
        notesRelatedList = notesRelatedListLayout;
        filesRelatedList = filesRelatedListLayout;
    }
    
    // Implement the compareTo() method
    public Integer compareTo(Object compareTo) {
        NMTLayoutWrapper other = (NMTLayoutWrapper)compareTo;
        return this.name.compareTo(other.name);       
    }
    
    

}