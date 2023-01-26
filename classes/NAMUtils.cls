/**
* @description contains common code for the three tools: attachment converter, notes converter and update page layout
* @author Jessica Bernal, Dayana Daniel, Andres Canavesi
* @date 2017-10
*/

public class NAMUtils {

    public static String DATE_TIME_FORMAT = 'yyyy-MM-dd\'T00:00:00z\'';

    public static String SUCCESS_COMMUNITY_GROUP_URL = 'https://success.salesforce.com/_ui/core/chatter/groups/GroupProfilePage?g=0F93A000000LgpS';

    public static String APP_EXCHANGE_URL = 'https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000EHAmyUAH';

    public static Integer DEFAULT_NOTE_PAGE_SIZE = 100;

    public static Integer DEFAULT_LAST_PAGE_SIZE = 20;

    public static Integer SCHEDULER_TIME = 1440;

    public static Integer DEFAULT_LAST_ATTACHMENTS_PAGE_SIZE = 20;

    public static Integer DEFAULT_CONFIG_PAGE_SIZE = 10;

    /**
* @description timeout in millis to get and count records in given date range if we
* do not use this limit we reach out a query limit
*/
    public static Integer LIMIT_TIME_OUT = NAMConfigs.getTimeoutAttachmentSize();
    
    public static Integer LIMIT_TIME_OUT_NOTE = NAMConfigs.getTimeoutNoteSize();
    
    //TODO I think we do not use this contant, otherwise add a comment
    public static Integer NUMBER_ERRORS = 5;
    /**
* @description to warn users to migrate up to this quantity in order to keep inside Salesforce Content Publication limits
*/
    public static Integer ORG_LIMIT_MIGRATE = 100000;

    public static Integer LIMIT_QUERIES_OBJECTS = 1000;
    public static Integer DEFAULT_PAGE_SIZE = 10;

    /**
* @description After a successful migration, we rename the attachments with the ContentVersion id (the file created).
* All migrated attachments start with this pattern. This way we are able to distinguish the migrated attachments
*/
    public static String MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN = '[068%';

    /**
* @description a list of supported objects. We also include custom objects
* the tool supports. These objects will be added in nexts releases:
* 'Emailmessage', '00X', 'Goal', 'Metric', 'WorkCoaching', 'SocialPost'
*/
    public static String[] PARENT_TYPE_GREENS = new String[] {'Account', 'Asset', 'Campaign', 'Case', 'Contact', 'Contract', 'Lead', 'Opportunity', 'Product2', 'Quote', 'Solution', 'Order',  'ServiceContract', 'Entitlement'};
        /**
* @description Event and Task have a different behavior(they have the parent.type blank in the query)
* so we need to work with them in a different way
*/
        public static String[] OTHER_PARENT_TYPE_GREENS = new String[] {'Event','Task'};

            public static String[] OTHER_PARENT_TYPE_GREENS_PREFIX = new String[] {'00U','00T'};

                /**
* @description a map with Standard Object Record ID Prefix
*/
                public static Map<String,String> STANDARD_OBJECT_PREFIX = new Map<String, String> {'00U' => 'Event', '00T' => 'Task'};

                    /**
* @description enable / disable notes test when enhanced notes are not enabled in the org.
*/
                    public static boolean ENABLE_NOTES_TESTS = true;

    /**
* @description to be able to see what version user has installed on the org
*/
    public static String PACKAGE_VERSION_NAME = 'V4.13';
    /**
* @description error text from Salesforce when we reach out CPU limit.
*/
    public static String APEX_CPU_LIMIT_TEXT = 'Apex CPU time limit exceeded';
    /**
* @description error text from Salesforce when we reach out heap size limit.
*/
    public static String APEX_HEAP_LIMIT_TEXT = 'heap limit';
    /**
* @description error text from Salesforce when there is a Salesforce internal unmanaged error.
* We faced these type of error when we try to migrate special characters
*/
    public static String INTERNAL_ERROR = 'Internal Salesforce.com Error';
    
    public static String CHARACTER_ERROR = 'UNSAFE_HTML_CONTENT';
    /**
* @description SOAP API version
*/
    public static String API_VERSION = '41.0';

    /**
* @description these objects have not parent type in Attachment object (for some strange reason)
*/
    public static String BLANK_PARENT_TYPES = 'Task and Event';

    /**
* @description
* @return a list of all custom objects in the org
*/

    public static String[] getCustomObject(){

        String[]  stdObjectNames = new String[]{};
            for ( Schema.SObjectType typ : Schema.getGlobalDescribe().values() ) {
                if (typ.getDescribe().isCustom() && !String.valueOf(typ).containsIgnoreCase('NAMAttachmentConversionStatus')
                    && !String.valueOf(typ).containsIgnoreCase('NAMConfig')
                    && !String.valueOf(typ).containsIgnoreCase('NAMNoteConversionStatus')) {
                        stdObjectNames.add(String.valueOf(typ));
                    }
            }
        system.debug('stdObjectNames:');
        system.debug(stdObjectNames);
        return stdObjectNames;
    }

    /**
* TODO move this method to MetadataController
* @desccription TODO
* @return true if... TODO
*/
    public static Boolean countLayouts(Integer limitQuery,Integer Offset, String query){
        Boolean moreLayouts = false;
        if (Test.isRunningTest()) {
            //We can't do callout during testing, so we mock them
            Test.setMock(HTTPCalloutMock.class, new NMTRetrieveMetadataMock());
        }
        HttpRequest req=new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('content-Type','application/json');

        String requestUrl = query+'LIMIT+'+limitQuery+'+OFFSET+'+Offset;
        req.setEndpoint(requestUrl);

        req.setMethod('GET');
        Http h=new Http();
        HttpResponse res=h.send(req);
        if(res.getStatusCode()==200){
            moreLayouts = newPageLayouts(res.getBody());
        }
        return moreLayouts;
    }

