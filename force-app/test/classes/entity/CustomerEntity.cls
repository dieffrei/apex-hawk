@IsTest
public class CustomerEntity extends Entity {

    private static final String CUSTOMER_NAME_SHOULD_HAVE_MORE_THAN_9_CHARS = 'Customer name should have more than 9 characters {0}';
    private static final String CUSTOMER_NAME_IS_REQUIRED = 'CUSTOMER_NAME_IS_REQUIRED';

    private class NameGreaterThan9CharsValidator implements IValidator, IBeforeCreateEntity, IBeforeSaveEntity {

        private CustomerEntity customer;

        public NameGreaterThan9CharsValidator(CustomerEntity customer) {
            this.customer = customer;
        }

        public SObjectValidationResult validate() {
            if (this.customer.name != null) {
                return new SObjectValidationResult((this.customer.name.length() > 9),
                    new List<String>{'Name'},
                    CUSTOMER_NAME_SHOULD_HAVE_MORE_THAN_9_CHARS
                );
            } else {
                return new SObjectValidationResult(false,
                    new List<String>{'Name'},
                    String.format(CUSTOMER_NAME_IS_REQUIRED, new List<String>{
                        this.customer.name
                    }));
            }
        }

    }

    public String name {
        get {
            return (String) super.get(Account.Name);
        }
    }

    public CustomerEntity() {
        super(Account.SObjectType);
    }

    public CustomerEntity(Account record) {
        super(record);
    }

    public CustomerEntity(SObjectType sObjectType, String recordTypeName) {
        super(sObjectType, recordTypeName);
    }

    override
    protected void setupValidation() {
        this.addValidator(new NameGreaterThan9CharsValidator(this));
    }

    public void namedAs(String name) {
        this.put(Account.Name, name);
    }

    public void sourceFrom(String source) {
        this.put(Account.AccountSource, source);
    }

}
