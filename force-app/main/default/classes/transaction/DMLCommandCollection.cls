/**
 * A Entity DML Command Collection
 * It Stores all pending DML Commands in a transaction grouped by SObjectType
 */
public inherited sharing class DMLCommandCollection {

    private Map<SObjectType, List<IEntity>> entitiesBySObjectType;

    /**
     *
     */
    public DMLCommandCollection() {
        this.entitiesBySObjectType = new Map<SObjectType, List<IEntity>>();
    }

    /**
     * Add Entity
     *
     * @param entity
     */
    public void add(IEntity entity) {
        if (this.entitiesBySObjectType.containsKey(entity.getSObjectType())) {
            this.entitiesBySObjectType.get(entity.getSObjectType()).add(entity);
        } else {
            this.entitiesBySObjectType.put(entity.getSObjectType(), new List<IEntity>{
                entity
            });
        }
    }

    /**
     *
     *
     * @param sObjectType
     *
     * @return
     */
    public Boolean hasSobjectType(SObjectType sObjectType) {
        return this.entitiesBySObjectType.containsKey(sObjectType);
    }

    /**
     * Get all DML commands by SobjectType
     *
     * @param sObjectType
     *
     * @return
     */
    public List<IEntity> getBy(SObjectType sObjectType) {
        return this.entitiesBySObjectType.get(sObjectType);
    }

    /**
     * @return Number of DML Commands remaining to all Sobject Types
     */
    public Integer size() {
        return entitiesBySObjectType.size();
    }

    /**
     * @return List of SObject Types
     */
    public Set<SObjectType> getSObjectTypes() {
        return this.entitiesBySObjectType.keySet();
    }

    public override String toString() {
        return null;
    }
}
