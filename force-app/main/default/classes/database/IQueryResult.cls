@NamespaceAccessible
public interface IQueryResult {
    Map<Id, IEntity> toMap();
    List<IEntity> toList();
    EntityCollection toCollection();
}
