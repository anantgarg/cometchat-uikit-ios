//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatMessageInformationSwiftUI: View {
    public static var style = MessageInformationStyle()
    public static var receiptStyle: ReceiptStyle = {
        var receiptStyle = CometChatReceipt.style
        receiptStyle.readImageTintColor = CometChatTheme.infoColor
        return receiptStyle
    }()
    
    private var style: MessageInformationStyle
    private var messageStyle: MessageBubbleStyle = CometChatMessageBubble.style.outgoing
    private var receiptStyle: ReceiptStyle
    private var dateTimeFormatter: CometChatDateTimeFormatter?
    
    private var bubbleView: ((BaseMessage) -> AnyView)?
    private var subtitleView: ((BaseMessage, MessageReceipt) -> AnyView)?
    private var listItemView: ((BaseMessage, MessageReceipt) -> AnyView)?
    
    private var onError: ((CometChatException) -> Void)?
    
    @StateObject private var viewModel = MessageInformationViewModelSwiftUI()
    @State private var bubbleSnapshotView: UIView?
    
    public init(style: MessageInformationStyle = CometChatMessageInformationSwiftUI.style) {
        self.style = style
        self.receiptStyle = CometChatMessageInformationSwiftUI.receiptStyle
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let message = viewModel.message {
                    if let customBubbleView = bubbleView?(message) {
                        customBubbleView
                            .padding()
                            .background(Color(style.bubbleContainerBackgroundColor))
                            .cornerRadius(style.bubbleContainerCornerRadius?.cornerRadius ?? 0)
                            .overlay(
                                RoundedRectangle(cornerRadius: style.bubbleContainerCornerRadius?.cornerRadius ?? 0)
                                    .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
                            )
                            .padding()
                    } else if let bubbleSnapshotView = bubbleSnapshotView {
                        BubbleSnapshotView(bubbleView: bubbleSnapshotView)
                            .padding()
                            .background(Color(style.bubbleContainerBackgroundColor))
                            .cornerRadius(style.bubbleContainerCornerRadius?.cornerRadius ?? 0)
                            .overlay(
                                RoundedRectangle(cornerRadius: style.bubbleContainerCornerRadius?.cornerRadius ?? 0)
                                    .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
                            )
                            .padding()
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if viewModel.hasError {
                    Text("SOMETHING_WENT_WRONG_WITH_NEW_LINE".localize())
                        .font(Font(style.errorStateTextFont))
                        .foregroundColor(Color(style.errorStateTextColor))
                        .padding()
                } else if viewModel.receipts.isEmpty {
                    Text("MESSAGE_INFORMATION_EMPTY_MESSAGE".localize())
                        .font(Font(style.emptyStateTextFont))
                        .foregroundColor(Color(style.emptyStateTextColor))
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.receipts, id: \.timeStamp) { receipt in
                            if let message = viewModel.message {
                                if let customListItemView = listItemView?(message, receipt) {
                                    customListItemView
                                } else {
                                    receiptRow(for: message, receipt: receipt)
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .background(Color(style.backgroundColor))
            .navigationBarTitle("MESSAGE_INFO".localize(), displayMode: .inline)
            .navigationBarColor(
                backgroundColor: style.navigationBarTintColor,
                titleColor: style.titleColor,
                tintColor: style.navigationBarItemsTintColor
            )
        }
        .onAppear {
            viewModel.connect()
            setupCallbacks()
            if let message = viewModel.message {
                viewModel.getMessageReceipt(information: message)
            }
        }
        .onDisappear {
            viewModel.disconnect()
        }
    }
    
    private func receiptRow(for message: BaseMessage, receipt: MessageReceipt) -> some View {
        HStack(spacing: 12) {
            if message.receiverType == .group {
                if let sender = receipt.sender {
                    CometChatAvatarSwiftUI()
                        .set(user: sender)
                        .set(width: 40)
                        .set(height: 40)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(sender.name ?? "")
                            .font(Font(style.titleFont))
                            .foregroundColor(Color(style.titleColor ?? .black))
                        
                        if let customSubtitleView = subtitleView?(message, receipt) {
                            customSubtitleView
                        } else {
                            VStack(alignment: .leading, spacing: 2) {
                                if receipt.receiptType == .read {
                                    Text("READ".localize())
                                        .font(Font(style.listItemSubTitleFont))
                                        .foregroundColor(Color(style.listItemSubTitleTextColor))
                                }
                                
                                Text("DELIVERED".localize())
                                    .font(Font(style.listItemSubTitleFont))
                                    .foregroundColor(Color(style.listItemSubTitleTextColor))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        if receipt.receiptType == .read {
                            Text(formatTimestamp(receipt.timeStamp))
                                .font(Font(style.listItemSubTitleFont))
                                .foregroundColor(Color(style.listItemSubTitleTextColor))
                        }
                        
                        Text(formatTimestamp(receipt.timeStamp))
                            .font(Font(style.listItemSubTitleFont))
                            .foregroundColor(Color(style.listItemSubTitleTextColor))
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(uiImage: receipt.receiptType == .delivered ? 
                              receiptStyle.deliveredImage.withTintColor(receiptStyle.deliveredImageTintColor) : 
                              receiptStyle.readImage.withTintColor(receiptStyle.readImageTintColor))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                        
                        Text(receipt.receiptType == .delivered ? "DELIVERED".localize() : "READ".localize())
                            .font(Font(style.titleFont))
                            .foregroundColor(Color(style.titleColor ?? .black))
                    }
                    
                    Text(formatTimestamp(receipt.timeStamp))
                        .font(Font(style.listItemSubTitleFont))
                        .foregroundColor(Color(style.listItemSubTitleTextColor))
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatTimestamp(_ timestamp: Int) -> String {
        return timestamp.getDateInString(dateTimeFormatter: dateTimeFormatter)
    }
    
    private func setupCallbacks() {
        viewModel.onError = { error in
            if let error = error, let onError = onError {
                onError(error)
            }
        }
    }
    
    public func set(message: BaseMessage) -> CometChatMessageInformationSwiftUI {
        var view = self
        view.viewModel.message = message
        return view
    }
    
    public func set(bubbleSnapshotView: UIView) -> CometChatMessageInformationSwiftUI {
        var view = self
        view.bubbleSnapshotView = bubbleSnapshotView
        return view
    }
    
    public func set(style: MessageInformationStyle) -> CometChatMessageInformationSwiftUI {
        var view = self
        view.style = style
        return view
    }
    
    public func set(messageStyle: MessageBubbleStyle) -> CometChatMessageInformationSwiftUI {
        var view = self
        view.messageStyle = messageStyle
        return view
    }
    
    public func set(receiptStyle: ReceiptStyle) -> CometChatMessageInformationSwiftUI {
        var view = self
        view.receiptStyle = receiptStyle
        return view
    }
    
    public func set(dateTimeFormatter: CometChatDateTimeFormatter) -> CometChatMessageInformationSwiftUI {
        var view = self
        view.dateTimeFormatter = dateTimeFormatter
        return view
    }
    
    public func set<T: View>(bubbleView: @escaping (BaseMessage) -> T) -> CometChatMessageInformationSwiftUI {
        var view = self
        view.bubbleView = { message in
            AnyView(bubbleView(message))
        }
        return view
    }
    
    public func set<T: View>(subtitleView: @escaping (BaseMessage, MessageReceipt) -> T) -> CometChatMessageInformationSwiftUI {
        var view = self
        view.subtitleView = { message, receipt in
            AnyView(subtitleView(message, receipt))
        }
        return view
    }
    
    public func set<T: View>(listItemView: @escaping (BaseMessage, MessageReceipt) -> T) -> CometChatMessageInformationSwiftUI {
        var view = self
        view.listItemView = { message, receipt in
            AnyView(listItemView(message, receipt))
        }
        return view
    }
    
    public func set(onError: @escaping (CometChatException) -> Void) -> CometChatMessageInformationSwiftUI {
        var view = self
        view.onError = onError
        return view
    }
}

extension CometChatMessageInformationSwiftUI {
    public func toUIKit() -> UIViewController {
        let hostingController = UIHostingController(rootView: self)
        return hostingController
    }
}

struct BubbleSnapshotView: UIViewRepresentable {
    let bubbleView: UIView
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.addSubview(bubbleView)
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let subview = uiView.subviews.first {
            subview.removeFromSuperview()
        }
        uiView.addSubview(bubbleView)
        bubbleView.frame = CGRect(
            x: UIScreen.main.bounds.width - 16 - bubbleView.bounds.width,
            y: 16,
            width: bubbleView.bounds.width,
            height: bubbleView.bounds.height
        )
    }
}

extension View {
    func navigationBarColor(backgroundColor: UIColor?, titleColor: UIColor?, tintColor: UIColor?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, titleColor: titleColor, tintColor: tintColor))
    }
}

struct NavigationBarModifier: ViewModifier {
    var backgroundColor: UIColor?
    var titleColor: UIColor?
    var tintColor: UIColor?
    
    init(backgroundColor: UIColor?, titleColor: UIColor?, tintColor: UIColor?) {
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.tintColor = tintColor
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        
        if let backgroundColor = backgroundColor {
            coloredAppearance.backgroundColor = backgroundColor
        }
        
        if let titleColor = titleColor {
            coloredAppearance.titleTextAttributes = [.foregroundColor: titleColor]
            coloredAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor]
        }
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        
        if let tintColor = tintColor {
            UINavigationBar.appearance().tintColor = tintColor
        }
    }
    
    func body(content: Content) -> some View {
        content
    }
}

struct CometChatMessageInformationSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatMessageInformationSwiftUI()
                .set(message: getMockUserMessage())
                .previewDisplayName("User Message")
            
            CometChatMessageInformationSwiftUI()
                .set(message: getMockGroupMessage())
                .previewDisplayName("Group Message")
            
            CometChatMessageInformationSwiftUI(style: getCustomStyle())
                .set(message: getMockUserMessage())
                .previewDisplayName("Custom Style")
            
            CometChatMessageInformationSwiftUI()
                .set(message: getMockUserMessage())
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
    
    static func getMockUserMessage() -> BaseMessage {
        let textMessage = TextMessage(receiverUid: "user1", text: "Hello, how are you?", receiverType: .user)
        textMessage.id = 123456
        textMessage.sender = User(uid: "sender1", name: "John Doe")
        textMessage.receiver = User(uid: "user1", name: "Jane Smith")
        textMessage.deliveredAt = Date().timeIntervalSince1970 - 3600 // 1 hour ago
        textMessage.readAt = Date().timeIntervalSince1970 - 1800 // 30 minutes ago
        return textMessage
    }
    
    static func getMockGroupMessage() -> BaseMessage {
        let textMessage = TextMessage(receiverUid: "group1", text: "Hello everyone!", receiverType: .group)
        textMessage.id = 789012
        textMessage.sender = User(uid: "sender1", name: "John Doe")
        
        let group = Group(guid: "group1", name: "Project Team", groupType: .public)
        group.membersCount = 12
        textMessage.receiver = group
        
        return textMessage
    }
    
    static func getCustomStyle() -> MessageInformationStyle {
        let style = MessageInformationStyle()
        style.backgroundColor = CometChatTheme.palatte.accent100
        style.titleColor = CometChatTheme.palatte.accent900
        style.listItemSubTitleTextColor = CometChatTheme.palatte.accent600
        style.bubbleContainerBackgroundColor = CometChatTheme.palatte.accent200
        return style
    }
}
