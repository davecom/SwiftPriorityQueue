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
            while let se = s.maxElement() {
                XCTAssertEqual(se, q.pop(), "Incorrect max item with elements: " + s.description)
                s.remove(se)
            }
            XCTAssert(q.isEmpty, "Is not empty. Still contains: " + q.description)
        }
    }
    
}
