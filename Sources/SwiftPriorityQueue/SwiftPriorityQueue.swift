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

prefix operator --
prefix operator ++

extension UnsafeMutablePointer {
    @usableFromInline
    static prefix func --(lhs: inout UnsafeMutablePointer) -> UnsafeMutablePointer {
        lhs -= 1
        return lhs
    }
    
    @usableFromInline
    static prefix func ++(lhs: inout UnsafeMutablePointer) -> UnsafeMutablePointer {
        lhs += 1
        return lhs
    }
}


extension Int {
    @usableFromInline
    static prefix func --(lhs: inout Int) -> Int {
        lhs -= 1
        return lhs
    }
    
    @usableFromInline
    static prefix func ++(lhs: inout Int) -> Int {
        lhs += 1
        return lhs
    }
}

@usableFromInline
internal func swap<T>(_ a: UnsafeMutablePointer<T>, _ b: UnsafeMutablePointer<T>) {
    let t = a.move()
    a.moveInitialize(from: b, count: 1)
    b.initialize(to: t)
}


@inlinable
internal func __push_heap_front<T>(_ first: UnsafeMutablePointer<T>, _ : UnsafeMutablePointer<T>, _ isOrderedBefore: (UnsafeMutablePointer<T>, UnsafeMutablePointer<T>) -> Bool,
                                   length: Int)
{
    typealias difference_type = Int
    if (length > 1)
    {
        var pIndex: Int = 0
        var pPointer = first
        var cIndex: Int = 2
        var cPointer = first + cIndex
        if (cIndex == length || isOrderedBefore(cPointer, (cPointer - 1)))
        {
            cIndex -= 1
            cPointer -= 1
        }
        if (isOrderedBefore(pPointer, cPointer))
        {
            var temp = pPointer.move()
            repeat {
                pPointer.moveInitialize(from: cPointer, count: 1)
                pPointer = cPointer;
                pIndex = cIndex;
                cIndex = (pIndex + 1) * 2;
                if (cIndex > length) {
                    break;
                }
                cPointer = first + cIndex;
                if (cIndex == length || isOrderedBefore(cPointer, (cPointer - 1)))
                {
                    cIndex -= 1
                    cPointer -= 1
                }
            } while (isOrderedBefore(&temp, cPointer));
            pPointer.initialize(to: temp)
        }
    }
}

@inlinable
internal func __push_heap_back<T: Comparable>(_ first: UnsafeMutablePointer<T>, _ last: UnsafeMutablePointer<T>, _ isOrderedBefore: (UnsafeMutablePointer<T>, UnsafeMutablePointer<T>) -> Bool, _ length: Int)
{
    
    var len = length
    var localLast = last
    
    if (len > 1)
    {
        len = (len - 2) / 2;
        var ptr = first + len;
        if (isOrderedBefore(ptr, --localLast))
        {
            var t = localLast.move()
            repeat {
                localLast.moveInitialize(from: ptr, count: 1)
                localLast = ptr;
                if (len == 0) {
                    break;
                }
                len = (len - 1) / 2;
                ptr = first + len;
            } while (isOrderedBefore(ptr, &t));
            localLast.initialize(to: t)
        }
    }
}

@inlinable
internal func __pop_heap<T: Comparable>(_ first: UnsafeMutablePointer<T>, _ last: UnsafeMutablePointer<T>, _ isOrderedBefore: (UnsafeMutablePointer<T>, UnsafeMutablePointer<T>) -> Bool, _ length: Int) {
    let newLast = last - 1
    if length > 1 {
        swap(first, newLast)
        __push_heap_front(first, newLast, isOrderedBefore, length: length - 1)
    }
}

@inlinable
internal func push_heap_back<T: Comparable>(_ first: UnsafeMutablePointer<T>, _ last:UnsafeMutablePointer<T>, _ ordered: (T, T) -> Bool = { $0 < $1 } ) {
    __push_heap_back(first, last, {ordered($0.pointee, $1.pointee)}, last - first)
}

@inlinable
internal func pop_heap<T: Comparable>(_ first: UnsafeMutablePointer<T>, _ last: UnsafeMutablePointer<T>, _ ordered: (T, T) -> Bool = { $0 < $1 } ) {
    __pop_heap(first, last, {ordered($0.pointee, $1.pointee)}, last - first)
}

