/*
Abstract:
The Entry content for a volume.
*/

import SwiftUI
import RealityKit
import AVFoundation
import CoreImage

struct FrameView: View {
    var image: CGImage?
    var texture: MaterialParameters.Texture?
    private let label = Text("frame")
    
    var body: some View {
        RealityView { content, attachments in
            
            let material = PhysicallyBasedMaterial()
            let videoSphereMesh = MeshResource.generatePlane(width: 0.1, depth: 0.1)
            var videoSphere = ModelEntity(mesh: videoSphereMesh, materials: [material])
            videoSphere.components.set(GroundingShadowComponent(castsShadow: true))
            videoSphere.name = "video_sphere"
            videoSphere.orientation = simd_quatf(angle: 1.5708, axis: simd_float3(1,0,0))
            videoSphere.position = simd_float3(0, 0, 0.01)
            content.add(videoSphere)
//            if let video = attachments.entity(for: "video") {
//                content.add(video)
//            }
        } update: { content, attachments in
            let sphere = content.entities.first(where: { entity in
                return entity.name == "video_sphere"
            }) as! ModelEntity
            var material = PhysicallyBasedMaterial()
            
            material.baseColor = .init(texture: texture)
            sphere.model?.materials = [material]
        } attachments: {
            Attachment(id: "video") {
                if let image = image {
                    Image(image, scale: 1.0, orientation: .up, label: label)
                } else {
                    Color.black
                }
            }
        }
    }
}

/// The cube content for a volume.
struct Entry: View {
    @Environment(ViewModel.self) private var model
    @ObservedObject var eventHandler = EventHandler.shared

    var body: some View {
        VStack {
            Text("ALVR")
                .font(.system(size: 50, weight: .bold))
            
            FrameView(image: eventHandler.frame, texture: eventHandler.texture)
            .fixedSize()
            .frame(width: 300, height: 300)
            
            if eventHandler.hostname != "" && eventHandler.IP != "" {
                let columns = [
                    GridItem(.fixed(100), alignment: .trailing),
                    GridItem(.fixed(150), alignment: .leading)
                ]

                LazyVGrid(columns: columns) {
                    Text("hostname:")
                    Text(eventHandler.hostname)
                    Text("IP:")
                    Text(eventHandler.IP)
                }
                .frame(width: 250, alignment: .center)
            }
        }
        .frame(minWidth: 350, minHeight: 500)
        .glassBackgroundEffect()
        
        EntryControls()
    }
}

#Preview {
    Entry()
        .environment(ViewModel())
}
