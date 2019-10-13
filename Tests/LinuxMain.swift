import XCTest
@testable import SwiftPriorityQueueTests

XCTMain([
    testCase(SwiftPriorityQueueTests.allTests),
    testCase(SwiftPriorityQueuePerformanceTests.allTests),
])
