import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var layerManager = LayerManager()
    @StateObject private var effectsManager = EffectsManager()
    @State private var isImporting: Bool = false
    @State private var selectedLayerId: UUID?
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 1200, height: 700)
                
                ForEach(layerManager.layers) { layer in
                    if let image = layer.image {
                        image
                            .resizable()
                            .frame(width: layer.originalSize.width, height: layer.originalSize.height)
                            .position(layer.position)
                            .scaleEffect(layer.scale)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        layerManager.moveLayer(id: layer.id, newPosition: value.location)
                                    }
                            )
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        layerManager.scaleLayer(id: layer.id, scaleFactor: value)
                                    }
                            )
                            .onTapGesture {
                                selectedLayerId = layer.id
                            }
                    }
                }
            }
            .background(Color.black)
            
            HStack(spacing: 20) {
                Button(action: {
                    isImporting = true
                }) {
                    Text("Add Layer")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .fileImporter(
                    isPresented: $isImporting,
                    allowedContentTypes: [.image],
                    allowsMultipleSelection: false
                ) { result in
                    do {
                        guard let selectedFile = try result.get().first else {
                            print("No file selected")
                            return
                        }
                        
                        guard selectedFile.startAccessingSecurityScopedResource() else {
                            print("Cannot access file")
                            return
                        }
                        
                        defer {
                            selectedFile.stopAccessingSecurityScopedResource()
                        }
                        
                        guard let imageData = try? Data(contentsOf: selectedFile),
                              let nsImage = NSImage(data: imageData) else {
                            print("Failed to create image from data")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            let image = Image(nsImage: nsImage)
                            layerManager.addLayer(image: image, size: nsImage.size)
                        }
                    } catch {
                        print("Error importing file: \(error.localizedDescription)")
                    }
                }
                
                Button(action: {
                    handlePasteboardImage()
                }) {
                    Text("Paste from Clipboard")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            
            // Effects Controls
            VStack {
                GroupBox(label: Text("Effects")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle("CRT Effect", isOn: $effectsManager.isCRTEnabled)
                        if effectsManager.isCRTEnabled {
                            VStack(alignment: .leading) {
                                Text("Scanline Intensity")
                                Slider(value: $effectsManager.scanlineIntensity, in: 0...1)
                            }
                            .padding(.leading)
                        }
                        
                        Toggle("RGB Separation", isOn: $effectsManager.isRGBSeparationEnabled)
                        if effectsManager.isRGBSeparationEnabled {
                            VStack(alignment: .leading) {
                                Text("RGB Offset")
                                Slider(value: $effectsManager.rgbOffset, in: 0...20)
                            }
                            .padding(.leading)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    func handlePasteboardImage() {
        let pasteboard = NSPasteboard.general
        if let imageData = pasteboard.data(forType: .tiff),
           let nsImage = NSImage(data: imageData) {
            let image = Image(nsImage: nsImage)
            layerManager.addLayer(image: image, size: nsImage.size)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
