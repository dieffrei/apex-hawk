@IsTest
private class EntityTest {

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
                    new List<String>{
                        'Name'
                    },
                    CUSTOMER_NAME_SHOULD_HAVE_MORE_THAN_9_CHARS
                );
            } else {
                return new SObjectValidationResult(false,
                    new List<String>{
                        'Name'
                    },
                    String.format(CUSTOMER_NAME_IS_REQUIRED, new List<String>{
                        this.customer.name
                    }));
            }
        }

    }

    private class CustomerEntity extends Entity {

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

    @IsTest
    public static void constructor_ValidSObject_InitPrivateVars() {
        CustomerEntity entity = new CustomerEntity();
        System.assertNotEquals(null, entity.record);
        System.assertNotEquals(null, entity.observers);
        System.assertNotEquals(null, entity.events);
        System.assertNotEquals(null, entity.errors);
    }

    @IsTest
    public static void constructor_InitWithNullRecord_ThrowException() {
        try {
            new CustomerEntity(null);
            System.assert(false, 'It should throw exception.');
        } catch (Exception ex) {
            System.assert(ex instanceof EntityException);
        }
    }

    @IsTest
    public static void constructor_SobjectWithoutId_IsDirty() {
        CustomerEntity customer = new CustomerEntity(new Account(Name = 'Testing'));
        System.assertEquals(true, customer.isDirty());
    }

    @IsTest
    public static void constructor_SobjectWithId_IsNotDirty() {
        CustomerEntity customer = new CustomerEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Testing'));
        System.assertEquals(false, customer.isDirty());
    }

    @IsTest
    public static void constructor_ValidSObject_InvalidRecordTypeParameter() {
        String recordTypeDeveloperName = 'NonExistingRecordType';
        try {
            CustomerEntity entity = new CustomerEntity(Account.SObjectType, recordTypeDeveloperName);
            System.assert(false, 'Should throw and entity exception');
        } catch (EntityException entityException) {
            System.assertEquals(entityException.getMessage(), String.format(Entity.RECORD_TYPE_NOT_FOUND_FOR_SOBJECT_TYPE, new String[]{
                recordTypeDeveloperName,
                'Account'
            }));
        }
    }

    @IsTest
    public static void constructor_CreateNewRecord_IsDirty() {
        CustomerEntity entity = new CustomerEntity();
        System.assertEquals(true, entity.isDirty());
    }

    @IsTest
    public static void constructor_ValidRecord_InitPrivateVars() {
        CustomerEntity entity = new CustomerEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType)));
        System.assertNotEquals(null, entity.record);
        System.assertNotEquals(null, entity.observers);
        System.assertNotEquals(null, entity.events);
        System.assertNotEquals(null, entity.errors);
    }

    @IsTest
    public static void put_InvalidField_ThrowSObjectException() {
        CustomerEntity entity = new CustomerEntity();
        try {
            entity.put(Account.BillingStreet, 'Long Avenue');
        } catch (SObjectException ex) {
            System.assert(false, 'Do not expect SObjectException');
        }
    }

    @IsTest
    public static void put_ChangeValue_UpdateRecord() {
        CustomerEntity entity = new CustomerEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType)));
        String street = 'Street XPTO';
        entity.put(Account.BillingStreet, street);

        System.assertEquals(street, entity.record.get(Account.BillingStreet));
        System.assertEquals(1, entity.events.size());

        System.assert(entity.events[0] instanceof EntityChangeSobjectFieldValueEvent);

        EntityChangeSobjectFieldValueEvent evt = (EntityChangeSobjectFieldValueEvent) entity.events[0];
        System.assertEquals(null, evt.oldValue);
        System.assertEquals(street, evt.newValue);
    }

    @IsTest
    public static void fireEvent_DispatchEvent_NotifyObservers() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IObserver observer1 = (IObserver) mocks.mock(IObserver.class);
        IObserver observer2 = (IObserver) mocks.mock(IObserver.class);

        CustomerEntity entity = new CustomerEntity();
        entity.addObserver(observer1);
        entity.addObserver(observer2);

        entity.put(Account.BillingStreet, 'AnyValue');

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(EntityChangeSobjectFieldValueEvent.class);
        ((IObserver) mocks.verify(observer1, 2))
            .onChange((EntityChangeSobjectFieldValueEvent) argument.capture());
        EntityChangeSobjectFieldValueEvent event = (EntityChangeSobjectFieldValueEvent) argument.getValue();

        System.assertNotEquals(null, event);
        System.assertEquals('AnyValue', event.newValue);
        System.assertEquals(null, event.oldValue);

        argument = fflib_ArgumentCaptor.forClass(EntityChangeSobjectFieldValueEvent.class);
        ((IObserver) mocks.verify(observer2, 2))
            .onChange((EntityChangeSobjectFieldValueEvent) argument.capture());
        event = (EntityChangeSobjectFieldValueEvent) argument.getAllValues()[1];

        System.assertNotEquals(null, event);
        System.assertEquals('AnyValue', event.newValue);
        System.assertEquals(null, event.oldValue);

    }

    @IsTest
    public static void isDirty_ChangeFieldValue_ShouldBeDirty() {
        CustomerEntity entity = new CustomerEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType)));
        System.assertEquals(false, entity.isDirty());
        entity.put(Account.BillingStreet, 'AnyValue');
        System.assertEquals(true, entity.isDirty());
    }

    @IsTest
    public static void toSObject_AlwaysReturnSobject() {
        CustomerEntity entity = new CustomerEntity();
        System.assertNotEquals(null, entity.toSObject());
        entity = new CustomerEntity(new Account());
        System.assertNotEquals(null, entity.record);
    }

    @IsTest
    public static void validateBeforeConstruct_validate_NumContraintValidationsCorrect() {
        CustomerEntity entity = new CustomerEntity(new Account(Name = 'My name'));
        System.assertEquals(1, entity.getErrors().size());
    }

    @IsTest
    public static void validateBeforeConstruct_validate_CorrectValidationField() {
        CustomerEntity entity = new CustomerEntity(new Account(Name = 'My name'));
        System.assertEquals(1, entity.getErrors().size());
        System.assertEquals(1, entity.getErrors().getByField(Account.Name).size());
        System.assertEquals(1, entity.getErrors().getByField(Account.Name).get(0).getMessages().size());
        System.assertEquals(Account.Name.getDescribe().name, entity.getErrors().getByField(Account.Name).get(0).getFields()[0]);
        System.assertEquals(EntityErrorTypes.ENTITY_VALIDATION, entity.getErrors().getByField(Account.Name).get(0).getType());
    }

    @IsTest
    public static void validateBeforeConstruct_validate_Success() {
        String customerName = 'My name is Dieffrei';
        CustomerEntity entity = new CustomerEntity(new Account(Name = customerName));
        System.assertEquals(entity.name, customerName);
    }

    @IsTest
    public static void isValid_InvalidState_ReturnsFalse() {
        CustomerEntity entity = new CustomerEntity(new Account(Name = 'My name'));
        System.assertEquals(false, entity.isValid());
    }

    @IsTest
    public static void isChanged_ChangeField_NumChangesCorrect() {

        String name = 'Carlos';
        String source = 'Site';

        // given
        CustomerEntity customer = new CustomerEntity();
        System.assertEquals(false, customer.isChanged(Account.Name));
        System.assertEquals(false, customer.isChanged(Account.AccountSource));

        // when
        customer.namedAs(name);
        customer.sourceFrom(source);

        // then
        System.assertEquals(true, customer.isChanged(Account.Name));
        System.assertEquals(true, customer.isChanged(Account.AccountSource));
        System.assertEquals(name, customer.get(Account.Name));
        System.assertEquals(source, customer.get(Account.AccountSource));
    }

    @IsTest
    public static void isOwner_CurrentUser() {
        CustomerEntity customer = new CustomerEntity(new Account(OwnerId = UserInfo.getUserId()));
        System.assertEquals(true, customer.isOwner());
        System.assertEquals(true, customer.isOwner(UserInfo.getUserId()));
        System.assertEquals(false, customer.isOwner(fflib_IDGenerator.generate(User.SObjectType)));
    }

    @IsTest
    public static void getOwnerId_ReturnsOwnerId() {
        CustomerEntity customer = new CustomerEntity(new Account(OwnerId = UserInfo.getUserId()));
        System.assertEquals(UserInfo.getUserId(), customer.getOwnerId());
    }
}
