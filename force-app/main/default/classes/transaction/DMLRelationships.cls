public  class DMLRelationships {

    private List<IDMLRelationship> relationships = new List<IDMLRelationship>();

    public void resolve() {
        for (IDMLRelationship relationship : relationships) {
            relationship.resolve();
        }
    }

    public void add(IEntity entity, Schema.SObjectField relatedToField, IEntity relatedTo) {
        DMLRelationship relationship = new DMLRelationship();
        relationship.entity = entity;
        relationship.relatedToField = relatedToField;
        relationship.relatedTo = relatedTo;
        relationships.add(relationship);
    }

}
