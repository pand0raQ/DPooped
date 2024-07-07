import SwiftUI
import SwiftData
import DPoopedShared
import UserNotifications

@main
struct DPoopedApp: App {
    @StateObject private var authService = AuthenticationService()
    @Environment(\.scenePhase) private var scenePhase
    @State private var modelContainer: ModelContainer?
    @State private var errorMessage: String?

    var body: some Scene {
            WindowGroup {
                Group {
                    if let container = modelContainer {
                        ContentView()
                            .environmentObject(authService)
                            .modelContainer(container)
                    } else if let errorMessage = errorMessage {
                        Text("Error: \(errorMessage)")
                    } else {
                        ProgressView("Loading...")
                    }
                }
                .task {
                    do {
                        let schema = Schema([Dog.self, Walk.self, UserProfile.self])
                        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
                        self.modelContainer = container
                        SyncService.shared.setModelContext(container.mainContext)
                        setupCloudKitSubscriptions()
                        requestNotificationPermissions()
                    } catch {
                        print("Failed to create ModelContainer: \(error)")
                        if let nsError = error as NSError? {
                            print("Error domain: \(nsError.domain)")
                            print("Error code: \(nsError.code)")
                            print("Error description: \(nsError.localizedDescription)")
                            if let reason = nsError.userInfo["NSLocalizedFailureReason"] as? String {
                                print("Failure reason: \(reason)")
                            }
                        }
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
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
        guard let container = modelContainer else { return }
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
