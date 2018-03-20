//
//  astar.swift
//  SwiftPriorityQueue
//
//  Copyright (c) 2015-2017 David Kopec
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

// This is an example of astar that uses SwiftPriorityQueue

class Node<T>: Comparable, Hashable {
    let state: T
    let parent: Node?
    let cost: Float
    let heuristic: Float
    init(state: T, parent: Node?, cost: Float, heuristic: Float) {
        self.state = state
        self.parent = parent
        self.cost = cost
        self.heuristic = heuristic
    }
    
    var hashValue: Int { return (Int) (cost + heuristic) }
}

func < <T>(lhs: Node<T>, rhs: Node<T>) -> Bool {
    return (lhs.cost + lhs.heuristic) < (rhs.cost + rhs.heuristic)
}

func == <T>(lhs: Node<T>, rhs: Node<T>) -> Bool {
    return lhs === rhs
}

/// Formulate a result path as an array from a goal node found in an astar search
///
/// - parameter startNode: The goal node found from an astar search.
/// - returns: An array containing the states to get from the start to the goal.
func backtrack<T>(_ goalNode: Node<T>) -> [T] {
    var sol: [T] = []
    var node = goalNode
    
    while (node.parent != nil) {
        sol.append(node.state)
        node = node.parent!
    }
    
    sol.append(node.state)
    
    return sol
}

/// Find the shortest path from a start state to a goal state.
///
/// - parameter initialState: The state that we are starting from.
/// - parameter goalTestFn: A function that determines whether a state is the goal state.
/// - parameter successorFn: A function that finds the next states from a state.
/// - parameter heuristicFn: A function that makes an underestimate of distance from a state to the goal.
/// - returns: A path from the start state to a goal state as an array.
func astar<T: Hashable>(_ initialState: T, goalTestFn: (T) -> Bool, successorFn: (T) -> [T], heuristicFn: (T) -> Float) -> [T]? {
    var frontier = PriorityQueue(ascending: true, startingValues: [Node(state: initialState, parent: nil, cost: 0, heuristic: heuristicFn(initialState))])
    var explored = Dictionary<T, Float>()
    explored[initialState] = 0
    var nodesSearched: Int = 0
    
    while let currentNode = frontier.pop() {
        nodesSearched += 1
          // we know if there are still items, we can pop one
        let currentState = currentNode.state
        
        if goalTestFn(currentState) {
            print("Searched \(nodesSearched) nodes.")
            return backtrack(currentNode)
        }
        
        for child in successorFn(currentState) {
            let newcost = currentNode.cost + 1  //1 assumes a grid, there should be a cost function
            if (explored[child] == nil) || (explored[child]! > newcost) {
                explored[child] = newcost
                frontier.push(Node(state: child, parent: currentNode, cost: newcost, heuristic: heuristicFn(child)))
            }
        }
    }
    
    return nil
}
