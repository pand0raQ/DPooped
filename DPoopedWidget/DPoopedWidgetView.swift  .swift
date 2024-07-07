import WidgetKit
import SwiftUI
import DPoopedShared

struct DPoopedWidgetEntryView : View {
    var entry: DPoopedWidgetTimelineEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack {
            HStack {
                if let imageData = entry.dogWalkInfo.dogImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "pawprint.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                Text(entry.dogWalkInfo.dogName)
                    .font(.headline)
            }
            
            Text("Last Walk: \(entry.dogWalkInfo.lastWalkDate, style: .relative)")
                .font(.subheadline)
            
            Text("Pooped: \(entry.dogWalkInfo.didPoop ? "Yes" : "No")")
                .font(.subheadline)
            
            if family != .systemSmall {
                HStack {
                    Button("Log Walk") {
                        LogWalkIntent().perform()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Log Relief") {
                        LogReliefIntent().perform()
                    }
                    .buttonStyle(.bordered)
                }
                
                Button("Request Walk") {
                    RequestWalkIntent().perform()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}
