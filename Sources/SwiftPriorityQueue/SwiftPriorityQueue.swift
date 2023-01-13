//
//  SwiftPriorityQueue.swift
//  SwiftPriorityQueue
//
//  Copyright (c) 2015-2023 David Kopec
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

/// A PriorityQueue takes objects to be pushed of any type that implements Comparable.
/// It will pop the objects in the order that they would be sorted. A pop() or a push()
/// can be accomplished in O(lg n) time. It can be specified whether the objects should
/// be popped in ascending or descending order (Max Priority Queue or Min Priority Queue)
/// at the time of initialization.
public struct PriorityQueue<T: Comparable> {
    
    fileprivate(set) var heap = [T]()
    private let ordered: (T, T) -> Bool
    
    /// Creates a new PriorityQueue using either the `>` operator or `<` operator to determine order.
    /// The default order is descending if `ascending` is not specified.
    ///
    /// - parameter ascending: Use the `>` operator (`true`) or `<` operator (`false`).
    /// - parameter startingValues: An array of elements to initialize the PriorityQueue with.
    public init(ascending: Bool = false, startingValues: [T] = []) {
        self.init(order: ascending ? { $0 > $1 } : { $0 < $1 }, startingValues: startingValues)
    }
    
    /// Creates a new PriorityQueue with the given custom ordering function.
    ///
    /// - parameter order: A function that specifies whether its first argument should
    ///                    come after the second argument in the PriorityQueue.
    /// - parameter startingValues: An array of elements to initialize the PriorityQueue with.
    public init(order: @escaping (T, T) -> Bool, startingValues: [T] = []) {
        ordered = order
        
        // Based on "Heap construction" from Sedgewick p 323
        heap = startingValues
        var i = heap.count/2 - 1
        while i >= 0 {
            sink(i)
            i -= 1
        }
    }
    
    /// How many elements the Priority Queue stores. O(1)
    public var count: Int { return heap.count }
    
    /// true if and only if the Priority Queue is empty. O(1)
    public var isEmpty: Bool { return heap.isEmpty }
    
    /// Add a new element onto the Priority Queue. O(lg n)
    ///
    /// - parameter element: The element to be inserted into the Priority Queue.
    public mutating func push(_ element: T) {
        heap.append(element)
        swim(heap.count - 1)
    }
    
    /// Add a new element onto a Priority Queue, limiting the size of the queue. O(n^2)
    /// If the size limit has been reached, the lowest priority element will be removed and returned.
    /// Note that because this is a binary heap, there is no easy way to find the lowest priority
    /// item, so this method can be inefficient.
    /// Also note, that only one item will be removed, even if count > maxCount by more than one.
    ///
    /// - parameter element: The element to be inserted into the Priority Queue.
    /// - parameter maxCount: The Priority Queue will not grow further if its count >= maxCount.
    /// - returns: the discarded lowest priority element, or `nil` if count < maxCount
    public mutating func push(_ element: T, maxCount: Int) -> T? {
        precondition(maxCount > 0)
        if count < maxCount {
            push(element)
        } else { // heap.count >= maxCount
            // find the min priority element (ironically using max here)
            if let discard = heap.max(by: ordered) {
                if ordered(discard, element) { return element }
                push(element)
                remove(discard)
                return discard
            }
        }
        return nil
    }

    /// Remove and return the element with the highest priority (or lowest if ascending). O(lg n)
    ///
    /// - returns: The element with the highest priority in the Priority Queue, or nil if the PriorityQueue is empty.
    public mutating func pop() -> T? {
        
        if heap.isEmpty { return nil }
        let count = heap.count
        if count == 1 { return heap.removeFirst() }  // added for Swift 2 compatibility
        // so as not to call swap() with two instances of the same location
        fastPop(newCount: count - 1)
        
        return heap.removeLast()
    }
    
    
    /// Removes the first occurence of a particular item. Finds it by value comparison using ==. O(n)
    /// Silently exits if no occurrence found.
    ///
    /// - parameter item: The item to remove the first occurrence of.
    public mutating func remove(_ item: T) {
        if let index = heap.firstIndex(of: item) {
            heap.swapAt(index, heap.count - 1)
            heap.removeLast()
            if index < heap.count { // if we removed the last item, nothing to swim
                swim(index)
                sink(index)
            }
        }
    }
    
    /// Removes all occurences of a particular item. Finds it by value comparison using ==. O(n^2)
    /// Silently exits if no occurrence found.
    ///
    /// - parameter item: The item to remove.
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
    public func peek() -> T? {
        return heap.first
    }
    
    /// Eliminate all of the elements from the Priority Queue, optionally replacing the order.
    public mutating func clear() {
        heap.removeAll(keepingCapacity: false)
    }
    
    // Based on example from Sedgewick p 316
    private mutating func sink(_ index: Int) {
        var index = index
        while 2 * index + 1 < heap.count {
            
            var j = 2 * index + 1
            
            if j < (heap.count - 1) && ordered(heap[j], heap[j + 1]) { j += 1 }
            if !ordered(heap[index], heap[j]) { break }
            
            heap.swapAt(index, j)
            index = j
        }
    }
    
    /// Helper function for pop.
    ///
    /// Swaps the first and last elements, then sinks the first element.
    ///
    /// After executing this function, calling `heap.removeLast()` returns the popped element.
    /// - Parameter newCount: The number of elements in heap after the `pop()` operation is complete.
    private mutating func fastPop(newCount: Int) {
        var index = 0
        heap.withUnsafeMutableBufferPointer { bufferPointer in
            let _heap = bufferPointer.baseAddress! // guaranteed non-nil because count > 0
            swap(&_heap[0], &_heap[newCount])
            while 2 * index + 1 < newCount {
                var j = 2 * index + 1
                if j < (newCount - 1) && ordered(_heap[j], _heap[j+1]) { j += 1 }
                if !ordered(_heap[index], _heap[j]) { return }
                swap(&_heap[index], &_heap[j])
                index = j
            }
        }
    }
    
    // Based on example from Sedgewick p 316
    private mutating func swim(_ index: Int) {
        var index = index
        while index > 0 && ordered(heap[(index - 1) / 2], heap[index]) {
            heap.swapAt((index - 1) / 2, index)
            index = (index - 1) / 2
        }
    }
}

// MARK: - GeneratorType
extension PriorityQueue: IteratorProtocol {
    
    public typealias Element = T
    mutating public func next() -> Element? { return pop() }
}

// MARK: - SequenceType
extension PriorityQueue: Sequence {
    
    public typealias Iterator = PriorityQueue
    public func makeIterator() -> Iterator { return self }
}

// MARK: - CollectionType
extension PriorityQueue: Collection {
    
    public typealias Index = Int
    
    public var startIndex: Int { return heap.startIndex }
    
    public var endIndex: Int { return heap.endIndex }
    
    /// Return the element at specified position in the heap (not the order). O(1)
    ///
    /// - Parameter position:   the index of the element to retireve.
    ///                         **Must not be negative**
    ///                         and **must be less greater than **
    ///                         `endindex`.
    ///
    /// - Returns: the element at the specified position in the heap.
    public subscript(position: Int) -> T {
        precondition(
            startIndex..<endIndex ~= position,
            "SwiftPriorityQueue subscript: index out of bounds"
        )
        return heap[position]
    }
    
    public func index(after i: PriorityQueue.Index) -> PriorityQueue.Index {
        return heap.index(after: i)
    }
    
    
}

// MARK: - CustomStringConvertible, CustomDebugStringConvertible
extension PriorityQueue: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String { return heap.description }
    public var debugDescription: String { return heap.debugDescription }
}
