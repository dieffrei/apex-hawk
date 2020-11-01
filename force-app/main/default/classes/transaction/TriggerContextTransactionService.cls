public virtual inherited sharing class TriggerContextTransactionService implements ITriggerContextTransactionService {

    private ITransaction transact = null;

    public ITransaction getTransaction(String transactionFactoryClassName) {
        if (transact == null) {
            transact = ((ITransactionFactory) Type.forName(transactionFactoryClassName).newInstance()).begin();
            transact.verboseMode();
        }
        return transact;
    }

    public ITransaction getTransaction() {
        return this.getTransaction('TransactionFactory');
    }

}
