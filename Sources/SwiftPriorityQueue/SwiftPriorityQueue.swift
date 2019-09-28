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
    
    
    /// Decrement and return
    ///
    /// Decrement the pointer by 1 and return the resulting pointer.
    /// - Parameter operand: operand
    @usableFromInline
    static prefix func --(operand: inout UnsafeMutablePointer) -> UnsafeMutablePointer {
        operand -= 1
        return operand
    }
    
    /// Increment and return
    ///
    /// Increment the pointer by 1 and return the resulting pointer.
    /// - Parameter operand: operand
    @usableFromInline
    static prefix func ++(operand: inout UnsafeMutablePointer) -> UnsafeMutablePointer {
        operand += 1
        return operand
    }
}


extension Int {
    
    /// Decrement and return
    ///
    /// Decrement the value by 1 and return the resulting value.
    /// - Parameter operand: operand
    @usableFromInline
    static prefix func --(lhs: inout Int) -> Int {
        lhs -= 1
        return lhs
    }
    
    /// Increment and return
    ///
    /// Increment the value by 1 and return the resulting value.
    /// - Parameter operand: operand
    @usableFromInline
    static prefix func ++(lhs: inout Int) -> Int {
        lhs += 1
        return lhs
    }
}


/// Swap by reference
///
/// Swap the values pointed to by the two pointers.
/// - Parameter a: first pointer
/// - Parameter b: second pointer
@usableFromInline
internal func swap<T>(_ a: UnsafeMutablePointer<T>, _ b: UnsafeMutablePointer<T>) {
    let t = a.move()
    a.moveInitialize(from: b, count: 1)
    b.initialize(to: t)
}

/// Heapify an array
///
/// Helper function for `SwiftPriorityQueue`.
///
/// Functionally equivalent to `heapify(array)`.
///
/// No assumptions are made about the initial order of the heap.
/// - Parameter first: Pointer to the first element of the heap
/// - Parameter isOrderedAfter: Ordering function. Returns true if `a.pointee` comes after `b.pointee`.
/// - Parameter a: The first pointer
/// - Parameter b: The second pointer
/// - Parameter length: Length of the heap
@inlinable
internal func __heapify<T>(_ first: UnsafeMutablePointer<T>, _ isOrderedAfter: (UnsafeMutablePointer<T>, UnsafeMutablePointer<T>) -> Bool, _ length: Int) {
    var n = (length - 2) / 2
    var i: Int
    var j: Int
    var iPointer: UnsafeMutablePointer<T>
    var jPointer: UnsafeMutablePointer<T>
    while n >= 0 {
        i = n
        j = 2 * i + 1
        iPointer = first + i
        jPointer = first + j
        
        while j < length {
            
            if j < (length - 1) && isOrderedAfter(jPointer, jPointer + 1) {
                j += 1
                jPointer += 1
            }
            if !isOrderedAfter(iPointer, jPointer) { break }
            
            swap(iPointer, jPointer)
            
            i = j
            j = 2 * i + 1
            iPointer = jPointer
            jPointer = first + j
        }
        n -= 1
    }
}

/// Correctly position the first item of a heap
///
/// Helper function for `SwiftPriorityQueue`.
///
/// Equivalent to `sink(0)`. Assumes the remainder of the heap is valid.
///
/// - Parameter first: Pointer to the first element of the heap
/// - Parameter isOrderedAfter: Ordering function. Returns true if `a.pointee` comes after `b.pointee`.
/// - Parameter a: The first pointer
/// - Parameter b: The second pointer
/// - Parameter length: Length of the heap
///
/// - Note: Inspired by [libcxx/include/algorithm](https://github.com/google/libcxx/blob/master/include/algorithm)
@inlinable
internal func __push_heap_front<T>(_ first: UnsafeMutablePointer<T>, _ isOrderedAfter: (_ a: UnsafeMutablePointer<T>, _ b: UnsafeMutablePointer<T>) -> Bool,
                                   _ length: Int)
{
    if (length > 1)
    {
        var pIndex: Int = 0
        var pPointer = first
        var cIndex: Int = 2
        var cPointer = first + cIndex
        if (cIndex == length || isOrderedAfter(cPointer, (cPointer - 1)))
        {
            cIndex -= 1
            cPointer -= 1
        }
        if (isOrderedAfter(pPointer, cPointer))
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
                if (cIndex == length || isOrderedAfter(cPointer, (cPointer - 1)))
                {
                    cIndex -= 1
                    cPointer -= 1
                }
            } while (isOrderedAfter(&temp, cPointer));
            pPointer.initialize(to: temp)
        }
    }
}

