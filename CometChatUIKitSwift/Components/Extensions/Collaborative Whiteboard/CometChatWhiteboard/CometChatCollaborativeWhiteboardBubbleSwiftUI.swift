//
//
//

import SwiftUI
import CometChatSDK

public struct CometChatCollaborativeWhiteboardBubbleSwiftUI: View {
    
    @State private var customMessage: CustomMessage?
    @State private var style: CollaborativeBubbleStyle = CollaborativeBubbleStyle()
    @State private var title: String = ""
    @State private var subTitle: String = ""
    @State private var buttonText: String = ""
    @State private var controller: UIViewController?
    @State private var additionalConfiguration: AdditionalConfiguration?
    @State private var onOpenButtonClicked: (() -> ())?
    
    @State private var collaborativeIconImage: UIImage? = UIImage(named: "collaborative-message-icon", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate)
    @State private var topImage: UIImage? = UIImage(named: "collaborative-white-board-image", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
    
    public init() {}
    
    public init(message: CustomMessage) {
        self._customMessage = State(initialValue: message)
    }
    
    public var body: some View {
        VStack(spacing: CometChatSpacing.Padding.p2) {
            if let topImage = topImage {
                Image(uiImage: topImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 140)
                    .cornerRadius(CometChatSpacing.Radius.r2)
                    .padding(.horizontal, CometChatSpacing.Padding.p1)
            }
            
            HStack(spacing: CometChatSpacing.Padding.p1) {
                if let collaborativeIconImage = collaborativeIconImage {
                    Image(uiImage: collaborativeIconImage)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .foregroundColor(Color(style.iconTint))
                }
                
                VStack(alignment: .leading, spacing: CometChatSpacing.Padding.p) {
                    Text(title)
                        .font(Font(style.titleFont))
                        .foregroundColor(Color(style.titleColor))
                    
                    Text(subTitle)
                        .font(Font(style.subTitleFont))
                        .foregroundColor(Color(style.subTitleColor))
                }
                
                Spacer()
            }
            .padding(.horizontal, CometChatSpacing.Padding.p1)
            
            Rectangle()
                .fill(Color.black.opacity(0.4))
                .frame(height: 0.3)
                .padding(.horizontal, CometChatSpacing.Padding.p1)
            
            Button(action: {
                handleOpenButtonClick()
            }) {
                Text(buttonText)
                    .font(Font(style.buttonTextFont))
                    .foregroundColor(Color(style.buttonTextColor))
                    .frame(height: 25)
            }
            .padding(.horizontal, CometChatSpacing.Padding.p1)
            .padding(.bottom, CometChatSpacing.Padding.p1)
        }
        .background(Color(style.backgroundColor ?? .clear))
        .cornerRadius(style.cornerRadius?.cornerRadius ?? 12)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius?.cornerRadius ?? 12)
                .stroke(Color(style.borderColor ?? .clear), lineWidth: style.borderWidth ?? 0)
        )
        .frame(width: 228, height: 145)
    }
    
    private func handleOpenButtonClick() {
        if let onOpenButtonClicked = onOpenButtonClicked {
            onOpenButtonClicked()
        } else {
            openWhiteboardURL()
        }
    }
    
    private func openWhiteboardURL() {
        if let controller = controller, let customMessage = customMessage {
            if let metaData = customMessage.metaData,
               let injected = metaData["@injected"] as? [String: Any],
               let cometChatExtension = injected[ExtensionConstants.extensions] as? [String: Any],
               let collaborativeDictionary = cometChatExtension[ExtensionConstants.whiteboard] as? [String: Any],
               let collaborativeURL = collaborativeDictionary["board_url"] as? String {
                
                let cometChatWebView = CometChatWebView()
                cometChatWebView.set(webViewType: .whiteboard)
                    .set(url: collaborativeURL)
                controller.navigationController?.pushViewController(cometChatWebView, animated: true)
            }
        }
    }
    
    @discardableResult
    public func set(message: CustomMessage) -> Self {
        var view = self
        view._customMessage = State(initialValue: message)
        return view
    }
    
    @discardableResult
    public func set(title: String) -> Self {
        var view = self
        view._title = State(initialValue: title)
        return view
    }
    
    @discardableResult
    public func set(subTitle: String) -> Self {
        var view = self
        view._subTitle = State(initialValue: subTitle)
        return view
    }
    
    @discardableResult
    public func set(buttonText: String) -> Self {
        var view = self
        view._buttonText = State(initialValue: buttonText)
        return view
    }
    
    @discardableResult
    public func set(controller: UIViewController?) -> Self {
        var view = self
        view._controller = State(initialValue: controller)
        return view
    }
    
    @discardableResult
    public func set(additionalConfiguration: AdditionalConfiguration?) -> Self {
        var view = self
        view._additionalConfiguration = State(initialValue: additionalConfiguration)
        
        if let customMessage = customMessage {
            let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: customMessage.senderUid)
            let messageBubbleStyle = isLoggedInUser ? additionalConfiguration?.messageBubbleStyle.outgoing : additionalConfiguration?.messageBubbleStyle.incoming
            if let style = messageBubbleStyle?.collaborativeWhiteboardBubbleStyle {
                view._style = State(initialValue: style)
            }
        }
        
        return view
    }
    
    @discardableResult
    public func set(style: CollaborativeBubbleStyle) -> Self {
        var view = self
        view._style = State(initialValue: style)
        return view
    }
    
    @discardableResult
    public func set(onOpenButtonClicked: @escaping (() -> ())) -> Self {
        var view = self
        view._onOpenButtonClicked = State(initialValue: onOpenButtonClicked)
        return view
    }
    
    @discardableResult
    public func set(collaborativeIconImage: UIImage?) -> Self {
        var view = self
        view._collaborativeIconImage = State(initialValue: collaborativeIconImage)
        return view
    }
    
    @discardableResult
    public func set(topImage: UIImage?) -> Self {
        var view = self
        view._topImage = State(initialValue: topImage)
        return view
    }
    
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        let view = hostingController.view
        view?.translatesAutoresizingMaskIntoConstraints = false
        view?.widthAnchor.constraint(equalToConstant: 228).isActive = true
        view?.heightAnchor.constraint(equalToConstant: 145).isActive = true
        return view ?? UIView()
    }
}

