//: Playground - noun: a place where people can play

import UIKit


func add1(_ x: Int, _ y: Int) -> Int {
    return x + y
}

func multiply(_ x: Int, _ y: Int) -> Int {
    return x * y
}

add1(1,2)

func add2(_ x: Int) -> (Int) -> Int {
    return { y in x + y }
}

add2(1)(2)

func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> ((B) -> C) {
    return { x in { y in f(x, y) }}
}

let curriedSum = curry(add1)
let curriedFourSum = curriedSum(4)
let curriedSumResult = curriedFourSum(6)

precedencegroup CombiningPrecedence {
    associativity : left
}

infix operator >>> : CombiningPrecedence
func >>> <A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
    return { x in g(f(x)) }
}

let curriedMultiply = curry(multiply)

let curriedMultiplyedSum = curriedMultiply(2) >>> curriedSum(4) >>> curriedSum(-6)
let result = curriedMultiplyedSum(6)







