import SwiftData
import CloudKit
import DPoopedShared


class SyncService {
    static let shared = SyncService()
    
    private let cloudKitService = CloudKitService.shared
    private var modelContext: ModelContext?
    
    private init() {}
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Dog Sync
    
    func syncDog(_ dog: Dog) {
        cloudKitService.saveDog(dog) { result in
            switch result {
            case .success(let recordID):
                print("Dog synced successfully with CloudKit ID: \(recordID.recordName)")
                dog.cloudKitRecordID = recordID.recordName
                self.saveContext()
            case .failure(let error):
                print("Failed to sync dog: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchAndSyncDogs() {
        cloudKitService.fetchDogs { result in
            switch result {
            case .success(let cloudDogs):
                self.updateLocalDogs(with: cloudDogs)
            case .failure(let error):
                print("Failed to fetch dogs from CloudKit: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateLocalDogs(with cloudDogs: [Dog]) {
        guard let context = modelContext else {
            print("Model context not set")
            return
        }
        
        do {
            let localDogs = try context.fetch(FetchDescriptor<Dog>())
            
            for cloudDog in cloudDogs {
                if let localDog = localDogs.first(where: { $0.cloudKitRecordID == cloudDog.cloudKitRecordID }) {
                    localDog.name = cloudDog.name
                    localDog.imageData = cloudDog.imageData
                } else {
                    context.insert(cloudDog)
                }
            }
            
            let cloudDogIDs = Set(cloudDogs.compactMap { $0.cloudKitRecordID })
            for localDog in localDogs {
                if let cloudKitRecordID = localDog.cloudKitRecordID, !cloudDogIDs.contains(cloudKitRecordID) {
                    context.delete(localDog)
                }
            }
            
            saveContext()
        } catch {
            print("Failed to fetch local dogs: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Walk Sync
    
    func syncWalk(_ walk: Walk, for dog: Dog) {
        cloudKitService.saveWalk(walk, for: dog) { result in
            switch result {
            case .success(let recordID):
                print("Walk synced successfully with CloudKit ID: \(recordID.recordName)")
                walk.cloudKitRecordID = recordID.recordName
                self.saveContext()
            case .failure(let error):
                print("Failed to sync walk: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchAndSyncWalks(for dog: Dog) {
        cloudKitService.fetchWalks(for: dog) { result in
            switch result {
            case .success(let cloudWalks):
                self.updateLocalWalks(with: cloudWalks, for: dog)
            case .failure(let error):
                print("Failed to fetch walks from CloudKit: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateLocalWalks(with cloudWalks: [Walk], for dog: Dog) {
        guard let context = modelContext else {
            print("Model context not set")
            return
        }
        
        do {
            let localWalks = try context.fetch(FetchDescriptor<Walk>(predicate: #Predicate { $0.dog == dog }))
            
            for cloudWalk in cloudWalks {
                if let localWalk = localWalks.first(where: { $0.cloudKitRecordID == cloudWalk.cloudKitRecordID }) {
                    localWalk.date = cloudWalk.date
                    localWalk.duration = cloudWalk.duration
                    localWalk.hadRelief = cloudWalk.hadRelief
                } else {
                    cloudWalk.dog = dog
                    context.insert(cloudWalk)
                }
            }
            
            let cloudWalkIDs = Set(cloudWalks.compactMap { $0.cloudKitRecordID })
            for localWalk in localWalks {
                if let cloudKitRecordID = localWalk.cloudKitRecordID, !cloudWalkIDs.contains(cloudKitRecordID) {
                    context.delete(localWalk)
                }
            }
            
            saveContext()
        } catch {
            print("Failed to fetch local walks: \(error.localizedDescription)")
        }
    }
    
    // MARK: - User Sync
    
    func syncUser(_ user: UserProfile) {
        cloudKitService.saveUser(user) { result in
            switch result {
            case .success(let recordID):
                print("User synced successfully with CloudKit ID: \(recordID.recordName)")
                user.cloudKitRecordID = recordID.recordName
                self.saveContext()
            case .failure(let error):
                print("Failed to sync user: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchAndSyncUsers() {
        cloudKitService.fetchUsers { result in
            switch result {
            case .success(let cloudUsers):
                self.updateLocalUsers(with: cloudUsers)
            case .failure(let error):
                print("Failed to fetch users from CloudKit: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateLocalUsers(with cloudUsers: [UserProfile]) {
        guard let context = modelContext else {
            print("Model context not set")
            return
        }
        
        do {
            let localUsers = try context.fetch(FetchDescriptor<UserProfile>())
            
            for cloudUser in cloudUsers {
                if let localUser = localUsers.first(where: { $0.cloudKitRecordID == cloudUser.cloudKitRecordID }) {
                    localUser.name = cloudUser.name
                    localUser.email = cloudUser.email
                } else {
                    context.insert(cloudUser)
                }
            }
            
            let cloudUserIDs = Set(cloudUsers.compactMap { $0.cloudKitRecordID })
            for localUser in localUsers {
                if let cloudKitRecordID = localUser.cloudKitRecordID, !cloudUserIDs.contains(cloudKitRecordID) {
                    context.delete(localUser)
                }
            }
            
            saveContext()
        } catch {
            print("Failed to fetch local users: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helpers
    
    private func saveContext() {
        do {
            try modelContext?.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
}
