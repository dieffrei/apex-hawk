/**
 * Maps a SObject and DML service
 */
public virtual inherited sharing class SObjectDMLSettings {

    public SObjectType sObjectType {get; protected set;}
    public IDML dml {get; protected set;}

    public SObjectDMLSettings(SObjectType sObjectType) {
        this(sObjectType, null);
    }

    public SObjectDMLSettings(SObjectType sObjectType, IDML dml) {
        this.sObjectType = sObjectType;
        this.dml = dml;
    }

    public Boolean usesCustomDMLImplementation() {
        return this.dml != null;
    }

    public IDML getCustomDMLImplementation() {
        //throew exception if  usesCustomDMLImplementation is false
        return dml;
    }

}
