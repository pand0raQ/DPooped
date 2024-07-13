import CloudKit
import SwiftData
import DPoopedShared

class CloudKitService {
    static let shared = CloudKitService()
    
    private let container: CKContainer
    private let publicDatabase: CKDatabase
    private let privateDatabase: CKDatabase
    
    private init() {
        container = CKContainer(identifier: "iCloud.com.yourcompany.DPooped") // Replace with your container identifier
        publicDatabase = container.publicCloudDatabase
        privateDatabase = container.privateCloudDatabase
    }
    
    // MARK: - Dog Operations
    
    func saveDog(_ dog: Dog, completion: @escaping (Result<CKRecord.ID, Error>) -> Void) {
        let record: CKRecord
        if let recordID = dog.cloudKitRecordID.flatMap({ CKRecord.ID(recordName: $0) }) {
            record = CKRecord(recordType: "Dog", recordID: recordID)
        } else if let id = dog.id {
            record = CKRecord(recordType: "Dog", recordID: CKRecord.ID(recordName: id.uuidString))
        } else {
            completion(.failure(NSError(domain: "DPoopedErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Dog ID is missing"])))
            return
        }
        
        if let id = dog.id {
            record["id"] = id.uuidString
        }
        record["name"] = dog.name
        record["imageData"] = dog.imageData
        if let ownerID = dog.owner?.cloudKitRecordID {
            record["owner"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: ownerID), action: .none)
        }
        
        let coParentReferences = dog.coParents?.compactMap { coParent in
            coParent.cloudKitRecordID.flatMap { CKRecord.Reference(recordID: CKRecord.ID(recordName: $0), action: .none) }
        } ?? []
        if !coParentReferences.isEmpty {
            record["coParents"] = coParentReferences
        }
        
        publicDatabase.save(record) { (savedRecord, error) in
            if let error = error {
                completion(.failure(error))
            } else if let savedRecord = savedRecord {
                dog.cloudKitRecordID = savedRecord.recordID.recordName
                completion(.success(savedRecord.recordID))
            }
        }
    }
    
    func fetchDogs(completion: @escaping (Result<[Dog], Error>) -> Void) {
        let query = CKQuery(recordType: "Dog", predicate: NSPredicate(value: true))
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let records = records else {
                completion(.success([]))
                return
            }
            
            let dogs = records.compactMap { record -> Dog? in
                guard let idString = record["id"] as? String,
                      let id = UUID(uuidString: idString),
                      let name = record["name"] as? String else {
                    return nil
                }
                let dog = Dog(id: id, name: name, imageData: record["imageData"] as? Data)
                dog.cloudKitRecordID = record.recordID.recordName
                
                if let ownerReference = record["owner"] as? CKRecord.Reference {
                    dog.owner = self.fetchOrCreateUser(withRecordID: ownerReference.recordID)
                }
                
                if let coParentReferences = record["coParents"] as? [CKRecord.Reference] {
                    dog.coParents = coParentReferences.compactMap { self.fetchOrCreateUser(withRecordID: $0.recordID) }
                }
                
                return dog
            }
            
            completion(.success(dogs))
        }
    }
    
    func deleteDog(_ dog: Dog, completion: @escaping (Result<Void, Error>) -> Void) {
            guard let cloudKitRecordID = dog.cloudKitRecordID else {
                completion(.failure(NSError(domain: "DPoopedErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Dog has no CloudKit record ID"])))
                return
            }

            let recordID = CKRecord.ID(recordName: cloudKitRecordID)
            publicDatabase.delete(withRecordID: recordID) { (_, error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    func deleteAllData(completion: @escaping (Result<Void, Error>) -> Void) {
            let recordTypes = ["Dog", "Walk", "UserProfile"] // Add any other record types you have
            let dispatchGroup = DispatchGroup()
            var errors: [Error] = []

            for recordType in recordTypes {
                dispatchGroup.enter()
                let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
                let operation = CKQueryOperation(query: query)
                operation.recordMatchedBlock = { (recordID, _) in
                    self.publicDatabase.delete(withRecordID: recordID) { (_, error) in
                        if let error = error {
                            errors.append(error)
                        }
                    }
                }
                operation.queryResultBlock = { _ in
                    dispatchGroup.leave()
                }
                publicDatabase.add(operation)
            }

            dispatchGroup.notify(queue: .main) {
                if errors.isEmpty {
                    completion(.success(()))
                } else {
                    let error = NSError(domain: "CloudKitDeleteAllError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to delete all records"])
                    completion(.failure(error))
                }
            }
        }
    


    // MARK: - Walk Operations
    
    func saveWalk(_ walk: Walk, completion: @escaping (Result<CKRecord.ID, Error>) -> Void) {
        let record: CKRecord
        if let recordID = walk.cloudKitRecordID.flatMap({ CKRecord.ID(recordName: $0) }) {
            record = CKRecord(recordType: "Walk", recordID: recordID)
        } else if let id = walk.id {
            record = CKRecord(recordType: "Walk", recordID: CKRecord.ID(recordName: id.uuidString))
        } else {
            completion(.failure(NSError(domain: "DPoopedErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Walk ID is missing"])))
            return
        }
        
        if let id = walk.id {
            record["id"] = id.uuidString
        }
        record["date"] = walk.date
        record["duration"] = walk.duration
        record["hadRelief"] = walk.hadRelief
        if let dogID = walk.dog?.cloudKitRecordID {
            record["dog"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: dogID), action: .deleteSelf)
        }
        if let dogId = walk.dogId {
            record["dogId"] = dogId.uuidString
        }
        
        publicDatabase.save(record) { (savedRecord, error) in
            if let error = error {
                completion(.failure(error))
            } else if let savedRecord = savedRecord {
                walk.cloudKitRecordID = savedRecord.recordID.recordName
                completion(.success(savedRecord.recordID))
            }
        }
    }
    
    func fetchWalks(for dog: Dog, completion: @escaping (Result<[Walk], Error>) -> Void) {
        guard let dogId = dog.id else {
            completion(.failure(NSError(domain: "DPoopedErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Dog ID is missing"])))
            return
        }
        let predicate = NSPredicate(format: "dogId == %@", dogId.uuidString)
        let query = CKQuery(recordType: "Walk", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let records = records else {
                completion(.success([]))
                return
            }
            
            let walks = records.compactMap { record -> Walk? in
                guard let idString = record["id"] as? String,
                      let id = UUID(uuidString: idString),
                      let date = record["date"] as? Date,
                      let duration = record["duration"] as? TimeInterval,
                      let hadRelief = record["hadRelief"] as? Bool else {
                    return nil
                }
                let walk = Walk(id: id, date: date, duration: duration, hadRelief: hadRelief, dog: dog)
                walk.cloudKitRecordID = record.recordID.recordName
                walk.dogId = dog.id
                return walk
            }
            
            completion(.success(walks))
        }
    }

    // MARK: - User Operations
    
    func saveUser(_ user: UserProfile, completion: @escaping (Result<CKRecord.ID, Error>) -> Void) {
        let record: CKRecord
        if let recordID = user.cloudKitRecordID.flatMap({ CKRecord.ID(recordName: $0) }) {
            record = CKRecord(recordType: "UserProfile", recordID: recordID)
        } else if let id = user.id {
            record = CKRecord(recordType: "UserProfile", recordID: CKRecord.ID(recordName: id))
        } else {
            completion(.failure(NSError(domain: "DPoopedErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "User ID is missing"])))
            return
        }
        
        record["id"] = user.id
        record["name"] = user.name
        record["email"] = user.email
        
        publicDatabase.save(record) { (savedRecord, error) in
            if let error = error {
                completion(.failure(error))
            } else if let savedRecord = savedRecord {
                user.cloudKitRecordID = savedRecord.recordID.recordName
                completion(.success(savedRecord.recordID))
            }
        }
    }
    
    func fetchUsers(completion: @escaping (Result<[UserProfile], Error>) -> Void) {
        let query = CKQuery(recordType: "UserProfile", predicate: NSPredicate(value: true))
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let records = records else {
                completion(.success([]))
                return
            }
            
            let users = records.compactMap { record -> UserProfile? in
                guard let id = record["id"] as? String,
                      let name = record["name"] as? String,
                      let email = record["email"] as? String else {
                    return nil
                }
                
                let user = UserProfile(id: id, name: name, email: email)
                user.cloudKitRecordID = record.recordID.recordName
                return user
            }
            
            completion(.success(users))
        }
    }
    
    // MARK: - Subscriptions
    
    func subscribeToChanges(completion: @escaping (Error?) -> Void) {
        let dogSubscription = CKQuerySubscription(recordType: "Dog", predicate: NSPredicate(value: true), options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate])
        let walkSubscription = CKQuerySubscription(recordType: "Walk", predicate: NSPredicate(value: true), options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate])
        let userSubscription = CKQuerySubscription(recordType: "UserProfile", predicate: NSPredicate(value: true), options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate])
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        
        dogSubscription.notificationInfo = notificationInfo
        walkSubscription.notificationInfo = notificationInfo
        userSubscription.notificationInfo = notificationInfo
        
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [dogSubscription, walkSubscription, userSubscription], subscriptionIDsToDelete: [])
        operation.qualityOfService = .utility
        
        operation.modifySubscriptionsCompletionBlock = { savedSubscriptions, deletedSubscriptionIDs, error in
            completion(error)
        }
        
        privateDatabase.add(operation)
    }
    
    // MARK: - Helper Functions
    
    private func fetchOrCreateUser(withRecordID recordID: CKRecord.ID) -> UserProfile {
        // This is a placeholder implementation. In a real app, you'd want to fetch from your local database
        // and create a new user if necessary. For now, we'll just create a new user with minimal info.
        return UserProfile(id: recordID.recordName, name: "Unknown", email: "")
    }
}
