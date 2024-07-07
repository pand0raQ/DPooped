import Foundation
import SwiftData

@Model
public final class Dog {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var imageData: Data?
    @Relationship(deleteRule: .nullify, inverse: \UserProfile.ownedDogs) public var owner: UserProfile?
    @Relationship(deleteRule: .nullify, inverse: \UserProfile.coParentedDogs) public var coParents: [UserProfile]
    @Relationship(deleteRule: .cascade, inverse: \Walk.dog) public var walks: [Walk]
    public var cloudKitRecordID: String?
    
    public init(id: UUID = UUID(), name: String, imageData: Data? = nil, owner: UserProfile? = nil) {
        self.id = id
        self.name = name
        self.imageData = imageData
        self.owner = owner
        self.coParents = []
        self.walks = []
        self.cloudKitRecordID = nil
    }
}
