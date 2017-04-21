//: [Previous](@previous)

import Foundation

extension Sequence {
    func all(_ predicate: (Iterator.Element) -> Bool)  -> Bool {
        for x in self where !predicate(x) {
            return false
        }
        return true
    }
}

indirect enum BinarySearchTree <Element: Comparable> {
    case Leaf
    case Node (BinarySearchTree<Element>, Element, BinarySearchTree<Element>)
}

let leaf = BinarySearchTree<Int>.Leaf
let node = BinarySearchTree<Int>.Node(leaf, 5, leaf)

extension BinarySearchTree {
    init() {
        self = .Leaf
    }
    
    init(value: Element) {
        self = .Node(.Leaf, value, .Leaf)
    }
}

extension BinarySearchTree {
    var count: Int {
        switch self {
        case .Leaf:
            return 0
        case let .Node(left, _, right):
            return 1 + left.count + right.count
        }
    }
}

extension BinarySearchTree {
    var elements: [Element] {
        switch self {
        case .Leaf:
            return []
        case let .Node(left, x, right):
            return left.elements + [x] + right.elements
        }
    }
}

extension BinarySearchTree {
    var isEmpty: Bool {
        if case .Leaf = self {
            return true
        }
        return false
    }
}

extension BinarySearchTree {
    var isBST: Bool {
        switch self {
        case .Leaf:
            return true
        case let .Node(left, x, right):
            return left.elements.all { $0 < x }
                && right.elements.all { $0 > x}
                && left.isBST
                && right.isBST
        }
    }
}

extension BinarySearchTree {
    func contains(_ value: Element) -> Bool {
        switch self {
        case .Leaf:
            return false
        case let .Node(_, x, _) where value == x:
            return true
        case let .Node(left, x, _) where value < x:
            return left.contains(value)
        case let .Node(_, x, right) where value > x:
            return right.contains(value)
        default:
            fatalError("Should not happen")
        }
    }
}

extension BinarySearchTree {
    mutating func insert(_ value: Element) {
        switch self {
        case .Leaf:
            self = BinarySearchTree(value: value)
        case let .Node(left, x, right):
            var mutableLeft = left
            var mutableRight = right
            if(value < x) { mutableLeft.insert(value) }
            if(value > x) { mutableRight.insert(value) }
            self = .Node(mutableLeft, x, mutableRight)
        }
    }
}

let tree = BinarySearchTree(value:0)
var mutableTree = tree

mutableTree.insert(10)
mutableTree.insert(8)

print(tree.elements)
print(mutableTree.elements)

//: [Next](@next)
