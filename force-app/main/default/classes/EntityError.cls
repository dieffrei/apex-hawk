/**
 * Entity errors are created from two sources:
 *  - Database Level
 *      - When a transaction execute a DML operation, if Dml operation fails it created an @EntityErrorDML on respective Entity
 *  - Domain Level
 *      - When the Entity has been constructed, if any validation fails it will add a @EntityErrorRecordValidation on respective Entity,
 *      EntityError enstances can be added from domain level. E.g Entity.addError();
 */
@NamespaceAccessible
public inherited sharing class EntityError implements IEntityError {

    private List<String> fields;
    private List<String> messages;

    private EntityError() {
        this.fields = new List<String>();
        this.messages = new List<String>();
    }

    public EntityError(String field, String message) {
        this();
        this.fields.add(field);
        this.messages.add(message);
    }

    public EntityError(String message) {
        this();
        this.messages.add(message);
    }

    public EntityError(EntityException ex) {
        this();
        if (ex.fields != null) {
            this.fields.addAll(ex.fields);
        }
        this.messages.add(ex.getMessage());
    }

    /**
     * Related fields to the error
     *
     * @return
     */
    public List<String> getFields() {
        return this.fields;
    }

    /**
     * Level of error
     *
     * @return
     */
    public EntityErrorTypes getType() {
        return EntityErrorTypes.ENTITY_MANUAL_EXCEPTION;
    }

    public List<String> getMessages() {
        return this.messages;
    }

}
