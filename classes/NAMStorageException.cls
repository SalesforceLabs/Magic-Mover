//Used to catch Storage exceptions and stop batch

public class NAMStorageException extends Exception {
    /**
     * List of results to send by CSV
     */
    public List<NAMMigrationResults> migrationResultsException;
    
    public NAMStorageException(List<NAMMigrationResults> listMigration){
        
        this.migrationResultsException = listMigration;
    }

}