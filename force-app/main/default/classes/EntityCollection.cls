/**
 * An Abstract for a collection of entity classes
 */
@NamespaceAccessible
public virtual inherited sharing class EntityCollection extends Entity {

    private List<Entity> entities;

    public EntityCollection() {
        this.entities = new List<Entity>();
    }

    public EntityCollection(List<Entity> entities) {
        this.entities = entities;
    }

    /**
     * Get entities by Id
     *
     * @param entities
     * @param entityId
     *
     * @return
     */
    public Entity getById(Id entityId) {
        Entity selectedEntity = null;
        for (Entity entity : entities) {
            if (entity.id == entityId) {
                selectedEntity = entity;
                break;
            }
        }
        return selectedEntity;
    }

    /**
     * Get get the first match for given field and value
     *
     * @param field SobjectField token
     * @param value
     *
     * @return
     */
    public Entity getByField(SObjectField field, Object value) {
        Entity selectedEntity = null;
        for (Entity entity : entities) {
            if (entity.get(field) == value) {
                selectedEntity = entity;
                break;
            }
        }
        return selectedEntity;
    }

    /**
     * Add an entity to a collection
     *
     * @param entity
     */
    public void add(Entity entity) {
        if (entity == null) {
            throw new EntityException('Is not allowed to add null entities to entity collection.');
        }
        this.entities.add(entity);
    }

    /**
     * Convert collection to a list
     * @return
     */
    public List<Entity> toList() {
        return entities;
    }

    /**
     * @return Size of collection
     */
    public Integer size() {
        return this.entities.size();
    }

    /**
     * Synchronize DMLResults from Transaction to Entity.
     * If DMLResult fails it creates an EntityError
     *
     * @param resultItems
     */
    public void synchronize(List<DMLResultItem> resultItems) {
        for (DMLResultItem resultItem : resultItems) {
            IEntity entity = this.getById(resultItem.recordId);
            entity.synchronize(resultItem);
        }
    }

}