struct CometChatCollaborativeWhiteboardBubbleSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            let sender = User(uid: "user1", name: "John Doe")
            let customMessage = CustomMessage(receiverUid: "user2", messageType: MessageTypeConstants.whiteboard, receiverType: .user)
            customMessage.sender = sender
            customMessage.senderUid = sender.uid
            
            let whiteboardURL = "https://example.com/whiteboard"
            let metaData: [String: Any] = [
                "@injected": [
                    "extensions": [
                        ExtensionConstants.whiteboard: [
                            "board_url": whiteboardURL
                        ]
                    ]
                ]
            ]
            customMessage.metaData = metaData
            
            CometChatCollaborativeWhiteboardBubbleSwiftUI(message: customMessage)
                .set(title: "COLLABORATIVE_WHITEBOARD".localize())
                .set(subTitle: "OPEN_WHITEBOARD_TO_DRAW_TOGETHER".localize())
                .set(buttonText: "OPEN_WHITEBOARD".localize())
                .set(style: CollaborativeBubbleStyle(styleType: .incoming))
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Incoming Whiteboard Bubble")
            
            CometChatCollaborativeWhiteboardBubbleSwiftUI(message: customMessage)
                .set(title: "COLLABORATIVE_WHITEBOARD".localize())
                .set(subTitle: "OPEN_WHITEBOARD_TO_DRAW_TOGETHER".localize())
                .set(buttonText: "OPEN_WHITEBOARD".localize())
                .set(style: CollaborativeBubbleStyle(styleType: .outgoing))
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Outgoing Whiteboard Bubble")
        }
    }
}
