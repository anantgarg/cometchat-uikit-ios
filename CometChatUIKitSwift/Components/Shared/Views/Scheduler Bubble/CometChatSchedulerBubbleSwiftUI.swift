//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatSchedulerBubbleSwiftUI: View {
    
    private var style = SchedulerBubbleStyle()
    @State private var message: SchedulerMessage?
    @State private var controller: UIViewController?
    @State private var unavailableTimeRange: [String: [TimeRange]]?
    @State private var viewStack: [AnyView] = []
    @State private var onScheduleClick: ((_ dateTime: String?, _ message: SchedulerMessage) -> Void)?
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            if let message = message {
                if viewStack.isEmpty {
                    if message.interactions == nil || message.interactions?.isEmpty == true {
                        suggestionTimeView()
                    } else {
                        interactedView()
                    }
                } else if let lastView = viewStack.last {
                    lastView
                }
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width - 40)
        .background(Color(style.background))
        .cornerRadius(style.cornerRadius.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius.cornerRadius)
                .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
        )
        .disabled(message != nil && !message!.allowSenderInteraction && LoggedInUserInformation.isLoggedInUser(uid: message!.senderUid))
    }
    
    private func suggestionTimeView() -> some View {
        SuggestionTimeViewSwiftUI(
            controller: controller,
            style: style,
            message: message,
            onMoreTimeButtonClicked: {
                pushView(calendarView())
            },
            onTimeSelected: { timeSlot, date in
                pushView(confirmationView(timeSlot: timeSlot, date: date))
            },
            onUnavailableTimeRangeDownloaded: { range in
                unavailableTimeRange = range
            }
        )
    }
    
    private func interactedView() -> some View {
        InteractedViewSwiftUI(
            titleText: message?.title,
            subtitleText: "Meeting Scheduler",
            bodyText: message?.goalCompletionText != "" ? message?.goalCompletionText : "MEETING_SCHEDULED".localize()
        )
    }
    
    private func calendarView() -> some View {
        CalendarViewSwiftUI(
            controller: controller,
            style: style,
            message: message,
            onBackButtonClicked: {
                popView()
            },
            onDateSelected: { date in
                pushView(timeSlotView(date: date))
            }
        )
    }
    
    private func timeSlotView(date: Date) -> some View {
        TimeSlotViewSwiftUI(
            controller: controller,
            style: style,
            message: message,
            date: date,
            unavailableTimeRange: unavailableTimeRange,
            onBackButtonClicked: {
                popView()
            },
            onTimeSelected: { timeSlot, date in
                pushView(confirmationView(timeSlot: timeSlot, date: date))
            }
        )
    }
    
    private func confirmationView(timeSlot: TimeRange, date: Date) -> some View {
        ConfirmationViewSwiftUI(
            controller: controller,
            style: style,
            message: message,
            date: date,
            timeSlot: timeSlot,
            onBackButtonClicked: {
                popView()
            },
            onTryAgainClicked: {
                viewStack = []
            },
            onScheduleButtonClicked: { onFailure in
                scheduleButtonClicked(timeSlot: timeSlot, date: date, onFailure: onFailure)
            }
        )
    }
    
    private func pushView<V: View>(_ view: V) {
        viewStack.append(AnyView(view))
    }
    
    private func popView() {
        if !viewStack.isEmpty {
            viewStack.removeLast()
        }
    }
    
    private func scheduleButtonClicked(timeSlot: TimeRange, date: Date, onFailure: @escaping (() -> Void)) {
        guard let message = message else { return }
        
        if let onScheduleClick = onScheduleClick {
            onScheduleClick(getFinalDate(date: date, time: timeSlot.startTime), message)
        } else {
            let scheduledPayload: [String: Any] = [
                InteractiveConstants.DURATION: message.duration,
                InteractiveConstants.MEET_STARTED_AT: (getFinalDate(date: date, time: timeSlot.startTime) ?? ""),
            ]
            
            ActionElementUtils.performAction(
                message: message,
                buttonElement: message.scheduleElement,
                payload: [InteractiveConstants.ButtonUIConstants.SCHEDULER_DATA: scheduledPayload]
            ) { success in
                if success {
                    DispatchQueue.main.async {
                        viewStack = []
                    }
                    CometChat.markAsInteracted(
                        messageId: message.id,
                        interactedElementId: message.scheduleElement?.elementId ?? ""
                    ) { _ in } onError: { _ in }
                } else {
                    DispatchQueue.main.async {
                        onFailure()
                    }
                }
            }
        }
    }
    
    private func getFinalDate(date: Date, time: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let datePart = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "yyyy-MM-dd HHmm"
        guard let convertedDate = dateFormatter.date(from: "\(datePart) \(time)") else {
            return nil
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return dateFormatter.string(from: convertedDate)
    }
    
    public func set(controller: UIViewController) -> CometChatSchedulerBubbleSwiftUI {
        var view = self
        view._controller = State(initialValue: controller)
        return view
    }
    
    public func set(style: SchedulerBubbleStyle) -> CometChatSchedulerBubbleSwiftUI {
        var view = self
        view.style = style
        return view
    }
    
    public func set(message: SchedulerMessage) -> CometChatSchedulerBubbleSwiftUI {
        var view = self
        view._message = State(initialValue: message)
        return view
    }
    
    public func set(onScheduleClick: @escaping ((_ dateTime: String?, _ message: SchedulerMessage) -> Void)) -> CometChatSchedulerBubbleSwiftUI {
        var view = self
        view._onScheduleClick = State(initialValue: onScheduleClick)
        return view
    }
}


