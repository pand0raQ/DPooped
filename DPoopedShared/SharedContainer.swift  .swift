import SwiftData
import WidgetKit

@MainActor
public class SharedContainer {
    public static let shared = SharedContainer()
    
    public lazy var container: ModelContainer = {
        let schema = Schema([Dog.self, Walk.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    private init() {}
}
