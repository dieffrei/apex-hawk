public virtual inherited sharing class TCustomerEntity extends Entity {

    public TCustomerEntity() {
        super(Account.SObjectType);
    }

    public TCustomerEntity(Account record) {
        super(record);
    }

    public TCustomerEntity(SObjectType sObjectType, String recordTypeName) {
        super(sObjectType, recordTypeName);
    }

}
