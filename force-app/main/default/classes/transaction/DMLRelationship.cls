public class DMLRelationship implements IDMLRelationship {
    public IEntity entity;
    public Schema.SObjectField relatedToField;
    public IEntity relatedTo;

    public void resolve() {
        if (this.relatedTo.getId() == null) {
            throw new TransactionException(String.format('{0}.{1} is invalid. Relationship field value was not expected as null.', new Object[]{
                this.entity.getSObjectType()           ,
                this.relatedToField
            }));
        }
        this.entity.setParent(this.relatedToField, this.relatedTo.getId());
    }
}
