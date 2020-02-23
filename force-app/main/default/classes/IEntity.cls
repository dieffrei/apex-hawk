@NamespaceAccessible
public interface IEntity {
    SObjectType getSObjectType();
    SObject toSObject();
    Boolean isDirty();
    Boolean isValid();
    Id getId();
    void setParent(SObjectField parentRecordField, Id parentId);
    void addError(IEntityError error);
    void addError(Exception ex);
    void addError(EntityException ex);
    void synchronize(DMLResultItem resultItem);
    void addObserver(IObserver observer);
    void onChange(EntityChangeEvent event);
    EntityErrorCollection getErrors();
    Boolean hasErrors();
}
