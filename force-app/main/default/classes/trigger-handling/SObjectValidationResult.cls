global inherited sharing class SObjectValidationResult {
    public List<String> fields;
    public Boolean isSuccess;
    public List<String> messages;

    global SObjectValidationResult(Boolean isSuccess, String msg) {
        this.isSuccess = isSuccess;
        this.messages = new List<String>{msg};
    }

    global SObjectValidationResult(Boolean isSuccess, List<String> fields, String msg) {
        this.isSuccess = isSuccess;
        this.fields = fields;
        this.messages = new List<String>{msg};
    }

    global SObjectValidationResult(Boolean isSuccess, List<String> fields, List<String> msgs) {
        this.isSuccess = isSuccess;
        this.fields = fields;
        this.messages = msgs;
    }
}
