import AppIntents
import SwiftData
import DPoopedShared

struct LogWalkIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Walk"
    
    func perform() async throws -> some IntentResult {
        let userDefaults = UserDefaults(suiteName: "group.com.yourcompany.DPooped")
        userDefaults?.set(true, forKey: "needsWalkSync")
        userDefaults?.set(Date().timeIntervalSince1970, forKey: "lastWalkDate")
        userDefaults?.set(1800, forKey: "lastWalkDuration")
        userDefaults?.set(false, forKey: "lastWalkHadRelief")
        return .result()
    }
}

struct LogReliefIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Relief"
    
    func perform() async throws -> some IntentResult {
        let userDefaults = UserDefaults(suiteName: "group.com.yourcompany.DPooped")
        userDefaults?.set(true, forKey: "needsWalkSync")
        userDefaults?.set(Date().timeIntervalSince1970, forKey: "lastWalkDate")
        userDefaults?.set(300, forKey: "lastWalkDuration")
        userDefaults?.set(true, forKey: "lastWalkHadRelief")
        return .result()
    }
}

struct RequestWalkIntent: AppIntent {
    static var title: LocalizedStringResource = "Request Walk"
    
    func perform() async throws -> some IntentResult {
        let userDefaults = UserDefaults(suiteName: "group.com.yourcompany.DPooped")
        userDefaults?.set(true, forKey: "walkRequested")
        return .result()
    }
}
