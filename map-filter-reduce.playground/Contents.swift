//: Playground - noun: a place where people can play

import UIKit

// Imperative approach

func incrementArray(_ xs: [Int]) -> [Int] {
    var result: [Int] = []
    for x in xs {
        result.append(x+1)
    }
    return result
}

func doubleArray(_ xs: [Int]) -> [Int] {
    var result: [Int] = []
    for x in xs {
        result.append(x * 2)
    }
    return result
}

// Declarative approach 1

func computeIntArray(_ xs: [Int], _ transform: (Int) -> Int) -> [Int] {
    var result: [Int] = []
    for x in xs {
        result.append(transform(x))
    }
    return result
}

func incrementArray1(_ xs: [Int]) -> [Int] {
    return computeIntArray(xs) { x in x + 1 }
}

func doubleArray1(_ xs: [Int]) -> [Int] {
    return computeIntArray(xs) { x in x * 2}
}

// Problem of declarative approach 2

func computeBoolArray(_ xs: [Int], _ transform: (Int) -> Bool) -> [Bool] {
    var result: [Bool] = []
    for x in xs {
        result.append(transform(x))
    }
    return result
}

func isEvenArray(_ xs: [Int]) -> [Bool] {
    return computeBoolArray(xs) { x in x % 2 == 0 }
}

// Declarative approach with generics and class extension

extension Array {
    func myMap<T>(_ transform: (Element) -> T) -> [T] {
        var result: [T] = []
        for x in self {
            result.append(transform(x))
        }
        return result
    }
    
    func myFilter(_ shouldInclude: (Element) -> Bool) -> [Element] {
        var result: [Element] = []
        for x in self where shouldInclude(x) {
            result.append(x)
        }
        return result
    }
    
    func myReduce<T>(_ initial: T, _ calculate: (T, Element) -> T) -> T {
        var result = initial
        for x in self {
            result = calculate(result, x)
        }
        return result
    }
    
    func mapWithReduce<T>(_ transform: (Element) -> T) -> [T] {
        return myReduce([]) { result, x in
            return result + [transform(x)]
        }
    }
    
    func filterWithReduce(_ shouldInclude: (Element) -> Bool) -> [Element] {
        return myReduce([]) { result, x in
            return shouldInclude(x) ? result + [x] : result
        }
    }
}


func genericComputeArray <T> (_ xs: [Int], _ transform: (Int) -> T) -> [T] {
    return xs.myMap(transform)
}

func flatten<T>(_ xss:[[T]]) -> [T] {
    return xss.myReduce([]) { result, xs in result + xs }
}

// Example

struct City {
    let name: String
    let population: Int
}

let paris = City(name: "Paris", population: 2241)
let madrid = City(name: "Madrid", population: 3165)
let amsterdam = City(name: "Amsterdam", population: 827)
let berlin = City(name: "Berlin", population: 3562)
let cities = [paris, madrid, amsterdam, berlin]

extension City {
    func cityByScalingPopulation() -> City {
        return City(name: self.name, population: self.population * 1000)
    }
}

let result = cities.filter { $0.population > 1000 }
    .map { $0.cityByScalingPopulation() }
    .reduce("City: Population") { result, city in
        result + "\n" + "\(city.name): \(city.population)"
}

print(result)
