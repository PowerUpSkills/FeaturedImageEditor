import SwiftUI

struct ImageLayer: Identifiable {
    let id = UUID()
    var image: Image?
    var position: CGPoint = CGPoint(x: 600, y: 350) // Center of canvas
    var scale: CGFloat = 1.0
}

class LayerManager: ObservableObject {
    @Published var layers: [ImageLayer] = [] {
        didSet {
            print("Layers updated, count: \(layers.count)")
        }
    }
    
    func addLayer(image: Image) {
        print("Adding new layer")
        DispatchQueue.main.async {
            self.layers.append(ImageLayer(image: image))
            print("Layer added successfully")
        }
    }


    
    func moveLayer(id: UUID, newPosition: CGPoint) {
        if let index = layers.firstIndex(where: { $0.id == id }) {
            layers[index].position = newPosition
        }
    }
    
    func scaleLayer(id: UUID, scaleFactor: CGFloat) {
        if let index = layers.firstIndex(where: { $0.id == id }) {
            layers[index].scale *= scaleFactor
        }
    }
}
