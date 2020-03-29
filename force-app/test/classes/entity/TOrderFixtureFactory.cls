public inherited sharing class TOrderFixtureFactory {
    public static TOrderEntity createNewOrderWith2LineItems(){
        TOrderEntity order = new TOrderEntityBuilder()
            .set(TCustomerFixtureFactory.createNewCustomerBasicInfo())
            .add(new TOrderItemEntityBuilder()
                .build())
            .add(new TOrderItemEntityBuilder()
                .build())
            .build();
        return order;
    }
}
