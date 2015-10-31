# SpratCodeCore
These are classes and methods I end up using in almost every private project I write.

Null Filter
In some folks' code, NSNull's get thrown in where nil might be more approrpiate.
Use the .nullFilter_scc property to get the object unless it's an NSNull, which will return nil.

SCCKVObserver
Key-Value Observing is awesome, but as Apple implemented it, it was extremely hard to use effectively.
SCCKVObserver lets you trigger a block when a KVO is generated.
You simply hold on to an observer object until you no longer care for the callback.
It automatically manages removing the observer when the observed object gets deallocated.


NSArray categories providing SCCChangeSet
Using two arrays of unique objects, categories on NSArray provide a change-set object which describes the changes made from one array to the other.


SccArrayController
This class povides registration of observers to changes to an array.
Use change set objects to make changes, and all registered observers get a batch change.
Alternatively, Use the mutable array controller, and simply set the new array on the controller to have change sets calcualted automatically.
