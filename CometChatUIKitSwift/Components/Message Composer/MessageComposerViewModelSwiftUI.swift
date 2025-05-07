//
//
//

import Foundation
import CometChatSDK
import SwiftUI
import Combine

public class MessageComposerViewModelSwiftUI: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var hasError: Bool = false
    @Published var errorMessage: String = ""
    
    var user: User?
    var group: Group?
    var message: BaseMessage?
    var parentMessageId: Int?
    var textFormatter = ChatConfigurator.getDataSource().getTextFormatters()
    var textFormatterMap = [Character: CometChatTextFormatter]()
    var listenerRandomId = Date().timeIntervalSince1970
    var typingWorkItem: DispatchWorkItem?
    
    var reset: ((Bool) -> Void)?
    var onMessageEdit: ((BaseMessage) -> Void)?
    var isSoundForMessageEnabled: (() -> Void)?
    var failure: ((CometChatException) -> Void)?
    
    public init() {
        setupTextFormatterMap()
    }
    
    func setupBaseMessage(message: String, textFormatter: [Character: [(item: SuggestionItem, range: NSRange)]]) -> BaseMessage {
        let textMessage = TextMessage(receiverUid: user?.uid ?? "", text: message, receiverType: user != nil ? .user : .group)
        
        if let group = group {
            textMessage.receiverUid = group.guid
        }
        
        if let parentMessageId = parentMessageId, parentMessageId != 0 {
            textMessage.parentMessageId = parentMessageId
        }
        
        return textMessage
    }
    
    func setupBaseMessage(url: String) -> BaseMessage {
        let mediaMessage = MediaMessage(receiverUid: user?.uid ?? "", fileURL: url, messageType: .audio, receiverType: user != nil ? .user : .group)
        
        if let group = group {
            mediaMessage.receiverUid = group.guid
        }
        
        if let parentMessageId = parentMessageId, parentMessageId != 0 {
            mediaMessage.parentMessageId = parentMessageId
        }
        
        return mediaMessage
    }
    
    func sendTextMessageToUser(message: String, textFormatter: [Character: [(item: SuggestionItem, range: NSRange)]]) {
        guard let user = user else { return }
        
        let textMessage = TextMessage(receiverUid: user.uid, text: message, receiverType: .user)
        
        if let parentMessageId = parentMessageId, parentMessageId != 0 {
            textMessage.parentMessageId = parentMessageId
        }
        
        CometChat.sendTextMessage(message: textMessage) { [weak self] message in
            guard let self = self else { return }
            self.isSoundForMessageEnabled?()
            self.reset?(true)
        } onError: { [weak self] error in
            guard let self = self, let error = error else { return }
            self.failure?(error)
        }
    }
    
    func sendTextMessageToGroup(message: String, textFormatter: [Character: [(item: SuggestionItem, range: NSRange)]]) {
        guard let group = group else { return }
        
        let textMessage = TextMessage(receiverUid: group.guid, text: message, receiverType: .group)
        
        if let parentMessageId = parentMessageId, parentMessageId != 0 {
            textMessage.parentMessageId = parentMessageId
        }
        
        CometChat.sendTextMessage(message: textMessage) { [weak self] message in
            guard let self = self else { return }
            self.isSoundForMessageEnabled?()
            self.reset?(true)
        } onError: { [weak self] error in
            guard let self = self, let error = error else { return }
            self.failure?(error)
        }
    }
    
    func sendMediaMessageToUser(url: String, type: CometChat.MessageType) {
        guard let user = user else { return }
        
        let mediaMessage = MediaMessage(receiverUid: user.uid, fileURL: url, messageType: type, receiverType: .user)
        
        if let parentMessageId = parentMessageId, parentMessageId != 0 {
            mediaMessage.parentMessageId = parentMessageId
        }
        
        CometChat.sendMediaMessage(message: mediaMessage) { [weak self] message in
            guard let self = self else { return }
            self.isSoundForMessageEnabled?()
            self.reset?(true)
        } onError: { [weak self] error in
            guard let self = self, let error = error else { return }
            self.failure?(error)
        }
    }
    
    func sendMediaMessageToGroup(url: String, type: CometChat.MessageType) {
        guard let group = group else { return }
        
        let mediaMessage = MediaMessage(receiverUid: group.guid, fileURL: url, messageType: type, receiverType: .group)
        
        if let parentMessageId = parentMessageId, parentMessageId != 0 {
            mediaMessage.parentMessageId = parentMessageId
        }
        
        CometChat.sendMediaMessage(message: mediaMessage) { [weak self] message in
            guard let self = self else { return }
            self.isSoundForMessageEnabled?()
            self.reset?(true)
        } onError: { [weak self] error in
            guard let self = self, let error = error else { return }
            self.failure?(error)
        }
    }
    
    func editTextMessage(textMessage: TextMessage, message: String, textFormatter: [Character: [(item: SuggestionItem, range: NSRange)]]) {
        textMessage.text = message
        
        CometChat.editMessage(message: textMessage) { [weak self] message in
            guard let self = self else { return }
            self.reset?(true)
        } onError: { [weak self] error in
            guard let self = self, let error = error else { return }
            self.failure?(error)
        }
    }
    
    func sendTypingIndicator() {
        typingWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            if let user = self.user {
                CometChat.startTyping(indicator: TypingIndicator(receiverID: user.uid, receiverType: .user))
            } else if let group = self.group {
                CometChat.startTyping(indicator: TypingIndicator(receiverID: group.guid, receiverType: .group))
            }
        }
        
        typingWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }
    
    func endTypingIndicator() {
        typingWorkItem?.cancel()
        
        if let user = user {
            CometChat.endTyping(indicator: TypingIndicator(receiverID: user.uid, receiverType: .user))
        } else if let group = group {
            CometChat.endTyping(indicator: TypingIndicator(receiverID: group.guid, receiverType: .group))
        }
    }
    
    func getAttachmentOptions() -> [CometChatMessageComposerAction] {
        let additionalConfiguration = AdditionalConfiguration()
        additionalConfiguration.hideImageAttachmentOption = false
        additionalConfiguration.hideVideoAttachmentOption = false
        additionalConfiguration.hideFileAttachmentOption = false
        additionalConfiguration.hidePollsOption = false
        additionalConfiguration.hideCollaborativeDocumentOption = false
        additionalConfiguration.hideCollaborativeWhiteboardOption = false
        
        return ChatConfigurator.getDataSource().getAttachmentOptions(
            controller: UIApplication.shared.windows.first?.rootViewController ?? UIViewController(),
            user: user,
            group: group,
            id: getId(),
            additionalConfiguration: additionalConfiguration
        ) ?? MessageUtils.getDefaultAttachmentOptions(addtionalConfiguration: additionalConfiguration)
    }
    
    func getAIOptions() -> [CometChatMessageComposerAction] {
        let aiOptionsStyle = AIOptionsStyle()
        
        return ChatConfigurator.getDataSource().getAIOptions(
            controller: UIApplication.shared.windows.first?.rootViewController ?? UIViewController(),
            user: user,
            group: group,
            id: getId(),
            aiOptionsStyle: aiOptionsStyle
        ) ?? []
    }
    
    private func setupTextFormatterMap() {
        for formatter in textFormatter {
            if let character = formatter.getStartSymbol().first {
                textFormatterMap[character] = formatter
            }
        }
    }
    
    private func getId() -> [String: Any] {
        var id = [String: Any]()
        
        if let user = user {
            id["uid"] = user.uid
        }
        if let group = group {
            id["guid"] = group.guid
        }
        if let parentMessageId = parentMessageId, parentMessageId != 0 {
            id["parentMessageId"] = parentMessageId
        }
        
        return id
    }
    
    func connect() {
        CometChatUIEvents.addListener("composer-ui-event-listener-\(listenerRandomId)", self as? CometChatUIEventListener)
    }
    
    func disconnect() {
        CometChatUIEvents.removeListener("composer-ui-event-listener-\(listenerRandomId)")
        endTypingIndicator()
    }
}
