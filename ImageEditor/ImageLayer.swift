import SwiftUI

struct ImageLayer: Identifiable {
    let id = UUID()
    var image: Image?
    var position: CGPoint = CGPoint(x: 600, y: 350)
    var scale: CGFloat = 1.0
    var originalSize: CGSize = CGSize(width: 0, height: 0)
}

class LayerManager: ObservableObject {
    @Published var layers: [ImageLayer] = []
    
    func addLayer(image: Image, size: CGSize) {
        DispatchQueue.main.async {
            var layer = ImageLayer(image: image)
            layer.originalSize = size
            self.layers.append(layer)
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
