//
//
//

import CometChatSDK
import CometChatUIKitSwift.Components.Shared.Constants
import SwiftUI

public struct CometChatMessageListSwiftUI: View {
    @ObservedObject private var viewModel: MessageListViewModelSwiftUI
    private var style: MessageListStyle

    private var hideHeaderView: Bool = false
    private var hideBubbleHeader: Bool = false
    private var hideFooterView: Bool = false
    private var hideDateSeparator: Bool = false
    private var scrollToBottomOnNewMessages: Bool = false
    private var hideReceipts: Bool = false
    private var disableSoundForMessages: Bool = false
    private var hideEmptyView: Bool = true
    private var hideErrorView: Bool = false
    private var hideLoadingView: Bool = false
    private var hideNewMessageIndicator: Bool = false
    private var messageAlignment: MessageListAlignment = .standard

    private var headerView: AnyView?
    private var footerView: AnyView?

    @State private var showNewMessageIndicator: Bool = false
    @State private var newMessageCount: Int = 0
    @State private var isScrolling: Bool = false
    @State private var isLoadingMore: Bool = false
    @State private var selectedMessage: BaseMessage?
    @State private var showContextMenu: Bool = false

    public init(style: MessageListStyle = CometChatMessageList.style) {
        self.style = style
        _viewModel = ObservedObject(wrappedValue: MessageListViewModelSwiftUI())
    }

    public var body: some View {
        ZStack {
            if let backgroundImage = style.backgroundImage {
                Image(uiImage: backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            } else {
                Color(style.backgroundColor)
                    .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                if !hideHeaderView, let headerView {
                    headerView
                }

                if viewModel.isLoading, viewModel.messages.isEmpty {
                    loadingView
                } else if viewModel.hasError {
                    errorView
                } else if viewModel.messages.isEmpty {
                    emptyView
                } else {
                    messageListView
                }

                if !hideFooterView, let footerView {
                    footerView
                }
            }

            if showNewMessageIndicator, !hideNewMessageIndicator {
                newMessageIndicatorView
            }
        }
        .onAppear {
            viewModel.connect()
            if !viewModel.hasFetchedMessagesBefore {
                viewModel.fetchPreviousMessages()
            }
        }
        .onDisappear {
            viewModel.disconnect()
        }
    }

    private var messageListView: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    if !viewModel.isAllMessagesFetchedInPrevious {
                        loadMoreIndicator
                            .onAppear {
                                if !isLoadingMore {
                                    isLoadingMore = true
                                    viewModel.fetchPreviousMessages()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        isLoadingMore = false
                                    }
                                }
                            }
                    }

