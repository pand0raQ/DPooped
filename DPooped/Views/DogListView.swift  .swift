import SwiftUI
import SwiftData
import DPoopedShared

struct DogListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dogs: [Dog]
    @State private var isAddingDog = false
    @State private var selectedDog: Dog?
    @State private var isLoggingWalk = false

    var body: some View {
        NavigationView {
            List {
                ForEach(dogs) { dog in
                    NavigationLink(destination: DogCoParentingView(dog: dog)) {
                        DogRow(dog: dog)
                    }
                    .swipeActions {
                        Button("Log Walk") {
                            selectedDog = dog
                            isLoggingWalk = true
                        }
                        .tint(.blue)
                        
                        Button("Delete") {
                            deleteDog(dog)
                        }
                        .tint(.red)
                    }
                }
                .onDelete(perform: deleteDogs)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("My Dogs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isAddingDog = true }) {
                        Label("Add Dog", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingDog) {
                AddDogView()
            }
            .sheet(isPresented: $isLoggingWalk) {
                if let dog = selectedDog {
                    LogWalkView(dog: dog)
                }
            }
        }
        .onAppear {
            SyncService.shared.fetchAndSyncDogs()
        }
    }
    
    private func deleteDog(_ dog: Dog) {
        CloudKitService.shared.deleteDog(dog) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Dog deleted from CloudKit successfully")
                    modelContext.delete(dog)
                    do {
                        try modelContext.save()
                    } catch {
                        print("Failed to delete dog from local storage: \(error)")
                    }
                case .failure(let error):
                    print("Failed to delete dog from CloudKit: \(error)")
                    // You might want to show an alert to the user here
                }
            }
        }
    }
    
    private func deleteDogs(offsets: IndexSet) {
        for index in offsets {
            let dogToDelete = dogs[index]
            deleteDog(dogToDelete)
        }
    }
}
