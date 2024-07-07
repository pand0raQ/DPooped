import Foundation
import SwiftData

@Model
public final class Dog {
    @Attribute(.unique) public var id: UUID?
    public var name: String?
    public var imageData: Data?
    @Relationship(inverse: \UserProfile.ownedDogs) public var owner: UserProfile?
    @Relationship(inverse: \UserProfile.coParentedDogs) public var coParents: [UserProfile]?
    @Relationship(inverse: \Walk.dog) public var walks: [Walk]?
    public var cloudKitRecordID: String?
    
    public init(id: UUID = UUID(), name: String, imageData: Data? = nil) {
        self.id = id
        self.name = name
        self.imageData = imageData
        self.coParents = []
        self.walks = []
        self.cloudKitRecordID = nil
    }
}

extension Dog {
    public var lastWalk: Walk? {
        walks?.sorted { $0.date ?? Date.distantPast > $1.date ?? Date.distantPast }.first
    }
    
    public var lastWalkDate: Date? {
        lastWalk?.date
    }
    
    public var lastWalkHadRelief: Bool {
        lastWalk?.hadRelief ?? false
    }
}
