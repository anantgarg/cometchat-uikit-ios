//
//
//

import SwiftUI
import CometChatSDK

public struct AIMessageComposerSwiftUI: View {
    @State private var messageText: String = ""
    @State private var textFieldHeight: CGFloat = 40
    
    private var placeholderText: String = "TYPE_A_MESSAGE".localize()
    private var user: User?
    private var style: MessageInputStyle?
    private var sendIcon = UIImage(named: "message-composer-send.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    private var onSendButtonClicked: ((BaseMessage) -> Void)?
    
    public init() {}
    
    public var body: some View {
        HStack(spacing: 8) {
            ZStack(alignment: .leading) {
                if messageText.isEmpty {
                    Text(placeholderText)
                        .font(Font(style?.placeHolderTextFont ?? CometChatTheme_v4.typography.text1))
                        .foregroundColor(Color(style?.placeHolderTextColor ?? CometChatTheme_v4.palatte.accent500))
                        .padding(.horizontal, 12)
                }
                
                TextEditor(text: $messageText)
                    .font(Font(style?.textFont ?? CometChatTheme_v4.typography.text1))
                    .foregroundColor(Color(style?.textColor ?? CometChatTheme_v4.palatte.accent))
                    .frame(minHeight: 40, maxHeight: 120)
                    .padding(.horizontal, 8)
                    .background(Color(style?.inputBackground ?? CometChatTheme_v4.palatte.background))
                    .onChange(of: messageText) { newValue in
                        let estimatedHeight = newValue.height(withConstrainedWidth: UIScreen.main.bounds.width - 100, font: style?.textFont ?? CometChatTheme_v4.typography.text1)
                        textFieldHeight = min(max(40, estimatedHeight + 20), 120)
                    }
            }
            .frame(height: textFieldHeight)
            .padding(.vertical, 4)
            .background(Color(style?.inputBackground ?? CometChatTheme_v4.palatte.background))
            .cornerRadius((style?.cornerRadius?.cornerRadius ?? 20))
            .overlay(
                RoundedRectangle(cornerRadius: (style?.cornerRadius?.cornerRadius ?? 20))
                    .stroke(Color(style?.borderColor ?? CometChatTheme_v4.palatte.accent700), lineWidth: style?.borderWidth ?? 1)
            )
            
            Button(action: sendMessage) {
                Image(uiImage: sendIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(style?.sendIconTint ?? CometChatTheme_v4.palatte.accent700))
            }
            .frame(width: 40, height: 40)
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
    
    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            let textMessage = TextMessage(receiverUid: user?.uid ?? "", text: trimmedText, receiverType: .user)
            onSendButtonClicked?(textMessage)
            messageText = ""
        }
    }
    
    public func set(user: User?) -> AIMessageComposerSwiftUI {
        var view = self
        view.user = user
        return view
    }
    
    public func set(onMessageSent: ((BaseMessage) -> Void)?) -> AIMessageComposerSwiftUI {
        var view = self
        view.onSendButtonClicked = onMessageSent
        return view
    }
    
    public func set(sendIcon: UIImage) -> AIMessageComposerSwiftUI {
        var view = self
        view.sendIcon = sendIcon
        return view
    }
    
    public func set(sendIconTint: UIColor) -> AIMessageComposerSwiftUI {
        var view = self
        view.sendIcon = view.sendIcon.withTintColor(sendIconTint)
        return view
    }
    
    public func set(messageInputStyle: MessageInputStyle) -> AIMessageComposerSwiftUI {
        var view = self
        view.style = messageInputStyle
        return view
    }
    
    public func set(placeholderText: String) -> AIMessageComposerSwiftUI {
        var view = self
        view.placeholderText = placeholderText
        return view
    }
}

extension AIMessageComposerSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
}

struct AIMessageComposerSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AIMessageComposerSwiftUI()
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Default")
            
            AIMessageComposerSwiftUI()
                .set(placeholderText: "Ask the AI assistant...")
                .set(messageInputStyle: getCustomStyle())
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Custom Style")
            
            AIMessageComposerSwiftUI()
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Dark Mode")
        }
    }
    
    static func getCustomStyle() -> MessageInputStyle {
        let style = MessageInputStyle()
        style.textColor = CometChatTheme_v4.palatte.accent900
        style.placeHolderTextColor = CometChatTheme_v4.palatte.accent400
        style.borderColor = CometChatTheme_v4.palatte.primary
        style.inputBackground = CometChatTheme_v4.palatte.accent50
        return style
    }
}
