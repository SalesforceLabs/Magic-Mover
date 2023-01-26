public class NMTDeployCallback implements Metadata.DeployCallback{

    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context){
        System.debug(result.details);
    }
}