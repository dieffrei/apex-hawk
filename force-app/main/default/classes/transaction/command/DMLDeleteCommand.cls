public inherited sharing class DMLDeleteCommand extends DMLCommand {

    public DMLDeleteCommand(Map<Schema.SObjectType, SObjectDMLSettings> sObjectDmlSettings, DMLCommandCollection dmlCommandCollection,
        Map<SObjectType, DMLRelationships> relationships) {
        super(sObjectDmlSettings, dmlCommandCollection, relationships, 'DELETE');
    }

    public Map<IEntity, DMLResultItem> execute(IDML entityDMLService, List<IEntity> records) {
        return entityDMLService.dmlDelete(records);
    }

}
