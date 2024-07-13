import SwiftUI
import DPoopedShared

struct DogRow: View {
    let dog: Dog
    
    var body: some View {
        HStack {
            if let imageData = dog.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Image(systemName: "pawprint.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading) {
                Text(dog.name ?? "Unnamed Dog")
                    .font(.headline)
                if let lastWalk = dog.lastWalk {
                    Text("Last walk: \(lastWalk.date?.formatted() ?? "Unknown")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
