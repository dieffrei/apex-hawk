public inherited sharing class InvalidArgumentException extends Exception {

    public InvalidArgumentException(String argumentName, Object value){
        this.setMessage(String.format('[{0}] argument has invalid value [{1}]', new Object[]{
            argumentName,
            value
        }));
    }

}
