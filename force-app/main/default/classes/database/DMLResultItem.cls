/**
 * Represents an DML operation result for either INSERT, UPDATE or DELETE
 */
public inherited sharing class DMLResultItem {

    enum Types {
        INSERTZ, UPDATEZ, UPSERTZ, DELETEZ
    }

    /**
     * Represents an DML operation error
     */
    public class Error {
        public List<String> fields;
        public String message;
        public StatusCode statusCode;

        private Error() {
            this.fields = new List<String>();
        }

        public Error(Database.Error error) {
            this();
            this.fields = error.getFields();
            this.message = error.getMessage();
            this.statusCode = error.getStatusCode();
        }
    }

    public Id recordId { get; protected set; }
    public Boolean isSuccess { get; protected set; }
    public Error[] errors { get; protected set; }

    private DMLResultItem() {
        this.errors = new List<Error>();
    }

    /**
     * Database.SaveResult, Database.UpsertResult, Database.DeleteResult are classes with private constructor.
     * Use this constructor to mock database result instances.
     *
     * @param recordId
     * @param isSuccess
     * @param errors
     */
    @TestVisible
    private DMLResultItem(Id recordId, Boolean isSuccess, Error[] errors) {
        this();
        this.recordId = recordId;
        this.isSuccess = isSuccess;
        this.errors = errors;
    }

    public DMLResultItem(Database.SaveResult result) {
        this();
        this.recordId = result.getId();
        this.isSuccess = result.isSuccess();
        for (Database.Error error : result.getErrors()){
            this.errors.add(new Error(error));
        }
    }

    public DMLResultItem(Database.UpsertResult result) {
        this();
        this.recordId = result.getId();
        this.isSuccess = result.isSuccess();
        for (Database.Error error : result.getErrors()){
            this.errors.add(new Error(error));
        }
    }

    public DMLResultItem(Database.DeleteResult result) {
        this();
        this.recordId = result.getId();
        this.isSuccess = result.isSuccess();
        for (Database.Error error : result.getErrors()){
            this.errors.add(new Error(error));
        }
    }
}
