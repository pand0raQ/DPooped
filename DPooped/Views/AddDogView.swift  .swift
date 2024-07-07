import SwiftUI
import PhotosUI
import DPoopedShared
import Foundation

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let error: String
    let guidance: String
    
    init(_ error: Error, guidance: String) {
        self.error = error.localizedDescription
        self.guidance = guidance
    }
}

struct AddDogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var croppedImage: UIImage?
    @State private var showingImageEditor = false
    @State private var errorWrapper: ErrorWrapper?
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Dog Name", text: $name)
                
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    if let croppedImage {
                        Image(uiImage: croppedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Text("Select a photo")
                    }
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                let resizedImage = resizeImage(uiImage, targetSize: CGSize(width: 1000, height: 1000))
                                selectedImageData = resizedImage.pngData()
                                showingImageEditor = true
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add New Dog")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        addDog()
                    }
                    .disabled(name.isEmpty || croppedImage == nil)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingImageEditor) {
            if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                ImageCropperView(image: uiImage) { croppedImage in
                    self.croppedImage = croppedImage
                    self.selectedImageData = croppedImage.pngData()
                    showingImageEditor = false
                }
            }
        }
        .alert(item: $errorWrapper) { wrapper in
            Alert(title: Text("Error"), message: Text(wrapper.error), dismissButton: .default(Text("OK")))
        }
    }
    
    private func addDog() {
        withAnimation {
            let newDog = Dog(name: name, imageData: selectedImageData)
            modelContext.insert(newDog)
            SyncService.shared.syncDog(newDog)
        }
        dismiss()
    }
    
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? image
    }
}


