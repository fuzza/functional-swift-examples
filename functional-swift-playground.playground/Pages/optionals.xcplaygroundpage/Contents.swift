//: [Previous](@previous)

import Foundation

// Optional binding

let cities = ["Paris": 2241, "Madrid": 3165, "Amsterdam": 827, "Berlin": 3562]
if let madridPopulation = cities["Madrid"] {
    print("The population of Madrid is \(madridPopulation * 1000)")
}

// Optional unwrapping

infix operator ???
func ???<T>(optional: T?, defaultValue: T) -> T {
    if let value = optional {
        return value
    }
    return defaultValue
}
let population1 = cities["Qwerty"] ??? 3232 // Default value is always evaluated if it's result of method etc.

infix operator ????
func ????<T>(optional: T?, defaultValue: () -> T) -> T {
    if let value = optional {
        return value
    }
    return defaultValue()
}
let population2 = cities["Qwerty"] ???? { 23232 } // Should be closured with {}

infix operator ?????
func ?????<T>(optional: T?, defaultValue: @autoclosure () -> T) -> T {
    if let value = optional {
        return value
    }
    return defaultValue()
}
let population3 = cities["Qwerty"] ????? 232323 // Close to perfect

// Optional chaining

struct Order {
    let id: Int
    let person: Person?
}

struct Person {
    let name: String
    let address: Address?
}

struct Address {
    let streetName: String
    let city: String
    let state: String?
}

let order = Order(id: 3, person: nil)
if let state = order.person?.address?.state {
    print("State - \(state)")
} else {
    print("Unknown person, address or state")
}

// Optional switch case

let berlinPopulation = cities["Berlin"]

switch berlinPopulation {
    case 0?: print("Nobody here")
    case (1...1000)?: print("Less than million")
    case .none: print("We don't know about Berlin")
    case .some(let x): print("\(x) people in Berlin")
}

func populationDescriptionForCity(_ city: String) -> String? {
    guard let population = cities[city] else { return nil }
    return "Population of \(city) is \(population * 1000) people"
}

populationDescriptionForCity("Madrid")
populationDescriptionForCity("Qwerty")

// Optional mapping

func incrementOptional(_ optional: Int?) -> Int? {
    guard let x = optional else { return nil }
    return x + 1
}

extension Optional {
    func customMap<U>(_ transform:(Wrapped) -> U) -> U? {
        guard let x = self else { return nil }
        return transform(x)
    }
}

func incrementOptional2(_ optional: Int?) -> Int? {
    return optional.customMap { $0 + 1 }
}

// Optional binding revisited

func addOptionals1(_ x: Int?, _ y: Int?) -> Int? {
    if let ux = x {
        if let uy = y {
            return ux + uy
        }
    }
    return nil
}

func addOptionals2(_ x: Int?, _ y: Int?) -> Int? {
    if let ux = x, let uy = y {
        return ux + uy
    }
    return nil
}

func addOptionals3(_ x: Int?, _ y: Int?) -> Int? {
    guard let ux = x, let uy = y else { return nil }
    return ux + uy
}

let capitals = [
    "France": "Paris",
    "Spain": "Madrid",
    "The Netherlands": "Amsterdam",
    "Belgium": "Brussels"
]

func populationOfCapital(country: String) -> Int? {
    guard let capital = capitals[country], let population = cities[capital] else { return nil }
    return population * 1000
}

populationOfCapital(country: "France")
populationOfCapital(country: "Unknown country")

// Optional flat map

func addOptionals4(_ x: Int?, _ y: Int?) -> Int? {
    return x.flatMap { ux in
        y.flatMap { uy in
            return ux + uy
        }
    }
}

func populationOfCapital2(country: String) -> Int? {
    return capitals[country].flatMap { capital in
        cities[capital].flatMap { population in
            return population * 1000
        }
    }
}

func populationOfCapital3(country: String) -> Int? {
    return capitals[country].flatMap { capital in
        return cities[capital]
    }.flatMap { population in
        return population * 1000
    }
}

//: [Next](@next)
