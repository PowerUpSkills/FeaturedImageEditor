import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import AppKit

class EffectsManager: ObservableObject {
    @Published var isCRTEnabled = false
    @Published var isRGBSeparationEnabled = false
    @Published var scanlineIntensity: Double = 0.5
    @Published var rgbOffset: Double = 5.0
    
    let context = CIContext()
    
    func applyCRTEffect(to image: NSImage) -> NSImage? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil),
              let filter = CIFilter(name: "CIStripesGenerator") else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        filter.setValue(scanlineIntensity, forKey: kCIInputWidthKey)
        
        guard let stripesImage = filter.outputImage,
              let blendFilter = CIFilter(name: "CIMultiplyBlendMode") else { return nil }
        
        blendFilter.setValue(ciImage, forKey: kCIInputBackgroundImageKey)
        blendFilter.setValue(stripesImage, forKey: kCIInputImageKey)
        
        guard let outputImage = blendFilter.outputImage,
              let cgOutput = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return NSImage(cgImage: cgOutput, size: outputImage.extent.size)
    }
    
    func applyRGBSeparation(to image: NSImage) -> NSImage? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        let redShift = CIVector(x: rgbOffset, y: 0)
        let greenShift = CIVector(x: 0, y: rgbOffset)
        let blueShift = CIVector(x: -rgbOffset, y: -rgbOffset)
        
        guard let rgbFilter = CIFilter(name: "CIColorMatrix") else { return nil }
        rgbFilter.setValue(ciImage, forKey: kCIInputImageKey)
        rgbFilter.setValue(redShift, forKey: "inputRVector")
        rgbFilter.setValue(greenShift, forKey: "inputGVector")
        rgbFilter.setValue(blueShift, forKey: "inputBVector")
        
        guard let outputImage = rgbFilter.outputImage,
              let cgOutput = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return NSImage(cgImage: cgOutput, size: outputImage.extent.size)
    }
}
