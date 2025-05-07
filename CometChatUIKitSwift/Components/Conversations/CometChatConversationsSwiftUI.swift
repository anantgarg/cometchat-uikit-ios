//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatConversationsSwiftUI: View {
    public static var style = ConversationsStyle()
    public static var avatarStyle: AvatarStyle = CometChatAvatar.style
    public static var statusIndicatorStyle: StatusIndicatorStyle = CometChatStatusIndicator.style
    public static var receiptStyle: ReceiptStyle = {
        var defaultReceiptStyle = CometChatReceipt.style
        defaultReceiptStyle.deliveredImageTintColor = CometChatTheme.iconColorSecondary
        defaultReceiptStyle.sentImageTintColor = CometChatTheme.iconColorSecondary
        defaultReceiptStyle.waitImageTintColor = CometChatTheme.iconColorSecondary
        return defaultReceiptStyle
    }()
    public static var badgeStyle: BadgeStyle = CometChatBadge.style
    public static var dateStyle: DateStyle = CometChatDate.style
    public static var typingIndicatorStyle = CometChatTypingIndicator.style
    
    private var style: ConversationsStyle
    private var avatarStyle: AvatarStyle
    private var statusIndicatorStyle: StatusIndicatorStyle
    private var receiptStyle: ReceiptStyle
    private var badgeStyle: BadgeStyle
    private var dateStyle: DateStyle
    private var typingIndicatorStyle: CometChatTypingIndicator.TypingIndicatorStyle
    
    private var privateGroupIcon = UIImage(systemName: "shield.fill")?.withRenderingMode(.alwaysTemplate)
    private var protectedGroupIcon = UIImage(systemName: "lock.fill")?.withRenderingMode(.alwaysTemplate)
    
    private var disableTyping: Bool = false
    private var disableSoundForMessages: Bool = false
    private var customSoundForMessages: URL?
    
    private var dateTimeFormatter: CometChatDateTimeFormatter = CometChatUIKit.dateTimeFormatter
    
    private var selectionMode: SelectionMode = .none
    
    private var hideReceipts: Bool = false
    private var hideDeleteConversationOption: Bool = false
    private var hideUserStatus: Bool = false
    private var hideGroupType: Bool = false
    
    private var listItemView: ((Conversation) -> AnyView)?
    private var leadingView: ((Conversation) -> AnyView)?
    private var titleView: ((Conversation) -> AnyView)?
    private var subtitleView: ((Conversation) -> AnyView)?
    private var tailView: ((Conversation) -> AnyView)?
    private var emptyStateView: (() -> AnyView)?
    private var errorStateView: (() -> AnyView)?
    private var loadingStateView: (() -> AnyView)?
    
    private var onItemClick: ((Conversation) -> Void)?
    private var onItemLongClick: ((Conversation) -> Void)?
    private var onSelection: (([Conversation]) -> Void)?
    private var onError: ((CometChatException) -> Void)?
    private var datePattern: ((Conversation) -> String)?
    
    @StateObject private var viewModel = ConversationsViewModelSwiftUI()
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var conversationToDelete: Conversation?
    
    public init(style: ConversationsStyle = CometChatConversationsSwiftUI.style) {
        self.style = style
        self.avatarStyle = CometChatConversationsSwiftUI.avatarStyle
        self.statusIndicatorStyle = CometChatConversationsSwiftUI.statusIndicatorStyle
        self.receiptStyle = CometChatConversationsSwiftUI.receiptStyle
        self.badgeStyle = CometChatConversationsSwiftUI.badgeStyle
        self.dateStyle = CometChatConversationsSwiftUI.dateStyle
        self.typingIndicatorStyle = CometChatConversationsSwiftUI.typingIndicatorStyle
    }
    
    public var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.conversations.isEmpty {
                loadingView
            } else if viewModel.hasError && viewModel.conversations.isEmpty {
                errorView
            } else if viewModel.conversations.isEmpty {
                emptyView
            } else {
                conversationListView
            }
        }
        .background(Color(style.backgroundColor))
        .onAppear {
            viewModel.connect()
            viewModel.isRefresh = true
        }
        .onDisappear {
            viewModel.disconnect()
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("DELETE_CONVERSATION".localize()),
                message: Text("DELETE_CONVERSATION_MESSAGE".localize()),
                primaryButton: .destructive(Text("DELETE".localize())) {
                    if let conversation = conversationToDelete {
                        viewModel.delete(conversation: conversation)
                    }
                },
                secondaryButton: .cancel(Text("CANCEL".localize()))
            )
        }
    }
    
    private var conversationListView: some View {
        List {
            ForEach(viewModel.conversations, id: \.conversationId) { conversation in
                conversationItemView(for: conversation)
                    .onAppear {
                        if conversation == viewModel.conversations.last && !viewModel.isFetchedAll && !viewModel.isFetching {
                            viewModel.isRefresh = false
                            viewModel.fetchConversations()
                        }
                    }
            }
            .listRowBackground(Color(style.backgroundColor))
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .listStyle(PlainListStyle())
        .refreshable {
            viewModel.isRefresh = true
        }
    }
    
    private func conversationItemView(for conversation: Conversation) -> some View {
        if let customView = listItemView?(conversation) {
            return customView
                .onTapGesture {
                    handleItemClick(conversation)
                }
                .onLongPressGesture {
                    onItemLongClick?(conversation)
                }
                .eraseToAnyView()
        } else {
            return conversationDefaultView(for: conversation)
                .onTapGesture {
                    handleItemClick(conversation)
                }
                .onLongPressGesture {
                    onItemLongClick?(conversation)
                }
                .eraseToAnyView()
        }
    }
    
    private func conversationDefaultView(for conversation: Conversation) -> some View {
        HStack(spacing: 16) {
            if let leadingCustomView = leadingView?(conversation) {
                leadingCustomView
            } else {
                leadingDefaultView(for: conversation)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let titleCustomView = titleView?(conversation) {
                    titleCustomView
                } else {
                    titleDefaultView(for: conversation)
                }
                
                if let subtitleCustomView = subtitleView?(conversation) {
                    subtitleCustomView
                } else {
                    subtitleDefaultView(for: conversation)
                }
            }
            
            Spacer()
            
            if let tailCustomView = tailView?(conversation) {
                tailCustomView
            } else {
                tailDefaultView(for: conversation)
            }
        }
        .padding(.vertical, 8)
        .background(
            viewModel.selectedConversations.contains(conversation) ?
            Color(style.selectedBackgroundColor) :
            Color(style.backgroundColor)
        )
        .cornerRadius(style.cornerRadius)
        .contentShape(Rectangle())
        .contextMenu {
            if !hideDeleteConversationOption {
                Button(action: {
                    conversationToDelete = conversation
                    showDeleteConfirmation = true
                }) {
                    Label("DELETE".localize(), systemImage: "trash")
                }
            }
        }
    }
    
    private func leadingDefaultView(for conversation: Conversation) -> some View {
        ZStack {
            CometChatAvatarSwiftUI(style: avatarStyle)
                .set(width: 48)
                .set(height: 48)
                .set(cornerRadius: 24)
            
            switch conversation.conversationType {
            case .user:
                if let user = conversation.conversationWith as? User {
                    CometChatAvatarSwiftUI(style: avatarStyle)
                        .set(user: user)
                        .set(width: 48)
                        .set(height: 48)
                        .set(cornerRadius: 24)
                    
                    if !hideUserStatus && user.status == .online {
                        CometChatStatusIndicatorSwiftUI(style: statusIndicatorStyle)
                            .set(status: .online)
                            .offset(x: 16, y: 16)
                    }
                }
            case .group:
                if let group = conversation.conversationWith as? Group {
                    CometChatAvatarSwiftUI(style: avatarStyle)
                        .set(group: group)
                        .set(width: 48)
                        .set(height: 48)
                        .set(cornerRadius: 24)
                    
                    if !hideGroupType {
                        switch group.groupType {
                        case .private:
                            Image(uiImage: privateGroupIcon ?? UIImage())
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundColor(Color(style.privateGroupImageTintColor))
                                .background(Color(style.privateGroupImageBackgroundColor))
                                .clipShape(Circle())
                                .offset(x: 16, y: 16)
                        case .password:
                            Image(uiImage: protectedGroupIcon ?? UIImage())
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundColor(Color(style.privateGroupImageTintColor))
                                .background(Color(style.passwordGroupImageBackgroundColor))
                                .clipShape(Circle())
                                .offset(x: 16, y: 16)
                        default:
                            EmptyView()
                        }
                    }
                }
            default:
                EmptyView()
            }
        }
        .frame(width: 48, height: 48)
    }
    
    private func titleDefaultView(for conversation: Conversation) -> some View {
        switch conversation.conversationType {
        case .user:
            if let user = conversation.conversationWith as? User {
                return Text(user.name ?? "")
                    .font(Font(style.titleFont))
                    .foregroundColor(Color(style.titleColor))
                    .lineLimit(1)
                    .eraseToAnyView()
            }
        case .group:
            if let group = conversation.conversationWith as? Group {
                return Text(group.name ?? "")
                    .font(Font(style.titleFont))
                    .foregroundColor(Color(style.titleColor))
                    .lineLimit(1)
                    .eraseToAnyView()
            }
        default:
            break
        }
        return EmptyView().eraseToAnyView()
    }
    
    private func subtitleDefaultView(for conversation: Conversation) -> some View {
        if let lastMessage = conversation.lastMessage {
            return Text(MessageUtils.getLastMessageText(lastMessage: lastMessage))
                .font(Font(style.subtitleFont))
                .foregroundColor(Color(style.subtitleColor))
                .lineLimit(1)
                .eraseToAnyView()
        }
        return EmptyView().eraseToAnyView()
    }
    
    private func tailDefaultView(for conversation: Conversation) -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            if let lastMessage = conversation.lastMessage {
                Text(getFormattedDate(for: conversation))
                    .font(Font(dateStyle.textFont))
                    .foregroundColor(Color(dateStyle.textColor))
            }
            
            if conversation.unreadMessageCount > 0 {
                Text("\(conversation.unreadMessageCount)")
                    .font(Font(badgeStyle.textFont))
                    .foregroundColor(Color(badgeStyle.textColor))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(badgeStyle.backgroundColor))
                    .cornerRadius(badgeStyle.cornerRadius)
            }
        }
    }
    
    private var loadingView: some View {
        if let customLoadingView = loadingStateView?() {
            return customLoadingView
        } else {
            return VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("LOADING".localize())
                    .font(Font(style.emptyStateTextFont))
                    .foregroundColor(Color(style.emptyStateTextColor))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(style.backgroundColor))
            .eraseToAnyView()
        }
    }
    
    private var errorView: some View {
        if let customErrorView = errorStateView?() {
            return customErrorView
        } else {
            return VStack(spacing: 16) {
                Image(uiImage: UIImage(named: "error-icon", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                
                Text("OOPS!".localize())
                    .font(Font(style.errorStateTextFont))
                    .foregroundColor(Color(style.errorStateTextColor))
                
                Text("LOOKS_LIKE_SOMETHINGS_WENT_WORNG._PLEASE_TRY_AGAIN".localize())
                    .font(Font(style.errorStateTextFont))
                    .foregroundColor(Color(style.errorStateTextColor))
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    viewModel.isRefresh = true
                }) {
                    Text("TRY_AGAIN".localize())
                        .font(Font(style.errorStateButtonFont))
                        .foregroundColor(Color(style.errorStateButtonTextColor))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(style.errorStateButtonBackgroundColor))
                        .cornerRadius(8)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(style.backgroundColor))
            .eraseToAnyView()
        }
    }
    
    private var emptyView: some View {
        if let customEmptyView = emptyStateView?() {
            return customEmptyView
        } else {
            return VStack(spacing: 16) {
                Image(uiImage: UIImage(named: "empty-icon", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                
                Text("NO_CONVERSATIONS_YET".localize())
                    .font(Font(style.emptyStateTextFont))
                    .foregroundColor(Color(style.emptyStateTextColor))
                
                Text("START_A_NEW_CHAT_OR_INVITE_OTHERS_TO_JOIN_THE_CONVERSATION.".localize())
                    .font(Font(style.emptyStateTextFont))
                    .foregroundColor(Color(style.emptyStateTextColor))
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(style.backgroundColor))
            .eraseToAnyView()
        }
    }
    
    private func getFormattedDate(for conversation: Conversation) -> String {
        if let customPattern = datePattern?(conversation) {
            return customPattern
        }
        
        if let lastMessage = conversation.lastMessage {
            let dateTimeFormatterUtils = DateTimeFormatterUtils()
            let timestamp = Int(lastMessage.sentAt)
            
            if let formattedDate = dateTimeFormatterUtils.getFormattedDateFromClosures(timeStamp: timestamp, dateTimeFormatter: dateTimeFormatter) {
                return formattedDate
            } else {
                let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                return formatter.string(from: date)
            }
        }
        
        return ""
    }
    
    private func handleItemClick(_ conversation: Conversation) {
        if selectionMode == .none {
            onItemClick?(conversation)
        } else {
            if selectionMode == .single {
                viewModel.selectedConversations = [conversation]
            } else {
                if viewModel.selectedConversations.contains(conversation) {
                    viewModel.selectedConversations.removeAll { $0.conversationId == conversation.conversationId }
                } else {
                    viewModel.selectedConversations.append(conversation)
                }
            }
            onSelection?(viewModel.selectedConversations)
        }
    }
    
    public func set(style: ConversationsStyle) -> CometChatConversationsSwiftUI {
        var view = self
        view.style = style
        return view
    }
    
    public func set(avatarStyle: AvatarStyle) -> CometChatConversationsSwiftUI {
        var view = self
        view.avatarStyle = avatarStyle
        return view
    }
    
    public func set(statusIndicatorStyle: StatusIndicatorStyle) -> CometChatConversationsSwiftUI {
        var view = self
        view.statusIndicatorStyle = statusIndicatorStyle
        return view
    }
    
    public func set(receiptStyle: ReceiptStyle) -> CometChatConversationsSwiftUI {
        var view = self
        view.receiptStyle = receiptStyle
        return view
    }
    
    public func set(badgeStyle: BadgeStyle) -> CometChatConversationsSwiftUI {
        var view = self
        view.badgeStyle = badgeStyle
        return view
    }
    
    public func set(dateStyle: DateStyle) -> CometChatConversationsSwiftUI {
        var view = self
        view.dateStyle = dateStyle
        return view
    }
    
    public func set(typingIndicatorStyle: CometChatTypingIndicator.TypingIndicatorStyle) -> CometChatConversationsSwiftUI {
        var view = self
        view.typingIndicatorStyle = typingIndicatorStyle
        return view
    }
    
    public func set(privateGroupIcon: UIImage?) -> CometChatConversationsSwiftUI {
        var view = self
        view.privateGroupIcon = privateGroupIcon?.withRenderingMode(.alwaysTemplate)
        return view
    }
    
    public func set(protectedGroupIcon: UIImage?) -> CometChatConversationsSwiftUI {
        var view = self
        view.protectedGroupIcon = protectedGroupIcon?.withRenderingMode(.alwaysTemplate)
        return view
    }
    
    public func disable(typing: Bool) -> CometChatConversationsSwiftUI {
        var view = self
        view.disableTyping = typing
        return view
    }
    
    public func disable(soundForMessages: Bool) -> CometChatConversationsSwiftUI {
        var view = self
        view.disableSoundForMessages = soundForMessages
        return view
    }
    
    public func set(customSoundForMessages: URL?) -> CometChatConversationsSwiftUI {
        var view = self
        view.customSoundForMessages = customSoundForMessages
        return view
    }
    
    public func set(dateTimeFormatter: CometChatDateTimeFormatter) -> CometChatConversationsSwiftUI {
        var view = self
        view.dateTimeFormatter = dateTimeFormatter
        return view
    }
    
    public func set(selectionMode: SelectionMode) -> CometChatConversationsSwiftUI {
        var view = self
        view.selectionMode = selectionMode
        return view
    }
    
    public func hide(receipts: Bool) -> CometChatConversationsSwiftUI {
        var view = self
        view.hideReceipts = receipts
        return view
    }
    
    public func hide(deleteConversationOption: Bool) -> CometChatConversationsSwiftUI {
        var view = self
        view.hideDeleteConversationOption = deleteConversationOption
        return view
    }
    
    public func hide(userStatus: Bool) -> CometChatConversationsSwiftUI {
        var view = self
        view.hideUserStatus = userStatus
        return view
    }
    
    public func hide(groupType: Bool) -> CometChatConversationsSwiftUI {
        var view = self
        view.hideGroupType = groupType
        return view
    }
    
    public func set<T: View>(listItemView: @escaping (Conversation) -> T) -> CometChatConversationsSwiftUI {
        var view = self
        view.listItemView = { conversation in
            AnyView(listItemView(conversation))
        }
        return view
    }
    
    public func set<T: View>(leadingView: @escaping (Conversation) -> T) -> CometChatConversationsSwiftUI {
        var view = self
        view.leadingView = { conversation in
            AnyView(leadingView(conversation))
        }
        return view
    }
    
    public func set<T: View>(titleView: @escaping (Conversation) -> T) -> CometChatConversationsSwiftUI {
        var view = self
        view.titleView = { conversation in
            AnyView(titleView(conversation))
        }
        return view
    }
    
    public func set<T: View>(subtitleView: @escaping (Conversation) -> T) -> CometChatConversationsSwiftUI {
        var view = self
        view.subtitleView = { conversation in
            AnyView(subtitleView(conversation))
        }
        return view
    }
    
    public func set<T: View>(tailView: @escaping (Conversation) -> T) -> CometChatConversationsSwiftUI {
        var view = self
        view.tailView = { conversation in
            AnyView(tailView(conversation))
        }
        return view
    }
    
    public func set<T: View>(emptyStateView: @escaping () -> T) -> CometChatConversationsSwiftUI {
        var view = self
        view.emptyStateView = {
            AnyView(emptyStateView())
        }
        return view
    }
    
    public func set<T: View>(errorStateView: @escaping () -> T) -> CometChatConversationsSwiftUI {
        var view = self
        view.errorStateView = {
            AnyView(errorStateView())
        }
        return view
    }
    
    public func set<T: View>(loadingStateView: @escaping () -> T) -> CometChatConversationsSwiftUI {
        var view = self
        view.loadingStateView = {
            AnyView(loadingStateView())
        }
        return view
    }
    
    public func set(onItemClick: @escaping (Conversation) -> Void) -> CometChatConversationsSwiftUI {
        var view = self
        view.onItemClick = onItemClick
        return view
    }
    
    public func set(onItemLongClick: @escaping (Conversation) -> Void) -> CometChatConversationsSwiftUI {
        var view = self
        view.onItemLongClick = onItemLongClick
        return view
    }
    
    public func set(onSelection: @escaping ([Conversation]) -> Void) -> CometChatConversationsSwiftUI {
        var view = self
        view.onSelection = onSelection
        return view
    }
    
    public func set(onError: @escaping (CometChatException) -> Void) -> CometChatConversationsSwiftUI {
        var view = self
        view.onError = onError
        return view
    }
    
    public func set(datePattern: @escaping (Conversation) -> String) -> CometChatConversationsSwiftUI {
        var view = self
        view.datePattern = datePattern
        return view
    }
}

extension CometChatConversationsSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }
}

struct CometChatConversationsSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatConversationsSwiftUI()
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Default")
            
            CometChatConversationsSwiftUI()
                .set(selectionMode: .single)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Single Selection Mode")
            
            CometChatConversationsSwiftUI()
                .set(selectionMode: .multiple)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Multiple Selection Mode")
        }
    }
}
