//
//  SwiftPriorityQueuePerformanceTests.swift
//  SwiftPriorityQueue
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
@testable import SwiftPriorityQueue

class SwiftPriorityQueuePerformanceTests: XCTestCase {
    
    func testBuildPerformance() {
        let input: [Int] = Array((0 ..< 100000))
        measure {
            let _: PriorityQueue<Int> = PriorityQueue(ascending: true, startingValues: input)
        }
    }
    
    func testPopPerformance() {
        let original = PriorityQueue(ascending: true, startingValues: Array(0 ..< 100000))
        measure {
            var pq = original
            for _ in 0 ..< 100000 {
                let _ = pq.pop()
            }
        }
    }
    
    func testPushPerformance() {
        measure {
            var pq = PriorityQueue<Int>(ascending: true, startingValues: [])
            for i in 0 ..< 100000 {
                pq.push(i)
            }
        }
    }
    
    func testRemovePerformance() {
        let original = PriorityQueue(ascending: true, startingValues: Array(0 ..< 10000))
        measure {
            var pq = original
            for x in 0 ..< 100 {
                pq.remove(x * x)
            }
        }
    }
    
    static var allTests = [
        ("testBuildPerformance", testBuildPerformance),
        ("testPopPerformance", testPopPerformance),
        ("testPushPerformance", testPushPerformance),
        ("testRemovePerformance", testRemovePerformance)
    ]
}
