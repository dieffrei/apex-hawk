public abstract class TriggerHandler implements ITriggerHandler {

    public virtual String getName() {
        return String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
    }

    public virtual Boolean shouldExecute(TriggerContext context) {
        return true;
    }
}
