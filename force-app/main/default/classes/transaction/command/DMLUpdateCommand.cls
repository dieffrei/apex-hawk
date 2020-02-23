public inherited sharing class DMLUpdateCommand extends DMLCommand {

    public DMLUpdateCommand(Map<Schema.SObjectType, SObjectDMLSettings> sObjectDmlSettings, DMLCommandCollection dmlCommandCollection,
        Map<SObjectType, DMLRelationships> relationships) {
        super(sObjectDmlSettings, dmlCommandCollection, relationships, 'UPDATE/UPSERT');
    }

    public Map<IEntity, DMLResultItem> execute(IDML entityDMLService, List<IEntity> records) {
        return entityDMLService.dmlUpdate(records);
    }

}
