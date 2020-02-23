public inherited sharing class DMLInsertCommand extends DMLCommand {

    public DMLInsertCommand(Map<Schema.SObjectType, SObjectDMLSettings> sObjectDmlSettings, DMLCommandCollection dmlCommandCollection,
        Map<SObjectType, DMLRelationships> relationships) {
        super(sObjectDmlSettings, dmlCommandCollection, relationships, 'INSERT');
    }

    public Map<IEntity, DMLResultItem> execute(IDML entityDMLService, List<IEntity> records) {
        return entityDMLService.dmlInsert(records);
    }
}
