### 1.4.0
- Added a push() with a size limit, removing the lowest priority item (thanks @reedes)
- Added some asserts and tests (thanks @vale-cocoa)

### 1.3.1
- Improvements to pop() performance (thanks @peteraisher)
- Some basic performance tests (thanks @peteraisher)

### 1.3.0
- Swift 5 support

### 1.2.1
- Fixed a critical bug in remove() and added a test for it
- Rearranged the project to be testable on Linux
- Updated the format of Package.swift to be in-line with Swift 4

### 1.2.0
> Note: 1.2.0 is the first version of SwiftPriorityQueue to break compatibility with previous versions of Swift since release 1.0.1. From this point forward users of Swift 2 and Swift 3 should use release 1.1.2 of SwiftPriorityQueue.

- Swift 4 support
- Removed preprocessor macros and code to support Swift 2

### 1.1.2
- Initializer that takes custom order function added
- watchOS added to podspec

### 1.1.1
- Added remove(item: T) method to remove an item at an arbitrary location
- Added removeAll(item: T) method to remove multiple of the same item

### 1.1.0
- Swift 3 support

### 1.0.3
- Last Swift 2 only release
- Improved unit tests

### 1.0.2
- Better Swift 2 support

### 1.0.1
- Access control bug fix
- Documentation Additions

### 1.0
- Initial Stable Release
- Last Release to support Swift 1.2