struct SuggestionTimeViewSwiftUI: View {
    let controller: UIViewController?
    let style: SchedulerBubbleStyle
    let message: SchedulerMessage?
    let onMoreTimeButtonClicked: () -> Void
    let onTimeSelected: (TimeRange, Date) -> Void
    let onUnavailableTimeRangeDownloaded: ([String: [TimeRange]]) -> Void
    
    @State private var timeSlots: [TimeRange] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 10) {
            headerView()
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else if timeSlots.isEmpty {
                noSlotsView()
            } else {
                timeSlotsView()
            }
        }
        .padding()
        .onAppear {
            getSuggestedTimeSlot()
        }
    }
    
    private func headerView() -> some View {
        VStack(spacing: 10) {
            CometChatAvatarSwiftUI()
                .set(avatarURL: message?.avatarURL ?? message?.sender?.avatar)
                .set(name: message?.sender?.name ?? "")
                .frame(width: 60, height: 60)
            
            Text(message?.title ?? "MEETING_WITH".localize() + " " + (message?.sender?.name ?? ""))
                .font(Font(style.titleFont))
                .foregroundColor(Color(style.titleTint))
            
            Divider()
                .background(Color(style.dividerTint))
                .frame(height: 0.3)
        }
    }
    
    private func noSlotsView() -> some View {
        VStack(spacing: 10) {
            Image(uiImage: UIImage(named: "error-clock", in: CometChatUIKit.bundle, with: nil) ?? UIImage())
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color(CometChatTheme_v4.palatte.accent600))
                .frame(width: 35, height: 35)
            
            Text("NO_TIME_SLOTS_AVAILABLE".localize())
                .foregroundColor(Color(CometChatTheme_v4.palatte.accent600))
                .font(Font(CometChatTheme_v4.typography.text1))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 30)
    }
    
    private func timeSlotsView() -> some View {
        VStack(spacing: 15) {
            ForEach(0..<min(timeSlots.count, 3), id: \.self) { index in
                Button(action: {
                    onTimeSelected(timeSlots[index], Date(timeIntervalSince1970: TimeInterval(Int(timeSlots[index].startDate) ?? 0)))
                }) {
                    Text(formatDateTime(epochDate: Int(timeSlots[index].startDate) ?? 0, timeString: timeSlots[index].startTime))
                        .font(Font(CometChatTheme_v4.typography.text2))
                        .foregroundColor(Color(style.messageTintColor))
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color(CometChatTheme_v4.palatte.background))
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color(style.messageTintColor), lineWidth: 0.7)
                        )
                }
            }
            
            Text("\((message?.duration ?? 0))min meeting • \(TimeZone.current.getFullForm())")
                .font(Font(CometChatTheme_v4.typography.caption2))
                .foregroundColor(Color(CometChatTheme_v4.palatte.accent700))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button("More times") {
                onMoreTimeButtonClicked()
            }
            .font(Font(CometChatTheme_v4.typography.text3))
            .foregroundColor(Color(style.messageTintColor))
            .padding(.vertical, 10)
        }
    }
    
    private func getSuggestedTimeSlot() {
        guard let message = message else { return }
        
        let icsFile = message.icsFileUrl
        if let url = URL(string: icsFile) {
            CometChatICSParser.load(url: url) { eventsByDate in
                self.onUnavailableTimeRangeDownloaded(eventsByDate)
                var eventsByDate = eventsByDate
                let forDate = max(Date(timeIntervalSince1970: TimeInterval(message.dateRangeStart)), Date())
                
                if forDate.getOnlyDate() == Date().getOnlyDate() {
                    if var currentDateObj = eventsByDate[forDate.getOnlyDate()] {
                        currentDateObj.append(TimeRange(startTime: "0000", endTime: forDate.to24HFormateTime(), startDate: forDate.getOnlyDate(), endDate: forDate.getOnlyDate()))
                        eventsByDate[forDate.getOnlyDate()] = currentDateObj
                    } else {
                        eventsByDate.append(with: [(forDate.getOnlyDate()): [TimeRange(startTime: "0000", endTime: forDate.to24HFormateTime(), startDate: forDate.getOnlyDate(), endDate: forDate.getOnlyDate())]])
                    }
                }
                
                getTimeSlots(eventsByDate: eventsByDate, date: forDate)
            }
        } else {
            var eventByDate = [String: [TimeRange]]()
            let forDate = max(Date(timeIntervalSince1970: TimeInterval(message.dateRangeStart)), Date())
            
            if forDate.getOnlyDate() == Date().getOnlyDate() {
                if var currentDateObj = eventByDate[forDate.getOnlyDate()] {
                    currentDateObj.append(TimeRange(startTime: "0000", endTime: forDate.to24HFormateTime(), startDate: forDate.getOnlyDate(), endDate: forDate.getOnlyDate()))
                    eventByDate[forDate.getOnlyDate()] = currentDateObj
                } else {
                    eventByDate.append(with: [(forDate.getOnlyDate()): [TimeRange(startTime: "0000", endTime: forDate.to24HFormateTime(), startDate: forDate.getOnlyDate(), endDate: forDate.getOnlyDate())]])
                }
            }
            
            getTimeSlots(eventsByDate: eventByDate, date: forDate)
        }
    }
    
    private func getTimeSlots(eventsByDate: [String: [TimeRange]], date: Date) {
        guard let message = message else { return }
        
        if timeSlots.count > 2 {
            isLoading = false
            return
        }
        
        if date > Date(timeIntervalSince1970: TimeInterval(message.dateRangeEnd)) {
            isLoading = false
            return
        }
        
        SchedulerUtils.generateTimeSlots(
            allAvailableTimes: message.availability,
            allUnAvailableTime: eventsByDate,
            forDate: date,
            bufferTime: message.bufferTime,
            duration: message.duration,
            timeZoneCode: message.timezoneCode
        ) { slots in
            for slot in (slots ?? []) {
                var newSlot = slot
                newSlot.startDate = String(Int(date.timeIntervalSince1970))
                newSlot.endDate = String(Int(date.timeIntervalSince1970))
                timeSlots.append(newSlot)
            }
            getTimeSlots(eventsByDate: eventsByDate, date: date.addingTimeInterval(TimeInterval(86400)))
        }
    }
    
    private func formatDateTime(epochDate: Int, timeString: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(epochDate))
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "EEE, MMM d"
        let formattedDate = dateFormatter.string(from: date)
        let hour = Int(timeString.prefix(2))!
        let minute = Int(timeString.suffix(2))!
        
        let calendar = Calendar.current
        let components = DateComponents(hour: hour, minute: minute)
        let timeDate = calendar.date(from: components)!
        
        dateFormatter.dateFormat = "h:mm a"
        let formattedTime = dateFormatter.string(from: timeDate)
        
        return formattedDate + " at " + formattedTime
    }
}

