//
//
//

import Foundation
import CometChatSDK
import SwiftUI
import Combine

public class ConversationsViewModelSwiftUI: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var filteredConversations: [Conversation] = []
    @Published var selectedConversations: [Conversation] = []
    @Published var isLoading: Bool = false
    @Published var hasError: Bool = false
    @Published var errorMessage: String = ""
    
    private var conversationRequest: ConversationRequest?
    private var refereshConversationRequest: ConversationRequest?
    private var conversationRequestBuilder: ConversationRequest.ConversationRequestBuilder
    private var listenerRandomID = Date().timeIntervalSince1970
    
    var isFetching = false
    var isFetchedAll = false
    var isRefresh: Bool = false {
        didSet {
            if isRefresh {
                self.fetchConversations()
            }
        }
    }
    
    var disableReceipt: Bool = false
    var enableSoundForConversation: Bool = true
    var customSoundForConversations: URL?
    
    var onNewMessageReceived: ((BaseMessage) -> Void)?
    var onError: ((CometChatException) -> Void)?
    var onTypingStatusChanged: ((Int, TypingIndicator, Bool) -> Void)?
    
    public init(conversationRequestBuilder: ConversationRequest.ConversationRequestBuilder = ConversationsBuilder.getDefaultRequestBuilder()) {
        self.conversationRequestBuilder = conversationRequestBuilder.with(blockedInfo: true)
        self.conversationRequest = conversationRequestBuilder.build()
    }
    
    deinit {
        disconnect()
    }
    
    public func fetchConversations() {
        if isRefresh {
            isFetchedAll = false
            refereshConversationRequest = conversationRequestBuilder.build()
            self.conversationRequest = refereshConversationRequest
        }
        
        if isFetchedAll { return }
        
        isLoading = true
        isFetching = true
        
        ConversationsBuilder.fetchConversation(conversationRequest: conversationRequest!) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.isFetching = false
                
                switch result {
                case .success(let conversations):
                    if conversations.isEmpty {
                        self.isFetchedAll = true
                    }
                    
                    if self.isRefresh {
                        self.conversations = conversations
                    } else {
                        self.conversations.append(contentsOf: conversations)
                    }
                    
                    for conversation in self.conversations {
                        self.markAsDelivered(conversation: conversation)
                    }
                    
                case .failure(let error):
                    self.hasError = true
                    self.errorMessage = error.errorDescription
                    self.onError?(error)
                }
            }
        }
    }
    
    public func setRequestBuilder(conversationRequestBuilder: ConversationRequest.ConversationRequestBuilder) {
        self.conversationRequestBuilder = conversationRequestBuilder.with(blockedInfo: true)
        self.conversationRequest = conversationRequestBuilder.build()
    }
    
    func markAsDelivered(conversation: Conversation) {
        if !disableReceipt {
            if let message = conversation.lastMessage, message.deliveredAt == 0.0, message.senderUid != CometChat.getLoggedInUser()?.uid {
                CometChat.markAsDelivered(baseMessage: message)
            }
        }
    }
    
    func getConversationRow(with typingDetails: TypingIndicator) -> Int? {
        guard let row = self.conversations.firstIndex(where: {
            (
                ($0.conversationWith as? User)?.uid == typingDetails.sender?.uid &&
                typingDetails.receiverType == .user
            ) ||
            (
                ($0.conversationWith as? Group)?.guid == typingDetails.receiverID &&
                typingDetails.receiverType == .group
            )
        }) else { return nil }
        return row
    }
    
    func checkForConversationUpdate(action: ActionMessage? = nil) -> Bool {
        return CometChat.getConversationUpdateSettings().groupActions
    }
    
    func checkForConversationUpdate(message: BaseMessage) -> Bool {
        let settings = CometChat.getConversationUpdateSettings()
        if message.parentMessageId == 0 || settings.messageReplies == true {
            if let customMessage = message as? CustomMessage {
                if customMessage.updateConversation || settings.customMessages || ((customMessage.metaData?["incrementUnreadCount"] as? Bool) == true) {
                    return true
                } else {
                    return false
                }
            } else if let _ = (message as? Call) {
                return settings.callActivities
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    func update(group: Group) {
        if let conversationOfGroup = self.conversations.first(where: { ($0.conversationWith as? Group)?.guid == group.guid }) {
            conversationOfGroup.conversationWith = group
        }
    }
    
    func removerConversation(for entity: AppEntity) {
        if let conversationIndex = conversations.firstIndex(where: { conversation in
            if let user = conversation.conversationWith as? User, let entityUser = entity as? User {
                return user.uid == entityUser.uid
            } else if let group = conversation.conversationWith as? Group, let entityGroup = entity as? Group {
                return group.guid == entityGroup.guid
            }
            return false
        }) {
            removeAt(at: conversationIndex)
        }
    }
    
    func add(conversation: Conversation) -> Self {
        if !self.conversations.contains(obj: conversation) {
            DispatchQueue.main.async {
                self.conversations.append(conversation)
            }
        }
        return self
    }
    
    func insert(conversation: Conversation, at: Int = 0) {
        DispatchQueue.main.async {
            self.conversations.insert(conversation, at: at)
        }
    }
    
    func update(conversation: Conversation) {
        markAsDelivered(conversation: conversation)
        if let currentRow = conversations.firstIndex(where: {
            return $0.conversationId == conversation.conversationId
        }) {
            DispatchQueue.main.async {
                self.conversations[currentRow] = conversation
            }
        }
    }
    
    func update(lastMessage: BaseMessage, updateCount: Bool = true) {
        if let conversation = CometChat.getConversationFromMessage(lastMessage) {
            if let existingConversation = conversations.first(where: {
                lastMessage.conversationId == $0.conversationId
            }) {
                if !LoggedInUserInformation.isLoggedInUser(uid: lastMessage.sender?.uid) {
                    if updateCount && lastMessage.readAt == 0 {
                        conversation.unreadMessageCount = existingConversation.unreadMessageCount + 1
                    } else {
                        conversation.unreadMessageCount = existingConversation.unreadMessageCount
                    }
                }
                moveToTop(conversation: conversation)
                update(conversation: conversation)
            } else {
                if !LoggedInUserInformation.isLoggedInUser(uid: lastMessage.sender?.uid) {
                    conversation.unreadMessageCount = 1
                }
                self.insert(conversation: conversation)
            }
        }
    }
    
    func updateAlreadyPresent(lastMessage: BaseMessage) {
        if let existingConversation = conversations.first(where: {
            lastMessage.conversationId == $0.conversationId
        }) {
            if existingConversation.lastMessage?.id == lastMessage.id {
                if let updatedConversation = CometChat.getConversationFromMessage(lastMessage) {
                    updatedConversation.unreadMessageCount = existingConversation.unreadMessageCount
                    moveToTop(conversation: updatedConversation)
                    update(conversation: updatedConversation)
                }
            }
        }
    }
    
    @discardableResult
    public func remove(conversation: Conversation) -> Self {
        if let index = conversations.firstIndex(of: conversation) {
            DispatchQueue.main.async {
                self.conversations.remove(at: index)
            }
        }
        return self
    }
    
    @discardableResult
    public func delete(conversation: Conversation) -> Self {
        guard let id = conversation.conversationType == .user ? (conversation.conversationWith as? User)?.uid! : (conversation.conversationWith as? Group)?.guid else { return self }
        
        let type: CometChat.ConversationType = conversation.conversationType == .user ? .user : .group
        
        CometChat.deleteConversation(conversationWith: id, conversationType: type) { [weak self] success in
            guard let self = self else { return }
            self.remove(conversation: conversation)
        } onError: { [weak self] error in
            guard let error = error, let self = self else { return }
            DispatchQueue.main.async {
                self.hasError = true
                self.errorMessage = error.errorDescription
                self.onError?(error)
            }
        }
        return self
    }
    
    public func moveToTop(conversation: Conversation) {
        guard let row = conversations.firstIndex(where: {$0.conversationId == conversation.conversationId}) else { return }
        
        DispatchQueue.main.async {
            self.conversations.remove(at: row)
            self.conversations.insert(conversation, at: 0)
        }
    }
    
    public func removeAt(at index: Int) {
        DispatchQueue.main.async {
            self.conversations.remove(at: index)
        }
    }
    
    public func clearList() {
        DispatchQueue.main.async {
            self.conversations.removeAll()
        }
    }
    
    public func size() -> Int {
        return self.conversations.count
    }
    
    func disable(receipt: Bool) {
        self.disableReceipt = receipt
    }
    
    func connect() {
        CometChat.addUserListener("conversations-list-users-sdk-listner-\(listenerRandomID)", self as? CometChatUserDelegate)
        CometChatUserEvents.addListener("conversations-list-user-event-listener-\(listenerRandomID)", self as? CometChatUserEventListener)
        CometChat.addGroupListener("conversations-list-groups-sdk-listner-\(listenerRandomID)", self as? CometChatGroupDelegate)
        CometChatGroupEvents.addListener("conversations-list-groups-event-listner-\(listenerRandomID)", self as? CometChatGroupEventListener)
        CometChatMessageEvents.addListener("conversations-list-messages-event-listener-\(listenerRandomID)", self as? CometChatMessageEventListener)
        CometChatCallEvents.addListener("conversations-list-call-event-listener-\(listenerRandomID)", self as? CometChatCallEventListener)
        CometChat.addCallListener("conversations-list-call-sdk-listener-\(listenerRandomID)", self as? CometChatCallDelegate)
    }
    
    func disconnect() {
        CometChat.removeUserListener("conversations-list-users-sdk-listner-\(listenerRandomID)")
        CometChatUserEvents.removeListener("conversations-list-user-event-listener-\(listenerRandomID)")
        CometChat.removeGroupListener("conversations-list-groups-sdk-listner-\(listenerRandomID)")
        CometChatGroupEvents.removeListener("conversations-list-groups-event-listner-\(listenerRandomID)")
        CometChatMessageEvents.removeListener("conversations-list-messages-event-listener-\(listenerRandomID)")
        CometChatCallEvents.removeListener("conversations-list-call-event-listener-\(listenerRandomID)")
        CometChat.removeCallListener("conversations-list-call-sdk-listener-\(listenerRandomID)")
    }
}
