/**
* @author Andres Canavesi 
* edited ateppo 5/5/2020
*/

public class NMTTestNoteUtils {
    
    public static final Integer MAX_COUNT = 9999;
    
    /**
* sleeps the main thread for X seconds
*/
    public static void sleep(Integer seconds){
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 1000 * seconds) {
            finishTime = DateTime.now().getTime();
        }
    } 
    
    public static Integer randomInteger(){
        return integer.ValueOf(Math.rint(Math.random() * 100000));
    }
    
    public static Account createAccount(){
        Account account = new Account();
        account.Name = UserInfo.getFirstName()+randomInteger();
        if (Schema.sObjectType.Account.isCreateable()) {
            insert account;
        }
        return account;
    }
    
    public static Contact createContact(){
        Contact contact=new Contact();
        if (Schema.sObjectType.Contact.fields.LastName.isCreateable()){
            contact.LastName = UserInfo.getFirstName()+randomInteger();
            insert contact; 
        } 
        return contact;
    } 
    
    public static List<Note> createNoteForObject(Integer count, Id parentId, Boolean createPrivateNotes, String noteTitle){
        System.debug('Creating '+count+' notes');
        List<Note> notes = new List<Note>();
        if (Schema.sObjectType.Note.fields.Title.isCreateable()
            && Schema.sObjectType.Note.fields.body.isCreateable()
            && Schema.sObjectType.Note.fields.parentId.isCreateable()
            && Schema.sObjectType.Note.fields.IsPrivate.isCreateable()) {
                for(Integer i = 0; i<count ; i++){
                    Note note=new Note(); 
                    note.Title=noteTitle;
                    String body = '';
                    for(Integer j=0; j<100; j++){
                        body+='random body '+randomInteger();
                    }
                    note.body=body;
                    note.parentId=parentId; 
                    note.IsPrivate = createPrivateNotes;
                    note.OwnerId = UserInfo.getUserId();
                    note.CreatedDate = Date.today();
                    note.LastModifiedDate = Date.today();
                    notes.add(note);
                }
                
                insert notes;
            }
        return notes;
    }
    
    
    public static List<Note> createNoteForObject(Integer count, Id parentId, Boolean createPrivateNotes){
        List<Note> notes = new List<Note>();
        if (Schema.sObjectType.Note.fields.Title.isCreateable()
            && Schema.sObjectType.Note.fields.body.isCreateable()
            && Schema.sObjectType.Note.fields.parentId.isCreateable()
            && Schema.sObjectType.Note.fields.IsPrivate.isCreateable()) {
                System.debug('Creating '+count+' notes');
                
                for(Integer i = 0; i<count ; i++){
                    String noteTitle = 'note_'+randomInteger();
                    Note note=new Note(); 
                    note.Title=noteTitle;
                    String body = '';
                    for(Integer j=0; j<100; j++){
                        body+='random body '+randomInteger();
                    }
                    note.body=body;
                    note.parentId=parentId; 
                    note.IsPrivate = createPrivateNotes;
                    notes.add(note);
                }
                
                insert notes;
            }
        
        return notes;
    }
    
    
    
    
    public static List<ContentVersion> getAllContentVersions(){
        /* SR note: user CRUD/FLS checks not appropriate here */
        return [SELECT Id, Title, LastModifiedDate, OwnerId FROM ContentVersion];
    }
    
    public static List<NAMNoteConverted__c> getAllConvertedNotes(){
        /* SR note: user CRUD/FLS checks not appropriate here */
        return [SELECT Id, LegacyNoteConvertedId__c FROM NAMNoteConverted__c];
    }
    
    
}