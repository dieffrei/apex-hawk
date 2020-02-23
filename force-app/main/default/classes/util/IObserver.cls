/**
 *  Defines a contract for Objects that needs to Observe instances which implements IObservable interface
 */
@NamespaceAccessible
public interface IObserver {
    void onChange(EntityChangeEvent event);
}