struct ConfirmationViewSwiftUI: View {
    let controller: UIViewController?
    let style: SchedulerBubbleStyle
    let message: SchedulerMessage?
    let date: Date
    let timeSlot: TimeRange
    let onBackButtonClicked: () -> Void
    let onTryAgainClicked: () -> Void
    let onScheduleButtonClicked: (@escaping () -> Void) -> Void
    
    @State private var isLoading = false
    @State private var errorMessage = " "
    @State private var showError = false
    @State private var buttonState = 0 // 0: normal, 1: try again
    
    var body: some View {
        VStack(spacing: 15) {
            headerView()
            
            VStack(spacing: 18) {
                HStack(spacing: 10) {
                    Image(uiImage: UIImage(named: "calendar", in: CometChatUIKit.bundle, with: nil) ?? UIImage())
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color(CometChatTheme_v4.palatte.accent800))
                        .frame(width: 17, height: 17)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "EEEE, dd MMMM yyyy"
                    Text("\(timeSlot.startTime.to12HFormattedTime()), \(dateFormatter.string(from: date))")
                        .foregroundColor(Color(CometChatTheme_v4.palatte.accent800))
                        .font(Font(CometChatTheme_v4.typography.text1))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 10) {
                    Image(uiImage: UIImage(named: "time-zone-earth", in: CometChatUIKit.bundle, with: nil) ?? UIImage())
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color(CometChatTheme_v4.palatte.accent800))
                        .frame(width: 17, height: 17)
                    
                    Text(TimeZone.current.getFullForm())
                        .foregroundColor(Color(CometChatTheme_v4.palatte.accent800))
                        .font(Font(CometChatTheme_v4.typography.text1))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {
                    if buttonState == 0 {
                        isLoading = true
                        onScheduleButtonClicked {
                            isLoading = false
                            errorMessage = "SOMETHING_WENT_WRONG_ERROR".localize()
                            showError = true
                            buttonState = 0
                        }
                    } else if buttonState == 1 {
                        onTryAgainClicked()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    } else {
                        Text(buttonState == 0 ? (message?.scheduleElement?.buttonText ?? "SCHEDULE".localize()) : "TRY_AGAIN".localize())
                            .foregroundColor(.white)
                            .font(Font(CometChatTheme_v4.typography.heading))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                }
                .background(Color(style.messageTintColor))
                .cornerRadius(5)
                .disabled(isLoading)
                
                if showError {
                    Text(errorMessage)
                        .foregroundColor(Color(CometChatTheme_v4.palatte.error))
                        .font(Font(CometChatTheme_v4.typography.subtitle2))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func headerView() -> some View {
        VStack(spacing: 10) {
            HStack {
                Button(action: {
                    onBackButtonClicked()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(style.messageTintColor))
                        .font(.system(size: 20, weight: .semibold))
                }
                .padding(.leading, 10)
                
                Spacer()
                
                Text(message?.title ?? "MEETING_WITH".localize() + " " + (message?.sender?.name ?? ""))
                    .font(Font(style.titleFont))
                    .foregroundColor(Color(style.titleTint))
                
                Spacer()
                
                Color.clear.frame(width: 20, height: 20)
            }
            
            Divider()
                .background(Color(style.dividerTint))
                .frame(height: 0.3)
        }
    }
}

struct InteractedViewSwiftUI: View {
    let titleText: String?
    let subtitleText: String?
    let bodyText: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color(CometChatTheme_v4.palatte.primary))
                    .frame(width: 5)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(titleText ?? "")
                        .font(Font(CometChatTheme_v4.typography.heading))
                        .foregroundColor(Color(CometChatTheme_v4.palatte.accent900))
                        .padding(.top, 5)
                    
                    Text(subtitleText ?? "")
                        .font(Font(CometChatTheme_v4.typography.text2))
                        .foregroundColor(Color(CometChatTheme_v4.palatte.accent700))
                        .padding(.bottom, 8)
                }
                .padding(.leading, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 50)
            .background(Color(CometChatTheme_v4.palatte.accent50))
            .cornerRadius(7)
            
            Text(bodyText ?? "")
                .font(Font(CometChatTheme_v4.typography.text1))
                .foregroundColor(Color(CometChatTheme_v4.palatte.accent))
            
            Spacer()
        }
        .padding(10)
    }
}

