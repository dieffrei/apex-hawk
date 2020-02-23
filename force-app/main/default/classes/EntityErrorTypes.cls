/**
 * Represents possible Entity error types.
 * <b>ENTITY_VALIDATION</b>: Errors are generated in case of entity validation fails
 * <b>ENTITY_MANUAL_EXCEPTION</b>: Errors add manually given some business logic
 * E.g Entity.addError(new EntityError(Account.Name, 'Name should have at least 10 chars....');
 * <b>DML</b>: Errors they are originated from failed database operations
 */
@NamespaceAccessible
public enum EntityErrorTypes {
    ENTITY_VALIDATION, ENTITY_MANUAL_EXCEPTION, DML
}
