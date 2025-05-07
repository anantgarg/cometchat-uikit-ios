//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatThreadedMessageHeaderSwiftUI: View {
    public static var style = ThreadedMessageHeaderStyle()
    
    private var style: ThreadedMessageHeaderStyle
    private var messageAlignment: MessageListAlignment = .standard
    private var hideReceipt: Bool = false
    private var hideBubbleHeader: Bool = false
    private var messageBubbleStyle = CometChatMessageBubble.style
    private var maxHeight: CGFloat = 250
    private var hideReplyCount: Bool = false
    private var hideReplyCountBar: Bool = false
    private var hideAvatar: Bool?
    private var singleNewMessageText: String = "ONE_REPLY".localize()
    private var multipleNewMessageText: String = "REPLIES".localize()
    private var controller: UIViewController?
    
    private var bubbleView: ((BaseMessage, MessageBubbleAlignment, UIViewController?) -> AnyView)?
    private var contentView: ((BaseMessage, MessageBubbleAlignment, UIViewController?) -> AnyView)?
    private var headerView: ((BaseMessage, MessageBubbleAlignment, UIViewController?) -> AnyView)?
    private var footerView: ((BaseMessage, MessageBubbleAlignment, UIViewController?) -> AnyView)?
    private var bottomView: ((BaseMessage, MessageBubbleAlignment, UIViewController?) -> AnyView)?
    private var statusInfoView: ((BaseMessage, MessageBubbleAlignment, UIViewController?) -> AnyView)?
    
    public static var dateTimeFormatter: CometChatDateTimeFormatter = CometChatUIKit.dateTimeFormatter
    private var dateTimeFormatter: CometChatDateTimeFormatter = CometChatThreadedMessageHeaderSwiftUI.dateTimeFormatter
    
    @StateObject private var viewModel = ThreadedMessageHeaderViewModelSwiftUI()
    
    public init(style: ThreadedMessageHeaderStyle = CometChatThreadedMessageHeaderSwiftUI.style) {
        self.style = style
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    if let message = viewModel.parentMessage {
                        messageBubbleView(for: message)
                            .padding(.vertical, CometChatSpacing.Padding.p2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxHeight: maxHeight)
            .background(Color(style.bubbleContainerBackgroundColor))
            .cornerRadius(style.bubbleContainerCornerRadius?.cornerRadius ?? 0)
            .overlay(
                RoundedRectangle(cornerRadius: style.bubbleContainerCornerRadius?.cornerRadius ?? 0)
                    .stroke(Color(style.bubbleContainerBorderColor), lineWidth: style.bubbleContainerBorderWidth)
            )
            
            if !hideReplyCountBar {
                HStack {
                    if !hideReplyCount {
                        Text(getReplyCountText())
                            .font(Font(style.countTextFont))
                            .foregroundColor(Color(style.countTextColor))
                    }
                    Spacer()
                }
                .padding(.horizontal, CometChatSpacing.Padding.p5)
                .padding(.vertical, CometChatSpacing.Padding.p1)
                .background(Color(style.dividerTintColor))
            }
        }
        .background(Color(style.backgroundColor))
        .cornerRadius(style.cornerRadius?.cornerRadius ?? 0)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius?.cornerRadius ?? 0)
                .stroke(Color(style.borderColor), lineWidth: style.borderWith)
        )
        .onAppear {
            viewModel.connect()
            if let message = viewModel.parentMessage {
                viewModel.setReplyCount(message.replyCount)
            }
        }
        .onDisappear {
            viewModel.disconnect()
        }
    }
    
    private func messageBubbleView(for message: BaseMessage) -> some View {
        Group {
            if let customBubbleView = bubbleView?(message, getBubbleAlignment(for: message), controller) {
                customBubbleView
            } else {
                CometChatMessageBubbleSwiftUI(style: messageBubbleStyle)
                    .set(message: message)
                    .set(alignment: getBubbleAlignment(for: message))
                    .set(hideAvatar: shouldHideAvatar(for: message))
                    .set(hideReceipt: hideReceipt)
                    .set(hideBubbleHeader: hideBubbleHeader)
                    .set(dateTimeFormatter: dateTimeFormatter)
                    .set(contentView: contentView)
                    .set(headerView: headerView)
                    .set(footerView: footerView)
                    .set(bottomView: bottomView)
                    .set(statusInfoView: statusInfoView)
            }
        }
    }
    
    private func getReplyCountText() -> String {
        let count = viewModel.replyCount
        return count == 1 ? singleNewMessageText : "\(count) \(multipleNewMessageText)"
    }
    
    private func getBubbleAlignment(for message: BaseMessage) -> MessageBubbleAlignment {
        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)
        
        switch messageAlignment {
        case .standard:
            return isLoggedInUser ? .right : .left
        case .leftAligned:
            return .left
        }
    }
    
    private func shouldHideAvatar(for message: BaseMessage) -> Bool {
        if let hideAvatar = hideAvatar {
            return hideAvatar
        }
        
        let alignment = getBubbleAlignment(for: message)
        if alignment == .right {
            return true
        }
        
        return message.receiverType == .user
    }
    
    public func set(message: BaseMessage) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.viewModel.parentMessage = message
        view.viewModel.setReplyCount(message.replyCount)
        return view
    }
    
    public func set(style: ThreadedMessageHeaderStyle) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.style = style
        return view
    }
    
    public func set(messageBubbleStyle: MessageBubbleStyle) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.messageBubbleStyle = messageBubbleStyle
        return view
    }
    
    public func set(messageAlignment: MessageListAlignment) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.messageAlignment = messageAlignment
        return view
    }
    
    public func set(hideReceipt: Bool) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.hideReceipt = hideReceipt
        return view
    }
    
    public func set(hideBubbleHeader: Bool) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.hideBubbleHeader = hideBubbleHeader
        return view
    }
    
    public func set(maxHeight: CGFloat) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.maxHeight = maxHeight
        return view
    }
    
    public func set(hideReplyCount: Bool) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.hideReplyCount = hideReplyCount
        return view
    }
    
    public func set(hideReplyCountBar: Bool) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.hideReplyCountBar = hideReplyCountBar
        return view
    }
    
    public func set(hideAvatar: Bool) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.hideAvatar = hideAvatar
        return view
    }
    
    public func set(singleNewMessageText: String) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.singleNewMessageText = singleNewMessageText
        return view
    }
    
    public func set(multipleNewMessageText: String) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.multipleNewMessageText = multipleNewMessageText
        return view
    }
    
    public func set(controller: UIViewController) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.controller = controller
        return view
    }
    
    public func set(dateTimeFormatter: CometChatDateTimeFormatter) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.dateTimeFormatter = dateTimeFormatter
        return view
    }
    
    public func set<T: View>(bubbleView: @escaping (BaseMessage, MessageBubbleAlignment, UIViewController?) -> T) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.bubbleView = { message, alignment, controller in
            AnyView(bubbleView(message, alignment, controller))
        }
        return view
    }
    
    public func set<T: View>(contentView: @escaping (BaseMessage, MessageBubbleAlignment, UIViewController?) -> T) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.contentView = { message, alignment, controller in
            AnyView(contentView(message, alignment, controller))
        }
        return view
    }
    
    public func set<T: View>(headerView: @escaping (BaseMessage, MessageBubbleAlignment, UIViewController?) -> T) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.headerView = { message, alignment, controller in
            AnyView(headerView(message, alignment, controller))
        }
        return view
    }
    
    public func set<T: View>(footerView: @escaping (BaseMessage, MessageBubbleAlignment, UIViewController?) -> T) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.footerView = { message, alignment, controller in
            AnyView(footerView(message, alignment, controller))
        }
        return view
    }
    
    public func set<T: View>(bottomView: @escaping (BaseMessage, MessageBubbleAlignment, UIViewController?) -> T) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.bottomView = { message, alignment, controller in
            AnyView(bottomView(message, alignment, controller))
        }
        return view
    }
    
    public func set<T: View>(statusInfoView: @escaping (BaseMessage, MessageBubbleAlignment, UIViewController?) -> T) -> CometChatThreadedMessageHeaderSwiftUI {
        var view = self
        view.statusInfoView = { message, alignment, controller in
            AnyView(statusInfoView(message, alignment, controller))
        }
        return view
    }
}

extension CometChatThreadedMessageHeaderSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatThreadedMessageHeaderSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatThreadedMessageHeaderSwiftUI()
                .set(message: getMockUserMessage())
                .previewDisplayName("User Message")
            
            CometChatThreadedMessageHeaderSwiftUI()
                .set(message: getMockGroupMessage())
                .previewDisplayName("Group Message")
            
            CometChatThreadedMessageHeaderSwiftUI(style: getCustomStyle())
                .set(message: getMockUserMessage())
                .previewDisplayName("Custom Style")
            
            CometChatThreadedMessageHeaderSwiftUI()
                .set(message: getMockUserMessage())
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
        .previewLayout(.fixed(width: 375, height: 300))
    }
    
    static func getMockUserMessage() -> BaseMessage {
        let textMessage = TextMessage(receiverUid: "user1", text: "Hello, how are you?", receiverType: .user)
        textMessage.id = 123456
        textMessage.sender = User(uid: "sender1", name: "John Doe")
        textMessage.receiver = User(uid: "user1", name: "Jane Smith")
        textMessage.replyCount = 3
        return textMessage
    }
    
    static func getMockGroupMessage() -> BaseMessage {
        let textMessage = TextMessage(receiverUid: "group1", text: "Hello everyone!", receiverType: .group)
        textMessage.id = 789012
        textMessage.sender = User(uid: "sender1", name: "John Doe")
        
        let group = Group(guid: "group1", name: "Project Team", groupType: .public)
        group.membersCount = 12
        textMessage.receiver = group
        textMessage.replyCount = 5
        
        return textMessage
    }
    
    static func getCustomStyle() -> ThreadedMessageHeaderStyle {
        let style = ThreadedMessageHeaderStyle()
        style.backgroundColor = CometChatTheme.palatte.accent100
        style.countTextColor = CometChatTheme.palatte.accent900
        style.dividerTintColor = CometChatTheme.palatte.accent200
        style.bubbleContainerBackgroundColor = CometChatTheme.palatte.accent50
        return style
    }
}
