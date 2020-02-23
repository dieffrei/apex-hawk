public class DMLRelationship implements IDMLRelationship {
    public IEntity entity;
    public Schema.SObjectField relatedToField;
    public IEntity relatedTo;

    public void resolve() {
        this.entity.setParent(this.relatedToField, this.relatedTo.getId());
    }
}
