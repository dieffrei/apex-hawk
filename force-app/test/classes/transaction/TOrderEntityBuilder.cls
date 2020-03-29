public inherited sharing class TOrderEntityBuilder extends TOrderEntity {

    private TOrderEntity order = null;

    public TOrderEntityBuilder() {
        this.order = new TOrderEntity();
        this.order.put(Schema.Order.BillingStreet, 'Testando');
        this.order.put(Schema.Order.EffectiveDate, System.today());
        this.order.put(Schema.Order.Status, 'Draft');
    }

    public TOrderEntityBuilder set(TCustomerEntity customer) {
        this.order.customer = customer;
        return this;
    }

    public TOrderEntityBuilder add(TOrderItemEntity item) {
        return this;
    }

    public TOrderEntity build() {
        return order;
    }
}
