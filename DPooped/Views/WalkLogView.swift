import SwiftUI
import DPoopedShared

struct LogWalkView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var duration: TimeInterval = 1800 // 30 minutes
    @State private var hadRelief = false
    @State private var date = Date()
    let dog: Dog
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Walk Details")) {
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    
                    Stepper(value: $duration, in: 300...7200, step: 300) {
                        Text("Duration: \(Int(duration)/60) minutes")
                    }
                    
                    Toggle("Had Relief", isOn: $hadRelief)
                }
            }
            .navigationTitle("Log Walk for \(dog.name)")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWalk()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveWalk() {
        let newWalk = Walk(date: date, duration: duration, hadRelief: hadRelief, dog: dog)
        modelContext.insert(newWalk)
        SyncService.shared.syncWalk(newWalk, for: dog)
        dismiss()
    }
}
