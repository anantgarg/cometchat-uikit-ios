//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatMessageHeaderSwiftUI: View {
    public static var style = MessageHeaderStyle()
    public static var statusIndicatorStyle: StatusIndicatorStyle = {
        var style = CometChatStatusIndicator.style
        style.borderWidth = 2
        return style
    }()
    public static var typingIndicatorStyle: TypingIndicatorStyle = {
        var style = CometChatTypingIndicator.style
        style.textFont = CometChatTypography.Caption1.regular
        return style
    }()
    public static var avatarStyle: AvatarStyle = {
        var style = CometChatAvatar.style
        return style
    }()
    
    private var style: MessageHeaderStyle
    private var statusIndicatorStyle: StatusIndicatorStyle
    private var typingIndicatorStyle: TypingIndicatorStyle
    private var avatarStyle: AvatarStyle
    
    private var hideBackButton: Bool = false
    private var hideUserStatus: Bool = false
    private var hideVideoCallButton: Bool = false
    private var hideVoiceCallButton: Bool = false
    private var disableTyping: Bool = false
    private var disableUsersPresence: Bool = false
    
    private var listItemView: ((User?, Group?) -> AnyView)?
    private var leadingView: ((User?, Group?) -> AnyView)?
    private var titleView: ((User?, Group?) -> AnyView)?
    private var subtitleView: ((User?, Group?) -> AnyView)?
    private var trailView: ((User?, Group?) -> AnyView)?
    private var auxiliaryView: ((User?, Group?) -> AnyView)?
    
    private var onBack: (() -> Void)?
    private var onError: ((CometChatException) -> Void)?
    
    private var dateTimeFormatter: CometChatDateTimeFormatter = CometChatUIKit.dateTimeFormatter
    
    @StateObject private var viewModel = MessageHeaderViewModelSwiftUI()
    @Environment(\.presentationMode) private var presentationMode
    
    public init(style: MessageHeaderStyle = CometChatMessageHeaderSwiftUI.style) {
        self.style = style
        self.statusIndicatorStyle = CometChatMessageHeaderSwiftUI.statusIndicatorStyle
        self.typingIndicatorStyle = CometChatMessageHeaderSwiftUI.typingIndicatorStyle
        self.avatarStyle = CometChatMessageHeaderSwiftUI.avatarStyle
    }
    
    public var body: some View {
        if let customView = listItemView?(viewModel.user, viewModel.group) {
            customView
        } else {
            defaultHeaderView
        }
        .onAppear {
            viewModel.connect()
            setupCallbacks()
        }
        .onDisappear {
            viewModel.disconnect()
        }
    }
    
    private var defaultHeaderView: some View {
        HStack(spacing: 8) {
            if let customLeadingView = leadingView?(viewModel.user, viewModel.group) {
                customLeadingView
            } else {
                defaultLeadingView
            }
            
            VStack(alignment: .leading, spacing: 2) {
                if let customTitleView = titleView?(viewModel.user, viewModel.group) {
                    customTitleView
                } else {
                    defaultTitleView
                }
                
                if !hideUserStatus {
                    if let customSubtitleView = subtitleView?(viewModel.user, viewModel.group) {
                        customSubtitleView
                    } else {
                        defaultSubtitleView
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                if let customAuxiliaryView = auxiliaryView?(viewModel.user, viewModel.group) {
                    customAuxiliaryView
                } else {
                    defaultAuxiliaryView
                }
                
                if let customTrailView = trailView?(viewModel.user, viewModel.group) {
                    customTrailView
                }
            }
            .frame(maxWidth: 120)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(height: 60)
        .background(
            style.backgroundImage != nil ?
            Image(uiImage: style.backgroundImage!)
                .resizable()
                .aspectRatio(contentMode: .fill) :
            Color(style.backgroundColor)
        )
        .cornerRadius(style.cornerRadius?.cornerRadius ?? 0)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius?.cornerRadius ?? 0)
                .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
        )
    }
    
    private var defaultLeadingView: some View {
        HStack(spacing: 8) {
            if !hideBackButton {
                Button(action: {
                    if let onBack = onBack {
                        onBack()
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Image(uiImage: style.backButtonIcon ?? UIImage(systemName: "chevron.left")!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(style.backButtonImageTintColor))
                }
            }
            
            ZStack {
                CometChatAvatarSwiftUI(style: avatarStyle)
                    .set(user: viewModel.user)
                    .set(group: viewModel.group)
                    .set(width: 40)
                    .set(height: 40)
                
                if let group = viewModel.group {
                    switch group.groupType {
                    case .private:
                        CometChatStatusIndicatorSwiftUI(style: statusIndicatorStyle)
                            .set(icon: style.privateGroupIcon)
                            .set(iconTint: style.privateGroupBadgeImageTintColor)
                            .set(backgroundColor: style.privateGroupImageBackgroundColor)
                            .offset(x: 14, y: 14)
                    case .password:
                        CometChatStatusIndicatorSwiftUI(style: statusIndicatorStyle)
                            .set(icon: style.protectedGroupIcon)
                            .set(iconTint: style.passwordProtectedGroupBadgeImageTintColor)
                            .set(backgroundColor: style.passwordGroupImageBackgroundColor)
                            .offset(x: 14, y: 14)
                    default:
                        EmptyView()
                    }
                } else if let user = viewModel.user, user.status == .online && !hideUserStatus {
                    CometChatStatusIndicatorSwiftUI(style: statusIndicatorStyle)
                        .set(status: .online)
                        .offset(x: 14, y: 14)
                }
            }
        }
    }
    
    private var defaultTitleView: some View {
        Text(getTitle())
            .font(Font(style.titleTextFont))
            .foregroundColor(Color(style.titleTextColor))
            .lineLimit(1)
    }
    
    private var defaultSubtitleView: some View {
        Group {
            if viewModel.isTyping {
                if let group = viewModel.group {
                    Text("\(viewModel.typingUser?.name ?? "") \(MessageHeaderConstants.isTyping)")
                        .font(Font(typingIndicatorStyle.textFont))
                        .foregroundColor(Color(typingIndicatorStyle.textColor))
                        .lineLimit(1)
                } else {
                    Text(MessageHeaderConstants.typing)
                        .font(Font(typingIndicatorStyle.textFont))
                        .foregroundColor(Color(typingIndicatorStyle.textColor))
                        .lineLimit(1)
                }
            } else if let group = viewModel.group {
                Text("\(group.membersCount) \(group.membersCount > 1 ? MessageHeaderConstants.members : MessageHeaderConstants.member)")
                    .font(Font(style.subtitleTextFont))
                    .foregroundColor(Color(style.subtitleTextColor))
                    .lineLimit(1)
            } else if let user = viewModel.user {
                if !disableUsersPresence {
                    if user.status == .online {
                        Text(MessageHeaderConstants.online)
                            .font(Font(style.subtitleTextFont))
                            .foregroundColor(Color(style.subtitleTextColor))
                            .lineLimit(1)
                    } else {
                        Text(getLastSeenText(for: user))
                            .font(Font(style.subtitleTextFont))
                            .foregroundColor(Color(style.subtitleTextColor))
                            .lineLimit(1)
                    }
                }
            }
        }
    }
    
    private var defaultAuxiliaryView: some View {
        HStack(spacing: 12) {
            if let user = viewModel.user {
                if !hideVoiceCallButton {
                    Button(action: {
                    }) {
                        Image(systemName: "phone")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color(CometChatTheme.primaryColor))
                    }
                }
                
                if !hideVideoCallButton {
                    Button(action: {
                    }) {
                        Image(systemName: "video")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color(CometChatTheme.primaryColor))
                    }
                }
            }
        }
    }
    
    private func getTitle() -> String {
        if let user = viewModel.user {
            return user.name ?? ""
        } else if let group = viewModel.group {
            return group.name ?? ""
        } else if let name = viewModel.name {
            return name
        }
        return ""
    }
    
    private func getLastSeenText(for user: User) -> String {
        let currentTime = Date()
        let dateTimeFormatterUtils = DateTimeFormatterUtils()
        
        let lastSeenTime = Date(timeIntervalSince1970: user.lastActiveAt)
        let timestamp = Int(user.lastActiveAt)
        
        if let formatter = dateTimeFormatterUtils.getFormattedDateFromClosures(timeStamp: timestamp, dateTimeFormatter: dateTimeFormatter) {
            return "\("LAST_SEEN".localize()) \(formatter)"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: CometChatLocalize.getLocale())
            dateFormatter.dateFormat = "d MMM 'at' h:mm a"
            return "\("LAST_SEEN".localize()) \(dateFormatter.string(from: lastSeenTime))"
        }
    }
    
    private func setupCallbacks() {
        viewModel.onUpdateUserStatus = { isOnline in
        }
        
        viewModel.onUpdateTypingStatus = { user, isTyping in
        }
        
        viewModel.onUpdateGroupCount = { group in
        }
        
        viewModel.onError = { error in
            if let onError = onError {
                onError(error)
            }
        }
    }
    
    public func set(user: User) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.viewModel.set(user: user)
        return view
    }
    
    public func set(group: Group) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.viewModel.set(group: group)
        return view
    }
    
    public func set(name: String) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.viewModel.name = name
        return view
    }
    
    public func set(style: MessageHeaderStyle) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.style = style
        return view
    }
    
    public func set(statusIndicatorStyle: StatusIndicatorStyle) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.statusIndicatorStyle = statusIndicatorStyle
        return view
    }
    
    public func set(typingIndicatorStyle: TypingIndicatorStyle) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.typingIndicatorStyle = typingIndicatorStyle
        return view
    }
    
    public func set(avatarStyle: AvatarStyle) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.avatarStyle = avatarStyle
        return view
    }
    
    public func set(dateTimeFormatter: CometChatDateTimeFormatter) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.dateTimeFormatter = dateTimeFormatter
        return view
    }
    
    public func hide(backButton: Bool) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.hideBackButton = backButton
        return view
    }
    
    public func hide(userStatus: Bool) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.hideUserStatus = userStatus
        return view
    }
    
    public func hide(videoCallButton: Bool) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.hideVideoCallButton = videoCallButton
        return view
    }
    
    public func hide(voiceCallButton: Bool) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.hideVoiceCallButton = voiceCallButton
        return view
    }
    
    public func disable(typing: Bool) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.disableTyping = typing
        return view
    }
    
    public func disable(usersPresence: Bool) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.disableUsersPresence = usersPresence
        return view
    }
    
    public func set<T: View>(listItemView: @escaping (User?, Group?) -> T) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.listItemView = { user, group in
            AnyView(listItemView(user, group))
        }
        return view
    }
    
    public func set<T: View>(leadingView: @escaping (User?, Group?) -> T) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.leadingView = { user, group in
            AnyView(leadingView(user, group))
        }
        return view
    }
    
    public func set<T: View>(titleView: @escaping (User?, Group?) -> T) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.titleView = { user, group in
            AnyView(titleView(user, group))
        }
        return view
    }
    
    public func set<T: View>(subtitleView: @escaping (User?, Group?) -> T) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.subtitleView = { user, group in
            AnyView(subtitleView(user, group))
        }
        return view
    }
    
    public func set<T: View>(trailView: @escaping (User?, Group?) -> T) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.trailView = { user, group in
            AnyView(trailView(user, group))
        }
        return view
    }
    
    public func set<T: View>(auxiliaryView: @escaping (User?, Group?) -> T) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.auxiliaryView = { user, group in
            AnyView(auxiliaryView(user, group))
        }
        return view
    }
    
    public func set(onBack: @escaping () -> Void) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.onBack = onBack
        return view
    }
    
    public func set(onError: @escaping (CometChatException) -> Void) -> CometChatMessageHeaderSwiftUI {
        var view = self
        view.onError = onError
        return view
    }
}

