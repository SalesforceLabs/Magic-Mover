@isTest
public class NAMConfigControllerTest {
    @isTest 
    static void construct() {
        NAMConfigController controller = new NAMConfigController();
        controller.changeConfigs();
        Boolean valuePrevious = controller.getDisablePrevious();
        controller.getDisableNext();
        controller.Next();
        controller.Previous();
        String v = controller.version;
        System.assertEquals(valuePrevious, true);
    }
    
    @isTest 
    static void construct2() {
        NAMConfigController controller = new NAMConfigController();
        controller.getEmptyScheduledJobs();
        controller.getEmptyTriggers();
        controller.getEmptyApexJobs();
        
        controller.getScheduledJobsDisableNext();
        controller.getScheduledJobsDisablePrevious();
        controller.ScheduledJobsNext();
        controller.ScheduledJobsPrevious();
        
        controller.getTriggersDisableNext();
        controller.getTriggersDisablePrevious();
        controller.TriggersNext();
        controller.TriggersPrevious();
        String v = controller.version;
        System.assertEquals(v.length() > 0, true);
    }
    
    @isTest 
    static void construct3() {
        NAMConfigController controller = new NAMConfigController();
        controller.resetNotesConversion();
        controller.resetAttachmentsConversion();
        controller.changeConfigs();
        controller.enableOwner = true;
        controller.changeConfigs();
        controller.enableOwnerFromTo = true;
        controller.changeConfigs();
        String v = controller.version;
        System.assertEquals(v.length() > 0, true);
        
    }

}