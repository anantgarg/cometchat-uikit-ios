//
//
//

import Combine
import CometChatSDK
import Foundation
import SwiftUI

class StickersExtensionDecoratorSwiftUI: DataSourceDecorator {
    var stickerTypeConstant = "extension_sticker"
    var configuration: StickerConfiguration?
    var anInterface: DataSource?

    private var cancellables = Set<AnyCancellable>()

    override public init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
        anInterface = dataSource
    }

    public init(dataSource: DataSource, configuration: StickerConfiguration?) {
        super.init(dataSource: dataSource)
        anInterface = dataSource
        self.configuration = configuration
    }

    override func getAllMessageTemplates(additionalConfiguration: AdditionalConfiguration?) -> [CometChatMessageTemplate] {
        var templates = super.getAllMessageTemplates(additionalConfiguration: additionalConfiguration)
        templates.append(getTemplate(additionalConfiguration: additionalConfiguration))
        return templates
    }

    override func getAuxiliaryOptions(user: User?, group: Group?, controller: UIViewController?, id: [String: Any]?) -> UIView? {
        var auxiliaryButtons = UIStackView()
        if let view = super.getAuxiliaryOptions(user: user, group: group, controller: controller, id: id) as? UIStackView {
            auxiliaryButtons = view
        }
        auxiliaryButtons.addArrangedSubview(getStickerAuxiliaryButton(user: user, group: group, controller: controller, id: id))

        return auxiliaryButtons
    }

    override func getAllMessageTypes() -> [String]? {
        var messageTypes = super.getAllMessageTypes()
        messageTypes?.append(stickerTypeConstant)
        return messageTypes
    }

    override func getAllMessageCategories() -> [String]? {
        if let categories = super.getAllMessageCategories(), !categories.contains(obj: MessageCategoryConstants.custom) {
            var messageCategories = categories
            messageCategories.append(MessageCategoryConstants.custom)
            return messageCategories
        }
        return super.getAllMessageCategories()
    }

    public func getTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        CometChatMessageTemplate(category: MessageCategoryConstants.custom, type: stickerTypeConstant, contentView: { message, _, controller in
            guard let message = message as? CustomMessage else { return UIView() }
            if message.deletedAt != 0.0 {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: message, additionalConfiguration: additionalConfiguration) {
                    return deletedBubble
                }
            }
            if let customData = message.customData, let stickerUrl = customData["sticker_url"] as? String {
                let stickerBubble = self.getStickerMessageBubble(stickerUrl: stickerUrl, message: message, controller: controller, style: StickerBubbleStyle(), additionalConfiguration: additionalConfiguration)
                return stickerBubble
            }
            return UIView()

        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let message else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: message, controller: controller, alignment: alignment, additionalConfiguration: additionalConfiguration)
        } options: { message, group, controller in
            guard let message, let user = LoggedInUserInformation.getUser() else { return [] }
            return ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: user, messageObject: message, controller: controller, group: group, additionalConfiguration: additionalConfiguration ?? AdditionalConfiguration())
        }
    }

    override public func getMessageTemplate(messageType: String, messageCategory: String, additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate? {
        if messageType == MessageCategoryConstants.custom, messageCategory == stickerTypeConstant {
            return getTemplate(additionalConfiguration: additionalConfiguration)
        }
        return super.getMessageTemplate(messageType: messageType, messageCategory: messageCategory, additionalConfiguration: additionalConfiguration)
    }

    public func getStickerMessageBubble(stickerUrl: String?, message: CometChatSDK.CustomMessage?, controller _: UIViewController?, style _: StickerBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        let stickerBubbleSwiftUI = CometChatStickerBubbleSwiftUI()
            .set(imageUrl: stickerUrl ?? "")

        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message?.senderUid)
        let messageBubbleStyle = isLoggedInUser ? additionalConfiguration?.messageBubbleStyle.outgoing : additionalConfiguration?.messageBubbleStyle.incoming
        if let style = messageBubbleStyle?.stickersBubbleStyle {
            stickerBubbleSwiftUI.set(style: style)
        }

        return stickerBubbleSwiftUI.toUIKit()
    }

    public func getStickerAuxiliaryButton(user: User?, group: Group?, controller: UIViewController?, id: [String: Any]?) -> UIView {
        let stickerAuxiliaryButtonSwiftUI = StickerAuxiliaryButtonSwiftUI()
        let stickerKeyboard = getStickerKeyboard(user: user, group: group, controller: controller, id: id)

        stickerAuxiliaryButtonSwiftUI.setOnStickerTap {
            let impactFeedbackLight = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackLight.impactOccurred()

            CometChatUIEvents.showPanel(id: id, alignment: .composerBottom, view: stickerKeyboard)
        }

        stickerAuxiliaryButtonSwiftUI.setOnKeyboardTap {
            let impactFeedbackLight = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackLight.impactOccurred()

            CometChatUIEvents.hidePanel(id: id, alignment: .composerBottom)
        }

        return stickerAuxiliaryButtonSwiftUI.toUIKit()
    }

    override func getId() -> String {
        "stickers"
    }

    override public func getLastConversationMessage(conversation: Conversation, additionalConfiguration: AdditionalConfiguration?) -> NSAttributedString? {
        if let customMessage = conversation.lastMessage as? CustomMessage, let additionalConfiguration {
            if customMessage.type == MessageTypeConstants.sticker, customMessage.deletedAt == 0.0 {
                return addImageToText(text: ConversationConstants.customMessageSticker, image: "messages-stickers", additionalConfiguration: additionalConfiguration)
            } else if customMessage.deletedAt > 0.0 {
                return addImageToText(text: ConversationConstants.thisMessageDeleted, image: "deleted-message", additionalConfiguration: additionalConfiguration)
            }
        }
        return super.getLastConversationMessage(conversation: conversation, additionalConfiguration: additionalConfiguration)
    }

    public func getStickerKeyboard(user: User?, group: Group?, controller _: UIViewController?, id: [String: Any]?) -> UIView {
        let stickerKeyboardSwiftUI = CometChatStickerKeyboardSwiftUI()

        stickerKeyboardSwiftUI.setOnStickerTap { sticker in
            var stickerData = [String: Any]()
            var metaData = [String: Any]()
            let pushNotificationMessage = "HAS_SHARED_A_STICKER".localize()

            stickerData["sticker_url"] = sticker.url
            stickerData["sticker_name"] = sticker.name
            metaData["incrementUnreadCount"] = true
            metaData["pushNotification"] = pushNotificationMessage

            var customMessage: CustomMessage?
            if user != nil {
                customMessage = CustomMessage(receiverUid: user?.uid ?? "", receiverType: .user, customData: stickerData, type: self.stickerTypeConstant)
            }
            if group != nil {
                customMessage = CustomMessage(receiverUid: group?.guid ?? "", receiverType: .group, customData: stickerData, type: self.stickerTypeConstant)
            }
            if let parentMessageId = id?["parentMessageId"] as? Int {
                customMessage?.parentMessageId = parentMessageId
            }

            customMessage?.updateConversation = true
            if let customMessage {
                customMessage.muid = "\(Int(Date().timeIntervalSince1970))"
                customMessage.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                customMessage.sender = CometChat.getLoggedInUser()
                CometChatUIKit.sendCustomMessage(message: customMessage)
            }
        }

        return stickerKeyboardSwiftUI.toUIKit()
    }

    public func getStickerMessageBubblePublisher(stickerUrl: String?, message: CometChatSDK.CustomMessage?, controller _: UIViewController?, style _: StickerBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> AnyPublisher<CometChatStickerBubbleSwiftUI, Never> {
        let stickerBubbleSwiftUI = CometChatStickerBubbleSwiftUI()
            .set(imageUrl: stickerUrl ?? "")

        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message?.senderUid)
        let messageBubbleStyle = isLoggedInUser ? additionalConfiguration?.messageBubbleStyle.outgoing : additionalConfiguration?.messageBubbleStyle.incoming
        if let style = messageBubbleStyle?.stickersBubbleStyle {
            stickerBubbleSwiftUI.set(style: style)
        }

        return Just(stickerBubbleSwiftUI).eraseToAnyPublisher()
    }

    public func getStickerKeyboardPublisher(user _: User?, group _: Group?, controller _: UIViewController?, id _: [String: Any]?) -> AnyPublisher<CometChatStickerKeyboardSwiftUI, Never> {
        let stickerKeyboardSwiftUI = CometChatStickerKeyboardSwiftUI()

        return Just(stickerKeyboardSwiftUI).eraseToAnyPublisher()
    }
}
