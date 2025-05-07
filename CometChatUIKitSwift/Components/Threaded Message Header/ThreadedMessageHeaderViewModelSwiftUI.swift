//
//
//

import Foundation
import CometChatSDK
import SwiftUI
import Combine

public class ThreadedMessageHeaderViewModelSwiftUI: ObservableObject {
    @Published var user: User?
    @Published var group: Group?
    @Published var parentMessage: BaseMessage? {
        didSet {
            self.user = parentMessage?.receiver as? User
            self.group = parentMessage?.receiver as? Group
        }
    }
    @Published var replyCount: Int = 0
    @Published var templates: [String: CometChatMessageTemplate]?
    
    public init() {}
    
    deinit {
        disconnect()
    }
    
    public func connect() {
        CometChatMessageEvents.addListener("threaded-messages-message-listener-swiftui", self as? CometChatMessageEventListener)
    }
    
    public func disconnect() {
        CometChatMessageEvents.removeListener("threaded-messages-message-listener-swiftui")
    }
    
    public func incrementCount() {
        DispatchQueue.main.async {
            self.replyCount += 1
        }
    }
    
    public func setReplyCount(_ count: Int) {
        DispatchQueue.main.async {
            self.replyCount = count
        }
    }
}

extension ThreadedMessageHeaderViewModelSwiftUI: CometChatMessageEventListener {
    public func onFormMessageReceived(message: FormMessage) {
        if message.parentMessageId == parentMessage?.id {
            incrementCount()
        }
    }
    
    public func onSchedulerMessageReceived(message: SchedulerMessage) {
        if message.parentMessageId == parentMessage?.id {
            incrementCount()
        }
    }
    
    public func onCardMessageReceived(message: CardMessage) {
        if message.parentMessageId == parentMessage?.id {
            incrementCount()
        }
    }
    
    public func onCustomInteractiveMessageReceived(message: CustomInteractiveMessage) {
        if message.parentMessageId == parentMessage?.id {
            incrementCount()
        }
    }
    
    public func ccMessageSent(message: BaseMessage, status: MessageStatus) {
        if parentMessage?.id == message.parentMessageId {
            switch status {
            case .inProgress:
                if let user = user {
                    if user.blockedByMe || user.hasBlockedMe {
                        break
                    } else {
                        incrementCount()
                    }
                } else {
                    incrementCount()
                }
            case .success, .error:
                break
            }
        }
    }
    
    public func onTextMessageReceived(textMessage: TextMessage) {
        if textMessage.parentMessageId == parentMessage?.id {
            incrementCount()
        }
    }
    
    public func onMediaMessageReceived(mediaMessage: MediaMessage) {
        if mediaMessage.parentMessageId == parentMessage?.id {
            incrementCount()
        }
    }
    
    public func onCustomMessageReceived(customMessage: CustomMessage) {
        if customMessage.parentMessageId == parentMessage?.id {
            incrementCount()
        }
    }
    
    public func onMessageEdited(message: BaseMessage) {
        if message.id == self.parentMessage?.id {
            DispatchQueue.main.async {
                self.parentMessage = message
            }
        }
    }
    
    public func onMessageDeleted(message: BaseMessage) {
        if message.id == self.parentMessage?.id {
            DispatchQueue.main.async {
                self.parentMessage = message
            }
        }
    }
    
    public func ccMessageDeleted(message: BaseMessage) {
        if message.id == self.parentMessage?.id {
            DispatchQueue.main.async {
                self.parentMessage?.deletedAt = Double(Int(NSDate().timeIntervalSince1970))
            }
        }
    }
    
    public func ccMessageEdited(message: BaseMessage, status: MessageStatus) {
        if message.id == self.parentMessage?.id {
            DispatchQueue.main.async {
                self.parentMessage = message
            }
        }
    }
}