/// Correctly position the last item of a heap
///
/// Helper function for `SwiftPriorityQueue`.
///
/// Functionally equivalent to `swim(length - 1)`. Assumes the remainder of the heap is valid.
///
/// - Parameter first: Pointer to the first element of the heap
/// - Parameter isOrderedAfter: Ordering function. Returns true if `a.pointee` comes after `b.pointee`.
/// - Parameter a: The first pointer
/// - Parameter b: The second pointer
/// - Parameter length: Length of the heap
///
/// - Note: Inspired by [libcxx/include/algorithm](https://github.com/google/libcxx/blob/master/include/algorithm)
@inlinable
internal func __push_heap_back<T>(_ first: UnsafeMutablePointer<T>, _ isOrderedAfter: (_ a: UnsafeMutablePointer<T>, _ b: UnsafeMutablePointer<T>) -> Bool, _ length: Int)
{
    
    var len = length
    var last = first + length
    
    if (len > 1)
    {
        len = (len - 2) / 2;
        var ptr = first + len;
        if (isOrderedAfter(ptr, --last))
        {
            var t = last.move()
            repeat {
                last.moveInitialize(from: ptr, count: 1)
                last = ptr;
                if (len == 0) {
                    break;
                }
                len = (len - 1) / 2;
                ptr = first + len;
            } while (isOrderedAfter(ptr, &t));
            last.initialize(to: t)
        }
    }
}

/// Pop an item from the heap
///
/// Helper function for `SwiftPriorityQueue`.
///
/// Functionally equivalent to:
///
///     swapAt(0, length - 1)
///     let temp = removeLast()
///     sink(0)
///     append(temp)
///
/// The popped item is moved to the end of the heap ready for removal. Assumes the remainder of the heap is valid.
///
///
/// - Parameter first: Pointer to the first element of the heap
/// - Parameter isOrderedAfter: Ordering function. Returns true if `a.pointee` comes after `b.pointee`.
/// - Parameter a: The first pointer
/// - Parameter b: The second pointer
/// - Parameter length: Length of the heap
///
/// - Note: Inspired by [libcxx/include/algorithm](https://github.com/google/libcxx/blob/master/include/algorithm)
@inlinable
internal func __pop_heap<T>(_ first: UnsafeMutablePointer<T>, _ isOrderedAfter: (UnsafeMutablePointer<T>, UnsafeMutablePointer<T>) -> Bool, _ length: Int) {
    let newLength = length - 1
    let newLast = first + newLength
    if length > 1 {
        swap(first, newLast)
        __push_heap_front(first, isOrderedAfter, newLength)
    }
}

/// Correctly position the last item of a heap
///
/// Helper function for `SwiftPriorityQueue`.
///
/// Functionally equivalent to `swim(length - 1)`. Assumes the remainder of the heap is valid.
///
/// - Parameter first: Pointer to the first element of the heap
/// - Parameter ordered: Ordering function. Returns true if `a` and `b` are correcly ordered. Defaults to `<`.
/// - Parameter a: The first element
/// - Parameter b: The second element
/// - Parameter length: Length of the heap
@inlinable
internal func push_heap_back<T: Comparable>(_ first: UnsafeMutablePointer<T>, _ length: Int, _ ordered: (_ a: T, _ b: T) -> Bool = { $0 < $1 } ) {
    __push_heap_back(first, {ordered($0.pointee, $1.pointee)}, length)
}

/// Pop an item from the heap
///
/// Helper function for `SwiftPriorityQueue`.
///
/// Functionally equivalent to:
///
///     swapAt(0, length - 1)
///     let temp = removeLast()
///     sink(0)
///     append(temp)
///
/// The popped item is moved to the end of the heap ready for removal. Assumes the remainder of the heap is valid.
///
/// - Parameter first: Pointer to the first element of the heap
/// - Parameter ordered: Ordering function. Returns true if `a` and `b` are correcly ordered. Defaults to `<`.
/// - Parameter a: The first element
/// - Parameter b: The second element
/// - Parameter length: Length of the heap
@inlinable
internal func pop_heap<T: Comparable>(_ first: UnsafeMutablePointer<T>, _ length: Int, _ ordered: (_ a: T, _ b: T) -> Bool = { $0 < $1 } ) {
    __pop_heap(first, {ordered($0.pointee, $1.pointee)}, length)
}

