import SwiftUI

struct ImageLayer: Identifiable {
    let id = UUID()
    var image: Image?
    var position: CGPoint = CGPoint(x: 600, y: 350)
    var scale: CGFloat = 1.0
    var originalSize: CGSize = CGSize(width: 0, height: 0)
    var isSelected: Bool = false
}

class LayerManager: ObservableObject {
    @Published var layers: [ImageLayer] = []
    @Published var selectedLayerId: UUID?
    
    func addLayer(image: Image, size: CGSize) {
        DispatchQueue.main.async {
            var layer = ImageLayer(image: image)
            layer.originalSize = size
            self.layers.append(layer)
            self.selectedLayerId = layer.id
        }
    }
    
    func moveLayer(id: UUID, newPosition: CGPoint) {
        if let index = layers.firstIndex(where: { $0.id == id }) {
            layers[index].position = newPosition
        }
    }
    
    func scaleLayer(id: UUID, scaleFactor: CGFloat) {
        if let index = layers.firstIndex(where: { $0.id == id }) {
            // Ensure scale doesn't go below 0.1 or above 5.0
            let newScale = layers[index].scale * scaleFactor
            layers[index].scale = min(max(newScale, 0.1), 5.0)
        }
    }
    
    func selectLayer(id: UUID) {
        selectedLayerId = id
    }
}

