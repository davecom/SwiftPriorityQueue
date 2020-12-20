//
//  SwiftPriorityQueueTests.swift
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

import XCTest
import Foundation
@testable import SwiftPriorityQueue

// based on gist https://gist.github.com/rymcol/48a505c2a1c874daea52a296a2687f5f
// so we have something that sorta kinda looks like arc4random_uniform() on Linux
#if os(Linux)
    import SwiftGlibc
    
    public func arc4random_uniform(_ max: UInt32) -> Int32 {
        return (SwiftGlibc.rand() % Int32(max-1))
    }
#endif

class SwiftPriorityQueueTests: XCTestCase {
    
    func testFastIteratingReturnsValuesInSameOrderOfIndexIteration() {
        var pq = PriorityQueue<Int>(order: <, startingValues: [1, 2, 3, 4, 5])
        
        var fastIterationValues = [Int]()
        var iter = pq.makeIterator()
        while let element = iter.next() {
            fastIterationValues.append(element)
        }
        
        var indexIterationValues = [Int]()
        for i in pq.startIndex..<pq.endIndex {
            indexIterationValues.append(pq[i])
        }
        
        XCTAssertEqual(fastIterationValues, indexIterationValues)
        
        // Let's also test with the other sort:
        fastIterationValues.removeAll(keepingCapacity: true)
        indexIterationValues.removeAll(keepingCapacity: true)
        pq = PriorityQueue<Int>(order: >, startingValues: [5, 4, 3, 2, 1])
        
        iter = pq.makeIterator()
        while let element = iter.next() {
            fastIterationValues.append(element)
        }
        
        var indexIterationValue = [Int]()
        for i in pq.startIndex..<pq.endIndex {
            indexIterationValue.append(pq[i])
        }
        
        XCTAssertEqual(fastIterationValues, indexIterationValue)
    }
    
    func testIteratingViaIndexesValueSemantics() {
        var pq = PriorityQueue<Int>(order: <, startingValues: [1, 2, 3, 4, 5])
        var expectedHeap = pq.heap
        for i in pq.indices {
            let _ = pq[i]
        }
        XCTAssertEqual(pq.heap, expectedHeap)
        
        // Let's also test with the other sort:
        pq = PriorityQueue<Int>(order: >, startingValues: [5, 4, 3, 2, 1])
        expectedHeap = pq.heap
        for i in pq.indices {
            let _ = pq[i]
        }
        XCTAssertEqual(pq.heap, expectedHeap)
    }
    
    func testCustomOrder() {
        let priorities = [0: 5000, 1: 4000, 2: 3000, 3: 2000, 4: 1000, 5: 0]
        var pq: PriorityQueue<Int> = PriorityQueue<Int>(order: { priorities[$0]! > priorities[$1]! })
        for i in 0...5 {
            pq.push(i);
        }
        
        let expected: [Int] = [5, 4, 3, 2, 1, 0]
        var actual: [Int] = []
        for j in pq {
            actual.append(j)
        }
        
        XCTAssertEqual(expected, actual)
    }
    
    func testBasic() {
        var pq: PriorityQueue<Int> = PriorityQueue<Int>()
        for i in 0..<10 {
            pq.push(i);
        }
        
        let expected: [Int] = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
        var actual: [Int] = []
        for j in pq {
            actual.append(j)
        }
        
        XCTAssertEqual(expected, actual, "Basic 10 Integer Array Test Pass")
    }
    
    func testString() {
        var pq: PriorityQueue<String> = PriorityQueue<String>()
        var s = "a"
        while (s < "aaaaaa") {
            pq.push(s)
            s += "a"
        }
        
        let expected: [String] = ["aaaaa", "aaaa", "aaa", "aa", "a"]
        var actual: [String] = []
        for i in pq {
            actual.append(i)
        }
        
        XCTAssertEqual(expected, actual, "Basic 5 String Array Test Pass")
    }
    
    func testSetEquiv() {
        for _ in 0..<100 {
            var s = Set((0..<(arc4random_uniform(100))).map { _ in arc4random_uniform(1000000) })
            var q = PriorityQueue.init(startingValues: Array(s))
            XCTAssertEqual(s.count, q.count, "Incorrect count with elements: " + s.description)
            while let se = s.max() {
                XCTAssertEqual(se, q.pop(), "Incorrect max item with elements: " + s.description)
                s.remove(se)
            }
            XCTAssert(q.isEmpty, "Is not empty. Still contains: " + q.description)
        }
    }
    
    func testClear() {
        var pq: PriorityQueue<Int> = PriorityQueue<Int>()
        for i in 0..<10 {
            pq.push(i);
        }
        pq.clear()
        XCTAssert(pq.isEmpty, "Is not empty. Still contains: " + pq.description)
    }
    
    func testPeek() {
        var pq: PriorityQueue<Int> = PriorityQueue<Int>()
        pq.push(1)
        pq.push(5)
        pq.push(3)
        XCTAssertEqual(pq.peek(), 5, "Peek didn't return top element: " + pq.description)
    }
    
    func testRemove() {
        var pq: PriorityQueue<Int> = PriorityQueue<Int>()
        for i in 0..<10 {
            pq.push(i);
        }
        
        pq.remove(4)
        pq.remove(7)
        
        let expected: [Int] = [9, 8, 6, 5, 3, 2, 1, 0]
        var actual: [Int] = []
        for j in pq {
            actual.append(j)
        }
        
        XCTAssertEqual(expected, actual, "Trouble Removing 4 or 7")
    }
    
    func testRemoveAll() {
        var pq: PriorityQueue<Int> = PriorityQueue<Int>()
        for i in 0..<10 {
            pq.push(i);
        }
        
        pq.push(4)
        pq.push(7)
        pq.push(7)
        
        pq.remove(4)
        pq.removeAll(7)
        
        let expected: [Int] = [9, 8, 6, 5, 4, 3, 2, 1, 0]
        var actual: [Int] = []
        for j in pq {
            actual.append(j)
        }
        
        XCTAssertEqual(expected, actual, "Trouble Removing 4 or all 7s")
    }
    
    func testRemoveLastInHeap() {
        var pq: PriorityQueue<Int> = PriorityQueue<Int>()
        pq.push(1)
        pq.push(2)
        
        pq.remove(1)
        
        let expected: [Int] = [2]
        var actual: [Int] = []
        for j in pq {
            actual.append(j)
        }
        
        XCTAssertEqual(expected, actual)
    }
    
    static var allTests = [
        ("testCustomOrder", testCustomOrder),
        ("testBasic", testBasic),
        ("testString", testString),
        ("testSetEquiv", testSetEquiv),
        ("testClear", testClear),
        ("testPeek", testPeek),
        ("testRemove", testRemove),
        ("testRemoveAll", testRemoveAll),
        ("testRemoveLastInHeap", testRemoveLastInHeap),
        ]
}
