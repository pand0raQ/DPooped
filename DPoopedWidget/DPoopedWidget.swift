import WidgetKit
import SwiftUI
import DPoopedShared

@main
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
