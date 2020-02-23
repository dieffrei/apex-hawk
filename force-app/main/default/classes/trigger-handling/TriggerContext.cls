public inherited sharing class TriggerContext {

    private List<SObject> newObjectsList;
    private Map<Id, SObject> newObjectsMap;
    private Map<Id, SObject> oldObjectsMap;
    private SObjectType objectType;

    public List<SObject> records { get {return newObjectsList != null ? newObjectsList : this.newObjectsMap.values();} }
    public TriggerEventTypes type { get; private set; }

    public TriggerContext(TriggerEventTypes type, List<SObject> newObjects) {
        this.newObjectsList = newObjects;
        this.type = type;
    }

    public TriggerContext(TriggerEventTypes type, List<SObject> newObjects, List<SObject> oldObjects) {
        this.newObjectsMap = new Map<Id, SObject>(newObjects);
        this.oldObjectsMap = new Map<Id, SObject>(oldObjects);
        this.type = type;
    }

    public TriggerContext(TriggerEventTypes type, Map<Id, SObject> newObjects, Map<Id, SObject> oldObjects) {
        this.newObjectsMap = newObjects;
        this.oldObjectsMap = oldObjects;
        this.type = type;
    }

    public SObjectType getSObjectType() {
        if (objectType != null) {
            return objectType;
        }
        objectType = newObjectsList != null && !newObjectsList.isEmpty() ? newObjectsList[0].getSObjectType() : null;
        if (objectType == null && newObjectsMap != null && !newObjectsMap.isEmpty()) {
            objectType = newObjectsMap.values()[0].getSObjectType();
        }
        if (objectType == null && oldObjectsMap != null && !oldObjectsMap.isEmpty()) {
            objectType = oldObjectsMap.values()[0].getSObjectType();
        }
        if (objectType == null) {
            throw new TypeException('Cannot determine SObjectType from empty trigger');
        }
        return objectType;
    }

    public Boolean isNewObject(SObject obj) {
        return obj.Id == null || (oldObjectsMap != null && oldObjectsMap.containsKey(obj.Id));
    }

    public Boolean isFieldChanged(SObject obj, Schema.SObjectField field) {
        return isFieldChanged(obj, String.valueOf(field));
    }

    public Boolean isFieldChanged(SObject obj, String field) {
        if (!obj.isSet(field)) {
            return false;
        }
        if (obj.Id == null) {
            return true;
        }
        SObject oldObject = oldObjectsMap != null ? oldObjectsMap.get(obj.Id) : null;
        if (oldObject == null) {
            return true;
        }
        return oldObject.get(field) != obj.get(field);
    }

    public Object getOldFieldValue(SObject obj, Schema.SObjectField field) {
        SObject old = getOld(obj);
        if (old != null) {
            return old.get(field);
        }
        return null;
    }

    public SObject getOld(SObject obj) {
        if (obj.Id == null || oldObjectsMap == null) {
            return null;
        }
        return oldObjectsMap.get(obj.Id);
    }

}
