/**
 * Defines a contract for objects that need to be observe any change.
 * This interfaces is used to implements Observer design pattern.
 * Well known change detection pattern.
 */
@NamespaceAccessible
public interface IObservable {
    void addObserver(IObserver observer);
}
