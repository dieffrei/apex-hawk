<!--nav class="nav-primary" role="navigation" >
    <ul>
        {% for p in site.pages %}
        <li>
        	<a {% if p.url == page.url %}class="active"{% endif %} href="{{ site.baseurl }}{{ p.url }}">{{ p.title }}</a>
        </li>
        {% endfor %}
    </ul>
</nav-->

# Salesforce Apex Hawk 
The purpose of apex hawk is to facilitate code best practices and DDD principles.

## Implementing Building blocks

### Entities
Entity object are abstractions on top of SObjects.
To create a Domain object just extend Entity class.
Entity instances are persisted to database using SFTransaction (ApexHawk UnitOfWork implementation).
Only changed field values are persisted to database.
It is possible since entity classes implements Observer pattern.

```apex
public virtual inherited sharing class SaleOpportunity extends Entity {

  public List<SaleOpportunityLineItem> items { public get; protected set; }

  protected SaleOpportunity() {
    super(Opportunity.SObjectType);
    this.items = new List<SaleOpportunityLineItem>();
  }

  protected SaleOpportunity(Opportunity record) {
    super(record);
    this.items = new List<SaleOpportunityLineItem>();
    for (OpportunityLineItem item : record.OpportunityLineItems) {
        this.items.add(new SaleOpportunityLineItem(item));
    }
  }

  public void applyDiscount(Decimal factor) {
    for (SaleOpportunityLineItem item : items) {
        item.applyDiscount(factor);
    }
  }

  public Decimal getTotalValue() {
    Decimal totalValue = 0;
    for (SaleOpportunityLineItem item : items) {
        totalValue = totalValue + item.getTotalPrice();
    }
    return totalValue;
  }

}
```

```apex
global virtual inherited sharing class SaleOpportunityLineItem extends Entity {

    protected SaleOpportunityLineItem() {
        super(OpportunityLineItem.SObjectType);
    }

    public SaleOpportunityLineItem(OpportunityLineItem record) {
        super(record);
    }

    public void applyDiscount(Decimal factor) {
        Decimal unitPrice = (Decimal) get(OpportunityLineItem.UnitPrice);
        put(OpportunityLineItem.UnitPrice, unitPrice - ((unitPrice / 100) * (factor)));
    }

    public Decimal getUnitPrice() {
        return (Decimal) get(OpportunityLineItem.UnitPrice);
    }

    public Decimal getQuantity() {
        return (Decimal) get(OpportunityLineItem.Quantity);
    }

    public Decimal getTotalPrice() {
        return (Decimal) get(OpportunityLineItem.UnitPrice) * (Decimal) get(OpportunityLineItem.Quantity);
    }

}

```

### Repositories
Mediates between the domain and data mapping layers using a collection-like interface for accessing domain objects. 
A mechanism for encapsulating storage, retrieval, and search behavior which emulates a collection of objects
#### Repository interfaces
Abstract the way you interact with persistense, it provides a way that usually you can inject different repository implementations either cache or mock.
  ```apex
  public interface SaleOpportunityRepository {
      SaleOpportunityQuerySpec find();
      Map<Id, SaleOpportunity> getById(List<Id> saleOpportunityIds);
      void save(ITransaction sfTransaction, SaleOpportunity salesOpportunity);
      void save(ITransaction sfTransaction, List<SaleOpportunity> saleOpportunities);
      void remove(ITransaction sfTransaction, List<SaleOpportunity> saleOpportunities);
  } 
  ```
#### Repository Implementation
```apex
public virtual inherited sharing class SaleOpportunityRepositoryImpl implements SaleOpportunityRepository {

    private SaleOpportunityQuerySpec querySpecification;

    @TestVisible
    private class SaleOpportunityBuilder extends SaleOpportunity implements IEntityBuilder {
        public Entity build(SObject record) {
            return new SaleOpportunity((Opportunity) record);
        }
    }

    @TestVisible
    private SaleOpportunityRepositoryImpl(SaleOpportunityQuerySpec querySpecification) {
        this.querySpecification = querySpecification;
    }

    public SaleOpportunityRepositoryImpl() {
        this.querySpecification = new SaleOpportunityQuerySpec(new SaleOpportunityBuilder());
    }

    public SaleOpportunityQuerySpec find() {
        return this.querySpecification;
    }

    public Map<Id, SaleOpportunity> getById(List<Id> saleOpportunityIds) {
        List<IEntity> results = this.querySpecification.findById(new Set<Id>(saleOpportunityIds)).toList();
        Map<Id, SaleOpportunity> opportunities = new Map<Id, SaleOpportunity>();
        for (IEntity result: results) {
            opportunities.put(result.getId(), (SaleOpportunity) result);
        }
        return opportunities;
    }

    public void save(ITransaction sfTransaction, SaleOpportunity salesOpportunity) {
        save(sfTransaction, new List<SaleOpportunity>{salesOpportunity});
    }

    public void save(ITransaction sfTransaction, List<SaleOpportunity> saleOpportunities){
        for (SaleOpportunity saleOpportunity : saleOpportunities) {
            sfTransaction.save(saleOpportunity);
            for (SaleOpportunityLineItem item : saleOpportunity.items) {
                sfTransaction.save(item);
            }
        }
    }

    public void remove(ITransaction sfTransaction, List<SaleOpportunity> saleOpportunities){
        sfTransaction.remove(saleOpportunities);
    }

} 
```
### Query Specifications
Low level api to query sobject records (It uses fflib query factory + selector)

