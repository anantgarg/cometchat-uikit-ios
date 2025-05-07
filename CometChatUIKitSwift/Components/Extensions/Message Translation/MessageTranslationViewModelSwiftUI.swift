//
//
//

import Foundation
import CometChatSDK
import SwiftUI
import Combine

public class MessageTranslationViewModelSwiftUI: ObservableObject, DataSource {
    
    @Published var dataSource: DataSource
    
    var messageTranslationConstant = ExtensionConstants.messageTranslation
    var loggedInUser = CometChat.getLoggedInUser()
    
    public init(dataSource: DataSource) {
        self.dataSource = dataSource
    }
    
    public func getId() -> String {
        return "message-translation-swiftui"
    }
    
    public func getTextMessageContentView(message: TextMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        if let translatedMessage = message.metaData?["translated-message"] as? String, !translatedMessage.isEmpty {
            return buildTextMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
        } else {
            return dataSource.getTextMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
        }
    }
    
    public func getTextMessageOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]? {
        var options = dataSource.getTextMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group, additionalConfiguration: additionalConfiguration)
        
        if !additionalConfiguration.hideTranslateMessageOption {
            let translationOption = textMessageOption(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group)
            options?.append(translationOption)
        }
        
        return options
    }
    
    func buildTextMessageContentView(message: TextMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView {
        
        let formatter = additionalConfiguration?.textFormatter ?? []
        
        let translatedTextBubble = CometChatMessageTranslationBubbleSwiftUI()
            .set(message: message)
            .set(controller: controller)
        
        if let translatedMessage = message.metaData?["translated-message"] as? String, !translatedMessage.isEmpty {
            let originalMessageString = message.text
            
            let translatedMessage = MessageUtils.processTextFormatter(for: message, customText: translatedMessage, in: UILabel(), textFormatter: formatter, controller: controller, alignment: alignment) ?? NSAttributedString(string: translatedMessage)
            
            let originalMessage = MessageUtils.processTextFormatter(for: message, customText: originalMessageString, in: UILabel(), textFormatter: formatter, controller: controller, alignment: alignment) ?? NSAttributedString(string: message.text)
            
            translatedTextBubble.set(originalMessage: originalMessage, translatedMessage: translatedMessage)
            
            let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)
            let messageBubbleStyle = isLoggedInUser ? additionalConfiguration?.messageBubbleStyle.outgoing : additionalConfiguration?.messageBubbleStyle.incoming
            
            if let style = messageBubbleStyle?.messageTranslationBubbleStyle {
                translatedTextBubble.set(style: style)
            }
        }
        
        return translatedTextBubble.toUIKit()
    }
    
    private func textMessageOption(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?) -> CometChatMessageOption {
        return CometChatMessageOption(id: ExtensionConstants.messageTranslation, title: "TRANSLATE_MESSAGE".localize(), icon: AssetConstants.translate) { message in
            self.translateMessage(messageObject: messageObject, controller: controller)
        }
    }
    
    private func openCometChatDialog() {
        let confirmDialog = CometChatDialog()
        confirmDialog.set(messageText: "NO_TRANSLATION_AVAILABLE".localize())
        confirmDialog.set(confirmButtonText: "OK".localize())
        confirmDialog.open(onConfirm: {})
    }
    
    private func translateMessage(messageObject: BaseMessage, controller: UIViewController?) {
        var textMessage: TextMessage?
        if let message = messageObject as? TextMessage {
            textMessage = message
            let systemLanguage = Locale.preferredLanguages.first?.replacingOccurrences(of: "-US", with: "")
            
            let spannedStringForMention = MessageUtils.wrapRegexMatches(in: textMessage?.text ?? "", regexPattern: CometChatMentionsFormatter().getRegex())
            
            CometChat.callExtension(slug: ExtensionConstants.messageTranslation, type: .post, endPoint: "v2/translate", body: ["msgId": message.id, "languages": [systemLanguage], "text": spannedStringForMention] as [String: Any], onSuccess: { (response) in
                DispatchQueue.main.async {
                    if let response = response, let originalLanguage = response["language_original"] as? String {
                        if originalLanguage == systemLanguage {
                            self.openCometChatDialog()
                        } else {
                            if let translatedLanguages = response["translations"] as? [[String: Any]] {
                                for tranlates in translatedLanguages {
                                    if let languageTranslated = tranlates["language_translated"] as? String,
                                       let messageTranslated = tranlates["message_translated"] as? String {
                                        if var metaData = textMessage?.metaData {
                                            metaData.append(with: ["translated-message": MessageUtils.removeSpanWrapping(in: messageTranslated)])
                                            textMessage?.metaData = metaData
                                        } else {
                                            textMessage?.metaData = ["translated-message": MessageUtils.removeSpanWrapping(in: messageTranslated)]
                                        }
                                        if let textMessage = textMessage {
                                            CometChatMessageEvents.onMessageEdited(message: textMessage)
                                        } else {
                                            self.openCometChatDialog()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }) { (error) in
                if let error = error {
                    let confirmDialog = CometChatDialog()
                    confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                    confirmDialog.set(cancelButtonText: "CANCEL".localize())
                    confirmDialog.set(error: CometChatServerError.get(error: error))
                    confirmDialog.open(onConfirm: { [weak self] in
                        guard let strongSelf = self else { return }
                    })
                }
            }
        }
    }
    
    
    public func getAudioMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: AudioBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        return dataSource.getAudioMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getFileMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FileBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        return dataSource.getFileMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getImageMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: ImageBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        return dataSource.getImageMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getVideoMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: VideoBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        return dataSource.getVideoMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getGroupActionMessageContentView(message: ActionMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: ActionMessageStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        return dataSource.getGroupActionMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getCustomMessageContentView(message: CustomMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: CustomMessageBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        return dataSource.getCustomMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getFormMessageContentView(message: CustomMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FormBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        return dataSource.getFormMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getSchedulerMessageContentView(message: CustomMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: SchedulerBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        return dataSource.getSchedulerMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getCardMessageContentView(message: CustomMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: CardBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        return dataSource.getCardMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
}
