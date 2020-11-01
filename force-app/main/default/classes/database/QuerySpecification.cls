/**
 * A abstract class which abstract the basic database retrieve operations based on @fflib_SObjectSelector
 */
@NamespaceAccessible
public abstract inherited sharing class QuerySpecification extends fflib_SObjectSelector implements IQuerySpecification {

    protected IEntityBuilder entityBuilder;
    protected fflib_QueryFactory queryFactory;

    protected QuerySpecification() {
        this.queryFactory = this.getBaseQueryFactory();
    }

    public QuerySpecification(IEntityBuilder entityBuilder, Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS);
        this.queryFactory = this.getBaseQueryFactory();
        this.entityBuilder = entityBuilder;
    }

    public QuerySpecification(IEntityBuilder entityBuilder) {
        this();
        this.queryFactory = this.getBaseQueryFactory();
        this.entityBuilder = entityBuilder;
    }

    public QuerySpecification(IEntityBuilder entityBuilder, Boolean includeFieldSetFields) {
        super(includeFieldSetFields, true, false);
        this.queryFactory = this.getBaseQueryFactory();
        this.entityBuilder = entityBuilder;
    }

    /**
     * Creates a new instance of query factory, which can be used to create a new repository query method
     *
     * @return
     */
    public fflib_QueryFactory getBaseQueryFactory() {
        return this.newQueryFactory();
    }

    /**
     * Enrich the records with the latest version of field values which are null.
     * Only null field values will be assigned.
     * It keeps the records reference, then it can be used on before triggers
     *
     * @param records
     *
     * @return
     */
    public virtual IQueryResult enrich(List<SObject> records) {
        Set<Id> ids = SObjectUtil.puckId(records);
        Map<Id, SObject> activeRecords = new Map<Id, SObject>(records);
        this.queryFactory.setCondition('id IN :ids');
        for (SObject dbRecord : Database.query(this.queryFactory.toSOQL())) {
            SObject activeRecord = activeRecords.get(dbRecord.Id);
            for (String fieldName : dbRecord.getPopulatedFieldsAsMap().keySet()) {
                if (!activeRecord.isSet(fieldName)) {
                    activeRecord.put(fieldName, dbRecord.get(fieldName));
                }
            }
        }
        return new QueryResult(this.entityBuilder, records);
    }

    /**
     * Query records by a set of Ids
     *
     * @param set of record ids
     *
     * @return Wrapper Result
     */
    public virtual IQueryResult byId(Set<Id> ids) {
        this.queryFactory.setCondition('Id IN :ids');
        return new QueryResult(this.entityBuilder,
            Database.query(this.queryFactory.toSOQL()));
    }

    /**
     * Query records by Id
     *
     * @param record id
     *
     * @return Wrapper Result
     */
    public virtual IQueryResult byId(Id id) {
        this.queryFactory.setCondition('Id =: id');
        return new QueryResult(this.entityBuilder,
            Database.query(this.queryFactory.toSOQL()));
    }

}
