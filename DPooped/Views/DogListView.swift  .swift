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
    
    private func deleteDogs(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let dogToDelete = dogs[index]
                modelContext.delete(dogToDelete)
                if let cloudKitRecordID = dogToDelete.cloudKitRecordID {
                    CloudKitService.shared.deleteDog(withRecordID: cloudKitRecordID) { result in
                        switch result {
                        case .success:
                            print("Dog deleted from CloudKit")
                        case .failure(let error):
                            print("Failed to delete dog from CloudKit: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}
struct DogRow: View {
    let dog: Dog
    
    var body: some View {
        HStack {
            if let imageData = dog.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Image(systemName: "pawprint.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            Text(dog.name)
        }
    }
}
