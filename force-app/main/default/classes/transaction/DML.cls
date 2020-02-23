public virtual class DML implements IDML {

    private ILogger logger;

    public DML() {
        this.logger = new Logger();
    }

    protected List<SObject> toSObject(List<IEntity> entities) {
        List<SObject> records = new List<SObject>();
        for (IEntity entity : entities) {
            records.add(entity.toSObject());
        }
        return records;
    }

    public virtual Map<IEntity, DMLResultItem> dmlInsert(List<IEntity> entities) {
        Map<IEntity, DMLResultItem> resultItems = new Map<IEntity, DMLResultItem>();
        Integer i = 0;
        for (Database.SaveResult result : Database.insert(toSObject(entities), false)) {
            resultItems.put(entities[i], new DMLResultItem(result));
            i++;
        }
        return resultItems;
    }

    public virtual Map<IEntity, DMLResultItem> dmlUpdate(List<IEntity> entities) {
        Map<IEntity, DMLResultItem> resultItems = new Map<IEntity, DMLResultItem>();
        Integer i = 0;
        for (Database.SaveResult result : Database.update(toSObject(entities), false)) {
            resultItems.put(entities[i], new DMLResultItem(result));
            i++;
        }
        return resultItems;
    }

    public virtual Map<IEntity, DMLResultItem> dmlDelete(List<IEntity> entities) {
        Map<IEntity, DMLResultItem> resultItems = new Map<IEntity, DMLResultItem>();
        Integer i = 0;
        for (Database.DeleteResult result : Database.delete(toSObject(entities), false)) {
            resultItems.put(entities[i], new DMLResultItem(result));
            i++;
        }
        return resultItems;
    }

}