extension CometChatMessageHeaderSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatMessageHeaderSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatMessageHeaderSwiftUI()
                .set(user: getMockUser())
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("User Header")
            
            CometChatMessageHeaderSwiftUI()
                .set(group: getMockGroup())
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Group Header")
            
            CometChatMessageHeaderSwiftUI(style: getCustomStyle())
                .set(user: getMockUser())
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Custom Style")
            
            CometChatMessageHeaderSwiftUI()
                .set(user: getMockUser())
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
    
    static func getMockUser() -> User {
        let user = User(uid: "user1", name: "John Doe")
        user.status = .online
        user.avatar = "https://example.com/avatar.jpg"
        user.lastActiveAt = Date().timeIntervalSince1970 - 3600 // 1 hour ago
        return user
    }
    
    static func getMockGroup() -> Group {
        let group = Group(guid: "group1", name: "Project Team", groupType: .public)
        group.membersCount = 12
        group.icon = "https://example.com/group.jpg"
        return group
    }
    
    static func getCustomStyle() -> MessageHeaderStyle {
        let style = MessageHeaderStyle()
        style.backgroundColor = CometChatTheme.palatte.accent100
        style.titleTextColor = CometChatTheme.palatte.accent900
        style.subtitleTextColor = CometChatTheme.palatte.accent600
        style.cornerRadius = CometChatCornerStyle(cornerRadius: 12)
        return style
    }
}
