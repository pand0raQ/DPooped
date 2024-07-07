import AppIntents
import SwiftData
import DPoopedShared

public struct LogWalkIntent: AppIntent {
    public static var title: LocalizedStringResource = "Log Walk"
    
    public init() {}
    
    public func perform() async throws -> some IntentResult {
        let userDefaults = UserDefaults(suiteName: "group.com.yourcompany.DPooped")
        userDefaults?.set(true, forKey: "needsWalkSync")
        userDefaults?.set(Date().timeIntervalSince1970, forKey: "lastWalkDate")
        userDefaults?.set(1800, forKey: "lastWalkDuration")
        userDefaults?.set(false, forKey: "lastWalkHadRelief")
        return .result()
    }
}

public struct LogReliefIntent: AppIntent {
    public static var title: LocalizedStringResource = "Log Relief"
    
    public init() {}
    
    public func perform() async throws -> some IntentResult {
        let userDefaults = UserDefaults(suiteName: "group.com.yourcompany.DPooped")
        userDefaults?.set(true, forKey: "needsWalkSync")
        userDefaults?.set(Date().timeIntervalSince1970, forKey: "lastWalkDate")
        userDefaults?.set(300, forKey: "lastWalkDuration")
        userDefaults?.set(true, forKey: "lastWalkHadRelief")
        return .result()
    }
}

public struct RequestWalkIntent: AppIntent {
    public static var title: LocalizedStringResource = "Request Walk"
    
    public init() {}
    
    public func perform() async throws -> some IntentResult {
        let userDefaults = UserDefaults(suiteName: "group.com.yourcompany.DPooped")
        userDefaults?.set(true, forKey: "walkRequested")
        return .result()
    }
}
