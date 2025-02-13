import SwiftUI
import SwiftData
import DPoopedShared

struct DogCoParentingView: View {
    @Bindable var dog: Dog
    @Environment(\.modelContext) private var modelContext
    @State private var isAddingCoParent = false
    @State private var newCoParentEmail = ""
    
    var body: some View {
        List {
            Section(header: Text("Owner")) {
                if let owner = dog.owner {
                    UserRow(user: owner)
                } else {
                    Text("No owner set")
                }
            }
            
            Section(header: Text("Co-Parents")) {
                ForEach(dog.coParents, id: \.id) { coParent in
                    UserRow(user: coParent)
                }
                .onDelete(perform: removeCoParents)
                
                Button(action: { isAddingCoParent = true }) {
                    Label("Add Co-Parent", systemImage: "person.badge.plus")
                }
            }
        }
        .navigationTitle("Co-Parenting: \(dog.name)")
        .sheet(isPresented: $isAddingCoParent) {
            AddCoParentView(dog: dog, isPresented: $isAddingCoParent)
        }
    }
    
    private func removeCoParents(at offsets: IndexSet) {
        dog.coParents.remove(atOffsets: offsets)
    }
}

struct UserRow: View {
    let user: UserProfile
    
    var body: some View {
        HStack {
            Text(user.name)
            Spacer()
            Text(user.email)
                .foregroundColor(.secondary)
        }
    }
}

struct AddCoParentView: View {
    @Bindable var dog: Dog
    @Binding var isPresented: Bool
    @State private var email = ""
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Co-Parent's Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
            }
            .navigationTitle("Add Co-Parent")
            .navigationBarItems(
                leading: Button("Cancel") { isPresented = false },
                trailing: Button("Add") {
                    addCoParent()
                    isPresented = false
                }
                .disabled(email.isEmpty)
            )
        }
    }
    
    private func addCoParent() {
        // In a real app, you'd want to verify this email and send an invitation
        let newCoParent = UserProfile(id: UUID().uuidString, name: "New Co-Parent", email: email)
        dog.coParents.append(newCoParent)
    }
}
