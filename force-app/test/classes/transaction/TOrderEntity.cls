public virtual inherited sharing class TOrderEntity extends Entity {

    public String name {
        get {
            return (String) super.get(Order.Name);
        }
    }

    public TCustomerEntity customer {get; protected set;}

    public TOrderEntity() {
        super(Order.SObjectType);
    }

    public TOrderEntity(Account record) {
        super(record);
    }

    public TOrderEntity(SObjectType sObjectType, String recordTypeName) {
        super(sObjectType, recordTypeName);
    }

    override
    protected void setupValidation() {
        //this.addValidator(new NameGreaterThan9CharsValidator(this));
    }

}
