/**
 *  Defines a common interface between @EntityError and @EntityCollection.
 */
public interface IHasDMLResult {
    Id getRecordId();
    EntityErrorCollection getErrors();
    Boolean hasErrors();
}
