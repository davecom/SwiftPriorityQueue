//
//  AppDelegate.swift
//  SwiftPriorityQueue
//
//  Created by David Kopec on 3/27/15.
//  Copyright (c) 2015 Oak Snow Consulting. All rights reserved.
//

import Cocoa

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

struct Point: Hashable {
    let x: Int
    let y: Int
    var hashValue: Int { return (Int) (x^y) }
}

func == (lhs: Point, rhs: Point) -> Bool {
    return lhs.x == rhs.x && lhs.x == rhs.x
}


class MazeView: NSView {
    let NUM_ROWS: Int = 20
    let NUM_COLS: Int = 20
    var hasStart: Bool = false
    var start: Point = Point(x: -1, y: -1)
    var goal: Point = Point(x: -1, y: -1)
    var position: [[Cell]] = [[Cell]]()  /*{
        didSet {
            for var i = 0; i < position.count; i++ {
                for var j = 0; j < position[0].count; j++ {
                    CATransaction.begin()
                    CATransaction.setValue(NSNumber(float: 1.0), forKey: kCATransactionAnimationDuration)
                    cellLayers[i][j].backgroundColor = position[i][j].color()
                    CATransaction.commit()
                }
            }
            
        }
    }*/
    var cellLayers:[[CALayer]] = [[CALayer]]()
    override func awakeFromNib() {
        wantsLayer = true
        let width: CGFloat = self.bounds.size.width
        let height: CGFloat = self.bounds.size.height
        for var i = 0; i < NUM_ROWS; i++ {
            cellLayers.append([CALayer]())
            position.append([Cell]())
            for var j = 0; j < NUM_COLS; j++ {
                var temp: CALayer = CALayer()
                var cell: Cell = .Empty
                let x = arc4random_uniform(5)
                if x == 0 {
                    cell = .Blocked
                }
                position[i].append(cell)
                temp.borderColor = NSColor.purpleColor().CGColor
                temp.backgroundColor = cell.color()
                temp.frame = CGRectMake(CGFloat(CGFloat(i) * (width / CGFloat(NUM_COLS))), CGFloat(CGFloat(j) * (height / CGFloat(NUM_ROWS))), (width / CGFloat(NUM_COLS)), (height / CGFloat(NUM_ROWS)))
                layer?.addSublayer(temp)
                cellLayers[i].append(temp)
            }
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        let width: CGFloat = self.bounds.size.width
        let height: CGFloat = self.bounds.size.height
        
        var bPath:NSBezierPath = NSBezierPath()
        bPath.moveToPoint(NSMakePoint(width/3, 0))
        bPath.lineToPoint(NSMakePoint(width/3, height))
        bPath.moveToPoint(NSMakePoint(width/3 * 2, 0))
        bPath.lineToPoint(NSMakePoint(width/3 * 2, height))
        bPath.moveToPoint(NSMakePoint(0, height/3))
        bPath.lineToPoint(NSMakePoint(width, height/3))
        bPath.moveToPoint(NSMakePoint(0, height/3 * 2))
        bPath.lineToPoint(NSMakePoint(width, height/3 * 2))
        bPath.stroke()
        
    }
    
    override func mouseDown(theEvent: NSEvent) {
        let width: CGFloat = self.bounds.size.width
        let height: CGFloat = self.bounds.size.height
        let mousePlace:NSPoint = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        let row: Int = Int(mousePlace.x / (width / CGFloat(NUM_ROWS)))
        let col: Int = Int(mousePlace.y / (height / CGFloat(NUM_COLS)))
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
                if (p.x + 1 < NUM_ROWS && position[p.x + 1][p.y] != .Blocked) {
                    ar.append(Point(x: p.x + 1, y: p.y))
                }
                if (p.x - 1 >= 0 && position[p.x - 1][p.y] != .Blocked) {
                    ar.append(Point(x: p.x - 1, y: p.y))
                }
                if (p.y + 1 < NUM_ROWS && position[p.x][p.y + 1] != .Blocked) {
                    ar.append(Point(x: p.x, y: p.y + 1))
                }
                if (p.y - 1 >= 0 && position[p.x][p.y - 1] != .Blocked) {
                    ar.append(Point(x: p.x, y: p.y - 1))
                }
                
                return ar
            }
            
            func heuristic(p: Point) -> Float {  // Manhattan distance
                let xdist = abs(p.x - goal.x)
                let ydist = abs(p.y - goal.y)
                return Float(xdist + ydist)
            }
            
            if let path:[Point] = astar(start, goalTest, successors, heuristic) {
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