    /**
*
* @desccription TODO
* @return true if... TODO
*/
    public static Boolean isPendingNotesToBeConverted(){
        Boolean pendingNotes = false;
        List<NMTSObjectWrapperNotes> quantities = new List<NMTSObjectWrapperNotes>();
        List<NMTSObjectWrapperNotes> migratedquantities = new List<NMTSObjectWrapperNotes>();
        List<List<NMTSObjectWrapperNotes>> notesresults = new List<List<NMTSObjectWrapperNotes>>();
        // String[] customobjects = getCustomObject();
        /* Updated 4/21/2021 for security re-review */
		if (Schema.sObjectType.Note.isAccessible()) {
        	for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Title) Quantity
                                        FROM Note
                                        GROUP BY Parent.Type
                                        ORDER BY Parent.Type ASC
                                        LIMIT :LIMIT_QUERIES_OBJECTS]){
                                            for (AggregateResult ar : results) {
                                                Integer migrated = countPublicNotesMigratedPerObjectMetadata((String)ar.get('ObjectName'));
                                                Integer unmigrated = (Integer)ar.get('Quantity')-migrated;
                                                if(unmigrated>0){
                                                    return true;
                                                }
                                            }

                                        }
        }
        return pendingNotes;
    }

    /**
*  TODO move this method to MetadataController
* @desccription TODO
* @return true if... TODO
*/
    public static Boolean newPageLayouts(String jsonStr){
        List<String> layoutsNameAux = new List<String>();
        NMTMetadataLayout.Layout2 r = NMTMetadataLayout.parse(jsonStr);
        List<NMTMetadataLayout.Records> records = r.records;
        List<String> results = new List<String>();
        for(NMTMetadataLayout.Records record: records){
            String text = '';
            String tempText = record.EntityDefinitionId;
            // First, instantiate a new Pattern object "MyPattern"
            Pattern MyPattern = Pattern.compile('([a-zA-Z0-9]{18}?|[a-zA-Z0-9]{15}?)');

            // Then instantiate a new Matcher object "MyMatcher"
            Matcher MyMatcher = MyPattern.matcher(tempText);

            if(MyMatcher.matches()&& record.EntityDefinition!=null){
                layoutsNameAux.add(record.EntityDefinition.DeveloperName+'__c');
            }
            else{
                layoutsNameAux.add(tempText);
            }
        }
        return layoutsNameAux.size() > 0;
    }
    /**
* @description
* @param theLimit this value wil be 100 always because the pagination is complicated
* The first query that we paginate is over Legacy Notes, converted or not
* @param theOffset
* @param startdate
* @param endDate
* @param byCreateDate false we want to count public notes by LastModifiedDate
* @return
*/
    public static List<List<NMTSObjectWrapperNotes>> countPublicNotesPerObject(Integer theLimit,
                                                                               Integer theOffset,
                                                                               Date startdate,
                                                                               Date endDate,
                                                                               Boolean byCreateDate, String objectSelected){
                                                                                   List<NMTSObjectWrapperNotes> quantities = new List<NMTSObjectWrapperNotes>();
                                                                                   List<NMTSObjectWrapperNotes> migratedquantities = new List<NMTSObjectWrapperNotes>();
                                                                                   List<List<NMTSObjectWrapperNotes>> notesresults = new List<List<NMTSObjectWrapperNotes>>();
                                                                                   Time firstTime = Time.newInstance(0, 0, 0, 0);
                                                                                   Time endTime = Time.newInstance(23, 59, 59, 0);
                                                                                   DateTime dtstart = DateTime.newInstance(startDate,firstTime);
                                                                                   DateTime dtend = DateTime.newInstance(endDate,endTime);

                                                                                   if(!objectSelected.equalsIgnoreCase('All')){

                                                                                       if(byCreateDate){
                                                                                           /* Updated 4/21/2021 for security re-review */
																							if (Schema.sObjectType.Note.isAccessible()) {
                                                                                           		for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Title) Quantity
                                                                                                                           FROM Note
                                                                                                                           WHERE createdDate >= :dtstart
                                                                                                                           AND createdDate <= :dtend
                                                                                                                           AND Parent.Type = :objectSelected
                                                                                                                           GROUP BY Parent.Type
                                                                                                                           ORDER BY Parent.Type ASC
                                                                                                                           LIMIT :theLimit
                                                                                                                           OFFSET :theOffset]){

                                                                                                                               for (AggregateResult ar : results) {
                                                                                                                                   Integer migrated = countPublicNotesMigratedPerObject((String)ar.get('ObjectName'), dtstart, dtend, byCreateDate);
                                                                                                                                   if(migrated==null){
                                                                                                                                       migrated = 0;
                                                                                                                                   }
                                                                                                                                   Integer unmigrated = (Integer)ar.get('Quantity')-migrated;
                                                                                                                                   if(unmigrated>0){
                                                                                                                                       quantities.add(new NMTSObjectWrapperNotes(ar, unmigrated));
                                                                                                                                   }
                                                                                                                                   if(migrated>0){
                                                                                                                                       migratedquantities.add(new NMTSObjectWrapperNotes(ar, migrated));
                                                                                                                                   }
                                                                                                                               }
                                                                                                                           }
                                                                                            }
                                                                                       } else {
                                                                                           for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Title) Quantity
                                                                                                                           FROM Note
                                                                                                                           WHERE lastModifiedDate >= :dtstart
                                                                                                                           AND lastModifiedDate <= :dtend
                                                                                                                           AND Parent.Type = :objectSelected
                                                                                                                           GROUP BY Parent.Type
                                                                                                                           ORDER BY Parent.Type ASC
                                                                                                                           LIMIT :theLimit
                                                                                                                           OFFSET :theOffset]){

                                                                                                                               for (AggregateResult ar : results) {
                                                                                                                                   Integer migrated = countPublicNotesMigratedPerObject((String)ar.get('ObjectName'), dtstart, dtend, byCreateDate);
                                                                                                                                   if(migrated==null){
                                                                                                                                       migrated = 0;
                                                                                                                                   }
                                                                                                                                   Integer unmigrated = (Integer)ar.get('Quantity')-migrated;
                                                                                                                                   if(unmigrated>0){
                                                                                                                                       quantities.add(new NMTSObjectWrapperNotes(ar, unmigrated));
                                                                                                                                   }
                                                                                                                                   if(migrated>0){
                                                                                                                                       migratedquantities.add(new NMTSObjectWrapperNotes(ar, migrated));
                                                                                                                                   }
                                                                                                                               }
                                                                                                                           }
                                                                                       }


                                                                                   } else {

                                                                                       if(byCreateDate){
                                                                                           /* Updated 4/21/2021 for security re-review */
																							if (Schema.sObjectType.Note.isAccessible()) {
                                                                                           		for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Title) Quantity
                                                                                                                           FROM Note
                                                                                                                           WHERE createdDate >= :dtstart
                                                                                                                           AND createdDate <= :dtend
                                                                                                                           GROUP BY Parent.Type
                                                                                                                           ORDER BY Parent.Type ASC
                                                                                                                           LIMIT :theLimit
                                                                                                                           OFFSET :theOffset]){

                                                                                                                               for (AggregateResult ar : results) {
                                                                                                                                   Integer migrated = countPublicNotesMigratedPerObject((String)ar.get('ObjectName'), dtstart, dtend, byCreateDate);
                                                                                                                                   if(migrated==null){
                                                                                                                                       migrated = 0;
                                                                                                                                   }
                                                                                                                                   Integer unmigrated = (Integer)ar.get('Quantity')-migrated;
                                                                                                                                   if(unmigrated>0){
                                                                                                                                       quantities.add(new NMTSObjectWrapperNotes(ar, unmigrated));
                                                                                                                                   }
                                                                                                                                   if(migrated>0){
                                                                                                                                       migratedquantities.add(new NMTSObjectWrapperNotes(ar, migrated));
                                                                                                                                   }
                                                                                                                               }
                                                                                                                           }
                                                                                            }
                                                                                       } else {
                                                                                           /* Updated 4/21/2021 for security re-review */
																							if (Schema.sObjectType.Note.isAccessible()) {
                                                                                           		for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Title) Quantity
                                                                                                                           FROM Note
                                                                                                                           WHERE lastModifiedDate >= :dtstart
                                                                                                                           AND lastModifiedDate <= :dtend
                                                                                                                           GROUP BY Parent.Type
                                                                                                                           ORDER BY Parent.Type ASC
                                                                                                                           LIMIT :theLimit
                                                                                                                           OFFSET :theOffset]){

                                                                                                                               for (AggregateResult ar : results) {
                                                                                                                                   Integer migrated = countPublicNotesMigratedPerObject((String)ar.get('ObjectName'), dtstart, dtend, byCreateDate);
                                                                                                                                   if(migrated==null){
                                                                                                                                       migrated = 0;
                                                                                                                                   }
                                                                                                                                   Integer unmigrated = (Integer)ar.get('Quantity')-migrated;
                                                                                                                                   if(unmigrated>0){
                                                                                                                                       quantities.add(new NMTSObjectWrapperNotes(ar, unmigrated));
                                                                                                                                   }
                                                                                                                                   if(migrated>0){
                                                                                                                                       migratedquantities.add(new NMTSObjectWrapperNotes(ar, migrated));
                                                                                                                                   }
                                                                                                                               }
                                                                                                                           }
                                                                                            }
                                                                                       }


                                                                                   }
                                                                                   notesresults.add(quantities);
                                                                                   notesresults.add(migratedquantities);
                                                                                   return notesresults;
                                                                               }

    /**
* @description
* @return
*/
    public static Integer countPublicNotesMigratedPerObjectMetadata(String ObjectName){
        //This is because of a null pointer exception that we can't reproduce.
        //I think that it could be because a note's parent.type is null.
        Integer count = 0;
        if(ObjectName!=null){
            if(ObjectName.equalsIgnoreCase('Contact') || ObjectName.equalsIgnoreCase('Account')){
                String query = 'SELECT count() from NAMNoteConverted__c where LegacyNoteConvertedParentId__c Like \'003%\'';
                String query2 = 'SELECT count() from NAMNoteConverted__c where LegacyNoteConvertedParentId__c Like \'001%\'';
                count = database.countQuery(query);
                count += database.countQuery(query2);

            } else{
                // Convert to schema.sObjectType
                Schema.SObjectType convertType = Schema.getGlobalDescribe().get(ObjectName);
                String query = 'SELECT count() from NAMNoteConverted__c where LegacyNoteConvertedParentId__c Like \'';
                query+=convertType.getDescribe().getKeyPrefix();
                query+='%\'';
                count = database.countQuery(query);
            }
            return count;
        }
        return 0;
    }

    /**
* @description  the same by date
*/
    public static Integer countPublicNotesMigratedPerObject(String ObjectName, DateTime startDate, DateTime endDate, Boolean byCreateDate){
        //This is because of a null pointer exception that we can't reproduce.
        //I think that it could be because a note's parent.type is null.

        Boolean isPersonAccountsEnabled = personAccountsEnabled();
        if(ObjectName!=null){
            String startMonth = String.valueOf(startDate.month());
            if(startMonth.length()==1){
                startMonth = '0'+startMonth;
            }

            String startDay = String.valueOf(startDate.day());
            if(startDay.length()==1){
                startDay = '0'+startDay;
            }

            String endMonth = String.valueOf(endDate.month());
            if(endMonth.length()==1){
                endMonth = '0'+endMonth;
            }

            String endDay = String.valueOf(endDate.day());
            if(endDay.length()==1){
                endDay = '0'+endDay;
            }
            String sstart = startDate.year()+'-'+startMonth+'-'+startDay;
            String send = endDate.year()+'-'+endMonth+'-'+endDay;
            System.debug('send:'+send);
            integer count = 0;
            if(isPersonAccountsEnabled && (ObjectName.equalsIgnoreCase('Contact') || ObjectName.equalsIgnoreCase('Account'))){
                /* Updated 4/21/2021 for security re-review */
				if (Schema.sObjectType.NAMNoteConverted__c.isAccessible()) {
                    String query = 'SELECT count() from NAMNoteConverted__c where LegacyNoteConvertedParentId__c Like \'003%\'';
                    if(byCreateDate){
                        query+=' And LegacyNoteConvertedDate__c >= ';
                        query+=sstart;
                        query+=' and LegacyNoteConvertedDate__c <= ';
                        query+=send;
                        query+=' ';
    
                    } else {
                        query+=' And LegacyNoteConvertedLastModifiedDate__c  >= ';
                        query+=sstart;
                        query+=' and LegacyNoteConvertedLastModifiedDate__c  <= ';
                        query+=send;
                        query+=' ';
                    }
                    system.debug('query countPublicNotesMigratedPerObject:');
                    system.debug(query);
                    count= database.countQuery(query);
    
                    String query2 = 'SELECT count() from NAMNoteConverted__c where LegacyNoteConvertedParentId__c Like \'001%\'';
                    if(byCreateDate){
                        query2+=' And LegacyNoteConvertedDate__c >= ';
                        query2+=sstart;
                        query2+=' and LegacyNoteConvertedDate__c <= ';
                        query2+=send;
                        query2+=' ';
    
                    } else {
                        query2+=' And LegacyNoteConvertedLastModifiedDate__c  >= ';
                        query2+=sstart;
                        query2+=' and LegacyNoteConvertedLastModifiedDate__c  <= ';
                        query2+=send;
                        query2+=' ';
                    }
                    system.debug('query2 countPublicNotesMigratedPerObject:');
                    system.debug(query2);
                    count += database.countQuery(query2);
                }
            } else{

                // Convert to schema.sObjectType
                Schema.SObjectType convertType = Schema.getGlobalDescribe().get(ObjectName);
                String query = 'SELECT count() from NAMNoteConverted__c where LegacyNoteConvertedParentId__c Like \'';
                query+=convertType.getDescribe().getKeyPrefix();
                query+='%\'';
                if(byCreateDate){
                    query+=' And LegacyNoteConvertedDate__c >= ';
                    query+=sstart;
                    query+=' and LegacyNoteConvertedDate__c <= ';
                    query+=send;
                    query+=' ';

                } else {
                    query+=' And LegacyNoteConvertedLastModifiedDate__c  >= ';
                    query+=sstart;
                    query+=' and LegacyNoteConvertedLastModifiedDate__c  <= ';
                    query+=send;
                    query+=' ';
                }
                system.debug('query countPublicNotesMigratedPerObject:');
                system.debug(query);
                count= database.countQuery(query);

            }
            return count;
        }
        return 0;
    }

    /**
* @description
* @throws NAMForbiddenException if the user has not enough permissions on objects and fields we need during conversion
*/
    public static void validatePermissions(){
        Id userProfileId = UserInfo.getProfileId();
        /* SR note: user CRUD/FLS checks not appropriate here since this method purpose is checking user perms */
        List<Profile> profilePermissionsModifyAllData = [SELECt id, PermissionsModifyAllData
                                                         FROM Profile
                                                         WHERE id = :userProfileId limit 1];
        if(profilePermissionsModifyAllData.size() ==0 ||!profilePermissionsModifyAllData.get(0).PermissionsModifyAllData){
            System.debug('You don\'t have permission \'Modify All Data\'. Ask your Salesforce admin for help.');
            throw new NAMForbiddenException('You don\'t have permission \'Modify All Data\'. Ask your Salesforce admin for help.');
        }
        if(!Schema.sObjectType.ContentVersion.fields.CreatedDate.isCreateable()
           ||!Schema.sObjectType.ContentVersion.fields.CreatedById.isCreateable()
           || !Schema.sObjectType.ContentVersion.fields.LegacyNoteConvertedId__c.isUpdateable()){
               System.debug('You don\'t have permission to access these fields on ContentVersion. Ask your Salesforce admin for help.');
               throw new NAMForbiddenException('You don\'t have permission to access these fields on ContentVersion. Ask your Salesforce admin for help.');
           }
        if(!Schema.sObjectType.NAMNoteConversionStatus__c.fields.Status__c.isCreateable()
           || !Schema.sObjectType.NAMNoteConversionStatus__c.fields.Status__c.isUpdateable()
           || !Schema.sObjectType.NAMNoteConversionStatus__c.isDeletable()
           || !Schema.sObjectType.NAMNoteConversionStatus__c.fields.JobId__c.isCreateable()
           || !Schema.sObjectType.NAMNoteConversionStatus__c.fields.JobId__c.isUpdateable()
           || !Schema.sObjectType.NAMNoteConversionStatus__c.fields.Type__c.isCreateable()
           || !Schema.sObjectType.NAMNoteConversionStatus__c.fields.Type__c.isUpdateable() ){
               System.debug('You don\'t have permission to access these fields on NAMNoteConversionStatus__c. Ask your Salesforce admin for help.');
               throw new NAMForbiddenException('You don\'t have permission to access these fields on NAMNoteConversionStatus__c. Ask your Salesforce admin for help.');

           }
        if(!Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.ObjectName__c.isCreateable()
           || !Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.ObjectName__c.isUpdateable()
           || !Schema.sObjectType.NAMAttachmentConversionStatus__c.isDeletable()
           || !Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.JobId__c.isCreateable()
           || !Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.JobId__c.isUpdateable()
           || !Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Type__c.isCreateable()
           || !Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Type__c.isUpdateable()
           || !Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.RecordId__c.isCreateable()
           || !Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.RecordId__c.isUpdateable()
           || !Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Quantity__c.isCreateable()
           || !Schema.sObjectType.NAMAttachmentConversionStatus__c.fields.Quantity__c.isUpdateable() ){
               System.debug('You don\'t have permission to access these fields on NAMAttachmentConversionStatus__c. Ask your Salesforce admin for help.');
               throw new NAMForbiddenException('You don\'t have permission to access these fields on NAMAttachmentConversionStatus__c. Ask your Salesforce admin for help.');

           }
        if(!Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isCreateable()
           || !Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable()
           || !Schema.sObjectType.ContentDocumentLink.fields.ShareType.isCreateable()
           || !Schema.sObjectType.ContentDocumentLink.fields.ShareType.isUpdateable()){
               System.debug('You don\'t have permission to access these fields on ContentDocumentLink. Ask your Salesforce admin for help.');
               throw new NAMForbiddenException('You don\'t have permission to access these fields on ContentDocumentLink. Ask your Salesforce admin for help.');

           }
        if(!Schema.sObjectType.NAMNoteConverted__c.fields.LegacyNoteConvertedId__c.isCreateable()
           || !Schema.sObjectType.NAMNoteConverted__c.fields.LegacyNoteConvertedId__c.isUpdateable()){
               System.debug('You don\'t have permission to access these fields on NAMNoteConverted__c - LegacyNoteConvertedId__c. Ask your Salesforce admin for help.');
               throw new NAMForbiddenException('You don\'t have permission to access these fields on NAMNoteConverted__c - LegacyNoteConvertedId__c. Ask your Salesforce admin for help.');

           }
    }

    /**
* @description
* @param objectIds
* @param mapMigration
* @return TODO... the key represnets... and the value represents...
*/
    public static Map<String,String> validateEnteredObjectIDs(List<Id> objectIds, Map<String,String> mapMigration){
        String idString = '';
        for(Id objectId : objectIds){
            Schema.SObjectType sobjectType = objectId.getSObjectType();
            String sobjectName = sobjectType.getDescribe().getName();
            try{
                SObject record = Database.query('Select Id From ' + sobjectName + ' Where Id = :objectId');
                if(record != null && sobjectName != 'Attachment' && sobjectName != 'Note'){
                    idString= objectId;
                    if(idString.length() == 18){
                        mapMigration.remove(idString.substring(0, 15));
                    }
                    mapMigration.remove(idString);
                }
            } catch(Exception e){
                //TODO we chould even throw a custom exception or remove this try-catch block
                //TODO if we throw an exception the error should contain '...verify you have permissions on :sobjectName'
                system.debug('Exception: ' + e.getMessage());
            }
        }
        return mapMigration;
    }

    /**
* @description
* @return
* @param objectIds
* @param mapMigration
* @param isAttachment
*/
    public static Map<String,String> validateNoRecordsObjectIDs(List<Id> objectIds,
                                                                Map<String,String> mapMigration,
                                                                Boolean isAttachment){
                                                                    String idString = '';
                                                                    if(isAttachment){
                                                                        /* Updated 4/21/2021 for security re-review */
																		if (Schema.sObjectType.Attachment.isAccessible()) {
                                                                            for(Id objectId : objectIds){
                                                                                List<Attachment> valid = [SELECT Id FROM Attachment WHERE ParentId = :objectId LIMIT 1];
                                                                                if(!valid.isEmpty()){
                                                                                    idString= objectId;
                                                                                    if(idString.length() == 18){
                                                                                        mapMigration.remove(idString.substring(0, 15));
                                                                                    }
                                                                                    mapMigration.remove(idString);
                                                                                }
                                                                            }
                                                                        }

                                                                    } else {
                                                                        for(Id objectId : objectIds){
                                                                            /* Updated 4/21/2021 for security re-review */
																			if (Schema.sObjectType.Note.isAccessible()) {
                                                                                List<Note> valid = [SELECT Id FROM Note WHERE ParentId = :objectId LIMIT 1];
                                                                                if(!valid.isEmpty()){
                                                                                    idString= objectId;
                                                                                    if(idString.length() == 18){
                                                                                        mapMigration.remove(idString.substring(0, 15));
                                                                                    }
                                                                                    mapMigration.remove(idString);
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                    return mapMigration;
                                                                }
    /**
* @description
* @return
*/
    public static Map<String,String> validateEnteredIDs(List<Id> idsToMigrate, Map<String,String> mapMigration, boolean isAttachment){
        if(isAttachment){
            /* Updated 4/21/2021 for security re-review */
			if (Schema.sObjectType.Attachment.isAccessible()) {
                List<Attachment> valid = [SELECT Id FROM Attachment WHERE Id IN :idsToMigrate LIMIT :LIMIT_QUERIES_OBJECTS];
                for(Attachment idToMigrate : valid){
                    String idString= idToMigrate.Id;
                    if(idString.length() == 18){
                        mapMigration.remove(idString.substring(0, 15));
                    }
                    mapMigration.remove(idString);
                }
            }

        } else {
            /* Updated 4/21/2021 for security re-review */
			if (Schema.sObjectType.Note.isAccessible()) {
                List<Note> valid = [SELECT Id FROM Note WHERE Id IN :idsToMigrate LIMIT :LIMIT_QUERIES_OBJECTS];
                for(Note idToMigrate : valid){
                    String idString= idToMigrate.Id;
                    if(idString.length() == 18){
                        mapMigration.remove(idString.substring(0, 15));
                    }
                    mapMigration.remove(idString);
                }
            }
        }

        return mapMigration;
    }

    /**
* @description Some special characters are not supported in enhanced notes.
* It cleans up some special characters from the note body.
* Most of the cases It replaces by an empty character
* @param noteBody the raw note body
* @return the note body without special characters
*/
    public static String cleanUpNoteBody(String baseBody){

        // per Salesforce we must escape certain special characters
        // logic inspired by David Reed (http://www.ktema.org//2016/08/24/importing-notes-into-salesforce/)
        // https://help.salesforce.com/apex/HTViewSolution?id=000230867&language=en_US
        // https://douglascayers.com/2015/10/10/salesforce-convert-attachments-to-chatter-files/
        String noteBody = ( String.isBlank( baseBody ) ? '<p></p>' : baseBody ).replaceAll('<p></p>','\n');
        String body = ( String.isBlank( noteBody ) ? '<p></p>' : noteBody )
            // the escape entity for '&' is '&amp;'
            // so it includes '&' in its own escape sequence, which is a problem
            // because escapeXml() changes '&' to '&amp;' as well
            // so a single '&' would become '&amp;amp;'
            // therefore we first find any normal '&'
            // and replace them with a token value that will
            // be later replaced with '&amp;'
            .replaceAll('&', 'sfdcAMPERSANDsfdc')
            .escapeXml()
            .replaceAll('sfdcAMPERSANDsfdc', '&amp;')
            // handle nitpick on apostrophe html entity
            .replaceAll('&apos;', '&#39;')
            // handle known unsupported non-ascii characters
            // oddly, other symbols like ® ™ are ok unescaped
            .replaceAll('©', '&copy;')
            // handle new lines
            .replaceAll('\r\n', '<br>')
            .replaceAll('\r', '<br>')
            .replaceAll('\n', '<br>')
            .replaceAll('\u2028', '<br>')
            .replaceAll('\u2029','<br>')
            .replaceAll('','')
            .replaceAll('\uFFFD','')
            //handle controls
            .replaceAll('[\\x7F-\\x9F\\x00-\\x1F]','')
            .replaceAll('[\\uD800-\\uDFFF]','');

        //'[\\uD800-\\uDFFF]' To remove emojis that may cause internal error when trying to convert


        // content version cannot have a null or empty string body
        // so set to empty paragraph which will appear as blank note.
        // we do this after escaping the original note body otherwise
        // the <p> tag would get escaped
        if ( String.isBlank( body ) ) {
            body = '<p></p>';
        }

        //keep html tags
        body = body.replace('&lt;p&gt;&lt;/p&gt;', '<p></p>');
        return body;
    }

    public static Boolean personAccountsEnabled()
    {
        try
        {
            // Try to use the isPersonAccount field.
            sObject testObject = new Contact();
            testObject.get('isPersonAccount');
            // If we got here without an exception, return true.
            return true;
        }
        catch( Exception ex )
        {
            // An exception was generated trying to access the isPersonAccount field
            // so person accounts aren’t enabled; return false.
            return false;
        }
    }

    /**
* TODO move this to NMTNotesMigrationController
* @description
* @param notes all notes in the batch
* @param totalToMigrateBatch
* @return the notes to be migrated
*/
    public static List<Note> filterNotesToMigrate(List<Note> notes, Integer totalToMigrateBatch){
        List<Note> notesToMigrate = new List<Note>();
        /* Updated 4/21/2021 for security re-review */
		if (Schema.sObjectType.Attachment.isAccessible()) {
            List<String> notesParentsIds = new List<String>();
            List<String> notesIds = new List<String>();
            for(Note note :notes){
                notesIds.add(String.valueOf(note.Id));
                notesParentsIds.add(String.valueOf(note.ParentId));
            }
    
            //look for notes already converted
            List<NAMNoteConverted__c> notesConverted = [SELECT LegacyNoteConvertedId__c
                                                                   FROM
                                                                   NAMNoteConverted__c
                                                                   WHERE
                                                                   LegacyNoteConvertedId__c in :notesIds];
    
            for(Note note :notes){
                boolean add = true;
                //look if the note was already migrated
                for(NAMNoteConverted__c cl: notesConverted){
                    if(note.id != null
                       && cl.LegacyNoteConvertedId__c != null
                       && (Id.valueOf(note.id) == Id.valueOf(cl.LegacyNoteConvertedId__c))){
                           add = false;
                           break;
                       }
                }
                if(add && notesToMigrate.size() < totalToMigrateBatch){
                    notesToMigrate.add(note);
                }
            }
        }
        return notesToMigrate;
    }

    /**
* @description this method is used in MetadataController and NotesMigrationController to know if the org has Enhanced Notes enabled
* @param address
* @param subject
* @param body
*/
    public static boolean isEnhancedNotesEnabled(){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        return gd.containsKey('ContentNote');
    }

    /**
* @description
* @return
*/
    public static Boolean isPendingAttachmentsToBeConverted (){
        /* Updated 4/21/2021 for security re-review */
		if (Schema.sObjectType.Attachment.isAccessible()) {
            String[] customobjects = getCustomObject();
            List<Attachment> quantities = new List<Attachment>();
            if(NAMConfigs.getEnableBodyLength()){
                Integer bodyLengthValue = NAMConfigs.getBodyLength() * 1024 * 1024;
                quantities = [SELECT id
                              FROM Attachment
                              WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                              AND bodyLength != 0
                              AND bodyLength <= :bodyLengthValue
                              AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                              LIMIT 1];
    
            } else {
                quantities = [SELECT id
                              FROM Attachment
                              WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                              AND bodyLength != 0
                              AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                              LIMIT 1];
    
            }
            return quantities.size() > 0;
        } else {
            return false;
        }
    }

    /**
* @description
* @return
Updated
*/
    public static Integer countTotalPublicUnmigratedAttachmentsPerObject(Date startdate, Date endDate, Boolean byCreateDate, String objectSelected){
		/* Updated 4/21/2021 for security re-review */
		if (Schema.sObjectType.Attachment.isAccessible()) {
            List<NMTSObjectWrapper> quantities = new List<NMTSObjectWrapper>();
            String[] customobjects = getCustomObject();
            Time firstTime = Time.newInstance(0, 0, 0, 0);
            Time endTime = Time.newInstance(23, 59, 59, 0);
    
            DateTime dtstart = DateTime.newInstance(startDate,firstTime);
            DateTime dtend = DateTime.newInstance(endDate,endTime);
            if(!objectSelected.equalsIgnoreCase('All')){
                if(NAMConfigs.getEnableBodyLength()){
                    Integer bodyLengthValue = NAMConfigs.getBodyLength() * 1024 * 1024;
                    if(byCreateDate){
                        //LIMIT we assume that there are not more than 1000 objects in the org
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :bodyLengthValue
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        AND Parent.Type = :objectSelected
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC
                                                        LIMIT :LIMIT_QUERIES_OBJECTS]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                         AND bodyLength != 0
                                                         AND bodyLength <= :bodyLengthValue
                                                         AND (Parent.Type = :differentType)
                                                         AND createdDate >= :dtstart
                                                         AND createdDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                    quantities.add(ow);
                                }
                            }
                        }
    
                    } else {
                        //LIMIT we assume that there are not more than 1000 objects in the org
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :bodyLengthValue
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC
                                                        LIMIT :LIMIT_QUERIES_OBJECTS]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                             AND bodyLength != 0
                                                             AND bodyLength <= :bodyLengthValue
                                                             AND (Parent.Type = :differentType)
                                                             AND lastModifiedDate >= :dtstart
                                                             AND lastModifiedDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                        quantities.add(ow);
                                    }
                                }
    
    
                            }
                        }
    
                    }
    
                }  else {
                    if(byCreateDate){
                        //LIMIT we assume that there are not more than 1000 objects in the org
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        AND Parent.Type = :objectSelected
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC
                                                        LIMIT :LIMIT_QUERIES_OBJECTS]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                             AND bodyLength != 0
                                                             AND (Parent.Type = :differentType)
                                                             AND createdDate >= :dtstart
                                                             AND createdDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                        quantities.add(ow);
                                    }
                                }
    
    
                            }
                        }
    
                    } else {
                        //LIMIT we assume that there are not more than 1000 objects in the org
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        AND Parent.Type = :objectSelected
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC
                                                        LIMIT :LIMIT_QUERIES_OBJECTS]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                             AND bodyLength != 0
                                                             AND (Parent.Type = :differentType)
                                                             AND lastModifiedDate >= :dtstart
                                                             AND lastModifiedDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                        quantities.add(ow);
                                    }
                                }
    
    
                            } }
    
                    }
    
                }
            } else {
                if(NAMConfigs.getEnableBodyLength()){
                    Integer bodyLengthValue = NAMConfigs.getBodyLength() * 1024 * 1024;
                    if(byCreateDate){
                        //LIMIT we assume that there are not more than 1000 objects in the org
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :bodyLengthValue
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC
                                                        LIMIT :LIMIT_QUERIES_OBJECTS]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                         AND bodyLength != 0
                                                         AND bodyLength <= :bodyLengthValue
                                                         AND (Parent.Type = :differentType)
                                                         AND createdDate >= :dtstart
                                                         AND createdDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                    quantities.add(ow);
                                }
                            }
                        }
    
                    } else {
                        //LIMIT we assume that there are not more than 1000 objects in the org
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :bodyLengthValue
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC
                                                        LIMIT :LIMIT_QUERIES_OBJECTS]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                         AND bodyLength != 0
                                                         AND bodyLength <= :bodyLengthValue
                                                         AND (Parent.Type = :differentType)
                                                         AND lastModifiedDate >= :dtstart
                                                         AND lastModifiedDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                    quantities.add(ow);
                                }
                            }
                        }
    
                    }
    
                }  else {
                    if(byCreateDate){
                        //LIMIT we assume that there are not more than 1000 objects in the org
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC
                                                        LIMIT :LIMIT_QUERIES_OBJECTS]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                         AND bodyLength != 0
                                                         AND (Parent.Type = :differentType)
                                                         AND createdDate >= :dtstart
                                                         AND createdDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                    quantities.add(ow);
                                }
                            }
                        }
    
                    } else {
                        //LIMIT we assume that there are not more than 1000 objects in the org
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC
                                                        LIMIT :LIMIT_QUERIES_OBJECTS]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                         AND bodyLength != 0
                                                         AND (Parent.Type = :differentType)
                                                         AND lastModifiedDate >= :dtstart
                                                         AND lastModifiedDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                    quantities.add(ow);
                                }
                            }
                        }
    
                    }
    
                }
    
            }
    
            return quantities.size();
        } else {
            return 0;
        }
    }

    /**
* @description
* @return
Updated
*/
    public static Integer countTotalMigratedAttachmentsPerObject(Date startdate, Date endDate, Boolean byCreateDate, String objectSelected){
		/* Updated 4/21/2021 for security re-review */
		if (Schema.sObjectType.Attachment.isAccessible()) {
            List<NAMObjectCount> quantities = new List<NAMObjectCount>();
            String[] customobjects = getCustomObject();
            Time firstTime = Time.newInstance(0, 0, 0, 0);
            Time endTime = Time.newInstance(23, 59, 59, 0);
    
            DateTime dtstart = DateTime.newInstance(startDate,firstTime);
            DateTime dtend = DateTime.newInstance(endDate,endTime);
            if(!objectSelected.equalsIgnoreCase('All')){
                if(NAMConfigs.getEnableBodyLength()){
                    Integer bodyLengthValue = NAMConfigs.getBodyLength() * 1024 * 1024;
                    if(byCreateDate){
                        //LIMIT we assume that there are not more than 1000 objects in the org
                        for(AggregateResult[] results  :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND createdDate >= :dtstart
                                                         AND createdDate <= :dtend
                                                         AND bodyLength != 0
                                                         AND bodyLength <= :bodyLengthValue
                                                         AND Parent.Type = :objectSelected
                                                         GROUP BY Parent.Type
                                                         LIMIT :LIMIT_QUERIES_OBJECTS]){
    
                                                             for (AggregateResult ar : results) {
                                                                 String objectType = (String) ar.get('ObjectName');
                                                                 if(objectType != null && !objectType.equals('')){
                                                                     NAMObjectCount oc = new NAMObjectCount(ar);
                                                                     quantities.add(oc);
                                                                 }
                                                             }
                                                         }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                             AND bodyLength != 0
                                                             AND bodyLength <= :bodyLengthValue
                                                             AND (Parent.Type = :differentType)
                                                             AND createdDate >= :dtstart
                                                             AND createdDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                        quantities.add(oc);
                                    }
                                }
    
                            }
                        }
                    } else {
                        //LIMIT we assume that there are not more than 1000 objects in the org
                        for(AggregateResult[] results  :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND lastModifiedDate >= :dtstart
                                                         AND lastModifiedDate <= :dtend
                                                         AND bodyLength != 0
                                                         AND bodyLength <= :bodyLengthValue
                                                         AND Parent.Type = :objectSelected
                                                         GROUP BY Parent.Type
                                                         LIMIT :LIMIT_QUERIES_OBJECTS]){
    
                                                             for (AggregateResult ar : results) {
                                                                 String objectType = (String) ar.get('ObjectName');
                                                                 if(objectType != null && !objectType.equals('')){
                                                                     NAMObjectCount oc = new NAMObjectCount(ar);
                                                                     quantities.add(oc);
                                                                 }
                                                             }
                                                         }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                             AND bodyLength != 0
                                                             AND bodyLength <= :bodyLengthValue
                                                             AND (Parent.Type = :differentType)
                                                             AND lastModifiedDate >= :dtstart
                                                             AND lastModifiedDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                        quantities.add(oc);
                                    }
                                }
    
    
                            }
                        }
    
                    }
    
    
                } else{
    
                    if(byCreateDate){
                        //LIMIT we assume that there are not more than 1000 objects in the org
                        for(AggregateResult[] results  :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND createdDate >= :dtstart
                                                         AND createdDate <= :dtend
                                                         AND bodyLength != 0
                                                         AND Parent.Type = :objectSelected
                                                         GROUP BY Parent.Type
                                                         LIMIT :LIMIT_QUERIES_OBJECTS]){
    
                                                             for (AggregateResult ar : results) {
                                                                 String objectType = (String) ar.get('ObjectName');
                                                                 if(objectType != null && !objectType.equals('')){
                                                                     NAMObjectCount oc = new NAMObjectCount(ar);
                                                                     quantities.add(oc);
                                                                 }
                                                             }
                                                         }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                             AND bodyLength != 0
                                                             AND (Parent.Type = :differentType)
                                                             AND createdDate >= :dtstart
                                                             AND createdDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                        quantities.add(oc);
                                    }
                                }
    
    
                            }
                        }
                    } else {
                        //LIMIT we assume that there are not more than 1000 objects in the org
                        for(AggregateResult[] results  :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND lastModifiedDate >= :dtstart
                                                         AND lastModifiedDate <= :dtend
                                                         AND bodyLength != 0
                                                         AND Parent.Type = :objectSelected
                                                         GROUP BY Parent.Type
                                                         LIMIT :LIMIT_QUERIES_OBJECTS]){
    
                                                             for (AggregateResult ar : results) {
                                                                 String objectType = (String) ar.get('ObjectName');
                                                                 if(objectType != null && !objectType.equals('')){
                                                                     NAMObjectCount oc = new NAMObjectCount(ar);
                                                                     quantities.add(oc);
                                                                 }
                                                             }
                                                         }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                             AND bodyLength != 0
                                                             AND (Parent.Type = :differentType)
                                                             AND lastModifiedDate >= :dtstart
                                                             AND lastModifiedDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                        quantities.add(oc);
                                    }
                                }
    
                            }
                        }
    
                    }
                }
    
            } else {
                if(NAMConfigs.getEnableBodyLength()){
                    Integer bodyLengthValue = NAMConfigs.getBodyLength() * 1024 * 1024;
                    if(byCreateDate){
                        //LIMIT we assume that there are not more than 1000 objects in the org
                        for(AggregateResult[] results  :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND createdDate >= :dtstart
                                                         AND createdDate <= :dtend
                                                         AND bodyLength != 0
                                                         AND bodyLength <= :bodyLengthValue
                                                         AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                         GROUP BY Parent.Type
                                                         LIMIT :LIMIT_QUERIES_OBJECTS]){
    
                                                             for (AggregateResult ar : results) {
                                                                 String objectType = (String) ar.get('ObjectName');
                                                                 if(objectType != null && !objectType.equals('')){
                                                                     NAMObjectCount oc = new NAMObjectCount(ar);
                                                                     quantities.add(oc);
                                                                 }
                                                             }
                                                         }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND bodyLength != 0
                                                         AND bodyLength <= :bodyLengthValue
                                                         AND (Parent.Type = :differentType)
                                                         AND createdDate >= :dtstart
                                                         AND createdDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                    quantities.add(oc);
                                }
                            }
                        }
                    } else {
                        //LIMIT we assume that there are not more than 1000 objects in the org
                        for(AggregateResult[] results  :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND lastModifiedDate >= :dtstart
                                                         AND lastModifiedDate <= :dtend
                                                         AND bodyLength != 0
                                                         AND bodyLength <= :bodyLengthValue
                                                         AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                         GROUP BY Parent.Type
                                                         LIMIT :LIMIT_QUERIES_OBJECTS]){
    
                                                             for (AggregateResult ar : results) {
                                                                 String objectType = (String) ar.get('ObjectName');
                                                                 if(objectType != null && !objectType.equals('')){
                                                                     NAMObjectCount oc = new NAMObjectCount(ar);
                                                                     quantities.add(oc);
                                                                 }
                                                             }
                                                         }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND bodyLength != 0
                                                         AND bodyLength <= :bodyLengthValue
                                                         AND (Parent.Type = :differentType)
                                                         AND lastModifiedDate >= :dtstart
                                                         AND lastModifiedDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                    quantities.add(oc);
                                }
                            }
                        }
    
                    }
    
    
                } else{
    
                    if(byCreateDate){
                        //LIMIT we assume that there are not more than 1000 objects in the org
                        for(AggregateResult[] results  :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND createdDate >= :dtstart
                                                         AND createdDate <= :dtend
                                                         AND bodyLength != 0
                                                         AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                         GROUP BY Parent.Type
                                                         LIMIT :LIMIT_QUERIES_OBJECTS]){
    
                                                             for (AggregateResult ar : results) {
                                                                 String objectType = (String) ar.get('ObjectName');
                                                                 if(objectType != null && !objectType.equals('')){
                                                                     NAMObjectCount oc = new NAMObjectCount(ar);
                                                                     quantities.add(oc);
                                                                 }
                                                             }
                                                         }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND bodyLength != 0
                                                         AND (Parent.Type = :differentType)
                                                         AND createdDate >= :dtstart
                                                         AND createdDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                    quantities.add(oc);
                                }
                            }
                        }
                    } else {
                        //LIMIT we assume that there are not more than 1000 objects in the org
                        for(AggregateResult[] results  :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND lastModifiedDate >= :dtstart
                                                         AND lastModifiedDate <= :dtend
                                                         AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                         AND bodyLength != 0
                                                         GROUP BY Parent.Type
                                                         LIMIT :LIMIT_QUERIES_OBJECTS]){
    
                                                             for (AggregateResult ar : results) {
                                                                 String objectType = (String) ar.get('ObjectName');
                                                                 if(objectType != null && !objectType.equals('')){
                                                                     NAMObjectCount oc = new NAMObjectCount(ar);
                                                                     quantities.add(oc);
                                                                 }
                                                             }
                                                         }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND bodyLength != 0
                                                         AND (Parent.Type = :differentType)
                                                         AND lastModifiedDate >= :dtstart
                                                         AND lastModifiedDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                    quantities.add(oc);
                                }
                            }
                        }
    
                    }
                }
    
            }
            return quantities.size();
        } else {
            return 0;
        }
    }

    /**
* @description
* @param theLimit
* @param theOffset
* @return example: [{Account, 22}, {Contact, 38}, {Lead,18}] where the number represents the quantity
* of migrated public attachments for that object
Updated
*/
    public static List<NAMObjectCount> countMigratedAttachmentsPerObject(Integer theLimit, Integer theOffset, Date startdate, Date endDate, Boolean byCreateDate, String objectSelected){
		
        List<NAMObjectCount> quantities = new List<NAMObjectCount>();
        
        /* Updated 4/21/2021 for security re-review */
		if (Schema.sObjectType.Attachment.isAccessible()) {
            Map<String, NAMObjectCount> types = new Map<String, NAMObjectCount>();
            String[] customobjects = getCustomObject();
    
            Time firstTime = Time.newInstance(0, 0, 0, 0);
            Time endTime = Time.newInstance(23, 59, 59, 0);
    
            DateTime dtstart = DateTime.newInstance(startDate,firstTime);
            DateTime dtend = DateTime.newInstance(endDate,endTime);
            if(!objectSelected.equalsIgnoreCase('All') && Schema.sObjectType.Attachment.isAccessible()){
                if(NAMConfigs.getEnableBodyLength()){
                    Integer bodyLengthValue = NAMConfigs.getBodyLength() * 1024 * 1024;
                    if(byCreateDate){
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :bodyLengthValue
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        AND Parent.Type = :objectSelected
                                                        GROUP BY Parent.Type
                                                        LIMIT :thelimit
                                                        OFFSET :theOffset]){
    
                                                            for (AggregateResult ar : results) {
                                                                String objectType = (String) ar.get('ObjectName');
                                                                if(objectType != null && !objectType.equals('')){
                                                                    NAMObjectCount oc = new NAMObjectCount(ar);
                                                                    quantities.add(oc);
                                                                }
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                             AND bodyLength != 0
                                                             AND bodyLength <= :bodyLengthValue
                                                             AND (Parent.Type = :differentType)
                                                             AND createdDate >= :dtstart
                                                             AND createdDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                        if(quantities.size()<thelimit){
                                            quantities.add(oc);
                                        }
                                    }
                                }
                                
    
                            }
                        }
                    } else {

                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :bodyLengthValue
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        AND Parent.Type = :objectSelected
                                                        GROUP BY Parent.Type
                                                        LIMIT :thelimit
                                                        OFFSET :theOffset]){
                                                            
                                                            for (AggregateResult ar : results) {
                                                                String objectType = (String) ar.get('ObjectName');
                                                                if(objectType != null && !objectType.equals('')){
                                                                    NAMObjectCount oc = new NAMObjectCount(ar);
                                                                    quantities.add(oc);
                                                                }
                                                            }
                                                        }
                        
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                             AND bodyLength != 0
                                                             AND bodyLength <= :bodyLengthValue
                                                             AND (Parent.Type = :differentType)
                                                             AND lastModifiedDate >= :dtstart
                                                             AND lastModifiedDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                        if(quantities.size()<thelimit){
                                            quantities.add(oc);
                                        }
                                    }
                                }
                                
    
    
                            }
                        }
    
                    }
    
                } else{
    
                    if(byCreateDate){
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                        AND bodyLength != 0
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        AND Parent.Type = :objectSelected
                                                        GROUP BY Parent.Type
                                                        LIMIT :thelimit
                                                        OFFSET :theOffset]){
    
                                                            for (AggregateResult ar : results) {
                                                                String objectType = (String) ar.get('ObjectName');
                                                                if(objectType != null && !objectType.equals('')){
                                                                    NAMObjectCount oc = new NAMObjectCount(ar);
                                                                    quantities.add(oc);
                                                                }
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                             AND bodyLength != 0
                                                             AND (Parent.Type = :differentType)
                                                             AND createdDate >= :dtstart
                                                             AND createdDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                        if(quantities.size()<thelimit){
                                            quantities.add(oc);
                                        }
                                    }
                                }
    
    
                            }
                        }
                    } else {
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                        AND bodyLength != 0
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        AND Parent.Type = :objectSelected
                                                        GROUP BY Parent.Type
                                                        LIMIT :thelimit
                                                        OFFSET :theOffset]){
    
                                                            for (AggregateResult ar : results) {
                                                                String objectType = (String) ar.get('ObjectName');
                                                                if(objectType != null && !objectType.equals('')){
                                                                    NAMObjectCount oc = new NAMObjectCount(ar);
                                                                    quantities.add(oc);
                                                                }
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                             AND bodyLength != 0
                                                             AND (Parent.Type = :differentType)
                                                             AND lastModifiedDate >= :dtstart
                                                             AND lastModifiedDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                        if(quantities.size()<thelimit){
                                            quantities.add(oc);
                                        }
                                    }
                                }
    
    
                            }
                        }
                    }
                }
    
    
            } else {
                if(NAMConfigs.getEnableBodyLength()){
                    Integer bodyLengthValue = NAMConfigs.getBodyLength() * 1024 * 1024;
                    if(byCreateDate){
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :bodyLengthValue
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        GROUP BY Parent.Type
                                                        LIMIT :thelimit
                                                        OFFSET :theOffset]){
    
                                                            for (AggregateResult ar : results) {
                                                                String objectType = (String) ar.get('ObjectName');
                                                                if(objectType != null && !objectType.equals('')){
                                                                    NAMObjectCount oc = new NAMObjectCount(ar);
                                                                    quantities.add(oc);
                                                                }
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND bodyLength != 0
                                                         AND bodyLength <= :bodyLengthValue
                                                         AND (Parent.Type = :differentType)
                                                         AND createdDate >= :dtstart
                                                         AND createdDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                    if(quantities.size()<thelimit){
                                        quantities.add(oc);
                                    }
                                }
                            }
                        }
                    } else {
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :bodyLengthValue
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        GROUP BY Parent.Type
                                                        LIMIT :thelimit
                                                        OFFSET :theOffset]){
    
                                                            for (AggregateResult ar : results) {
                                                                String objectType = (String) ar.get('ObjectName');
                                                                if(objectType != null && !objectType.equals('')){
                                                                    NAMObjectCount oc = new NAMObjectCount(ar);
                                                                    quantities.add(oc);
                                                                }
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND bodyLength != 0
                                                         AND bodyLength <= :bodyLengthValue
                                                         AND (Parent.Type = :differentType)
                                                         AND lastModifiedDate >= :dtstart
                                                         AND lastModifiedDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                    if(quantities.size()<thelimit){
                                        quantities.add(oc);
                                    }
                                }
                            }
                        }
    
                    }
    
                } else{
    
                    if(byCreateDate){
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                        AND bodyLength != 0
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        GROUP BY Parent.Type
                                                        LIMIT :thelimit
                                                        OFFSET :theOffset]){
    
                                                            for (AggregateResult ar : results) {
                                                                String objectType = (String) ar.get('ObjectName');
                                                                if(objectType != null && !objectType.equals('')){
                                                                    NAMObjectCount oc = new NAMObjectCount(ar);
                                                                    quantities.add(oc);
                                                                }
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND bodyLength != 0
                                                         AND (Parent.Type = :differentType)
                                                         AND createdDate >= :dtstart
                                                         AND createdDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                    if(quantities.size()<thelimit){
                                        quantities.add(oc);
                                    }
                                }
                            }
                        }
                    } else {
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                        AND bodyLength != 0
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        GROUP BY Parent.Type
                                                        LIMIT :thelimit
                                                        OFFSET :theOffset]){
    
                                                            for (AggregateResult ar : results) {
                                                                String objectType = (String) ar.get('ObjectName');
                                                                if(objectType != null && !objectType.equals('')){
                                                                    NAMObjectCount oc = new NAMObjectCount(ar);
                                                                    quantities.add(oc);
                                                                }
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND bodyLength != 0
                                                         AND (Parent.Type = :differentType)
                                                         AND lastModifiedDate >= :dtstart
                                                         AND lastModifiedDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                    if(quantities.size()<thelimit){
                                        quantities.add(oc);
                                    }
                                }
                            }
                        }
                    }
                }
    
            }
        }
        return quantities;
    }

    /**
* TODO I think this method also counts private attachments, the name should be countPublicUnmigratedAttachmentsPerObject
* @description
* @param theLimit
* @param theOffset
Updated
* @return
*/
    public static List<NMTSObjectWrapper> countPublicUnmigratedAttachmentsPerObject(Integer theLimit, Integer theOffset, Date startdate, Date endDate, Boolean byCreateDate, String objectSelected){

        List<NMTSObjectWrapper> quantities = new List<NMTSObjectWrapper>();
        
        /* Updated 4/21/2021 for security re-review */
		if (Schema.sObjectType.Attachment.isAccessible()) {
            String[] customobjects = getCustomObject();
            Time firstTime = Time.newInstance(0, 0, 0, 0);
            Time endTime = Time.newInstance(23, 59, 59, 0);
    
            DateTime dtstart = DateTime.newInstance(startDate,firstTime);
            DateTime dtend = DateTime.newInstance(endDate,endTime);
            if(!objectSelected.equalsIgnoreCase('All')){
                if(NAMConfigs.getEnableBodyLength()){
                    Integer bodyLengthValue = NAMConfigs.getBodyLength() * 1024 * 1024;
                    if(byCreateDate){
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :bodyLengthValue
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        AND Parent.Type = :objectSelected
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC
                                                        LIMIT :theLimit
                                                        OFFSET :theoffset]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
    
    
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                             AND bodyLength != 0
                                                             AND bodyLength <= :NAMConfigs.getBodyLength()
                                                             AND (Parent.Type = :differentType)
                                                             AND createdDate >= :dtstart
                                                             AND createdDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                        if(quantities.size()<thelimit){
                                            quantities.add(ow);
                                        }
                                    }
                                }
    
    
                            }
                        }
    
                    } else {
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :NAMConfigs.getBodyLength()
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        AND Parent.Type = :objectSelected
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC
                                                        LIMIT :theLimit
                                                        OFFSET :theoffset]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
    
    
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                             AND bodyLength != 0
                                                             AND bodyLength <= :NAMConfigs.getBodyLength()
                                                             AND (Parent.Type = :differentType)
                                                             AND lastModifiedDate >= :dtstart
                                                             AND lastModifiedDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                        if(quantities.size()<thelimit){
                                            quantities.add(ow);
                                        }
                                    }
                                }
    
                            }
                        }
                    }
                } else {
                    if(byCreateDate){
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        AND Parent.Type = :objectSelected
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC
                                                        LIMIT :theLimit
                                                        OFFSET :theoffset]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
    
    
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                             AND bodyLength != 0
                                                             AND (Parent.Type = :differentType)
                                                             AND createdDate >= :dtstart
                                                             AND createdDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                        if(quantities.size()<thelimit){
                                            quantities.add(ow);
                                        }
                                    }
                                }
    
    
                            }
                        }
    
                    } else {
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        AND Parent.Type = :objectSelected
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC
                                                        LIMIT :theLimit
                                                        OFFSET :theoffset]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
    
    
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                             AND bodyLength != 0
                                                             AND (Parent.Type = :differentType)
                                                             AND lastModifiedDate >= :dtstart
                                                             AND lastModifiedDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                        if(quantities.size()<thelimit){
                                            quantities.add(ow);
                                        }
                                    }
                                }
    
    
                            }
                        }
                    }
                }
    
    
            } else {
                if(NAMConfigs.getEnableBodyLength()){
                    Integer bodyLengthValue = NAMConfigs.getBodyLength() * 1024 * 1024;
                    if(byCreateDate){
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :bodyLengthValue
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC
                                                        LIMIT :theLimit
                                                        OFFSET :theoffset]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
    
    
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                         AND bodyLength != 0
                                                         AND bodyLength <= :bodyLengthValue
                                                         AND (Parent.Type = :differentType)
                                                         AND createdDate >= :dtstart
                                                         AND createdDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                    if(quantities.size()<thelimit){
                                        quantities.add(ow);
                                    }
                                }
                            }
                        }
    
                    } else {
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :bodyLengthValue
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC
                                                        LIMIT :theLimit
                                                        OFFSET :theoffset]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
    
    
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                         AND bodyLength != 0
                                                         AND bodyLength <= :bodyLengthValue
                                                         AND (Parent.Type = :differentType)
                                                         AND lastModifiedDate >= :dtstart
                                                         AND lastModifiedDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                    if(quantities.size()<thelimit){
                                        quantities.add(ow);
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if(byCreateDate){
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC
                                                        LIMIT :theLimit
                                                        OFFSET :theoffset]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
    
    
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                         AND bodyLength != 0
                                                         AND (Parent.Type = :differentType)
                                                         AND createdDate >= :dtstart
                                                         AND createdDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                    if(quantities.size()<thelimit){
                                        quantities.add(ow);
                                    }
                                }
                            }
                        }
    
                    } else {
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC
                                                        LIMIT :theLimit
                                                        OFFSET :theoffset]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
    
    
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                         AND bodyLength != 0
                                                         AND (Parent.Type = :differentType)
                                                         AND lastModifiedDate >= :dtstart
                                                         AND lastModifiedDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                    if(quantities.size()<thelimit){
                                        quantities.add(ow);
                                    }
                                }
                            }
                        }
                    }
                }
    
    
            }
        }
        return quantities;
    }

    /**
* @description
* @param startdate
* @param endDate
* @return
Update
*/
    public static List<NMTSObjectWrapper> countTotalUnmigratedAttachments(Date startdate, Date endDate, Boolean byCreateDate, String objectSelected){

        List<NMTSObjectWrapper> quantities = new List<NMTSObjectWrapper>();
        
        /* Updated 4/21/2021 for security re-review */
		if (Schema.sObjectType.Attachment.isAccessible()) {
            String[] customobjects = getCustomObject();
            Time firstTime = Time.newInstance(0, 0, 0, 0);
            Time endTime = Time.newInstance(23, 59, 59, 0);
    
            DateTime dtstart = DateTime.newInstance(startDate,firstTime);
            DateTime dtend = DateTime.newInstance(endDate,endTime);
            if(!objectSelected.equalsIgnoreCase('All')){
                if(NAMConfigs.getEnableBodyLength()){
                    Integer bodyLengthValue = NAMConfigs.getBodyLength() * 1024 * 1024;
                    if(byCreateDate){
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :bodyLengthValue
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        AND Parent.Type = :objectSelected
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                             AND bodyLength != 0
                                                             AND bodyLength <= :bodyLengthValue
                                                             AND (Parent.Type = :differentType)
                                                             AND createdDate >= :dtstart
                                                             AND createdDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                        quantities.add(ow);
                                    }
                                }
    
    
                            }
                        }
                    } else {
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :bodyLengthValue
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        AND Parent.Type = :objectSelected
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                             AND bodyLength != 0
                                                             AND bodyLength <= :bodyLengthValue
                                                             AND (Parent.Type = :differentType)
                                                             AND lastModifiedDate >= :dtstart
                                                             AND lastModifiedDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                        quantities.add(ow);
                                    }
                                }
    
    
                            }
                        }
    
                    }
    
                } else {
                    if(byCreateDate){
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        AND Parent.Type = :objectSelected
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                             AND bodyLength != 0
                                                             AND (Parent.Type = :differentType)
                                                             AND createdDate >= :dtstart
                                                             AND createdDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                        quantities.add(ow);
                                    }
                                }
    
                            }
                        }
                    } else {
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        AND Parent.Type = :objectSelected
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                             AND bodyLength != 0
                                                             AND (Parent.Type = :differentType)
                                                             AND lastModifiedDate >= :dtstart
                                                             AND lastModifiedDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                        quantities.add(ow);
                                    }
                                }
    
    
                            }
                        }
                    }
                }
    
            } else {
                if(NAMConfigs.getEnableBodyLength()){
                    Integer bodyLengthValue = NAMConfigs.getBodyLength() * 1024 * 1024;
                    if(byCreateDate){
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :bodyLengthValue
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                         AND bodyLength != 0
                                                         AND bodyLength <= :bodyLengthValue
                                                         AND (Parent.Type = :differentType)
                                                         AND createdDate >= :dtstart
                                                         AND createdDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                    quantities.add(ow);
                                }
                            }
                        }
                    } else {
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :bodyLengthValue
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                         AND bodyLength != 0
                                                         AND bodyLength <= :bodyLengthValue
                                                         AND (Parent.Type = :differentType)
                                                         AND lastModifiedDate >= :dtstart
                                                         AND lastModifiedDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                    quantities.add(ow);
                                }
                            }
                        }
    
                    }
    
                } else {
                    if(byCreateDate){
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                         AND bodyLength != 0
                                                         AND (Parent.Type = :differentType)
                                                         AND createdDate >= :dtstart
                                                         AND createdDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                    quantities.add(ow);
                                }
                            }
                        }
                    } else {
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                        AND bodyLength != 0
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        GROUP BY Parent.Type
                                                        ORDER BY Parent.Type ASC]){
    
                                                            for (AggregateResult ar : results) {
                                                                NMTSObjectWrapper ow = new NMTSObjectWrapper(ar);
                                                                quantities.add(ow);
                                                            }
                                                        }
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                                         AND bodyLength != 0
                                                         AND (Parent.Type = :differentType)
                                                         AND lastModifiedDate >= :dtstart
                                                         AND lastModifiedDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NMTSObjectWrapper ow = new NMTSObjectWrapper(ar,differentType);
                                    quantities.add(ow);
                                }
                            }
                        }
                    }
                }
    
    
            }
        }
        return quantities;
    }

    /**
* @description
* @param startdate
* @param endDate
Update
*/
    public static List<NAMObjectCount> countTotalMigratedAttachments(Date startdate, Date endDate, Boolean byCreateDate, String objectSelected){

        List<NAMObjectCount> quantities = new List<NAMObjectCount>();
        
        /* Updated 4/21/2021 for security re-review */
		if (Schema.sObjectType.Attachment.isAccessible()) {
            String[] customobjects = getCustomObject();
    
            Time firstTime = Time.newInstance(0, 0, 0, 0);
            Time endTime = Time.newInstance(23, 59, 59, 0);
    
            DateTime dtstart = DateTime.newInstance(startDate,firstTime);
            DateTime dtend = DateTime.newInstance(endDate,endTime);
    
            if(!objectSelected.equalsIgnoreCase('All')){
                if(NAMConfigs.getEnableBodyLength()){
                    Integer bodyLengthValue = NAMConfigs.getBodyLength() * 1024 * 1024;
                    if(byCreateDate){
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :bodyLengthValue
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        AND Parent.Type = :objectSelected
                                                        GROUP BY Parent.Type]){
    
                                                            for (AggregateResult ar : results) {
                                                                NAMObjectCount oc = new NAMObjectCount(ar);
                                                                quantities.add(oc);
                                                            }
                                                        }
    
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                             AND bodyLength != 0
                                                             AND bodyLength <= :bodyLengthValue
                                                             AND (Parent.Type = :differentType)
                                                             AND createdDate >= :dtstart
                                                             AND createdDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                        quantities.add(oc);
                                    }
                                }
    
    
                            }
                        }
    
                    } else {
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :bodyLengthValue
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        AND Parent.Type = :objectSelected
                                                        GROUP BY Parent.Type]){
    
                                                            for (AggregateResult ar : results) {
                                                                NAMObjectCount oc = new NAMObjectCount(ar);
                                                                quantities.add(oc);
                                                            }
                                                        }
    
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                             AND bodyLength != 0
                                                             AND bodyLength <= :bodyLengthValue
                                                             AND (Parent.Type = :differentType)
                                                             AND lastModifiedDate >= :dtstart
                                                             AND lastModifiedDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                        quantities.add(oc);
                                    }
                                }
    
    
                            }
                        }
    
                    }
    
                } else {
                    if(byCreateDate){
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                        AND bodyLength != 0
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        AND Parent.Type = :objectSelected
                                                        GROUP BY Parent.Type]){
    
                                                            for (AggregateResult ar : results) {
                                                                NAMObjectCount oc = new NAMObjectCount(ar);
                                                                quantities.add(oc);
                                                            }
                                                        }
    
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                             AND bodyLength != 0
                                                             AND (Parent.Type = :differentType)
                                                             AND createdDate >= :dtstart
                                                             AND createdDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                        quantities.add(oc);
                                    }
                                }
    
    
                            }
                        }
    
                    } else {
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                        AND bodyLength != 0
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        AND Parent.Type = :objectSelected
                                                        GROUP BY Parent.Type]){
    
                                                            for (AggregateResult ar : results) {
                                                                NAMObjectCount oc = new NAMObjectCount(ar);
                                                                quantities.add(oc);
                                                            }
                                                        }
    
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            if(differentType.equalsIgnoreCase(objectSelected)){
                                AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                             FROM Attachment
                                                             WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                             AND bodyLength != 0
                                                             AND (Parent.Type = :differentType)
                                                             AND lastModifiedDate >= :dtstart
                                                             AND lastModifiedDate <= :dtend];
                                for (AggregateResult ar : results) {
                                    Integer count = (Integer) ar.get('Quantity');
                                    if(count>0){
                                        NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                        quantities.add(oc);
                                    }
                                }
    
    
                            }
                        }
                    }
                }
    
    
            } else {
                if(NAMConfigs.getEnableBodyLength()){
                    Integer bodyLengthValue = NAMConfigs.getBodyLength() * 1024 * 1024;
                    if(byCreateDate){
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :bodyLengthValue
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        GROUP BY Parent.Type]){
    
                                                            for (AggregateResult ar : results) {
                                                                NAMObjectCount oc = new NAMObjectCount(ar);
                                                                quantities.add(oc);
                                                            }
                                                        }
    
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND bodyLength != 0
                                                         AND bodyLength <= :bodyLengthValue
                                                         AND (Parent.Type = :differentType)
                                                         AND createdDate >= :dtstart
                                                         AND createdDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                    quantities.add(oc);
                                }
                            }
                        }
    
                    } else {
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                        AND bodyLength != 0
                                                        AND bodyLength <= :bodyLengthValue
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        GROUP BY Parent.Type]){
    
                                                            for (AggregateResult ar : results) {
                                                                NAMObjectCount oc = new NAMObjectCount(ar);
                                                                quantities.add(oc);
                                                            }
                                                        }
    
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND bodyLength != 0
                                                         AND bodyLength <= :bodyLengthValue
                                                         AND (Parent.Type = :differentType)
                                                         AND lastModifiedDate >= :dtstart
                                                         AND lastModifiedDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                    quantities.add(oc);
                                }
                            }
                        }
    
                    }
    
                } else {
                    if(byCreateDate){
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                        AND bodyLength != 0
                                                        AND createdDate >= :dtstart
                                                        AND createdDate <= :dtend
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        GROUP BY Parent.Type]){
    
                                                            for (AggregateResult ar : results) {
                                                                NAMObjectCount oc = new NAMObjectCount(ar);
                                                                quantities.add(oc);
                                                            }
                                                        }
    
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND bodyLength != 0
                                                         AND (Parent.Type = :differentType)
                                                         AND createdDate >= :dtstart
                                                         AND createdDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                    quantities.add(oc);
                                }
                            }
                        }
    
                    } else {
                        for(AggregateResult[] results :[SELECT Parent.Type ObjectName, COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                        FROM Attachment
                                                        WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                        AND bodyLength != 0
                                                        AND lastModifiedDate >= :dtstart
                                                        AND lastModifiedDate <= :dtend
                                                        AND (Parent.Type IN :PARENT_TYPE_GREENS OR Parent.Type IN :customobjects)
                                                        GROUP BY Parent.Type]){
    
                                                            for (AggregateResult ar : results) {
                                                                NAMObjectCount oc = new NAMObjectCount(ar);
                                                                quantities.add(oc);
                                                            }
                                                        }
    
                        for(String differentType : NAMUtils.OTHER_PARENT_TYPE_GREENS){
                            AggregateResult[] results = [SELECT COUNT(Name) Quantity, SUM(BodyLength) totalBytesSize
                                                         FROM Attachment
                                                         WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                                         AND bodyLength != 0
                                                         AND (Parent.Type = :differentType)
                                                         AND lastModifiedDate >= :dtstart
                                                         AND lastModifiedDate <= :dtend];
                            for (AggregateResult ar : results) {
                                Integer count = (Integer) ar.get('Quantity');
                                if(count>0){
                                    NAMObjectCount oc = new NAMObjectCount(ar,differentType);
                                    quantities.add(oc);
                                }
                            }
                        }
                    }
                }
    
            }
        }

        return quantities;
    }

    /**
* @description It looks for potential Salesforce internal error (Salesforce unmanaged errors) during
* conversion. We detected that some special characters makes the tool fail and we don't know when an
* Apex job got stuck, so we need to look for this kind of errors in Apex jobs proactively
* PRECONDITION: It requires a remote setting with the org base URL since we need to do a callout to query Apex logs
* @param className
* @param nameSpace
* @return the class id that provoked the error or '-1' If ther's no error
*/
    public static String detectInternalSalesforceError(String className, String nameSpace){
        List<NAMNoteConversionStatus__c> noteConversionStatus = NMTNoteConversionStatus.find();
        DateTime lastDate;
        if(noteConversionStatus!=null&&!noteConversionStatus.isEmpty()){
            lastDate = noteConversionStatus.get(0).LastModifiedDate;

            /* Updated 4/21/2021 for security re-review */
			if (Schema.sObjectType.ApexLog.isAccessible() &&
               Schema.sObjectType.ApexClass.isAccessible() &&
               Schema.sObjectType.AsyncApexJob.isAccessible()) {
                //select the logs with internal salesforce errors
                List<ApexLog> logsError = [SELECT Id FROM ApexLog Where status = :NAMUtils.INTERNAL_ERROR AND LastModifiedDate >= :lastDate ORDER BY StartTime DESC];
                if(logsError!=null && !logsError.isEmpty()){
    
                    HttpRequest req=new HttpRequest();
                    req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
                    req.setHeader('content-Type','application/json');
                    string domainUrl=URL.getSalesforceBaseUrl().toExternalForm();
                    for(ApexLog log:logsError){
                        System.debug('Log Internal Salesforce Error Id '+log.Id);
                        req.setEndpoint(domainUrl+'/services/data/v'+NAMUtils.API_VERSION+'/sobjects/ApexLog/'+log.Id+'/Body');
                        req.setMethod('GET');
                        Http h=new Http();
                        HttpResponse res=h.send(req);
                        if(res.getStatusCode()==200){
                            //read the body of the logs
                            String body = res.getBody();
                            System.debug('Log Body '+ body.contains(className));
                            //if one body contains the className, select the id of the class
                            if(body.contains(className)){
                                List<ApexClass> classesId = new List<ApexClass>();
                                /* SR note: user CRUD/FLS checks not appropriate here */
                                if(String.isEmpty(nameSpace)){
                                    classesId = [SELECT Id FROM ApexClass WHERE Name = :className LIMIT 1];
                                }else{
                                    classesId = [SELECT Id FROM ApexClass WHERE Name = :className AND NamespacePrefix = :nameSpace LIMIT 1];
                                }
                                if(classesId!=null && !classesId.isEmpty()){
                                    Integer jobsProcessed = 0;
                                    //Select the Job that is processing for that class
                                    List<AsyncApexJob> jobs = [SELECT Id, JobItemsProcessed, Status FROM AsyncApexJob WHERE ApexClassId = :classesId[0].id AND Status != 'Completed' AND Status != 'Aborted' ORDER BY CreatedDate DESC];
                                    if(jobs!=null&&!jobs.isEmpty()){
                                        return classesId[0].id;
                                    }
                                }
                            }
                        }
                    }
                }
               }
        }
        return '-1';
    }

    /**
* @description
* @param className
* @param nameSpace
* @param forcedTerminate
* @param isAttachment
*/
    public static void abortOperation(String className, String nameSpace, Boolean forcedTerminate,  Boolean isAttachment){
        /* Updated 4/21/2021 for security re-review */
			if (Schema.sObjectType.ApexClass.isAccessible() &&
               Schema.sObjectType.AsyncApexJob.isAccessible()) {
                List<ApexClass> classesId = new List<ApexClass>();
                if(String.isEmpty(nameSpace)){
                    classesId = [SELECT Id FROM ApexClass WHERE Name = :className LIMIT 1];
                }else{
                    classesId = [SELECT Id FROM ApexClass WHERE Name = :className AND NamespacePrefix = :nameSpace LIMIT 1];
                }
                if(classesId!=null && !classesId.isEmpty()){
                    Integer jobsProcessed = 0;
                    //Select the Job that is processing for that class
                    List<AsyncApexJob> jobs = [SELECT Id, JobItemsProcessed, Status FROM AsyncApexJob WHERE ApexClassId = :classesId[0].id AND Status != 'Completed' AND Status != 'Aborted' ORDER BY CreatedDate DESC];
                    if(jobs!=null&&!jobs.isEmpty()){
                        for(AsyncApexJob job:jobs){
                            //Abort that Job
                            String jobId = job.id;
                            System.abortJob(jobId.substring(0, 15));
                        }
                        if(isAttachment){
                            ATFAttachmentConversionStatus.deleteAllAttachmentConversionStatus();
                        } else {
                            NMTNoteConversionStatus.changeStatus('Completed', null,'Convertion');
                        }
                    }
                }
            }
            if(forcedTerminate){
                if(isAttachment){
                    ATFAttachmentConversionStatus.deleteAllAttachmentConversionStatus();
                } else {
                    NMTNoteConversionStatus.deleteAllNoteConversionStatus();
                }
            }
    }

    public static List<ContentDocument> lastContentDocument(Integer theLimit, Integer theOffset){
        /* Updated 4/21/2021 for security re-review */
		if (Schema.sObjectType.ContentDocument.isAccessible()) {
        	List<ContentDocument> lastConverted = [SELECT Id, Title, ContentModifiedDate, FileType, Owner.FirstName
                                               FROM ContentDocument
                                               ORDER BY ContentModifiedDate  DESC
                                               LIMIT :theLimit
                                               OFFSET :theOffset];
        	return lastConverted;
        } else {
            List<ContentDocument> emptydoc = new List<ContentDocument>();
            return emptydoc;
        }
    }


    /**
* @description
* @param theLimit
* @param theOffset
* @return
*/
    public static List<NAMAttchmentWrapper> lastAttachments(Integer theLimit, Integer theOffset, Date startdate, Date endDate, Boolean migrated){

        List<NAMAttchmentWrapper> lastAttachments = new List<NAMAttchmentWrapper>();
        
        /* Updated 4/21/2021 for security re-review */
		if (Schema.sObjectType.Attachment.isAccessible()) {
            String[] customobjects = getCustomObject();
            Time firstTime = Time.newInstance(0, 0, 0, 0);
            Time endTime = Time.newInstance(23, 59, 59, 0);
    
            DateTime dtstart = DateTime.newInstance(startDate,firstTime);
            DateTime dtend = DateTime.newInstance(endDate,endTime);
    
            if(migrated){
                for (Attachment attachment : [SELECT Id,  Parent.Type, ParentId, Name, CreatedDate, BodyLength, Owner.FirstName
                                              FROM Attachment
                                              WHERE Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN
                                              AND createdDate >= :dtstart
                                              AND createdDate <= :dtend
                                              ORDER BY LastModifiedDate DESC
                                              LIMIT :theLimit
                                              OFFSET :theOffset]){
                                                  boolean supported = checkIfObjectIsSupported(attachment.Parent.Type, attachment.BodyLength, attachment.Id);
    
                                                  if(!supported){
                                                      String parentType = attachment.Parent.Type;
                                                      for(String differentType : OTHER_PARENT_TYPE_GREENS){
                                                          List<Attachment> attachments = [SELECT Id FROM Attachment WHERE Id = :attachment.Id AND (Parent.Type = :differentType) LIMIT 1];
    
                                                          if(attachments.size() > 0){
                                                              supported = true;
                                                              parentType = differentType;
    
                                                          }
                                                      }
                                                      lastAttachments.add(new NAMAttchmentWrapper(attachment.Id, attachment.Name, attachment.ParentId, parentType, attachment.Owner.FirstName, attachment.BodyLength, attachment.CreatedDate, supported));
    
    
                                                  } else {
                                                      lastAttachments.add(new NAMAttchmentWrapper(attachment.Id, attachment.Name, attachment.ParentId, attachment.Parent.Type, attachment.Owner.FirstName, attachment.BodyLength, attachment.CreatedDate, supported));
                                                  }
                                              }
    
    
            } else {
                for (Attachment attachment : [SELECT Id,  Parent.Type, ParentId, Name, CreatedDate, BodyLength, Owner.FirstName
                                              FROM Attachment
                                              WHERE (NOT Name LIKE :MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN)
                                              AND createdDate >= :dtstart
                                              AND createdDate <= :dtend
                                              ORDER BY LastModifiedDate DESC
                                              LIMIT :theLimit
                                              OFFSET :theOffset]){
                                                  boolean supported = checkIfObjectIsSupported(attachment.Parent.Type, attachment.BodyLength, attachment.Id);
    
                                                  if(!supported){
                                                      String parentType = attachment.Parent.Type;
                                                      for(String differentType : OTHER_PARENT_TYPE_GREENS){
                                                          List<Attachment> attachments = [SELECT Id FROM Attachment WHERE Id = :attachment.Id AND (Parent.Type = :differentType) LIMIT 1];
    
                                                          if(attachments.size() > 0){
                                                              supported = true;
                                                              parentType = differentType;
    
                                                          }
                                                      }
                                                      lastAttachments.add(new NAMAttchmentWrapper(attachment.Id, attachment.Name, attachment.ParentId, parentType, attachment.Owner.FirstName, attachment.BodyLength, attachment.CreatedDate, supported));
    
    
                                                  } else {
                                                      lastAttachments.add(new NAMAttchmentWrapper(attachment.Id, attachment.Name, attachment.ParentId, attachment.Parent.Type, attachment.Owner.FirstName, attachment.BodyLength, attachment.CreatedDate, supported));
                                                  }
    
    
    
                                              }
    
            }
        }
        return lastAttachments;

    }

    public static List<User> checkUserId(String userId){
        /* Updated 4/21/2021 for security re-review */
		if (Schema.sObjectType.User.isAccessible()) {
    		List<User> user = [SELECT Id, IsActive, FirstName, LastName FROM User WHERE Id= :userId LIMIT 1];
        	return user;
        } else {
            List<User> user = new List<User>();
            return user;
        }
    }


    public static Boolean checkIfObjectIsSupported(String objectType, Decimal body, String attachmentId){
        if(body <= 0){
            return false;
        }

        if(objectType != null && objectType.toLowerCase().endsWith('_c')){
            return true;
        } else{
            if(objectType != null){
                for(String objectTypeName : PARENT_TYPE_GREENS){
                    if(objectTypeName.equalsIgnoreCase(objectType)){
                        return true;
                    }
                }

                for(String objectTypeName : OTHER_PARENT_TYPE_GREENS ){
                    if(objectTypeName.equalsIgnoreCase(objectType)){
                        return true;
                    }
                }

                for(String objectTypeName : OTHER_PARENT_TYPE_GREENS_PREFIX ){
                    if(objectTypeName.equalsIgnoreCase(objectType)){
                        return true;
                    }
                }
            }

            return false;
        }
    }

    /**
* @description
* @param theLimit
* @param theOffset
* @return
*/
    public static List<AsyncApexJob> loadApexJobs(Integer theLimit, Integer theOffset){
		/* Updated 4/21/2021 for security re-review */
		if (Schema.sObjectType.ApexClass.isAccessible() &&
           Schema.sObjectType.AsyncApexJob.isAccessible()) {
            String name = NMTMigratorBatch.class.getName();
            String nameAttachment = ATFMigratorBatch.class.getName();
            String nameSpace = '';
            String nameSpaceAttachment = '';
            List<ApexClass> className = new List<ApexClass>();
            List<ApexClass> classNameAttachment = new List<ApexClass>();
            if(name.contains('.')){
                nameSpace = name.substringBefore('.');
                name = name.substringAfter('.');
                className = [SELECT id FROM ApexClass WHERE name = :name AND namespaceprefix=:namespace LIMIT 1];
            }else{
                className = [SELECT id FROM ApexClass WHERE name = :name LIMIT 1];
            }
    
            if(nameAttachment.contains('.')){
                nameSpaceAttachment = nameAttachment.substringBefore('.');
                nameAttachment = nameAttachment.substringAfter('.');
                classNameAttachment = [SELECT id FROM ApexClass WHERE name = :nameAttachment AND namespaceprefix=:nameSpaceAttachment LIMIT 1];
            }else{
                classNameAttachment = [SELECT id FROM ApexClass WHERE name = :nameAttachment LIMIT 1];
            }
    
            //If an error is thrown during change of status, job (AsyncApexJob) status will be 'Completed'
            //In progress label will be hidden anyway
            List<AsyncApexJob> jobs = [SELECT ApexClass.Name, ApexClassID , Status, ExtendedStatus, JobType, CompletedDate,
                                       JobItemsProcessed, MethodName, NumberOfErrors, TotalJobItems
                                       FROM AsyncApexJob
                                       WHERE (ApexClassID  = :className.get(0).Id
                                              OR ApexClassID  = :classNameAttachment.get(0).Id)
                                       AND JobType = 'BatchApex'
                                       ORDER BY CreatedDate DESC
                                       LIMIT :theLimit
                                       OFFSET :theOffset];
            return jobs;
        } else {
            List<AsyncApexJob> jobs = new List<AsyncApexJob>();
            return jobs;
        }

    }

    public static List<ApexTrigger> loadTriggers(Integer theLimit, Integer theOffset){
        List<String> names = new List<String>();
        String name = Attachment.sObjectType.getDescribe().getName();
        names.add(name);
        name = ContentDocumentLink.sObjectType.getDescribe().getName();
        names.add(name);
        name = ContentVersion.sObjectType.getDescribe().getName();
        names.add(name);
        name = Note.sObjectType.getDescribe().getName();
        names.add(name);
        name = ContentDocument.sObjectType.getDescribe().getName();
        names.add(name);

        /* Updated 4/21/2021 for security re-review */
		if (Schema.sObjectType.ApexTrigger.isAccessible()) {
        	List<ApexTrigger> triggers = [SELECT Name, TableEnumOrId, NamespacePrefix, ApiVersion, Status, IsValid
                                      FROM ApexTrigger
                                      WHERE (TableEnumOrId IN :names)
                                      AND Status = 'Active'
                                      AND (NOT Name LIKE 'NMTNotesDeletionTrigger')
                                      ORDER BY TableEnumOrId ASC
                                      LIMIT :theLimit
                                      OFFSET :theOffset];
            return triggers;
        } else {
            List<ApexTrigger> triggers = new List<ApexTrigger>();
            return triggers;
        }

    }

    public static List<CronTrigger> loadScheduledJobs(Integer theLimit, Integer theOffset){
		/* Updated 4/21/2021 for security re-review */
		if (Schema.sObjectType.ApexTrigger.isAccessible()) {
        	List<CronTrigger> scheduledJobs = [SELECT CronJobDetail.Name, NextFireTime, CreatedBy.Name
                                           FROM CronTrigger
                                           WHERE CronJobDetail.Name LIKE 'MigratorBatch%' OR CronJobDetail.Name LIKE 'NMTMigratorBatch%'
                                           ORDER BY CreatedDate DESC
                                           LIMIT :theLimit
                                           OFFSET :theOffset];
            return scheduledJobs;
        } else {
            List<CronTrigger> scheduledJobs = new List<CronTrigger>();
            return scheduledJobs;
        }
    }

    /**
* @description Used for csv column is Private
* @param isPrivate
* @return 'Yes' or 'No' depending on isPrivate param
*/
    public static String isPrivateResult (Boolean isPrivate){
        if(isPrivate){
            return 'Yes';
        } else {
            return 'No';
        }
    }

    public static Boolean isEditionSupported (String orgType){
        return !orgType.equalsIgnoreCase('Professional Edition');
    }
    
    /*
     * Method used to know if the data has been synchronized by the config
     * Maybe the org is new and doesn't need synchronization, the config can't be set to true this time because it implies a DML operation not allowed in this class
     */
    public static Boolean isDataSynchronized(){
        Boolean dataSync = NAMConfigs.getDataSynchronized();
        /* Updated 4/21/2021 for security re-review */
		if (Schema.sObjectType.ContentDocument.isAccessible()) {
            if(!dataSync){
                List<ContentDocument> cds = [SELECT Id FROM ContentDocument WHERE latestPublishedVersion.LegacyNoteConvertedId__c != null AND latestPublishedVersion.LegacyNoteConvertedDate__c != null LIMIT 1];
                if(cds!=null && cds.size()==0){
                    dataSync = true;
                }
            }
        } 
        return dataSync;
    }
}