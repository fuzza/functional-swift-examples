//: Playground - noun: a place where people can play

import UIKit

typealias Distance = Double

struct Position {
    var x: Double
    var y: Double
}

extension Position {
    func inRange(_ range: Distance) -> Bool {
        return sqrt(x*x + y*y) <= range;
    }
}

extension Position {
    func minus(_ position: Position) -> Position {
        return Position(x: x - position.x, y: y - position.y)
    }
    
    var length: Double {
        return sqrt(x * x + y * y)
    }
}

struct Ship {
    var position: Position
    var firingRange: Distance
    var unsafeRange: Distance
}

// Object oriented

extension Ship {
    func canEngageShip(_ ship: Ship) -> Bool {
        return position.minus(ship.position).length <= firingRange
    }
}

extension Ship {
    func canSafelyEngageShip(_ ship: Ship) -> Bool {
        let targetDistance = position.minus(ship.position).length
        return targetDistance <= firingRange && targetDistance > unsafeRange
    }
}

extension Ship {
    func canSafelyEngageShip(_ target: Ship, friendly: Ship) -> Bool {
        let targetDistance = position.minus(target.position).length
        let friendlyDistance = friendly.position.minus(target.position).length
        
        return targetDistance <= firingRange &&
            targetDistance > unsafeRange &&
            friendlyDistance > unsafeRange
    }
}

// Functional

typealias Region = (Position) -> Bool

func circle(_ radius: Distance) -> Region {
    return { point in point.length <= radius }
}

func shift(_ region: @escaping Region, offset: Position) -> Region {
    return { point in region(point.minus(offset)) }
}

func invert(_ region: @escaping Region) -> Region {
    return { point in !region(point) }
}

func intersection(_ region1: @escaping Region, _ region2: @escaping Region) -> Region {
    return { point in region1(point) && region2(point) }
}

func union(_ region1: @escaping Region, _ region2: @escaping Region) -> Region {
    return { point in region1(point) || region2(point) }
}

func difference(_ region: @escaping Region, minus: @escaping Region) -> Region {
    return intersection(region, invert(minus))
}

extension Ship {
    func canFunctionallyEngageShip(_ target: Ship, friendly: Ship) -> Bool {
        let rangeRegion = difference(circle(firingRange), minus: circle(unsafeRange))
        let firingRegion = shift(rangeRegion, offset: position)
        
        let friendlyRegion = shift(circle(unsafeRange), offset: friendly.position)
        let resultRegion = difference(firingRegion, minus: friendlyRegion)
        
        return resultRegion(target.position)
    }
}

