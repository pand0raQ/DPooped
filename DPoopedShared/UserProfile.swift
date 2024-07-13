import Foundation
import SwiftData

@Model
public final class UserProfile {
    public var id: String?
    public var name: String?
    public var email: String?
    @Relationship(deleteRule: .nullify) public var ownedDogs: [Dog]?
    @Relationship(deleteRule: .nullify) public var coParentedDogs: [Dog]?
    public var cloudKitRecordID: String?
    
    public init(id: String? = UUID().uuidString, name: String? = nil, email: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.ownedDogs = []
        self.coParentedDogs = []
        self.cloudKitRecordID = nil
    }
}

extension UserProfile {
    public var owner: Dog? {
        ownedDogs?.first
    }
    
    public var coParents: [Dog] {
        coParentedDogs ?? []
    }
    
    public func fetchOwnedDogs(context: ModelContext) -> [Dog] {
        return ownedDogs ?? []
    }
    
    public func fetchCoParentedDogs(context: ModelContext) -> [Dog] {
        return coParentedDogs ?? []
    }
}
