[![codecov](https://codecov.io/gh/dieffrei/apex-hawk/branch/master/graph/badge.svg?token=YZ22J8GQF3)](https://codecov.io/gh/dieffrei/apex-hawk)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/05e0bf9a64c441cba589930c319f9003)](https://www.codacy.com/manual/dieffrei/apex-hawk?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=dieffrei/apex-hawk&amp;utm_campaign=Badge_Grade)
# apex-hawk
Apex library to support Domain Driven Design


# Domain driven design concepts
## Domain
A subject of matter that we are building software on. A sphere of knowledge, influence, or activity to which the user applies a software.
Ubiquitous language — a common, rigorous language to help communication between software developers and domain experts. A language structured around the domain model and used by all team members to connect all the activities of the team with the software.
## Invariant 
Describes something that must be true with your design all the time. Invariants help us to discover the Bounded Context. An Assertion about some design element that must be true at all times, except during specifically transient situations such as the middle of the execution of a method, or the middle of an uncommitted database transaction.
## Bounded Context
Central part in DDD. A specific responsibility enforced by explicit boundaries. These boundaries are set by the different way we represent models. Different contexts may have completely different models of common concepts with mechanisms to map between them. It gives team members a clear and shared understanding of what has to be consistent and what can develop independently.
## Adapter
a bridge between an application and the service that is needed by the application. It lies outside a domain and helps two incompatible interfaces to work together. It allows the interface of an existing class to be used from another interface.
## Aggregate
A cluster of domain objects that can be treated as a single unit to provide a specific functionality and for the purpose of data changes. An aggregate will have one of its component objects be the aggregate root.
## Aggregate root
The domain’s only entry point for data access. A heart of your domain. The job of an Aggregate Root is to control and encapsulate access to it’s members in such a way as to protect its invariants. Any references from outside the aggregate should only go to the aggregate root. The root can thus ensure the integrity of the aggregate as a whole.
## Entity
An object fundamentally defined not by its attributes, but by a thread of continuity and identity. A unique thing that has a life cycle and can change state. An object that differs by ID, which have to be unique within an aggregate, not necessary globally. Never share an entity between aggregates.
## Value object
An immutable object that describes some characteristic or attribute but carries no concept of identity. Sometimes in one context something is an entity while in another it is just a value object.
## Service
Communicates aggregate roots, performs complex use cases, cross aggregates transaction. An operation offered as an interface that stands alone in the model, with no encapsulated state.
## Infrastructural service
Usually encapsulates IO concerns such as file system access, database access, email, 3rd party APIs. An email infrastructure service can handle a domain event by generating and transmitting an appropriate email message. Another infrastructural service can handle the same event and send a notification via SMS or another channel. The domain layer doesn’t care about the specifics or how an event notification is delivered, it only cares about raising the event. A repository implementation is also an example of an infrastructural service. The specifics of the communication with durable storage mechanisms are handled in the infrastructure layer.
## Domain service
embeds and operate upon domain concepts and is part of the ubiquitous language. Domain services are very granular, contain domain logic that can’t be placed naturally in an entity or value object.
Application service — orchestrates the execution of domain logic and don’t implement any domain logic. Domain service methods can have other domain elements as operands and return values. Application services declare dependencies on infrastructural services required to execute domain logic. Application services operate upon trivial operands such as identity values and primitive data structures.
## CQRS
Command-Query Responsibility Segregation. A common sense rather than a pattern. CQRS just separates a model into two separate parts — READ model and WRITE model. They also can be referenced as Query model and Command model. Segregation must be clean so commands can’t return any data.
## Query
An interpreter, which is a structure of objects which can form itself into an SQL query. You can create this query by referring to classes and fields rather than tables and columns. In this way, those who write the queries can do so independently of the database schema and changes to the schema can be localized in a single place.
## Command
An operation that effects some change to the system (for example, setting a variable). An operation that intentionally creates a side effect.
Event Sourcing — ensuring every change to the state of an application is captured in an event object, and that these event objects are themselves stored in the sequence they were applied for the same lifetime as the application state itself. A method of storing business data as a sequence of modification events. The most natural addition to CQRS. It turns commands into an asynchronous world because processing could take some time on a server.
## ActiveRecord
an approach to accessing data in a database. A database table or view is wrapped into a class, so AR encapsulates the data access and adds domain logic on that data. Thus, an object instance is tied to a single row in the table. After a creation of an object, a new row is added to the table upon save. Any object loaded gets its information from the database. Active Record, by its nature does not support testing.
## Repository
mediates between the domain and data mapping layers using a collection-like interface for accessing domain objects. A mechanism for encapsulating storage, retrieval, and search behavior which emulates a collection of objects.
## Form object
an object that wraps incoming input from a user and provides a validation to ensure that only correct data is processed within an application anytime later.

# Hexagonal architecture

![Hexagonal architecture](https://i.imgur.com/1gVLOpf.png)


## Resources
https://blog.lelonek.me/ddd-building-blocks-for-ruby-developers-cdc6c25a80d2
https://herbertograca.com/2017/11/16/explicit-architecture-01-ddd-hexagonal-onion-clean-cqrs-how-i-put-it-all-together/
