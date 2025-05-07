//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatDateSwiftUI: View {
    private var style: DateStyle
    private var pattern: CometChatDatePattern?
    private var timestamp: Int?
    private var customFormat: String?
    private var dateTimeFormatter: CometChatDateTimeFormatter?
    
    public init(style: DateStyle = CometChatDate.style) {
        self.style = style
        self.pattern = .dayDate
    }
    
    public var body: some View {
        Text(getFormattedText())
            .font(Font(style.textFont))
            .foregroundColor(Color(style.textColor))
            .padding(8) // Default padding
            .background(Color(style.backgroundColor))
            .cornerRadius(style.cornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r1)
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r1)
                    .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
            )
            .multilineTextAlignment(.center)
    }
    
    private func getFormattedText() -> String {
        if let customFormat = self.customFormat, !customFormat.isEmpty {
            return customFormat
        } else if let timestamp = self.timestamp {
            switch self.pattern {
            case .time:
                return setTime(for: timestamp)
            case .dayDate:
                return setDayDate(for: timestamp)
            case .dayDateTime:
                return setDayTime(for: timestamp)
            default:
                return ""
            }
        }
        return ""
    }
    
    private func setTime(for time: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let dateTimeFormatterUtils = DateTimeFormatterUtils()
        
        if let formatter = dateTimeFormatterUtils.getFormattedDateFromClosures(timeStamp: time, dateTimeFormatter: dateTimeFormatter) {
            return formatter
        } else {
            return fetchMessagePastTime(for: date)
        }
    }
    
    private func fetchMessagePastTime(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.locale = Locale(identifier: CometChatLocalize.getLocale())
        let strDate: String = formatter.string(from: date)
        return strDate
    }
    
    private func setDayDate(for time: Int) -> String {
        let interval = TimeInterval(time)
        let date = Date(timeIntervalSince1970: interval)
        let dateTimeFormatterUtils = DateTimeFormatterUtils()
        
        if let formatter = dateTimeFormatterUtils.getFormattedDateFromClosures(timeStamp: time, dateTimeFormatter: dateTimeFormatter) {
            return formatter
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM, yyyy"
            formatter.locale = Locale(identifier: CometChatLocalize.getLocale())
            let strDate: String = formatter.string(from: date)
            return strDate
        }
    }
    
    private func setDayTime(for time: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let dateTimeFormatterUtils = DateTimeFormatterUtils()
        var secondsAgo = Int(Date().timeIntervalSince(date))
        if secondsAgo < 0 {
            secondsAgo = secondsAgo * (-1)
        }
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let twoDays = 2 * day
        let sevenDays = 7 * day
        
        if let formatter = dateTimeFormatterUtils.getFormattedDateFromClosures(timeStamp: time, dateTimeFormatter: dateTimeFormatter) {
            return formatter
        } else {
            if secondsAgo < day {
                let formatter = DateFormatter()
                formatter.dateFormat = "hh:mm a"
                formatter.locale = Locale(identifier: "en_US")
                let strDate: String = formatter.string(from: date)
                return strDate
            } else if secondsAgo < twoDays {
                let day = secondsAgo/day
                if day == 1 {
                    return "YESTERDAY".localize()
                } else {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "EEE"
                    formatter.locale = Locale(identifier: "en_US")
                    let strDate: String = formatter.string(from: date)
                    return strDate.capitalized
                }
            } else if secondsAgo < sevenDays {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE"
                formatter.locale = Locale(identifier: "en_US")
                let strDate: String = formatter.string(from: date)
                return strDate.capitalized
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                formatter.locale = Locale(identifier: "en_US")
                let strDate: String = formatter.string(from: date)
                return strDate.capitalized
            }
        }
    }
    
    public func set(timestamp: Int) -> CometChatDateSwiftUI {
        var view = self
        view.timestamp = timestamp
        return view
    }
    
    public func set(pattern: CometChatDatePattern) -> CometChatDateSwiftUI {
        var view = self
        view.pattern = pattern
        return view
    }
    
    public func setCustomPattern(customPattern: @escaping (_ timestamp: Int) -> (String?)) -> CometChatDateSwiftUI {
        var view = self
        if let timestamp = view.timestamp, let customFormat = customPattern(timestamp) {
            view.customFormat = customFormat
        }
        return view
    }
    
    public func set(dateTimeFormatter: CometChatDateTimeFormatter?) -> CometChatDateSwiftUI {
        var view = self
        view.dateTimeFormatter = dateTimeFormatter
        return view
    }
}

extension CometChatDateSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatDateSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatDateSwiftUI()
                .set(timestamp: Int(Date().timeIntervalSince1970))
                .set(pattern: .time)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Time Pattern")
            
            CometChatDateSwiftUI()
                .set(timestamp: Int(Date().timeIntervalSince1970))
                .set(pattern: .dayDate)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Day Date Pattern")
            
            CometChatDateSwiftUI()
                .set(timestamp: Int(Date().timeIntervalSince1970))
                .set(pattern: .dayDateTime)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Day Date Time Pattern")
        }
    }
}
