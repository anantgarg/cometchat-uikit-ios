//
//
//

import Combine
import CometChatSDK
import Foundation
import SwiftUI

public class CometChatPollsViewModelSwiftUI: ObservableObject, DataSource {
    @Published var dataSource: DataSource

    var pollsExtensionTypeConstant = ExtensionType.extensionPoll
    var configuration: PollBubbleConfiguration?
    var loggedInUser = CometChat.getLoggedInUser()

    public init(dataSource: DataSource) {
        self.dataSource = dataSource
    }

    public func getId() -> String {
        "polls-swiftui"
    }

    public func getAllMessageTypes() -> [String]? {
        var messageTypes = dataSource.getAllMessageTypes()
        messageTypes?.append(pollsExtensionTypeConstant)
        return messageTypes
    }

    public func getAllMessageCategories() -> [String]? {
        var messageCategories = dataSource.getAllMessageCategories()
        messageCategories?.append(MessageCategoryConstants.custom)
        return messageCategories
    }

    public func getLastConversationMessage(conversation: Conversation, additionalConfiguration: AdditionalConfiguration?) -> NSAttributedString? {
        if let customMessage = conversation.lastMessage as? CustomMessage, let additionalConfiguration {
            if customMessage.type == MessageTypeConstants.poll, customMessage.deletedAt == 0.0 {
                return addImageToText(text: ConversationConstants.customMessagePoll, image: "messages-poll", additionalConfiguration: additionalConfiguration)
            }
        }
        return dataSource.getLastConversationMessage(conversation: conversation, additionalConfiguration: additionalConfiguration)
    }

    public func getAllMessageTemplates(additionalConfiguration: AdditionalConfiguration?) -> [CometChatMessageTemplate] {
        var templates = dataSource.getAllMessageTemplates(additionalConfiguration: additionalConfiguration)
        templates.append(getTemplate(additionalConfiguration: additionalConfiguration))
        return templates
    }

    public func getAttachmentOptions(controller: UIViewController, user: User?, group: Group?, id: [String: Any]?, additionalConfiguration: AdditionalConfiguration = AdditionalConfiguration()) -> [CometChatMessageComposerAction]? {
        var actions = dataSource.getAttachmentOptions(controller: controller, user: user, group: group, id: id, additionalConfiguration: additionalConfiguration)
        if id?[MessagesConstants.parentMessageId] == nil {
            if let option = getAttachmentOption(controller: controller, user: user, group: group) {
                if !additionalConfiguration.hidePollsOption {
                    actions?.append(option)
                }
            }
        }
        return actions
    }

    public func getMessageTemplate(messageType: String, messageCategory: String, additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate? {
        if messageType == MessageCategoryConstants.custom, messageCategory == pollsExtensionTypeConstant {
            return getTemplate(additionalConfiguration: additionalConfiguration)
        }
        return dataSource.getMessageTemplate(messageType: messageType, messageCategory: messageCategory, additionalConfiguration: additionalConfiguration)
    }

    public func getTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        CometChatMessageTemplate(category: MessageCategoryConstants.custom, type: pollsExtensionTypeConstant, contentView: { message, _, controller in
            guard let message = message as? CustomMessage else { return UIView() }
            if message.deletedAt != 0.0 {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: message, additionalConfiguration: additionalConfiguration) {
                    return deletedBubble
                }
            }
            let pollsBubble = self.getContentView(_customMessage: message, controller: controller, additionalConfiguration: additionalConfiguration)
            return pollsBubble

        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let message else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: message, controller: controller, alignment: alignment, additionalConfiguration: additionalConfiguration)
        } options: { message, group, controller in
            guard let message, let user = LoggedInUserInformation.getUser() else { return [] }
            return ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: user, messageObject: message, controller: controller, group: group, additionalConfiguration: additionalConfiguration ?? AdditionalConfiguration())
        }
    }

    public func getContentView(_customMessage: CustomMessage, controller: UIViewController?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        let pollsBubbleSwiftUI = CometChatPollsBubbleSwiftUI()
            .set(pollMessage: _customMessage)

        if let controller {
            pollsBubbleSwiftUI.set(controller: controller)
        }

        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: _customMessage.senderUid)
        let messageBubbleStyle = isLoggedInUser ? additionalConfiguration?.messageBubbleStyle.outgoing : additionalConfiguration?.messageBubbleStyle.incoming

        if let style = messageBubbleStyle?.pollBubbleStyle {
            pollsBubbleSwiftUI.set(style: style)
        }

        return pollsBubbleSwiftUI.toUIKit()
    }

    public func getAttachmentOption(controller: UIViewController?, user: User?, group: Group?) -> CometChatMessageComposerAction? {
        CometChatMessageComposerAction(id: ExtensionConstants.polls, text: "CUSTOM_MESSAGE_POLL".localize(), startIcon: UIImage(named: "polls.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil) { [weak self, weak controller] in
            guard let this = self else { return }
            this.presentCreatePoll(user: user, group: group, controller: controller)
        }
    }

    private func presentCreatePoll(user: User?, group: Group?, controller: UIViewController?) {
        let createPoll = CometChatCreatePoll()

        if let user {
            createPoll.set(user: user)
        }
        if let group {
            createPoll.set(group: group)
        }

        let navigationController = UINavigationController(rootViewController: createPoll)
        controller?.present(navigationController, animated: true, completion: nil)
    }

    public func getTextMessageContentView(message: TextMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        dataSource.getTextMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
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

    private func addImageToText(text: String, image: String, additionalConfiguration _: AdditionalConfiguration) -> NSAttributedString? {
        let attachment = NSTextAttachment()
        if let image = UIImage(named: image, in: CometChatUIKit.bundle, compatibleWith: nil) {
            attachment.image = image.withRenderingMode(.alwaysTemplate)
            let attachmentString = NSAttributedString(attachment: attachment)
            let completeText = NSMutableAttributedString(string: "")
            completeText.append(attachmentString)
            let textAfterIcon = NSAttributedString(string: " " + text)
            completeText.append(textAfterIcon)
            return completeText
        }
        return nil
    }

    private func getDeleteMessageBubble(messageObject: BaseMessage, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        dataSource.getDeleteMessageBubble(messageObject: messageObject, additionalConfiguration: additionalConfiguration)
    }
}
