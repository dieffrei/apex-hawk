/**
 * Represents a collection of Entity Errors
 * It can be used when working on trigger.
 * SObject.addError() can be used only for record on trigger context.
 */
@NamespaceAccessible
public inherited sharing class EntityErrorCollection {

    private List<IEntityError> errors;

    public EntityErrorCollection() {
        this.errors = new List<IEntityError>();
    }

    public EntityErrorCollection(List<IEntityError> constraintViolations) {
        this();
        this.errors = constraintViolations;
    }

    /**
     * Synchronize errors from Entity level to DB error
     * Entity Abstraction --> SObject record
     *
     * @param record
     * @param constraintViolations`
     */
    public void synchronizeToSObject(SObject record) {
        for (IEntityError constraintViolation : this.errors) {
            for (String message : ((IEntityError) constraintViolation).getMessages()) {
                record.addError(message);
            }
        }
    }

    /**
     *
     *
     * @param field
     *
     * @return
     */
    public List<IEntityError> getByField(SObjectField field) {
        List<IEntityError> violations = new List<IEntityError>();
        for (IEntityError violation : this.errors) {
            String paramFieldName = String.valueOf(field);
            for (String fieldName : violation.getFields()) {
                if (fieldName == paramFieldName) {
                    violations.add(violation);
                }
            }
        }
        return violations;
    }

    public void add(IEntityError violation) {
        this.errors.add(violation);
    }

    public void clear() {
        this.errors.clear();
    }

    public Integer size() {
        return this.errors.size();
    }

    public List<IEntityError> toList() {
        return this.errors;
    }

}
