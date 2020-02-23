@NamespaceAccessible
public inherited sharing class EntityErrorRecordValidation implements IEntityError {

    private SObjectValidationResult validationResult;

    public EntityErrorRecordValidation(SObjectValidationResult objectValidationResult) {
        this.validationResult = objectValidationResult;
    }

    public List<String> getFields() {
        return validationResult.fields;
    }

    public EntityErrorTypes getType() {
        return EntityErrorTypes.ENTITY_VALIDATION;
    }

    public List<String> getMessages() {
        return validationResult.messages;
    }

}
