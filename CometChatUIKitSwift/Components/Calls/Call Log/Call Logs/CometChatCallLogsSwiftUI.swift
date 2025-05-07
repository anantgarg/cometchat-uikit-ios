//
//
//

#if canImport(CometChatCallsSDK)

import SwiftUI
import CometChatSDK
import CometChatUIKitSwift.Components.Shared.Constants

public struct CometChatCallLogsSwiftUI: View {
    @StateObject private var viewModel = CallLogsViewModelSwiftUI()
    @State private var controller: UIViewController?
    
    private var listItemView: ((CometChatCallsSDK.CallLog) -> AnyView)?
    private var trailView: ((CometChatCallsSDK.CallLog) -> AnyView)?
    private var leadingView: ((CometChatCallsSDK.CallLog) -> AnyView)?
    private var titleView: ((CometChatCallsSDK.CallLog) -> AnyView)?
    private var subtitleView: ((CometChatCallsSDK.CallLog) -> AnyView)?
    private var onItemClick: ((CometChatCallsSDK.CallLog) -> Void)?
    private var onItemLongClick: ((CometChatCallsSDK.CallLog, Int) -> Void)?
    private var goToCallLogDetail: ((CometChatCallsSDK.CallLog, User?, Group?) -> Void)?
    private var onError: ((Any?) -> Void)?
    private var outgoingCallConfiguration = OutgoingCallConfiguration()
    private var onCallButtonClicked: ((CometChatCallsSDK.CallLog) -> Void)?
    private var onEmpty: (() -> Void)?
    private var onLoad: (([CometChatCallsSDK.CallLog]) -> Void)?
    private var datePattern: ((CometChatCallsSDK.CallLog) -> String)?
    private var options: ((CometChatCallsSDK.CallLog) -> [CometChatCallOption])?
    private var addOptions: ((CometChatCallsSDK.CallLog) -> [CometChatCallOption])?
    private var callRequestBuilder: CometChatCallsSDK.CallLogsRequest.CallLogsBuilder?
    
    public static var style = CallLogStyle()
    private var style = CometChatCallLogsSwiftUI.style
    
    public static var dateTimeFormatter: CometChatDateTimeFormatter = CometChatUIKit.dateTimeFormatter
    private var dateTimeFormatter: CometChatDateTimeFormatter = CometChatCallLogsSwiftUI.dateTimeFormatter
    
    public static var avatarStyle: AvatarStyle = {
        var avatarStyle = CometChatAvatar.style
        return avatarStyle
    }()
    private var avatarStyle = CometChatCallLogsSwiftUI.avatarStyle
    
    public static var dateStyle: DateStyle = {
        var dateStyle = CometChatDate.style
        return dateStyle
    }()
    private var dateStyle = CometChatCallLogsSwiftUI.dateStyle
    
    private var errorStateTitleText = "OOPS!".localize()
    private var errorStateSubTitleText = "LOOKS_LIKE_SOMETHINGS_WENT_WORNG._PLEASE_TRY_AGAIN".localize()
    private var errorStateImageName = "error-icon"
    private var emptyStateImageName = "phone.fill"
    private var emptyStateTitleText = "CALL_LOGS_EMPTY_MESSAGE".localize()
    private var emptyStateSubTitleText = "CALL_LOGS_EMPTY_SUBTITLE_MESSAGE".localize()
    
    public init() {
        setupController()
    }
    
