//
//
//

import Foundation
import CometChatSDK
import SwiftUI
import Combine

public class CollaborativeWhiteboardViewModelSwiftUI: DataSourceDecorator {
    
    var collaborativeWhiteboardExtensionTypeConstant = ExtensionType.whiteboard
    var configuration: CollaborativeWhiteboardBubbleConfiguration?
    var loggedInUser = CometChat.getLoggedInUser()
    
    private var cancellables = Set<AnyCancellable>()
    
    public override init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
    }
    
    public override func getId() -> String {
        return "whiteboard"
    }
    
    public override func getAllMessageTypes() -> [String]? {
        var messageTypes = super.getAllMessageTypes()
        messageTypes?.append(collaborativeWhiteboardExtensionTypeConstant)
        return messageTypes
    }
    
    public override func getAllMessageCategories() -> [String]? {
        var messageCategories = super.getAllMessageCategories()
        messageCategories?.append(MessageCategoryConstants.custom)
        return messageCategories
    }
    
    public override func getAllMessageTemplates(additionalConfiguration: AdditionalConfiguration?) -> [CometChatMessageTemplate] {
        var templates = super.getAllMessageTemplates(additionalConfiguration: additionalConfiguration)
        templates.append(getTemplate(additionalConfiguration: additionalConfiguration))
        return templates
    }
    
    public override func getAttachmentOptions(controller: UIViewController, user: User?, group: Group?, id: [String: Any]?, additionalConfiguration: AdditionalConfiguration = AdditionalConfiguration()) -> [CometChatMessageComposerAction]? {
        var actions = super.getAttachmentOptions(controller: controller, user: user, group: group, id: id, additionalConfiguration: additionalConfiguration)
        if id?[MessagesConstants.parentMessageId] == nil {
            if let action = getAttachmentOption(controller: controller, user: user, group: group) {
                if !additionalConfiguration.hideCollaborativeWhiteboardOption{
                    actions?.append(action)
                }
            }
        }
        return actions
    }
    
    public override func getLastConversationMessage(conversation: Conversation, additionalConfiguration: AdditionalConfiguration?) -> NSAttributedString? {
        if let customMessage = conversation.lastMessage as? CustomMessage, let additionalConfiguration {
            if customMessage.type == MessageTypeConstants.whiteboard && customMessage.deletedAt == 0.0 {
                return addImageToText(text: ConversationConstants.customMessageWhiteboard, image: "collaborative-message-icon", additionalConfiguration: additionalConfiguration)
            }else if customMessage.deletedAt > 0.0{
                return addImageToText(text: ConversationConstants.thisMessageDeleted, image: "deleted-message", additionalConfiguration: additionalConfiguration)
            }
        }
        return super.getLastConversationMessage(conversation: conversation, additionalConfiguration: additionalConfiguration)
    }
    
    public override func getMessageTemplate(messageType: String, messageCategory: String, additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate? {
        if messageType == MessageCategoryConstants.custom && messageCategory == collaborativeWhiteboardExtensionTypeConstant {
            return getTemplate(additionalConfiguration: additionalConfiguration)
        }
        return super.getMessageTemplate(messageType: messageType, messageCategory: messageCategory, additionalConfiguration: additionalConfiguration)
    }
    
    public func getTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.custom, type: collaborativeWhiteboardExtensionTypeConstant, contentView: { message, alignment, controller in
            guard let message = message as? CustomMessage else { return UIView() }
            if (message.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: message, additionalConfiguration: additionalConfiguration) {
                    return deletedBubble
                }
            }
            
            let whiteboardBubble = self.getContentView(_customMessage: message, controller: controller, additionalConfiguration: additionalConfiguration)
            return whiteboardBubble
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let message = message else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: message, controller: controller, alignment: alignment, additionalConfiguration: additionalConfiguration)
        } options: { message, group, controller in
            guard let message = message, let user = LoggedInUserInformation.getUser() else { return [] }
            return ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: user, messageObject: message, controller: controller, group: group, additionalConfiguration: additionalConfiguration ?? AdditionalConfiguration())
        }
    }
    
    public func getContentView(_customMessage: CustomMessage, controller: UIViewController?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        let whiteboardBubbleSwiftUI = CometChatCollaborativeWhiteboardBubbleSwiftUI(message: _customMessage)
            .set(title: "COLLABORATIVE_WHITEBOARD".localize())
            .set(subTitle: "OPEN_WHITEBOARD_TO_DRAW_TOGETHER".localize())
            .set(buttonText: "OPEN_WHITEBOARD".localize())
            .set(controller: controller)
            .set(additionalConfiguration: additionalConfiguration)
        
        let hostingController = UIHostingController(rootView: whiteboardBubbleSwiftUI)
        let whiteboardBubbleView = hostingController.view
        
        whiteboardBubbleView?.translatesAutoresizingMaskIntoConstraints = false
        whiteboardBubbleView?.widthAnchor.constraint(equalToConstant: 228).isActive = true
        whiteboardBubbleView?.heightAnchor.constraint(equalToConstant: 145).isActive = true
        
        return whiteboardBubbleView
    }
    
    public func getAttachmentOption(controller: UIViewController?, user: User?, group: Group?) -> CometChatMessageComposerAction? {
        return CometChatMessageComposerAction(id: ExtensionConstants.whiteboard, text: "COLLABORATIVE_WHITEBOARD".localize(), startIcon: UIImage(named: "collaborative-whiteboard.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil) { [weak self] in
            guard let this = self else { return }
            this.sentWhiteboard(user: user, group: group, controller: controller)
        }
    }
    
    private func sentWhiteboard(user: User?, group: Group?, controller: UIViewController?) {
        if let group = group {
            CometChat.callExtension(slug: ExtensionConstants.whiteboard, type: .post, endPoint: ExtensionUrls.whiteboard, body: ["receiver":group.guid,"receiverType":"group"], onSuccess: { (response) in
                
            }) { (error) in
                if let error = error {
                    DispatchQueue.main.async {
                        let confirmDialog = CometChatDialog()
                        confirmDialog.set(confirmButtonText: "OK".localize())
                        confirmDialog.set(cancelButtonText: "CANCEL".localize())
                        confirmDialog.set(error: CometChatServerError.get(error: error))
                        confirmDialog.open(onConfirm: {
                        })
                    }
                }
            }
        } else if let user = user {
            CometChat.callExtension(slug: ExtensionConstants.whiteboard, type: .post, endPoint:  ExtensionUrls.whiteboard, body: ["receiver":user.uid ?? "","receiverType":"user"], onSuccess: { (response) in
                
            }) { (error) in
                if let error = error {
                    DispatchQueue.main.async {
                        let confirmDialog = CometChatDialog()
                        confirmDialog.set(confirmButtonText: "OK".localize())
                        confirmDialog.set(cancelButtonText: "CANCEL".localize())
                        confirmDialog.set(error: CometChatServerError.get(error: error))
                        confirmDialog.open(onConfirm: {
                        })
                    }
                }
            }
        }
    }
}