### Application Services
Communicates aggregate roots, performs complex use cases, cross aggregates transaction. An operation offered as an interface that stands alone in the model, with no encapsulated state.
```apex
public interface SaleOpportunityService {
    Map<Id, SaleOpportunity> getById(List<Id> opportunityIds);
    void applyDiscount(ITransaction salesforceTransaction, List<Id> opportunityIds, Decimal factor);
}
```
```apex
public inherited sharing class SaleOpportunityServiceImpl implements SaleOpportunityService {

    private SaleOpportunityRepository saleOpportunityRepository;

    public SaleOpportunityServiceImpl() {
        this.saleOpportunityRepository = (SaleOpportunityRepository) Injector.getInstance(SaleOpportunityRepository.class);
    }

    public Map<Id, SaleOpportunity> getById(List<Id> opportunityIds) {
        return this.saleOpportunityRepository.getById(opportunityIds);
    }

    public void applyDiscount(ITransaction salesforceTransaction, List<Id> opportunityIds, Decimal factor) {
        Map<Id, SaleOpportunity> opportunities = this.saleOpportunityRepository.getById(opportunityIds);
        for (SaleOpportunity opportunity : opportunities.values()) {
            opportunity.applyDiscount(factor);
            saleOpportunityRepository.save(salesforceTransaction, opportunity);
        }
    }

}
```

### Persistence
How to persist an entity instance state?
- #### Automatic detecting changes on domain objects
  The base class of apex hawk is ```Entity``` class, it has an SObject record internally,
  all changes in a entity should be reflected to the class, it is the way we interact with database.
  To update/get a field value use ```Entity.put()``` / ```Entity.get()``` methods.
- #### Transaction / Unit of work
  Martin Fowler definition for Unit of work pattern is "Maintains a list of objects affected by a business transaction and coordinates the writing out of changes and the resolution of concurrency problems."
  To persist a Domain object to database use ```SFTransaction``` it works similar as fflib_SObjectUnitOfWork.
- #### Creating a Transaction
  ```SFTransaction``` constructor map parameter let you define per Object an DML implementation.
  It allows to for a edge cases implement a special way to insert/upsert/delete records from database.

  *DML executions are executed by object and the execution order as defined on parameter keySet .* 
```apex
new SFTransaction(new Map<Schema.SObjectType, SObjectDMLSettings>{
    Opportunity.SObjectType => new SObjectDMLSettings(Opportunity.SObjectType),
    OpportunityLineItem.SObjectType => new SObjectDMLSettings(OpportunityLineItem.SObjectType)
});
In the code above, Opportunities will be inserted/updated/upserted/deleted before OpportunityLineItems.
```
- #### Retrieving a domain object state
  - #### Query Specifications
- #### Persisting a domain object state
```apex    
    // initialize salesforce transaction
    SFTransaction salesforceTransaction = new SFTransaction(new Map<Schema.SObjectType, SObjectDMLSettings>{
        Opportunity.SObjectType => new SObjectDMLSettings(Opportunity.SObjectType)
    });
    
    // create an entity instance and update
    SaleOpportunity opportunity = new SaleOpportunity();
    opportunity.addItem(new SaleOpportunityItem());
    
    // register domain object to save (update/insert/upsert).
    // To delete use ITransaction.remove() method
    salesforceTransaction.save(opportunity)       
    
    // commit is a keyword so method has Z as suffix    
    salesforceTransaction.commitZ();
```
- #### Sharing transaction between services
  To provide better orchestration of persistence, provide for your methods transaction parameters.
```apex
    SFTransaction salesforceTransaction;
    {
        Customer customer = new CustomerService()
            .createCustomer(customerInfo, salesforceTransaction);
        
        new OrderService()
            .createOrder(customer, salesforceTransaction);
    }
    salesforceTransaction.commitZ();
```
