public interface ITriggerContextTransactionService {
    ITransaction getTransaction();
    ITransaction getTransaction(String transactionClassName);
}
