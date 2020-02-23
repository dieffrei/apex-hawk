@NamespaceAccessible
public virtual inherited sharing class EntityException extends Exception {

    public final String[] fields;

    public EntityException(String message, String[] fields){
        this.setMessage(message);
        this.fields = fields;
    }

}
