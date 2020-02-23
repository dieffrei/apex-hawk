@NamespaceAccessible
public inherited sharing class EntityErrorDML implements IEntityError {

    private DMLResultItem.Error error;

    public EntityErrorDML(DMLResultItem.Error error) {
        this.error = error;
    }

    public List<String> getFields() {
        return this.error.fields;
    }

    public EntityErrorTypes getType() {
        return EntityErrorTypes.ENTITY_VALIDATION;
    }

    public List<String> getMessages() {
        return new List<String>{error.message};
    }

}
