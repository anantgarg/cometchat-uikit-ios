//
//
//

import SwiftUI
import CometChatSDK
import CometChatUIKitSwift.Components.Shared.Constants

public struct AIAssistViewSwiftUI: View {
    @StateObject private var viewModel = AIAssistViewModelSwiftUI()
    @Environment(\.presentationMode) private var presentationMode
    @State private var scrollToBottom = false
    
    private var titleMain: String?
    private var closeIconName = "xmark"
    private var configuration = AIAssistBotConfiguration()
    private var onSendButtonClick: ((BaseMessage) -> Void)?
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            headerView
                .frame(height: LayoutMetrics.avatarLarge + LayoutMetrics.spacingStandard)
                .background(Color(CometChatTheme_v4.palatte.background))
            
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(spacing: LayoutMetrics.spacingStandard) {
                        ForEach(viewModel.messageDataSource, id: \.id) { message in
                            messageBubbleView(for: message)
                                .id(message.id)
                        }
                        
                        Color.clear
                            .frame(height: LayoutMetrics.dividerHeight)
                            .id("bottomAnchor")
                    }
                    .padding(.horizontal, LayoutMetrics.spacingStandard)
                    .padding(.vertical, LayoutMetrics.spacingSmall)
                }
                .onChange(of: viewModel.messageDataSource.count) { _ in
                    scrollToBottom = true
                }
                .onChange(of: scrollToBottom) { newValue in
                    if newValue {
                        withAnimation {
                            scrollView.scrollTo("bottomAnchor", anchor: .bottom)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            scrollToBottom = false
                        }
                    }
                }
            }
            .background(Color(CometChatTheme_v4.palatte.background))
            
            Divider()
                .background(Color(configuration.messageInputStyle?.dividerColor ?? CometChatTheme_v4.palatte.accent500))
            
            AIMessageComposerSwiftUI()
                .set(user: viewModel.bot)
                .set(onMessageSent: { message in
                    if let textMessage = message as? TextMessage {
                        viewModel.add(message: textMessage)
                        onSendButtonClick?(message)
                    }
                })
                .set(messageInputStyle: configuration.messageInputStyle ?? MessageInputStyle())
                .padding(.bottom, viewModel.isKeyboardVisible ? viewModel.keyboardHeight - 30 : 30)
                .animation(.easeInOut, value: viewModel.isKeyboardVisible)
        }
        .background(Color(CometChatTheme_v4.palatte.background))
        .edgesIgnoringSafeArea(.bottom)
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 10) {
            CometChatAvatarSwiftUI()
                .set(user: viewModel.bot)
                .set(width: 35)
                .set(height: 35)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(titleMain ?? viewModel.bot?.name ?? "")
                    .font(Font(configuration.style?.titleFont ?? CometChatTheme_v4.typography.name))
                    .foregroundColor(Color(configuration.style?.titleColor ?? CometChatTheme_v4.palatte.accent))
                
                Text(configuration.subtitle ?? "AI_BOT".localize())
                    .font(Font(configuration.style?.subtitleFont ?? CometChatTheme_v4.typography.subtitle2))
                    .foregroundColor(Color(configuration.style?.subtitleColor ?? CometChatTheme_v4.palatte.accent500))
            }
            
            Spacer()
            
            Button(action: {
                hideKeyboard()
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: closeIconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: LayoutMetrics.largeIconSize, height: LayoutMetrics.largeIconSize)
                    .foregroundColor(Color(configuration.style?.closeIconTint ?? CometChatTheme_v4.palatte.accent))
            }
            .frame(width: LayoutMetrics.avatarSmall, height: LayoutMetrics.avatarSmall)
        }
        .padding(.horizontal, LayoutMetrics.spacingStandard)
    }
    
    private func messageBubbleView(for message: TextMessage) -> some View {
        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)
        let alignment: HorizontalAlignment = isLoggedInUser ? .trailing : .leading
        let bubbleAlignment: MessageBubbleAlignment = isLoggedInUser ? .right : .left
        
        return HStack {
            if isLoggedInUser { Spacer() }
            
            VStack(alignment: alignment) {
                HStack {
                    if !isLoggedInUser && !message.hideAvatar {
                        CometChatAvatarSwiftUI()
                            .set(user: message.sender)
                            .set(width: LayoutMetrics.avatarSmall)
                            .set(height: LayoutMetrics.avatarSmall)
                    }
                    
                    VStack(alignment: alignment) {
                        Text(message.text)
                            .font(Font(getBubbleStyle(isLoggedInUser: isLoggedInUser).textFont))
                            .foregroundColor(Color(getBubbleStyle(isLoggedInUser: isLoggedInUser).textColor))
                            .padding(.horizontal, LayoutMetrics.spacingMedium)
                            .padding(.vertical, LayoutMetrics.spacingStandard)
                            .background(
                                RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusMedium)
                                    .fill(getBubbleBackgroundColor(isLoggedInUser: isLoggedInUser))
                            )
                        
                        HStack(spacing: 4) {
                            Text(formatTimestamp(message.sentAt))
                                .font(.caption2)
                                .foregroundColor(Color(CometChatTheme_v4.palatte.accent500))
                            
                            if (message.metaData?["error"] as? Bool) == true {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.caption2)
                            }
                            
                            if (message.metaData?["isProcessing"] as? Bool) == true {
                                ProgressView()
                                    .scaleEffect(0.5)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
            
            if !isLoggedInUser { Spacer() }
        }
    }
    
    private func getBubbleStyle(isLoggedInUser: Bool) -> TextBubbleStyle {
        if isLoggedInUser, let senderStyle = configuration.senderMessageBubbleStyle {
            return senderStyle
        } else if let botStyle = configuration.botMessageBubbleStyle {
            return botStyle
        } else {
            let style = TextBubbleStyle()
            style.textFont = CometChatTheme_v4.typography.text1
            style.textColor = isLoggedInUser ? .white : CometChatTheme_v4.palatte.accent
            return style
        }
    }
    
    private func getBubbleBackgroundColor(isLoggedInUser: Bool) -> Color {
        if isLoggedInUser {
            return Color(CometChatTheme_v4.palatte.primary)
        } else {
            return Color(CometChatTheme_v4.palatte.secondary)
        }
    }
    
    private func formatTimestamp(_ timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func hideKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
    
    public func set(title: String) -> AIAssistViewSwiftUI {
        var view = self
        view.titleMain = title
        return view
    }
    
    public func set(closeIconName: String) -> AIAssistViewSwiftUI {
        var view = self
        view.closeIconName = closeIconName
        return view
    }
    
    public func set(bot: User?) -> AIAssistViewSwiftUI {
        var view = self
        view.viewModel.set(bot: bot)
        return view
    }
    
    public func set(configuration: AIAssistBotConfiguration?) -> AIAssistViewSwiftUI {
        var view = self
        if let configuration = configuration {
            view.configuration = configuration
            view.viewModel.set(configuration: configuration)
        }
        return view
    }
    
    public func set(onMessageSent: ((BaseMessage) -> Void)?) -> AIAssistViewSwiftUI {
        var view = self
        view.onSendButtonClick = onMessageSent
        return view
    }
    
    public func add(message: TextMessage) -> AIAssistViewSwiftUI {
        var view = self
        view.viewModel.add(message: message)
        return view
    }
    
    public func update(message: TextMessage) -> AIAssistViewSwiftUI {
        var view = self
        view.viewModel.update(message: message)
        return view
    }
}

extension AIAssistViewSwiftUI {
    public func toUIKit() -> UIViewController {
        let hostingController = UIHostingController(rootView: self)
        return hostingController
    }
}

struct AIAssistViewSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AIAssistViewSwiftUI()
                .set(bot: getMockBot())
                .set(title: "AI Assistant")
                .previewDisplayName("Default (Light)")
            
            AIAssistViewSwiftUI()
                .set(bot: getMockBot())
                .set(title: "AI Assistant")
                .preferredColorScheme(.dark)
                .previewDisplayName("Default (Dark)")
            
            AIAssistViewSwiftUI()
                .set(bot: getMockBot())
                .set(title: "AI Assistant")
                .add(message: getMockUserMessage())
                .add(message: getMockBotMessage())
                .previewDisplayName("With Messages (Light)")
            
            AIAssistViewSwiftUI()
                .set(bot: getMockBot())
                .set(title: "AI Assistant")
                .add(message: getMockUserMessage())
                .add(message: getMockBotMessage())
                .preferredColorScheme(.dark)
                .previewDisplayName("With Messages (Dark)")
        }
    }
    
    static func getMockBot() -> User {
        let bot = User(uid: "ai-assistant", name: "AI Assistant")
        bot.avatar = "https://example.com/avatar.png"
        return bot
    }
    
    static func getMockUserMessage() -> TextMessage {
        let message = TextMessage(receiverUid: "ai-assistant", text: "Hello, can you help me with something?", receiverType: .user)
        message.sender = User(uid: "user1", name: "John Doe")
        message.senderUid = "user1"
        message.sentAt = Date().timeIntervalSince1970 - 300
        return message
    }
    
    static func getMockBotMessage() -> TextMessage {
        let message = TextMessage(receiverUid: "user1", text: "Hi there! I'm your AI assistant. How can I help you today?", receiverType: .user)
        message.sender = User(uid: "ai-assistant", name: "AI Assistant")
        message.senderUid = "ai-assistant"
        message.sentAt = Date().timeIntervalSince1970 - 270
        return message
    }
}
