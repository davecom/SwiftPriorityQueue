//
//  SwiftPriorityQueue.swift
//  SwiftPriorityQueue
//
//  Copyright (c) 2015-2019 David Kopec
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

// This code was inspired by Section 2.4 of Algorithms by Sedgewick & Wayne, 4th Edition

internal extension UnsafeMutablePointer {
    @usableFromInline
    func swapAt(_ i: Int, _ j: Int) {
        if _slowPath(i == j) { return }
        let t = (self + i).move()
        (self + i).moveAssign(from: (self + j), count: 1)
        (self + j).initialize(to: t)
    }
}

@inlinable
internal func sink<T>(_ heap: UnsafeMutablePointer<T>, length: Int, index: Int, ordered: (T,T) -> Bool) {
    var index = index
    var j = 2 * index + 1
    while j < length {
        
        if j < (length - 1) && ordered(heap[j], heap[j + 1]) { j += 1 }
        if !ordered(heap[index], heap[j]) { break }
        
        heap.swapAt(index, j)
        
        index = j
        j = 2 * index + 1
    }
    
}

@inlinable
internal func swim<T>(_ heap: UnsafeMutablePointer<T>, index: Int, ordered: (T,T) -> Bool) {
    var index = index
    var j = (index - 1) / 2
    while index > 0 && ordered(heap[j], heap[index]) {
        heap.swapAt(j, index)
        index = j
        j = (index - 1) / 2
    }
}

@inlinable
internal func heapify<T>(_ heap: UnsafeMutablePointer<T>, length: Int, ordered: (T,T) -> Bool) {
    // Based on "Heap construction" from Sedgewick p 323
    var i = length/2 - 1
    while i >= 0 {
        sink(heap, length: length, index: i, ordered: ordered)
        i -= 1
    }
}

/// A PriorityQueue takes objects to be pushed of any type that implements Comparable.
/// It will pop the objects in the order that they would be sorted. A pop() or a push()
/// can be accomplished in O(lg n) time. It can be specified whether the objects should
/// be popped in ascending or descending order (Max Priority Queue or Min Priority Queue)
/// at the time of initialization.
public struct PriorityQueue<T: Comparable> {
    
    @usableFromInline
    internal var heap = [T]()
    
    @usableFromInline
    internal let ordered: (T, T) -> Bool
    
    @inlinable
    public init(ascending: Bool = false, startingValues: [T] = []) {
        self.init(order: ascending ? { $0 > $1 } : { $0 < $1 }, startingValues: startingValues)
    }
    
    /// Creates a new PriorityQueue with the given ordering.
    ///
    /// - parameter order: A function that specifies whether its first argument should
    ///                    come after the second argument in the PriorityQueue.
    /// - parameter startingValues: An array of elements to initialize the PriorityQueue with.
    @inlinable
    public init(order: @escaping (T, T) -> Bool, startingValues: [T] = []) {
        ordered = order
        
        heap = startingValues
        // heapify using buffer pointer
        heap.withUnsafeMutableBufferPointer { bufferPointer in
            guard let heapPointer = bufferPointer.baseAddress else { return }
            heapify(heapPointer, length: bufferPointer.count, ordered: ordered)
        }
//        // heapify using array
//        var i = heap.count/2 - 1
//        while i >= 0 {
//            _sink(i)
//            i -= 1
//        }
    }
    
    /// How many elements the Priority Queue stores
    @inlinable
    public var count: Int { return heap.count }
    
    /// true if and only if the Priority Queue is empty
    @inlinable
    public var isEmpty: Bool { return heap.isEmpty }
    
    /// Add a new element onto the Priority Queue. O(lg n)
    ///
    /// - parameter element: The element to be inserted into the Priority Queue.
    @inlinable
    public mutating func push(_ element: T) {
        heap.append(element)
        // swim with buffer pointer
        heap.withUnsafeMutableBufferPointer { bufferPointer in
            guard let heapPointer = bufferPointer.baseAddress else { return }
            swim(heapPointer, index: bufferPointer.count - 1, ordered: ordered)
        }
//        // swim with array
//        _swim(heap.count - 1)
    }
    
