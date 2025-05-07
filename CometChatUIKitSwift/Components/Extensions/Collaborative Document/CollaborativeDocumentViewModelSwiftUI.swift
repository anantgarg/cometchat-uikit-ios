//
//
//

import Combine
import CometChatSDK
import Foundation
import SwiftUI

public class CollaborativeDocumentViewModelSwiftUI: DataSourceDecorator {
    var collaborativeDocumentExtensionTypeConstant = ExtensionType.document
    var configuration: CollaborativeDocumentBubbleConfiguration?
    var loggedInUser = CometChat.getLoggedInUser()

    private var cancellables = Set<AnyCancellable>()

    override public init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
    }

    override public func getId() -> String {
        "document"
    }

    override public func getAllMessageTypes() -> [String]? {
        var messageTypes = super.getAllMessageTypes()
        messageTypes?.append(collaborativeDocumentExtensionTypeConstant)
        return messageTypes
    }

    override public func getAllMessageCategories() -> [String]? {
        var messageCategories = super.getAllMessageCategories()
        messageCategories?.append(MessageCategoryConstants.custom)
        return messageCategories
    }

    override public func getAllMessageTemplates(additionalConfiguration: AdditionalConfiguration?) -> [CometChatMessageTemplate] {
        var templates = super.getAllMessageTemplates(additionalConfiguration: additionalConfiguration)
        templates.append(getTemplate(additionalConfiguration: additionalConfiguration))
        return templates
    }

    override public func getAttachmentOptions(controller: UIViewController, user: User?, group: Group?, id: [String: Any]?, additionalConfiguration: AdditionalConfiguration = AdditionalConfiguration()) -> [CometChatMessageComposerAction]? {
        var actions = super.getAttachmentOptions(controller: controller, user: user, group: group, id: id, additionalConfiguration: additionalConfiguration)
        if id?[MessagesConstants.parentMessageId] == nil {
            if let action = getAttachmentOption(controller: controller, user: user, group: group) {
                if !additionalConfiguration.hideCollaborativeDocumentOption {
                    actions?.append(action)
                }
            }
        }
        return actions
    }

    override public func getLastConversationMessage(conversation: Conversation, additionalConfiguration: AdditionalConfiguration?) -> NSAttributedString? {
        if let customMessage = conversation.lastMessage as? CustomMessage, let additionalConfiguration {
            if customMessage.type == MessageTypeConstants.document, customMessage.deletedAt == 0.0 {
                return addImageToText(text: ConversationConstants.customMessageDocument, image: "collaborative-document-message", additionalConfiguration: additionalConfiguration)
            } else if customMessage.deletedAt > 0.0 {
                return addImageToText(text: ConversationConstants.thisMessageDeleted, image: "deleted-message", additionalConfiguration: additionalConfiguration)
            }
        }
        return super.getLastConversationMessage(conversation: conversation, additionalConfiguration: additionalConfiguration)
    }

    override public func getMessageTemplate(messageType: String, messageCategory: String, additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate? {
        if messageType == MessageCategoryConstants.custom, messageCategory == collaborativeDocumentExtensionTypeConstant {
            return getTemplate(additionalConfiguration: additionalConfiguration)
        }
        return super.getMessageTemplate(messageType: messageType, messageCategory: messageCategory, additionalConfiguration: additionalConfiguration)
    }

    public func getTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        CometChatMessageTemplate(category: MessageCategoryConstants.custom, type: collaborativeDocumentExtensionTypeConstant, contentView: { message, _, controller in
            guard let message = message as? CustomMessage else { return UIView() }
            if message.deletedAt != 0.0 {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: message, additionalConfiguration: additionalConfiguration) {
                    return deletedBubble
                }
            }

            let documentBubble = self.getContentView(_customMessage: message, controller: controller, additionalConfiguration: additionalConfiguration)
            return documentBubble

        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let message else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: message, controller: controller, alignment: alignment, additionalConfiguration: additionalConfiguration)
        } options: { message, group, controller in
            guard let message, let user = LoggedInUserInformation.getUser() else { return [] }
            return ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: user, messageObject: message, controller: controller, group: group, additionalConfiguration: additionalConfiguration ?? AdditionalConfiguration())
        }
    }

    public func getContentView(_customMessage: CustomMessage, controller: UIViewController?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        let documentBubbleSwiftUI = CometChatCollaborativeBubbleSwiftUI(message: _customMessage)
            .set(title: "COLLABORATIVE_DOCUMENT".localize())
            .set(subTitle: "OPEN_DOCUMENT_TO_EDIT_CONTENT_TOGETHER".localize())
            .set(buttonText: "OPEN_DOCUMENT".localize())
            .set(controller: controller)
            .set(additionalConfiguration: additionalConfiguration)

        let hostingController = UIHostingController(rootView: documentBubbleSwiftUI)
        let documentBubbleView = hostingController.view

        documentBubbleView?.translatesAutoresizingMaskIntoConstraints = false
        documentBubbleView?.widthAnchor.constraint(equalToConstant: 228).isActive = true
        documentBubbleView?.heightAnchor.constraint(equalToConstant: 145).isActive = true

        return documentBubbleView
    }

    public func getAttachmentOption(controller _: UIViewController?, user: User?, group: Group?) -> CometChatMessageComposerAction? {
        CometChatMessageComposerAction(id: ExtensionConstants.document, text: "COLLABORATIVE_DOCUMENT".localize(), startIcon: UIImage(named: "collaborative-document.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil) { [weak self] in
            guard let this = self else { return }
            this.sentDocument(user: user, group: group)
        }
    }

    private func sentDocument(user: User?, group: Group?) {
        if let group {
            CometChat.callExtension(slug: ExtensionConstants.document, type: .post, endPoint: ExtensionUrls.document, body: ["receiver": group.guid, "receiverType": "group"], onSuccess: { _ in

            }) { error in
                if let error {
                    DispatchQueue.main.async {
                        let confirmDialog = CometChatDialog()
                        confirmDialog.set(confirmButtonText: "OK".localize())
                        confirmDialog.set(cancelButtonText: "CANCEL".localize())
                        confirmDialog.set(error: CometChatServerError.get(error: error))
                        confirmDialog.open(onConfirm: {})
                    }
                }
            }
        } else if let user {
            CometChat.callExtension(slug: ExtensionConstants.document, type: .post, endPoint: ExtensionUrls.document, body: ["receiver": user.uid ?? "", "receiverType": "user"], onSuccess: { _ in

            }) { error in
                if let error {
                    DispatchQueue.main.async {
                        let confirmDialog = CometChatDialog()
                        confirmDialog.set(confirmButtonText: "OK".localize())
                        confirmDialog.set(cancelButtonText: "CANCEL".localize())
                        confirmDialog.set(error: CometChatServerError.get(error: error))
                        confirmDialog.open(onConfirm: {})
                    }
                }
            }
        }
    }
}
