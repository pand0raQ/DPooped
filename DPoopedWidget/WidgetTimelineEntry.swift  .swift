import WidgetKit

public struct DogWalkInfo {
    public let dogName: String
    public let dogImageData: Data?
    public let lastWalkDate: Date
    public let didPoop: Bool
    
    public init(dogName: String, dogImageData: Data?, lastWalkDate: Date, didPoop: Bool) {
        self.dogName = dogName
        self.dogImageData = dogImageData
        self.lastWalkDate = lastWalkDate
        self.didPoop = didPoop
    }
}

struct DPoopedWidgetTimelineEntry: TimelineEntry {
    let date: Date
    let dogWalkInfo: DogWalkInfo
}

