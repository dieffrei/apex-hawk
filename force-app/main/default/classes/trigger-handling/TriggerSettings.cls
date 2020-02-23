public inherited sharing class TriggerSettings {

    public Boolean isGlobalDisabled;
    public Map<String, Boolean> disabledTriggersByName;

    public TriggerSettings() {
        this.isGlobalDisabled = false;
    }

    public Boolean isTriggerEnabled(SObjectType sObjectType) {
        return true;
    }

}
