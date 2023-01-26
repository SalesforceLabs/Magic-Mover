/**
* @author Dayana Daniel
*/

public class NAMRollupService {
    
    /**
* @description It does a request to Tooling API in order to know If we are authorized to do callouts.
* Otherwise we'll need to create a remote setting
* @return true If we are able to do requests using Tooling API
*/
    public static Boolean checkRemoteSetting(){
        try {
            checkRemoteSettingForCallouts();
            return true;
        } catch (System.CalloutException e) {
            System.debug('Error doing toolling API request. Error message: '+e.getMessage()+'. Stack trace: '+e.getStackTraceString()+'. Verify also IP restrictions.');
            return false;
        }
    }
    
    public static void checkRemoteSettingForCallouts(){
        //for test environments
            if (test.isRunningTest()) {
                Test.setMock(HTTPCalloutMock.class, new NMTRetrieveMetadataMock());
            }
            HttpRequest req=new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            req.setHeader('content-Type','application/json');
            string domainUrl=URL.getSalesforceBaseUrl().toExternalForm();
            
            //in the endpoint we specify a query with a green list because there are some objects that can't have one or more of the related lists
            req.setEndpoint(domainUrl+'/services/data/v'+NamUtils.API_VERSION+'/tooling/query/?q=Select+Name+from+Layout+limit+'+1);
            req.setMethod('GET');
            Http h=new Http();
            HttpResponse res=h.send(req);
    }
}