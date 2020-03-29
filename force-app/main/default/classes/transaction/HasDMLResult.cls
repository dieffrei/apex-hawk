/**
 * Template class which defines that class contains Entity Errors
 */
@NamespaceAccessible
public abstract inherited sharing class HasDMLResult implements IHasDMLResult {

    private IEntity entity;

    public HasDMLResult(IEntity entity) {
        this.entity = entity;
    }

    public Boolean hasErrors() {
      return this.entity.getErrors().size() > 0;
    }

    public EntityErrorCollection getErrors() {
        return this.entity.getErrors();
    }

    public Id getRecordId() {
        return this.entity.getId();
    }
}
