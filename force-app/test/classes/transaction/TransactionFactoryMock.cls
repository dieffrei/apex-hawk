public class TransactionFactoryMock implements ITransactionFactory {
    public ITransaction begin() {
        return new SFTransaction(new Map<SObjectType, SObjectDMLSettings>{
            Order.SObjectType => new SObjectDMLSettings(Account.SObjectType)
        });
    }
}
