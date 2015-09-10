# SwiftPriorityQueue

SwiftPriorityQueue is a pure Swift (no Cocoa) implementation of a generic priority queue data structure, appropriate for use on both iOS and OS X projects. It features a straightforward interface and can be used with any type that implements Comparable. It utilizes comparisons between elements rather than separate numeric priorities to determine order.

Internally, SwiftPriorityQueue uses a classic binary heap, resulting in O(lg n) pushes and pops. It includes in-source documentation, an A* based example maze solving program, and unit tests are in progress (*pull requests are welcome for unit tests especially*).

## Features
* Easy-to-use method interface
* Small, self contained, pure Swift code base
* Classic binary heap implementation with O(lg n) pushes and pops
* Iterable through standard Swift for...in loops (implements SequenceType and GeneratorType)
* In-source documentation
* A fun maze solving A* based example program

## Installation
Simply copy `SwiftPriorityQueue.swift` into your project or use the CocoaPod `SwiftPriorityQueue`. Release 1.0.1 and beyond supports Swift 2. Use release 1.0 for Swift 1.2 support.

## Documentation
There is a large amount of documentation in the source code using the standard Swift documentation technique (compatible with Jazzy).  Essentially though, SwiftPriorityQueue has the three critical methods you'd expect - push(), pop(), and peek().

### Initialization
When you create a new `PriorityQueue` you can optionally specify whether the priority queue is ascending or descending. What does this mean? If the priority queue is ascending, its smallest values (as determined by their implementation of `Comparable` aka `<`) will be popped first, and if it's descending, its largest values will be popped first.
```
var pq: PriorityQueue<String> = PriorityQueue<String>(ascending: true)
```
You can also provide an array of starting values to be pushed sequentially immediately into the priority queue.
```
var pq: PriorityQueue<Int> = PriorityQueue<Int>(startingValues: [6, 2, 3, 235, 4, 500])
```
Or you can specify both.
```
var pq: PriorityQueue<Int> = PriorityQueue<Int>(ascending: false, startingValues: [6, 2, 3, 235, 4, 500])
```
Or you can specify neither. By default a `PriorityQueue` is decsending and empty. As you've probably noticed, a PriorityQueue takes a generic type. This type must be `Comparable`, as its comparison will be used for determining priority.  This means that your custom types must implement `Comparable` and utilize the overridden `<` to determine priority.

### Methods
`PriorityQueue` has all of the standard methods you'd expect a priority queue data structure to have.
* `push(element: T)` - Puts an element into the priority queue. O(lg n)
* `pop() -> T?` - Returns and removes the element with the highest (or lowest if ascending) priority or `nil` if the priority queue is empty. O(lg n)
* `peek() -> T?` - Returns the element with the highest (or lowest if ascending) priority or `nil` if the priority queue is empty. O(1)
* `clear()` - Removes all elements from the priority queue.

### Properties
* `count: Int` - The number of elements in the priority queue.
* `isEmpty: Bool` - `true` if the priority queue has zero elements, and `false` otherwise.

### Standard Swift Protocols
`PriorityQueue` implements `SequenceType`, `CollectionType` and `GeneratorType` so you can treat `PriorityQueue` like any other Swift sequence/collection. This means you can use Swift standard library fucntions on a `PriorityQueue` and iterate through a `PriorityQueue` like this:
```
for item in pq {  // pq is a PriorityQueue<String>
    println(item)
}
```
When you do this, every item from the `PriorityQueue` is popped in order. `PriorityQueue` also implements `Printable`.
```
println(pq)
```
Note: `PriorityQueue` is *not* thread-safe (do not manipulate it from multiple threads at once).

### Just for Fun - A* (`astar.swift`)
A* is a pathfinding algorithm that uses a priority queue. The sample program that comes with SwiftPriorityQueue is a maze solver that uses A*. You can find some in-source documentation if you want to reuse this algorithm inside `astar.swift`.

## Authorship & License
SwiftPriorityQueue is written by David Kopec and released under the MIT License (see `LICENSE`). You can find my email address on my GitHub profile page. I encourage you to submit pull requests and open issues here on GitHub.