/// Heapify an array
///
/// Helper function for `SwiftPriorityQueue`
///
/// Functionally equivalent to: `heapify(array)`
///
/// No assumptions are made about the initial order of the heap.
///
/// - Parameter first: Pointer to the first element of the heap
/// - Parameter ordered: Ordering function. Returns true if `a` and `b` are correcly ordered. Defaults to `<`.
/// - Parameter a: The first element
/// - Parameter b: The second element
/// - Parameter length: Length of the heap
@inlinable
internal func heapify<T: Comparable>(_ first: UnsafeMutablePointer<T>, _ length: Int, ordered: (_ a: T, _ b: T) -> Bool = { $0 < $1 } ) {
    __heapify(first, {ordered($0.pointee, $1.pointee)}, length)
}

// MARK: -

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
    /// - parameter a: first argument
    /// - parameter b: second argument
    @inlinable
    public init(order: @escaping (_ a: T, _ b: T) -> Bool, startingValues: [T] = []) {
        ordered = order
        
        // Based on "Heap construction" from Sedgewick p 323
        heap = startingValues
        heap.withUnsafeMutableBufferPointer { bufferPointer in
            guard let first = bufferPointer.baseAddress else {
                return
            }
            heapify(first, bufferPointer.count, ordered: order)
        }
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
        heap.withUnsafeMutableBufferPointer { bufferPointer in
            guard let first = bufferPointer.baseAddress else {
                return
            }
            push_heap_back(first, bufferPointer.count, ordered)
        }
    }
    
    /// Remove and return the element with the highest priority (or lowest if ascending). O(lg n)
    ///
    /// - returns: The element with the highest priority in the Priority Queue, or nil if the PriorityQueue is empty.
    @inlinable
    public mutating func pop() -> T? {
        
        if heap.isEmpty { return nil }
        heap.withUnsafeMutableBufferPointer { bufferPointer in
            guard let first = bufferPointer.baseAddress else {
                return
            }
            pop_heap(first, bufferPointer.count, ordered)
        }
        return heap.removeLast()
    }
    
    
    /// Removes the first occurence of a particular item. Finds it by value comparison using ==. O(n)
    /// Silently exits if no occurrence found.
    ///
    /// - parameter item: The item to remove the first occurrence of.
    @inlinable
    public mutating func remove(_ item: T) {
        
        
        /// closure returns true if an item was found and moved to the end
        let removed = heap.withUnsafeMutableBufferPointer { bufferPointer -> Bool in
            guard let first = bufferPointer.baseAddress else { return false }
            
            /// pointer to after the last item in the heap
            let last = first + bufferPointer.count
            
            /// pointer to found item
            var current = first
            
            /// item was found
            var found = true
            
            // loop through the array to find the item
            while current.pointee != item {
                current += 1
                if current == last {
                    found = false
                    break
                }
            }
            // if not found, no need to go further
            guard found else { return false }
            
            /// index of item in heap
            let index = current - first
            
            
            // now ignore last item of `heap` and act as if `heap` is one element shorter
            
            /// length of heap with found item removed
            let length = bufferPointer.count - 1
            
            // only necessary if the item found was not the last in the heap
            if current < last - 1 {
                
                @_transparent
                func orderedRef(_ a: UnsafeMutablePointer<T>, _ b: UnsafeMutablePointer<T>) -> Bool {
                    return self.ordered(a.pointee, b.pointee)
                }
                
                // swap found item with last item of heap
                swap(current, last - 1)
                
                /**
                 * this code implements `swim`
                 */
                
                var j = (index - 1) / 2
                
                var node = current
                var nextNode = first + j    // nextNode is the parent node
                
                while node > first && orderedRef(nextNode, node) {
                    swap(nextNode, node)
                    node = nextNode
                    j = (j - 1) / 2
                    nextNode = first + j
                }
                
                // if node has changed, sink is unneccessary
                if node != current {
                    return true
                }
                
                /**
                 * this code implements `sink`
                 */
                
                j = 2 * index + 1
                nextNode = first + j    // nextNode is the left child
                
                while j < length {
                    
                    if j < (length - 1) && orderedRef(nextNode, (nextNode + 1)) {
                        j += 1
                        nextNode += 1
                    }
                    if !orderedRef(node, nextNode) { break }
                    
                    swap(node, nextNode)
                    
                    j = 2 * j + 1
                    node = nextNode
                    nextNode = first + j
                }
            }
            return true
        }
        // found item was moved to the end and must be removed
        if removed {
            heap.removeLast()
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
    public var description: String { return String(describing: heap) }
    
    @inlinable
    public var debugDescription: String { return String(reflecting: heap) }
}
