//
//
//

import Foundation
import CometChatSDK
import SwiftUI
import Combine

public class ProfanityDataMaskingExtensionDecoratorSwiftUI: DataSourceDecorator {
    
    private var cancellables = Set<AnyCancellable>()
    
    override init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
    }
    
    public override func getTextMessageBubble(messageText: String?, message: TextMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        guard let message = message else { return nil }
        let filteredText = ProfanityDataMaskingExtensionDecoratorSwiftUI.getContentText(message: message)
        return super.getTextMessageBubble(messageText: filteredText, message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public override func getLastConversationMessage(conversation: Conversation, additionalConfiguration: AdditionalConfiguration?) -> NSAttributedString? {
        if let textMessage = conversation.lastMessage as? TextMessage, checkProfanityDataMasking(in: textMessage) {
            textMessage.text = ProfanityDataMaskingExtensionDecoratorSwiftUI.getContentText(message: textMessage)
            if let textFormatter = additionalConfiguration?.textFormatter, !textFormatter.isEmpty {
                return MessageUtils.processTextFormatter(message: textMessage, textFormatter: textFormatter, formattingType: .CONVERSATION_LIST)
            }
        }
        return super.getLastConversationMessage(conversation: conversation, additionalConfiguration: additionalConfiguration)
    }
    
    public static func getContentText(message: TextMessage) -> String {
        var text = checkProfanityMessage(message: message)
        if text == message.text {
            text = checkDataMasking(message: message)
        }
        return text
    }
    
    public static func checkProfanityMessage(message: TextMessage) -> String {
        var result = (message as TextMessage).text
        if let map = ExtensionModerator.extensionCheck(baseMessage: message), !map.isEmpty && map.containsKey(ExtensionConstants.profanityFilter), let profanityFilter = map[ExtensionConstants.profanityFilter], let profanity = profanityFilter["profanity"] as? String, let cleanMessage = profanityFilter["message_clean"] as? String {
            if (profanity == "no") {
                result = message.text
            } else {
                result = cleanMessage
            }
        } else {
            result = message.text
        }
        return result
    }
    
    func checkProfanityDataMasking(in message: TextMessage) -> Bool {
        
        if let map = ExtensionModerator.extensionCheck(baseMessage: message), !map.isEmpty && map.containsKey(ExtensionConstants.profanityFilter), let profanityFilter = map[ExtensionConstants.profanityFilter], let profanity = profanityFilter["profanity"] as? String {
            if (profanity != "no") {
                return true
            }
        }
        
        if let map = ExtensionModerator.extensionCheck(baseMessage: message), message.sender?.uid != CometChat.getLoggedInUser()?.uid ,!map.isEmpty && map.containsKey(ExtensionConstants.dataMasking), let dataMaskingDict = map[ExtensionConstants.dataMasking], let dataMasking = dataMaskingDict["data"] as? [String:Any], let sensitiveData = dataMasking["sensitive_data"] as? String {
            if (sensitiveData != "no") {
                return true
            }
        }
        
        return false
    }
    
    public static func checkDataMasking(message: TextMessage) -> String {
        var result = (message as TextMessage).text
        if let map = ExtensionModerator.extensionCheck(baseMessage: message), message.sender?.uid != CometChat.getLoggedInUser()?.uid ,!map.isEmpty && map.containsKey(ExtensionConstants.dataMasking), let dataMaskingDict = map[ExtensionConstants.dataMasking], let dataMasking = dataMaskingDict["data"] as? [String:Any], let sensitiveData = dataMasking["sensitive_data"] as? String, let messageMasked = dataMasking["message_masked"] as? String {
            
            if (sensitiveData == "no") {
                result = message.text
            } else {
                result = messageMasked
            }
        } else {
            result = message.text
        }
        return result
    }
    
    public override func getId() -> String {
        return "profanity-filter"
    }
    
    public func processText(for message: TextMessage) -> AnyPublisher<String, Never> {
        return Just(ProfanityDataMaskingExtensionDecoratorSwiftUI.getContentText(message: message))
            .eraseToAnyPublisher()
    }
    
    public func processConversationText(for conversation: Conversation) -> AnyPublisher<NSAttributedString?, Never> {
        if let textMessage = conversation.lastMessage as? TextMessage, checkProfanityDataMasking(in: textMessage) {
            textMessage.text = ProfanityDataMaskingExtensionDecoratorSwiftUI.getContentText(message: textMessage)
            if let additionalConfiguration = conversation.additionalData as? AdditionalConfiguration, 
               let textFormatter = additionalConfiguration.textFormatter, 
               !textFormatter.isEmpty {
                return Just(MessageUtils.processTextFormatter(message: textMessage, textFormatter: textFormatter, formattingType: .CONVERSATION_LIST))
                    .eraseToAnyPublisher()
            }
        }
        return Just(nil)
            .eraseToAnyPublisher()
    }
}
