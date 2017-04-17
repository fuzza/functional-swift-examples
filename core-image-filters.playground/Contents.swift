//: Playground - noun: a place where people can play

import UIKit
import CoreImage

typealias Filter = (CIImage) -> CIImage

func blur(_ radius: Double) -> Filter {
    return { image in
        let parameters: [String : Any] = [
            kCIInputRadiusKey : radius,
            kCIInputImageKey : image
        ]
        
        guard let filter = CIFilter(name: "CIGaussianBlur", withInputParameters: parameters) else {
            fatalError()
        }
        
        guard let outputImage = filter.outputImage else {
            fatalError()
        }
        
        let cropRect = outputImage.extent
        return outputImage.cropping(to: cropRect)
    }
}

func colorGenerator(_ color: UIColor) -> Filter {
    return { image in
        let c = CIColor(color: color)
        let parameters = [kCIInputColorKey : c]
        
        guard let filter = CIFilter(name: "CIConstantColorGenerator", withInputParameters: parameters) else {
            fatalError()
        }
        
        guard let outputImage = filter.outputImage else {
            fatalError()
        }
        
        return outputImage.cropping(to: image.extent)
    }
}

func compositeSourceOver(_ overlay: CIImage) -> Filter {
    return { image in
        let parameters = [
            kCIInputBackgroundImageKey : image,
            kCIInputImageKey : overlay
        ]
        
        guard let filter = CIFilter(name: "CISourceOverCompositing", withInputParameters: parameters) else {
            fatalError()
        }
        
        guard let outputImage = filter.outputImage else {
            fatalError()
        }
        
        let cropRect = outputImage.extent
        return outputImage.cropping(to: cropRect)
    }
}

func colorOverlay(_ color: UIColor) -> Filter {
    return { image in
        let overlay = colorGenerator(color)(image)
        return compositeSourceOver(overlay)(image)
    }
}

precedencegroup CombiningPrecedence {
    associativity : left
}

infix operator >>> : CombiningPrecedence
func >>> (_ filter1: @escaping Filter, _ filter2: @escaping Filter) -> Filter {
    return { image in
        filter1(filter2(image))
    }
}

let url = URL(string: "https://d3nevzfk7ii3be.cloudfront.net/igi/DX2OGI5fYDA3jOZ5.medium")!

let image = CIImage(contentsOf: url)!

let blurRadius = 5.0
let color = UIColor.red.withAlphaComponent(0.2)

let filter = blur(blurRadius) >>> colorOverlay(color)
let overlaidImage = filter(image)