struct CalendarViewSwiftUI: View {
    let controller: UIViewController?
    let style: SchedulerBubbleStyle
    let message: SchedulerMessage?
    let onBackButtonClicked: () -> Void
    let onDateSelected: (Date) -> Void
    
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            headerView()
            
            VStack(spacing: 15) {
                Text("SELECT_A_DAY".localize())
                    .font(Font(CometChatTheme_v4.typography.text1))
                    .foregroundColor(Color(CometChatTheme_v4.palatte.accent600))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 5)
                
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .accentColor(style.messageTintColor)
                    .onChange(of: selectedDate) { newValue in
                        onDateSelected(newValue)
                    }
                    .environment(\.locale, Locale.current)
                
                HStack(spacing: 5) {
                    Spacer()
                    
                    Image(uiImage: UIImage(named: "time-zone-earth", in: CometChatUIKit.bundle, with: nil) ?? UIImage())
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color(CometChatTheme_v4.palatte.accent900))
                        .frame(width: 13, height: 13)
                    
                    Text(TimeZone.current.getFullForm())
                        .font(Font(CometChatTheme_v4.typography.caption1))
                        .foregroundColor(Color(CometChatTheme_v4.palatte.accent900))
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 15)
        }
        .onAppear {
            if let message = message {
                let minDate = Date(timeIntervalSince1970: TimeInterval(message.dateRangeStart))
                let maxDate = Date(timeIntervalSince1970: TimeInterval(message.dateRangeEnd))
                selectedDate = max(minDate, Date())
                
            }
        }
    }
    
    private func headerView() -> some View {
        VStack(spacing: 10) {
            HStack {
                Button(action: {
                    onBackButtonClicked()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(style.messageTintColor))
                        .font(.system(size: 20, weight: .semibold))
                }
                .padding(.leading, 10)
                
                Spacer()
                
                Text(message?.title ?? "MEETING_WITH".localize() + " " + (message?.sender?.name ?? ""))
                    .font(Font(style.titleFont))
                    .foregroundColor(Color(style.titleTint))
                
                Spacer()
                
                Color.clear.frame(width: 20, height: 20)
            }
            
            Divider()
                .background(Color(style.dividerTint))
                .frame(height: 0.3)
        }
    }
}

