//
//  AppDelegate.swift
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

// This is an example of a maze search that uses astar via SwiftPriorityQueue

import Cocoa

// A Cell represents a grid location in the maze
enum Cell {
    case Empty
    case Blocked
    case Start
    case Goal
    case Path
    func color() -> CGColorRef {
        switch (self) {
        case Empty: return NSColor.whiteColor().CGColor
        case Blocked: return NSColor.blackColor().CGColor
        case Start: return NSColor.greenColor().CGColor
        case Goal: return NSColor.redColor().CGColor
        case Path: return NSColor.yellowColor().CGColor
        }
    }
}

// A point is a way to refer to the row and column of a cell
struct Point: Hashable {
    let x: Int
    let y: Int
    var hashValue: Int { return (Int) (x.hashValue * 31 + y.hashValue) }
}

func == (lhs: Point, rhs: Point) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}


class MazeView: NSView {
    let NUM_ROWS: Int = 20
    let NUM_COLS: Int = 20
    var hasStart: Bool = false
    var start: Point = Point(x: -1, y: -1)
    var goal: Point = Point(x: -1, y: -1)
    var path: [Point] = [Point]()
    var position: [[Cell]] = [[Cell]]()
    var cellLayers:[[CALayer]] = [[CALayer]]()
    
    // initialize the cells
    override func awakeFromNib() {
        wantsLayer = true
        let width: CGFloat = self.bounds.size.width
        let height: CGFloat = self.bounds.size.height
        for i in 0..<NUM_ROWS {
            cellLayers.append([CALayer]())
            position.append([Cell]())
            for j in 0..<NUM_COLS {
                let temp: CALayer = CALayer()
                var cell: Cell = .Empty
                let x = arc4random_uniform(5)
                if x == 0 {
                    cell = .Blocked
                }
                position[i].append(cell)
                temp.borderColor = NSColor.purpleColor().CGColor
                temp.backgroundColor = cell.color()
                temp.frame = CGRectMake(CGFloat(CGFloat(j) * (width / CGFloat(NUM_COLS))), CGFloat(CGFloat(i) * (height / CGFloat(NUM_ROWS))), (width / CGFloat(NUM_COLS)), (height / CGFloat(NUM_ROWS)))
                layer?.addSublayer(temp)
                cellLayers[i].append(temp)
            }
        }
    }
    
    // when a click occurs, place a start and a goal cell, then ultimately do an astar search
    override func mouseDown(theEvent: NSEvent) {
        let width: CGFloat = self.bounds.size.width
        let height: CGFloat = self.bounds.size.height
        let mousePlace:NSPoint = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        let col: Int = Int(mousePlace.x / (width / CGFloat(NUM_ROWS)))
        let row: Int = Int(mousePlace.y / (height / CGFloat(NUM_COLS)))
        if position[row][col] != .Empty {  //can only click on empty cells
            return
        }
        if !hasStart {
            if start.x != -1 {
                position[start.x][start.y] = .Empty
                cellLayers[start.x][start.y].backgroundColor = position[start.x][start.y].color()
            }
            if goal.x != -1 {
                position[goal.x][goal.y] = .Empty
                cellLayers[goal.x][goal.y].backgroundColor = position[goal.x][goal.y].color()
            }
            for p in path {  // clear path
                if p != start && p != goal {
                    let row = p.x
                    let col = p.y
                    position[row][col] = .Empty
                    CATransaction.begin()
                    CATransaction.setValue(NSNumber(float: 0.5), forKey: kCATransactionAnimationDuration)
                    cellLayers[row][col].backgroundColor = position[row][col].color()
                    CATransaction.commit()
                }
            }
            position[row][col] = .Start
            CATransaction.begin()
            CATransaction.setValue(NSNumber(float: 0.5), forKey: kCATransactionAnimationDuration)
            cellLayers[row][col].backgroundColor = position[row][col].color()
            CATransaction.commit()
            hasStart = true
            start = Point(x: row, y: col)
        } else {
            position[row][col] = .Goal
            CATransaction.begin()
            CATransaction.setValue(NSNumber(float: 0.5), forKey: kCATransactionAnimationDuration)
            cellLayers[row][col].backgroundColor = position[row][col].color()
            CATransaction.commit()
            hasStart = false
            goal = Point(x: row, y: col)
            
            //find path
            
            func goalTest(x: Point) -> Bool {
                if x == goal {
                    return true
                }
                return false
            }
            
            func successors(p: Point) -> [Point] { //can't go on diagonals
                var ar: [Point] = [Point]()
                if (p.x + 1 < NUM_ROWS) && (position[p.x + 1][p.y] != .Blocked) {
                    ar.append(Point(x: p.x + 1, y: p.y))
                }
                if (p.x - 1 >= 0) && (position[p.x - 1][p.y] != .Blocked) {
                    ar.append(Point(x: p.x - 1, y: p.y))
                }
                if (p.y + 1 < NUM_COLS) && (position[p.x][p.y + 1] != .Blocked) {
                    ar.append(Point(x: p.x, y: p.y + 1))
                }
                if (p.y - 1 >= 0) && (position[p.x][p.y - 1] != .Blocked) {
                    ar.append(Point(x: p.x, y: p.y - 1))
                }
                
                return ar
            }
            
            func heuristic(p: Point) -> Float {  // Manhattan distance
                let xdist = abs(p.x - goal.x)
                let ydist = abs(p.y - goal.y)
                return Float(xdist + ydist)
            }
            
            if let pathresult:[Point] = astar(start, goalTestFn: goalTest, successorFn: successors, heuristicFn: heuristic) {
                path = pathresult
                for p in path {
                    if p != start && p != goal {
                        let row = p.x
                        let col = p.y
                        position[row][col] = .Path
                        CATransaction.begin()
                        CATransaction.setValue(NSNumber(float: 0.5), forKey: kCATransactionAnimationDuration)
                        cellLayers[row][col].backgroundColor = position[row][col].color()
                        CATransaction.commit()
                    }
                }
            }
        }
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

