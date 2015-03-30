//
//  SwiftPriorityQueue.swift
//  SwiftPriorityQueue
//
//  Copyright (c) 2015 David Kopec
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
class PriorityQueue<T: Comparable>: Printable, GeneratorType, SequenceType, CollectionType {
    private final var heap: [T] = []
    private let contrast: (T, T) -> Bool
    
    convenience init() {
        self.init(ascending: false, startingValues: [])
    }
    
    convenience init(ascending: Bool) {
        self.init(ascending: ascending, startingValues: [])
    }
    
    convenience init(startingValues: [T]) {
        self.init(ascending: false, startingValues: startingValues)
    }
    
    init(ascending: Bool, startingValues: [T]) {
        if ascending {
            contrast = {$0 > $1}
        } else {
            contrast = {$0 < $1}
        }
        
        for value in startingValues {
            push(value)
        }
    }
    
    /// How many elements are in the Priority Queue?
    var count: Int {
        return heap.count
    }
    
    /// Are there any elements in the Priority Queue?
    var isEmpty: Bool {
        return heap.isEmpty
    }
    
    /// Add a new element onto the Priority Queue.
    func push(element: T) {
        heap.append(element)
        swim((heap.count - 1))
    }
    
    /// Remove and return the element with the highest priority (or lowest if ascending).
    func pop() -> T? {
        if heap.isEmpty {
            return nil;
        }
        swap(&heap[0], &heap[(heap.count - 1)])
        let temp: T = heap.removeLast()
        sink(0)
        
        return temp
    }
    
    /// Eliminate all of the elements from the Priority Queue.
    func clear() {
        heap.removeAll(keepCapacity: false)
    }
    
    // Based on example from Sedgewick p 316
    private func sink(index: Int) {
        var k: Int = index
        while (((2 * k) + 1) < heap.count) {
            var j: Int = (2 * k) + 1
            if j < (heap.count - 1) && contrast(heap[j], heap[(j + 1)]) {
                j++
            }
            if !contrast(heap[k], heap[j]) {
                break;
            }
            swap(&heap[k], &heap[j])
            k = j
        }
    }
    
    // Based on example from Sedgewick p 316
    private func swim(index: Int) {
        var k: Int = index
        while k > 0 && contrast(heap[((k - 1) / 2)], heap[k]) {
            swap(&heap[((k - 1) / 2)], &heap[k])
            k = ((k - 1) / 2)
        }
    }
    
    //Implement Printable protocol
    var description: String {
        return heap.description
    }
    
    //Implement GeneratorType
    typealias Element = T
    func next() -> Element? {
        if let e = pop() {
            return e
        }
        return nil
    }
    
    //Implement SequenceType
    typealias Generator = PriorityQueue
    func generate() -> Generator {
        return self
    }
    
    //Implement CollectionType
    typealias Index = Int
    
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        return count
    }
    
    subscript(i: Int) -> T {
        return heap[i]
    }
}