/**
* @author Andres Canavesi
* @date 2016-12
* @description 
*/
public class ATFTestUtils {

    
    public static final Integer MAX_COUNT = 9999;
    
    public static Integer randomInteger(){
        return integer.ValueOf(Math.rint(Math.random() * 100000));
    }
    
    /**
    * @return a contact inserted in DB with a random last name
    */
    public static Contact createContact(){
        
        Contact contact=new Contact();
        if (Schema.sObjectType.Contact.fields.LastName.isCreateable()
            && Schema.sObjectType.Contact.fields.LastName.isUpdateable ()) {
                contact.LastName = UserInfo.getFirstName()+randomInteger();
                insert contact;  }
        return contact;
    }  
    
    public static NAMConfig__c  createNAMConfig(){
        NAMConfig__c config = new NAMConfig__c();
        if (Schema.sObjectType.NAMConfig__c.fields.Name.isCreateable()
            && Schema.sObjectType.NAMConfig__c.fields.Name.isUpdateable ()
            && Schema.sObjectType.NAMConfig__c.fields.Value__c .isCreateable()
            && Schema.sObjectType.NAMConfig__c.fields.Value__c .isUpdateable ()) {
                config.Name = UserInfo.getFirstName()+randomInteger();
                config.Value__c = UserInfo.getFirstName()+randomInteger();
                insert config;  }
        return config;
    } 
    
    public static NAMAttachmentConversionStatus__c   createNAMAttachmentConversionStatus(){
        NAMAttachmentConversionStatus__c conStatus = new NAMAttachmentConversionStatus__c();
        if (Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Name.isCreateable()
            && Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Name.isUpdateable ()) {
                conStatus.Name = UserInfo.getFirstName()+randomInteger();
                insert conStatus;  }
        return conStatus;
    } 
    
    public static Account createAccount(){
        Account account = new Account();
        if (Schema.sObjectType.Account.fields.Name.isCreateable()
            && Schema.sObjectType.Account.fields.Name.isUpdateable ()) {
                account.Name = UserInfo.getFirstName()+randomInteger();
                insert account; }
        return account;
    }
    
    public static void createAttachmentForNAMConfig(Integer count, Boolean createPrivateAttachments, String attachmentName){
        NAMConfig__c config = createNAMConfig();
        Id parentId = config.Id;  
        createAttachmentForObject(count, parentId, createPrivateAttachments, attachmentName);
    }  
    
    public static void createAttachmentForContact(Integer count, Boolean createPrivateAttachments, String attachmentName){
        Contact contact = createContact();
        Id parentId = contact.Id;  
        createAttachmentForObject(count, parentId, createPrivateAttachments, attachmentName);
    }   
    
    public static List<Attachment> createAttachmentForObjectCreatedDate(Integer count, Id parentId, Boolean createPrivateAttachments, Integer attachmentsCreatedDate){
        List<Attachment> attachments = new List<Attachment>();
        if (Schema.sObjectType.Attachment.fields.Name.isCreateable()
            && Schema.sObjectType.Attachment.fields.Description.isCreateable()
            && Schema.sObjectType.Attachment.fields.body.isCreateable()
            && Schema.sObjectType.Attachment.fields.parentId.isCreateable()
            && Schema.sObjectType.Attachment.fields.createdDate.isCreateable()
            && Schema.sObjectType.Attachment.fields.lastModifiedDate.isCreateable()
            && Schema.sObjectType.Attachment.fields.IsPrivate.isCreateable()) {
                System.debug('Creating '+count+' attachments');
                Datetime createdDate = Date.today();
                createdDate = createdDate.addDays(- attachmentsCreatedDate+1);
                for(Integer i = 0; i<count ; i++){
                    String attachmentName = 'att_'+randomInteger();
                    Attachment attachment=new Attachment(); 
                    attachment.Name=attachmentName;
                    attachment.Description = attachmentName;
                    String body = '';
                    for(Integer j=0; j<100; j++){
                        body+='random body '+randomInteger();
                    }
                    Blob bodyBlob=Blob.valueOf(body);
                    attachment.body=bodyBlob;
                    attachment.parentId=parentId;
                    attachment.IsPrivate = createPrivateAttachments;
                    if(attachmentsCreatedDate > 0){
                        attachment.createdDate = createdDate;
                        attachment.lastModifiedDate = createdDate;
                    }
                    attachments.add(attachment);
                }
                
                insert attachments;
            }
        
        return attachments;
    }
    
    
    
    public static List<Attachment> createAttachmentForObject(Integer count, Id parentId, Boolean createPrivateAttachments, String attachmentName){
        System.debug('Creating '+count+' attachments');
        List<Attachment> attachments = new List<Attachment>();
        if (Schema.sObjectType.Attachment.fields.Name.isCreateable()
            && Schema.sObjectType.Attachment.fields.Description.isCreateable()
            && Schema.sObjectType.Attachment.fields.body.isCreateable()
            && Schema.sObjectType.Attachment.fields.parentId.isCreateable()
            && Schema.sObjectType.Attachment.fields.IsPrivate.isCreateable()) {
                for(Integer i = 0; i<count ; i++){
                    Attachment attachment=new Attachment(); 
                    attachment.Name=attachmentName;
                    attachment.Description = attachmentName;           
                    String body = '';
                    for(Integer j=0; j<10; j++){
                        body+='random body '+randomInteger();
                    }
                    Blob bodyBlob=Blob.valueOf(body);                  
                    attachment.body=bodyBlob;
                    attachment.parentId=parentId; 
                    attachment.IsPrivate = createPrivateAttachments;
                    attachments.add(attachment);
                }
                
                insert(attachments);
                
                /*Database.SaveResult[] srList = Database.insert(attachments);
                
                for (Database.SaveResult sr : srList) {
					if (sr.isSuccess()) {
                        System.debug('Successfully inserted attachment');
                    } else {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('Error! ' + err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }*/
            }
        return attachments;
    }
    
    //sleeps the main thread for X seconds
    public static void sleep(Integer seconds){
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 1000 * seconds) {
            finishTime = DateTime.now().getTime();
        }
    } 
    
    public static Integer countAllAttachments(){
        List<Attachment> listOfAttachments = [SELECT name from Attachment LIMIT 1000];
        return listOfAttachments.size();
    }
    
}