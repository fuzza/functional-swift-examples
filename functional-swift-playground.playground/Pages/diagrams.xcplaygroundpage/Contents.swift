//: [Previous](@previous)

import Foundation
import Cocoa
import CoreGraphics

enum Primitive {
    case Ellipse
    case Rectangle
    case Text(String)
}

indirect enum Diagram {
    case Primitive(CGSize, Primitive)
    case Beside(Diagram, Diagram)
    case Below(Diagram, Diagram)
    case Align(CGVector, Diagram)
    case Attributed(Attribute, Diagram)
}

enum Attribute {
    case FillColor(NSColor)
}

extension Diagram {
    var size: CGSize {
        switch self {
        case .Primitive(let s, _):
            return s
        case .Beside(let l, let r):
            let leftSize = l.size
            let rightSize = r.size
            return CGSize(width: leftSize.width + rightSize.width, height: max(leftSize.height,rightSize.height))
        case .Below(let t, let b):
            let topSize = t.size
            let botSize = b.size
            return CGSize(width: max(topSize.width, botSize.width), height: topSize.height + b.size.height)
        case .Align(_, let x):
            return x.size
        case .Attributed(_, let x):
            return x.size
        }
    }
}

func *(l: CGFloat, r: CGSize) -> CGSize {
    return CGSize(width: l * r.width, height: l * r.height)
}

func /(l: CGSize, r: CGSize) -> CGSize {
    return CGSize(width: l.width / r.width, height: l.height / r.height)
}

func *(l: CGSize, r: CGSize) -> CGSize {
    return CGSize(width: l.width * r.width, height: l.height * r.height)
}

func -(l: CGSize, r: CGSize) -> CGSize {
    return CGSize(width: l.width - r.width, height: l.height - r.height)
}

func -(l: CGPoint, r: CGPoint) -> CGPoint {
    return CGPoint(x: l.x - r.x, y: l.y - r.y)
}

extension CGSize {
    var point: CGPoint {
        return CGPoint(x: self.width, y: self.height)
    }
}

extension CGVector {
    var point: CGPoint {
        return CGPoint(x: dx, y: dy)
    }
    
    var size: CGSize {
        return CGSize(width: dx, height: dy)
    }
}

extension CGSize {
    func fit(_ vector: CGVector, _ rect: CGRect) -> CGRect {
        let scaleSize = rect.size / self
        let scale = min(scaleSize.width, scaleSize.height)
        
        let size = scale * self
        let space = vector.size * (size - rect.size)
        return CGRect(origin: rect.origin - space.point, size: size)
    }
}

let centerRect = CGSize(width: 1, height: 1).fit(
    CGVector(dx:0.5, dy:0.5), CGRect(x: 0, y: 0, width: 200, height: 100))

let leftRect = CGSize(width: 1, height: 1).fit(
    CGVector(dx:0, dy:0.5), CGRect(x: 0, y: 0, width: 200, height: 100))

extension CGRect {
    func split(_ ratio: CGFloat, edge:CGRectEdge) -> (CGRect, CGRect) {
        let length = edge.isHorizontal ? width : height
        return divided(atDistance: length * ratio, from: edge)
    }
}

extension CGRectEdge {
    var isHorizontal: Bool {
        return self == .maxXEdge || self == .minXEdge
    }
}

extension CGContext {
    func draw(_ diagram: Diagram, _ bounds: CGRect) {
        switch diagram {
            case .Primitive(let size, .Ellipse):
                let frame = size.fit(CGVector(dx:0.5, dy:0.5), bounds)
                self.fillEllipse(in: frame)
            case .Primitive(let size, .Rectangle):
                let frame = size.fit(CGVector(dx:0.5, dy:0.5), bounds)
                self.fill(frame)
            case .Primitive(let size, .Text(let text)):
                let frame = size.fit(CGVector(dx:0.5, dy:0.5), bounds)
                let font = NSFont.systemFont(ofSize: 12.0)
                let attributes = [NSFontAttributeName: font]
                let attributedText = NSAttributedString(string: text, attributes: attributes)
                attributedText.draw(in: frame)
            case .Attributed(.FillColor(let color), let d):
                CGContext.saveGState(self)
                color.set()
                draw(d, bounds)
                CGContext.restoreGState(self)
            case .Beside(let left, let right):
                let (lFrame, rFrame) = bounds.split(
                    left.size.width / diagram.size.width, edge: .minXEdge)
                draw(left, lFrame)
                draw(right, rFrame)
            case .Below(let top, let bot):
                let (lFrame, rFrame) = bounds.split(
                    bot.size.height, edge: .minYEdge)
                draw(bot, lFrame)
                draw(top, rFrame)
            case .Align(let vec, let d):
                let frame = d.size.fit(vec, bounds)
                draw(d, frame)
        }    }
}

class Draw: NSView {
    let diagram: Diagram
    
    init(frame frameRect: NSRect, diagram: Diagram) {
        self.diagram = diagram
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current() else { return }
        context.cgContext.draw(self.diagram, self.bounds)
    }
}

let rect = NSRect(x: 0, y: 0, width: 1000, height: 1000)
let view = Draw(frame: rect, diagram: .Primitive(CGSize(width:10, height:10), .Ellipse))


// Combinators 

func rect(width: CGFloat, height: CGFloat) -> Diagram {
    return .Primitive(CGSize(width: width, height: height), .Rectangle)
}

func circle(diameter: CGFloat) -> Diagram {
    return .Primitive(CGSize(width: diameter, height: diameter), .Ellipse)
}

func text(theText: String, width: CGFloat, height: CGFloat) -> Diagram {
    return .Primitive(CGSize(width: width, height: height), .Text(theText))
}

func square(side: CGFloat) -> Diagram {
    return rect(width:side, height:side)
}

infix operator |||
func ||| (l: Diagram, r: Diagram) -> Diagram {
    return Diagram.Beside(l, r)
}

infix operator ---
func --- (l: Diagram, r: Diagram) -> Diagram {
    return Diagram.Below(l, r)
}

extension Diagram {
    func fill(_ color: NSColor) -> Diagram {
        return .Attributed(.FillColor(color), self)
    }
    
    func alignTop() -> Diagram {
        return .Align(CGVector(dx: 0.5, dy: 1), self)
    }
    
    func alignBottom() -> Diagram {
        return .Align(CGVector(dx: 0.5, dy: 0), self)
    }
}

let empty: Diagram = rect(width:0, height:0)

func hcat(diagrams: [Diagram]) -> Diagram {
    return diagrams.reduce(empty, |||)
}

// Example

extension Array where Element == CGFloat {
    func normalize() -> [Element] {
        let max: CGFloat = self.reduce(0, { i, x in return i < x ? x : i })
        return self.map { $0 / max }
    }
}

func barGraph(input: [(String, Double)]) -> Diagram {
    let values: [CGFloat] = input.map { CGFloat($0.1) }
    let hValues = values.normalize()
    let bars = hcat(diagrams: hValues.map { (x: CGFloat) -> Diagram in
        return rect(width: 1, height: 3 * x).fill(.black).alignBottom()
        
    })
    
    let labels = hcat(diagrams: input.map { x in
        return text(theText: x.0, width: 1, height: 0.3).alignTop() })
    return bars --- labels }

let cities = ["Shanghai": 14.01, "Istanbul": 13.3, "Moscow": 10.56, "New York": 8.33, "Berlin": 3.43]
let example3 = barGraph(input: Array(cities))

let view2 = Draw(frame: rect, diagram: example3)


//: [Next](@next)