    /// Remove and return the element with the highest priority (or lowest if ascending). O(lg n)
    ///
    /// - returns: The element with the highest priority in the Priority Queue, or nil if the PriorityQueue is empty.
    @inlinable
    public mutating func pop() -> T? {
        
        if heap.isEmpty { return nil }
        
        // sink with buffer pointer
        heap.withUnsafeMutableBufferPointer { bufferPointer in
            guard let heapPointer = bufferPointer.baseAddress else { return }
            heapPointer.swapAt(0, bufferPointer.count - 1)
            sink(heapPointer, length: bufferPointer.count - 1, index: 0, ordered: ordered)
        }
        
        return heap.removeLast()
        
//        // sink with array
//        if heap.count == 1 { return heap.removeFirst() }  // added for Swift 2 compatibility
//        // so as not to call swap() with two instances of the same location
//        heap.swapAt(0, heap.count - 1)
//        let temp = heap.removeLast()
//        _sink(0)
//
//        return temp
    }
    
    
    /// Removes the first occurence of a particular item. Finds it by value comparison using ==. O(n)
    /// Silently exits if no occurrence found.
    ///
    /// - parameter item: The item to remove the first occurrence of.
    @inlinable
    public mutating func remove(_ item: T) {
        if let index = heap.firstIndex(of: item) {
            heap.withUnsafeMutableBufferPointer { bufferPointer in
                guard let heapPointer = bufferPointer.baseAddress else { return }
                
                heapPointer.swapAt(index, bufferPointer.count - 1)
                swim(heapPointer, index: index, ordered: ordered)
                sink(heapPointer, length: bufferPointer.count - 1, index: 0, ordered: ordered)
            }
            heap.removeLast()
            
//            // remove using array
//            heap.swapAt(index, heap.count - 1)
//            heap.removeLast()
//            if index < heap.count { // if we removed the last item, nothing to swim
//                _swim(index)
//                _sink(index)
//            }
        }
    }
    
    /// Removes all occurences of a particular item. Finds it by value comparison using ==. O(n)
    /// Silently exits if no occurrence found.
    ///
    /// - parameter item: The item to remove.
    @inlinable
    public mutating func removeAll(_ item: T) {
        var lastCount = heap.count
        remove(item)
        while (heap.count < lastCount) {
            lastCount = heap.count
            remove(item)
        }
    }
    
    /// Get a look at the current highest priority item, without removing it. O(1)
    ///
    /// - returns: The element with the highest priority in the PriorityQueue, or nil if the PriorityQueue is empty.
    @inlinable
    public func peek() -> T? {
        return heap.first
    }
    
    /// Eliminate all of the elements from the Priority Queue.
    @inlinable
    public mutating func clear() {
        heap.removeAll(keepingCapacity: false)
    }
    
//    // Based on example from Sedgewick p 316
//    private mutating func _sink(_ index: Int) {
//        var index = index
//        while 2 * index + 1 < heap.count {
//
//            var j = 2 * index + 1
//
//            if j < (heap.count - 1) && ordered(heap[j], heap[j + 1]) { j += 1 }
//            if !ordered(heap[index], heap[j]) { break }
//
//            heap.swapAt(index, j)
//            index = j
//        }
//    }
//
//    // Based on example from Sedgewick p 316
//    private mutating func _swim(_ index: Int) {
//        var index = index
//        while index > 0 && ordered(heap[(index - 1) / 2], heap[index]) {
//            heap.swapAt((index - 1) / 2, index)
//            index = (index - 1) / 2
//        }
//    }
}

// MARK: - GeneratorType
extension PriorityQueue: IteratorProtocol {
    
    public typealias Element = T
    
    @inlinable
    mutating public func next() -> Element? { return pop() }
}

// MARK: - SequenceType
extension PriorityQueue: Sequence {
    
    public typealias Iterator = PriorityQueue
    
    @inlinable
    public func makeIterator() -> Iterator { return self }
}

// MARK: - CollectionType
extension PriorityQueue: Collection {
    
    public typealias Index = Int
    
    @inlinable
    public var startIndex: Int { return heap.startIndex }
    
    @inlinable
    public var endIndex: Int { return heap.endIndex }
    
    @inlinable
    public subscript(i: Int) -> T { return heap[i] }
    
    @inlinable
    public func index(after i: PriorityQueue.Index) -> PriorityQueue.Index {
        return heap.index(after: i)
    }
}

// MARK: - CustomStringConvertible, CustomDebugStringConvertible
extension PriorityQueue: CustomStringConvertible, CustomDebugStringConvertible {
    
    @inlinable
    public var description: String { return heap.description }
    
    @inlinable
    public var debugDescription: String { return heap.debugDescription }
}
