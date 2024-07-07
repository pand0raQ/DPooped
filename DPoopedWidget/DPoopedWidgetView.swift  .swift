import WidgetKit
import SwiftUI
import DPoopedShared
import AppIntents

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
                    Link("Log Walk", destination: URL(string: "dpooped://logwalk")!)
                        .buttonStyle(.bordered)
                    
                    Link("Log Relief", destination: URL(string: "dpooped://logrelief")!)
                        .buttonStyle(.bordered)
                }
                
                Link("Request Walk", destination: URL(string: "dpooped://requestwalk")!)
                    .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}


