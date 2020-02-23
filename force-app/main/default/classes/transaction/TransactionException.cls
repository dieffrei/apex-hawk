public inherited sharing class TransactionException extends Exception {

    public Map<IEntity, DMLResultItem> result {get; protected set;}

    public TransactionException(Map<IEntity, DMLResultItem> result){
        this.setMessage('Error to commit to database. ' + result);
    }
}
