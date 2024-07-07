import CloudKit
import SwiftData
import DPoopedShared

class CloudKitService {
    static let shared = CloudKitService()
    
    private let container: CKContainer
    private let publicDatabase: CKDatabase
    private let privateDatabase: CKDatabase
    
    private init() {
        container = CKContainer(identifier: "iCloud.com.yourcompany.DPooped")
        publicDatabase = container.publicCloudDatabase
        privateDatabase = container.privateCloudDatabase
    }
    
    // MARK: - Dog Operations
    
    func saveDog(_ dog: Dog, completion: @escaping (Result<CKRecord.ID, Error>) -> Void) {
        let record: CKRecord
        if let recordID = dog.cloudKitRecordID.flatMap({ CKRecord.ID(recordName: $0) }) {
            record = CKRecord(recordType: "Dog", recordID: recordID)
        } else {
            record = CKRecord(recordType: "Dog")
        }
        
        record["name"] = dog.name
        record["imageData"] = dog.imageData
        if let ownerID = dog.owner?.cloudKitRecordID {
            record["owner"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: ownerID), action: .none)
        }
        
        let coParentReferences = dog.coParents.compactMap { coParent in
            coParent.cloudKitRecordID.flatMap { CKRecord.Reference(recordID: CKRecord.ID(recordName: $0), action: .none) }
        }
        record["coParents"] = coParentReferences
        
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
                guard let name = record["name"] as? String else { return nil }
                let dog = Dog(name: name, imageData: record["imageData"] as? Data)
                dog.cloudKitRecordID = record.recordID.recordName
                return dog
            }
            
            completion(.success(dogs))
        }
    }
    
    func deleteDog(withRecordID recordID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let recordID = CKRecord.ID(recordName: recordID)
        publicDatabase.delete(withRecordID: recordID) { (recordID, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Walk Operations
    
    func saveWalk(_ walk: Walk, completion: @escaping (Result<CKRecord.ID, Error>) -> Void) {
        let record: CKRecord
        if let recordID = walk.cloudKitRecordID.flatMap({ CKRecord.ID(recordName: $0) }) {
            record = CKRecord(recordType: "Walk", recordID: recordID)
        } else {
            record = CKRecord(recordType: "Walk")
        }
        
        record["date"] = walk.date
        record["duration"] = walk.duration
        record["hadRelief"] = walk.hadRelief
        if let dogID = walk.dog?.cloudKitRecordID {
            record["dog"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: dogID), action: .deleteSelf)
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
        guard let dogRecordID = dog.cloudKitRecordID.flatMap({ CKRecord.ID(recordName: $0) }) else {
            completion(.failure(NSError(domain: "CloudKitService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Dog has no CloudKit record ID"])))
            return
        }
        
        let dogReference = CKRecord.Reference(recordID: dogRecordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "dog == %@", dogReference)
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
                guard let date = record["date"] as? Date,
                      let duration = record["duration"] as? TimeInterval,
                      let hadRelief = record["hadRelief"] as? Bool else {
                    return nil
                }
                let walk = Walk(date: date, duration: duration, hadRelief: hadRelief, dog: dog)
                walk.cloudKitRecordID = record.recordID.recordName
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
        } else {
            record = CKRecord(recordType: "UserProfile", recordID: CKRecord.ID(recordName: user.id))
        }
        
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
                guard let name = record["name"] as? String,
                      let email = record["email"] as? String else {
                    return nil
                }
                let user = UserProfile(id: record.recordID.recordName, name: name, email: email)
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
        
        let operations = [
            CKModifySubscriptionsOperation(subscriptionsToSave: [dogSubscription, walkSubscription, userSubscription], subscriptionIDsToDelete: nil)
        ]
        
        operations.first?.modifySubscriptionsCompletionBlock = { _, _, error in
            completion(error)
        }
        
        operations.forEach { publicDatabase.add($0) }
    }
}
