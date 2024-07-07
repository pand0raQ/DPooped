import Foundation
import SwiftData

@Model
public final class UserProfile {
    @Attribute(.unique) public var id: String
    public var name: String
    public var email: String
    @Relationship(deleteRule: .nullify) public var ownedDogs: [Dog]
    @Relationship(deleteRule: .nullify) public var coParentedDogs: [Dog]
    public var cloudKitRecordID: String?
    
    public init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
        self.ownedDogs = []
        self.coParentedDogs = []
        self.cloudKitRecordID = nil
    }
    
    public var owner: Dog? {
        ownedDogs.first
    }
    
    public var coParents: [Dog] {
        coParentedDogs
    }
    
    public func fetchOwnedDogs(context: ModelContext) -> [Dog] {
        do {
            let descriptor = FetchDescriptor<Dog>(predicate: #Predicate { $0.owner?.id == self.id })
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching owned dogs: \(error)")
            return []
        }
    }
    
    public func fetchCoParentedDogs(context: ModelContext) -> [Dog] {
        do {
            let descriptor = FetchDescriptor<Dog>(predicate: #Predicate { $0.coParents.contains { $0.id == self.id } })
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching co-parented dogs: \(error)")
            return []
        }
    }
}
