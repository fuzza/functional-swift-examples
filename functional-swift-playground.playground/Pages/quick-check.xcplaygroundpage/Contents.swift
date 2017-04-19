//: [Previous](@previous)

import Foundation

func tabulate<A>(times:Int, _ transform: (Int) -> A) -> [A] {
    return (0..<times).map(transform)
}

protocol Arbitrary: Smaller {
    static func arbitrary() -> Self
}

protocol Smaller {
    func smaller() -> Self?
}

extension Smaller {
    func smaller() -> Self? {
        return nil
    }
}

extension Int: Arbitrary {
    static func arbitrary() -> Int {
        return Int(arc4random())
    }
    
    func smaller() -> Int? {
        return self == 0 ? nil : self / 2
    }
}

extension Int {
    static func random(from:Int, to: Int) -> Int {
        return from + Int(arc4random()) % (to - from)
    }
}

extension Character: Arbitrary {
    static func arbitrary() -> Character {
        let scalar = UInt8(Int.random(from:65, to:90))
        return Character(UnicodeScalar(scalar))
    }
}

extension String: Arbitrary {
    static func arbitrary() -> String {
        let randomLength = Int.random(from: 0, to: 40)
        let characters = tabulate(times: randomLength) { _ in Character.arbitrary() }
        return String(characters)
    }
    
    func smaller() -> String? {
        return isEmpty ? nil : String(self.characters.dropFirst())
    }
}

extension Array where Element: Arbitrary {
    static func arbitrary() -> [Element] {
        let randomLength = Int.random(from: 0, to: 50)
        return tabulate(times: randomLength) { _ in Element.arbitrary() }
    }
}

extension Array: Smaller {
    func smaller() -> Array<Element>? {
        guard !isEmpty else { return nil }
        return Array(dropFirst())
    }
}

let numberOfIterations = 10
func iterateWhile<A>(_ condition: (A) -> Bool, initial: A, _ next: (A) -> A?) -> A {
    if let x = next(initial), condition(x) {
        return iterateWhile(condition, initial: x, next)
    }
    return initial
}

struct ArbitraryInstance <T> {
    let arbitrary: () -> T
    let smaller: (T) -> T?
}

func checkHelper<A>(_ arbitraryInstance: ArbitraryInstance<A>, _ property: @escaping (A) -> Bool, _ message: String) {
    for _ in 0..<numberOfIterations {
        let value = arbitraryInstance.arbitrary()
        guard property(value) else {
            let smallerValue = iterateWhile({ !property($0) }, initial: value, arbitraryInstance.smaller)
            print("\(message) doesn't hold \(smallerValue)")
            return
        }
    }
    print("\(message) passed tests \(numberOfIterations) times")
}

func check<A: Arbitrary>(_ message: String, _ property: @escaping (A) -> Bool) {
    let arbitraryInstance = ArbitraryInstance(arbitrary: A.arbitrary, smaller: { $0.smaller() })
    checkHelper(arbitraryInstance, property, message)
}

func check<A: Arbitrary>(_ message: String, _ property: @escaping ([A]) -> Bool) {
    let instance = ArbitraryInstance(arbitrary: Array.arbitrary, smaller: { (x: [A]) in x.smaller() })
    checkHelper(instance, property, message)
}

check("Every string starts with hello or empty") { (s: String) in
    s.isEmpty || s.hasPrefix("Hello")
}

func qsort(_ array:[Int]) -> [Int] {
    if (array.isEmpty) { return array }
    
    var mutableArray = array
    let pivot = mutableArray.remove(at: 0)
    
    let lesser = mutableArray.filter { $0 < pivot }
    let greater = mutableArray.filter { $0 >= pivot }

    let pivotArray = [pivot]
    return qsort(lesser) + pivotArray + qsort(greater)
}

check("Qsort should behave like sort") { (x: [Int]) in
    return qsort(x) == x.sorted(by: <)
}

//: [Next](@next)
