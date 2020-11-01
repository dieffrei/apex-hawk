@IsTest
private class TriggerContextTransactionServiceTest {

    @IsTest
    static void testStartStopTransaction() {
        ITriggerContextTransactionService transactionService = new TriggerContextTransactionService();
        System.assertNotEquals(null, transactionService.getTransaction('TransactionFactoryMock'));
    }

}
