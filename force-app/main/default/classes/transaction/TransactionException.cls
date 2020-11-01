/**
* @description Transaction exception
*/
public inherited sharing class TransactionException extends Exception {

    public Map<IEntity, DMLResultItem> dmlResult {get; protected set;}

    public TransactionException(Map<IEntity, DMLResultItem> dmlResult){
        this.dmlResult = dmlResult;
        this.setMessage('One or more records failed to commit to database.');
    }
}
