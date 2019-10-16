# SwiftPriorityQueue

[![Swift Versions](https://img.shields.io/badge/Swift-1%2C2%2C3%2C4%2C5-green.svg)](https://swift.org)
[![CocoaPods Version](https://img.shields.io/cocoapods/v/SwiftPriorityQueue.svg)](https://cocoapods.org/pods/SwiftPriorityQueue)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![CocoaPods Platforms](https://img.shields.io/cocoapods/p/SwiftPriorityQueue.svg)](https://cocoapods.org/pods/SwiftPriorityQueue)
[![Linux Compatible](https://img.shields.io/badge/Linux-compatible-4BC51D.svg?style=flat)](https://swift.org)
[![Twitter Contact](https://img.shields.io/badge/contact-@davekopec-blue.svg?style=flat)](https://twitter.com/davekopec)

SwiftPriorityQueue is a pure Swift (no Cocoa) implementation of a generic priority queue data structure, appropriate for use on all platforms (macOS, iOS, Linux, etc.) where Swift is supported. It features a straightforward interface and can be used with any type that implements `Comparable`. It utilizes comparisons between elements rather than separate numeric priorities to determine order.

Internally, SwiftPriorityQueue uses a classic binary heap, resulting in O(lg n) pushes and pops. It includes in-source documentation, an A* based example maze solving program (for macOS), and unit tests (*pull requests are welcome for additional unit tests in particular*).

## Features
* Easy-to-use method interface
* Small, self contained, pure Swift code base
* Classic binary heap implementation with O(lg n) pushes and pops
* Iterable through standard Swift for...in loops (implements `Sequence` and `IteratorProtocol`)
* In-source documentation
* A fun maze solving A* based example program

## Installation

Release 1.3.0 and above supports Swift 5. Use release 1.2.1 for Swift 4. Use release 1.1.2 for Swift 3 and Swift 2 support. Use release 1.0 for Swift 1.2 support.

### CocoaPods

Use the CocoaPod `SwiftPriorityQueue`.

### Swift Package Manager (SPM)

Add this repository as a dependency.

### Manual

Copy `SwiftPriorityQueue.swift` into your project.

## Documentation
There is a large amount of documentation in the source code using the standard Swift documentation technique (compatible with Jazzy).  Essentially though, SwiftPriorityQueue has the three critical methods you'd expect - `push()`, `pop()`, and `peek()`.

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
Or you can specify neither. By default a `PriorityQueue` is descending and empty. As you've probably noticed, a PriorityQueue takes a generic type. This type must be `Comparable`, as its comparison will be used for determining priority.  This means that your custom types must implement `Comparable` and utilize the overridden `<` to determine priority.

### Methods
`PriorityQueue` has all of the standard methods you'd expect a priority queue data structure to have.
* `push(element: T)` - Puts an element into the priority queue. O(lg n)
* `pop() -> T?` - Returns and removes the element with the highest (or lowest if ascending) priority or `nil` if the priority queue is empty. O(lg n)
* `peek() -> T?` - Returns the element with the highest (or lowest if ascending) priority or `nil` if the priority queue is empty. O(1)
* `clear()` - Removes all elements from the priority queue.
* `remove(item: T)` - Removes the first found instance of *item* in the priority queue. Silently returns if not found. O(n)
* `removeAll(item: T)` - Removes all instances of *item* in the priority queue through repeated calls to `remove()`. Silently returns if not found.

### Properties
* `count: Int` - The number of elements in the priority queue.
* `isEmpty: Bool` - `true` if the priority queue has zero elements, and `false` otherwise.

### Standard Swift Protocols
`PriorityQueue` implements `IteratorProtocol`, `Sequence` and `Collection` so you can treat `PriorityQueue` like any other Swift sequence/collection. This means you can use Swift standard library fucntions on a `PriorityQueue` and iterate through a `PriorityQueue` like this:
```
for item in pq {  // pq is a PriorityQueue<String>
    print(item)
}
```
When you do this, every item from the `PriorityQueue` is popped in order. `PriorityQueue` also implements `CustomStringConvertible` and `CustomDebugStringConvertible`.
```
print(pq)
```
Note: `PriorityQueue` is *not* thread-safe (do not manipulate it from multiple threads at once).

### Just for Fun - A* (`astar.swift`)
A* is a pathfinding algorithm that uses a priority queue. The sample program that comes with SwiftPriorityQueue is a maze solver that uses A*. You can find some in-source documentation if you want to reuse this algorithm inside `astar.swift`.

## Authorship & License
SwiftPriorityQueue is written by David Kopec and released under the MIT License (see `LICENSE`). You can find my email address on my GitHub profile page. I encourage you to submit pull requests and open issues here on GitHub.
