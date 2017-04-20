//: [Previous](@previous)

import Foundation

enum Encoding {
    case ASCII
    case NEXTSTEP
    case JapaneseEUC
    case UTF8
}

extension Encoding {
    var nsStringEncoding: String.Encoding {
        switch self {
        case .ASCII: return String.Encoding.ascii
        case .NEXTSTEP: return String.Encoding.nextstep
        case .JapaneseEUC: return String.Encoding.japaneseEUC
        case .UTF8: return String.Encoding.utf8
        }
    }
}

extension Encoding {
    init?(enc: String.Encoding) {
        switch enc {
        case String.Encoding.ascii: self = .ASCII
        case String.Encoding.nextstep: self = .NEXTSTEP
        case String.Encoding.japaneseEUC: self = .JapaneseEUC
        case String.Encoding.utf8: self = .UTF8
        default: return nil
        }
    }
}

func localizedEncodingName(_ encoding: Encoding) -> String {
    return .localizedName(of: encoding.nsStringEncoding)
}

// Associated values

let cities = [
    "Paris": 2241,
    "Madrid": 3165,
    "Amsterdam": 827,
    "Berlin": 3562
]

let capitals = [
    "France": "Paris",
    "Spain": "Madrid",
    "The Netherlands": "Amsterdam",
    "Belgium": "Brussels"
]

enum LookupError: Error {
    case CapitalNotFound
    case PopulationNotFound
    case MayorNotFound
}

enum Result <T> {
    case Failure(Error)
    case Success(T)
}

func populationOfCapital(_ country: String) -> Result<Int> {
    guard let capital = capitals[country] else {
        return .Failure(LookupError.CapitalNotFound)
    }
    guard let population = cities[capital] else {
        return .Failure(LookupError.PopulationNotFound)
    }
    return .Success(population)
}

switch populationOfCapital("France") {
case let .Success(population):
    print("Population is \(population)")
case let .Failure(error):
    print("Error is \(error)")
}

let mayors = [
    "Paris": "Hidalgo",
    "Madrid": "Carmena",
    "Amsterdam": "van der Laan",
    "Berlin": "Müller"
]

func mayorOfCapital1(_ country: String) -> String? {
    return capitals[country].flatMap { mayors[$0] }
}

func mayourOfCapital(_ country:String) -> Result<String> {
    guard let capital = capitals[country] else {
        return .Failure(LookupError.CapitalNotFound)
    }
    guard let mayor = mayors[capital] else {
        return .Failure(LookupError.MayorNotFound)
    }
    return .Success(mayor)
}

// Error handling

func populationOfCapital1(_ country: String) throws -> Int {
    guard let capital = capitals[country] else {
        throw LookupError.CapitalNotFound
    }
    guard let population = cities[capital] else {
        throw LookupError.PopulationNotFound
    }
    return population
}

do {
    let population = try populationOfCapital1("France")
    print("Population is \(population)")
} catch {
    print("Error is \(error)")
}

// Custom unwrapping with default value for Result type

func ??<T>(_ result: Result<T>, _ errorHandler: @autoclosure (Error) -> T) -> T {
    switch result{
    case let .Success(value):
        return value
    case let .Failure(error):
        return errorHandler(error)
    }
}

let successfullResult: Result<Int> = .Success(15)
let intResult = successfullResult ?? 0

let failureResult: Result<Int> = .Failure(LookupError.CapitalNotFound)
let errorResult = failureResult ?? 0

//: [Next](@next)
