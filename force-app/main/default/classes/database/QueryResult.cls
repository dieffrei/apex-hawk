/**
 * A Wrapper class for database results
 */
@NamespaceAccessible
public virtual inherited sharing class QueryResult implements IQueryResult {

    private List<SObject> records;
    private IEntityBuilder entityBuilder;

    /**
     *
     * @param entityBuilder IEntityBuilder enabled to created Entities based on a QueryResult
     * @param records List of database records
     */
    public QueryResult(IEntityBuilder entityBuilder, List<SObject> records) {
        this.entityBuilder = entityBuilder;
        this.records = records;
    }

    /**
     * Converts to Map
     *
     * @return An entities map indexed by Id
     */
    public Map<Id, IEntity> toMap() {
        Map<Id, IEntity> entities = new Map<Id, IEntity> ();
        for (SObject record : this.records) {
            IEntity customer = (IEntity) this.entityBuilder.build(record);
            entities.put(record.Id, customer);
        }
        return entities;
    }

    /**
     * Converts to a collection of entities
     *
     * @return
     */
    public EntityCollection toCollection() {
        EntityCollection collection = new EntityCollection();
        for (SObject record : this.records) {
            IEntity customer = (IEntity) this.entityBuilder.build(record);
            collection.add((Entity)customer);
        }
        return collection;
    }

    /**
     * Converts to a list of entity
     *
     * @return
     */
    public List<IEntity> toList() {
        List<IEntity> entities = new List<IEntity>();
        for (SObject record : this.records) {
            IEntity customer = (IEntity) this.entityBuilder.build(record);
            entities.add(customer);
        }
        return entities;
    }

}
