import SwiftUI
import AuthenticationServices
import DPoopedShared
import SwiftData


struct ProfileView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @Environment(\.modelContext) private var modelContext
    @State private var showingClearDataAlert = false
    @State private var showingClearDataConfirmation = false

    var body: some View {
        NavigationView {
            Group {
                if authService.isAuthenticated {
                    AuthenticatedProfileView(
                        showingClearDataAlert: $showingClearDataAlert,
                        showingClearDataConfirmation: $showingClearDataConfirmation,
                        clearAllData: clearAllData
                    )
                } else {
                    UnauthenticatedProfileView()
                }
            }
            .navigationTitle("Profile")
        }
        .alert(item: Binding<AlertItem?>(
            get: { authService.errorMessage.map { AlertItem(message: $0) } },
            set: { _ in authService.errorMessage = nil }
        )) { alertItem in
            Alert(title: Text("Error"), message: Text(alertItem.message))
        }
        .alert("Clear All Data", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                showingClearDataConfirmation = true
            }
        } message: {
            Text("Are you sure you want to clear all data? This action cannot be undone.")
        }
        .alert("Confirm Clear All Data", isPresented: $showingClearDataConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will delete all data from the app and CloudKit. Are you absolutely sure?")
        }
    }

    private func clearAllData() {
        // Clear local SwiftData
        do {
            try modelContext.delete(model: Dog.self)
            try modelContext.delete(model: Walk.self)
            try modelContext.delete(model: UserProfile.self)
            try modelContext.save()
        } catch {
            print("Failed to clear local data: \(error)")
        }

        // Clear CloudKit data
        CloudKitService.shared.deleteAllData { result in
            switch result {
            case .success:
                print("All data cleared successfully")
            case .failure(let error):
                print("Failed to clear CloudKit data: \(error)")
            }
        }
    }
}

struct AuthenticatedProfileView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @Binding var showingClearDataAlert: Bool
    @Binding var showingClearDataConfirmation: Bool
    var clearAllData: () -> Void

    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                Text("Name: \(authService.userName ?? "Not provided")")
                Text("Email: \(authService.userEmail ?? "Not provided")")
            }
            
            Section(header: Text("Account Information")) {
                Text("User ID: \(authService.userId ?? "N/A")")
            }
            
            Section {
                Button("Sign Out") {
                    authService.signOut()
                }
                .foregroundColor(.red)
            }

            Section {
                Button("Clear All Data") {
                    showingClearDataAlert = true
                }
                .foregroundColor(.red)
            }
        }
    }
}

struct UnauthenticatedProfileView: View {
    @EnvironmentObject private var authService: AuthenticationService
    
    var body: some View {
        VStack {
            Text("Please sign in to view your profile")
                .padding()
            
            SignInWithAppleButton(.signIn) { request in
                authService.signInWithApple()
            } onCompletion: { result in
                // Handle any errors here if needed
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}

extension ModelContext {
    func delete<T: PersistentModel>(model: T.Type) throws {
        let fetchDescriptor = FetchDescriptor<T>()
        let items = try fetch(fetchDescriptor)
        items.forEach { delete($0) }
    }
}
