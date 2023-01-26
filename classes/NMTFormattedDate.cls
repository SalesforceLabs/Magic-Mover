public class NMTFormattedDate {
    
    public Date fDateStart { get; set; } //property that reads the date value from the component attribute tag for start date
    
    public Date fDateEnd { get; set; } //property that reads the date value from the component attribute tag for end date
    
    public String getFormattedDate() {
        String startDate;
        String endDate;
        if (fDateStart == null) { //if no date_time value is provided
            startDate = ''; //return blank string
        } else { //otherwise, a date_time value was provided
            startDate = fDateStart.format(); //return the full date for the user based upon the locale and time zone (the format() method provides the string in the running user's time zone and locale)
        }
        if (fDateEnd == null) { //if no date_time value is provided
            endDate = ''; //return blank string
        } else { //otherwise, a date_time value was provided
            endDate = fDateEnd.format(); //return the full date for the user based upon the locale and time zone (the format() method provides the string in the running user's time zone and locale)
        }
        
        return 'Date '+startDate+' to '+endDate;
    }
}