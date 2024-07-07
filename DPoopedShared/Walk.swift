import Foundation
import SwiftData

@Model
public final class Walk {
    @Attribute(.unique) public var id: UUID
    public var date: Date
    public var duration: TimeInterval
    public var hadRelief: Bool
    @Relationship(deleteRule: .nullify) public var dog: Dog?
    public var cloudKitRecordID: String?
    
    public init(id: UUID = UUID(), date: Date, duration: TimeInterval, hadRelief: Bool, dog: Dog? = nil) {
        self.id = id
        self.date = date
        self.duration = duration
        self.hadRelief = hadRelief
        self.dog = dog
        self.cloudKitRecordID = nil
    }
}
