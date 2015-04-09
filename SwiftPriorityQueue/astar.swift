//
//  astar.swift
//  SwiftPriorityQueue
//
//  Created by David Kopec on 4/8/15.
//  Copyright (c) 2015 Oak Snow Consulting. All rights reserved.
//

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
/// :param: startNode The goal node found from an astar search.
/// :returns: An array containing the states to get from the start to the goal.
func backtrack<T>(goalNode: Node<T>) -> [T] {
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
/// :param: initialState The state that we are starting from.
/// :param: goalTestFn A function that determines whether a state is the goal state.
/// :param: successorFn A function that finds the next states from a state.
/// :param: heuristicFn A function that makes an underestimate of distance from a state to the goal.
/// :returns: A path from the start state to a goal state as an array.
func astar<T: Hashable>(initialState: T, goalTestFn: (T) -> Bool, successorFn: (T) -> [T], heuristicFn: (T) -> Float) -> [T]? {
    var frontier = PriorityQueue(startingValues: [Node(state: initialState, parent: nil, cost: 0, heuristic: 0)])
    var explored = Dictionary<T, Float>()
    explored[initialState] = 0
    
    while !frontier.isEmpty {
        let currentNode = frontier.pop()!  // we know if there are still items, we can pop one
        let currentState = currentNode.state
        
        if goalTestFn(currentState) {
            return backtrack(currentNode)
        }
        
        for child in successorFn(currentState) {
            let newcost = currentNode.cost + 1  //1 assumes a grid, there should be a cost function
            if explored[child] == nil || explored[child] > newcost {
                explored[child] = newcost
                frontier.push(Node(state: child, parent: currentNode, cost: newcost, heuristic: heuristicFn(child)))
            }
        }
    }
    
    return nil
}