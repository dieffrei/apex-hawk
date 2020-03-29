@IsTest
private class SFTransactionTest {

    @IsTest
    static void constructor_Default_InitVariable() {
        SFTransaction transactionZ = new SFTransaction(new Map<SObjectType, SObjectDMLSettings>{
            Order.SObjectType => new SObjectDMLSettings(Account.SObjectType)
        });
        System.assertNotEquals(null, transactionZ.sObjectDmlSettings);
        System.assertNotEquals(null, transactionZ.entitiesToInsert);
        System.assertNotEquals(null, transactionZ.entitiesToDelete);
        System.assertNotEquals(null, transactionZ.entitiesToUpdate);
    }

    @IsTest
    static void constructor_NotProvideEntitySequence_ThrowException() {
        try {
            new SFTransaction(new Map<SObjectType, SObjectDMLSettings>{
            });
            System.assert(false, 'Should throw an exception');
        } catch (Exception ex) {
            System.assert(ex instanceof TransactionException, 'Wrong exception');
        }
        try {
            new SFTransaction(null);
            System.assert(false, 'Should throw an exception');
        } catch (Exception ex) {
            System.assert(ex instanceof TransactionException, 'Wrong exception');
        }
    }

    @IsTest
    static void registerNew_Insert_CheckCreationRegisterProperly() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IDML dml = (IDML) mocks.mock(IDML.class);

        // given
        TOrderEntity order = TOrderFixtureFactory.createNewOrderWith2LineItems();

        SFTransaction sfTransaction = new SFTransaction(new Map<SObjectType, SObjectDMLSettings>{
            Order.SObjectType => new SObjectDMLSettings(Order.SObjectType)
        }, dml);

        // when
        sfTransaction.save(order);

        //then
        System.assertEquals(1, sfTransaction.entitiesToInsert.size());

    }

    @IsTest
    static void registerDirty_Update_CheckUpdateRegisterProperly() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IDML dml = (IDML) mocks.mock(IDML.class);

        // given
        TOrderEntity order = TOrderFixtureFactory.createNewOrderWith2LineItems();
        order.put(Schema.Order.Id, fflib_IDGenerator.generate(Schema.Order.SObjectType));

        System.assertEquals(true, order.isDirty());

        SFTransaction sfTransaction = new SFTransaction(new Map<SObjectType, SObjectDMLSettings>{
            Order.SObjectType => new SObjectDMLSettings(Order.SObjectType)
        }, dml);

        // when
        sfTransaction.save(order);

        //then
        System.assertEquals(1, sfTransaction.entitiesToUpdate.size());

    }

    @IsTest
    static void registerDirty_CreateParentRecord_UpdateChildrenLookup() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IDML dml = (IDML) mocks.mock(IDML.class);

        // given
        TOrderEntity order = TOrderFixtureFactory.createNewOrderWith2LineItems();
        order.put(Schema.Order.Id, fflib_IDGenerator.generate(Schema.Order.SObjectType));

        System.assertEquals(true, order.isDirty());

        SFTransaction sfTransaction = new SFTransaction(new Map<SObjectType, SObjectDMLSettings>{
            OrderItem.SObjectType => new SObjectDMLSettings(OrderItem.SObjectType),
            Order.SObjectType => new SObjectDMLSettings(Order.SObjectType)
        }, dml);

        // when
        sfTransaction.save(order);

        //then
        System.assertEquals(1, sfTransaction.entitiesToUpdate.size());

    }

    @IsTest
    static void registerDelete_Delete_CheckDeleteRegisterProperly() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IDML dml = (IDML) mocks.mock(IDML.class);

        // given
        TOrderEntity order = TOrderFixtureFactory.createNewOrderWith2LineItems();

        SFTransaction sfTransaction = new SFTransaction(new Map<SObjectType, SObjectDMLSettings>{
            Order.SObjectType => new SObjectDMLSettings(Order.SObjectType)
        }, dml);

        // when
        sfTransaction.remove(order);

        //then
        System.assertEquals(1, sfTransaction.entitiesToDelete.size());

    }

    @IsTest
    static void commitz_Success() {

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IDML dml = (IDML) mocks.mock(IDML.class);

        // given
        TOrderEntity order = TOrderFixtureFactory.createNewOrderWith2LineItems();

        mocks.startStubbing();
        {
            mocks.when(dml.dmlInsert((List<IEntity>) fflib_Match.anyObject()))
                .thenReturn(new Map<IEntity, DMLResultItem>{
                order => new DMLResultItem(null, true, null)
            });
        }
        mocks.stopStubbing();

        SFTransaction sfTransaction = new SFTransaction(new Map<Schema.SObjectType, SObjectDMLSettings>{
            Account.SObjectType => new SObjectDMLSettings(Account.SObjectType),
            Order.SObjectType => new SObjectDMLSettings(Order.SObjectType)
        }, dml);

        sfTransaction.save(order.customer);
        sfTransaction.save(order, Schema.Order.AccountId, order.customer);

        // when
        sfTransaction.commitZ();
    }

}