@inlinable
internal func __make_heap<T: Comparable>(_ first: UnsafeMutablePointer<T>, _ last: UnsafeMutablePointer<T>, _ isOrderedBefore: (UnsafeMutablePointer<T>, UnsafeMutablePointer<T>) -> Bool) {
    let n = last - first
    if n > 1 {
        var current = first + 1
        var i = 1
        while i < n {
            __push_heap_back(first, ++current, isOrderedBefore, ++i)
        }
    }
}

@inlinable
internal func make_heap<T: Comparable>(_ first: UnsafeMutablePointer<T>, _ last: UnsafeMutablePointer<T>, _ ordered: (T, T) -> Bool = { $0 < $1 }) {
    __make_heap(first, last, {ordered($0.pointee, $1.pointee)})
}

@inlinable
internal func __heapify<T: Comparable>(_ first: UnsafeMutablePointer<T>, _ last: UnsafeMutablePointer<T>, _ isOrderedBefore: (UnsafeMutablePointer<T>, UnsafeMutablePointer<T>) -> Bool, _ length: Int) {
    var n = (length - 2) / 2
    while n >= 0 {
        var i = n
        while 2 * i + 1 < length {
            
            var j = 2 * i + 1
            
            if j < (length - 1) && isOrderedBefore(first + j, first + j + 1) { j += 1 }
            if !isOrderedBefore(first + i, first + j) { break }
            
            swap(first + i, first + j)
            
            i = j
        }
        n -= 1
    }
}

@inlinable
internal func heapify<T: Comparable>(_ first: UnsafeMutablePointer<T>, _ last: UnsafeMutablePointer<T>, ordered: (T, T) -> Bool) {
    __heapify(first, last, {ordered($0.pointee, $1.pointee)}, last - first)
}


/// A PriorityQueue takes objects to be pushed of any type that implements Comparable.
/// It will pop the objects in the order that they would be sorted. A pop() or a push()
/// can be accomplished in O(lg n) time. It can be specified whether the objects should
/// be popped in ascending or descending order (Max Priority Queue or Min Priority Queue)
/// at the time of initialization.
public struct PriorityQueue<T: Comparable> {
    
    fileprivate var heap = [T]()
    private let ordered: (T, T) -> Bool
    
    public init(ascending: Bool = false, startingValues: [T] = []) {
        self.init(order: ascending ? { $0 > $1 } : { $0 < $1 }, startingValues: startingValues)
    }
    
    /// Creates a new PriorityQueue with the given ordering.
    ///
    /// - parameter order: A function that specifies whether its first argument should
    ///                    come after the second argument in the PriorityQueue.
    /// - parameter startingValues: An array of elements to initialize the PriorityQueue with.
    public init(order: @escaping (T, T) -> Bool, startingValues: [T] = []) {
        ordered = order
        
        // Based on "Heap construction" from Sedgewick p 323
        heap = startingValues
        heap.withUnsafeMutableBufferPointer { bufferPointer in
            guard let first = bufferPointer.baseAddress else {
                return
            }
            heapify(first, first + bufferPointer.count, ordered: order)
        }
    }
    
    /// How many elements the Priority Queue stores
    public var count: Int { return heap.count }
    
    /// true if and only if the Priority Queue is empty
    public var isEmpty: Bool { return heap.isEmpty }
    
    /// Add a new element onto the Priority Queue. O(lg n)
    ///
    /// - parameter element: The element to be inserted into the Priority Queue.
    public mutating func push(_ element: T) {
        heap.append(element)
        heap.withUnsafeMutableBufferPointer { bufferPointer in
            guard let first = bufferPointer.baseAddress else {
                return
            }
            push_heap_back(first, first + bufferPointer.count, ordered)
        }
    }
    
    /// Remove and return the element with the highest priority (or lowest if ascending). O(lg n)
    ///
    /// - returns: The element with the highest priority in the Priority Queue, or nil if the PriorityQueue is empty.
    public mutating func pop() -> T? {
        
        if heap.isEmpty { return nil }
        heap.withUnsafeMutableBufferPointer { bufferPointer in
            guard let first = bufferPointer.baseAddress else {
                return
            }
            pop_heap(first, first + bufferPointer.count, ordered)
        }
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
    
    /// Removes all occurences of a particular item. Finds it by value comparison using ==. O(n)
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
    
    /// Eliminate all of the elements from the Priority Queue.
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
    
    public subscript(i: Int) -> T { return heap[i] }
    
    public func index(after i: PriorityQueue.Index) -> PriorityQueue.Index {
        return heap.index(after: i)
    }
}

// MARK: - CustomStringConvertible, CustomDebugStringConvertible
extension PriorityQueue: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String { return heap.description }
    public var debugDescription: String { return heap.debugDescription }
}
