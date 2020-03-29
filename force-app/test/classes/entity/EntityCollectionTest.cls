@IsTest
public class EntityCollectionTest {

    private class CustomerTestEntity extends Entity {
        public CustomerTestEntity() {
            super(Account.SObjectType);
        }

        public CustomerTestEntity(Account record) {
            super(record);
        }
    }

    @IsTest
    public static void size_EntityList_MatchSize() {
        EntityCollection collection = new EntityCollection(new List<Entity>{
            new CustomerTestEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType))),
            new CustomerTestEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType))),
            new CustomerTestEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType)))
        });
        System.assertEquals(3, collection.size());
    }

    @IsTest
    public static void getById_NotFoundElement_ReturnsNull() {
        EntityCollection collection = new EntityCollection(new List<Entity>{
            new CustomerTestEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType))),
            new CustomerTestEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType))),
            new CustomerTestEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType)))
        });
        System.assertEquals(null, collection.getById(fflib_IDGenerator.generate(Account.SObjectType)));
    }

    @IsTest
    public static void getById_PickRightEntity_ReturnsEntity() {
        CustomerTestEntity toBeFound = new CustomerTestEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType)));
        EntityCollection collection = new EntityCollection(new List<Entity>{
            new CustomerTestEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType))),
            new CustomerTestEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType))),
            new CustomerTestEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType))),
            new CustomerTestEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType))),
            toBeFound,
            new CustomerTestEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType)))
        });
        System.assertEquals(toBeFound, collection.getById(toBeFound.id));
    }

    @IsTest
    public static void add_EntityList_CorrectSize() {
        EntityCollection collection = new EntityCollection();
        collection.add(new CustomerTestEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType))));
        collection.add(new CustomerTestEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType))));
        collection.add(new CustomerTestEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType))));
        System.assertEquals(3, collection.size());
    }

    @IsTest
    public static void add_NullValue_ThowsException() {
        EntityCollection collection = new EntityCollection();
        try {
            collection.add(null);
            System.assert(false, 'Should thr owed an exception');
        } catch(Exception ex) {

        }
    }

    @IsTest
    public static void toList_DefaultConstructor_Success() {
        EntityCollection collection = new EntityCollection();
        System.assertEquals(0, collection.toList().size());
    }

    @IsTest
    public static void getByField_EntityList_PickRightItem() {
        CustomerTestEntity entityToBeFound = new CustomerTestEntity(new Account(AccountSource = 'Facebook'));
        EntityCollection collection = new EntityCollection();
        collection.add(new CustomerTestEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType))));
        collection.add(new CustomerTestEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType))));
        collection.add(new CustomerTestEntity(new Account(Id = fflib_IDGenerator.generate(Account.SObjectType))));
        collection.add(entityToBeFound);

        System.assertEquals(entityToBeFound, collection.getByField(Account.AccountSource, 'Facebook'));
    }

    @IsTest
    public static void serialization_Success() {
        EntityCollection collection = new EntityCollection();
        String serializedObject = JSON.serialize(collection);
        System.assertNotEquals(null, serializedObject);
    }
}
