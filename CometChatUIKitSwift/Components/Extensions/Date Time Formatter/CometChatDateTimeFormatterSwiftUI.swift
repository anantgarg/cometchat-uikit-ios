//
//
//

import Foundation
import SwiftUI

public struct CometChatDateTimeFormatterSwiftUI {

    public var time: ((_ timestamp: Int) -> String)?
    public var today: ((_ timestamp: Int) -> String)?
    public var yesterday: ((_ timestamp: Int) -> String)?
    public var lastWeek: ((_ timestamp: Int) -> String)?
    public var otherDay: ((_ timestamp: Int) -> String)?
    
    public var minute: ((_ timestamp: Int) -> String)?
    public var minutes: ((_ timestamp: Int) -> String)?
    public var hour: ((_ timestamp: Int) -> String)?
    public var hours: ((_ timestamp: Int) -> String)?

    public init() {}
    
    public func toUIKit() -> CometChatDateTimeFormatter {
        let formatter = CometChatDateTimeFormatter()
        
        formatter.time = self.time
        formatter.today = self.today
        formatter.yesterday = self.yesterday
        formatter.lastWeek = self.lastWeek
        formatter.otherDay = self.otherDay
        formatter.minute = self.minute
        formatter.minutes = self.minutes
        formatter.hour = self.hour
        formatter.hours = self.hours
        
        return formatter
    }
    
    public static func from(uiKitFormatter: CometChatDateTimeFormatter) -> CometChatDateTimeFormatterSwiftUI {
        let formatter = CometChatDateTimeFormatterSwiftUI()
        
        formatter.time = uiKitFormatter.time
        formatter.today = uiKitFormatter.today
        formatter.yesterday = uiKitFormatter.yesterday
        formatter.lastWeek = uiKitFormatter.lastWeek
        formatter.otherDay = uiKitFormatter.otherDay
        formatter.minute = uiKitFormatter.minute
        formatter.minutes = uiKitFormatter.minutes
        formatter.hour = uiKitFormatter.hour
        formatter.hours = uiKitFormatter.hours
        
        return formatter
    }
}
