public inherited sharing class TriggerContextFactory {

    public static TriggerContext buildFromCurrentTrigger() {

        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                return new TriggerContext(TriggerEventTypes.BeforeInsert, Trigger.new);
            } else if (Trigger.isUpdate) {
                return new TriggerContext(TriggerEventTypes.BeforeUpdate, Trigger.newMap, Trigger.oldMap);
            } else if (Trigger.isDelete) {
                return new TriggerContext(TriggerEventTypes.BeforeDelete, Trigger.oldMap, null);
            }
        }

        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                return new TriggerContext(TriggerEventTypes.AfterInsert, Trigger.newMap, null);
            } else if (Trigger.isUpdate) {
                return new TriggerContext(TriggerEventTypes.AfterUpdate, Trigger.newMap, Trigger.oldMap);
            } else if (Trigger.isDelete) {
                return new TriggerContext(TriggerEventTypes.AfterDelete, Trigger.oldMap, null);
            } else if (Trigger.isUndelete) {
                return new TriggerContext(TriggerEventTypes.AfterUndelete, Trigger.oldMap, null);
            }
        }

        return null;
    }

}
