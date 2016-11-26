//
//  SwiftPriorityQueueTests.swift
//  SwiftPriorityQueueTests
//
//  Created by David Kopec on 3/27/15.
//  Copyright (c) 2015 Oak Snow Consulting. All rights reserved.
//

import Cocoa
import XCTest
import Foundation

class SwiftPriorityQueueTests: XCTestCase {
    
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
            var s = Set((0..<(arc4random_uniform(100))).map { _ in arc4random_uniform(UInt32.max) })
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
    
}
