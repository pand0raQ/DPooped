import WidgetKit
import SwiftUI
import SwiftData
import DPoopedShared

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DPoopedWidgetTimelineEntry {
        DPoopedWidgetTimelineEntry(date: Date(), dogWalkInfo: DogWalkInfo(dogName: "Buddy", dogImageData: nil, lastWalkDate: Date(), didPoop: false))
    }

    func getSnapshot(in context: Context, completion: @escaping (DPoopedWidgetTimelineEntry) -> ()) {
        Task {
            let entry = await fetchLatestDogWalkInfo()
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let currentDate = Date()
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
            
            let entry = await fetchLatestDogWalkInfo()
            
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
    
    private func fetchLatestDogWalkInfo() async -> DPoopedWidgetTimelineEntry {
        let container = await  SharedContainer.shared.container
        let context = ModelContext(container)
        
        do {
            let dogDescriptor = FetchDescriptor<Dog>(sortBy: [SortDescriptor(\Dog.name)])
            let dogs = try context.fetch(dogDescriptor)
            
            guard let firstDog = dogs.first else {
                return DPoopedWidgetTimelineEntry(date: Date(), dogWalkInfo: DogWalkInfo(dogName: "No Dogs", dogImageData: nil, lastWalkDate: Date(), didPoop: false))
            }
            
            var walkDescriptor = FetchDescriptor<Walk>(
                predicate: #Predicate { $0.dog == firstDog },
                sortBy: [SortDescriptor(\Walk.date, order: .reverse)]
            )
            walkDescriptor.fetchLimit = 1
            
            let latestWalks = try context.fetch(walkDescriptor)
            let latestWalk = latestWalks.first
            
            return DPoopedWidgetTimelineEntry(
                date: Date(),
                dogWalkInfo: DogWalkInfo(
                    dogName: firstDog.name,
                    dogImageData: firstDog.imageData,
                    lastWalkDate: latestWalk?.date ?? Date(),
                    didPoop: latestWalk?.hadRelief ?? false
                )
            )
        } catch {
            print("Error fetching dog data: \(error)")
            return DPoopedWidgetTimelineEntry(date: Date(), dogWalkInfo: DogWalkInfo(dogName: "Error", dogImageData: nil, lastWalkDate: Date(), didPoop: false))
        }
    }
}
