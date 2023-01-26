/**
* @description class to wrapp common errors to suggest a solution to the admin.
* For example if we detect a trigger is failing we suggest review its behavior and deactivate It If necessary
* @author Dayana Daniel
*/

public class NAMTroubleshooting {
    
    public String errorCode {get; set;}
    public String cause {get; set;}
    public String solution {get; set;}
    
    public NAMTroubleshooting(String errorCode, String cause, String solution){
        this.errorCode = errorCode;
        this.cause = cause;
        this.solution = solution;
    }

}