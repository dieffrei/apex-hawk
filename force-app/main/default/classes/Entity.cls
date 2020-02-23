@NamespaceAccessible
public abstract inherited sharing class Entity implements IEntity, IObservable, IObserver {

    public static String RECORD_TYPE_NOT_FOUND_FOR_SOBJECT_TYPE = 'Record type {0} can not found for SObject Type {1}';
    public static String RECORDTYPE_FIELD_ID_API_NAME = 'RecordTypeId';

    public Id id {
        get {
            return (Id) get('Id');
        }
    }

    @TestVisible
    transient private List<IObserver> observers;

    @TestVisible
    transient private List<EntityChangeEvent> events;

    @TestVisible
    transient private List<IValidator> validators;

    @TestVisible
    transient private EntityErrorCollection errors;

    @TestVisible
    private SObject record;

    @TestVisible
    transient private SObjectType sObjectType;

    protected Entity() {
        this.observers = new List<IObserver>();
        this.events = new List<EntityChangeEvent>();
        this.validators = new List<IValidator>();
        this.errors = new EntityErrorCollection();
    }

    public Entity(SObjectType sObjectType) {
        this();
        this.setupValidation();
        this.record = sObjectType.newSObject();
        this.sObjectType = sObjectType;
        this.fireEvent(new EntityNewEvent());
    }

    public Entity(SObjectType sObjectType, String recordTypeDeveloperName) {
        this(sObjectType);
        Map<String, RecordTypeInfo> recordTypes = fflib_SObjectDescribe.getDescribe(sObjectType)
            .getDescribe()
            .getRecordTypeInfosByDeveloperName();

        if (recordTypes.containsKey(recordTypeDeveloperName)) {
            this.record.put(RECORDTYPE_FIELD_ID_API_NAME, recordTypes.get(recordTypeDeveloperName).getRecordTypeId());
        } else {
            throw new EntityException(String.format(RECORD_TYPE_NOT_FOUND_FOR_SOBJECT_TYPE, new Object[]{
                recordTypeDeveloperName, sObjectType
            }));
        }
    }

    public Entity(SObject record) {
        this();
        if (record == null) {
            throw new EntityException('Record parameter can not be null');
        }
        this.setupValidation();
        this.record = record;
        this.sObjectType = record.getSObjectType();
        this.validateBeforeConstruct();
        if (record.Id == null) {
            this.fireEvent(new EntityNewEvent());
        }
    }



    public SObjectType getSObjectType() {
        return this.sObjectType;
    }

    protected virtual void setupValidation() {
    }

    /**
     * Run all validators (beforeConstruct type)
     */
    protected virtual void validateBeforeConstruct() {
        this.errors.clear();
        for (IValidator validator : this.validators) {
            if (validator instanceof IBeforeCreateEntity) {
                SObjectValidationResult validationResult = validator.validate();
                if (!validationResult.isValid) {
                    this.errors.add(new EntityErrorRecordValidation(validationResult));
                }
            }
        }
    }

    public void addError(IEntityError error) {
        this.errors.add(error);
    }

    public void addError(Exception ex) {
        this.errors.add(new EntityError(ex.getMessage()));
    }

    public void addError(EntityException ex){
        this.errors.add(new EntityError(ex));
    }

    /**
     * Get all constraint validations
     *
     * @return
     */
    public EntityErrorCollection getErrors() {
        return this.errors;
    }

    public Boolean hasErrors() {
        return this.errors.size() > 0;
    }

    public Id getId() {
        return this.id;
    }

    /**
     * Get is protected, because we dont want to expose all data, we want to make sure that entities change states for a reason.
     * It helps to rid of from https://martinfowler.com/bliki/AnemicDomainModel.html
     *
     * @param field
     *
     * @return
     */
    @TestVisible
    protected Object get(SObjectField field) {
        if (this.record == null) {
            return null;
        }
        return this.record.get(field);
    }

    private Object get(String field) {
        if (this.record == null) {
            return null;
        }
        return this.record.get(field);
    }

    /**
     * Set parent record Id
     * It is used on SFTransaction on parent-child relationship DMLs
     * @see DMLRelationship
     *
     * @param parentRecordField
     * @param parentId
     */
    public void setParent(SObjectField parentRecordField, Id parentId) {
        this.put(parentRecordField, parentId);
    }

    public void addValidator(IValidator validator) {
        this.validators.add(validator);
    }

    /**
     * Set value on a record on an specific field.
     * It dispatch FieldChangeValueEvent for every field value change.
     *
     * @param field
     * @param value
     */
    @TestVisible
    protected void put(SObjectField field, Object value) {
        // just in case if field was not queried
        // and prevent non queried field exception
        if (!this.record.getPopulatedFieldsAsMap().containsKey(String.valueOf(field))){
            if (this.record.get(field) != value) {
                this.fireEvent(new EntityChangeSobjectFieldValueEvent(field, this.record.get(field), value));
            }
        } else {
            this.fireEvent(new EntityChangeSobjectFieldValueEvent(field, this.record.get(field), value));
        }
        this.record.put(field, value);
    }

    /**
     * Dispatch event and notify all observers
     *
     * @param event
     */
    public void fireEvent(EntityChangeEvent event) {
        this.events.add(event);
        this.notifyObservers(event);
    }

    /**
     * Notify all subscribed observers
     *
     * @param event
     */
    public void notifyObservers(EntityChangeEvent event) {
        for (IObserver observer : observers) {
            observer.onChange(event);
        }
    }

    public void addObserver(IObserver observer) {
        this.observers.add(observer);
    }

    /**
     * Handles all observable events
     *
     * @param event
     */
    public virtual void onChange(EntityChangeEvent event) {
        //
    }

    /**
     * Check if the a specific field was changed
     *
     * @param field
     *
     * @return
     */
    public Boolean isChanged(SObjectField field) {
        Boolean wasFieldChanged = false;
        for (EntityChangeEvent event : events) {
            if (event instanceof EntityChangeSobjectFieldValueEvent) {
                EntityChangeSobjectFieldValueEvent fieldValueEvent = (EntityChangeSobjectFieldValueEvent) event;
                if (fieldValueEvent.field == field) {
                    wasFieldChanged = true;
                }
            }
        }
        return wasFieldChanged;
    }

    /**
     * Check if the entity was changed
     * @return
     */
    public Boolean isDirty() {
        return !events.isEmpty();
    }

    /**
     * Runs all validators and return true if all runs successfully
     *
     * @return
     */
    public Boolean isValid() {
        Boolean isValid = true;
        for (IValidator validator : this.validators) {
            if (!validator.validate().isValid) {
                isValid = false;
                break;
            }
        }
        return isValid;
    }

    /**
     * Synchronize a DML error from <b>Database Level</b> level to Entity <b>Model Level</b>
     *
     * @param resultItem
     */
    public void synchronize(DMLResultItem resultItem) {
        if (!resultItem.isSuccess) {
            for (DMLResultItem.Error error : resultItem.errors) {
                this.addError(new EntityErrorDML(error));
            }
        }
    }

    override
    public String toString() {
        return String.format('Id={0}, SObjectType={1}, HasErrors={2}, IsDirty={3}, IsValid={4}, Errors={5}, Record={6}', new Object[]{
            this.id,
            this.getSObjectType(),
            this.hasErrors(),
            this.isDirty(),
            this.isValid(),
            this.getErrors(),
            JSON.serialize(this.record)
        });
    }

    public virtual SObject toSObject() {
        return record;
    }

}
