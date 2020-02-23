public interface ITriggerHandler {
    String getName();
    List<IHasDMLResult> execute(TriggerContext context);
    Boolean shouldExecute(TriggerContext context);
}
