public with sharing class NAMlastConvertedController {
    
    public List<ContentDocument> lastConverted {get; set;}
    public Integer OffsetSize = 0;
    public Integer QueryLimit = NAMUtils.DEFAULT_LAST_PAGE_SIZE;
    public String sucessComumunityGroupURL {get; set;}
    public String appExchangeURL {get; set;}
    public String version {get{
        return NAMUtils.PACKAGE_VERSION_NAME;
    } set;}
    
    
    public NAMlastConvertedController(){
        
        sucessComumunityGroupURL = NAMUtils.SUCCESS_COMMUNITY_GROUP_URL;
        appExchangeURL = NAMUtils.APP_EXCHANGE_URL;
        loadLastContentDocument();
    }
    
    
    public PageReference loadLastContentDocument(){
        lastConverted = NAMUtils.lastContentDocument(QueryLimit, OffsetSize);
        return null;
    }
    
    public Boolean getDisablePrevious(){
        if(OffsetSize > 0){
            return false;
        }
        else return true;
    }
    
    public Boolean getDisableNext() {
        if(NAMUtils.lastContentDocument(QueryLimit,NAMUtils.DEFAULT_LAST_PAGE_SIZE + OffsetSize).size() > 0){
            return false;
            
        } else{
            return true;
            
        }
    }
    
     public PageReference Next() {
        OffsetSize += NAMUtils.DEFAULT_LAST_PAGE_SIZE;
        lastConverted = NAMUtils.lastContentDocument(QueryLimit, OffsetSize);
         system.debug('OffsetSize: ' + OffsetSize);
        return null;
    }
    
    public PageReference Previous() {
        OffsetSize -= NAMUtils.DEFAULT_LAST_PAGE_SIZE;
        lastConverted = NAMUtils.lastContentDocument(QueryLimit, OffsetSize);
        system.debug('OffsetSize: ' + OffsetSize);
        return null;
    }
    
    public Boolean getEmpty() { 
        return lastConverted.size() == 0;
    } 
    

}