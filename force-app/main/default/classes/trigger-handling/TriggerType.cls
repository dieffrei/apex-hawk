public class TriggerType {

    public interface AfterUpdate {}
    public interface AfterInsert { }
    public interface AfterDelete { }
    public interface AfterUndelete { }

    public interface BeforeUpdate { }
    public interface BeforeInsert { }
    public interface BeforeDelete { }

    private TriggerType() { }
}
