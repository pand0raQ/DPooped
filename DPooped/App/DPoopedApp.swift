import SwiftUI
import SwiftData
import DPoopedShared
import UserNotifications

@main
struct DPoopedApp: App {
    let container: ModelContainer
    @StateObject private var authService = AuthenticationService()
    @Environment(\.scenePhase) private var scenePhase

    
    init() {
        do {
            container = try ModelContainer(for: Dog.self, Walk.self, UserProfile.self)
            SyncService.shared.setModelContext(container.mainContext)
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
        
        setupCloudKitSubscriptions()
        requestNotificationPermissions()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { _, newPhase in
                  if newPhase == .active {
                syncData()
            }
        }
    }
    
    private func setupCloudKitSubscriptions() {
        CloudKitService.shared.subscribeToChanges { error in
            if let error = error {
                print("Failed to set up CloudKit subscriptions: \(error.localizedDescription)")
            } else {
                print("CloudKit subscriptions set up successfully")
            }
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permissions granted")
            } else if let error = error {
                print("Failed to request notification permissions: \(error.localizedDescription)")
            }
        }
    }
    
    private func syncData() {
        SyncService.shared.fetchAndSyncDogs()
        SyncService.shared.fetchAndSyncUsers()
        
        // Fetch and sync walks for all dogs
        do {
            let dogs = try container.mainContext.fetch(FetchDescriptor<Dog>())
            for dog in dogs {
                SyncService.shared.fetchAndSyncWalks(for: dog)
            }
        } catch {
            print("Failed to fetch dogs for walk sync: \(error.localizedDescription)")
        }
    }
}
