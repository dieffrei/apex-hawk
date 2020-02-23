/**
 * <b>Unit of work implementation</b>
 * Maintains a list of records affected by a business transaction and coordinates the writing out of changes and the resolution of concurrency problems.
 * @see https://martinfowler.com/eaaCatalog/unitOfWork.html
 */
@NamespaceAccessible
public virtual inherited sharing class SFTransaction implements ITransaction {

    @TestVisible
    private Map<Schema.SObjectType, SObjectDMLSettings> sObjectDmlSettings;

    @TestVisible
    private DMLCommandCollection entitiesToInsert;

    @TestVisible
    private DMLCommandCollection entitiesToUpdate;

    @TestVisible
    private DMLCommandCollection entitiesToDelete;

    @TestVisible
    private Logger logger;

    @TestVisible
    private Boolean isPartialSuccessMode = false;

    @TestVisible
    private Boolean verboseMode = false;

    @TestVisible
    private Boolean throwsExceptionIfFails = true;

    @TestVisible
    private Map<SObjectType, DMLRelationships> relationships;

    /**
     * Construct a SFTransaction based on SObjectType list
     * @param entitiesOrder List of SObjectDMLMapping. The sequence they are provided defines the sequence of dml operation will be executed.
     */
    public SFTransaction(Map<Schema.SObjectType, SObjectDMLSettings> sObjectDmlSettings) {
        if (sObjectDmlSettings == null || sObjectDmlSettings.size() < 1) {
            throw new TransactionException('entitiesOrder argument can not be null');
        }
        this.logger = new Logger();
        this.sObjectDmlSettings = sObjectDmlSettings;
        this.entitiesToInsert = new DMLCommandCollection();
        this.entitiesToUpdate = new DMLCommandCollection();
        this.entitiesToDelete = new DMLCommandCollection();
        this.relationships = new Map<SObjectType, DMLRelationships>();
    }

    private void checkSObjectTypeSupport(IEntity entity) {
        Objects.assertIsNotNull('entity', entity);
        SObjectType sObjectType = entity.getSObjectType();
        if (!this.sObjectDmlSettings.keySet().contains(sObjectType)) {
            throw new TransactionException(
                String.format('This transaction do not support [{0}] not supported.', new Object[]{
                    sObjectType
                }));
        }
    }

    /**
     * Clear all pending DML Commands
     */
    private void clear() {
        this.entitiesToInsert = new DMLCommandCollection();
        this.entitiesToUpdate = new DMLCommandCollection();
        this.entitiesToDelete = new DMLCommandCollection();
        this.relationships = new Map<SObjectType, DMLRelationships>();
    }

    @TestVisible
    protected SFTransaction(Map<Schema.SObjectType, SObjectDMLSettings> sObjectTypes, IDML dml) {
        this(sObjectTypes);
    }

    /**
     * Register a Entity state to be persisted in database
     *
     * @param entity
     */
    public void save(IEntity entity) {
        if (entity == null) {
            throw new InvalidArgumentException('Entity reference argument is null');
        }
        this.save(new List<IEntity>{
            entity
        });
    }

    /**
     * TODO: improve documentation with some samples and better explanation
     * Register a Entity state to be persisted in database, and after create a record on database use the recordId and set to the relatedEntityParentField as a value
     *
     * @param entity
     * @param relatedToParentField
     * @param relatedEntity
     */
    public void save(IEntity entity, Schema.SObjectField relatedToParentField, IEntity relatedEntity) {
        Objects.assertIsNotNull('entity', entity);
        Objects.assertIsNotNull('relatedToParentField', relatedToParentField);
        Objects.assertIsNotNull('relatedEntity', relatedEntity);
        this.save(entity);
        this.registerRelationship(entity, relatedToParentField, relatedEntity);
    }

    /**
     *
     *
     * @param entities
     */
    public void save(List<IEntity> entities) {
        if (entities == null) throw new TransactionException('Entities can not be null');
        for (IEntity entity : entities) {
            checkSObjectTypeSupport(entity);
            if (entity.isDirty()) {
                if (entity.getId() == null) {
                    this.registerNew(entity);
                } else {
                    this.registerDirty(entity);
                }
            } else {
                this.logger.debug('Skipping entity persistence, It doesn\'t have any change to be update on db {0}', new Object[]{
                    entity
                });
            }
        }
    }

    /**
     * Register a Entity to be deleted
     *
     * @param entity
     */
    public void remove(IEntity entity) {
        checkSObjectTypeSupport(entity);
        this.remove(new List<IEntity>{
            entity
        });
    }

    /**
     * Register a list of  Entity to be deleted
     * @param entities
     */
    public void remove(List<IEntity> entities) {
        for (IEntity entity : entities) {
            checkSObjectTypeSupport(entity);
            this.registerDelete(entity);
        }
    }

    /**
     * @param entity
     */
    private void registerNew(IEntity entity) {
        checkSObjectTypeSupport(entity);
        this.entitiesToInsert.add(entity);
    }

    public void registerRelationship(IEntity entity, Schema.SObjectField relatedToField, IEntity relatedTo) {
        checkSObjectTypeSupport(entity);
        if (relationships.containsKey(entity.getSObjectType())) {
            relationships.get(entity.getSObjectType()).add(entity, relatedToField, relatedTo);
        } else {
            DMLRelationships newRelationShip = new DMLRelationships();
            newRelationShip.add(entity, relatedToField, relatedTo);
            relationships.put(entity.getSObjectType(), newRelationShip);
        }
    }

    /**
     *  Register an entity to update
     *
     * @param entity
     */
    private void registerDirty(IEntity entity) {
        checkSObjectTypeSupport(entity);
        this.entitiesToUpdate.add(entity);
    }

    /**
     *
     *
     * @param entity
     * @param relatedToField
     * @param relatedTo
     */
    private void registerDirty(IEntity entity, Schema.SObjectField relatedToField, IEntity relatedTo) {
        checkSObjectTypeSupport(entity);
        registerDirty(entity);
        registerRelationship(entity, relatedToField, relatedTo);
    }

    /**
     *  Register an entity to removal
     *
     * @param entity
     */
    private void registerDelete(IEntity entity) {
        checkSObjectTypeSupport(entity);
        this.entitiesToDelete.add(entity);
    }

    /**
     *  Commit operations to the database
     *
     *
     * @return DML results indexed by Entity
     */
    public Map<IEntity, DMLResultItem> commitZ() {

        Map<IEntity, DMLResultItem> resultItems = new Map<IEntity, DMLResultItem>();

        if (!hasSomethingToCommit()) {
            return resultItems;
        }

        if (verboseMode) {
            logSummaryDMLCommands();
        }

        Savepoint savepoint = Database.setSavepoint();

        try {

            logger.debug('##### Executing DMLS ########################');
            resultItems.putAll(new DMLInsertCommand(sObjectDmlSettings, entitiesToInsert, relationships).persist());
            resultItems.putAll(new DMLUpdateCommand(sObjectDmlSettings, entitiesToUpdate, relationships).persist());
            resultItems.putAll(new DMLDeleteCommand(sObjectDmlSettings, entitiesToDelete, relationships).persist());

        } catch (Exception ex) {
            logger.debug('Fatal error to try to commit: {0}', new List<Object>{
                ex.getMessage()
            });
            Database.rollback(savepoint);
            logger.debug('##### Database rollback done. #####');
            throw ex;
        } finally {

            // if any result fails and auto rollback activated...
            if (!isPartialSuccessMode && hasFailedResult(resultItems)) {
                Database.rollback(savepoint);
                logger.debug('##### isPartialSuccessMode=false, database rollback done. #####');
            } else {
                logger.debug('##### isPartialSuccessMode=true, all success results has been committed to database. #####');
            }

            //always sync results
            this.synchronizeDatabaseToEntities(resultItems);

            // if success clear
            if (!hasFailedResult(resultItems)) {
                clear();
            } else if (throwsExceptionIfFails){
                throw new TransactionException(resultItems);
            } else {
                logger.debug('!!!!!! Warning: transaction on throwExceptionIfFails=false !!!!');
            }

        }

        return resultItems;
    }

    private Boolean hasSomethingToCommit() {
        return (entitiesToInsert.size() > 0
            || entitiesToUpdate.size() > 0
            || entitiesToDelete.size() > 0);
    }

    private void logSummaryDMLCommands() {
        logger.debug('##### transaction overview #######################');

        for (SObjectType sType : entitiesToInsert.getSObjectTypes()) {
            logger.debug('INSERT: {0} - {1}', new Object[]{
                entitiesToInsert.getBy(sType).size(), sType
            });
        }

        for (SObjectType sType : entitiesToUpdate.getSObjectTypes()) {
            logger.debug('UPDATE/UPSERT: {0} - {1}', new Object[]{
                entitiesToUpdate.getBy(sType).size(), sType
            });
        }

        for (SObjectType sType : entitiesToDelete.getSObjectTypes()) {
            logger.debug('DELETE: {0} - {1}', new Object[]{
                entitiesToDelete.getBy(sType).size(), sType
            });
        }

    }


    private Boolean hasFailedResult(Map<IEntity, DMLResultItem> resultItems) {
        for (DMLResultItem dmlResultItem : resultItems.values()) {
            if (!dmlResultItem.isSuccess) {
                return true;
            }
        }
        return false;
    }

    /**
     * Synchronize Database Level errors to Entity layer level
     *
     * @param resultItems DML results
     */
    protected void synchronizeDatabaseToEntities(Map<IEntity, DMLResultItem> resultItems) {
        for (IEntity entity : resultItems.keySet()) {
            entity.synchronize(resultItems.get(entity));
        }
    }

    /**
     * Set transaction that partial success records are not acceptable
     */
    public ITransaction acceptsPartialSuccess() {
        this.isPartialSuccessMode = true;
        return this;
    }

    public ITransaction dontThrowsExceptionIfFails() {
        throwsExceptionIfFails = false;
        return this;
    }

    public ITransaction verboseMode() {
        verboseMode = true;
        return this;
    }

}
