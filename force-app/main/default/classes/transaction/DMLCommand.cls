public abstract inherited sharing class DMLCommand {

    @TestVisible
    private Logger logger;
    private Map<Schema.SObjectType, SObjectDMLSettings> sObjectDmlSettings;
    private DMLCommandCollection dmlCommandCollection;
    private Map<SObjectType, DMLRelationships> relationships;
    private String operationName;

    protected DMLCommand(Map<Schema.SObjectType, SObjectDMLSettings> sObjectDmlSettings, DMLCommandCollection dmlCommandCollection,
        Map<SObjectType, DMLRelationships> relationships, String operationName) {
            this.logger = new Logger();
            this.sObjectDmlSettings = sObjectDmlSettings;
            this.dmlCommandCollection = dmlCommandCollection;
            this.relationships = relationships;
            this.operationName = operationName;
    }

    public Map<IEntity, DMLResultItem> persist() {
         Map<IEntity, DMLResultItem> resultItems = new Map<IEntity, DMLResultItem>();
         for (SObjectDMLSettings dmlSettings : sObjectDmlSettings.values()) {
             if (dmlCommandCollection.hasSobjectType(dmlSettings.sObjectType)) {
                 if (relationships.containsKey(dmlSettings.sObjectType)) {
                     relationships.get(dmlSettings.sObjectType).resolve();
                 }
                 IDML entityDMLService = dmlSettings.usesCustomDMLImplementation() ? dmlSettings.getCustomDMLImplementation() : new DML();
                 Map<IEntity, DMLResultItem> insertResults = this.execute(entityDMLService, dmlCommandCollection.getBy(dmlSettings.sObjectType));
                 logDMLResult(dmlSettings.sObjectType, dmlSettings.usesCustomDMLImplementation() ? 'Custom' : operationName, insertResults);
                 resultItems.putAll(insertResults);
             }
         }
         return resultItems;

     }

    abstract Map<IEntity, DMLResultItem> execute(IDML entityDMLService, List<IEntity> records);

    /**
     *  Log DMl results for each DML Operation
     *
     * @param sObjectType
     * @param dmlOperation
     * @param insertResults
     */
    private void logDMLResult(Schema.SObjectType sObjectType, String dmlOperation, Map<IEntity, DMLResultItem> insertResults) {
        for (DMLResultItem result : insertResults.values()) {
            logger.debug('{0} \t {1} \t {2} \t IsSuccess={3} \t Errors={4}', new Object[]{
                String.valueOf(sObjectType).rightPad(10),
                String.valueOf(dmlOperation).rightPad(8),
                result.recordId == null ? 'null'.rightPad(18) : result.recordId,
                result.isSuccess,
                result.errors
            });
        }
    }

}
