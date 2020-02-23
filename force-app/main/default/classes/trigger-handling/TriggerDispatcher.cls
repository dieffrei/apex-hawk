public virtual inherited sharing class TriggerDispatcher {

    @TestVisible
    private static Map<String, Integer> executionCounterPerTriggerHandler = new Map<String, Integer>();
    private List<ITriggerHandler> handlers;
    private ILogger logger;
    private TriggerSettings settings;

    public TriggerDispatcher() {
        this.logger = (ILogger) Injector.getInstance(ILogger.class);
        this.handlers = new List<ITriggerHandler>();
        this.settings = new TriggerSettings();
    }

    @TestVisible
    private TriggerDispatcher(List<ITriggerHandler> triggers, TriggerSettings settings) {
        this.handlers = triggers;
        this.settings = settings;
    }

    /**
     * Discover all trigger handles by SobjectType and execute them according to the ordering from DI
     * @param sObjectType
     */
    public void discoverAndDispatch(SObjectType sObjectType) {
        if (settings.isGlobalDisabled) {
            this.logger.debug('Disabled trigger execution for all objects.');
            return;
        }

        List<di_Binding> bindings = di_Injector.Org.Bindings.bySObject(sObjectType).get();
        for (di_Binding binding : bindings) {
            Object handler = binding.getInstance();
            if (handler instanceof ITriggerHandler) {
                ITriggerHandler triggerHandler = (ITriggerHandler) handler;
                this.logger.debug('Trigger Handler {0}', new Object[]{
                    triggerHandler.getName()
                });
                handlers.add(triggerHandler);
            } else {
                throw new TriggerException('Binding for ' + binding.DeveloperName + ' must extend ITriggerHandler');
            }
        }
        dispatch();
    }

    @TestVisible
    private void dispatch() {
        dispatch(TriggerContextFactory.buildFromCurrentTrigger());
    }

    private void dispatch(TriggerContext context) {

        if (!this.settings.isTriggerEnabled(context.getSObjectType())) {
            this.logger.debug('Trigger handling is disabled for {0}', new Object[]{
                context.getSObjectType()
            });
            return;
        }

        for (ITriggerHandler handler : this.handlers) {
            if (this.shouldExecuteTrigger(context, handler) && handler.shouldExecute(context)) {
                try {
                    incrementExecutionCounter(handler);
                    List<IHasDMLResult> results = handler.execute(context);
                    if (results != null) {
                        this.logger.debug('Trigger execution result: {0}', results);
                        handleExecutionResult(context, results);
                    }
                } catch (Exception e) {
                    this.logger.error('An exception occurred while running trigger handler ' + handler.getName() + ': ' + e.getMessage());
                    this.logger.error(e.getStackTraceString());
                    throw e;
                }

            } else {
              this.logger.debug('Skipping handler: {0}, eventType: {1}', new Object[]{
                handler.getName(),
                context.type
              });
            }
        }
    }

    private void handleExecutionResult(TriggerContext context, List<IHasDMLResult> results) {
        for (IHasDMLResult result : results) {
            SObject record = new Map<Id, SObject>(context.records).get(result.getRecordId());
            this.logger.debug('{0}', new Object[]{record});
            if (record != null && result.hasErrors()) {
                result.getErrors()
                  .synchronizeToSObject(record);
            } else {
                throw new TriggerException('Record not found...');
            }
        }
    }

    private Boolean shouldExecuteTrigger(TriggerContext evt, ITriggerHandler handler) {

        switch on evt.type {
            when BeforeInsert {
                return handler instanceof TriggerType.BeforeInsert;
            }
            when BeforeUpdate {
                return handler instanceof TriggerType.BeforeUpdate;
            }
            when BeforeDelete {
                return handler instanceof TriggerType.BeforeDelete;
            }
            when AfterInsert {
                return handler instanceof TriggerType.AfterInsert;
            }
            when AfterUpdate {
                return handler instanceof TriggerType.AfterUpdate;
            }
            when AfterDelete {
                return handler instanceof TriggerType.AfterDelete;
            }
            when AfterUndelete {
                return handler instanceof TriggerType.AfterUndelete;
            }
        }

        return false;
    }

    private Integer incrementExecutionCounter(ITriggerHandler triggerHandler) {
        Integer counter = executionCounterPerTriggerHandler.get(triggerHandler.getName());
        counter = counter == null ? 1 : counter + 1;
        executionCounterPerTriggerHandler.put(triggerHandler.getName(), counter);
        this.logger.debug('Incrementing execution counter to {0} for {1}', new Object[]{
            counter,
            triggerHandler.getName()
        });
        return counter;
    }

}