struct TimeSlotViewSwiftUI: View {
    let controller: UIViewController?
    let style: SchedulerBubbleStyle?
    let message: SchedulerMessage?
    let date: Date
    let unavailableTimeRange: [String: [TimeRange]]?
    let onBackButtonClicked: () -> Void
    let onTimeSelected: (TimeRange, Date) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            headerView()
            
            if let message = message, let style = style {
                CometChatTimeSlotSelectorSwiftUI()
                    .set(date: date)
                    .set(style: style.timeSlotSelectorStyle)
                    .set(duration: message.duration)
                    .set(bufferTime: message.bufferTime)
                    .set(icsFileUrl: message.icsFileUrl)
                    .set(unavailableTimeRange: unavailableTimeRange)
                    .set(timeZone: message.timezoneCode)
                    .set(onTimeSelected: { timeRange, date in
                        onTimeSelected(timeRange, date)
                    })
                    .set(availability: message.availability)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 15)
            }
        }
    }
    
    private func headerView() -> some View {
        VStack(spacing: 10) {
            HStack {
                Button(action: {
                    onBackButtonClicked()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(style?.messageTintColor ?? .blue))
                        .font(.system(size: 20, weight: .semibold))
                }
                .padding(.leading, 10)
                
                Spacer()
                
                Text(message?.title ?? "MEETING_WITH".localize() + " " + (message?.sender?.name ?? ""))
                    .font(Font(style?.titleFont ?? UIFont.systemFont(ofSize: 16, weight: .bold)))
                    .foregroundColor(Color(style?.titleTint ?? .black))
                
                Spacer()
                
                Color.clear.frame(width: 20, height: 20)
            }
            
            Divider()
                .background(Color(style?.dividerTint ?? .gray))
                .frame(height: 0.3)
        }
    }
}

