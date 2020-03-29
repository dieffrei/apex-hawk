public virtual inherited sharing class TOrderItemEntity extends Entity {

    public TOrderItemEntity() {
        super(OrderItem.SObjectType);
    }

    public TOrderItemEntity(OrderItem record) {
        super(record);
    }

    public TOrderItemEntity(SObjectType sObjectType, String recordTypeName) {
        super(sObjectType, recordTypeName);
    }

}
