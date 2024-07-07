import Foundation
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

public struct DPoopedWidgetTimelineEntry: TimelineEntry {
    public let date: Date
    public let dogWalkInfo: DogWalkInfo
    
    public init(date: Date, dogWalkInfo: DogWalkInfo) {
        self.date = date
        self.dogWalkInfo = dogWalkInfo
    }
}
