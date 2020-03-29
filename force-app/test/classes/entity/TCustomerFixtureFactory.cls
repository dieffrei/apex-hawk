@IsTest
public inherited sharing class TCustomerFixtureFactory {
    public static TCustomerEntity createNewCustomerBasicInfo() {
        return new TCustomerEntity(new Account(
            Name = 'Account Test'
        ));
    }
}
