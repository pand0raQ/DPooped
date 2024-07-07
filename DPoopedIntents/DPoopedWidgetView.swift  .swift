import WidgetKit
import SwiftUI
import DPoopedShared
import AppIntents

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DPoopedWidgetTimelineEntry {
        DPoopedWidgetTimelineEntry(date: Date(), dogWalkInfo: DogWalkInfo(dogName: "Buddy", dogImageData: nil, lastWalkDate: Date(), didPoop: false))
    }

    func getSnapshot(in context: Context, completion: @escaping (DPoopedWidgetTimelineEntry) -> ()) {
        let entry = DPoopedWidgetTimelineEntry(date: Date(), dogWalkInfo: DogWalkInfo(dogName: "Buddy", dogImageData: nil, lastWalkDate: Date(), didPoop: false))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DPoopedWidgetTimelineEntry>) -> ()) {
        // Implement your timeline generation logic here
        // For now, we'll just create a single entry
        let entry = DPoopedWidgetTimelineEntry(date: Date(), dogWalkInfo: DogWalkInfo(dogName: "Buddy", dogImageData: nil, lastWalkDate: Date(), didPoop: false))
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

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

struct DPoopedWidget: Widget {
    let kind: String = "DPoopedWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DPoopedWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("DPooped Widget")
        .description("Keep track of your dog's walks and bathroom habits.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct DPoopedWidget_Previews: PreviewProvider {
    static var previews: some View {
        DPoopedWidgetEntryView(entry: DPoopedWidgetTimelineEntry(date: Date(), dogWalkInfo: DogWalkInfo(dogName: "Preview Dog", dogImageData: nil, lastWalkDate: Date(), didPoop: false)))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
