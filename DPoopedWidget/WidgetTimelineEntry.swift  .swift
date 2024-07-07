import WidgetKit

struct DogWalkInfo: Codable {
    let dogName: String
    let dogImageData: Data?
    let lastWalkDate: Date
    let didPoop: Bool
}

struct DPoopedWidgetTimelineEntry: TimelineEntry {
    let date: Date
    let dogWalkInfo: DogWalkInfo
}

