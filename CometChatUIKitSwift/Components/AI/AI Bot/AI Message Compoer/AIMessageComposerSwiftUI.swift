//
//
//

import CometChatSDK
import CometChatUIKitSwift.Components.Shared.Constants
import SwiftUI

public struct AIMessageComposerSwiftUI: View {
    @State private var messageText: String = ""
    @State private var textFieldHeight: CGFloat = LayoutMetrics.avatarMedium

    private var placeholderText: String = "TYPE_A_MESSAGE".localize()
    private var user: User?
    private var style: MessageInputStyle?
    private var sendIconName = "paperplane.fill"
    private var onSendButtonClicked: ((BaseMessage) -> Void)?

    public init() {}

    public var body: some View {
        HStack(spacing: 8) {
            ZStack(alignment: .leading) {
                if messageText.isEmpty {
                    Text(placeholderText)
                        .font(Font(style?.placeHolderTextFont ?? CometChatTheme_v4.typography.text1))
                        .foregroundColor(Color(style?.placeHolderTextColor ?? CometChatTheme_v4.palatte.accent500))
                        .padding(.horizontal, LayoutMetrics.spacingMedium)
                }

                TextEditor(text: $messageText)
                    .font(Font(style?.textFont ?? CometChatTheme_v4.typography.text1))
                    .foregroundColor(Color(style?.textColor ?? CometChatTheme_v4.palatte.accent))
                    .frame(minHeight: LayoutMetrics.avatarMedium, maxHeight: LayoutMetrics.avatarLarge * 2.5)
                    .padding(.horizontal, LayoutMetrics.spacingStandard)
                    .background(Color(style?.inputBackground ?? CometChatTheme_v4.palatte.background))
                    .onChange(of: messageText) { newValue in
                        let estimatedHeight = newValue.height(withConstrainedWidth: UIScreen.main.bounds.width - 100, font: style?.textFont ?? CometChatTheme_v4.typography.text1)
                        textFieldHeight = min(max(LayoutMetrics.avatarMedium, estimatedHeight + LayoutMetrics.spacingLarge), LayoutMetrics.avatarLarge * 2.5)
                    }
            }
            .frame(height: textFieldHeight)
            .padding(.vertical, LayoutMetrics.spacingSmall)
            .background(Color(style?.inputBackground ?? CometChatTheme_v4.palatte.background))
            .cornerRadius((style?.cornerRadius?.cornerRadius ?? LayoutMetrics.cornerRadiusRound))
            .overlay(
                RoundedRectangle(cornerRadius: (style?.cornerRadius?.cornerRadius ?? LayoutMetrics.cornerRadiusRound))
                    .stroke(Color(style?.borderColor ?? CometChatTheme_v4.palatte.accent700), lineWidth: style?.borderWidth ?? LayoutMetrics.dividerHeight)
            )

            Button(action: sendMessage) {
                Image(systemName: sendIconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: LayoutMetrics.largeIconSize, height: LayoutMetrics.largeIconSize)
                    .foregroundColor(Color(style?.sendIconTint ?? CometChatTheme_v4.palatte.accent700))
            }
            .frame(width: LayoutMetrics.avatarMedium, height: LayoutMetrics.avatarMedium)
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, LayoutMetrics.spacingStandard)
        .padding(.vertical, LayoutMetrics.spacingSmall)
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

    public func set(sendIconName: String) -> AIMessageComposerSwiftUI {
        var view = self
        view.sendIconName = sendIconName
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

public extension AIMessageComposerSwiftUI {
    func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
}

struct AIMessageComposerSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AIMessageComposerSwiftUI()
                .padding()
                .previewDisplayName("Default (Light)")

            AIMessageComposerSwiftUI()
                .preferredColorScheme(.dark)
                .padding()
                .previewDisplayName("Default (Dark)")

            AIMessageComposerSwiftUI()
                .set(placeholderText: "Ask the AI assistant...")
                .set(messageInputStyle: getCustomStyle())
                .padding()
                .previewDisplayName("Custom Style (Light)")

            AIMessageComposerSwiftUI()
                .set(placeholderText: "Ask the AI assistant...")
                .set(messageInputStyle: getCustomStyle())
                .preferredColorScheme(.dark)
                .padding()
                .previewDisplayName("Custom Style (Dark)")
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
