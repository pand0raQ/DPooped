import Foundation
import SwiftData

@Model
public final class Walk {
    public var id: UUID?
    public var date: Date?
    public var duration: TimeInterval?
    public var hadRelief: Bool?
    @Relationship public var dog: Dog?
    public var cloudKitRecordID: String?
    public var dogId: UUID?
        
    public init(id: UUID? = UUID(), date: Date? = Date(), duration: TimeInterval? = 0, hadRelief: Bool? = false, dog: Dog? = nil) {
        self.id = id
        self.date = date
        self.duration = duration
        self.hadRelief = hadRelief
        self.dog = dog
        self.cloudKitRecordID = nil
        self.dogId = dog?.id
    }
}

extension Walk {
    public var formattedDuration: String {
        guard let duration = duration else { return "N/A" }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "N/A"
    }
    
    public var formattedDate: String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

extension Walk: Comparable {
    public static func < (lhs: Walk, rhs: Walk) -> Bool {
        guard let lhsDate = lhs.date, let rhsDate = rhs.date else {
            return false
        }
        return lhsDate < rhsDate
    }
}
