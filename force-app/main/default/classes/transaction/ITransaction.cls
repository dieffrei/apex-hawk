/**
 * Stores all Entity persistence commands
 */
@NamespaceAccessible
public interface ITransaction {

    /**
     * Register a entity to be saved
     * @param entity
     */
    void save(IEntity entity);

    /**
     * Register a entity to be saved.
     * After save the entity, it is going to update relatedToParentField with Entity.id
     * @param entity
     * @param relatedToParentField
     * @param relatedEntity
     */
    void save(IEntity entity, Schema.sObjectField relatedToParentField, IEntity relatedEntity);

    /**
     * Register an list of entities to be saved (insert/upsert/update)
     * @param entities
     */
    void save(List<IEntity> entities);

    /**
     *  Register an entity to be deleted
     * @param entity
     */
    void remove(IEntity entity);

    /**
     *  Register a list of entities to be deleted
     * @param entities
     */
    void remove(List<IEntity> entities);

    /**
     * Commit all entity DML commands
     * @return All DML Results
     */
    Map<IEntity, DMLResultItem> commitZ();

    /**
     * Set transaction that partial success records are not acceptable
     */
    ITransaction acceptsPartialSuccess();

    ITransaction dontThrowsExceptionIfFails();

    /**
     * Set transaction to output all messages
     *
     * @return
     */
    ITransaction verboseMode();

    void clear();
}
