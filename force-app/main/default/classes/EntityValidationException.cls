global with sharing class EntityValidationException extends Exception {

    private SObjectValidationResult validationResult;

    global EntityValidationException(SObjectValidationResult validationResult) {
        this.setMessage(String.valueOf(validationResult.messages));
        this.validationResult = validationResult;
    }
}
