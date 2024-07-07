//
//  DPoopedWidgetLiveActivity.swift
//  DPoopedWidget
//
//  Created by Halik on 06.07.2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DPoopedWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct DPoopedWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DPoopedWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension DPoopedWidgetAttributes {
    fileprivate static var preview: DPoopedWidgetAttributes {
        DPoopedWidgetAttributes(name: "World")
    }
}

extension DPoopedWidgetAttributes.ContentState {
    fileprivate static var smiley: DPoopedWidgetAttributes.ContentState {
        DPoopedWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: DPoopedWidgetAttributes.ContentState {
         DPoopedWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: DPoopedWidgetAttributes.preview) {
   DPoopedWidgetLiveActivity()
} contentStates: {
    DPoopedWidgetAttributes.ContentState.smiley
    DPoopedWidgetAttributes.ContentState.starEyes
}
