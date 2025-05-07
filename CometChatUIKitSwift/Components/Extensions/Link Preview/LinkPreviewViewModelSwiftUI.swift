//
//
//

import Combine
import CometChatSDK
import Foundation
import SwiftUI

public class LinkPreviewViewModelSwiftUI: ObservableObject, DataSource {
    @Published var dataSource: DataSource

    var messageTypeConstant = ExtensionConstants.linkPreview
    var loggedInUser = CometChat.getLoggedInUser()

    public init(dataSource: DataSource) {
        self.dataSource = dataSource
    }

    public func getId() -> String {
        "link-preview-swiftui"
    }

    public func getTextMessageContentView(message: TextMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        if getMessageLinks(message: message) != nil {
            let linkPreviewBubble = CometChatLinkPreviewBubbleSwiftUI()
                .set(message: message)
                .set(controller: controller)

            let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)
            let messageBubbleStyle = isLoggedInUser ? additionalConfiguration?.messageBubbleStyle.outgoing : additionalConfiguration?.messageBubbleStyle.incoming

            if let style = messageBubbleStyle?.linkPreviewBubbleStyle {
                linkPreviewBubble.set(style: style)
            }

            if let textFormatter = additionalConfiguration?.textFormatter, !textFormatter.isEmpty {
                if let attributedText = MessageUtils.processTextFormatter(for: message, in: UILabel(), textFormatter: textFormatter, controller: controller, alignment: alignment) {
                    linkPreviewBubble.set(attributedText: attributedText)
                }
            }

            return linkPreviewBubble.toUIKit()

        } else {
            return dataSource.getTextMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
        }
    }

    private func getMessageLinks(message: TextMessage) -> [Any]? {
        if let map = ExtensionModerator.extensionCheck(baseMessage: message), !map.isEmpty,
           let linkPreview = map[ExtensionConstants.linkPreview], let links = linkPreview["links"] as? [Any], !links.isEmpty
        {
            links
        } else {
            nil
        }
    }

    public func getAudioMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: AudioBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        dataSource.getAudioMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }

    public func getFileMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FileBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        dataSource.getFileMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }

    public func getImageMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: ImageBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        dataSource.getImageMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }

    public func getVideoMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: VideoBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        dataSource.getVideoMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }

    public func getGroupActionMessageContentView(message: ActionMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: ActionMessageStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        dataSource.getGroupActionMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }

    public func getCustomMessageContentView(message: CustomMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: CustomMessageBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        dataSource.getCustomMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }

    public func getFormMessageContentView(message: CustomMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FormBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        dataSource.getFormMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }

    public func getSchedulerMessageContentView(message: CustomMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: SchedulerBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        dataSource.getSchedulerMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }

    public func getCardMessageContentView(message: CustomMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: CardBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        dataSource.getCardMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
}
