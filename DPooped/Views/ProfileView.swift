import SwiftUI
import AuthenticationServices

struct ProfileView: View {
    @EnvironmentObject private var authService: AuthenticationService
    
    var body: some View {
        NavigationView {
            Group {
                if authService.isAuthenticated {
                    AuthenticatedProfileView()
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
    }
}

struct AuthenticatedProfileView: View {
    @EnvironmentObject private var authService: AuthenticationService
    
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
