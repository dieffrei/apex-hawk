global inherited sharing class SObjectValidationResult {
    public List<String> fields;
    public Boolean isValid;
    public List<String> messages;

    global SObjectValidationResult(Boolean isValid, String msg) {
        this.isValid = isValid;
        this.messages = new List<String>{msg};
    }

    global SObjectValidationResult(Boolean isValid, List<String> fields, String msg) {
        this.isValid = isValid;
        this.fields = fields;
        this.messages = new List<String>{msg};
    }

    global SObjectValidationResult(Boolean isValid, List<String> fields, List<String> msgs) {
        this.isValid = isValid;
        this.fields = fields;
        this.messages = msgs;
    }
}