                    ForEach(viewModel.messages, id: \.date) { section in
                        if !hideDateSeparator {
                            dateSeparatorView(for: section.date)
                        }

                        ForEach(section.messages, id: \.id) { message in
                            messageBubbleView(for: message)
                                .id(message.id)
                                .contextMenu {
                                    contextMenuItems(for: message)
                                }
                        }
                    }
                }
                .padding(.vertical, LayoutMetrics.spacingStandard)
            }
            .onChange(of: viewModel.messages) { newMessages in
                if scrollToBottomOnNewMessages, !newMessages.isEmpty {
                    if let lastSection = newMessages.first, !lastSection.messages.isEmpty {
                        withAnimation {
                            scrollProxy.scrollTo(lastSection.messages.first?.id, anchor: .top)
                        }
                    }
                }
            }
            .onChange(of: viewModel.newMessageReceived) { _ in
                if !scrollToBottomOnNewMessages {
                    newMessageCount += 1
                    showNewMessageIndicator = true
                }
            }
        }
    }

    private var loadMoreIndicator: some View {
        HStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            Spacer()
        }
        .padding()
    }

    private func dateSeparatorView(for date: Date) -> some View {
        HStack {
            Spacer()
            CometChatDateSwiftUI(style: CometChatMessageList.dateSeparatorStyle)
                .set(pattern: .dayDate)
                .set(timestamp: Int(date.timeIntervalSince1970))
            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func messageBubbleView(for message: BaseMessage) -> some View {
        Group {
            if let template = viewModel.getTemplate(for: message) {
                messageBubbleWithTemplate(message: message, template: template)
            } else {
                defaultMessageBubble(for: message)
            }
        }
        .padding(.horizontal, LayoutMetrics.spacingStandard)
        .padding(.vertical, LayoutMetrics.spacingSmall)
    }

    private func messageBubbleWithTemplate(message: BaseMessage, template: CometChatMessageTemplate) -> some View {
        let alignment: MessageBubbleAlignment = messageAlignment == .standard ?
            (message.sender?.uid == CometChat.getLoggedInUser()?.uid ? .right : .left) : .left

        return CometChatMessageBubbleSwiftUI()
            .set(bubbleAlignment: alignment)
            .set(message: message)
            .set(avatarURL: message.sender?.avatar, avatarName: message.sender?.name)
            .set(style: style.messageBubbleStyle, specificMessageTypeStyle: template.style)
            .set(contentView:
                AnyView(
                    template.contentView(message: message)
                )
            )
            .onLongPress {
                selectedMessage = message
                showContextMenu = true
            }
    }

    private func defaultMessageBubble(for message: BaseMessage) -> some View {
        let alignment: MessageBubbleAlignment = messageAlignment == .standard ?
            (message.sender?.uid == CometChat.getLoggedInUser()?.uid ? .right : .left) : .left

        return CometChatMessageBubbleSwiftUI()
            .set(bubbleAlignment: alignment)
            .set(message: message)
            .set(avatarURL: message.sender?.avatar, avatarName: message.sender?.name)
            .set(contentView:
                AnyView(
                    CometChatTextBubbleSwiftUI()
                        .set(text: message.rawData?["text"] as? String ?? "")
                )
            )
            .onLongPress {
                selectedMessage = message
                showContextMenu = true
            }
    }

    private func contextMenuItems(for message: BaseMessage) -> some View {
        Group {
            if !viewModel.hideReplyInThreadOption, message.parentMessageId == 0 {
                Button(action: {
                    viewModel.onThreadRepliesClick?(message)
                }) {
                    Label("Reply in Thread", systemImage: "arrowshape.turn.up.left")
                }
            }

            if !viewModel.hideCopyMessageOption {
                Button(action: {
                    viewModel.copyMessage(message)
                }) {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }

            if !viewModel.hideEditMessageOption, message.sender?.uid == CometChat.getLoggedInUser()?.uid {
                Button(action: {
                    viewModel.editMessage(message)
                }) {
                    Label("Edit", systemImage: "pencil")
                }
            }

            if !viewModel.hideDeleteMessageOption {
                Button(action: {
                    viewModel.deleteMessage(message)
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }

    private var newMessageIndicatorView: some View {
        Button(action: {
            showNewMessageIndicator = false
            newMessageCount = 0
        }) {
            HStack {
                Text("\(newMessageCount) new message\(newMessageCount > 1 ? "s" : "")")
                    .font(.caption)
                    .foregroundColor(.white)

                Image(systemName: "chevron.down")
                    .foregroundColor(.white)
            }
            .padding(.horizontal, LayoutMetrics.spacingMedium)
            .padding(.vertical, LayoutMetrics.spacingStandard)
            .background(Color.blue)
            .cornerRadius(LayoutMetrics.cornerRadiusRound)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(.bottom, LayoutMetrics.messageIndicatorBottomOffset)
        .padding(.trailing, LayoutMetrics.messageIndicatorTrailingOffset)
        .transition(.opacity)
        .animation(.easeInOut, value: showNewMessageIndicator)
    }

    private var loadingView: some View {
        VStack {
            ForEach(0 ..< LayoutMetrics.loadingItemCount, id: \.self) { _ in
                HStack(alignment: .top) {
                    Circle()
                        .fill(Color(style.shimmerGradientColor1))
                        .frame(width: LayoutMetrics.avatarMedium, height: LayoutMetrics.avatarMedium)

                    VStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(style.shimmerGradientColor1))
                            .frame(height: LayoutMetrics.loadingTextHeight)
                            .frame(width: LayoutMetrics.loadingTextWidth)

                        Rectangle()
                            .fill(Color(style.shimmerGradientColor1))
                            .frame(height: LayoutMetrics.loadingContentHeight)
                            .frame(width: LayoutMetrics.loadingContentWidth)
                    }

                    Spacer()
                }
                .padding()
                .redacted(reason: .placeholder)
                .shimmering()
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            if let emptyImage = style.emptyImage {
                Image(uiImage: emptyImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: LayoutMetrics.largeIconSize * 4, height: LayoutMetrics.largeIconSize * 4)
            }

            Text("NO_CONVERSATIONS_YET".localize())
                .font(.headline)
                .foregroundColor(Color(style.emptyStateTitleColor))
                .multilineTextAlignment(.center)

            Text("START_A_NEW_CHAT_OR_INVITE_OTHERS_TO_JOIN_THE_CONVERSATION.".localize())
                .font(.subheadline)
                .foregroundColor(Color(style.emptyStateSubtitleColor))
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            if let errorImage = style.errorImage {
                Image(uiImage: errorImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: LayoutMetrics.largeIconSize * 4, height: LayoutMetrics.largeIconSize * 4)
            }

            Text("OOPS!".localize())
                .font(.headline)
                .foregroundColor(Color(style.errorStateTitleColor))
                .multilineTextAlignment(.center)

            Text("LOOKS_LIKE_SOMETHINGS_WENT_WORNG._PLEASE_TRY_AGAIN".localize())
                .font(.subheadline)
                .foregroundColor(Color(style.errorStateSubtitleColor))
                .multilineTextAlignment(.center)

            Button(action: {
                viewModel.fetchPreviousMessages()
            }) {
                Text("Try Again")
                    .foregroundColor(.white)
                    .padding(.horizontal, LayoutMetrics.spacingLarge)
                    .padding(.vertical, LayoutMetrics.spacingStandard)
                    .background(Color.blue)
                    .cornerRadius(LayoutMetrics.cornerRadiusStandard)
            }
        }
        .padding()
    }

    public func set(user: User, messagesRequestBuilder: MessagesRequest.MessageRequestBuilder? = nil) -> Self {
        var view = self
        view.viewModel.set(user: user, messagesRequestBuilder: messagesRequestBuilder)
        return view
    }

    public func set(group: Group, messagesRequestBuilder: MessagesRequest.MessageRequestBuilder? = nil) -> Self {
        var view = self
        view.viewModel.set(group: group, messagesRequestBuilder: messagesRequestBuilder)
        return view
    }

    public func set(parentMessage: BaseMessage) -> Self {
        var view = self
        view.viewModel.parentMessage = parentMessage
        return view
    }

    public func set(messagesRequestBuilder: MessagesRequest.MessageRequestBuilder) -> Self {
        var view = self
        view.viewModel.set(messagesRequestBuilder: messagesRequestBuilder)
        return view
    }

    public func hide(headerView: Bool) -> Self {
        var view = self
        view.hideHeaderView = headerView
        return view
    }

    public func hide(footerView: Bool) -> Self {
        var view = self
        view.hideFooterView = footerView
        return view
    }

    public func hide(bubbleHeader: Bool) -> Self {
        var view = self
        view.hideBubbleHeader = bubbleHeader
        return view
    }

    public func hide(dateSeparator: Bool) -> Self {
        var view = self
        view.hideDateSeparator = dateSeparator
        return view
    }

    public func hide(receipts: Bool) -> Self {
        var view = self
        view.hideReceipts = receipts
        return view
    }

    public func hide(newMessageIndicator: Bool) -> Self {
        var view = self
        view.hideNewMessageIndicator = newMessageIndicator
        return view
    }

    public func disable(soundForMessages: Bool) -> Self {
        var view = self
        view.disableSoundForMessages = soundForMessages
        return view
    }

    public func scrollToBottom(onNewMessages: Bool) -> Self {
        var view = self
        view.scrollToBottomOnNewMessages = onNewMessages
        return view
    }

    public func set(messageAlignment: MessageListAlignment) -> Self {
        var view = self
        view.messageAlignment = messageAlignment
        return view
    }

    public func set(headerView: some View) -> Self {
        var view = self
        view.headerView = AnyView(headerView)
        return view
    }

    public func set(footerView: some View) -> Self {
        var view = self
        view.footerView = AnyView(footerView)
        return view
    }

    public func onError(_ action: @escaping (CometChatException) -> Void) -> Self {
        var view = self
        view.viewModel.onError = action
        return view
    }

    public func onEmpty(_ action: @escaping () -> Void) -> Self {
        var view = self
        view.viewModel.onEmpty = action
        return view
    }

    public func onLoad(_ action: @escaping ([BaseMessage]) -> Void) -> Self {
        var view = self
        view.viewModel.onLoad = action
        return view
    }

    public func onThreadRepliesClick(_ action: @escaping (BaseMessage, CometChatMessageTemplate) -> Void) -> Self {
        var view = self
        view.viewModel.onThreadRepliesClick = action
        return view
    }
}

public extension CometChatMessageListSwiftUI {
    func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

extension View {
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { _ in
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: phase - 0.2),
                            .init(color: .white.opacity(0.3), location: phase),
                            .init(color: .clear, location: phase + 0.2),
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .mask(content)
                    .blendMode(.screen)
                }
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

struct CometChatMessageListSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatMessageListSwiftUI()
                .previewDisplayName("Default (Light)")

            CometChatMessageListSwiftUI()
                .hide(headerView: true)
                .hide(footerView: true)
                .previewDisplayName("No Header/Footer (Light)")

            CometChatMessageListSwiftUI()
                .preferredColorScheme(.dark)
                .previewDisplayName("Default (Dark)")
        }
    }
}
