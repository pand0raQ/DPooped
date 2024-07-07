import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var authService = AuthenticationService()
    
    var body: some View {
        TabView {
            if authService.isAuthenticated {
                ProfileView()
                    .environmentObject(authService)
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                
                DogListView()
                    .tabItem {
                        Label("My Dogs", systemImage: "pawprint")
                    }
                
                Text("Walks")
                    .tabItem {
                        Label("Walks", systemImage: "figure.walk")
                    }
            } else {
                ProfileView()
                    .environmentObject(authService)
                    .tabItem {
                        Label("Sign In", systemImage: "person")
                    }
            }
        }
    }
}
