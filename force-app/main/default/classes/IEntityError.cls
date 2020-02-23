@NamespaceAccessible
public interface IEntityError {
    EntityErrorTypes getType();
    List<String> getFields();
    List<String> getMessages();
}
