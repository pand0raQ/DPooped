import SwiftUI

struct ImageCropperView: View {
    let image: UIImage
    let onCropped: (UIImage) -> Void
    
    @State private var scale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) * 0.9
            
            VStack {
                Spacer()
                
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size, height: size)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = value.translation
                                    print("Image dragged. New offset: \(offset)")
                                }
                                .onEnded { _ in
                                    withAnimation {
                                        offset = limitOffset(offset, in: geometry.size)
                                    }
                                    print("Drag ended. Final offset: \(offset)")
                                }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = value
                                    print("Image scaled. New scale: \(scale)")
                                }
                                .onEnded { _ in
                                    withAnimation {
                                        scale = min(max(scale, 1), 3)
                                    }
                                    print("Scale ended. Final scale: \(scale)")
                                }
                        )
                        .clipShape(Circle())
                    
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 2)
                        .frame(width: size, height: size)
                }
                
                Spacer()
                
                HStack {
                    Button("Cancel") {
                        print("Cancel button tapped")
                        dismiss()
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    Button("Crop") {
                        print("Crop button tapped")
                        let renderer = ImageRenderer(content:
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(scale)
                                .offset(offset)
                                .frame(width: size, height: size)
                                .clipShape(Circle())
                        )
                        renderer.proposedSize = ProposedViewSize(width: size, height: size)
                        if let uiImage = renderer.uiImage {
                            print("Image successfully cropped. Cropped image size: \(uiImage.size)")
                            onCropped(uiImage)
                        } else {
                            print("Failed to crop image")
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
        .onAppear {
            print("ImageCropperView appeared")
            print("Original image size: \(image.size)")
        }
    }
    
    private func limitOffset(_ offset: CGSize, in size: CGSize) -> CGSize {
        let maxOffset = (size.width / 2) * (scale - 1)
        return CGSize(
            width: min(max(offset.width, -maxOffset), maxOffset),
            height: min(max(offset.height, -maxOffset), maxOffset)
        )
    }
}