    public var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.callLogs.isEmpty {
                loadingView
            } else if viewModel.isError {
                errorView
            } else if viewModel.isEmpty {
                emptyView
            } else {
                callLogsList
            }
        }
        .onAppear {
            if callRequestBuilder != nil {
                viewModel.set(callLogRequestBuilder: callRequestBuilder!)
            }
            viewModel.fetchCallLogs()
        }
    }
    
    private var loadingView: some View {
        CometChatCallLogShimmerSwiftUI()
    }
    
    private var errorView: some View {
        VStack(spacing: LayoutMetrics.spacingLarge) {
            if let bundleImage = UIImage(named: errorStateImageName, in: CometChatUIKit.bundle, compatibleWith: nil) {
                Image(uiImage: bundleImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: LayoutMetrics.largeIconSize * 3, height: LayoutMetrics.largeIconSize * 3)
            } else {
                Image(systemName: "exclamationmark.triangle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: LayoutMetrics.largeIconSize * 3, height: LayoutMetrics.largeIconSize * 3)
                    .foregroundColor(Color(style.errorStateIconTint))
            }
            
            Text(errorStateTitleText)
                .font(Font(style.errorStateTitleFont))
                .foregroundColor(Color(style.errorStateTextColor))
            
            Text(errorStateSubTitleText)
                .font(Font(style.errorStateTextFont))
                .foregroundColor(Color(style.errorStateTextColor))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                viewModel.fetchCallLogs()
            }) {
                Text("RETRY".localize())
                    .font(Font(style.errorStateButtonFont))
                    .foregroundColor(Color(style.errorStateButtonTextColor))
                    .padding(.horizontal, LayoutMetrics.spacingLarge)
                    .padding(.vertical, LayoutMetrics.spacingMedium)
                    .background(Color(style.errorStateButtonBackgroundColor))
                    .cornerRadius(LayoutMetrics.cornerRadiusStandard)
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: LayoutMetrics.spacingLarge) {
            Image(systemName: emptyStateImageName)
                .resizable()
                .scaledToFit()
                .frame(width: LayoutMetrics.largeIconSize * 3, height: LayoutMetrics.largeIconSize * 3)
                .foregroundColor(Color(style.emptyStateIconTint))
            
            Text(emptyStateTitleText)
                .font(Font(style.emptyStateTitleFont))
                .foregroundColor(Color(style.emptyStateTextColor))
            
            Text(emptyStateSubTitleText)
                .font(Font(style.emptyStateTextFont))
                .foregroundColor(Color(style.emptyStateTextColor))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .onAppear {
            onEmpty?()
        }
    }
    
    private var callLogsList: some View {
        List {
            ForEach(Array(viewModel.callLogs.enumerated()), id: \.element.sessionId) { index, callLog in
                callLogCell(for: callLog, at: index)
                    .onAppear {
                        if index == viewModel.callLogs.count - 1 && !viewModel.isLoading {
                            viewModel.fetchNext()
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .background(Color.clear)
            }
            
            if !viewModel.callLogs.isEmpty {
                HStack {
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            viewModel.refresh()
        }
        .onAppear {
            onLoad?(viewModel.callLogs)
        }
    }
    
    private func callLogCell(for callLog: CometChatCallsSDK.CallLog, at index: Int) -> some View {
        let callUser = getCallUser(from: callLog)
        let callGroup = getCallGroup(from: callLog)
        
        return Button(action: {
            handleItemClick(callLog: callLog, callUser: callUser, callGroup: callGroup)
        }) {
            HStack(spacing: LayoutMetrics.spacingMedium) {
                if let leadingView = leadingView?(callLog) {
                    leadingView
                } else {
                    CometChatAvatarSwiftUI(style: avatarStyle)
                        .set(avatarURL: callUser?.avatar ?? callGroup?.icon ?? "")
                        .set(name: callUser?.name ?? callGroup?.name ?? "")
                        .set(width: LayoutMetrics.avatarLarge)
                        .set(height: LayoutMetrics.avatarLarge)
                }
                
                VStack(alignment: .leading, spacing: LayoutMetrics.spacingSmall) {
                    if let titleView = titleView?(callLog) {
                        titleView
                    } else {
                        Text(callUser?.name ?? callGroup?.name ?? "")
                            .font(Font(style.titleTextFont))
                            .foregroundColor(isMissedCall(callLog) ? Color(style.missedCallTitleColor) : Color(style.titleTextColor))
                            .lineLimit(1)
                    }
                    
                    if let subtitleView = subtitleView?(callLog) {
                        subtitleView
                    } else {
                        defaultSubtitleView(for: callLog)
                    }
                }
                
                Spacer()
                
                if let trailView = trailView?(callLog) {
                    trailView
                } else {
                    Button(action: {
                        handleCallButtonClick(callLog: callLog)
                    }) {
                        if callLog.type == .audio {
                            Image(systemName: "phone.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: LayoutMetrics.largeIconSize, height: LayoutMetrics.largeIconSize)
                                .foregroundColor(Color(style.audioCallIconTint))
                        } else {
                            Image(systemName: "video.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: LayoutMetrics.largeIconSize, height: LayoutMetrics.largeIconSize)
                                .foregroundColor(Color(style.videoCallIconTint))
                        }
                    }
                }
            }
            .padding(.vertical, LayoutMetrics.spacingMedium)
            .padding(.horizontal, LayoutMetrics.spacingLarge)
            .contentShape(Rectangle())
            .contextMenu {
                contextMenuItems(for: callLog)
            }
            .onLongPressGesture {
                onItemLongClick?(callLog, index)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func defaultSubtitleView(for callLog: CometChatCallsSDK.CallLog) -> some View {
        HStack(spacing: LayoutMetrics.spacingSmall) {
            getCallStatusImage(for: callLog)
                .resizable()
                .scaledToFit()
                .frame(width: LayoutMetrics.iconSize, height: LayoutMetrics.iconSize)
                .foregroundColor(getCallStatusIconTint(for: callLog))
            
            Text(getCallStatusText(for: callLog))
                .font(Font(style.subtitleTextFont))
                .foregroundColor(Color(style.subtitleTextColor))
            
            Text("•")
                .font(Font(style.subtitleTextFont))
                .foregroundColor(Color(style.subtitleTextColor))
            
            Text(getFormattedDate(for: callLog))
                .font(Font(style.subtitleTextFont))
                .foregroundColor(Color(style.subtitleTextColor))
        }
    }
    
    private func getCallStatusImage(for callLog: CometChatCallsSDK.CallLog) -> Image {
        let isOutgoing = (callLog.initiator as? CallUser)?.uid == CometChat.getLoggedInUser()?.uid
        
        if isOutgoing {
            return Image(systemName: "arrow.up.right")
        } else if callLog.status == .unanswered || callLog.status == .cancelled {
            return Image(systemName: "phone.down.fill")
        } else {
            return Image(systemName: "arrow.down.left")
        }
    }
    
    private func contextMenuItems(for callLog: CometChatCallsSDK.CallLog) -> some View {
        Group {
            if let options = options?(callLog) {
                ForEach(options, id: \.id) { option in
                    Button(action: {
                        option.onClick?(nil, 0, option, nil)
                    }) {
                        if let icon = option.icon {
                            Label(
                                title: { Text(option.title ?? "") },
                                icon: { Image(uiImage: icon) }
                            )
                        } else {
                            Text(option.title ?? "")
                        }
                    }
                }
            }
            
            if let addOptions = addOptions?(callLog) {
                ForEach(addOptions, id: \.id) { option in
                    Button(action: {
                        option.onClick?(nil, 0, option, nil)
                    }) {
                        if let icon = option.icon {
                            Label(
                                title: { Text(option.title ?? "") },
                                icon: { Image(uiImage: icon) }
                            )
                        } else {
                            Text(option.title ?? "")
                        }
                    }
                }
            }
        }
    }
    
    private func setupController() {
        let rootViewController = UIApplication.shared.windows.first?.rootViewController
        self.controller = rootViewController
    }
    
    private func getCallUser(from callLog: CometChatCallsSDK.CallLog) -> CallUser? {
        if let initiator = (callLog.initiator as? CallUser), initiator.uid != CometChatUIKit.getLoggedInUser()?.uid {
            return initiator
        } else if let receiver = (callLog.receiver as? CallUser) {
            return receiver
        }
        return nil
    }
    
    private func getCallGroup(from callLog: CometChatCallsSDK.CallLog) -> CallGroup? {
        return (callLog.receiver as? CallGroup)
    }
    
    private func isMissedCall(_ callLog: CometChatCallsSDK.CallLog) -> Bool {
        return (callLog.status == .unanswered && (callLog.initiator as? CallUser)?.uid != CometChat.getLoggedInUser()?.uid) ||
               (callLog.status == .cancelled && (callLog.initiator as? CallUser)?.uid != CometChat.getLoggedInUser()?.uid)
    }
    
    private func getCallStatusIcon(for callLog: CometChatCallsSDK.CallLog) -> Image {
        getCallStatusImage(for: callLog)
    }
    
    private func getCallStatusIconTint(for callLog: CometChatCallsSDK.CallLog) -> Color {
        let isOutgoing = (callLog.initiator as? CallUser)?.uid == CometChat.getLoggedInUser()?.uid
        
        if isOutgoing {
            return Color(style.outgoingCallIconTint)
        } else if callLog.status == .unanswered || callLog.status == .cancelled {
            return Color(style.missedCallIconTint)
        } else {
            return Color(style.incomingCallIconTint)
        }
    }
    
    private func getCallStatusText(for callLog: CometChatCallsSDK.CallLog) -> String {
        let isOutgoing = (callLog.initiator as? CallUser)?.uid == CometChat.getLoggedInUser()?.uid
        
        if isOutgoing {
            return "OUTGOING".localize()
        } else if callLog.status == .unanswered || callLog.status == .cancelled {
            return "MISSED".localize()
        } else {
            return "INCOMING".localize()
        }
    }
    
    private func getFormattedDate(for callLog: CometChatCallsSDK.CallLog) -> String {
        if let customPattern = datePattern?(callLog) {
            return customPattern
        }
        
        if let initiatedAt = callLog.initiatedAt {
            return dateTimeFormatter.getTimeStringFromUTC(date: initiatedAt)
        }
        
        return ""
    }
    
    private func handleItemClick(callLog: CometChatCallsSDK.CallLog, callUser: CallUser?, callGroup: CallGroup?) {
        if let onItemClick = onItemClick {
            onItemClick(callLog)
        } else if let goToCallLogDetail = goToCallLogDetail {
            if let callUser = callUser {
                CometChat.getUser(UID: callUser.uid) { user in
                    DispatchQueue.main.async {
                        if let user = user {
                            goToCallLogDetail(callLog, user, nil)
                        }
                    }
                } onError: { error in
                    onError?(error)
                }
            } else if let callGroup = callGroup {
                CometChat.getGroup(GUID: callGroup.guid) { group in
                    DispatchQueue.main.async {
                        goToCallLogDetail(callLog, nil, group)
                    }
                } onError: { error in
                    onError?(error)
                }
            }
        }
    }
    
    private func handleCallButtonClick(callLog: CometChatCallsSDK.CallLog) {
        if let onCallButtonClicked = onCallButtonClicked {
            onCallButtonClicked(callLog)
        } else {
            placeCall(for: callLog)
        }
    }
    
    private func placeCall(for callObject: CallLog) {
        var call: Call?
        let isInitiator = CometChat.getLoggedInUser()?.uid != (callObject.initiator as? CallUser)?.uid
        if let callUser = isInitiator ? (callObject.initiator as? CallUser) : (callObject.receiver as? CallUser) {
            call = Call(receiverId: callUser.uid, callType: callObject.type == .video ? .video : .audio, receiverType: .user)
            
            if callObject.type == .video {
                initiateDefaultVideoCall(call!)
            } else {
                initiateDefaultAudioCall(call!)
            }
        }
    }
    
    private func initiateDefaultAudioCall(_ call: Call) {
        CometChat.initiateCall(call: call) { call in
            DispatchQueue.main.async { [self] in
                guard let call = call else { return }
                CometChatCallEvents.ccOutgoingCall(call: call)
                let outgoingCall = CometChatOutgoingCall()
                outgoingCall.set(call: call)
                outgoingCall.modalPresentationStyle = .fullScreen
                setupOutgoingCallConfiguration(outgoingCall: outgoingCall)
                outgoingCall.set(onCancelClick: { call, controller in
                    CometChat.rejectCall(sessionID: call?.sessionID ?? "", status: .cancelled) { call in
                        if let call = call {
                            CometChatCallEvents.ccCallRejected(call: call)
                        }
                        DispatchQueue.main.async {
                            controller?.dismiss(animated: true)
                        }
                    } onError: { error in
                        onError?(error)
                        DispatchQueue.main.async {
                            controller?.dismiss(animated: true)
                        }
                    }
                })
                
                controller?.present(outgoingCall, animated: true)
            }
        } onError: { error in
            onError?(error)
        }
    }
    
    private func initiateDefaultVideoCall(_ call: Call) {
        CometChat.initiateCall(call: call) { call in
            DispatchQueue.main.async { [self] in
                guard let call = call else { return }
                CometChatCallEvents.ccOutgoingCall(call: call)
                let outgoingCall = CometChatOutgoingCall()
                outgoingCall.set(call: call)
                outgoingCall.modalPresentationStyle = .fullScreen
                setupOutgoingCallConfiguration(outgoingCall: outgoingCall)
                outgoingCall.set(onCancelClick: { call, controller in
                    CometChat.rejectCall(sessionID: call?.sessionID ?? "", status: .cancelled) { call in
                        if let call = call {
                            CometChatCallEvents.ccCallRejected(call: call)
                        }
                        DispatchQueue.main.async {
                            controller?.dismiss(animated: true)
                        }
                    } onError: { error in
                        onError?(error)
                        DispatchQueue.main.async {
                            controller?.dismiss(animated: true)
                        }
                    }
                })
                
                controller?.present(outgoingCall, animated: true)
            }
        } onError: { error in
            onError?(error)
        }
    }
    
    private func setupOutgoingCallConfiguration(outgoingCall: CometChatOutgoingCall) {
        if let declineButtonIcon = outgoingCallConfiguration.declineButtonIcon {
            outgoingCall.style.declineButtonIcon = declineButtonIcon
        }
        if let disableSoundForCalls = outgoingCallConfiguration.disableSoundForCalls {
            outgoingCall.disable(soundForCalls: disableSoundForCalls)
        }
        if let customSoundForCalls = outgoingCallConfiguration.customSoundForCalls {
            outgoingCall.set(customSoundForCalls: customSoundForCalls)
        }
        if let avatarStyle = outgoingCallConfiguration.avatarStyle {
            outgoingCall.avatarStyle = avatarStyle
        }
        if let outgoingCallStyle = outgoingCallConfiguration.outgoingCallStyle {
            outgoingCall.style = outgoingCallStyle
        }
        if let callSettingsBuilder = outgoingCallConfiguration.callSettingsBuilder {
            outgoingCall.set(callSettingsBuilder: callSettingsBuilder)
        }
    }
    
    @discardableResult
    public func set(listItemView: @escaping ((CometChatCallsSDK.CallLog) -> AnyView)) -> Self {
        var view = self
        view.listItemView = listItemView
        return view
    }
    
    @discardableResult
    public func set(trailView: @escaping ((CometChatCallsSDK.CallLog) -> AnyView)) -> Self {
        var view = self
        view.trailView = trailView
        return view
    }
    
    @discardableResult
    public func set(leadingView: @escaping ((CometChatCallsSDK.CallLog) -> AnyView)) -> Self {
        var view = self
        view.leadingView = leadingView
        return view
    }
    
    @discardableResult
    public func set(titleView: @escaping ((CometChatCallsSDK.CallLog) -> AnyView)) -> Self {
        var view = self
        view.titleView = titleView
        return view
    }
    
    @discardableResult
    public func set(subtitleView: @escaping ((CometChatCallsSDK.CallLog) -> AnyView)) -> Self {
        var view = self
        view.subtitleView = subtitleView
        return view
    }
    
    @discardableResult
    public func set(onItemClick: @escaping ((CometChatCallsSDK.CallLog) -> Void)) -> Self {
        var view = self
        view.onItemClick = onItemClick
        return view
    }
    
    @discardableResult
    public func set(onItemLongClick: @escaping ((CometChatCallsSDK.CallLog, Int) -> Void)) -> Self {
        var view = self
        view.onItemLongClick = onItemLongClick
        return view
    }
    
    @discardableResult
    public func set(goToCallLogDetail: @escaping ((CometChatCallsSDK.CallLog, User?, Group?) -> Void)) -> Self {
        var view = self
        view.goToCallLogDetail = goToCallLogDetail
        return view
    }
    
    @discardableResult
    public func set(onError: @escaping ((Any?) -> Void)) -> Self {
        var view = self
        view.onError = onError
        return view
    }
    
    @discardableResult
    public func set(outgoingCallConfiguration: OutgoingCallConfiguration) -> Self {
        var view = self
        view.outgoingCallConfiguration = outgoingCallConfiguration
        return view
    }
    
    @discardableResult
    public func set(onCallButtonClicked: @escaping ((CometChatCallsSDK.CallLog) -> Void)) -> Self {
        var view = self
        view.onCallButtonClicked = onCallButtonClicked
        return view
    }
    
    @discardableResult
    public func set(onEmpty: @escaping (() -> Void)) -> Self {
        var view = self
        view.onEmpty = onEmpty
        return view
    }
    
    @discardableResult
    public func set(onLoad: @escaping (([CometChatCallsSDK.CallLog]) -> Void)) -> Self {
        var view = self
        view.onLoad = onLoad
        return view
    }
    
    @discardableResult
    public func set(datePattern: @escaping ((CometChatCallsSDK.CallLog) -> String)) -> Self {
        var view = self
        view.datePattern = datePattern
        return view
    }
    
    @discardableResult
    public func set(options: @escaping ((CometChatCallsSDK.CallLog) -> [CometChatCallOption])) -> Self {
        var view = self
        view.options = options
        return view
    }
    
    @discardableResult
    public func set(addOptions: @escaping ((CometChatCallsSDK.CallLog) -> [CometChatCallOption])) -> Self {
        var view = self
        view.addOptions = addOptions
        return view
    }
    
    @discardableResult
    public func set(callRequestBuilder: CometChatCallsSDK.CallLogsRequest.CallLogsBuilder) -> Self {
        var view = self
        view.callRequestBuilder = callRequestBuilder
        return view
    }
    
    @discardableResult
    public func set(style: CallLogStyle) -> Self {
        var view = self
        view.style = style
        return view
    }
    
    @discardableResult
    public func set(dateTimeFormatter: CometChatDateTimeFormatter) -> Self {
        var view = self
        view.dateTimeFormatter = dateTimeFormatter
        return view
    }
    
    @discardableResult
    public func set(avatarStyle: AvatarStyle) -> Self {
        var view = self
        view.avatarStyle = avatarStyle
        return view
    }
    
    @discardableResult
    public func set(dateStyle: DateStyle) -> Self {
        var view = self
        view.dateStyle = dateStyle
        return view
    }
    
    @discardableResult
    public func set(errorStateTitleText: String) -> Self {
        var view = self
        view.errorStateTitleText = errorStateTitleText
        return view
    }
    
    @discardableResult
    public func set(errorStateSubTitleText: String) -> Self {
        var view = self
        view.errorStateSubTitleText = errorStateSubTitleText
        return view
    }
    
    @discardableResult
    public func set(errorStateImage: UIImage) -> Self {
        var view = self
        view.errorStateImage = errorStateImage
        return view
    }
    
    @discardableResult
    public func set(emptyStateImage: UIImage) -> Self {
        var view = self
        view.emptyStateImage = emptyStateImage
        return view
    }
    
    @discardableResult
    public func set(emptyStateTitleText: String) -> Self {
        var view = self
        view.emptyStateTitleText = emptyStateTitleText
        return view
    }
    
    @discardableResult
    public func set(emptyStateSubTitleText: String) -> Self {
        var view = self
        view.emptyStateSubTitleText = emptyStateSubTitleText
        return view
    }
}

struct CometChatCallLogShimmerSwiftUI: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { _ in
                HStack(spacing: 12) {
                    Circle()
                        .fill(shimmerGradient)
                        .frame(width: 48, height: 48)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(shimmerGradient)
                            .frame(height: 16)
                            .frame(width: 120)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(shimmerGradient)
                            .frame(height: 12)
                            .frame(width: 180)
                    }
                    
                    Spacer()
                    
                    Circle()
                        .fill(shimmerGradient)
                        .frame(width: 24, height: 24)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                
                Divider()
                    .padding(.leading, 76)
            }
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
    
    private var shimmerGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(UIColor.systemGray5),
                Color(UIColor.systemGray6),
                Color(UIColor.systemGray5)
            ]),
            startPoint: .leading,
            endPoint: isAnimating ? .trailing : .leading
        )
    }
}

extension CometChatCallLogsSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatCallLogsSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatCallLogsSwiftUI()
                .previewDisplayName("Call Logs (Light)")
            
            CometChatCallLogsSwiftUI()
                .preferredColorScheme(.dark)
                .previewDisplayName("Call Logs (Dark)")
        }
    }
}

#endif