struct CometChatTimeSlotSelectorSwiftUI: View {
    @State private var date: Date?
    @State private var style: TimeSlotSelectorStyle?
    @State private var duration: Int = 30
    @State private var bufferTime: Int = 0
    @State private var icsFileUrl: String = ""
    @State private var unavailableTimeRange: [String: [TimeRange]]?
    @State private var timeZone: String = ""
    @State private var onTimeSelected: ((TimeRange, Date) -> Void)?
    @State private var availability: [String]?
    @State private var timeSlots: [TimeRange] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else if timeSlots.isEmpty {
                Text("No time slots available")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(timeSlots, id: \.startTime) { slot in
                            Button(action: {
                                if let date = date {
                                    onTimeSelected?(slot, date)
                                }
                            }) {
                                Text(slot.startTime.to12HFormattedTime())
                                    .foregroundColor(.primary)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                timeSlots = [
                    TimeRange(startTime: "0900", endTime: "0930", startDate: "", endDate: ""),
                    TimeRange(startTime: "1000", endTime: "1030", startDate: "", endDate: ""),
                    TimeRange(startTime: "1100", endTime: "1130", startDate: "", endDate: "")
                ]
                isLoading = false
            }
        }
    }
    
    func set(date: Date) -> CometChatTimeSlotSelectorSwiftUI {
        var view = self
        view._date = State(initialValue: date)
        return view
    }
    
    func set(style: TimeSlotSelectorStyle?) -> CometChatTimeSlotSelectorSwiftUI {
        var view = self
        view._style = State(initialValue: style)
        return view
    }
    
    func set(duration: Int) -> CometChatTimeSlotSelectorSwiftUI {
        var view = self
        view._duration = State(initialValue: duration)
        return view
    }
    
    func set(bufferTime: Int) -> CometChatTimeSlotSelectorSwiftUI {
        var view = self
        view._bufferTime = State(initialValue: bufferTime)
        return view
    }
    
    func set(icsFileUrl: String) -> CometChatTimeSlotSelectorSwiftUI {
        var view = self
        view._icsFileUrl = State(initialValue: icsFileUrl)
        return view
    }
    
    func set(unavailableTimeRange: [String: [TimeRange]]?) -> CometChatTimeSlotSelectorSwiftUI {
        var view = self
        view._unavailableTimeRange = State(initialValue: unavailableTimeRange)
        return view
    }
    
    func set(timeZone: String) -> CometChatTimeSlotSelectorSwiftUI {
        var view = self
        view._timeZone = State(initialValue: timeZone)
        return view
    }
    
    func set(onTimeSelected: @escaping (TimeRange, Date) -> Void) -> CometChatTimeSlotSelectorSwiftUI {
        var view = self
        view._onTimeSelected = State(initialValue: onTimeSelected)
        return view
    }
    
    func set(availability: [String]?) -> CometChatTimeSlotSelectorSwiftUI {
        var view = self
        view._availability = State(initialValue: availability)
        return view
    }
}

extension CometChatSchedulerBubbleSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatSchedulerBubbleSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatSchedulerBubbleSwiftUI()
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            CometChatSchedulerBubbleSwiftUI()
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
