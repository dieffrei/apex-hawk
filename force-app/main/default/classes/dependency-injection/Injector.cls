/**
 * A Dependency Injector based on Metadata Types.
 * It uses https://github.com/afawcett/force-di
 */
@NamespaceAccessible
public inherited sharing class Injector {

    /**
     *
     * @param interfaceType Type of interfaces which injector will looking for a implementation
     *
     * @return The interface implementation
     */
    public static Object getInstance(Type interfaceType) {
        return di_Injector.Org.getInstance(interfaceType);
    }
}
